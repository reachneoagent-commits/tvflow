import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import '../../core/net.dart';
import '../../core/text.dart';

/// What we want from an XMLTV feed: our live channels, by provider EPG id
/// and by name, so programmes can be matched and everything else skipped.
class XmltvRequest {
  XmltvRequest({
    required this.urls,
    required this.channels,
    this.userAgent = kDefaultUserAgent,
    this.pastHours = 24,
    this.futureHours = 72,
    this.localFile,
  });

  final List<String> urls;

  /// itemId → (epgId, name)
  final Map<String, (String?, String)> channels;
  final String userAgent;
  final int pastHours;
  final int futureHours;
  final String? localFile;
}

class XmltvResult {
  XmltvResult({
    required this.programmes,
    required this.matches,
    required this.channelCount,
    required this.errors,
  });

  /// (xmltvChannelId, start s, stop s, title, desc)
  final List<(String, int, int, String, String?)> programmes;

  /// itemId → xmltv channel id
  final Map<String, String> matches;
  final int channelCount;
  final List<String> errors;
}

/// Downloads (or reads) XMLTV feeds and parses them as a stream.
/// Intended to run inside `Isolate.run`.
Future<XmltvResult> loadXmltv(XmltvRequest req) async {
  final byId = <String, List<String>>{}; // lower epg id → itemIds
  final byName = <String, List<String>>{}; // channelKey(name) → itemIds
  req.channels.forEach((itemId, v) {
    final (epgId, name) = v;
    if (epgId != null && epgId.isNotEmpty) {
      (byId[epgId.toLowerCase()] ??= []).add(itemId);
    }
    final k = channelKey(name);
    if (k.isNotEmpty) (byName[k] ??= []).add(itemId);
  });

  final matches = <String, String>{};
  final wanted = <String>{};
  final programmes = <(String, int, int, String, String?)>[];
  final errors = <String>[];
  var channelCount = 0;
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final from = now - req.pastHours * 3600;
  final to = now + req.futureHours * 3600;

  Future<void> consume(Stream<List<int>> bytes) async {
    final chars = _decodeMaybeGzip(bytes);
    await for (final nodes in chars
        .toXmlEvents()
        .normalizeEvents()
        .selectSubtreeEvents(
            (e) => e.localName == 'channel' || e.localName == 'programme')
        .toXmlNodes()) {
      for (final node in nodes) {
        if (node is! XmlElement) continue;
        if (node.localName == 'channel') {
          channelCount++;
          final id = node.getAttribute('id') ?? '';
          if (id.isEmpty) continue;
          final hits = <String>{...?byId[id.toLowerCase()]};
          for (final dn in node.findElements('display-name')) {
            hits.addAll(byName[channelKey(dn.innerText)] ?? const []);
          }
          final idKey = channelKey(id.split('.').first);
          if (idKey.length > 3) hits.addAll(byName[idKey] ?? const []);
          for (final itemId in hits) {
            // Exact provider id beats a name match.
            final exact = byId[id.toLowerCase()]?.contains(itemId) ?? false;
            if (exact || !matches.containsKey(itemId)) matches[itemId] = id;
          }
          if (hits.isNotEmpty) wanted.add(id);
        } else {
          final ch = node.getAttribute('channel');
          if (ch == null || !(wanted.contains(ch) || byId.containsKey(ch.toLowerCase()))) {
            continue;
          }
          final start = parseXmltvTime(node.getAttribute('start'));
          final stop = parseXmltvTime(node.getAttribute('stop'));
          if (start == null || stop == null || stop < from || start > to) continue;
          final title = node.getElement('title')?.innerText.trim() ?? '';
          final desc = node.getElement('desc')?.innerText.trim();
          programmes.add((ch, start, stop, title, (desc?.isEmpty ?? true) ? null : desc));
          if (!wanted.contains(ch)) {
            // Channel element missing but id matches a provider epg id.
            for (final itemId in byId[ch.toLowerCase()] ?? const <String>[]) {
              matches[itemId] = ch;
            }
            wanted.add(ch);
          }
        }
      }
    }
  }

  if (req.localFile != null) {
    try {
      await consume(File(req.localFile!).openRead());
    } catch (e) {
      errors.add('EPG file: $e');
    }
  }
  for (final url in req.urls) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      errors.add('Invalid EPG URL: $url');
      continue;
    }
    final client = http.Client();
    try {
      final r = http.Request('GET', uri)..headers['User-Agent'] = req.userAgent;
      final res = await client.send(r).timeout(const Duration(seconds: 60));
      if (res.statusCode >= 400) {
        errors.add('${uri.host} returned HTTP ${res.statusCode} for the EPG.');
        continue;
      }
      await consume(res.stream.timeout(const Duration(seconds: 90)));
    } on TimeoutException {
      errors.add('EPG download from ${uri.host} timed out.');
    } on XmlException catch (e) {
      errors.add('EPG from ${uri.host} is not valid XMLTV (${e.message}).');
    } catch (e) {
      errors.add('EPG from ${uri.host} failed: $e');
    } finally {
      client.close();
    }
  }

  return XmltvResult(
    programmes: programmes,
    matches: matches,
    channelCount: channelCount,
    errors: errors,
  );
}

/// Peeks at the first bytes; gunzips when the gzip magic is present.
Stream<String> _decodeMaybeGzip(Stream<List<int>> input) async* {
  final controller = StreamController<List<int>>();
  var decided = false;
  late Stream<List<int>> decoded;
  final sub = input.listen(null);
  final first = Completer<List<int>?>();
  sub.onData((chunk) {
    if (!decided) {
      decided = true;
      sub.pause();
      first.complete(chunk);
    } else {
      controller.add(chunk);
    }
  });
  sub.onError(controller.addError);
  sub.onDone(() {
    if (!decided) first.complete(null);
    controller.close();
  });
  final head = await first.future;
  if (head == null) return;
  final gz = head.length > 1 && head[0] == 0x1f && head[1] == 0x8b;
  final raw = (() async* {
    yield head;
    sub.resume();
    yield* controller.stream;
  })();
  decoded = gz ? raw.transform(gzip.decoder) : raw;
  yield* decoded.transform(const Utf8Decoder(allowMalformed: true));
}

/// "20261025120000 +0100" → epoch seconds (UTC). Null when unparsable.
int? parseXmltvTime(String? v) {
  if (v == null) return null;
  final m = RegExp(r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})?\s*([+-]\d{4})?')
      .firstMatch(v.trim());
  if (m == null) return null;
  final dt = DateTime.utc(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
    int.parse(m.group(4)!),
    int.parse(m.group(5)!),
    int.parse(m.group(6) ?? '0'),
  );
  var secs = dt.millisecondsSinceEpoch ~/ 1000;
  final tz = m.group(7);
  if (tz != null) {
    final sign = tz.startsWith('-') ? -1 : 1;
    final h = int.parse(tz.substring(1, 3));
    final mi = int.parse(tz.substring(3, 5));
    secs -= sign * (h * 3600 + mi * 60);
  }
  return secs;
}
