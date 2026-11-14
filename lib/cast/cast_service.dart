import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:cast/device.dart' as gc;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'cast_backends.dart';

/// What the player is showing right now, so the cast button knows what to send.
class CastSource {
  CastSource({required this.url, required this.title, this.subtitle, required this.isLive, required this.position});
  final String url;
  final String title;
  final String? subtitle;
  final bool isLive;
  final Duration Function() position;
}

enum CastStatus { idle, connecting, casting, error }

/// Finds TVs on the local network and sends the playing stream to one of them.
/// Chromecast and AirPlay are found with Bonjour (mDNS); smart TVs (DLNA) and Roku with SSDP.
class CastService extends ChangeNotifier {
  CastService._();
  static final instance = CastService._();

  final List<CastTarget> devices = [];
  bool scanning = false;
  CastSource? source;

  CastStatus status = CastStatus.idle;
  CastTarget? target;
  CastBackend? _backend;
  String? error;
  bool paused = false;
  Duration position = Duration.zero;
  Timer? _poll;
  int _scanId = 0;

  bool get casting => status == CastStatus.casting || status == CastStatus.connecting;

  /// Called when casting ends on its own or by the user, with where the TV got to.
  void Function(Duration position)? onStopped;

  void setSource(CastSource? s) {
    source = s;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Discovery

  Future<void> scan({Duration timeout = const Duration(seconds: 6)}) async {
    final id = ++_scanId;
    scanning = true;
    devices.removeWhere((d) => d != target);
    notifyListeners();
    void add(CastTarget t) {
      if (id != _scanId || devices.any((d) => d.id == t.id)) return;
      devices.add(t);
      notifyListeners();
    }

    await Future.wait([
      _bonjour('_googlecast._tcp', (s, host) {
        final name = s.attributes['fn'] ?? s.name;
        add(CastTarget(
          id: 'cc:${s.attributes['id'] ?? s.name}',
          name: name,
          kind: CastKind.chromecast,
          host: host,
          port: s.port,
          chromecast: gc.CastDevice(serviceName: s.name, name: name, host: host, port: s.port, extras: s.attributes),
        ));
      }, timeout),
      _bonjour('_airplay._tcp', (s, host) {
        add(CastTarget(id: 'ap:${s.name}', name: s.name, kind: CastKind.airplay, host: host, port: s.port));
      }, timeout),
      _ssdp(add, timeout),
    ]);
    if (id == _scanId) {
      scanning = false;
      notifyListeners();
    }
  }

  Future<void> _bonjour(String type, void Function(BonsoirService, String) found, Duration timeout) async {
    BonsoirDiscovery? d;
    try {
      d = BonsoirDiscovery(type: type);
      await d.initialize();
      d.eventStream!.listen((e) {
        switch (e) {
          case BonsoirDiscoveryServiceFoundEvent():
            e.service.resolve(d!.serviceResolver);
          case BonsoirDiscoveryServiceResolvedEvent():
            final host = e.service.hostAddresses.firstWhere((a) => !a.contains(':'), orElse: () => e.service.hostAddress ?? '');
            if (host.isNotEmpty && e.service.port > 0) found(e.service, host);
          default:
        }
      });
      await d.start();
      await Future.delayed(timeout);
    } catch (e) {
      debugPrint('Bonjour $type: $e');
    } finally {
      try {
        await d?.stop();
      } catch (_) {}
    }
  }

  Future<void> _ssdp(void Function(CastTarget) add, Duration timeout) async {
    RawDatagramSocket? sock;
    try {
      sock = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0, reuseAddress: true);
      final seen = <String>{};
      final pending = <Future<void>>[];
      sock.listen((ev) {
        if (ev != RawSocketEvent.read) return;
        final dg = sock!.receive();
        if (dg == null) return;
        final text = utf8.decode(dg.data, allowMalformed: true);
        final loc = RegExp(r'^location:\s*(.+)$', caseSensitive: false, multiLine: true).firstMatch(text)?.group(1)?.trim();
        if (loc == null || !seen.add(loc)) return;
        pending.add(_describe(loc, add));
      });
      for (final st in ['urn:schemas-upnp-org:service:AVTransport:1', 'roku:ecp']) {
        final msg = 'M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: "ssdp:discover"\r\nMX: 2\r\nST: $st\r\n\r\n';
        for (var i = 0; i < 2; i++) {
          sock.send(utf8.encode(msg), InternetAddress('239.255.255.250'), 1900);
          await Future.delayed(const Duration(milliseconds: 250));
        }
      }
      await Future.delayed(timeout);
      await Future.wait(pending);
    } catch (e) {
      debugPrint('SSDP: $e');
    } finally {
      sock?.close();
    }
  }

