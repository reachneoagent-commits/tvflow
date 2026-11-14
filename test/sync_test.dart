import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:tvflow/core/hlc.dart';
import 'package:tvflow/data/database/schema.dart';
import 'package:tvflow/data/repository.dart';
import 'package:tvflow/data/sources/models.dart';
import 'package:tvflow/data/sync/sync_engine.dart';

/// A simulated device: its own database, clock and sync engine.
class Device {
  Device(this.id, {int Function()? clock}) {
    db = AppDatabase.memory();
    hlc = Hlc(id, now: clock);
    repo = Repository(db, hlc);
    engine = SyncEngine(db: db, hlc: hlc, deviceId: id, deviceName: 'Device $id');
  }
  final String id;
  late final AppDatabase db;
  late final Hlc hlc;
  late final Repository repo;
  late final SyncEngine engine;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory folder;
  setUp(() async => folder = await Directory.systemTemp.createTemp('sync'));
  tearDown(() async => folder.delete(recursive: true));

  group('HLC', () {
    test('monotonic even when the clock stands still', () {
      final h = Hlc('a', now: () => 1000);
      final a = h.tick(), b = h.tick();
      expect(b.compareTo(a), greaterThan(0));
    });
    test('observing a future stamp moves the clock past it', () {
      final h = Hlc('a', now: () => 1000);
      h.observe(Hlc.format(5000, 3, 'b'));
      expect(h.tick().compareTo(Hlc.format(5000, 3, 'b')), greaterThan(0));
    });
  });

  test('favourites, groups and history travel between two devices', () async {
    final a = Device('aaaa'), b = Device('bbbb');
    final src = await a.repo.saveSource(
        name: 'Prov', kind: SourceKind.xtream, server: 'http://x', username: 'u', password: 'p');
    await a.repo.toggleFavorite(src.id, ContentType.live, '1');
    final g = await a.repo.createGroup(src.id, ContentType.movie, 'Weekend');
    await a.repo.setInGroup(g.id, 'm9', true);
    await a.repo.recordWatch(
        sourceId: src.id, type: 'movie', itemId: 'm9', name: 'M', positionMs: 60000, durationMs: 6000000);
    await a.repo.setPref('theme', 'dark');

    await a.engine.run(folder: folder.path, passphrase: 'secret');
    final rep = await b.engine.run(folder: folder.path, passphrase: 'secret');
    expect(rep.failedPeers, isEmpty);

    final srcB = await b.repo.source(src.id);
    expect(srcB?.password, 'p', reason: 'encrypted sync carries credentials');
    expect(await b.repo.favoriteIds(src.id, ContentType.live), ['1']);
    expect((await b.repo.userGroups(src.id, ContentType.movie)).single.name, 'Weekend');
    expect(await b.repo.groupItemIds(g.id), ['m9']);
    expect((await b.repo.watch(src.id, 'movie', 'm9'))?.positionMs, 60000);
    expect((await b.repo.allPrefs())['theme'], 'dark');
  });

  test('offline edits on both sides merge; newest edit of a row wins', () async {
    var t = 1000;
    final a = Device('aaaa', clock: () => t), b = Device('bbbb', clock: () => t);
    final src = await a.repo.saveSource(name: 'S', kind: SourceKind.m3u, url: 'http://l');
    await a.engine.run(folder: folder.path);
    await b.engine.run(folder: folder.path);

    // Both offline: different favourites, conflicting pref.
    t = 2000;
    await a.repo.toggleFavorite(src.id, ContentType.live, 'x');
    await a.repo.setPref('start_tab', 'live');
    t = 3000;
    await b.repo.toggleFavorite(src.id, ContentType.live, 'y');
    await b.repo.setPref('start_tab', 'movies'); // later → wins

    await a.engine.run(folder: folder.path);
    await b.engine.run(folder: folder.path);
    await a.engine.run(folder: folder.path);

    for (final d in [a, b]) {
      expect((await d.repo.favoriteIds(src.id, ContentType.live)).toSet(), {'x', 'y'});
      expect((await d.repo.allPrefs())['start_tab'], 'movies');
    }
  });

