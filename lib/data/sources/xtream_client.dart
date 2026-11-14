import 'dart:convert';
import 'dart:isolate';

import '../../core/net.dart';
import '../../core/text.dart';
import 'models.dart';

/// Xtream Codes `player_api.php` client.
///
/// Stream URLs:
///   live    /live/{u}/{p}/{id}.ts            (or .m3u8)
///   movie   /movie/{u}/{p}/{id}.{ext}
///   episode /series/{u}/{p}/{id}.{ext}
///   catchup /timeshift/{u}/{p}/{minutes}/{yyyy-MM-dd:HH-mm}/{id}.ts
///   XMLTV   /xmltv.php?username=&password=
class XtreamClient {
  XtreamClient({
    required String server,
    required this.username,
    required this.password,
    this.userAgent = kDefaultUserAgent,
    Net? net,
  })  : base = normalizeServer(server),
        _net = net ?? Net();

  final String base;
  final String username;
  final String password;
  final String userAgent;
  final Net _net;

  static String normalizeServer(String s) {
    var v = s.trim();
    if (!v.startsWith('http://') && !v.startsWith('https://')) v = 'http://$v';
    final u = Uri.parse(v);
    return '${u.scheme}://${u.authority}';
  }

  Uri _api([String? action, Map<String, String> extra = const {}]) =>
      Uri.parse('$base/player_api.php').replace(queryParameters: {
        'username': username,
        'password': password,
        'action': ?action,
        ...extra,
      });

  /// Verifies credentials. Returns the `user_info` map.
  Future<Map<String, dynamic>> account() async {
    final d = await _net.getJson(_api(), userAgent: userAgent);
    final u = d is Map ? d['user_info'] : null;
    if (u is! Map) {
      throw NetException('This server did not answer like an Xtream Codes panel.');
    }
    if (u['auth'] == 0 || u['auth'] == '0' || u['auth'] == false) {
      throw NetException('Wrong username or password.');
    }
    final status = u['status']?.toString();
    if (status != null && status.toLowerCase() != 'active') {
      throw NetException('Account status: $status');
    }
    return u.cast<String, dynamic>();
  }

  /// Big lists are fetched with one retry: panels often drop the first request after a pause.
  Future<List<int>> _raw(String action) async {
    try {
      return await _net.getBytes(_api(action), userAgent: userAgent, timeout: const Duration(seconds: 120));
    } catch (_) {
      await Future.delayed(const Duration(seconds: 2));
      return _net.getBytes(_api(action), userAgent: userAgent, timeout: const Duration(seconds: 180));
    }
  }

  Future<ImportBatch> fetch(ContentType type) async {
    final (catAction, listAction) = switch (type) {
      ContentType.live => ('get_live_categories', 'get_live_streams'),
      ContentType.movie => ('get_vod_categories', 'get_vod_streams'),
      ContentType.series => ('get_series_categories', 'get_series'),
    };
    final catBytes = await _raw(catAction);
    final listBytes = await _raw(listAction);
    // JSON decoding of 50+ MB payloads happens off the UI isolate.
    return _parseInIsolate(type, catBytes, listBytes);
  }

