import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/hlc.dart';
import '../core/net.dart';
import '../core/paths.dart';
import '../data/catalog_service.dart';
import '../data/database/schema.dart';
import '../data/repository.dart';
import '../data/services/metadata.dart';
import '../data/services/secrets.dart';
import '../data/sources/models.dart';
import '../data/sync/sync_engine.dart';

enum MainTab { live, series, movies, search, menu, home, favorites, history }

extension MainTabX on MainTab {
  String get label => switch (this) {
        MainTab.live => 'Live TV',
        MainTab.series => 'Series',
        MainTab.movies => 'Movies',
        MainTab.search => 'Search',
        MainTab.menu => 'Settings',
        MainTab.home => 'Home',
        MainTab.favorites => 'Favourites',
        MainTab.history => 'History',
      };
  ContentType? get contentType => switch (this) {
        MainTab.live => ContentType.live,
        MainTab.series => ContentType.series,
        MainTab.movies => ContentType.movie,
        _ => null,
      };
}

/// Pref keys (synced between devices).
abstract class P {
  static const theme = 'theme'; // light | dark | system
  static const tvMargin = 'tv.margin'; // percent of the screen kept clear on each edge (TV)
  static const startTab = 'start_tab';
  static const subLang = 'sub_lang'; // '' = disabled
  static const audioLang = 'audio_lang';
  static String favFirst(ContentType t) => '${t.key}.fav_first';
  static String defaultCat(ContentType t) => '${t.key}.default_cat';
  static String defaultSort(ContentType t) => '${t.key}.default_sort'; // 'remember' | sort key
  static String lastSort(ContentType t) => '${t.key}.last_sort';
  static String recents(ContentType t) => '${t.key}.recents';
  static const liveEpgGrid = 'live.epg_grid';
  static const autoplayNext = 'series.autoplay_next';
  static const seriesSkipIntro = 'series.skip_intro';
  static const seriesSkipCredits = 'series.skip_credits';
  static const movieSkipIntro = 'movie.skip_intro';
  static const controlsOnMove = 'player.controls_on_move';
  static const rememberVolume = 'player.remember_volume';
  static const volume = 'player.volume';
  static const fullscreenOnOpen = 'player.fullscreen_on_open';
  static const userAgent = 'player.user_agent';
  static const skipSeconds = 'player.skip_seconds';
  static const subSize = 'sub.size';
  static const subColor = 'sub.color';
  static const subBg = 'sub.bg';
}

/// Device-only settings (never synced): identity, sync folder, active source.
class DeviceConfig {
  DeviceConfig(this.file, this.data);
  final File file;
  final Map<String, dynamic> data;

  static Future<DeviceConfig> load(File f) async {
    Map<String, dynamic> d = {};
    try {
      if (await f.exists()) d = (jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>();
    } catch (_) {}
    final cfg = DeviceConfig(f, d);
    if (cfg.data['deviceId'] == null) {
      cfg.data['deviceId'] = const Uuid().v4().replaceAll('-', '').substring(0, 12);
      cfg.data['deviceName'] = Platform.localHostname.replaceAll('.local', '');
      await cfg.save();
    }
    return cfg;
  }

  String get deviceId => data['deviceId'] as String;
  String get deviceName => (data['deviceName'] as String?) ?? 'Mac';
  String? get activeSource => data['activeSource'] as String?;
  String? get syncFolder => data['syncFolder'] as String?;
  bool get syncEnabled => data['syncEnabled'] == true;
  int get syncIntervalMin => (data['syncIntervalMin'] as num?)?.toInt() ?? 5;
  int? get lastSync => (data['lastSync'] as num?)?.toInt();
  String? get lastSyncError => data['lastSyncError'] as String?;

  Future<void> set(String k, Object? v) async {
    if (v == null) {
      data.remove(k);
    } else {
      data[k] = v;
    }
    await save();
  }

  Future<void> save() => file.writeAsString(jsonEncode(data), flush: true);
}

class SyncState {
  SyncState({this.running = false, this.lastReport, this.error});
  final bool running;
  final SyncReport? lastReport;
  final String? error;
}

/// App-wide state shared through [AppScope].
class AppState extends ChangeNotifier {
  AppState._(this.paths, this.db, this.repo, this.catalog, this.secrets, this.device,
      this.ids, this.introDb, this.subtitles);

  final AppPaths paths;
  final AppDatabase db;
  final Repository repo;
  final CatalogService catalog;
  final SecretsStore secrets;
  final DeviceConfig device;
  final IdResolver ids;
  final IntroDbClient introDb;
  final OpenSubtitlesClient subtitles;
  late final SyncEngine syncEngine;

  Map<String, String> _prefs = {};
  List<Source> sources = [];
  Source? activeSource;
  MainTab tab = MainTab.live;

  /// Bumped whenever user data or catalogue changes so screens re-query.
  final revision = ValueNotifier<int>(0);
  final sync = ValueNotifier<SyncState>(SyncState());

  final _subs = <StreamSubscription>[];
  Timer? _syncDebounce;
  Timer? _syncTimer;

