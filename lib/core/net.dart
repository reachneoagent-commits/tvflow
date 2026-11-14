import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

/// Default User-Agent, same as the reference app ("VLC/3.0.4 LibVLC/3.0.4").
const kDefaultUserAgent = 'VLC/3.0.4 LibVLC/3.0.4';

class NetException implements Exception {
  NetException(this.message, {this.status});
  final String message;
  final int? status;
  @override
  String toString() => message;
}

/// Small HTTP helper with timeouts, user-agent and readable errors.
class Net {
  Net({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<int>> getBytes(
    Uri uri, {
    String userAgent = kDefaultUserAgent,
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 60),
    void Function(int received, int? total)? onProgress,
  }) async {
    final req = http.Request('GET', uri)
      ..headers['User-Agent'] = userAgent
      ..headers.addAll(headers);
    http.StreamedResponse res;
    try {
      res = await _client.send(req).timeout(timeout);
    } on TimeoutException {
      throw NetException('The server did not respond in time (${uri.host}).');
    } on SocketException catch (e) {
      throw NetException('Could not reach ${uri.host}: ${e.osError?.message ?? e.message}');
    } on HandshakeException {
      throw NetException('Secure connection to ${uri.host} failed.');
    } on http.ClientException catch (e) {
      throw NetException('Connection to ${uri.host} failed: ${e.message}');
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw NetException(
          'Access denied by ${uri.host} (HTTP ${res.statusCode}). Check the credentials.',
          status: res.statusCode);
    }
    if (res.statusCode >= 400) {
      throw NetException('${uri.host} returned HTTP ${res.statusCode}.',
          status: res.statusCode);
    }
    final total = res.contentLength;
    final out = BytesBuilder(copy: false);
    var got = 0;
    final idle = const Duration(seconds: 60);
    await for (final chunk in res.stream.timeout(idle,
        onTimeout: (s) => s.addError(
            NetException('Download from ${uri.host} stalled.')))) {
      out.add(chunk);
      got += chunk.length;
      onProgress?.call(got, total);
    }
    return out.takeBytes();
  }

  /// Text body; transparently gunzips `.gz` / gzip-magic payloads.
  Future<String> getText(Uri uri,
      {String userAgent = kDefaultUserAgent,
      Map<String, String> headers = const {},
      Duration timeout = const Duration(seconds: 60),
      void Function(int, int?)? onProgress}) async {
    final bytes = await getBytes(uri,
        userAgent: userAgent,
        headers: headers,
        timeout: timeout,
        onProgress: onProgress);
    return decodeText(bytes);
  }

  Future<dynamic> getJson(Uri uri,
      {String userAgent = kDefaultUserAgent,
      Map<String, String> headers = const {},
      Duration timeout = const Duration(seconds: 60)}) async {
    final text = await getText(uri,
        userAgent: userAgent, headers: headers, timeout: timeout);
    try {
      return jsonDecode(text);
    } on FormatException {
      final snippet = text.length > 120 ? text.substring(0, 120) : text;
      throw NetException(
          'Unexpected response from ${uri.host} (not JSON): ${snippet.trim()}');
    }
  }

  void close() => _client.close();
}

/// Decodes bytes as UTF-8 (latin-1 fallback), gunzipping when needed.
String decodeText(List<int> bytes) {
  var data = bytes;
  if (data.length > 2 && data[0] == 0x1f && data[1] == 0x8b) {
    data = const GZipDecoder().decodeBytes(data);
  }
  try {
    return utf8.decode(data);
  } on FormatException {
    return latin1.decode(data);
  }
}
