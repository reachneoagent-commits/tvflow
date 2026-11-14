import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/hlc.dart';
import '../core/text.dart';
import 'database/schema.dart';
import 'sources/models.dart';

/// Sort modes offered in the browse toolbar (mirrors the reference app).
enum SortMode {
  defaultOrder('default', 'Default'),
  az('az', 'A-Z'),
  za('za', 'Z-A'),
  addedNewest('added_newest', 'Recently added (newest first)'),
  addedOldest('added_oldest', 'Recently added (oldest first)'),
  releaseNewest('release_newest', 'Release date (newest first)'),
  releaseOldest('release_oldest', 'Release date (oldest first)'),
  ratingHighest('rating_highest', 'Rating (highest first)'),
  ratingLowest('rating_lowest', 'Rating (lowest first)');

  const SortMode(this.key, this.label);
  final String key;
  final String label;

  static SortMode of(String? k) =>
      values.firstWhere((e) => e.key == k, orElse: () => defaultOrder);

  String get short => switch (this) {
        az => 'AZ',
        za => 'ZA',
        defaultOrder => '',
        _ => '',
      };
}

/// A catalogue entry as shown in the UI.
class ItemView {
  ItemView({
    required this.sourceId,
    required this.type,
    required this.id,
    required this.name,
    required this.categoryId,
    this.icon,
    this.lang,
    this.rating,
    this.year,
    this.added = 0,
    this.epgId,
    this.tmdbId,
    this.archiveDays = 0,
    this.ext,
    this.url,
    this.plot,
    this.extra,
    this.releaseDate,
    this.isFavorite = false,
  });

  final String sourceId;
  final ContentType type;
  final String id;
  final String name;
  final String categoryId;
  final String? icon;
  final String? lang;
  final double? rating;
  final int? year;
  final int added;
  final String? epgId;
  final int? tmdbId;
  final int archiveDays;
  final String? ext;
  final String? url;
  final String? plot;
  final Map<String, dynamic>? extra;
  final String? releaseDate;
  bool isFavorite;

  String get key => '${type.key}:$id';

  /// 0..5 stars
  double? get stars => rating == null ? null : (rating! / 2).clamp(0, 5);

  static ItemView fromRow(QueryRow r) {
    final extra = r.readNullable<String>('extra');
    return ItemView(
      sourceId: r.read<String>('source_id'),
      type: ContentType.of(r.read<String>('type')),
      id: r.read<String>('id'),
      name: r.read<String>('name'),
      categoryId: r.read<String>('category_id'),
      icon: r.readNullable<String>('icon'),
      lang: r.readNullable<String>('lang'),
      rating: r.readNullable<double>('rating'),
      year: r.readNullable<int>('year'),
      added: r.read<int>('added'),
      epgId: r.readNullable<String>('epg_id'),
      tmdbId: r.readNullable<int>('tmdb_id'),
      archiveDays: r.read<int>('archive_days'),
      ext: r.readNullable<String>('ext'),
      url: r.readNullable<String>('url'),
      plot: r.readNullable<String>('plot'),
      releaseDate: r.readNullable<String>('release_date'),
      extra: extra == null || extra.isEmpty
          ? null
          : (jsonDecode(extra) as Map).cast<String, dynamic>(),
      isFavorite: (r.data['is_fav'] as int? ?? 0) == 1,
    );
  }
}

/// A category entry for the sidebar.
class CategoryView {
  CategoryView({
    required this.id,
    required this.name,
    this.isGroup = false,
    this.hidden = false,
    this.count,
  });
  final String id; // provider category id, or "group:<uuid>"
  final String name;
  final bool isGroup;
  final bool hidden;
  final int? count;
}

/// What to show in a browse grid.
class BrowseQuery {
  const BrowseQuery({
    required this.sourceId,
    required this.type,
    this.categoryId,
    this.search = '',
    this.lang,
    this.favoritesOnly = false,
    this.favoritesFirst = false,
    this.archiveOnly = false,
    this.sort = SortMode.defaultOrder,
  });

  final String sourceId;
  final ContentType type;

  /// null = All, `group:<id>` = custom group.
  final String? categoryId;
  final String search;
  final String? lang;
  final bool favoritesOnly;
  final bool favoritesFirst;
  final bool archiveOnly;
  final SortMode sort;

  BrowseQuery copyWith({
    Object? categoryId = _keep,
    String? search,
    Object? lang = _keep,
    bool? favoritesOnly,
    bool? favoritesFirst,
    bool? archiveOnly,
    SortMode? sort,
  }) =>
      BrowseQuery(
        sourceId: sourceId,
        type: type,
        categoryId:
            identical(categoryId, _keep) ? this.categoryId : categoryId as String?,
        search: search ?? this.search,
        lang: identical(lang, _keep) ? this.lang : lang as String?,
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
        favoritesFirst: favoritesFirst ?? this.favoritesFirst,
        archiveOnly: archiveOnly ?? this.archiveOnly,
        sort: sort ?? this.sort,
      );
}

