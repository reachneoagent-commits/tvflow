import 'dart:async';
import 'dart:convert';

import 'package:cast/device.dart' as gc;
import 'package:cast/session.dart' as gc;
import 'package:cast/session_manager.dart' as gc;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

enum CastKind { chromecast, airplay, dlna, roku }

extension CastKindX on CastKind {
  String get label => switch (this) {
        CastKind.chromecast => 'Chromecast',
        CastKind.airplay => 'AirPlay',
        CastKind.dlna => 'Smart TV (DLNA)',
        CastKind.roku => 'Roku',
      };
}

/// A TV or speaker on the local network that can be sent a stream.
class CastTarget {
  CastTarget({
    required this.id,
    required this.name,
    required this.kind,
    required this.host,
    required this.port,
    this.controlUrl,
    this.chromecast,
  });
  final String id;
  final String name;
  final CastKind kind;
  final String host;
  final int port;

  /// DLNA: URL of the AVTransport control endpoint.
  final String? controlUrl;
  final gc.CastDevice? chromecast;
}

/// What is being sent to the device.
class CastMedia {
  CastMedia({required this.url, required this.title, this.subtitle, this.isLive = false, this.start = Duration.zero});
  final String url;
  final String title;
  final String? subtitle;
  final bool isLive;
  final Duration start;

  String get contentType {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.m3u8')) return 'application/x-mpegURL';
    if (path.endsWith('.mkv')) return 'video/x-matroska';
    if (path.endsWith('.mp4') || path.endsWith('.m4v')) return 'video/mp4';
    if (path.endsWith('.avi')) return 'video/x-msvideo';
    if (path.endsWith('.ts') || isLive) return 'video/mp2t';
    return 'video/mp4';
  }
}

/// One way of talking to a device. Methods throw a readable message when the device refuses.
abstract class CastBackend {
  Future<void> load(CastMedia m);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration to);
  Future<void> stop();

  /// Current position when the device reports it, else null.
  Future<Duration?> position() async => null;
  void dispose() {}
}

// -----------------------------------------------------------------------------
// Chromecast / Google Cast

class ChromecastBackend extends CastBackend {
  ChromecastBackend(this.device);
  final gc.CastDevice device;
  gc.CastSession? _session;
  int _req = 1;
  int? _mediaSessionId;
  Duration _lastPos = Duration.zero;
  DateTime _lastPosAt = DateTime.now();
  bool _playing = true;
  final _connected = Completer<void>();
  StreamSubscription? _stateSub, _msgSub;

  static const _defaultReceiver = 'CC1AD845';