  static ImportBatch parseBatch(
      ContentType type, List<int> catBytes, List<int> listBytes) {
    final cats = _asList(jsonDecode(decodeText(catBytes)));
    final list = _asList(jsonDecode(decodeText(listBytes)));
    final categories = <ImportedCategory>[
      for (final c in cats)
        if (c is Map)
          ImportedCategory(c['category_id']?.toString() ?? '',
              c['category_name']?.toString() ?? ''),
    ];
    final items = <ImportedItem>[];
    for (final r in list) {
      if (r is! Map) continue;
      final name = r['name']?.toString().trim() ?? '';
      final cat = r['category_id']?.toString() ?? '';
      switch (type) {
        case ContentType.live:
          final id = r['stream_id']?.toString();
          if (id == null) continue;
          items.add(ImportedItem(
            type: type,
            id: id,
            name: name,
            categoryId: cat,
            icon: _str(r['stream_icon']),
            added: _int(r['added']) ?? 0,
            epgId: _str(r['epg_channel_id']),
            archiveDays: _truthy(r['tv_archive'])
                ? (_int(r['tv_archive_duration']) ?? 1)
                : 0,
          ));
        case ContentType.movie:
          final id = r['stream_id']?.toString();
          if (id == null) continue;
          items.add(ImportedItem(
            type: type,
            id: id,
            name: name,
            categoryId: cat,
            icon: _str(r['stream_icon']),
            rating: _double(r['rating']),
            added: _int(r['added']) ?? 0,
            year: _int(r['year']) ?? yearOf(name),
            tmdbId: _int(r['tmdb']) ?? _int(r['tmdb_id']),
            ext: _str(r['container_extension']) ?? 'mp4',
          ));
        case ContentType.series:
          final id = r['series_id']?.toString();
          if (id == null) continue;
          final release = _str(r['releaseDate']) ?? _str(r['release_date']);
          items.add(ImportedItem(
            type: type,
            id: id,
            name: name,
            categoryId: cat,
            icon: _str(r['cover']),
            rating: _double(r['rating']),
            added: _int(r['last_modified']) ?? 0,
            releaseDate: release,
            year: _yearFromDate(release) ?? yearOf(name),
            tmdbId: _int(r['tmdb']) ?? _int(r['tmdb_id']),
            plot: _str(r['plot']),
            extra: {
              'genre': ?_str(r['genre']),
              'cast': ?_str(r['cast']),
              'director': ?_str(r['director']),
            },
          ));
      }
    }
    return ImportBatch(type, categories, items);
  }

  Future<MovieDetail> vodInfo(String streamId) async {
    final d = await _net.getJson(_api('get_vod_info', {'vod_id': streamId}),
        userAgent: userAgent);
    final info = (d is Map && d['info'] is Map) ? d['info'] as Map : const {};
    final movie =
        (d is Map && d['movie_data'] is Map) ? d['movie_data'] as Map : const {};
    final backdrops = info['backdrop_path'];
    return MovieDetail(
      plot: _str(info['plot']) ?? _str(info['description']),
      cast: _str(info['cast']) ?? _str(info['actors']),
      director: _str(info['director']),
      genre: _str(info['genre']),
      durationSecs: _int(info['duration_secs']),
      backdrop: backdrops is List && backdrops.isNotEmpty
          ? backdrops.first?.toString()
          : _str(backdrops),
      tmdbId: _int(info['tmdb_id']) ?? _int(movie['tmdb_id']),
      imdbId: _imdb(info['imdb_id']),
      rating: _double(info['rating']),
      releaseDate: _str(info['releasedate']) ?? _str(info['release_date']),
      trailer: _str(info['youtube_trailer']),
    );
  }

  Future<SeriesDetail> seriesInfo(String seriesId) async {
    final d = await _net.getJson(
        _api('get_series_info', {'series_id': seriesId}),
        userAgent: userAgent);
    final m = d is Map ? d : const {};
    final info = m['info'] is Map ? m['info'] as Map : const {};
    final episodes = <EpisodeInfo>[];

    void addEp(Map e, int seasonHint) {
      final i = e['info'] is Map ? e['info'] as Map : const {};
      final id = e['id']?.toString();
      if (id == null) return;
      episodes.add(EpisodeInfo(
        id: id,
        season: _int(e['season']) ?? _int(e['season_number']) ?? seasonHint,
        episode: _int(e['episode_num']) ?? _int(e['episode_number']) ?? 0,
        title: _str(e['title']) ?? _str(e['name']) ?? 'Episode',
        plot: _str(i['plot']) ?? _str(e['plot']),
        image: _str(i['movie_image']) ?? _str(e['cover']),
        durationSecs: _int(i['duration_secs']),
        ext: _str(e['container_extension']) ?? 'mp4',
        rating: _double(i['rating']),
        airDate: _str(i['releasedate']) ?? _str(i['air_date']),
      ));
    }

    final eps = m['episodes'];
    if (eps is Map) {
      eps.forEach((k, v) {
        if (v is List) {
          for (final e in v) {
            if (e is Map) addEp(e, int.tryParse(k.toString()) ?? 0);
          }
        }
      });
    } else if (eps is List) {
      for (final e in eps) {
        if (e is Map) addEp(e, 0);
      }
    }
    // Some panels embed episodes inside seasons.
    if (episodes.isEmpty && m['seasons'] is List) {
      for (final s in m['seasons'] as List) {
        if (s is Map && s['episodes'] is List) {
          for (final e in s['episodes'] as List) {
            if (e is Map) addEp(e, _int(s['season_number']) ?? 0);
          }
        }
      }
    }
    episodes.sort((a, b) => a.season != b.season
        ? a.season.compareTo(b.season)
        : a.episode.compareTo(b.episode));
    final backdrops = info['backdrop_path'];
    return SeriesDetail(
      episodes: episodes,
      plot: _str(info['plot']),
      cast: _str(info['cast']),
      director: _str(info['director']),
      genre: _str(info['genre']),
      backdrop: backdrops is List && backdrops.isNotEmpty
          ? backdrops.first?.toString()
          : _str(backdrops),
      tmdbId: _int(info['tmdb']) ?? _int(info['tmdb_id']),
      rating: _double(info['rating']),
      releaseDate: _str(info['releaseDate']),
      trailer: _str(info['youtube_trailer']),
    );
  }

