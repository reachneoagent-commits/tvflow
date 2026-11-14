import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Where releases are published. The app only reads the public "latest release" and never sends anything.
const _repo = 'reachneoagent-commits/tvflow';
const releasesPage = 'https://github.com/$_repo/releases/latest';

class UpdateInfo {
  UpdateInfo({required this.current, required this.latest, required this.newer});
  final String current;
  final String latest;
  final bool newer;
}

/// Checks GitHub for a newer TVflow. Returns null when offline or when there is no release yet.
class UpdateChecker {
  static String? _version;

  static Future<String> currentVersion() async =>
      _version ??= (await PackageInfo.fromPlatform()).version;

  static Future<UpdateInfo?> check() async {
    try {
      final cur = await currentVersion();
      final r = await http
          .get(Uri.https('api.github.com', '/repos/$_repo/releases/latest'), headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      final tag = (jsonDecode(r.body) as Map)['tag_name'] as String? ?? '';
      final latest = tag.replaceFirst(RegExp(r'^[vV]'), '');
      if (latest.isEmpty) return null;
      return UpdateInfo(current: cur, latest: latest, newer: _isNewer(latest, cur));
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  static bool _isNewer(String a, String b) {
    List<int> parts(String v) => v.split('+').first.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    final x = parts(a), y = parts(b);
    for (var i = 0; i < 3; i++) {
      final p = i < x.length ? x[i] : 0, q = i < y.length ? y[i] : 0;
      if (p != q) return p > q;
    }
    return false;
  }
}
