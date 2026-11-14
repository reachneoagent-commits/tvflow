import 'dart:convert';
import 'dart:io';

/// Device-local secrets (API keys, passwords, sync passphrase).
///
/// Stored as JSON in the app's Application Support folder with 0600
/// permissions — never in the project folder, never synced. Environment
/// variables override stored values (handy for development):
///   OPENSUBTITLES_API_KEY, OPENSUBTITLES_USERNAME, OPENSUBTITLES_PASSWORD,
///   TMDB_API_KEY
class SecretsStore {
  SecretsStore(this.file);
  final File file;
  Map<String, String> _data = {};

  static const osApiKey = 'opensubtitles_api_key';
  static const osUsername = 'opensubtitles_username';
  static const osPassword = 'opensubtitles_password';
  static const tmdbKey = 'tmdb_api_key';
  static const syncPassphrase = 'sync_passphrase';

  static const _env = {
    osApiKey: 'OPENSUBTITLES_API_KEY',
    osUsername: 'OPENSUBTITLES_USERNAME',
    osPassword: 'OPENSUBTITLES_PASSWORD',
    tmdbKey: 'TMDB_API_KEY',
  };

  Future<void> load() async {
    try {
      if (await file.exists()) {
        _data = (jsonDecode(await file.readAsString()) as Map).cast<String, String>();
      }
    } catch (_) {
      _data = {};
    }
  }

  String? get(String key) {
    final env = _env[key];
    final fromEnv = env == null ? null : Platform.environment[env];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    final v = _data[key];
    return v == null || v.isEmpty ? null : v;
  }

  bool fromEnvironment(String key) {
    final env = _env[key];
    return env != null && (Platform.environment[env]?.isNotEmpty ?? false);
  }

  Future<void> set(String key, String? value) async {
    if (value == null || value.isEmpty) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
    await file.writeAsString(jsonEncode(_data), flush: true);
    if (!Platform.isWindows) {
      try {
        await Process.run('chmod', ['600', file.path]);
      } catch (_) {}
    }
  }
}