  static Future<AppState> load() async {
    final paths = await AppPaths.resolve();
    final device = await DeviceConfig.load(paths.device);
    final db = AppDatabase.file(paths.database);
    final hlc = Hlc(device.deviceId);
    final repo = Repository(db, hlc);
    final secrets = SecretsStore(paths.secrets);
    await secrets.load();
    late AppState s;
    final catalog = CatalogService(repo, userAgent: () => s.userAgent);
    s = AppState._(
      paths,
      db,
      repo,
      catalog,
      secrets,
      device,
      IdResolver(repo, secrets),
      IntroDbClient(repo),
      OpenSubtitlesClient(secrets, paths.subtitles),
    );
    s.syncEngine = SyncEngine(
        db: db, hlc: hlc, deviceId: device.deviceId, deviceName: device.deviceName);
    await s._reload();
    s.tab = s.sources.isEmpty
        ? MainTab.home
        : MainTab.values.firstWhere((t) => t.name == s.str(P.startTab, 'live'),
            orElse: () => MainTab.live);
    s._subs.add(repo.userChanges.stream.listen(s._onUserChange));
    s._subs.add(repo.catalogChanges.stream.listen((_) => s.revision.value++));
    catalog.startScheduler();
    s._startSyncTimer();
    if (device.syncEnabled) unawaited(s.syncNow());
    return s;
  }

  Future<void> _reload() async {
    _prefs = await repo.allPrefs();
    sources = await repo.sources();
    final wanted = device.activeSource;
    activeSource = sources.where((x) => x.id == wanted).firstOrNull ?? sources.firstOrNull;
  }

  Future<void> _onUserChange(String what) async {
    await _reload();
    revision.value++;
    notifyListeners();
    if (what != 'sync:remote' && device.syncEnabled) {
      _syncDebounce?.cancel();
      _syncDebounce = Timer(const Duration(seconds: 8), syncNow);
    }
  }

  // ---- prefs ---------------------------------------------------------------

  String str(String key, [String def = '']) => _prefs[key] ?? def;
  bool flag(String key, [bool def = false]) {
    final v = _prefs[key];
    return v == null ? def : v == 'true';
  }

  int integer(String key, int def) => int.tryParse(_prefs[key] ?? '') ?? def;
  double dbl(String key, double def) => double.tryParse(_prefs[key] ?? '') ?? def;

  Future<void> setPref(String key, Object value) async {
    _prefs[key] = '$value';
    notifyListeners();
    await repo.setPref(key, '$value');
  }

  ThemeMode get themeMode => switch (str(P.theme, 'light')) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

  String get userAgent {
    final ua = str(P.userAgent);
    return ua.isEmpty ? kDefaultUserAgent : ua;
  }

  SortMode sortFor(ContentType t) {
    final def = str(P.defaultSort(t), 'remember');
    if (def != 'remember') return SortMode.of(def);
    return SortMode.of(str(P.lastSort(t), 'default'));
  }

  // ---- navigation & sources --------------------------------------------------

  void go(MainTab t) {
    tab = t;
    notifyListeners();
  }

  Future<void> selectSource(String id) async {
    activeSource = sources.firstWhere((s) => s.id == id);
    await device.set('activeSource', id);
    revision.value++;
    notifyListeners();
  }

  Future<void> sourceSaved(Source s, {bool refresh = true}) async {
    await _reload();
    if (activeSource == null || sources.length == 1) {
      await selectSource(s.id);
    }
    notifyListeners();
    if (refresh) unawaited(catalog.refresh(s));
  }

  Future<void> deleteSource(String id) async {
    await repo.deleteSource(id);
    if (device.activeSource == id) await device.set('activeSource', null);
    await _reload();
    if (sources.isEmpty) tab = MainTab.home;
    revision.value++;
    notifyListeners();
  }

  // ---- sync -------------------------------------------------------------------

  void _startSyncTimer() {
    _syncTimer?.cancel();
    if (!device.syncEnabled) return;
    _syncTimer = Timer.periodic(Duration(minutes: device.syncIntervalMin.clamp(1, 1440)), (_) => syncNow());
  }

  Future<void> configureSync({
    String? folder,
    bool? enabled,
    int? intervalMin,
    String? passphrase,
    bool clearPassphrase = false,
    String? deviceName,
  }) async {
    if (folder != null) await device.set('syncFolder', folder);
    if (enabled != null) await device.set('syncEnabled', enabled);
    if (intervalMin != null) await device.set('syncIntervalMin', intervalMin);
    if (deviceName != null && deviceName.trim().isNotEmpty) {
      await device.set('deviceName', deviceName.trim());
    }
    if (passphrase != null || clearPassphrase) {
      await secrets.set(SecretsStore.syncPassphrase, clearPassphrase ? null : passphrase);
    }
    syncEngine = SyncEngine(
        db: db, hlc: repo.hlc, deviceId: device.deviceId, deviceName: device.deviceName);
    _startSyncTimer();
    notifyListeners();
  }

  /// Runs one sync. Errors are kept in [sync] and in the device config.
  Future<void> syncNow() async {
    final folder = device.syncFolder;
    if (sync.value.running || folder == null || folder.isEmpty) return;
    sync.value = SyncState(running: true, lastReport: sync.value.lastReport);
    try {
      final report = await syncEngine.run(
          folder: folder, passphrase: secrets.get(SecretsStore.syncPassphrase));
      await device.set('lastSync', report.at.millisecondsSinceEpoch);
      final peerErr = report.failedPeers.isEmpty
          ? null
          : report.failedPeers.map((p) => '${p.deviceName} (${p.deviceId}): ${p.error}').join('\n');
      await device.set('lastSyncError', peerErr);
      sync.value = SyncState(lastReport: report, error: peerErr);
      if (report.applied > 0) {
        repo.userChanges.add('sync:remote');
      }
    } catch (e) {
      await device.set('lastSyncError', e.toString());
      sync.value = SyncState(lastReport: sync.value.lastReport, error: e.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _syncTimer?.cancel();
    _syncDebounce?.cancel();
    catalog.dispose();
    db.close();
    super.dispose();
  }
}

/// Gives every widget access to [AppState].
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
