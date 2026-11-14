import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import 'detail_common.dart';

/// "Add from your phone": the TV shows a web address and a code; the phone opens that page, and
/// the playlist link is pasted there instead of being typed with the remote.
class PhoneSetupScreen extends StatefulWidget {
  const PhoneSetupScreen({super.key});
  @override
  State<PhoneSetupScreen> createState() => _PhoneSetupScreenState();
}

class _PhoneSetupScreenState extends State<PhoneSetupScreen> {
  int _port = 8080;
  HttpServer? _server;
  List<String> _addresses = [];
  String? _error;
  int _wrong = 0;
  final String _pin = (1000 + Random.secure().nextInt(9000)).toString();
  String? _added;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  Future<void> _start() async {
    try {
      HttpServer? server;
      for (var port = 8080; port < 8090 && server == null; port++) {
        try {
          server = await HttpServer.bind(InternetAddress.anyIPv4, port);
          _port = port;
        } on SocketException {
          // Port in use: try the next one.
        }
      }
      if (server == null) throw 'no free port between 8080 and 8089';
      _server = server;
      final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      final ips = [
        for (final i in ifaces)
          for (final a in i.addresses)
            if (!a.isLoopback) a.address
      ];
      if (!mounted) return;
      setState(() => _addresses = ips);
      server.listen(_handle);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not start the phone page: $e');
    }
  }

  Future<void> _handle(HttpRequest req) async {
    try {
      if (req.method == 'POST' && req.uri.path == '/add') {
        if (req.contentLength > 65536) {
          req.response.statusCode = HttpStatus.requestEntityTooLarge;
          await req.response.close();
          return;
        }
        final body = await utf8.decoder.bind(req).join();
        final f = Uri.splitQueryString(body);
        await _respond(req, await _add(f));
      } else {
        await _respond(req, _form());
      }
    } catch (e) {
      await _respond(req, _page('<p class="err">Something went wrong: ${_esc('$e')}</p>${_formBody()}'));
    }
  }

  Future<void> _respond(HttpRequest req, String html) async {
    req.response.headers.set('content-type', 'text/html; charset=utf-8');
    req.response.write(html);
    await req.response.close();
  }

  Future<String> _add(Map<String, String> f) async {
    if (_wrong >= 5) {
      return _page('<p class="err">Too many wrong codes. Close this page and open "Add from phone" on the TV again to get a new code.</p>');
    }
    if ((f['pin'] ?? '').trim() != _pin) {
      _wrong++;
      return _page('<p class="err">That code is not right. Check the number on your TV.</p>${_formBody(name: f['name'], url: f['url'])}');
    }
    final url = (f['url'] ?? '').trim();
    final name = (f['name'] ?? '').trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return _page('<p class="err">The link must start with http:// or https://</p>${_formBody(name: name, url: url)}');
    }
    if (!mounted) return _page('<p class="err">The TV screen was closed. Open Add from phone again.</p>');
    final state = AppScope.read(context);
    final err = await state.catalog.validate(SourceKind.m3u, url: url);
    if (err != null) {
      return _page('<p class="err">The TV could not load that playlist: ${_esc(err)}</p>${_formBody(name: name, url: url)}');
    }
    final s = await state.repo.saveSource(
      name: name.isEmpty ? Uri.tryParse(url)?.host ?? 'Playlist' : name,
      kind: SourceKind.m3u,
      url: url,
    );
    await state.sourceSaved(s);
    if (mounted) {
      setState(() => _added = s.name);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop(s);
      });
    }
    return _page('<p class="ok">Added "${_esc(s.name)}". It is loading on your TV. You can close this page.</p>');
  }

  static String _esc(String s) => const HtmlEscape(HtmlEscapeMode.attribute).convert(s);

  String _form() => _page(_formBody());

  String _formBody({String? name, String? url}) => '''
<form method="post" action="/add">
  <label>Code shown on the TV</label>
  <input name="pin" inputmode="numeric" autocomplete="off" placeholder="4-digit code" required>
  <label>Name (optional)</label>
  <input name="name" value="${_esc(name ?? '')}" placeholder="e.g. Oct 29" autocomplete="off">
  <label>Playlist link</label>
  <textarea name="url" rows="5" placeholder="Paste the playlist link here" required autocapitalize="off" autocorrect="off" spellcheck="false">${_esc(url ?? '')}</textarea>
  <button type="submit">Add to TVflow</button>
</form>''';

  String _page(String body) => '''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>TVflow</title>
<style>
body{margin:0;padding:24px;background:#080D0F;color:#ffffff;font:17px -apple-system,system-ui,sans-serif}
h1{font-size:26px;margin:0 0 18px}
label{display:block;margin:18px 0 6px;color:#B8C4C5;font-size:14px}
input,textarea{width:100%;box-sizing:border-box;padding:14px;border-radius:12px;border:1px solid #294D53;background:#17272B;color:#fff;font-size:17px}
button{margin-top:24px;width:100%;padding:16px;border:0;border-radius:14px;background:#F5C400;color:#080D0F;font-size:18px;font-weight:700}
.err{background:#3a1519;border:1px solid #7a2a31;padding:12px;border-radius:10px}
.ok{background:#0f3a2b;border:1px solid #1f7a55;padding:14px;border-radius:10px;font-size:18px}
</style></head><body><h1>Add a playlist to TVflow</h1>$body</body></html>''';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final addr = _addresses.isEmpty ? null : 'http://${_addresses.first}:$_port';
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          const BackBar(title: 'Add from your phone'),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _added != null
                      ? Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.circleCheck, size: 56, color: p.accent),
                          const SizedBox(height: 16),
                          Text('"$_added" added', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                        ])
                      : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          const Text('Paste your playlist from your phone',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 18),
                          _step(p, '1', 'Connect your phone to the same Wi-Fi as this TV.'),
                          _step(p, '2', 'Open your phone\'s browser and go to:'),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 4, 0, 10),
                            child: SelectableText(
                              _error ?? addr ?? 'Looking for this TV\'s address…',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _error != null ? p.danger : p.accent),
                            ),
                          ),
                          if (_addresses.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 32, bottom: 10),
                              child: Text('Other addresses to try: ${_addresses.skip(1).map((a) => 'http://$a:$_port').join('   ')}',
                                  style: TextStyle(color: p.ink3)),
                            ),
                          _step(p, '3', 'Type this code, paste your link, and tap Add:'),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 4, 0, 0),
                            child: Text(_pin, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: 6)),
                          ),
                        ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _step(Palette p, String n, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.pill, shape: BoxShape.circle),
            child: Text(n, style: TextStyle(color: p.onPill, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 17, color: p.ink2))),
        ]),
      );
}
