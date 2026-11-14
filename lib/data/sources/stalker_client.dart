import '../../core/net.dart';
import '../../core/text.dart';
import 'models.dart';

/// Stalker / Ministra middleware client (MAG set-top-box emulation).
///
/// Flow: handshake → token, get_profile, then itv/vod/series lists. Stream
/// links are created on demand with `create_link` (they expire), so items
/// store the portal `cmd` and the URL is resolved just before playback.
///
/// Status: implemented from the public protocol; not verified against a live
/// portal (none was available while building). See FEATURE_MATRIX.md.
class StalkerClient {
  StalkerClient({required String server, required String mac, Net? net})
      : mac = mac.trim().toUpperCase(),
        _portalRoot = _root(server),
        _net = net ?? Net();

  final String mac;
  final String _portalRoot;
  final Net _net;
  String? _token;
  Uri? _endpoint;

  static const _ua =
      'Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 250 Safari/533.3';

  static String _root(String server) {
    var s = server.trim();
    if (!s.startsWith('http')) s = 'http://$s';
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (s.endsWith('/c')) s = s.substring(0, s.length - 2);
    return s;
  }

  static bool validMac(String mac) =>
      RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$').hasMatch(mac.trim());

  Map<String, String> get _headers => {
        'X-User-Agent': 'Model: MAG250; Link: WiFi',
        'Cookie':
            'mac=${Uri.encodeComponent(mac)}; stb_lang=en; timezone=UTC',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _call(Map<String, String> q) async {
    final uri = _endpoint!.replace(queryParameters: {...q, 'JsHttpRequest': '1-xml'});
    final d = await _net.getJson(uri, userAgent: _ua, headers: _headers);
    return d is Map ? d['js'] : null;
  }

  /// Finds the API endpoint and obtains a token.
  Future<void> connect() async {
    if (_token != null) return;
    final candidates = [
      '$_portalRoot/server/load.php',
      '$_portalRoot/portal.php',
      '$_portalRoot/stalker_portal/server/load.php',
    ];
    Object? lastError;
    for (final c in candidates) {
      _endpoint = Uri.parse(c);
      try {
        final js = await _call({'type': 'stb', 'action': 'handshake', 'token': ''});
        final t = js is Map ? js['token']?.toString() : null;
        if (t != null && t.isNotEmpty) {
          _token = t;
          final profile = await _call({
            'type': 'stb',
            'action': 'get_profile',
            'hd': '1',
            'sn': shortHash(mac).toUpperCase().substring(0, 13),
            'stb_type': 'MAG250',
            'device_id': shortHash('d$mac'),
            'device_id2': shortHash('e$mac'),
          });
          if (profile is Map && profile['status'] == 2) {
            throw NetException('The portal rejected this MAC address.');
          }
          return;
        }
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError is NetException
        ? lastError
        : NetException('Could not connect to the Stalker portal at $_portalRoot.');
  }

  Future<ImportBatch> fetch(ContentType type) async {
    await connect();
    switch (type) {
      case ContentType.live:
        final genres = await _call({'type': 'itv', 'action': 'get_genres'});
        final cats = <ImportedCategory>[
          for (final g in (genres is List ? genres : const []))
            if (g is Map && g['id']?.toString() != '*')
              ImportedCategory(g['id'].toString(), g['title']?.toString() ?? ''),
        ];
        final all = await _call({'type': 'itv', 'action': 'get_all_channels'});
        final data = all is Map ? (all['data'] as List? ?? const []) : const [];
        return ImportBatch(type, cats, [
          for (final c in data)
            if (c is Map)
              ImportedItem(
                type: type,
                id: c['id'].toString(),
                name: c['name']?.toString() ?? '',
                categoryId: c['tv_genre_id']?.toString() ?? '',
                icon: _s(c['logo']),
                epgId: _s(c['xmltv_id']),
                archiveDays: c['tv_archive'] == 1 || c['tv_archive'] == '1'
                    ? (int.tryParse('${c['tv_archive_duration']}') ?? 1) ~/ 24 + 1
                    : 0,
                url: 'stalker:${c['cmd']}',
              ),
        ]);
      case ContentType.movie:
      case ContentType.series:
        final apiType = type == ContentType.movie ? 'vod' : 'series';
        final catsJs = await _call({'type': apiType, 'action': 'get_categories'});
        final cats = <ImportedCategory>[
          for (final g in (catsJs is List ? catsJs : const []))
            if (g is Map && g['id']?.toString() != '*')
              ImportedCategory(g['id'].toString(), g['title']?.toString() ?? ''),
        ];
        final items = <ImportedItem>[];
        for (final cat in cats) {
          // Portals page 14 items at a time; cap per category to stay usable.
          for (var page = 1; page <= 40; page++) {
            final js = await _call({
              'type': apiType,
              'action': 'get_ordered_list',
              'category': cat.id,
              'p': '$page',
              'sortby': 'added',
            });
            final data = js is Map ? (js['data'] as List? ?? const []) : const [];
            for (final v in data) {
              if (v is! Map) continue;
              items.add(ImportedItem(
                type: type,
                id: v['id'].toString(),
                name: v['name']?.toString() ?? '',
                categoryId: cat.id,
                icon: _s(v['screenshot_uri']),
                rating: double.tryParse('${v['rating_imdb']}'),
                year: int.tryParse('${v['year']}'),
                plot: _s(v['description']),
                url: 'stalker:${v['cmd']}',
                tmdbId: int.tryParse('${v['tmdb_id']}'),
              ));
            }
            final total = js is Map ? int.tryParse('${js['total_items']}') ?? 0 : 0;
            if (data.isEmpty || page * 14 >= total) break;
          }
        }
        return ImportBatch(type, cats, items);
    }
  }

  /// Resolves a `stalker:<cmd>` reference into a playable URL.
  Future<String> createLink(ContentType type, String cmd) async {
    await connect();
    final js = await _call({
      'type': type == ContentType.live ? 'itv' : 'vod',
      'action': 'create_link',
      'cmd': cmd,
    });
    final link = js is Map ? js['cmd']?.toString() : null;
    if (link == null || link.isEmpty) {
      throw NetException('The portal did not return a stream link.');
    }
    return link.replaceFirst(RegExp(r'^(ffmpeg|ffrt\d?|auto)\s+'), '').trim();
  }

  Future<List<Programme>> shortEpg(String channelId) async {
    await connect();
    final js = await _call({
      'type': 'itv',
      'action': 'get_short_epg',
      'ch_id': channelId,
      'size': '10',
    });
    return [
      for (final p in (js is List ? js : const []))
        if (p is Map && p['start_timestamp'] != null)
          Programme(
            start: DateTime.fromMillisecondsSinceEpoch(
                int.parse('${p['start_timestamp']}') * 1000),
            stop: DateTime.fromMillisecondsSinceEpoch(
                int.parse('${p['stop_timestamp']}') * 1000),
            title: p['name']?.toString() ?? '',
            description: _s(p['descr']),
          ),
    ];
  }

  static String? _s(dynamic v) {
    final s = v?.toString().trim();
    return s == null || s.isEmpty ? null : s;
  }
}
