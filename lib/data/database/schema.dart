import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'schema.g.dart';

// ---------------------------------------------------------------------------
// Catalogue tables — rebuilt from the provider on refresh. Never synced.
// ---------------------------------------------------------------------------

/// Provider categories. `type` is live | movie | series.
@DataClassName('CategoryRow')
@TableIndex(name: 'idx_categories_src', columns: {#sourceId, #type})
class Categories extends Table {
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {sourceId, type, id};
}

/// Channels, movies and series from a provider.
@TableIndex(name: 'idx_items_cat', columns: {#sourceId, #type, #categoryId})
@TableIndex(name: 'idx_items_name', columns: {#sourceId, #type, #nameNorm})
@TableIndex(name: 'idx_items_epg', columns: {#sourceId, #epgId})
class Items extends Table {
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameNorm => text()();
  TextColumn get categoryId => text().withDefault(const Constant(''))();
  TextColumn get icon => text().nullable()();
  TextColumn get lang => text().nullable()();
  RealColumn get rating => real().nullable()(); // 0..10
  IntColumn get added => integer().withDefault(const Constant(0))(); // epoch s
  IntColumn get year => integer().nullable()();
  TextColumn get releaseDate => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  TextColumn get epgId => text().nullable()();
  IntColumn get tmdbId => integer().nullable()();
  IntColumn get archiveDays => integer().withDefault(const Constant(0))();
  TextColumn get ext => text().nullable()();
  TextColumn get url => text().nullable()(); // direct URL (M3U)
  TextColumn get plot => text().nullable()();
  TextColumn get extra => text().nullable()(); // JSON

  @override
  Set<Column> get primaryKey => {sourceId, type, id};
}

/// Cached series detail (seasons + episodes JSON).
class SeriesCache extends Table {
  TextColumn get sourceId => text()();
  TextColumn get seriesId => text()();
  IntColumn get fetchedAt => integer()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {sourceId, seriesId};
}

/// Generic cache: vod info, TheIntroDB answers, OpenSubtitles results.
class MetaCache extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

/// XMLTV channels (for name-based matching).
class EpgChannels extends Table {
  TextColumn get sourceId => text()();
  TextColumn get channelKey => text()();
  TextColumn get nameNorm => text()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId, channelKey, nameNorm};
}

@TableIndex(name: 'idx_epg_time', columns: {#sourceId, #channelKey, #stop})
class EpgProgrammes extends Table {
  TextColumn get sourceId => text()();
  TextColumn get channelKey => text()();
  IntColumn get start => integer()(); // epoch s
  IntColumn get stop => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId, channelKey, start};
}

/// Local refresh bookkeeping per source (not synced).
@DataClassName('SourceStatusRow')
class SourceStatus extends Table {
  TextColumn get sourceId => text()();
  IntColumn get lastRefresh => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get liveCount => integer().withDefault(const Constant(0))();
  IntColumn get movieCount => integer().withDefault(const Constant(0))();
  IntColumn get seriesCount => integer().withDefault(const Constant(0))();
  IntColumn get lastEpgRefresh => integer().withDefault(const Constant(0))();
  TextColumn get epgError => text().nullable()();
  IntColumn get epgProgrammes => integer().withDefault(const Constant(0))();
  TextColumn get accountJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {sourceId};
}

// ---------------------------------------------------------------------------
// User tables — synced between devices. Every row carries a Hybrid Logical
// Clock stamp (`hlc`) and a tombstone flag (`deleted`).
// ---------------------------------------------------------------------------

mixin Synced on Table {
  TextColumn get hlc => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

class Sources extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => text()(); // m3u | file | xtream | stalker
  TextColumn get url => text().nullable()(); // M3U URL
  TextColumn get filePath => text().nullable()(); // local file (device-specific)
  TextColumn get server => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get password => text().nullable()();
  TextColumn get mac => text().nullable()();
  TextColumn get epgUrl => text().nullable()(); // custom XMLTV URL
  BoolColumn get epgEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get epgRefreshHours => integer().withDefault(const Constant(24))();
  IntColumn get epgOffsetMin => integer().withDefault(const Constant(0))();
  IntColumn get refreshHours => integer().withDefault(const Constant(0))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Favorites extends Table with Synced {
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get itemId => text()();
  RealColumn get position => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {sourceId, type, itemId};
}

class UserGroups extends Table with Synced {
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  RealColumn get position => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class GroupItems extends Table with Synced {
  TextColumn get groupId => text()();
  TextColumn get itemId => text()();
  RealColumn get position => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {groupId, itemId};
}

/// Hidden items (kind=item) and hidden categories (kind=category).
@DataClassName('HiddenRow')
class Hidden extends Table with Synced {
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get kind => text()();
  TextColumn get refId => text()();

  @override
  Set<Column> get primaryKey => {sourceId, type, kind, refId};
}

/// User ordering of provider categories.
class CategoryOrder extends Table with Synced {
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get categoryId => text()();
  RealColumn get position => real()();

  @override
  Set<Column> get primaryKey => {sourceId, type, categoryId};
}

/// Watch history + resume position. type = live | movie | episode.
@DataClassName('WatchRow')
@TableIndex(name: 'idx_watch_recent', columns: {#sourceId, #type, #watchedAt})
class WatchState extends Table with Synced {
  TextColumn get sourceId => text()();
  TextColumn get type => text()();
  TextColumn get itemId => text()();
  TextColumn get seriesId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get season => integer().nullable()();
  IntColumn get episode => integer().nullable()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get watchedAt => integer()(); // epoch ms
  BoolColumn get finished => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sourceId, type, itemId};
}

/// Synced key/value preferences (theme, player options, customisation).
class Prefs extends Table with Synced {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Categories,
  Items,
  SeriesCache,
  MetaCache,
  EpgChannels,
  EpgProgrammes,
  SourceStatus,
  Sources,
  Favorites,
  UserGroups,
  GroupItems,
  Hidden,
  CategoryOrder,
  WatchState,
  Prefs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.file(File file) => AppDatabase(
        NativeDatabase.createInBackground(file, setup: (db) {
          db.execute('PRAGMA journal_mode=WAL;');
          db.execute('PRAGMA synchronous=NORMAL;');
        }),
      );

  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );
}
