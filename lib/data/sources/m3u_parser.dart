import '../../core/text.dart';
import 'models.dart';

/// Result of parsing an M3U/M3U8 playlist.
class M3uResult {
  M3uResult({
    required this.batches,
    required this.series,
    required this.epgUrls,
    required this.entryCount,
  });
  final Map<ContentType, ImportBatch> batches;

  /// Series assembled from "Show S01 E02" style entries, keyed by series id.
  final Map<String, SeriesDetail> series;
  final List<String> epgUrls;
  final int entryCount;
}

class M3uFormatException implements Exception {
  M3uFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Streaming-friendly M3U parser.
///
/// Understands `#EXTM3U url-tvg=/x-tvg-url=`, `#EXTINF` attributes
/// (tvg-id, tvg-name, tvg-logo, group-title, catchup, catchup-days,
/// catchup-source, tvg-rec), `#EXTGRP`, and `#EXTVLCOPT:http-user-agent`.
///
/// Type detection: `/movie/` → movie, `/series/` → episode of a series,
/// a video file extension → movie, everything else → live.
class M3uParser {
  static final _attrRe = RegExp(r'([A-Za-z0-9_-]+)="([^"]*)"');
  static final _seRe = RegExp(
      r'^(.*?)[\s._-]*(?:S(\d{1,3})[\s._-]*E(\d{1,4})|(\d{1,2})x(\d{2,3}))\b',
      caseSensitive: false);
  static const _videoExt = {'mp4', 'mkv', 'avi', 'mov', 'm4v', 'wmv', 'flv', 'webm', 'mpg', 'mpeg'};

  static M3uResult parse(String content) {
    final text = content.startsWith('﻿') ? content.substring(1) : content;
    final lines = text.split(RegExp(r'\r\n|\n|\r'));
    final firstReal = lines.firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    if (!firstReal.trim().startsWith('#EXTM3U') && !text.contains('#EXTINF')) {
      throw M3uFormatException(
          'This file is not an M3U playlist (no #EXTM3U / #EXTINF lines found).');
    }

    final epgUrls = <String>[];
    final cats = {
      for (final t in ContentType.values) t: <String, ImportedCategory>{}
    };
    final items = {for (final t in ContentType.values) t: <ImportedItem>[]};
    final seriesEps = <String, List<EpisodeInfo>>{};
    final seriesSeen = <String, ImportedItem>{};
    var count = 0;

    Map<String, String> attrs = {};
    String? title;
    String? group;
    var position = 0;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#EXTM3U')) {
        for (final m in _attrRe.allMatches(line)) {
          final k = m.group(1)!.toLowerCase();
          if (k == 'url-tvg' || k == 'x-tvg-url' || k == 'tvg-url') {
            epgUrls.addAll(m
                .group(2)!
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty));
          }
        }
        continue;
      }
      if (line.startsWith('#EXTINF')) {
        attrs = {};
        final comma = _titleComma(line);
        final head = comma >= 0 ? line.substring(0, comma) : line;
        title = comma >= 0 ? line.substring(comma + 1).trim() : null;
        for (final m in _attrRe.allMatches(head)) {
          attrs[m.group(1)!.toLowerCase()] = m.group(2)!.trim();
        }
        group = attrs['group-title'];
        continue;
      }
      if (line.startsWith('#EXTGRP:')) {
        group ??= line.substring(8).trim();
        continue;
      }
      if (line.startsWith('#')) continue;

      // URL line
      final url = line;
      count++;
      final name = (title?.isNotEmpty == true
              ? title!
              : (attrs['tvg-name']?.isNotEmpty == true ? attrs['tvg-name']! : url))
          .trim();
      final type = _typeOf(url);
      final groupName = (group?.isNotEmpty == true) ? group! : 'Uncategorized';
      final catId = 'g${shortHash(groupName)}';
      final logo = attrs['tvg-logo']?.isNotEmpty == true ? attrs['tvg-logo'] : null;