  @override
  Future<void> load(CastMedia m) async {
    final s = await gc.CastSessionManager().startSession(device, const Duration(seconds: 10));
    _session = s;
    _stateSub = s.stateStream.listen((st) {
      if (st == gc.CastSessionState.connected && !_connected.isCompleted) _connected.complete();
    });
    _msgSub = s.messageStream.listen(_onMessage);
    s.sendMessage(gc.CastSession.kNamespaceReceiver, {'type': 'LAUNCH', 'appId': _defaultReceiver, 'requestId': _req++});
    await _connected.future.timeout(const Duration(seconds: 15), onTimeout: () => throw 'The Chromecast did not respond.');
    s.sendMessage(gc.CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'requestId': _req++,
      'autoplay': true,
      'currentTime': m.start.inSeconds,
      'media': {
        'contentId': m.url,
        'streamType': m.isLive ? 'LIVE' : 'BUFFERED',
        'contentType': m.contentType,
        'metadata': {'metadataType': 0, 'title': m.title, if (m.subtitle != null) 'subtitle': m.subtitle},
      },
    });
    _lastPos = m.start;
    _lastPosAt = DateTime.now();
  }

  void _onMessage(Map<String, dynamic> msg) {
    final type = msg['type'];
    if (type == 'MEDIA_STATUS') {
      final list = msg['status'];
      if (list is List && list.isNotEmpty) {
        final st = list.first as Map;
        _mediaSessionId = (st['mediaSessionId'] as num?)?.toInt() ?? _mediaSessionId;
        final t = (st['currentTime'] as num?)?.toDouble();
        if (t != null) {
          _lastPos = Duration(milliseconds: (t * 1000).round());
          _lastPosAt = DateTime.now();
        }
        _playing = st['playerState'] == 'PLAYING' || st['playerState'] == 'BUFFERING';
      }
    } else if (type == 'LOAD_FAILED' || type == 'INVALID_REQUEST') {
      _error = 'The Chromecast could not play this stream.';
    }
  }

  String? _error;
  String? get error => _error;

  void _media(String type, [Map<String, dynamic> extra = const {}]) {
    final id = _mediaSessionId;
    if (id == null) return;
    _session?.sendMessage(gc.CastSession.kNamespaceMedia, {'type': type, 'mediaSessionId': id, 'requestId': _req++, ...extra});
  }

  @override
  Future<void> play() async => _media('PLAY');
  @override
  Future<void> pause() async => _media('PAUSE');
  @override
  Future<void> seek(Duration to) async => _media('SEEK', {'currentTime': to.inSeconds});

  @override
  Future<void> stop() async {
    _media('STOP');
    _session?.sendMessage(gc.CastSession.kNamespaceReceiver, {'type': 'STOP', 'requestId': _req++});
    await Future.delayed(const Duration(milliseconds: 200));
    dispose();
  }

  @override
  Future<Duration?> position() async {
    if (_error != null) throw _error!;
    return _playing ? _lastPos + DateTime.now().difference(_lastPosAt) : _lastPos;
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _msgSub?.cancel();
    final s = _session;
    _session = null;
    if (s != null) unawaited(s.close().catchError((_) {}));
  }
}

// -----------------------------------------------------------------------------
// DLNA / UPnP (many smart TVs: Samsung, LG, Sony, Philips, Kodi, VLC)

class DlnaBackend extends CastBackend {
  DlnaBackend(this.controlUrl);
  final String controlUrl;
  static const _svc = 'urn:schemas-upnp-org:service:AVTransport:1';

  Future<String> _call(String action, String args) async {
    final body = '<?xml version="1.0" encoding="utf-8"?>'
        '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
        '<s:Body><u:$action xmlns:u="$_svc"><InstanceID>0</InstanceID>$args</u:$action></s:Body></s:Envelope>';
    final r = await http
        .post(Uri.parse(controlUrl),
            headers: {'Content-Type': 'text/xml; charset="utf-8"', 'SOAPAction': '"$_svc#$action"'}, body: body)
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) throw 'The TV refused the request ($action, ${r.statusCode}).';
    return r.body;
  }

  static String _esc(String s) => const HtmlEscape(HtmlEscapeMode.element).convert(s);

  @override
  Future<void> load(CastMedia m) async {
    final didl = '<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" '
        'xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">'
        '<item id="0" parentID="-1" restricted="1"><dc:title>${_esc(m.title)}</dc:title>'
        '<upnp:class>object.item.videoItem</upnp:class>'
        '<res protocolInfo="http-get:*:${m.contentType}:*">${_esc(m.url)}</res></item></DIDL-Lite>';
    await _call('SetAVTransportURI', '<CurrentURI>${_esc(m.url)}</CurrentURI><CurrentURIMetaData>${_esc(didl)}</CurrentURIMetaData>');
    await _call('Play', '<Speed>1</Speed>');
    if (m.start > Duration.zero) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        await seek(m.start);
      } catch (_) {}
    }
  }

  @override
  Future<void> play() async => _call('Play', '<Speed>1</Speed>').then((_) {});
  @override
  Future<void> pause() async => _call('Pause', '').then((_) {});
  @override
  Future<void> stop() async => _call('Stop', '').then((_) {});

  static String _hms(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Future<void> seek(Duration to) async =>
      _call('Seek', '<Unit>REL_TIME</Unit><Target>${_hms(to)}</Target>').then((_) {});

  @override
  Future<Duration?> position() async {
    final xml = XmlDocument.parse(await _call('GetPositionInfo', ''));
    final t = xml.findAllElements('RelTime').map((e) => e.innerText).firstOrNull;
    if (t == null) return null;
    final p = t.split(':');
    if (p.length != 3) return null;
    final secs = double.tryParse(p[2]);
    final h = int.tryParse(p[0]), m = int.tryParse(p[1]);
    if (secs == null || h == null || m == null) return null;
    return Duration(hours: h, minutes: m, seconds: secs.floor());
  }
}