  test('deletions propagate as tombstones', () async {
    final a = Device('aaaa'), b = Device('bbbb');
    final src = await a.repo.saveSource(name: 'S', kind: SourceKind.m3u, url: 'http://l');
    await a.repo.toggleFavorite(src.id, ContentType.movie, 'm');
    await a.engine.run(folder: folder.path);
    await b.engine.run(folder: folder.path);
    expect(await b.repo.favoriteIds(src.id, ContentType.movie), ['m']);

    await b.repo.toggleFavorite(src.id, ContentType.movie, 'm'); // remove on B
    await b.engine.run(folder: folder.path);
    await a.engine.run(folder: folder.path);
    expect(await a.repo.favoriteIds(src.id, ContentType.movie), isEmpty);
  });

  test('without a passphrase credentials stay local', () async {
    final a = Device('aaaa'), b = Device('bbbb');
    final src = await a.repo.saveSource(
        name: 'S', kind: SourceKind.xtream, server: 'http://x', username: 'u', password: 'p');
    await a.engine.run(folder: folder.path);
    await b.engine.run(folder: folder.path);
    final bs = await b.repo.source(src.id);
    expect(bs?.name, 'S');
    expect(bs?.password, isNull);
    final raw = File('${folder.path}/aaaa${SyncEngine.fileExt}').readAsStringSync();
    expect(raw.contains('"p"'), isFalse);
  });

  test('with a passphrase credentials travel, encrypted', () async {
    final a = Device('aaaa'), b = Device('bbbb');
    final src = await a.repo.saveSource(
        name: 'S', kind: SourceKind.xtream, server: 'http://x', username: 'u', password: 'secret-pw');
    await a.engine.run(folder: folder.path, passphrase: 'pp');
    await b.engine.run(folder: folder.path, passphrase: 'pp');
    expect((await b.repo.source(src.id))?.password, 'secret-pw');
    final raw = File('${folder.path}/aaaa${SyncEngine.fileExt}').readAsStringSync();
    expect(raw.contains('secret-pw'), isFalse);
  });

  test('a redacted snapshot keeps the logins already on this device', () async {
    final a = Device('aaaa'), b = Device('bbbb');
    final src = await a.repo.saveSource(
        name: 'S', kind: SourceKind.m3u, url: 'http://h/get.php?username=u&password=p');
    await a.engine.run(folder: folder.path, passphrase: 'pp');
    await b.engine.run(folder: folder.path, passphrase: 'pp');
    // A later rename on A, synced without a passphrase.
    await a.repo.saveSource(id: src.id, name: 'Renamed', kind: SourceKind.m3u,
        url: 'http://h/get.php?username=u&password=p');
    await a.engine.run(folder: folder.path);
    await b.engine.run(folder: folder.path);
    final bs = await b.repo.source(src.id);
    expect(bs?.name, 'Renamed');
    expect(bs?.url, 'http://h/get.php?username=u&password=p');
  });

  test('wrong passphrase and corrupt files are reported, not fatal', () async {
    final a = Device('aaaa'), b = Device('bbbb'), c = Device('cccc');
    await a.repo.setPref('k', 'v');
    await a.engine.run(folder: folder.path, passphrase: 'right');
    File('${folder.path}/zzzz${SyncEngine.fileExt}').writeAsStringSync('{broken');
    await c.repo.setPref('k2', 'v2');
    await c.engine.run(folder: folder.path, passphrase: 'other');

    final rep = await b.engine.run(folder: folder.path, passphrase: 'right');
    expect(rep.failedPeers.length, 2); // c (wrong key) + zzzz (corrupt)
    expect((await b.repo.allPrefs())['k'], 'v');
    expect(rep.failedPeers.any((p) => p.error!.contains('passphrase')), isTrue);
  });

  test('missing folder gives a clear error', () async {
    final a = Device('aaaa');
    expect(() => a.engine.run(folder: '${folder.path}/nope'), throwsA(isA<SyncException>()));
  });
}
