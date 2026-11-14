import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../core/net.dart';
import 'database/schema.dart';
import 'epg/xmltv.dart';
import 'repository.dart';
import 'sources/m3u_parser.dart';
import 'sources/models.dart';
import 'sources/stalker_client.dart';
import 'sources/xtream_client.dart';

// Isolate entry points are top-level so their closures capture nothing
// but the arguments (instance closures would drag in timers and sockets).
Future<M3uResult> _parseM3u(String text) => Isolate.run(() => M3uParser.parse(text));
Future<XmltvResult> _loadXmltv(XmltvRequest req) => Isolate.run(() => loadXmltv(req));

class RefreshProgress {
  RefreshProgress(this.stage, [this.fraction]);
  final String stage;
  final double? fraction;
}

/// Outcome of a refresh, for toasts and status rows.
class RefreshOutcome {
  RefreshOutcome.ok(this.live, this.movies, this.series,
      {this.warnings = const [], this.guideProgrammes, this.guideChannels, this.guideNote})
      : error = null;
  RefreshOutcome.failed(this.error)
      : live = 0,
        movies = 0,
        series = 0,
        warnings = const [],
        guideProgrammes = null,
        guideChannels = null,
        guideNote = null;
  final String? error;
  final int live;
  final int movies;
  final int series;

  /// Things that went wrong without failing the whole refresh (a section kept as it was, a guide problem…).
  final List<String> warnings;

  /// TV guide result: programmes saved and live channels that now have a guide. Null when the guide was not loaded.
  final int? guideProgrammes;
  final int? guideChannels;

  /// Why the guide could not be loaded, when it could not.
  final String? guideNote;
  bool get ok => error == null;
}

/// Loads catalogues from providers, keeps them fresh, resolves stream URLs.
class CatalogService {
  CatalogService(this.repo, {required this.userAgent});

  final Repository repo;
  final String Function() userAgent;
  final Net net = Net();

  /// sourceId → current refresh progress (absent = idle).
  final progress = ValueNotifier<Map<String, RefreshProgress>>({});
  final epgProgress = ValueNotifier<Set<String>>({});
  final _running = <String, Future<RefreshOutcome>>{};
  final _stalker = <String, StalkerClient>{};
  final _epgAttempt = <String, int>{};
  Timer? _timer;

  void _setProgress(String id, RefreshProgress? p) {
    final m = Map.of(progress.value);
    if (p == null) {
      m.remove(id);
    } else {
      m[id] = p;
    }
    progress.value = m;
  }

  XtreamClient xtream(Source s) => XtreamClient(
        server: s.server ?? '',
        username: s.username ?? '',
        password: s.password ?? '',
        userAgent: userAgent(),
        net: net,
      );

  StalkerClient stalker(Source s) => _stalker.putIfAbsent(
      s.id, () => StalkerClient(server: s.server ?? '', mac: s.mac ?? '', net: net));

  /// For an M3U URL that is really an Xtream link, the Xtream client.
  XtreamClient? _xtreamFromM3u(Source s) {
    final d = s.kind == SourceKind.m3u.key && s.url != null ? detectXtream(s.url!) : null;
    if (d == null) return null;
    return XtreamClient(
        server: d.server,
        username: d.username,
        password: d.password,
        userAgent: userAgent(),
        net: net);
  }