  /// Short EPG (titles are base64 on most panels).
  Future<List<Programme>> shortEpg(String streamId, {int limit = 8}) async {
    final d = await _net.getJson(
        _api('get_short_epg', {'stream_id': streamId, 'limit': '$limit'}),
        userAgent: userAgent);
    final list = d is Map ? (d['epg_listings'] as List? ?? const []) : const [];
    final out = <Programme>[];
    for (final r in list) {
      if (r is! Map) continue;
      final start = _int(r['start_timestamp']);
      final stop = _int(r['stop_timestamp']);
      if (start == null || stop == null) continue;
      out.add(Programme(
        start: DateTime.fromMillisecondsSinceEpoch(start * 1000),
        stop: DateTime.fromMillisecondsSinceEpoch(stop * 1000),
        title: _b64(r['title']) ?? '',
        description: _b64(r['description']),
      ));
    }
    return out;
  }

  Uri get xmltvUri => Uri.parse('$base/xmltv.php')
      .replace(queryParameters: {'username': username, 'password': password});

  String liveUrl(String id, {String ext = 'ts'}) =>
      '$base/live/$username/$password/$id.$ext';
  String movieUrl(String id, String ext) =>
      '$base/movie/$username/$password/$id.$ext';
  String episodeUrl(String id, String ext) =>
      '$base/series/$username/$password/$id.$ext';

  /// Catch-up URL. Panels expect the start in the server's local time; most
  /// use UTC, which is what we send.
  String timeshiftUrl(String id, DateTime start, Duration length) {
    final s = start.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    final ts = '${s.year}-${two(s.month)}-${two(s.day)}:${two(s.hour)}-${two(s.minute)}';
    return '$base/timeshift/$username/$password/${length.inMinutes}/$ts/$id.ts';
  }

  static List _asList(dynamic d) {
    if (d is List) return d;
    if (d is Map) return d.values.toList(); // some panels return {"0": {...}}
    return const [];
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty || s == 'null' ? null : s;
  }

  static int? _int(dynamic v) => v is int ? v : int.tryParse(_str(v) ?? '');
  static double? _double(dynamic v) {
    final d = v is num ? v.toDouble() : double.tryParse(_str(v) ?? '');
    return d == null || d <= 0 ? null : d;
  }

  static bool _truthy(dynamic v) => v == 1 || v == '1' || v == true;
  static int? _yearFromDate(String? d) =>
      d == null || d.length < 4 ? null : int.tryParse(d.substring(0, 4));
  static String? _imdb(dynamic v) {
    final s = _str(v);
    if (s == null) return null;
    return s.startsWith('tt') ? s : 'tt$s';
  }

  static String? _b64(dynamic v) {
    final s = _str(v);
    if (s == null) return null;
    try {
      return utf8.decode(base64Decode(s)).trim();
    } catch (_) {
      return s;
    }
  }
}

Future<ImportBatch> _parseInIsolate(ContentType type, List<int> cat, List<int> list) =>
    Isolate.run(() => XtreamClient.parseBatch(type, cat, list));
