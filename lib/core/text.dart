import 'dart:convert';

import 'package:crypto/crypto.dart' as c;

/// Lower-cases and strips accents/punctuation so search and EPG matching are
/// forgiving ("Café TV HD" → "cafe tv hd").
String normalize(String s) {
  final lower = s.toLowerCase();
  final b = StringBuffer();
  for (final r in lower.runes) {
    final ch = String.fromCharCode(r);
    b.write(_fold[ch] ?? ch);
  }
  return b
      .toString()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();
}

/// Looser key for matching channel names to XMLTV display names: drops
/// quality tags, country prefixes and spaces ("UK: BBC One HD" → "bbcone").
String channelKey(String s) {
  var words = normalize(s).split(' ').where((w) => w.isNotEmpty).toList();
  if (words.length > 1 && _knownPrefixes.contains(words.first)) {
    words = words.sublist(1);
  }
  final kept = words.where((w) => !_quality.contains(w)).toList();
  return (kept.isEmpty ? words : kept).join();
}

const _quality = {
  'fhd', 'uhd', 'hd', 'sd', '4k', 'hevc', 'h265', '1080p', '720p', '50fps',
  'backup', 'raw',
};

const _knownPrefixes = {
  'uk', 'us', 'fr', 'de', 'it', 'es', 'pt', 'nl', 'be', 'ca', 'au', 'ar',
  'en', 'tr', 'pl', 'ro', 'ru', 'in', 'pk', 'ae', 'sa', 'ch', 'at', 'se',
  'no', 'dk', 'fi', 'gr', 'al', 'alb', 'ex', 'yu', 'br', 'mx', 'latam', 'ie',
};

/// Language/region chip code from a name prefix like "EN - Title",
/// "FR| Channel", "[US] Channel", "UK: News". Null when absent.
String? langCode(String name, [String? categoryName]) {
  String? pick(String? s) {
    if (s == null) return null;
    final m = RegExp(r'^\s*[\[\(]?([A-Za-z]{2,4})[\]\)]?\s*(?:[-|:]|\s\|)\s*')
        .firstMatch(s);
    if (m == null) return null;
    final code = m.group(1)!.toUpperCase();
    if (_notCodes.contains(code)) return null;
    return code;
  }

  return pick(name) ?? pick(categoryName);
}

const _notCodes = {'VIP', 'VOD', 'SRS', 'TV', 'THE', 'NEW', 'TOP', 'HD', 'FHD', 'UHD', 'SD', '4K', 'PPV', 'ALL', 'EPG', 'LIVE', 'MAX'};

/// Year in a title like "Movie (2019)" or "Movie - 2019".
int? yearOf(String name) {
  final m = RegExp(r'(?:\(|\s-\s|\s)((?:19|20)\d{2})\)?\s*$').firstMatch(name);
  return m == null ? null : int.tryParse(m.group(1)!);
}

String shortHash(String s) =>
    c.sha1.convert(utf8.encode(s)).toString().substring(0, 16);

const _fold = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'æ': 'ae',
  'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'í': 'i',
  'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o',
  'ö': 'o', 'ø': 'o', 'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y',
  'ÿ': 'y', 'ß': 'ss', 'œ': 'oe', 'ş': 's', 'ğ': 'g', 'ı': 'i', 'ł': 'l',
  'č': 'c', 'ć': 'c', 'š': 's', 'ž': 'z', 'đ': 'd', 'ř': 'r', 'ě': 'e',
};
