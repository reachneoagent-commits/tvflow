import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Posters and logos are saved to disk, so they load instantly on the next launch
/// and are not downloaded again. Files live in the OS cache folder (safe to delete).
class ImageDiskCache {
  ImageDiskCache._();
  static final instance = ImageDiskCache._();

  static const _maxBytes = 400 * 1024 * 1024;
  static const _maxParallel = 6;

  Directory? _dir;
  final _client = http.Client();
  final _inflight = <String, Future<File?>>{};
  final _waiting = <Completer<void>>[];
  int _active = 0;

  Future<Directory> _folder() async {
    final d = _dir;
    if (d != null) return d;
    final base = await getApplicationCacheDirectory();
    final dir = Directory(p.join(base.path, 'images'));
    await dir.create(recursive: true);
    return _dir = dir;
  }

  /// Keeps the cache under the size limit, dropping the least recently used files. Run once after startup.
  Future<void> trim() async {
    try {
      final files = <File, FileStat>{};
      var total = 0;
      await for (final e in (await _folder()).list()) {
        if (e is! File) continue;
        final s = await e.stat();
        files[e] = s;
        total += s.size;
      }
      if (total <= _maxBytes) return;
      final old = files.entries.toList()..sort((a, b) => a.value.accessed.compareTo(b.value.accessed));
      for (final e in old) {
        if (total <= _maxBytes * 0.8) break;
        total -= e.value.size;
        await e.key.delete();
      }
    } catch (_) {}
  }

  Future<void> _acquire() async {
    if (_active < _maxParallel) {
      _active++;
      return;
    }
    final c = Completer<void>();
    _waiting.add(c);
    await c.future;
  }

  void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeAt(0).complete();
    } else {
      _active--;
    }
  }

  Future<File?> fetch(String url) => _inflight[url] ??= _load(url).whenComplete(() {
        // Block body on purpose: returning remove()'s Future would make whenComplete wait on itself forever.
        _inflight.remove(url);
      });

  Future<File?> _load(String url) async {
    try {
      final file = File(p.join((await _folder()).path, sha1.convert(url.codeUnits).toString()));
      if (await file.exists() && await file.length() > 0) {
        // Touch so the trim keeps what is used.
        unawaited(file.setLastAccessed(DateTime.now()).catchError((_) {}));
        return file;
      }
      await _acquire();
      try {
        final r = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
        if (r.statusCode != 200 || r.bodyBytes.isEmpty) return null;
        final tmp = File('${file.path}.part');
        await tmp.writeAsBytes(r.bodyBytes, flush: true);
        await tmp.rename(file.path);
        return file;
      } finally {
        _release();
      }
    } catch (_) {
      return null;
    }
  }
}

/// ImageProvider that reads through [ImageDiskCache].
@immutable
class DiskCachedImage extends ImageProvider<DiskCachedImage> {
  const DiskCachedImage(this.url);
  final String url;

  @override
  Future<DiskCachedImage> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(DiskCachedImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _codec(decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _codec(ImageDecoderCallback decode) async {
    final file = await ImageDiskCache.instance.fetch(url);
    if (file == null) throw StateError('Image unavailable: $url');
    return decode(await ui.ImmutableBuffer.fromUint8List(await file.readAsBytes()));
  }

  @override
  bool operator ==(Object other) => other is DiskCachedImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
