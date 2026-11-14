import 'package:flutter_test/flutter_test.dart';
import 'package:tvflow/core/hlc.dart';
import 'package:tvflow/data/catalog_service.dart';
import 'package:tvflow/data/database/schema.dart';
import 'package:tvflow/data/repository.dart';
import 'package:tvflow/data/sync/sync_engine.dart';

void main() {
  group('watch progress', () {
    late Repository repo;
    setUp(() => repo = Repository(AppDatabase.memory(), Hlc('t')));

    Future<WatchRow?> save(int pos, int dur) async {
      await repo.recordWatch(
          sourceId: 's', type: 'movie', itemId: 'm', name: 'M', positionMs: pos, durationMs: dur);
      return repo.watch('s', 'movie', 'm');
    }

    test('below 95% keeps the resume position', () async {
      final w = await save(196000, 300000); // 3:16 of 5:00
      expect(w!.finished, isFalse);
      expect(w.positionMs, 196000);
    });
    test('95% or more counts as finished and clears the position', () async {
      final w = await save(285000, 300000);
      expect(w!.finished, isTrue);
      expect(w.positionMs, 0);
    });
    test('unknown duration (live) is never finished', () async {
      final w = await save(5000000, 0);
      expect(w!.finished, isFalse);
    });
  });

  group('catch-up template', () {
    final start = DateTime.utc(2026, 10, 25, 12);
    final stop = DateTime.utc(2026, 10, 25, 13);
    final now = DateTime.utc(2026, 10, 25, 15);
    test('append mode adds the filled query to the channel URL', () {
      expect(
          m3uCatchupUrl('http://h/live.m3u8', {'catchup': 'append', 'catchupSource': '?utc={utc}&lutc={lutc}'},
              start, stop, now: now),
          'http://h/live.m3u8?utc=${start.millisecondsSinceEpoch ~/ 1000}&lutc=${now.millisecondsSinceEpoch ~/ 1000}');
    });
    test('absolute template is used as is, with end and duration', () {
      expect(
          m3uCatchupUrl('http://h/x', {'catchup': 'default', 'catchupSource': 'http://a/{utc}-{utcend}/{duration}'},
              start, stop),
          'http://a/${start.millisecondsSinceEpoch ~/ 1000}-${stop.millisecondsSinceEpoch ~/ 1000}/3600');
    });
    test('relative template without append/shift mode is unsupported', () {
      expect(m3uCatchupUrl('http://h/x', {'catchup': 'default', 'catchupSource': '?u={utc}'}, start, stop), isNull);
      expect(m3uCatchupUrl('http://h/x', null, start, stop), isNull);
    });
  });

  group('sync redaction', () {
    test('plain playlist URLs are kept, credential URLs are dropped', () {
      expect(urlCarriesCredentials('https://iptv-org.github.io/iptv/countries/uk.m3u'), isFalse);
      expect(urlCarriesCredentials('http://h/get.php?username=a&password=b&type=m3u'), isTrue);
      expect(urlCarriesCredentials('http://user:pw@h/list.m3u'), isTrue);
      expect(urlCarriesCredentials('http://h/list.m3u?token=abc'), isTrue);
      expect(urlCarriesCredentials(null), isFalse);
    });
    test('redactSource strips secrets and marks the row', () {
      final r = redactSource({
        'name': 'S',
        'url': 'http://h/get.php?username=a&password=b',
        'server': 'http://h:8080',
        'username': 'a',
        'password': 'b',
        'mac': '00:1A:79:00:00:01',
      });
      expect(r['url'], isNull);
      expect(r['server'], 'http://h:8080');
      expect([r['username'], r['password'], r['mac']], [null, null, null]);
      expect(r['_redacted'], isTrue);
      expect(r['name'], 'S');
    });
  });
}
