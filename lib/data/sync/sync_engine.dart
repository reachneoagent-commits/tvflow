import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/hlc.dart';
import '../database/schema.dart';
import 'sync_crypto.dart';

/// Synced tables and their primary keys.
const syncTables = <String, List<String>>{
  'sources': ['id'],
  'favorites': ['source_id', 'type', 'item_id'],
  'user_groups': ['id'],
  'group_items': ['group_id', 'item_id'],
  'hidden': ['source_id', 'type', 'kind', 'ref_id'],
  'category_order': ['source_id', 'type', 'category_id'],
  'watch_state': ['source_id', 'type', 'item_id'],
  'prefs': ['key'],
};

/// Source fields holding credentials. They only leave the device when the
/// snapshot is encrypted.
const _secretSourceFields = ['username', 'password', 'mac', 'url', 'server'];

/// Keys that mark a URL as carrying credentials.
final _credentialQuery = RegExp(r'^(user(name)?|pass(word)?|token|auth|key|mac|sn)$', caseSensitive: false);

/// A URL is safe to sync unencrypted when it has no user-info and no
/// credential-like query parameters.
bool urlCarriesCredentials(String? url) {
  if (url == null || url.isEmpty) return false;
  final u = Uri.tryParse(url);
  if (u == null) return true;
  if (u.userInfo.isNotEmpty) return true;
  if (u.queryParameters.keys.any(_credentialQuery.hasMatch)) return true;
  // Xtream-style paths: /live/<user>/<pass>/..., /get.php is handled above.
  return false;
}

/// Unencrypted snapshots keep everything except secrets.
Map<String, dynamic> redactSource(Map<String, dynamic> row) => {
      ...row,
      'username': null,
      'password': null,
      'mac': null,
      if (urlCarriesCredentials(row['url'] as String?)) 'url': null,
      if (urlCarriesCredentials(row['server'] as String?)) 'server': null,
      '_redacted': true,
    };

class PeerInfo {
  PeerInfo(this.deviceId, this.deviceName, this.written, {this.error});
  final String deviceId;
  final String deviceName;
  final DateTime? written;
  final String? error;
}

class SyncReport {
  SyncReport({
    required this.applied,
    required this.exported,
    required this.peers,
    required this.at,
  });
  final int applied;
  final int exported;
  final List<PeerInfo> peers;
  final DateTime at;
  List<PeerInfo> get failedPeers => peers.where((p) => p.error != null).toList();
}