      if (type == ContentType.series) {
        final m = _seRe.firstMatch(name);
        final showName = (m?.group(1)?.trim().isNotEmpty == true
                ? m!.group(1)!.trim()
                : name)
            .replaceAll(RegExp(r'[\s._-]+$'), '');
        final seriesId = 's${shortHash('$groupName|$showName')}';
        cats[ContentType.series]!.putIfAbsent(
            catId, () => ImportedCategory(catId, groupName));
        if (!seriesSeen.containsKey(seriesId)) {
          final it = ImportedItem(
            type: ContentType.series,
            id: seriesId,
            name: showName,
            categoryId: catId,
            icon: logo,
            year: yearOf(showName),
          );
          seriesSeen[seriesId] = it;
          items[ContentType.series]!.add(it);
        }
        final season = int.tryParse(m?.group(2) ?? m?.group(4) ?? '') ?? 1;
        final episode = int.tryParse(m?.group(3) ?? m?.group(5) ?? '') ??
            (seriesEps[seriesId]?.length ?? 0) + 1;
        (seriesEps[seriesId] ??= []).add(EpisodeInfo(
          id: shortHash(url),
          season: season,
          episode: episode,
          title: name,
          image: logo,
          url: url,
          ext: _ext(url),
        ));
      } else {
        cats[type]!.putIfAbsent(catId, () => ImportedCategory(catId, groupName));
        final catchupDays = int.tryParse(attrs['catchup-days'] ??
                attrs['tvg-rec'] ??
                attrs['timeshift'] ??
                '') ??
            0;
        items[type]!.add(ImportedItem(
          type: type,
          id: shortHash(url),
          name: name,
          categoryId: catId,
          icon: logo,
          year: type == ContentType.movie ? yearOf(name) : null,
          epgId: type == ContentType.live
              ? (attrs['tvg-id']?.isNotEmpty == true ? attrs['tvg-id'] : null)
              : null,
          archiveDays: attrs.containsKey('catchup') ? (catchupDays > 0 ? catchupDays : 1) : catchupDays,
          ext: _ext(url),
          url: url,
          added: position++,
          extra: {
            if (attrs['catchup'] != null) 'catchup': attrs['catchup'],
            if (attrs['catchup-source'] != null) 'catchupSource': attrs['catchup-source'],
            if (attrs['tvg-name'] != null) 'tvgName': attrs['tvg-name'],
          },
        ));
      }
      attrs = {};
      title = null;
      group = null;
    }

    final series = <String, SeriesDetail>{};
    seriesEps.forEach((id, eps) {
      eps.sort((a, b) => a.season != b.season
          ? a.season.compareTo(b.season)
          : a.episode.compareTo(b.episode));
      series[id] = SeriesDetail(episodes: eps);
    });

    return M3uResult(
      batches: {
        for (final t in ContentType.values)
          t: ImportBatch(t, cats[t]!.values.toList(), items[t]!)
      },
      series: series,
      epgUrls: epgUrls.toSet().toList(),
      entryCount: count,
    );
  }

  /// The title comma is the first comma outside quoted attribute values.
  static int _titleComma(String line) {
    var inQuote = false;
    for (var i = 0; i < line.length; i++) {
      final c = line.codeUnitAt(i);
      if (c == 0x22) inQuote = !inQuote;
      if (c == 0x2C && !inQuote) return i;
    }
    return -1;
  }

  static ContentType _typeOf(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('/series/')) return ContentType.series;
    if (lower.contains('/movie/') || lower.contains('/movies/')) {
      return ContentType.movie;
    }
    final ext = _ext(url);
    if (ext != null && _videoExt.contains(ext)) return ContentType.movie;
    return ContentType.live;
  }

  static String? _ext(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot < path.lastIndexOf('/')) return null;
    final e = path.substring(dot + 1).toLowerCase();
    return e.length <= 5 ? e : null;
  }
}

/// If an M3U URL is really an Xtream `get.php` link, returns its credentials
/// so the faster Xtream API can be used instead.
({String server, String username, String password})? detectXtream(String url) {
  final u = Uri.tryParse(url.trim());
  if (u == null || !u.path.endsWith('get.php')) return null;
  final user = u.queryParameters['username'];
  final pass = u.queryParameters['password'];
  if (user == null || pass == null || user.isEmpty) return null;
  return (server: '${u.scheme}://${u.authority}', username: user, password: pass);
}