  /// Credentials check used by the Add-source form before saving.
  Future<String?> validate(SourceKind kind,
      {String? url, String? file, String? server, String? user, String? pass, String? mac}) async {
    try {
      switch (kind) {
        case SourceKind.xtream:
          await XtreamClient(
                  server: server ?? '',
                  username: user ?? '',
                  password: pass ?? '',
                  userAgent: userAgent(),
                  net: net)
              .account();
        case SourceKind.m3u:
          final uri = Uri.tryParse(url ?? '');
          if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
            return 'Enter a valid http(s) URL.';
          }
          final d = detectXtream(url!);
          if (d != null) {
            try {
              await XtreamClient(
                      server: d.server,
                      username: d.username,
                      password: d.password,
                      userAgent: userAgent(),
                      net: net)
                  .account();
              return null;
            } catch (_) {/* fall back to plain M3U */}
          }
          final text = await net.getText(uri, userAgent: userAgent(), timeout: const Duration(seconds: 90));
          M3uParser.parse(text);
        case SourceKind.file:
          if (file == null || !File(file).existsSync()) return 'File not found.';
          M3uParser.parse(decodeText(await File(file).readAsBytes()));
        case SourceKind.stalker:
          if (!StalkerClient.validMac(mac ?? '')) {
            return 'MAC address must look like 00:1A:79:XX:XX:XX.';
          }
          await StalkerClient(server: server ?? '', mac: mac!, net: net).connect();
      }
      return null;
    } on NetException catch (e) {
      return e.message;
    } on M3uFormatException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not load the source: $e';
    }
  }

  bool isRefreshing(String id) => _running.containsKey(id);

  Future<RefreshOutcome> refresh(Source s, {bool withEpg = true}) {
    return _running[s.id] ??= _refresh(s, withEpg).whenComplete(() {
      _running.remove(s.id);
      _setProgress(s.id, null);
    });
  }

  /// Replaces one section of the catalogue, unless the provider's answer looks broken:
  /// an empty list, or one that lost more than half of what was there before. A bad answer
  /// keeps the old list and is reported, so a server hiccup never wipes the channels.
  /// Returns true when the new list was saved.
  Future<bool> _replaceGuarded(Source s, ImportBatch batch, int? before, List<String> warnings) async {
    final now = batch.items.length;
    final prev = before ?? 0;
    final label = batch.type.label.toLowerCase();
    if (prev > 0 && now == 0) {
      warnings.add('The provider returned no $label this time, so the $prev $label from the last update were kept.');
      return false;
    }
    if (prev >= 40 && now * 2 < prev) {
      warnings.add('The provider returned only $now $label (was $prev), which looks incomplete, so the last list was kept. '
          'Update again in a few minutes.');
      return false;
    }
    await repo.replaceCatalog(s.id, batch);
    return true;
  }

  Future<RefreshOutcome> _refresh(Source s, bool withEpg) async {
    final counts = <ContentType, int>{};
    final warnings = <String>[];
    String? accountJson;
    final before = await repo.status(s.id);
    final prevCounts = <ContentType, int>{
      ContentType.live: before?.liveCount ?? 0,
      ContentType.movie: before?.movieCount ?? 0,
      ContentType.series: before?.seriesCount ?? 0,
    };
    try {
      final kind = SourceKind.of(s.kind);
      final missing = switch (kind) {
        SourceKind.xtream => (s.server ?? '').isEmpty || (s.username ?? '').isEmpty || (s.password ?? '').isEmpty,
        SourceKind.stalker => (s.server ?? '').isEmpty || (s.mac ?? '').isEmpty,
        SourceKind.m3u => (s.url ?? '').isEmpty,
        SourceKind.file => (s.filePath ?? '').isEmpty,
      };
      if (missing) {
        throw NetException(kind == SourceKind.file
            ? 'This playlist file is on another device. Edit the source to choose the file on this Mac.'
            : 'The login details for this source were not synced to this Mac (sync has no passphrase). '
                'Edit the source to enter them, or set the same sync passphrase on every device.');
      }
      final xc = kind == SourceKind.xtream ? xtream(s) : _xtreamFromM3u(s);
      if (xc != null) {
        _setProgress(s.id, RefreshProgress('Connecting…'));
        Map<String, dynamic>? acct;
        try {
          acct = await xc.account();
        } catch (e) {
          if (kind == SourceKind.xtream) rethrow;
        }
        if (acct != null) {
          accountJson = jsonEncode(acct);
          var step = 0;
          Object? firstError;
          var loaded = 0;
          for (final t in ContentType.values) {
            _setProgress(s.id, RefreshProgress('Loading ${t.label}…', step++ / 3));
            try {
              final batch = await xc.fetch(t);
              final saved = await _replaceGuarded(s, batch, prevCounts[t], warnings);
              counts[t] = saved ? batch.items.length : prevCounts[t] ?? 0;
              loaded++;
            } catch (e) {
              // One section failing must not lose the others: keep its old list and carry on.
              firstError ??= e;
              counts[t] = prevCounts[t] ?? 0;
              warnings.add('Could not load ${t.label.toLowerCase()}: ${e is NetException ? e.message : e}. '
                  'The last list was kept.');
            }
          }
          if (loaded == 0 && firstError != null) throw firstError;
          await repo.clearSeriesCache(s.id);
          await repo.cachePut('epg_urls:${s.id}', jsonEncode([xc.xmltvUri.toString()]));
        }
      }
      if (counts.isEmpty && (kind == SourceKind.m3u || kind == SourceKind.file)) {
        _setProgress(s.id, RefreshProgress('Downloading playlist…'));
        final String text;
        if (kind == SourceKind.file) {
          final f = File(s.filePath ?? '');
          if (!f.existsSync()) {
            throw NetException('The playlist file is no longer at ${s.filePath}.');
          }
          text = decodeText(await f.readAsBytes());
        } else {
          text = await net.getText(Uri.parse(s.url!),
              userAgent: userAgent(),
              timeout: const Duration(seconds: 120), onProgress: (got, total) {
            _setProgress(
                s.id,
                RefreshProgress('Downloading playlist… ${(got / 1048576).toStringAsFixed(1)} MB',
                    total == null ? null : got / total));
          });
        }
        _setProgress(s.id, RefreshProgress('Reading playlist…'));
        final result = await _parseM3u(text);
        for (final t in ContentType.values) {
          _setProgress(s.id, RefreshProgress('Saving ${t.label}…'));
          final batch = result.batches[t]!;
          final saved = await _replaceGuarded(s, batch, prevCounts[t], warnings);
          counts[t] = saved ? batch.items.length : prevCounts[t] ?? 0;
        }
        await repo.clearSeriesCache(s.id);
        for (final e in result.series.entries) {
          await repo.putSeriesDetail(s.id, e.key, e.value);
        }
        await repo.cachePut('epg_urls:${s.id}', jsonEncode(result.epgUrls));
      } else if (kind == SourceKind.stalker) {
        final sc = stalker(s);
        var step = 0;
        for (final t in ContentType.values) {
          _setProgress(s.id, RefreshProgress('Loading ${t.label}…', step++ / 3));
          try {
            final batch = await sc.fetch(t);
            await repo.replaceCatalog(s.id, batch);
            counts[t] = batch.items.length;
          } catch (e) {
            if (t == ContentType.live) rethrow; // VOD is optional on portals
          }
        }
      }
      final prev = await repo.status(s.id);
      await repo.writeStatus(SourceStatusCompanion(
        sourceId: Value(s.id),
        lastRefresh: Value(DateTime.now().millisecondsSinceEpoch),
        lastError: const Value(null),
        liveCount: Value(counts[ContentType.live] ?? 0),
        movieCount: Value(counts[ContentType.movie] ?? 0),
        seriesCount: Value(counts[ContentType.series] ?? 0),
        accountJson: Value(accountJson ?? prev?.accountJson),
      ));
      int? guideProgrammes, guideChannels;
      String? guideNote;
      if (withEpg && s.epgEnabled) {
        _setProgress(s.id, RefreshProgress('Loading TV guide…'));
        guideNote = await refreshEpg(s);
        final st = await repo.status(s.id);
        guideProgrammes = st?.epgProgrammes;
        guideChannels = await repo.guideCoverage(s.id);
      }
      return RefreshOutcome.ok(counts[ContentType.live] ?? 0,
          counts[ContentType.movie] ?? 0, counts[ContentType.series] ?? 0,
          warnings: warnings, guideProgrammes: guideProgrammes, guideChannels: guideChannels, guideNote: guideNote);
    } catch (e) {
      final msg = e is NetException || e is M3uFormatException ? e.toString() : 'Refresh failed: $e';
      final prev = await repo.status(s.id);
      await repo.writeStatus(SourceStatusCompanion(
        sourceId: Value(s.id),
        lastRefresh: Value(prev?.lastRefresh ?? 0),
        lastError: Value(msg),
      ));
      return RefreshOutcome.failed(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // EPG
  // ---------------------------------------------------------------------------

  Future<List<String>> epgUrls(Source s) async {
    if (s.epgUrl != null && s.epgUrl!.trim().isNotEmpty) {
      return s.epgUrl!.split(RegExp(r'[\s,]+')).where((u) => u.isNotEmpty).toList();
    }
    final cached = await repo.cacheGet('epg_urls:${s.id}');
    if (cached != null) return (jsonDecode(cached) as List).cast<String>();
    if (s.kind == SourceKind.xtream.key) return [xtream(s).xmltvUri.toString()];
    return [];
  }

  Future<String?> refreshEpg(Source s) async {
    if (epgProgress.value.contains(s.id)) return null;
    epgProgress.value = {...epgProgress.value, s.id};
    _epgAttempt[s.id] = DateTime.now().millisecondsSinceEpoch;
    try {
      final urls = await epgUrls(s);
      if (urls.isEmpty) {
        const msg = 'This source has no TV guide link. Set a Guide URL (XMLTV) for it in Settings → Manage sources.';
        await _epgStatus(s.id, error: msg);
        return msg;
      }
      final channels = await repo.liveChannelsForEpg(s.id);
      final req = XmltvRequest(urls: urls, channels: channels, userAgent: userAgent());
      final res = await _loadXmltv(req);
      if (res.programmes.isEmpty && res.errors.isNotEmpty) {
        await _epgStatus(s.id, error: res.errors.join('\n'));
        return res.errors.join('\n');
      }
      await repo.replaceEpg(s.id, res.programmes, res.matches);
      final err = res.errors.isEmpty
          ? (res.programmes.isEmpty ? 'The EPG loaded but no programmes matched your channels.' : null)
          : res.errors.join('\n');
      await _epgStatus(s.id, error: err, count: res.programmes.length, ok: true);
      return err;
    } catch (e) {
      await _epgStatus(s.id, error: 'EPG refresh failed: $e');
      return 'EPG refresh failed: $e';
    } finally {
      epgProgress.value = {...epgProgress.value}..remove(s.id);
    }
  }

  Future<void> _epgStatus(String id, {String? error, int? count, bool ok = false}) async {
    final prev = await repo.status(id);
    await repo.writeStatus(SourceStatusCompanion(
      sourceId: Value(id),
      lastRefresh: Value(prev?.lastRefresh ?? 0),
      lastEpgRefresh: ok ? Value(DateTime.now().millisecondsSinceEpoch) : Value(prev?.lastEpgRefresh ?? 0),
      epgError: Value(error),
      epgProgrammes: Value(count ?? prev?.epgProgrammes ?? 0),
    ));
    repo.catalogChanges.add(id);
  }

  /// Current/next programmes for live channels; XMLTV first, then the
  /// provider's short EPG for a single channel when XMLTV has nothing.
  Future<List<Programme>> channelGuide(Source s, ItemView ch,
      {Duration back = const Duration(hours: 6), Duration ahead = const Duration(hours: 24)}) async {
    final now = DateTime.now();
    if (ch.epgId != null) {
      final m = await repo.programmes(s.id, [ch.epgId!], now.subtract(back), now.add(ahead),
          offsetMin: s.epgOffsetMin);
      final list = m[ch.epgId!];
      if (list != null && list.isNotEmpty) return list;
    }
    try {
      final key = 'short_epg:${s.id}:${ch.id}';
      final cached = await repo.cacheGet(key, maxAge: const Duration(minutes: 30));
      List<Programme> progs;
      if (cached != null) {
        progs = [
          for (final p in jsonDecode(cached) as List)
            Programme(
                start: DateTime.fromMillisecondsSinceEpoch(p[0] as int),
                stop: DateTime.fromMillisecondsSinceEpoch(p[1] as int),
                title: p[2] as String,
                description: p[3] as String?)
        ];
      } else if (s.kind == SourceKind.xtream.key || _xtreamFromM3u(s) != null) {
        progs = await (_xtreamFromM3u(s) ?? xtream(s)).shortEpg(ch.id);
        await repo.cachePut(key, jsonEncode([
          for (final p in progs)
            [p.start.millisecondsSinceEpoch, p.stop.millisecondsSinceEpoch, p.title, p.description]
        ]));
      } else if (s.kind == SourceKind.stalker.key) {
        progs = await stalker(s).shortEpg(ch.id);
      } else {
        progs = const [];
      }
      return progs.where((p) => p.stop.isAfter(now.subtract(back))).toList();
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // Details & URLs
  // ---------------------------------------------------------------------------

  Future<MovieDetail?> movieDetail(Source s, ItemView m) async {
    final key = 'vod_info:${s.id}:${m.id}';
    final cached = await repo.cacheGet(key, maxAge: const Duration(days: 7));
    if (cached != null) {
      return MovieDetail.fromJson((jsonDecode(cached) as Map).cast<String, dynamic>());
    }
    final xc = s.kind == SourceKind.xtream.key ? xtream(s) : _xtreamFromM3u(s);
    if (xc == null) {
      return MovieDetail(plot: m.plot, tmdbId: m.tmdbId);
    }
    final d = await xc.vodInfo(m.id);
    await repo.cachePut(key, jsonEncode(d.toJson()));
    return d;
  }

  Future<SeriesDetail> seriesDetail(Source s, ItemView series, {bool force = false}) async {
    final cached = await repo.seriesDetail(s.id, series.id);
    final xc = s.kind == SourceKind.xtream.key ? xtream(s) : _xtreamFromM3u(s);
    final fresh = cached != null &&
        (xc == null ||
            DateTime.now().millisecondsSinceEpoch - cached.$2 < const Duration(hours: 12).inMilliseconds);
    if (cached != null && (fresh && !force || xc == null)) return cached.$1;
    if (xc == null) {
      throw NetException('Episodes for this series are not available. Try refreshing the source.');
    }
    final d = await xc.seriesInfo(series.id);
    await repo.putSeriesDetail(s.id, series.id, d);
    return d;
  }

  Future<String> streamUrl(Source s, ItemView item) async {
    final xc = s.kind == SourceKind.xtream.key ? xtream(s) : _xtreamFromM3u(s);
    if (item.url != null && item.url!.startsWith('stalker:')) {
      return stalker(s).createLink(item.type, item.url!.substring(8));
    }
    if (item.url != null && item.url!.isNotEmpty) return item.url!;
    if (xc == null) throw NetException('No stream URL for "${item.name}".');
    return switch (item.type) {
      ContentType.live => xc.liveUrl(item.id),
      ContentType.movie => xc.movieUrl(item.id, item.ext ?? 'mp4'),
      ContentType.series => throw StateError('series has no direct stream'),
    };
  }

  Future<String> episodeUrl(Source s, EpisodeInfo e) async {
    if (e.url != null && e.url!.isNotEmpty) return e.url!;
    final xc = s.kind == SourceKind.xtream.key ? xtream(s) : _xtreamFromM3u(s);
    if (xc == null) throw NetException('No stream URL for this episode.');
    return xc.episodeUrl(e.id, e.ext ?? 'mp4');
  }

  /// Catch-up URL for a past programme, or null if unsupported.
  String? catchupUrl(Source s, ItemView ch, Programme p) {
    if (ch.archiveDays <= 0) return null;
    final xc = s.kind == SourceKind.xtream.key ? xtream(s) : _xtreamFromM3u(s);
    if (xc != null) {
      return xc.timeshiftUrl(ch.id, p.start, p.stop.difference(p.start));
    }
    if (ch.url == null) return null;
    return m3uCatchupUrl(ch.url!, ch.extra, p.start, p.stop);
  }

  // ---------------------------------------------------------------------------
  // Scheduler
  // ---------------------------------------------------------------------------

  /// Checks every few minutes whether a source or its EPG is due.
  void startScheduler() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => checkDue());
    Future.delayed(const Duration(seconds: 3), checkDue);
  }

  Future<void> checkDue() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final s in await repo.sources()) {
      final st = await repo.status(s.id);
      final last = st?.lastRefresh ?? 0;
      final neverLoaded = last == 0 && st?.lastError == null;
      if (neverLoaded || (s.refreshHours > 0 && now - last >= s.refreshHours * 3600000)) {
        if (!isRefreshing(s.id)) await refresh(s);
        continue;
      }
      final lastEpg = st?.lastEpgRefresh ?? 0;
      final stale = (await repo.latestProgrammeEnd(s.id) ?? 0) * 1000 < now;
      final recentlyTried = now - (_epgAttempt[s.id] ?? 0) < 3600000;
      if (s.epgEnabled &&
          s.epgRefreshHours > 0 &&
          !recentlyTried &&
          (now - lastEpg >= s.epgRefreshHours * 3600000 || (stale && now - lastEpg > 3600000))) {
        await refreshEpg(s);
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    net.close();
  }
}


/// Fills an M3U `catchup-source` template for a past programme.
/// Returns null when the channel has no usable catch-up template.
String? m3uCatchupUrl(String channelUrl, Map<String, dynamic>? extra, DateTime start, DateTime stop,
    {DateTime? now}) {
  final tpl = extra?['catchupSource'] as String?;
  if (tpl == null) return null;
  final s = start.toUtc().millisecondsSinceEpoch ~/ 1000;
  final e = stop.toUtc().millisecondsSinceEpoch ~/ 1000;
  final n = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
  final filled = tpl
      .replaceAll('{utc}', '$s')
      .replaceAll('\${start}', '$s')
      .replaceAll('{utcend}', '$e')
      .replaceAll('\${end}', '$e')
      .replaceAll('{lutc}', '$n')
      .replaceAll('{duration}', '${e - s}');
  if (filled.startsWith('http')) return filled;
  final mode = extra?['catchup'];
  return mode == 'append' || mode == 'shift' ? '$channelUrl$filled' : null;
}
