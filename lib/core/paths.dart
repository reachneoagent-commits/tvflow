import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the app keeps its database, caches and secrets.
///
/// Default: ~/Library/Application Support/com.tvflow.app
/// Override with the TVFLOW_DATA_DIR environment variable (used for running two
/// instances side by side when testing sync).
class AppPaths {
  AppPaths._(this.root);
  final Directory root;

  static Future<AppPaths> resolve() async {
    final override = Platform.environment['TVFLOW_DATA_DIR'];
    final dir = override != null && override.isNotEmpty
        ? Directory(override)
        : await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final paths = AppPaths._(dir);
    await paths.subtitles.create(recursive: true);
    return paths;
  }

  File get database => File(p.join(root.path, 'tvflow.sqlite'));
  File get secrets => File(p.join(root.path, 'secrets.json'));
  File get device => File(p.join(root.path, 'device.json'));
  Directory get subtitles => Directory(p.join(root.path, 'subtitles'));
}