const _keep = Object();

/// Data access for the whole app. All user-data writes are stamped with the
/// HLC so they can be synchronised.
class Repository {
  Repository(this.db, this.hlc);

  final AppDatabase db;
  final Hlc hlc;
  final _uuid = const Uuid();

  /// Fires after any user-data change (favourites, groups, history, prefs…).
  final userChanges = StreamController<String>.broadcast();

  /// Fires after catalogue/EPG changes for a source id.
  final catalogChanges = StreamController<String>.broadcast();

  String stamp() => hlc.tick();
  void _changed(String what) => userChanges.add(what);

  // ---------------------------------------------------------------------------
  // Sources
  // ---------------------------------------------------------------------------

  Future<List<Source>> sources() => (db.select(db.sources)
        ..where((s) => s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm(expression: s.position), (s) => OrderingTerm(expression: s.createdAt)]))
      .get();

  Future<Source?> source(String id) => (db.select(db.sources)
        ..where((s) => s.id.equals(id) & s.deleted.equals(false)))
      .getSingleOrNull();

  Future<Source> saveSource({
    String? id,
    required String name,
    required SourceKind kind,
    String? url,
    String? filePath,
    String? server,
    String? username,
    String? password,
    String? mac,
  }) async {
    final existing = id == null ? null : await source(id);
    final row = SourcesCompanion(
      id: Value(id ?? _uuid.v4()),
      name: Value(name.trim()),
      kind: Value(kind.key),
      url: Value(url?.trim()),
      filePath: Value(filePath),
      server: Value(server?.trim()),
      username: Value(username?.trim()),
      password: Value(password),
      mac: Value(mac?.trim().toUpperCase()),
      createdAt: Value(existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch),
      position: Value(existing?.position ?? (await sources()).length),
      epgUrl: Value(existing?.epgUrl),
      epgEnabled: Value(existing?.epgEnabled ?? true),
      epgRefreshHours: Value(existing?.epgRefreshHours ?? 24),
      epgOffsetMin: Value(existing?.epgOffsetMin ?? 0),
      refreshHours: Value(existing?.refreshHours ?? 0),
      hlc: Value(stamp()),
      deleted: const Value(false),
    );
    await db.into(db.sources).insertOnConflictUpdate(row);
    _changed('sources');
    return (await source(row.id.value))!;
  }

  Future<void> updateSourceSettings(String id,
      {int? refreshHours,
      String? epgUrl,
      bool clearEpgUrl = false,
      bool? epgEnabled,
      int? epgRefreshHours,
      int? epgOffsetMin}) async {
    await (db.update(db.sources)..where((s) => s.id.equals(id))).write(
      SourcesCompanion(
        refreshHours: Value.absentIfNull(refreshHours),
        epgUrl: clearEpgUrl ? const Value(null) : Value.absentIfNull(epgUrl),
        epgEnabled: Value.absentIfNull(epgEnabled),
        epgRefreshHours: Value.absentIfNull(epgRefreshHours),
        epgOffsetMin: Value.absentIfNull(epgOffsetMin),
        hlc: Value(stamp()),
      ),
    );
    _changed('sources');
  }

  /// Tombstones the source and drops its local catalogue.
  Future<void> deleteSource(String id) async {
    await db.transaction(() async {
      await (db.update(db.sources)..where((s) => s.id.equals(id))).write(
          SourcesCompanion(deleted: const Value(true), hlc: Value(stamp())));
      await purgeCatalog(id);
    });
    _changed('sources');
  }

  Future<void> purgeCatalog(String id) async {
    await (db.delete(db.items)..where((t) => t.sourceId.equals(id))).go();
    await (db.delete(db.categories)..where((t) => t.sourceId.equals(id))).go();
    await (db.delete(db.seriesCache)..where((t) => t.sourceId.equals(id))).go();
    await (db.delete(db.epgProgrammes)..where((t) => t.sourceId.equals(id))).go();
    await (db.delete(db.sourceStatus)..where((t) => t.sourceId.equals(id))).go();
  }

  Future<SourceStatusRow?> status(String sourceId) =>
      (db.select(db.sourceStatus)..where((s) => s.sourceId.equals(sourceId)))
          .getSingleOrNull();

  Future<void> writeStatus(SourceStatusCompanion c) =>
      db.into(db.sourceStatus).insertOnConflictUpdate(c);

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Replaces one content type of a source's catalogue.
  Future<void> replaceCatalog(String sourceId, ImportBatch batch) async {
    final catNames = {for (final c in batch.categories) c.id: c.name};
    await db.transaction(() async {
      await (db.delete(db.items)
            ..where((t) => t.sourceId.equals(sourceId) & t.type.equals(batch.type.key)))
          .go();
      await (db.delete(db.categories)
            ..where((t) => t.sourceId.equals(sourceId) & t.type.equals(batch.type.key)))
          .go();
      await db.batch((b) {
        var i = 0;
        b.insertAll(
          db.categories,
          [
            for (final c in batch.categories)
              CategoriesCompanion.insert(
                sourceId: sourceId,
                type: batch.type.key,
                id: c.id,
                name: c.name,
                position: Value(i++),
              )
          ],
          mode: InsertMode.insertOrReplace,
        );
      });
      const chunk = 5000;
      for (var start = 0; start < batch.items.length; start += chunk) {
        final slice = batch.items.skip(start).take(chunk);
        var pos = start;
        await db.batch((b) {
          b.insertAll(
            db.items,
            [
              for (final it in slice)
                ItemsCompanion.insert(
                  sourceId: sourceId,
                  type: it.type.key,
                  id: it.id,
                  name: it.name,
                  nameNorm: normalize(it.name),
                  categoryId: Value(it.categoryId),
                  icon: Value(it.icon),
                  lang: Value(langCode(it.name, catNames[it.categoryId])),
                  rating: Value(it.rating),
                  added: Value(it.added),
                  year: Value(it.year),
                  releaseDate: Value(it.releaseDate),
                  position: Value(pos++),
                  epgId: Value(it.epgId),
                  tmdbId: Value(it.tmdbId),
                  archiveDays: Value(it.archiveDays),
                  ext: Value(it.ext),
                  url: Value(it.url),
                  plot: Value(it.plot),
                  extra: Value(it.extra == null || it.extra!.isEmpty
                      ? null
                      : jsonEncode(it.extra)),
                )
            ],
            mode: InsertMode.insertOrReplace,
          );
        });
      }
    });
    catalogChanges.add(sourceId);
  }

  Future<void> putSeriesDetail(
      String sourceId, String seriesId, SeriesDetail d) async {
    await db.into(db.seriesCache).insertOnConflictUpdate(SeriesCacheCompanion.insert(
          sourceId: sourceId,
          seriesId: seriesId,
          fetchedAt: DateTime.now().millisecondsSinceEpoch,
          json: jsonEncode(d.toJson()),
        ));
  }

  Future<(SeriesDetail, int)?> seriesDetail(String sourceId, String seriesId) async {
    final r = await (db.select(db.seriesCache)
          ..where((t) => t.sourceId.equals(sourceId) & t.seriesId.equals(seriesId)))
        .getSingleOrNull();
    if (r == null) return null;
    return (
      SeriesDetail.fromJson((jsonDecode(r.json) as Map).cast<String, dynamic>()),
      r.fetchedAt
    );
  }

  Future<void> clearSeriesCache(String sourceId) =>
      (db.delete(db.seriesCache)..where((t) => t.sourceId.equals(sourceId))).go();

  // ---------------------------------------------------------------------------
  // Meta cache
  // ---------------------------------------------------------------------------

  Future<String?> cacheGet(String key, {Duration? maxAge}) async {
    final r = await (db.select(db.metaCache)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (r == null) return null;
    if (maxAge != null &&
        DateTime.now().millisecondsSinceEpoch - r.fetchedAt > maxAge.inMilliseconds) {
      return null;
    }
    return r.value;
  }

  Future<void> cachePut(String key, String value) =>
      db.into(db.metaCache).insertOnConflictUpdate(MetaCacheCompanion.insert(
          key: key, value: value, fetchedAt: DateTime.now().millisecondsSinceEpoch));

  // ---------------------------------------------------------------------------
  // Browse queries
  // ---------------------------------------------------------------------------

  static const _itemCols =
      'i.source_id, i.type, i.id, i.name, i.category_id, i.icon, i.lang, i.rating, '
      'i.year, i.added, i.epg_id, i.tmdb_id, i.archive_days, i.ext, i.url, i.plot, '
      'i.extra, i.release_date';

  String _favExpr() =>
      'EXISTS(SELECT 1 FROM favorites f WHERE f.source_id = i.source_id AND '
      'f.type = i.type AND f.item_id = i.id AND f.deleted = 0)';

  String _notHidden() =>
      'NOT EXISTS(SELECT 1 FROM hidden h WHERE h.source_id = i.source_id AND '
      'h.type = i.type AND h.deleted = 0 AND ((h.kind = \'item\' AND h.ref_id = i.id) '
      'OR (h.kind = \'category\' AND h.ref_id = i.category_id)))';

  (String, List<Variable>) _where(BrowseQuery q) {
    final parts = <String>['i.source_id = ?', 'i.type = ?'];
    final vars = <Variable>[Variable(q.sourceId), Variable(q.type.key)];
    final cat = q.categoryId;
    if (cat != null && cat.startsWith('group:')) {
      parts.add('i.id IN (SELECT gi.item_id FROM group_items gi WHERE gi.group_id = ? AND gi.deleted = 0)');
      vars.add(Variable(cat.substring(6)));
    } else if (cat != null) {
      parts.add('i.category_id = ?');
      vars.add(Variable(cat));
    }
    if (q.search.trim().isNotEmpty) {
      for (final word in normalize(q.search).split(' ').where((w) => w.isNotEmpty)) {
        parts.add('i.name_norm LIKE ?');
        vars.add(Variable('%$word%'));
      }
    }
    if (q.lang != null) {
      parts.add('i.lang = ?');
      vars.add(Variable(q.lang));
    }
    if (q.favoritesOnly) parts.add(_favExpr());
    if (q.archiveOnly) parts.add('i.archive_days > 0');
    // Hidden items stay out of normal browsing but remain in their group.
    if (cat == null || !cat.startsWith('group:')) parts.add(_notHidden());
    return (parts.join(' AND '), vars);
  }

  String _order(BrowseQuery q) {
    final sort = switch (q.sort) {
      SortMode.defaultOrder => 'i.position ASC',
      SortMode.az => 'i.name_norm ASC',
      SortMode.za => 'i.name_norm DESC',
      SortMode.addedNewest => 'i.added DESC',
      SortMode.addedOldest => 'i.added ASC',
      SortMode.releaseNewest => 'COALESCE(i.release_date, i.year) DESC',
      SortMode.releaseOldest => 'COALESCE(i.release_date, i.year) IS NULL, COALESCE(i.release_date, i.year) ASC',
      SortMode.ratingHighest => 'COALESCE(i.rating, 0) DESC',
      SortMode.ratingLowest => 'i.rating IS NULL, i.rating ASC',
    };
    final cat = q.categoryId;
    final groupOrder = cat != null && cat.startsWith('group:') && q.sort == SortMode.defaultOrder
        ? '(SELECT gi.position FROM group_items gi WHERE gi.group_id = \'${cat.substring(6).replaceAll("'", "")}\' AND gi.item_id = i.id) ASC, '
        : '';
    final fav = q.favoritesOnly && q.sort == SortMode.defaultOrder
        ? '(SELECT f.position FROM favorites f WHERE f.source_id = i.source_id AND f.type = i.type AND f.item_id = i.id) ASC, '
        : (q.favoritesFirst ? 'is_fav DESC, ' : '');
    return '$fav$groupOrder$sort, i.position ASC';
  }

  Future<List<ItemView>> browse(BrowseQuery q, {int limit = 200, int offset = 0}) async {
    final (where, vars) = _where(q);
    final rows = await db.customSelect(
      'SELECT $_itemCols, ${_favExpr()} AS is_fav FROM items i WHERE $where '
      'ORDER BY ${_order(q)} LIMIT ? OFFSET ?',
      variables: [...vars, Variable(limit), Variable(offset)],
      readsFrom: {db.items, db.favorites, db.hidden, db.groupItems},
    ).get();
    return rows.map(ItemView.fromRow).toList();
  }

  Future<int> count(BrowseQuery q) async {
    final (where, vars) = _where(q);
    final r = await db
        .customSelect('SELECT COUNT(*) AS c FROM items i WHERE $where', variables: vars)
        .getSingle();
    return r.read<int>('c');
  }

  Future<ItemView?> item(String sourceId, ContentType type, String id) async {
    final rows = await db.customSelect(
      'SELECT $_itemCols, ${_favExpr()} AS is_fav FROM items i '
      'WHERE i.source_id = ? AND i.type = ? AND i.id = ?',
      variables: [Variable(sourceId), Variable(type.key), Variable(id)],
    ).get();
    return rows.isEmpty ? null : ItemView.fromRow(rows.first);
  }

  Future<List<ItemView>> itemsByIds(
      String sourceId, ContentType type, List<String> ids) async {
    if (ids.isEmpty) return [];
    final out = <ItemView>[];
    for (var s = 0; s < ids.length; s += 500) {
      final slice = ids.sublist(s, (s + 500).clamp(0, ids.length));
      final rows = await db.customSelect(
        'SELECT $_itemCols, ${_favExpr()} AS is_fav FROM items i WHERE i.source_id = ? '
        'AND i.type = ? AND i.id IN (${List.filled(slice.length, '?').join(',')})',
        variables: [Variable(sourceId), Variable(type.key), ...slice.map(Variable.new)],
      ).get();
      out.addAll(rows.map(ItemView.fromRow));
    }
    final order = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    out.sort((a, b) => (order[a.id] ?? 0).compareTo(order[b.id] ?? 0));
    return out;
  }

  /// Language/region chips with item counts, most common first.
  Future<List<(String, int)>> chips(String sourceId, ContentType type) async {
    final rows = await db.customSelect(
      'SELECT lang, COUNT(*) AS c FROM items WHERE source_id = ? AND type = ? '
      'AND lang IS NOT NULL GROUP BY lang HAVING c >= 3 ORDER BY lang ASC',
      variables: [Variable(sourceId), Variable(type.key)],
    ).get();
    return [for (final r in rows) (r.read<String>('lang'), r.read<int>('c'))];
  }

  /// Sidebar categories: user order first, provider order next; custom groups
  /// on top. Hidden categories are included only when [includeHidden].
  Future<List<CategoryView>> categories(String sourceId, ContentType type,
      {bool includeHidden = false}) async {
    final groups = await userGroups(sourceId, type);
    final rows = await db.customSelect(
      'SELECT c.id, c.name, c.position, o.position AS upos, '
      'EXISTS(SELECT 1 FROM hidden h WHERE h.source_id = c.source_id AND h.type = c.type '
      'AND h.kind = \'category\' AND h.ref_id = c.id AND h.deleted = 0) AS hid '
      'FROM categories c LEFT JOIN category_order o ON o.source_id = c.source_id AND '
      'o.type = c.type AND o.category_id = c.id AND o.deleted = 0 '
      'WHERE c.source_id = ? AND c.type = ? '
      'ORDER BY COALESCE(o.position, 1e9 + c.position) ASC',
      variables: [Variable(sourceId), Variable(type.key)],
      readsFrom: {db.categories, db.categoryOrder, db.hidden},
    ).get();
    return [
      for (final g in groups)
        CategoryView(id: 'group:${g.id}', name: g.name, isGroup: true),
      for (final r in rows)
        if (includeHidden || r.read<int>('hid') == 0)
          CategoryView(
            id: r.read<String>('id'),
            name: r.read<String>('name'),
            hidden: r.read<int>('hid') == 1,
          ),
    ];
  }

  /// Visible item counts per category, plus `group:<id>` counts for groups.
  Future<Map<String, int>> categoryCounts(String sourceId, ContentType type) async {
    final rows = await db.customSelect(
      'SELECT i.category_id AS c, COUNT(*) AS n FROM items i '
      'WHERE i.source_id = ? AND i.type = ? AND ${_notHidden()} GROUP BY i.category_id',
      variables: [Variable(sourceId), Variable(type.key)],
      readsFrom: {db.items, db.hidden},
    ).get();
    final groups = await db.customSelect(
      'SELECT gi.group_id AS g, COUNT(*) AS n FROM group_items gi '
      'JOIN items i ON i.id = gi.item_id AND i.source_id = ? AND i.type = ? '
      'WHERE gi.deleted = 0 GROUP BY gi.group_id',
      variables: [Variable(sourceId), Variable(type.key)],
      readsFrom: {db.items, db.groupItems},
    ).get();
    return {
      for (final r in rows) r.read<String>('c'): r.read<int>('n'),
      for (final r in groups) 'group:${r.read<String>('g')}': r.read<int>('n'),
    };
  }

  Future<Map<String, String>> categoryNames(String sourceId, ContentType type) async {
    final rows = await (db.select(db.categories)
          ..where((c) => c.sourceId.equals(sourceId) & c.type.equals(type.key)))
        .get();
    return {for (final r in rows) r.id: r.name};
  }

  Future<void> setCategoryOrder(
      String sourceId, ContentType type, List<String> orderedIds) async {
    final s = stamp();
    await db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.insert(
          db.categoryOrder,
          CategoryOrderCompanion.insert(
            sourceId: sourceId,
            type: type.key,
            categoryId: orderedIds[i],
            position: i.toDouble(),
            hlc: s,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    _changed('category_order');
  }

  /// Search across all types (Search tab).
  Future<Map<ContentType, List<ItemView>>> searchAll(String sourceId, String text,
      {int perType = 60}) async {
    final out = <ContentType, List<ItemView>>{};
    for (final t in ContentType.values) {
      out[t] = await browse(
          BrowseQuery(sourceId: sourceId, type: t, search: text, sort: SortMode.az),
          limit: perType);
    }
    return out;
  }

  /// Items added most recently (Series/Movies "New" row).
  Future<List<ItemView>> newest(String sourceId, ContentType type, {int limit = 30}) =>
      browse(BrowseQuery(sourceId: sourceId, type: type, sort: SortMode.addedNewest),
          limit: limit);

  // ---------------------------------------------------------------------------
  // Favourites
  // ---------------------------------------------------------------------------

  Future<bool> toggleFavorite(String sourceId, ContentType type, String itemId) async {
    final existing = await (db.select(db.favorites)
          ..where((f) =>
              f.sourceId.equals(sourceId) & f.type.equals(type.key) & f.itemId.equals(itemId)))
        .getSingleOrNull();
    final nowFav = existing == null || existing.deleted;
    double pos = 0;
    if (nowFav) {
      final maxRow = await db.customSelect(
        'SELECT MAX(position) AS m FROM favorites WHERE source_id = ? AND type = ? AND deleted = 0',
        variables: [Variable(sourceId), Variable(type.key)],
      ).getSingle();
      pos = (maxRow.readNullable<double>('m') ?? 0) + 1;
    }
    await db.into(db.favorites).insertOnConflictUpdate(FavoritesCompanion.insert(
          sourceId: sourceId,
          type: type.key,
          itemId: itemId,
          position: Value(nowFav ? pos : (existing.position)),
          hlc: stamp(),
          deleted: Value(!nowFav),
        ));
    _changed('favorites');
    return nowFav;
  }

  Future<List<String>> favoriteIds(String sourceId, ContentType type) async {
    final rows = await (db.select(db.favorites)
          ..where((f) =>
              f.sourceId.equals(sourceId) & f.type.equals(type.key) & f.deleted.equals(false))
          ..orderBy([(f) => OrderingTerm(expression: f.position)]))
        .get();
    return rows.map((r) => r.itemId).toList();
  }

  Future<void> reorderFavorites(
      String sourceId, ContentType type, List<String> orderedIds) async {
    final s = stamp();
    await db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          db.favorites,
          FavoritesCompanion(position: Value(i.toDouble()), hlc: Value(s)),
          where: (f) =>
              f.sourceId.equals(sourceId) & f.type.equals(type.key) & f.itemId.equals(orderedIds[i]),
        );
      }
    });
    _changed('favorites');
  }

  // ---------------------------------------------------------------------------
  // Custom groups
  // ---------------------------------------------------------------------------

  Future<List<UserGroup>> userGroups(String sourceId, ContentType type) =>
      (db.select(db.userGroups)
            ..where((g) =>
                g.sourceId.equals(sourceId) & g.type.equals(type.key) & g.deleted.equals(false))
            ..orderBy([(g) => OrderingTerm(expression: g.position)]))
          .get();

  Future<UserGroup> createGroup(String sourceId, ContentType type, String name) async {
    final groups = await userGroups(sourceId, type);
    final id = _uuid.v4();
    await db.into(db.userGroups).insert(UserGroupsCompanion.insert(
          id: id,
          sourceId: sourceId,
          type: type.key,
          name: name.trim(),
          position: Value(groups.length.toDouble()),
          hlc: stamp(),
        ));
    _changed('groups');
    return (await (db.select(db.userGroups)..where((g) => g.id.equals(id))).getSingle());
  }

  Future<void> renameGroup(String id, String name) async {
    await (db.update(db.userGroups)..where((g) => g.id.equals(id)))
        .write(UserGroupsCompanion(name: Value(name.trim()), hlc: Value(stamp())));
    _changed('groups');
  }

  Future<void> deleteGroup(String id) async {
    final s = stamp();
    await db.transaction(() async {
      await (db.update(db.userGroups)..where((g) => g.id.equals(id)))
          .write(UserGroupsCompanion(deleted: const Value(true), hlc: Value(s)));
      await (db.update(db.groupItems)..where((g) => g.groupId.equals(id)))
          .write(GroupItemsCompanion(deleted: const Value(true), hlc: Value(s)));
    });
    _changed('groups');
  }

  Future<void> reorderGroups(List<String> orderedIds) async {
    final s = stamp();
    await db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(db.userGroups,
            UserGroupsCompanion(position: Value(i.toDouble()), hlc: Value(s)),
            where: (g) => g.id.equals(orderedIds[i]));
      }
    });
    _changed('groups');
  }

  Future<Set<String>> groupsContaining(String itemId) async {
    final rows = await (db.select(db.groupItems)
          ..where((g) => g.itemId.equals(itemId) & g.deleted.equals(false)))
        .get();
    return rows.map((r) => r.groupId).toSet();
  }

  Future<void> setInGroup(String groupId, String itemId, bool inGroup) async {
    double pos = 0;
    if (inGroup) {
      final m = await db.customSelect(
          'SELECT MAX(position) AS m FROM group_items WHERE group_id = ? AND deleted = 0',
          variables: [Variable(groupId)]).getSingle();
      pos = (m.readNullable<double>('m') ?? -1) + 1;
    }
    await db.into(db.groupItems).insertOnConflictUpdate(GroupItemsCompanion.insert(
          groupId: groupId,
          itemId: itemId,
          position: Value(pos),
          hlc: stamp(),
          deleted: Value(!inGroup),
        ));
    _changed('groups');
  }

  Future<void> reorderGroupItems(String groupId, List<String> orderedIds) async {
    final s = stamp();
    await db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(db.groupItems,
            GroupItemsCompanion(position: Value(i.toDouble()), hlc: Value(s)),
            where: (g) => g.groupId.equals(groupId) & g.itemId.equals(orderedIds[i]));
      }
    });
    _changed('groups');
  }

  Future<List<String>> groupItemIds(String groupId) async {
    final rows = await (db.select(db.groupItems)
          ..where((g) => g.groupId.equals(groupId) & g.deleted.equals(false))
          ..orderBy([(g) => OrderingTerm(expression: g.position)]))
        .get();
    return rows.map((r) => r.itemId).toList();
  }

  // ---------------------------------------------------------------------------
  // Hidden content
  // ---------------------------------------------------------------------------

  Future<void> setHidden(String sourceId, ContentType type, String kind, String refId,
      bool hidden) async {
    await db.into(db.hidden).insertOnConflictUpdate(HiddenCompanion.insert(
          sourceId: sourceId,
          type: type.key,
          kind: kind,
          refId: refId,
          hlc: stamp(),
          deleted: Value(!hidden),
        ));
    _changed('hidden');
  }

  Future<List<String>> hiddenIds(String sourceId, ContentType type, String kind) async {
    final rows = await (db.select(db.hidden)
          ..where((h) =>
              h.sourceId.equals(sourceId) &
              h.type.equals(type.key) &
              h.kind.equals(kind) &
              h.deleted.equals(false)))
        .get();
    return rows.map((r) => r.refId).toList();
  }

  // ---------------------------------------------------------------------------
  // Watch history & resume
  // ---------------------------------------------------------------------------

  Future<void> recordWatch({
    required String sourceId,
    required String type, // live | movie | episode
    required String itemId,
    required String name,
    String? icon,
    String? seriesId,
    int? season,
    int? episode,
    int positionMs = 0,
    int durationMs = 0,
  }) async {
    // The last 5% counts as finished (credits).
    final finished = durationMs > 0 && positionMs >= durationMs * 0.95;
    await db.into(db.watchState).insertOnConflictUpdate(WatchStateCompanion.insert(
          sourceId: sourceId,
          type: type,
          itemId: itemId,
          seriesId: Value(seriesId),
          name: name,
          icon: Value(icon),
          season: Value(season),
          episode: Value(episode),
          positionMs: Value(finished ? 0 : positionMs),
          durationMs: Value(durationMs),
          watchedAt: DateTime.now().millisecondsSinceEpoch,
          finished: Value(finished),
          hlc: stamp(),
          deleted: const Value(false),
        ));
    _changed('watch');
  }

  Future<WatchRow?> watch(String sourceId, String type, String itemId) =>
      (db.select(db.watchState)
            ..where((w) =>
                w.sourceId.equals(sourceId) &
                w.type.equals(type) &
                w.itemId.equals(itemId) &
                w.deleted.equals(false)))
          .getSingleOrNull();

  Future<List<WatchRow>> recent(String sourceId, String type, {int limit = 30}) =>
      (db.select(db.watchState)
            ..where((w) =>
                w.sourceId.equals(sourceId) & w.type.equals(type) & w.deleted.equals(false))
            ..orderBy([(w) => OrderingTerm.desc(w.watchedAt)])
            ..limit(limit))
          .get();

  /// Episodes watched for a series, keyed by episode id.
  Future<Map<String, WatchRow>> seriesProgress(String sourceId, String seriesId) async {
    final rows = await (db.select(db.watchState)
          ..where((w) =>
              w.sourceId.equals(sourceId) &
              w.type.equals('episode') &
              w.seriesId.equals(seriesId) &
              w.deleted.equals(false)))
        .get();
    return {for (final r in rows) r.itemId: r};
  }

  /// Series with an episode watched recently (most recent first): seriesId → last row.
  Future<List<WatchRow>> recentSeries(String sourceId, {int limit = 30}) async {
    final rows = await (db.select(db.watchState)
          ..where((w) =>
              w.sourceId.equals(sourceId) &
              w.type.equals('episode') &
              w.deleted.equals(false))
          ..orderBy([(w) => OrderingTerm.desc(w.watchedAt)]))
        .get();
    final seen = <String>{};
    final out = <WatchRow>[];
    for (final r in rows) {
      if (r.seriesId == null || !seen.add(r.seriesId!)) continue;
      out.add(r);
      if (out.length >= limit) break;
    }
    return out;
  }

  Future<void> removeWatch(String sourceId, String type, String itemId) async {
    await (db.update(db.watchState)
          ..where((w) =>
              w.sourceId.equals(sourceId) & w.type.equals(type) & w.itemId.equals(itemId)))
        .write(WatchStateCompanion(deleted: const Value(true), hlc: Value(stamp())));
    _changed('watch');
  }

  /// Drops a series from "recently watched" by clearing every episode's history.
  Future<void> removeSeriesWatch(String sourceId, String seriesId) async {
    await (db.update(db.watchState)
          ..where((w) => w.sourceId.equals(sourceId) & w.type.equals('episode') & w.seriesId.equals(seriesId)))
        .write(WatchStateCompanion(deleted: const Value(true), hlc: Value(stamp())));
    _changed('watch');
  }

  /// Deletes history for a content type ('live', 'movie', 'series'), or all.
  Future<void> clearHistory(String sourceId, {ContentType? type}) async {
    final types = type == null
        ? ['live', 'movie', 'episode']
        : [type == ContentType.series ? 'episode' : type.key];
    await (db.update(db.watchState)
          ..where((w) => w.sourceId.equals(sourceId) & w.type.isIn(types)))
        .write(WatchStateCompanion(deleted: const Value(true), hlc: Value(stamp())));
    _changed('watch');
  }

  // ---------------------------------------------------------------------------
  // Preferences (synced key/value)
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> allPrefs() async {
    final rows = await (db.select(db.prefs)..where((p) => p.deleted.equals(false))).get();
    return {for (final r in rows) r.key: r.value};
  }

  Future<void> setPref(String key, String value) async {
    await db.into(db.prefs).insertOnConflictUpdate(
        PrefsCompanion.insert(key: key, value: value, hlc: stamp(), deleted: const Value(false)));
    _changed('prefs');
  }

  // ---------------------------------------------------------------------------
  // EPG storage
  // ---------------------------------------------------------------------------

  Future<void> replaceEpg(String sourceId, List<(String, int, int, String, String?)> progs,
      Map<String, String> matches) async {
    await db.transaction(() async {
      await (db.delete(db.epgProgrammes)..where((p) => p.sourceId.equals(sourceId))).go();
      for (var s = 0; s < progs.length; s += 5000) {
        final slice = progs.skip(s).take(5000);
        await db.batch((b) {
          b.insertAll(
            db.epgProgrammes,
            [
              for (final p in slice)
                EpgProgrammesCompanion.insert(
                  sourceId: sourceId,
                  channelKey: p.$1,
                  start: p.$2,
                  stop: p.$3,
                  title: p.$4,
                  description: Value(p.$5),
                )
            ],
            mode: InsertMode.insertOrReplace,
          );
        });
      }
      // Remember matches so channels without a provider EPG id still resolve.
      await db.batch((b) {
        matches.forEach((itemId, xmltvId) {
          b.update(db.items, ItemsCompanion(epgId: Value(xmltvId)),
              where: (i) =>
                  i.sourceId.equals(sourceId) & i.type.equals('live') & i.id.equals(itemId));
        });
      });
    });
    catalogChanges.add(sourceId);
  }

  /// Programmes for [epgIds] overlapping [from, to).
  Future<Map<String, List<Programme>>> programmes(
      String sourceId, List<String> epgIds, DateTime from, DateTime to,
      {int offsetMin = 0}) async {
    if (epgIds.isEmpty) return {};
    final shift = offsetMin * 60;
    final out = <String, List<Programme>>{};
    for (var s = 0; s < epgIds.length; s += 400) {
      final slice = epgIds.sublist(s, (s + 400).clamp(0, epgIds.length));
      final rows = await db.customSelect(
        'SELECT channel_key, start, stop, title, description FROM epg_programmes '
        'WHERE source_id = ? AND channel_key IN (${List.filled(slice.length, '?').join(',')}) '
        'AND stop > ? AND start < ? ORDER BY start ASC',
        variables: [
          Variable(sourceId),
          ...slice.map(Variable.new),
          Variable(from.millisecondsSinceEpoch ~/ 1000 - shift),
          Variable(to.millisecondsSinceEpoch ~/ 1000 - shift),
        ],
      ).get();
      for (final r in rows) {
        (out[r.read<String>('channel_key')] ??= []).add(Programme(
          start: DateTime.fromMillisecondsSinceEpoch((r.read<int>('start') + shift) * 1000),
          stop: DateTime.fromMillisecondsSinceEpoch((r.read<int>('stop') + shift) * 1000),
          title: r.read<String>('title'),
          description: r.readNullable<String>('description'),
        ));
      }
    }
    return out;
  }

  Future<int?> latestProgrammeEnd(String sourceId) async {
    final r = await db.customSelect(
        'SELECT MAX(stop) AS m FROM epg_programmes WHERE source_id = ?',
        variables: [Variable(sourceId)]).getSingle();
    return r.readNullable<int>('m');
  }

  /// Live channels that have programme data from now on. A guide id shared by many
  /// channels (provider placeholders) is not counted as a real guide for each.
  Future<int> guideCoverage(String sourceId) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final r = await db.customSelect(
        'SELECT COUNT(*) AS n FROM items WHERE source_id = ? AND type = \'live\' AND epg_id IN ('
        ' SELECT channel_key FROM epg_programmes WHERE source_id = ? AND stop > ?)'
        ' AND epg_id IN (SELECT epg_id FROM items WHERE source_id = ? AND type = \'live\' AND epg_id IS NOT NULL'
        ' GROUP BY epg_id HAVING COUNT(*) <= 25)',
        variables: [Variable(sourceId), Variable(sourceId), Variable(now), Variable(sourceId)]).getSingle();
    return r.read<int>('n');
  }

  /// Live channels (id → (epgId, name)) for EPG matching.
  Future<Map<String, (String?, String)>> liveChannelsForEpg(String sourceId) async {
    final rows = await db.customSelect(
        'SELECT id, epg_id, name, extra FROM items WHERE source_id = ? AND type = \'live\'',
        variables: [Variable(sourceId)]).get();
    final out = <String, (String?, String)>{};
    for (final r in rows) {
      out[r.read<String>('id')] = (r.readNullable<String>('epg_id'), r.read<String>('name'));
    }
    return out;
  }
}