class SyncException implements Exception {
  SyncException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Folder-based sync.
///
/// Each device writes `<folder>/<deviceId>.iptvsync` — a snapshot of every
/// synced row including tombstones — and merges every other device's file
/// row by row, keeping the version with the highest HLC stamp. Merging is
/// commutative and idempotent, so devices can sync in any order, offline
/// edits merge cleanly, and a failed or partial run is simply retried.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.hlc,
    required this.deviceId,
    required this.deviceName,
  });

  final AppDatabase db;
  final Hlc hlc;
  final String deviceId;
  final String deviceName;

  static const fileExt = '.iptvsync';
  static const tombstoneTtl = Duration(days: 180);

  SyncCrypto? _crypto;
  String? _cryptoPass;

  SyncCrypto? _cryptoFor(String? passphrase) {
    if (passphrase == null || passphrase.isEmpty) return null;
    if (_cryptoPass != passphrase) {
      _crypto = SyncCrypto(passphrase);
      _cryptoPass = passphrase;
    }
    return _crypto;
  }

  Future<SyncReport> run({required String folder, String? passphrase}) async {
    final dir = Directory(folder);
    if (!await dir.exists()) {
      throw SyncException(
          'Sync folder not found: $folder. Is the drive (Synology/iCloud/Dropbox) available?');
    }
    final crypto = _cryptoFor(passphrase);
    final peers = <PeerInfo>[];
    var applied = 0;

    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith(fileExt))
        .cast<File>()
        .toList();
    for (final f in files) {
      final name = p.basenameWithoutExtension(f.path);
      if (name == deviceId) continue;
      try {
        final snap = await _read(f, crypto);
        applied += await _merge(snap);
        peers.add(PeerInfo(
          snap['device'] as String? ?? name,
          snap['deviceName'] as String? ?? 'Unknown device',
          DateTime.fromMillisecondsSinceEpoch((snap['written'] as num?)?.toInt() ?? 0),
        ));
      } catch (e) {
        peers.add(PeerInfo(name, 'Unknown device', null, error: e.toString()));
      }
    }

    await _purgeOldTombstones();
    final exported = await _write(dir, crypto);
    return SyncReport(applied: applied, exported: exported, peers: peers, at: DateTime.now());
  }

  Future<Map<String, dynamic>> _read(File f, SyncCrypto? crypto) async {
    final text = await f.readAsString();
    final Map<String, dynamic> outer;
    try {
      outer = (jsonDecode(text) as Map).cast<String, dynamic>();
    } on FormatException {
      throw SyncException('Unreadable sync file ${p.basename(f.path)} (still uploading?).');
    }
    if (outer['format'] == 'iptv-one-sync-enc') {
      if (crypto == null) {
        throw SyncException('This device\'s data is encrypted. Enter the sync passphrase.');
      }
      final plain = await crypto.decrypt(outer);
      return (jsonDecode(utf8.decode(plain)) as Map).cast<String, dynamic>();
    }
    if (outer['format'] != 'iptv-one-sync') {
      throw SyncException('Not a sync file: ${p.basename(f.path)}');
    }
    return outer;
  }

  Future<Map<String, Set<String>>> _columns() async {
    final out = <String, Set<String>>{};
    for (final t in syncTables.keys) {
      final rows = await db.customSelect('PRAGMA table_info($t)').get();
      out[t] = rows.map((r) => r.read<String>('name')).toSet();
    }
    return out;
  }

  String _pkOf(String table, Map<String, dynamic> row) =>
      syncTables[table]!.map((k) => '${row[k]}').join('\u0000');

  /// Applies newer remote rows. Returns how many rows changed.
  Future<int> _merge(Map<String, dynamic> snap) async {
    final tables = (snap['tables'] as Map?)?.cast<String, dynamic>() ?? const {};
    final cols = await _columns();
    var changed = 0;
    await db.transaction(() async {
      for (final entry in tables.entries) {
        final table = entry.key;
        if (!syncTables.containsKey(table)) continue;
        final known = cols[table]!;
        final local = <String, Map<String, dynamic>>{};
        for (final r in await db.customSelect('SELECT * FROM $table').get()) {
          local[_pkOf(table, r.data)] = r.data;
        }
        for (final raw in (entry.value as List)) {
          final remote = (raw as Map).cast<String, dynamic>();
          final rHlc = remote['hlc'] as String?;
          if (rHlc == null) continue;
          hlc.observe(rHlc);
          final pk = _pkOf(table, remote);
          final mine = local[pk];
          if (mine != null && (mine['hlc'] as String).compareTo(rHlc) >= 0) continue;
          final row = <String, dynamic>{
            for (final e in remote.entries)
              if (known.contains(e.key)) e.key: e.value,
          };
          if (table == 'sources' && remote['_redacted'] == true) {
            for (final f in _secretSourceFields) {
              if (row[f] == null) row[f] = mine?[f];
            }
          }
          if (table == 'sources' && mine != null) {
            row['file_path'] = mine['file_path']; // device-specific
          }
          final keys = row.keys.toList();
          await db.customStatement(
            'INSERT OR REPLACE INTO $table (${keys.join(',')}) '
            'VALUES (${List.filled(keys.length, '?').join(',')})',
            [for (final k in keys) _sqlValue(row[k])],
          );
          changed++;
        }
      }
    });
    return changed;
  }

  static Object? _sqlValue(Object? v) => v is bool ? (v ? 1 : 0) : v;

  Future<int> _write(Directory dir, SyncCrypto? crypto) async {
    final tables = <String, List<Map<String, dynamic>>>{};
    var count = 0;
    for (final t in syncTables.keys) {
      final rows = await db.customSelect('SELECT * FROM $t').get();
      tables[t] = [
        for (final r in rows)
          {
            ...(t == 'sources' && crypto == null ? redactSource(r.data) : r.data),
            if (t == 'sources') 'file_path': null,
          }
      ];
      count += rows.length;
    }
    final snap = {
      'format': 'iptv-one-sync',
      'version': 1,
      'device': deviceId,
      'deviceName': deviceName,
      'written': DateTime.now().millisecondsSinceEpoch,
      'tables': tables,
    };
    final plain = utf8.encode(jsonEncode(snap));
    final body = crypto == null ? plain : utf8.encode(jsonEncode(await crypto.encrypt(plain)));
    final target = File(p.join(dir.path, '$deviceId$fileExt'));
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(body, flush: true);
    await tmp.rename(target.path);
    return count;
  }

  Future<void> _purgeOldTombstones() async {
    final cutoff = DateTime.now().subtract(tombstoneTtl).millisecondsSinceEpoch;
    final stamp = Hlc.format(cutoff, 0, '');
    for (final t in syncTables.keys) {
      await db.customStatement('DELETE FROM $t WHERE deleted = 1 AND hlc < ?', [stamp]);
    }
  }
}
