import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tvflow/core/text.dart';
import 'package:tvflow/data/epg/xmltv.dart';
import 'package:tvflow/data/sources/m3u_parser.dart';
import 'package:tvflow/data/sources/models.dart';
import 'package:tvflow/data/sources/xtream_client.dart';

const _m3u = '''
#EXTM3U url-tvg="http://epg.example/guide.xml.gz" x-tvg-url="http://epg2.example/a.xml"
#EXTINF:-1 tvg-id="bbc1.uk" tvg-name="BBC One" tvg-logo="http://logo/bbc.png" group-title="UK, General" catchup="default" catchup-days="7",UK: BBC One HD
http://host/live/u/p/1.ts
#EXTINF:-1 group-title="UK, General",Channel, with comma
http://host/live/u/p/2.m3u8
#EXTINF:-1 tvg-logo="http://logo/m.jpg" group-title="Movies EN",EN - The Matrix (1999)
http://host/movie/u/p/10.mkv
#EXTINF:-1 group-title="Series EN",Friends S01 E02
http://host/series/u/p/100.mp4
#EXTINF:-1 group-title="Series EN",Friends S01 E01
http://host/series/u/p/99.mp4
#EXTINF:-1,No group local video
/Users/me/video.mp4
''';

void main() {
  group('M3U', () {
    final r = M3uParser.parse(_m3u);

    test('reads EPG urls from the header', () {
      expect(r.epgUrls, ['http://epg.example/guide.xml.gz', 'http://epg2.example/a.xml']);
    });

    test('splits live / movie / series', () {
      expect(r.batches[ContentType.live]!.items.length, 2);
      expect(r.batches[ContentType.movie]!.items.length, 2);
      expect(r.batches[ContentType.series]!.items.length, 1);
      expect(r.entryCount, 6);
    });

    test('keeps attributes and commas inside quotes', () {
      final live = r.batches[ContentType.live]!.items;
      expect(live[0].name, 'UK: BBC One HD');
      expect(live[0].epgId, 'bbc1.uk');
      expect(live[0].icon, 'http://logo/bbc.png');
      expect(live[0].archiveDays, 7);
      expect(live[1].name, 'Channel, with comma');
      expect(r.batches[ContentType.live]!.categories.single.name, 'UK, General');
    });

    test('groups series episodes in order', () {
      final s = r.batches[ContentType.series]!.items.single;
      expect(s.name, 'Friends');
      final eps = r.series[s.id]!.episodes;
      expect(eps.map((e) => e.episode), [1, 2]);
      expect(eps.first.url, 'http://host/series/u/p/99.mp4');
    });

    test('movie year and ids are stable', () {
      final m = r.batches[ContentType.movie]!.items.first;
      expect(m.year, 1999);
      expect(M3uParser.parse(_m3u).batches[ContentType.movie]!.items.first.id, m.id);
    });

    test('rejects non-playlists', () {
      expect(() => M3uParser.parse('<html>nope</html>'), throwsA(isA<M3uFormatException>()));
    });

    test('detects Xtream get.php links', () {
      final d = detectXtream('http://srv.tv:8080/get.php?username=a&password=b&type=m3u_plus');
      expect(d?.server, 'http://srv.tv:8080');
      expect(d?.username, 'a');
      expect(detectXtream('http://x/list.m3u'), isNull);
    });
  });

  group('Xtream', () {
    final dir = '../research/data-samples';
    final available = Directory(dir).existsSync();

    test('parses real sample payloads', () {
      final cats = File('$dir/vod_categories.json').readAsBytesSync();
      final list = File('$dir/vod_sample.json').readAsBytesSync();
      final b = XtreamClient.parseBatch(ContentType.movie, cats, list);
      expect(b.items, isNotEmpty);
      expect(b.categories, isNotEmpty);
      final first = b.items.first;
      expect(first.ext, isNotNull);
      expect(first.year, isNotNull);
    }, skip: available ? false : 'samples not present');

    test('parses live + series samples', () {
      final live = XtreamClient.parseBatch(
          ContentType.live,
          File('$dir/live_categories.json').readAsBytesSync(),
          File('$dir/live_channels_sample.json').readAsBytesSync());
      expect(live.items.first.icon, startsWith('http'));
      final series = XtreamClient.parseBatch(
          ContentType.series,
          File('$dir/series_categories.json').readAsBytesSync(),
          File('$dir/series_sample.json').readAsBytesSync());
      expect(series.items.first.plot, isNotNull);
    }, skip: available ? false : 'samples not present');

    test('accepts object-shaped lists', () {
      final b = XtreamClient.parseBatch(
          ContentType.live,
          utf8.encode('[]'),
          utf8.encode('{"0":{"stream_id":5,"name":"A","category_id":"1"}}'));
      expect(b.items.single.id, '5');
    });
  });

  group('text helpers', () {
    test('normalize folds accents and punctuation', () {
      expect(normalize('Café-TV  HD!'), 'cafe tv hd');
    });
    test('langCode picks prefixes but not VIP/VOD', () {
      expect(langCode('EN - The Matrix'), 'EN');
      expect(langCode('FR| TF1'), 'FR');
      expect(langCode('VIP - NO EVENT'), isNull);
      expect(langCode('Some Channel', 'SRS | EN - NETFLIX'), isNull);
      expect(langCode('Some Channel', 'AR | Sports'), 'AR');
    });
    test('channelKey ignores quality and country prefix', () {
      expect(channelKey('UK: BBC One HD'), channelKey('BBC One'));
      expect(channelKey('FR | TF1 FHD'), 'tf1');
    });
  });

  group('XMLTV', () {
    test('time parsing honours offsets', () {
      expect(parseXmltvTime('20260101120000 +0000'), DateTime.utc(2026, 1, 1, 12).millisecondsSinceEpoch ~/ 1000);
      expect(parseXmltvTime('20260101120000 +0100'), DateTime.utc(2026, 1, 1, 11).millisecondsSinceEpoch ~/ 1000);
      expect(parseXmltvTime('garbage'), isNull);
    });

    test('matches by id and by name, skips the rest', () async {
      final now = DateTime.now().toUtc();
      String ts(DateTime d) =>
          '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}'
          '${d.hour.toString().padLeft(2, '0')}0000 +0000';
      final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<tv>
 <channel id="bbc1.uk"><display-name>BBC One</display-name></channel>
 <channel id="cnn.us"><display-name>CNN International</display-name></channel>
 <channel id="other"><display-name>Not Ours</display-name></channel>
 <programme start="${ts(now)}" stop="${ts(now.add(const Duration(hours: 1)))}" channel="bbc1.uk"><title>News</title><desc>Headlines</desc></programme>
 <programme start="${ts(now)}" stop="${ts(now.add(const Duration(hours: 1)))}" channel="cnn.us"><title>World</title></programme>
 <programme start="${ts(now)}" stop="${ts(now.add(const Duration(hours: 1)))}" channel="other"><title>Skip me</title></programme>
 <programme start="20000101000000 +0000" stop="20000101010000 +0000" channel="bbc1.uk"><title>Too old</title></programme>
</tv>''';
      final dir = await Directory.systemTemp.createTemp('xmltv');
      final f = File('${dir.path}/g.xml.gz')..writeAsBytesSync(gzip.encode(utf8.encode(xml)));
      final res = await loadXmltv(XmltvRequest(
        urls: const [],
        localFile: f.path,
        channels: {
          'a': ('bbc1.uk', 'UK: BBC One HD'),
          'b': (null, 'US: CNN International FHD'),
          'c': (null, 'Unknown'),
        },
      ));
      expect(res.errors, isEmpty);
      expect(res.matches, {'a': 'bbc1.uk', 'b': 'cnn.us'});
      expect(res.programmes.map((p) => p.$4).toSet(), {'News', 'World'});
      expect(res.channelCount, 3);
      await dir.delete(recursive: true);
    });
  });
}
