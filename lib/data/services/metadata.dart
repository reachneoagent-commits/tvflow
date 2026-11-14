import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../repository.dart';
import 'secrets.dart';

/// Strips provider decoration so a title can be looked up:
/// "EN - The Witcher: Blood Origin [MULTI-SUB] (2022) 4K" → "The Witcher: Blood Origin".
String cleanTitle(String name) {
  var s = name;
  s = s.replaceFirst(RegExp(r'^\s*[\[\(]?[A-Za-z]{2,4}[\]\)]?\s*[-|:]\s*'), '');
  s = s.replaceAll(RegExp(r'\[[^\]]*\]|\{[^}]*\}'), ' ');
  s = s.replaceAll(RegExp(r'\((?:19|20)\d{2}\)'), ' ');
  s = s.replaceAll(
      RegExp(r'\b(?:4K|UHD|FHD|HD|SD|HEVC|x265|H\.?265|1080p|720p|2160p|MULTI(?:-SUB)?|VOSTFR|SUB|DUB)\b',
          caseSensitive: false),
      ' ');
  s = s.replaceAll(RegExp(r'\s+-\s+(?:19|20)\d{2}\s*$'), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Finds TMDb/IMDb ids for titles that the provider did not tag.
///
/// Order: provider id → TMDb search (needs the user's TMDb key) →
/// OpenSubtitles feature search (needs the user's OpenSubtitles key).
/// Results, including misses, are cached.
class IdResolver {
  IdResolver(this.repo, this.secrets, {http.Client? client})
      : _http = client ?? http.Client();
  final Repository repo;
  final SecretsStore secrets;
  final http.Client _http;

  bool get canResolve =>
      secrets.get(SecretsStore.tmdbKey) != null || secrets.get(SecretsStore.osApiKey) != null;

  Future<({int? tmdb, String? imdb})> resolve(String name,
      {required bool tv, int? year}) async {
    final title = cleanTitle(name);
    if (title.isEmpty) return (tmdb: null, imdb: null);
    final key = 'ids:${tv ? 'tv' : 'movie'}:${title.toLowerCase()}:${year ?? ''}';
    final cached = await repo.cacheGet(key, maxAge: const Duration(days: 30));
    if (cached != null) {
      final j = jsonDecode(cached) as Map;
      return (tmdb: (j['tmdb'] as num?)?.toInt(), imdb: j['imdb'] as String?);
    }
    ({int? tmdb, String? imdb}) out = (tmdb: null, imdb: null);
    try {
      out = await _tmdb(title, tv: tv, year: year) ?? await _os(title, tv: tv, year: year) ?? out;
    } catch (_) {/* network trouble: treat as miss, retried after cache expiry */}
    if (out.tmdb != null || out.imdb != null || canResolve) {
      await repo.cachePut(key, jsonEncode({'tmdb': out.tmdb, 'imdb': out.imdb}));
    }
    return out;
  }

  Future<({int? tmdb, String? imdb})?> _tmdb(String title, {required bool tv, int? year}) async {
    final k = secrets.get(SecretsStore.tmdbKey);
    if (k == null) return null;
    final bearer = k.length > 40;
    final uri = Uri.https('api.themoviedb.org', '/3/search/${tv ? 'tv' : 'movie'}', {
      'query': title,
      if (year != null) (tv ? 'first_air_date_year' : 'year'): '$year',
      if (!bearer) 'api_key': k,
    });
    final res = await _http.get(uri, headers: {
      if (bearer) 'Authorization': 'Bearer $k',
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final results = (jsonDecode(res.body)['results'] as List?) ?? const [];
    if (results.isEmpty) return null;
    return (tmdb: (results.first['id'] as num?)?.toInt(), imdb: null);
  }

  Future<({int? tmdb, String? imdb})?> _os(String title, {required bool tv, int? year}) async {
    final k = secrets.get(SecretsStore.osApiKey);
    if (k == null) return null;
    final uri = Uri.https('api.opensubtitles.com', '/api/v1/features', {
      'query': title,
      'type': tv ? 'tvshow' : 'movie',
      if (year != null) 'year': '$year',
    });
    final res = await _http.get(uri, headers: {
      'Api-Key': k,
      'User-Agent': OpenSubtitlesClient.userAgent,
    }).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final data = (jsonDecode(res.body)['data'] as List?) ?? const [];
    for (final d in data) {
      final a = d['attributes'] as Map? ?? const {};
      final tmdb = int.tryParse('${a['tmdb_id'] ?? ''}');
      final imdbNum = int.tryParse('${a['imdb_id'] ?? ''}');
      if (tmdb != null || imdbNum != null) {
        return (
          tmdb: tmdb,
          imdb: imdbNum == null ? null : 'tt${imdbNum.toString().padLeft(7, '0')}'
        );
      }
    }
    return null;
  }
}

/// One skippable segment in milliseconds (end null = until the end).
class Segment {
  Segment(this.startMs, this.endMs);
  final int startMs;
  final int? endMs;
}

class SkipSegments {
  SkipSegments({this.intro = const [], this.recap = const [], this.credits = const []});
  final List<Segment> intro;
  final List<Segment> recap;
  final List<Segment> credits;
  bool get isEmpty => intro.isEmpty && recap.isEmpty && credits.isEmpty;
}

/// TheIntroDB (https://theintrodb.org) — crowd-sourced intro/recap/credits
/// timestamps. Same service the reference app uses. No key needed.
class IntroDbClient {
  IntroDbClient(this.repo, {http.Client? client}) : _http = client ?? http.Client();
  final Repository repo;
  final http.Client _http;

  Future<SkipSegments> lookup({
    int? tmdbId,
    String? imdbId,
    int? season,
    int? episode,
    int? durationMs,
  }) async {
    if (tmdbId == null && imdbId == null) return SkipSegments();
    final q = {
      if (tmdbId != null) 'tmdb_id': '$tmdbId' else 'imdb_id': imdbId!,
      if (season != null && episode != null) ...{'season': '$season', 'episode': '$episode'},
      if (durationMs != null && durationMs > 0) 'duration_ms': '$durationMs',
    };
    final key = 'introdb:${q.entries.where((e) => e.key != 'duration_ms').map((e) => '${e.key}=${e.value}').join('&')}';
    var body = await repo.cacheGet(key, maxAge: const Duration(days: 3));
    if (body == null) {
      try {
        final res = await _http
            .get(Uri.https('api.theintrodb.org', '/v4/media', q))
            .timeout(const Duration(seconds: 12));
        body = res.statusCode == 200 ? res.body : '{}';
        if (res.statusCode == 200 || res.statusCode == 404) await repo.cachePut(key, body);
      } on SocketException {
        return SkipSegments();
      } catch (_) {
        return SkipSegments();
      }
    }
    final j = jsonDecode(body) as Map;
    List<Segment> segs(String k) => [
          for (final s in (j[k] as List? ?? const []))
            Segment((s['start_ms'] as num?)?.toInt() ?? 0, (s['end_ms'] as num?)?.toInt())
        ];
    return SkipSegments(intro: segs('intro'), recap: segs('recap'), credits: segs('credits'));
  }
}

class SubtitleResult {
  SubtitleResult({
    required this.fileId,
    required this.language,
    required this.release,
    required this.downloads,
    this.hearingImpaired = false,
    this.trusted = false,
    this.title,
  });
  final int fileId;
  final String language;
  final String release;
  final int downloads;
  final bool hearingImpaired;
  final bool trusted;
  final String? title;
}

class SubtitleException implements Exception {
  SubtitleException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// OpenSubtitles.com REST API v1. Needs the user's own API key (free at
/// opensubtitles.com/consumers); downloads also need an account login.
class OpenSubtitlesClient {
  OpenSubtitlesClient(this.secrets, this.cacheDir, {http.Client? client})
      : _http = client ?? http.Client();
  final SecretsStore secrets;
  final Directory cacheDir;
  final http.Client _http;
  static const userAgent = 'TVflow v1.0';

  String? _token;
  String _base = 'api.opensubtitles.com';

  bool get configured => secrets.get(SecretsStore.osApiKey) != null;
  bool get canDownload => configured && secrets.get(SecretsStore.osUsername) != null;

  Map<String, String> _headers({bool auth = false}) => {
        'Api-Key': secrets.get(SecretsStore.osApiKey) ?? '',
        'User-Agent': userAgent,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (auth && _token != null) 'Authorization': 'Bearer $_token',
      };

  SubtitleException _err(http.Response r, String what) {
    String? msg;
    try {
      final j = jsonDecode(r.body);
      msg = (j['message'] ?? j['errors']?.toString())?.toString();
    } catch (_) {}
    return switch (r.statusCode) {
      401 || 403 => SubtitleException('OpenSubtitles rejected the API key or login${msg != null ? ': $msg' : ''}.'),
      406 || 429 => SubtitleException('OpenSubtitles limit reached${msg != null ? ': $msg' : ''}. Try again later.'),
      _ => SubtitleException('$what failed (HTTP ${r.statusCode})${msg != null ? ': $msg' : ''}.'),
    };
  }

  /// Checks the key (and login, when given). Returns null when fine.
  Future<String?> test() async {
    if (!configured) return 'Enter an API key first.';
    try {
      // A text search is rejected (403) for an invalid key. /infos/* and
      // imdb_id lookups are answered from a cache without checking the key.
      final r = await _http
          .get(Uri.https(_base, '/api/v1/subtitles', {'query': 'matrix'}), headers: _headers())
          .timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return _err(r, 'Key check').message;
      if (secrets.get(SecretsStore.osUsername) != null) {
        _token = null;
        await _login();
      }
      return null;
    } on SubtitleException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not reach OpenSubtitles: $e';
    }
  }

  Future<void> _login() async {
    final user = secrets.get(SecretsStore.osUsername);
    final pass = secrets.get(SecretsStore.osPassword);
    if (user == null || pass == null) {
      throw SubtitleException('Downloading needs an OpenSubtitles username and password (Settings → Subtitles).');
    }
    final r = await _http
        .post(Uri.https('api.opensubtitles.com', '/api/v1/login'),
            headers: _headers(), body: jsonEncode({'username': user, 'password': pass}))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) throw _err(r, 'Login');
    final j = jsonDecode(r.body);
    _token = j['token'] as String?;
    final base = j['base_url'] as String?;
    if (base != null && base.isNotEmpty) _base = base.replaceAll(RegExp(r'^https?://'), '').split('/').first;
  }

  Future<List<SubtitleResult>> search({
    required String title,
    int? tmdbId,
    String? imdbId,
    int? season,
    int? episode,
    bool tv = false,
    List<String> languages = const ['en'],
  }) async {
    if (!configured) {
      throw SubtitleException('Add your OpenSubtitles API key in Settings → Subtitles.');
    }
    final q = <String, String>{
      'languages': (languages.toList()..sort()).join(','),
      if (tv && tmdbId != null) 'parent_tmdb_id': '$tmdbId',
      if (!tv && tmdbId != null) 'tmdb_id': '$tmdbId',
      if (tmdbId == null && imdbId != null) (tv ? 'parent_imdb_id' : 'imdb_id'): imdbId.replaceFirst('tt', ''),
      if (tmdbId == null && imdbId == null) 'query': cleanTitle(title).toLowerCase(),
      if (season != null) 'season_number': '$season',
      if (episode != null) 'episode_number': '$episode',
      'type': tv ? 'episode' : 'movie',
      'order_by': 'download_count',
    };
    final r = await _http
        .get(Uri.https(_base, '/api/v1/subtitles', q), headers: _headers())
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) throw _err(r, 'Subtitle search');
    final data = (jsonDecode(r.body)['data'] as List?) ?? const [];
    final out = <SubtitleResult>[];
    for (final d in data) {
      final a = d['attributes'] as Map? ?? const {};
      final files = a['files'] as List? ?? const [];
      if (files.isEmpty) continue;
      out.add(SubtitleResult(
        fileId: (files.first['file_id'] as num).toInt(),
        language: a['language']?.toString() ?? '?',
        release: a['release']?.toString() ?? files.first['file_name']?.toString() ?? '',
        downloads: (a['download_count'] as num?)?.toInt() ?? 0,
        hearingImpaired: a['hearing_impaired'] == true,
        trusted: a['from_trusted'] == true,
        title: (a['feature_details'] as Map?)?['title']?.toString(),
      ));
    }
    return out;
  }

  /// Downloads a subtitle file and returns its local path (cached).
  Future<File> download(SubtitleResult s) async {
    final cached = File('${cacheDir.path}/os_${s.fileId}.srt');
    if (await cached.exists()) return cached;
    if (_token == null) await _login();
    var r = await _http
        .post(Uri.https(_base, '/api/v1/download'),
            headers: _headers(auth: true), body: jsonEncode({'file_id': s.fileId, 'sub_format': 'srt'}))
        .timeout(const Duration(seconds: 20));
    if (r.statusCode == 401) {
      _token = null;
      await _login();
      r = await _http
          .post(Uri.https(_base, '/api/v1/download'),
              headers: _headers(auth: true), body: jsonEncode({'file_id': s.fileId, 'sub_format': 'srt'}))
          .timeout(const Duration(seconds: 20));
    }
    if (r.statusCode != 200) throw _err(r, 'Subtitle download');
    final link = jsonDecode(r.body)['link'] as String?;
    if (link == null) throw SubtitleException('OpenSubtitles did not return a download link.');
    final file = await _http.get(Uri.parse(link)).timeout(const Duration(seconds: 30));
    if (file.statusCode != 200) {
      throw SubtitleException('Subtitle file download failed (HTTP ${file.statusCode}).');
    }
    await cached.writeAsBytes(file.bodyBytes, flush: true);
    return cached;
  }
}