// -----------------------------------------------------------------------------
// Roku (External Control Protocol, plays through the built-in Roku Media Player)

class RokuBackend extends CastBackend {
  RokuBackend(this.host, this.port);
  final String host;
  final int port;

  Uri _u(String path, [Map<String, String>? q]) => Uri(scheme: 'http', host: host, port: port, path: path, queryParameters: q);

  @override
  Future<void> load(CastMedia m) async {
    final fmt = switch (m.contentType) {
      'application/x-mpegURL' => 'hls',
      'video/x-matroska' => 'mkv',
      'video/mp2t' => 'ts',
      _ => 'mp4',
    };
    final r = await http
        .post(_u('/input/15985', {'t': 'v', 'u': m.url, 'k': '(null)', 'videoName': m.title, 'videoFormat': fmt}))
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) throw 'The Roku refused the stream (${r.statusCode}).';
  }

  Future<void> _key(String k) => http.post(_u('/keypress/$k')).timeout(const Duration(seconds: 5));

  // The Roku has one Play/Pause key, so play and pause both toggle.
  @override
  Future<void> play() => _key('Play');
  @override
  Future<void> pause() => _key('Play');
  @override
  Future<void> seek(Duration to) async {} // Not supported by the Roku Media Player.
  @override
  Future<void> stop() => _key('Home');

  @override
  Future<Duration?> position() async {
    final r = await http.get(_u('/query/media-player')).timeout(const Duration(seconds: 4));
    final pos = XmlDocument.parse(r.body).findAllElements('position').firstOrNull?.innerText;
    final ms = int.tryParse((pos ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
    return ms == null ? null : Duration(milliseconds: ms);
  }
}

// -----------------------------------------------------------------------------
// AirPlay (AirPlay 1 HTTP: Apple TV up to 3rd gen, and TVs / receivers that accept open AirPlay)

class AirPlayBackend extends CastBackend {
  AirPlayBackend(this.host, this.port);
  final String host;
  final int port;
  final _session = 'tvflow-${DateTime.now().microsecondsSinceEpoch}';

  Uri _u(String path, [Map<String, String>? q]) => Uri(scheme: 'http', host: host, port: port, path: path, queryParameters: q);
  Map<String, String> get _h => {'User-Agent': 'MediaControl/1.0', 'X-Apple-Session-ID': _session};

  @override
  Future<void> load(CastMedia m) async {
    final r = await http
        .post(_u('/play'),
            headers: {..._h, 'Content-Type': 'text/parameters'},
            body: 'Content-Location: ${m.url}\nStart-Position: ${m.start.inSeconds == 0 ? 0 : (m.start.inSeconds / 1.0)}\n')
        .timeout(const Duration(seconds: 10));
    if (r.statusCode == 200) return;
    if (r.statusCode == 403 || r.statusCode == 470 || r.statusCode == 401) {
      throw 'This device needs AirPlay pairing, which TVflow does not support yet. Try Chromecast or DLNA if it has them.';
    }
    throw 'The AirPlay device refused the stream (${r.statusCode}).';
  }

  Future<void> _rate(int v) => http.post(_u('/rate', {'value': '$v'}), headers: _h).timeout(const Duration(seconds: 5));
  @override
  Future<void> play() => _rate(1);
  @override
  Future<void> pause() => _rate(0);
  @override
  Future<void> seek(Duration to) =>
      http.post(_u('/scrub', {'position': '${to.inSeconds}'}), headers: _h).timeout(const Duration(seconds: 5));
  @override
  Future<void> stop() => http.post(_u('/stop'), headers: _h).timeout(const Duration(seconds: 5));
}