  Future<void> _describe(String location, void Function(CastTarget) add) async {
    try {
      final uri = Uri.parse(location);
      if (uri.port == 8060) {
        // Roku: the name is in device-info.
        final r = await http.get(uri.replace(path: '/query/device-info')).timeout(const Duration(seconds: 4));
        final x = XmlDocument.parse(r.body);
        final name = x.findAllElements('user-device-name').firstOrNull?.innerText ??
            x.findAllElements('friendly-device-name').firstOrNull?.innerText ??
            'Roku';
        add(CastTarget(id: 'roku:${uri.host}', name: name, kind: CastKind.roku, host: uri.host, port: 8060));
        return;
      }
      final r = await http.get(uri).timeout(const Duration(seconds: 4));
      final x = XmlDocument.parse(r.body);
      final name = x.findAllElements('friendlyName').firstOrNull?.innerText ?? uri.host;
      for (final s in x.findAllElements('service')) {
        final type = s.findElements('serviceType').firstOrNull?.innerText ?? '';
        if (!type.contains('AVTransport')) continue;
        final ctl = s.findElements('controlURL').firstOrNull?.innerText;
        if (ctl == null) continue;
        add(CastTarget(
          id: 'dlna:${uri.host}:$name',
          name: name,
          kind: CastKind.dlna,
          host: uri.host,
          port: uri.port,
          controlUrl: uri.resolve(ctl).toString(),
        ));
        return;
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Casting

  CastBackend _backendFor(CastTarget t) => switch (t.kind) {
        CastKind.chromecast => ChromecastBackend(t.chromecast!),
        CastKind.dlna => DlnaBackend(t.controlUrl!),
        CastKind.roku => RokuBackend(t.host, t.port),
        CastKind.airplay => AirPlayBackend(t.host, t.port),
      };

  Future<void> start(CastTarget t) async {
    final s = source;
    if (s == null) {
      error = 'Start playing something first, then cast it.';
      status = CastStatus.error;
      notifyListeners();
      return;
    }
    await stop(notify: false);
    target = t;
    status = CastStatus.connecting;
    error = null;
    paused = false;
    notifyListeners();
    final b = _backendFor(t);
    try {
      final pos = s.isLive ? Duration.zero : s.position();
      await b.load(CastMedia(url: s.url, title: s.title, subtitle: s.subtitle, isLive: s.isLive, start: pos));
      _backend = b;
      position = pos;
      status = CastStatus.casting;
      _poll = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    } catch (e) {
      b.dispose();
      status = CastStatus.error;
      error = '$e';
      target = null;
    }
    notifyListeners();
  }

  Future<void> _tick() async {
    final b = _backend;
    if (b == null) return;
    try {
      final p = await b.position();
      if (p != null) position = p;
      notifyListeners();
    } catch (e) {
      error = '$e';
      await stop();
    }
  }

  Future<void> togglePause() async {
    final b = _backend;
    if (b == null) return;
    try {
      paused ? await b.play() : await b.pause();
      paused = !paused;
    } catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  Future<void> seekBy(Duration d) async {
    final b = _backend;
    if (b == null || (source?.isLive ?? false)) return;
    final to = position + d;
    try {
      await b.seek(to < Duration.zero ? Duration.zero : to);
      position = to < Duration.zero ? Duration.zero : to;
    } catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  /// Stops the TV and hands playback back to this device.
  Future<void> stop({bool notify = true}) async {
    _poll?.cancel();
    _poll = null;
    final b = _backend;
    final pos = position;
    final was = casting;
    _backend = null;
    try {
      await b?.stop();
    } catch (_) {}
    b?.dispose();
    target = null;
    if (status != CastStatus.error) status = CastStatus.idle;
    paused = false;
    if (notify) {
      notifyListeners();
      if (was) onStopped?.call(pos);
    }
  }
}
