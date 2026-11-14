// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [sourceId, type, id, name, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, type, id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String sourceId;
  final String type;
  final String id;
  final String name;
  final int position;
  const CategoryRow({
    required this.sourceId,
    required this.type,
    required this.id,
    required this.name,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      sourceId: Value(sourceId),
      type: Value(type),
      id: Value(id),
      name: Value(name),
      position: Value(position),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  CategoryRow copyWith({
    String? sourceId,
    String? type,
    String? id,
    String? name,
    int? position,
  }) => CategoryRow(
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    id: id ?? this.id,
    name: name ?? this.name,
    position: position ?? this.position,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, type, id, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> id;
  final Value<String> name;
  final Value<int> position;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String sourceId,
    required String type,
    required String id,
    required String name,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       type = Value(type),
       id = Value(id),
       name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? id,
    Value<String>? name,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  @override
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedMeta = const VerificationMeta('added');
  @override
  late final GeneratedColumn<int> added = GeneratedColumn<int>(
    'added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _epgIdMeta = const VerificationMeta('epgId');
  @override
  late final GeneratedColumn<String> epgId = GeneratedColumn<String>(
    'epg_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archiveDaysMeta = const VerificationMeta(
    'archiveDays',
  );
  @override
  late final GeneratedColumn<int> archiveDays = GeneratedColumn<int>(
    'archive_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _extMeta = const VerificationMeta('ext');
  @override
  late final GeneratedColumn<String> ext = GeneratedColumn<String>(
    'ext',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotMeta = const VerificationMeta('plot');
  @override
  late final GeneratedColumn<String> plot = GeneratedColumn<String>(
    'plot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
    'extra',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    type,
    id,
    name,
    nameNorm,
    categoryId,
    icon,
    lang,
    rating,
    added,
    year,
    releaseDate,
    position,
    epgId,
    tmdbId,
    archiveDays,
    ext,
    url,
    plot,
    extra,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('added')) {
      context.handle(
        _addedMeta,
        added.isAcceptableOrUnknown(data['added']!, _addedMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('epg_id')) {
      context.handle(
        _epgIdMeta,
        epgId.isAcceptableOrUnknown(data['epg_id']!, _epgIdMeta),
      );
    }
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    }
    if (data.containsKey('archive_days')) {
      context.handle(
        _archiveDaysMeta,
        archiveDays.isAcceptableOrUnknown(
          data['archive_days']!,
          _archiveDaysMeta,
        ),
      );
    }
    if (data.containsKey('ext')) {
      context.handle(
        _extMeta,
        ext.isAcceptableOrUnknown(data['ext']!, _extMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('plot')) {
      context.handle(
        _plotMeta,
        plot.isAcceptableOrUnknown(data['plot']!, _plotMeta),
      );
    }
    if (data.containsKey('extra')) {
      context.handle(
        _extraMeta,
        extra.isAcceptableOrUnknown(data['extra']!, _extraMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, type, id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      added: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_date'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      epgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epg_id'],
      ),
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      ),
      archiveDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}archive_days'],
      )!,
      ext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ext'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      plot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot'],
      ),
      extra: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String sourceId;
  final String type;
  final String id;
  final String name;
  final String nameNorm;
  final String categoryId;
  final String? icon;
  final String? lang;
  final double? rating;
  final int added;
  final int? year;
  final String? releaseDate;
  final int position;
  final String? epgId;
  final int? tmdbId;
  final int archiveDays;
  final String? ext;
  final String? url;
  final String? plot;
  final String? extra;
  const Item({
    required this.sourceId,
    required this.type,
    required this.id,
    required this.name,
    required this.nameNorm,
    required this.categoryId,
    this.icon,
    this.lang,
    this.rating,
    required this.added,
    this.year,
    this.releaseDate,
    required this.position,
    this.epgId,
    this.tmdbId,
    required this.archiveDays,
    this.ext,
    this.url,
    this.plot,
    this.extra,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    map['added'] = Variable<int>(added);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || epgId != null) {
      map['epg_id'] = Variable<String>(epgId);
    }
    if (!nullToAbsent || tmdbId != null) {
      map['tmdb_id'] = Variable<int>(tmdbId);
    }
    map['archive_days'] = Variable<int>(archiveDays);
    if (!nullToAbsent || ext != null) {
      map['ext'] = Variable<String>(ext);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || plot != null) {
      map['plot'] = Variable<String>(plot);
    }
    if (!nullToAbsent || extra != null) {
      map['extra'] = Variable<String>(extra);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      sourceId: Value(sourceId),
      type: Value(type),
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
      categoryId: Value(categoryId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      added: Value(added),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      position: Value(position),
      epgId: epgId == null && nullToAbsent
          ? const Value.absent()
          : Value(epgId),
      tmdbId: tmdbId == null && nullToAbsent
          ? const Value.absent()
          : Value(tmdbId),
      archiveDays: Value(archiveDays),
      ext: ext == null && nullToAbsent ? const Value.absent() : Value(ext),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      plot: plot == null && nullToAbsent ? const Value.absent() : Value(plot),
      extra: extra == null && nullToAbsent
          ? const Value.absent()
          : Value(extra),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['nameNorm']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      icon: serializer.fromJson<String?>(json['icon']),
      lang: serializer.fromJson<String?>(json['lang']),
      rating: serializer.fromJson<double?>(json['rating']),
      added: serializer.fromJson<int>(json['added']),
      year: serializer.fromJson<int?>(json['year']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      position: serializer.fromJson<int>(json['position']),
      epgId: serializer.fromJson<String?>(json['epgId']),
      tmdbId: serializer.fromJson<int?>(json['tmdbId']),
      archiveDays: serializer.fromJson<int>(json['archiveDays']),
      ext: serializer.fromJson<String?>(json['ext']),
      url: serializer.fromJson<String?>(json['url']),
      plot: serializer.fromJson<String?>(json['plot']),
      extra: serializer.fromJson<String?>(json['extra']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameNorm': serializer.toJson<String>(nameNorm),
      'categoryId': serializer.toJson<String>(categoryId),
      'icon': serializer.toJson<String?>(icon),
      'lang': serializer.toJson<String?>(lang),
      'rating': serializer.toJson<double?>(rating),
      'added': serializer.toJson<int>(added),
      'year': serializer.toJson<int?>(year),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'position': serializer.toJson<int>(position),
      'epgId': serializer.toJson<String?>(epgId),
      'tmdbId': serializer.toJson<int?>(tmdbId),
      'archiveDays': serializer.toJson<int>(archiveDays),
      'ext': serializer.toJson<String?>(ext),
      'url': serializer.toJson<String?>(url),
      'plot': serializer.toJson<String?>(plot),
      'extra': serializer.toJson<String?>(extra),
    };
  }

  Item copyWith({
    String? sourceId,
    String? type,
    String? id,
    String? name,
    String? nameNorm,
    String? categoryId,
    Value<String?> icon = const Value.absent(),
    Value<String?> lang = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    int? added,
    Value<int?> year = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    int? position,
    Value<String?> epgId = const Value.absent(),
    Value<int?> tmdbId = const Value.absent(),
    int? archiveDays,
    Value<String?> ext = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> plot = const Value.absent(),
    Value<String?> extra = const Value.absent(),
  }) => Item(
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
    categoryId: categoryId ?? this.categoryId,
    icon: icon.present ? icon.value : this.icon,
    lang: lang.present ? lang.value : this.lang,
    rating: rating.present ? rating.value : this.rating,
    added: added ?? this.added,
    year: year.present ? year.value : this.year,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    position: position ?? this.position,
    epgId: epgId.present ? epgId.value : this.epgId,
    tmdbId: tmdbId.present ? tmdbId.value : this.tmdbId,
    archiveDays: archiveDays ?? this.archiveDays,
    ext: ext.present ? ext.value : this.ext,
    url: url.present ? url.value : this.url,
    plot: plot.present ? plot.value : this.plot,
    extra: extra.present ? extra.value : this.extra,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      icon: data.icon.present ? data.icon.value : this.icon,
      lang: data.lang.present ? data.lang.value : this.lang,
      rating: data.rating.present ? data.rating.value : this.rating,
      added: data.added.present ? data.added.value : this.added,
      year: data.year.present ? data.year.value : this.year,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      position: data.position.present ? data.position.value : this.position,
      epgId: data.epgId.present ? data.epgId.value : this.epgId,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      archiveDays: data.archiveDays.present
          ? data.archiveDays.value
          : this.archiveDays,
      ext: data.ext.present ? data.ext.value : this.ext,
      url: data.url.present ? data.url.value : this.url,
      plot: data.plot.present ? data.plot.value : this.plot,
      extra: data.extra.present ? data.extra.value : this.extra,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('categoryId: $categoryId, ')
          ..write('icon: $icon, ')
          ..write('lang: $lang, ')
          ..write('rating: $rating, ')
          ..write('added: $added, ')
          ..write('year: $year, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('position: $position, ')
          ..write('epgId: $epgId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('archiveDays: $archiveDays, ')
          ..write('ext: $ext, ')
          ..write('url: $url, ')
          ..write('plot: $plot, ')
          ..write('extra: $extra')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    type,
    id,
    name,
    nameNorm,
    categoryId,
    icon,
    lang,
    rating,
    added,
    year,
    releaseDate,
    position,
    epgId,
    tmdbId,
    archiveDays,
    ext,
    url,
    plot,
    extra,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm &&
          other.categoryId == this.categoryId &&
          other.icon == this.icon &&
          other.lang == this.lang &&
          other.rating == this.rating &&
          other.added == this.added &&
          other.year == this.year &&
          other.releaseDate == this.releaseDate &&
          other.position == this.position &&
          other.epgId == this.epgId &&
          other.tmdbId == this.tmdbId &&
          other.archiveDays == this.archiveDays &&
          other.ext == this.ext &&
          other.url == this.url &&
          other.plot == this.plot &&
          other.extra == this.extra);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> id;
  final Value<String> name;
  final Value<String> nameNorm;
  final Value<String> categoryId;
  final Value<String?> icon;
  final Value<String?> lang;
  final Value<double?> rating;
  final Value<int> added;
  final Value<int?> year;
  final Value<String?> releaseDate;
  final Value<int> position;
  final Value<String?> epgId;
  final Value<int?> tmdbId;
  final Value<int> archiveDays;
  final Value<String?> ext;
  final Value<String?> url;
  final Value<String?> plot;
  final Value<String?> extra;
  final Value<int> rowid;
  const ItemsCompanion({
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.icon = const Value.absent(),
    this.lang = const Value.absent(),
    this.rating = const Value.absent(),
    this.added = const Value.absent(),
    this.year = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.position = const Value.absent(),
    this.epgId = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.archiveDays = const Value.absent(),
    this.ext = const Value.absent(),
    this.url = const Value.absent(),
    this.plot = const Value.absent(),
    this.extra = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String sourceId,
    required String type,
    required String id,
    required String name,
    required String nameNorm,
    this.categoryId = const Value.absent(),
    this.icon = const Value.absent(),
    this.lang = const Value.absent(),
    this.rating = const Value.absent(),
    this.added = const Value.absent(),
    this.year = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.position = const Value.absent(),
    this.epgId = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.archiveDays = const Value.absent(),
    this.ext = const Value.absent(),
    this.url = const Value.absent(),
    this.plot = const Value.absent(),
    this.extra = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       type = Value(type),
       id = Value(id),
       name = Value(name),
       nameNorm = Value(nameNorm);
  static Insertable<Item> custom({
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
    Expression<String>? categoryId,
    Expression<String>? icon,
    Expression<String>? lang,
    Expression<double>? rating,
    Expression<int>? added,
    Expression<int>? year,
    Expression<String>? releaseDate,
    Expression<int>? position,
    Expression<String>? epgId,
    Expression<int>? tmdbId,
    Expression<int>? archiveDays,
    Expression<String>? ext,
    Expression<String>? url,
    Expression<String>? plot,
    Expression<String>? extra,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
      if (categoryId != null) 'category_id': categoryId,
      if (icon != null) 'icon': icon,
      if (lang != null) 'lang': lang,
      if (rating != null) 'rating': rating,
      if (added != null) 'added': added,
      if (year != null) 'year': year,
      if (releaseDate != null) 'release_date': releaseDate,
      if (position != null) 'position': position,
      if (epgId != null) 'epg_id': epgId,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (archiveDays != null) 'archive_days': archiveDays,
      if (ext != null) 'ext': ext,
      if (url != null) 'url': url,
      if (plot != null) 'plot': plot,
      if (extra != null) 'extra': extra,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? id,
    Value<String>? name,
    Value<String>? nameNorm,
    Value<String>? categoryId,
    Value<String?>? icon,
    Value<String?>? lang,
    Value<double?>? rating,
    Value<int>? added,
    Value<int?>? year,
    Value<String?>? releaseDate,
    Value<int>? position,
    Value<String?>? epgId,
    Value<int?>? tmdbId,
    Value<int>? archiveDays,
    Value<String?>? ext,
    Value<String?>? url,
    Value<String?>? plot,
    Value<String?>? extra,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
      categoryId: categoryId ?? this.categoryId,
      icon: icon ?? this.icon,
      lang: lang ?? this.lang,
      rating: rating ?? this.rating,
      added: added ?? this.added,
      year: year ?? this.year,
      releaseDate: releaseDate ?? this.releaseDate,
      position: position ?? this.position,
      epgId: epgId ?? this.epgId,
      tmdbId: tmdbId ?? this.tmdbId,
      archiveDays: archiveDays ?? this.archiveDays,
      ext: ext ?? this.ext,
      url: url ?? this.url,
      plot: plot ?? this.plot,
      extra: extra ?? this.extra,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (added.present) {
      map['added'] = Variable<int>(added.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (epgId.present) {
      map['epg_id'] = Variable<String>(epgId.value);
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (archiveDays.present) {
      map['archive_days'] = Variable<int>(archiveDays.value);
    }
    if (ext.present) {
      map['ext'] = Variable<String>(ext.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (plot.present) {
      map['plot'] = Variable<String>(plot.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('categoryId: $categoryId, ')
          ..write('icon: $icon, ')
          ..write('lang: $lang, ')
          ..write('rating: $rating, ')
          ..write('added: $added, ')
          ..write('year: $year, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('position: $position, ')
          ..write('epgId: $epgId, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('archiveDays: $archiveDays, ')
          ..write('ext: $ext, ')
          ..write('url: $url, ')
          ..write('plot: $plot, ')
          ..write('extra: $extra, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesCacheTable extends SeriesCache
    with TableInfo<$SeriesCacheTable, SeriesCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sourceId, seriesId, fetchedAt, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, seriesId};
  @override
  SeriesCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesCacheData(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $SeriesCacheTable createAlias(String alias) {
    return $SeriesCacheTable(attachedDatabase, alias);
  }
}

class SeriesCacheData extends DataClass implements Insertable<SeriesCacheData> {
  final String sourceId;
  final String seriesId;
  final int fetchedAt;
  final String json;
  const SeriesCacheData({
    required this.sourceId,
    required this.seriesId,
    required this.fetchedAt,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['series_id'] = Variable<String>(seriesId);
    map['fetched_at'] = Variable<int>(fetchedAt);
    map['json'] = Variable<String>(json);
    return map;
  }

  SeriesCacheCompanion toCompanion(bool nullToAbsent) {
    return SeriesCacheCompanion(
      sourceId: Value(sourceId),
      seriesId: Value(seriesId),
      fetchedAt: Value(fetchedAt),
      json: Value(json),
    );
  }

  factory SeriesCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesCacheData(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'seriesId': serializer.toJson<String>(seriesId),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
      'json': serializer.toJson<String>(json),
    };
  }

  SeriesCacheData copyWith({
    String? sourceId,
    String? seriesId,
    int? fetchedAt,
    String? json,
  }) => SeriesCacheData(
    sourceId: sourceId ?? this.sourceId,
    seriesId: seriesId ?? this.seriesId,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    json: json ?? this.json,
  );
  SeriesCacheData copyWithCompanion(SeriesCacheCompanion data) {
    return SeriesCacheData(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCacheData(')
          ..write('sourceId: $sourceId, ')
          ..write('seriesId: $seriesId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, seriesId, fetchedAt, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesCacheData &&
          other.sourceId == this.sourceId &&
          other.seriesId == this.seriesId &&
          other.fetchedAt == this.fetchedAt &&
          other.json == this.json);
}

class SeriesCacheCompanion extends UpdateCompanion<SeriesCacheData> {
  final Value<String> sourceId;
  final Value<String> seriesId;
  final Value<int> fetchedAt;
  final Value<String> json;
  final Value<int> rowid;
  const SeriesCacheCompanion({
    this.sourceId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesCacheCompanion.insert({
    required String sourceId,
    required String seriesId,
    required int fetchedAt,
    required String json,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       seriesId = Value(seriesId),
       fetchedAt = Value(fetchedAt),
       json = Value(json);
  static Insertable<SeriesCacheData> custom({
    Expression<String>? sourceId,
    Expression<String>? seriesId,
    Expression<int>? fetchedAt,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (seriesId != null) 'series_id': seriesId,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesCacheCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? seriesId,
    Value<int>? fetchedAt,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return SeriesCacheCompanion(
      sourceId: sourceId ?? this.sourceId,
      seriesId: seriesId ?? this.seriesId,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCacheCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('seriesId: $seriesId, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaCacheTable extends MetaCache
    with TableInfo<$MetaCacheTable, MetaCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $MetaCacheTable createAlias(String alias) {
    return $MetaCacheTable(attachedDatabase, alias);
  }
}

class MetaCacheData extends DataClass implements Insertable<MetaCacheData> {
  final String key;
  final String value;
  final int fetchedAt;
  const MetaCacheData({
    required this.key,
    required this.value,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  MetaCacheCompanion toCompanion(bool nullToAbsent) {
    return MetaCacheCompanion(
      key: Value(key),
      value: Value(value),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory MetaCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaCacheData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  MetaCacheData copyWith({String? key, String? value, int? fetchedAt}) =>
      MetaCacheData(
        key: key ?? this.key,
        value: value ?? this.value,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  MetaCacheData copyWithCompanion(MetaCacheCompanion data) {
    return MetaCacheData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaCacheData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaCacheData &&
          other.key == this.key &&
          other.value == this.value &&
          other.fetchedAt == this.fetchedAt);
}

class MetaCacheCompanion extends UpdateCompanion<MetaCacheData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const MetaCacheCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCacheCompanion.insert({
    required String key,
    required String value,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       fetchedAt = Value(fetchedAt);
  static Insertable<MetaCacheData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return MetaCacheCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCacheCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpgChannelsTable extends EpgChannels
    with TableInfo<$EpgChannelsTable, EpgChannel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpgChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelKeyMeta = const VerificationMeta(
    'channelKey',
  );
  @override
  late final GeneratedColumn<String> channelKey = GeneratedColumn<String>(
    'channel_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  @override
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [sourceId, channelKey, nameNorm, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epg_channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpgChannel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('channel_key')) {
      context.handle(
        _channelKeyMeta,
        channelKey.isAcceptableOrUnknown(data['channel_key']!, _channelKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_channelKeyMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, channelKey, nameNorm};
  @override
  EpgChannel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpgChannel(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      channelKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_key'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $EpgChannelsTable createAlias(String alias) {
    return $EpgChannelsTable(attachedDatabase, alias);
  }
}

class EpgChannel extends DataClass implements Insertable<EpgChannel> {
  final String sourceId;
  final String channelKey;
  final String nameNorm;
  final String? icon;
  const EpgChannel({
    required this.sourceId,
    required this.channelKey,
    required this.nameNorm,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['channel_key'] = Variable<String>(channelKey);
    map['name_norm'] = Variable<String>(nameNorm);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  EpgChannelsCompanion toCompanion(bool nullToAbsent) {
    return EpgChannelsCompanion(
      sourceId: Value(sourceId),
      channelKey: Value(channelKey),
      nameNorm: Value(nameNorm),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory EpgChannel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpgChannel(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      channelKey: serializer.fromJson<String>(json['channelKey']),
      nameNorm: serializer.fromJson<String>(json['nameNorm']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'channelKey': serializer.toJson<String>(channelKey),
      'nameNorm': serializer.toJson<String>(nameNorm),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  EpgChannel copyWith({
    String? sourceId,
    String? channelKey,
    String? nameNorm,
    Value<String?> icon = const Value.absent(),
  }) => EpgChannel(
    sourceId: sourceId ?? this.sourceId,
    channelKey: channelKey ?? this.channelKey,
    nameNorm: nameNorm ?? this.nameNorm,
    icon: icon.present ? icon.value : this.icon,
  );
  EpgChannel copyWithCompanion(EpgChannelsCompanion data) {
    return EpgChannel(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      channelKey: data.channelKey.present
          ? data.channelKey.value
          : this.channelKey,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpgChannel(')
          ..write('sourceId: $sourceId, ')
          ..write('channelKey: $channelKey, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, channelKey, nameNorm, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpgChannel &&
          other.sourceId == this.sourceId &&
          other.channelKey == this.channelKey &&
          other.nameNorm == this.nameNorm &&
          other.icon == this.icon);
}

class EpgChannelsCompanion extends UpdateCompanion<EpgChannel> {
  final Value<String> sourceId;
  final Value<String> channelKey;
  final Value<String> nameNorm;
  final Value<String?> icon;
  final Value<int> rowid;
  const EpgChannelsCompanion({
    this.sourceId = const Value.absent(),
    this.channelKey = const Value.absent(),
    this.nameNorm = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpgChannelsCompanion.insert({
    required String sourceId,
    required String channelKey,
    required String nameNorm,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       channelKey = Value(channelKey),
       nameNorm = Value(nameNorm);
  static Insertable<EpgChannel> custom({
    Expression<String>? sourceId,
    Expression<String>? channelKey,
    Expression<String>? nameNorm,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (channelKey != null) 'channel_key': channelKey,
      if (nameNorm != null) 'name_norm': nameNorm,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpgChannelsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? channelKey,
    Value<String>? nameNorm,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return EpgChannelsCompanion(
      sourceId: sourceId ?? this.sourceId,
      channelKey: channelKey ?? this.channelKey,
      nameNorm: nameNorm ?? this.nameNorm,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (channelKey.present) {
      map['channel_key'] = Variable<String>(channelKey.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpgChannelsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('channelKey: $channelKey, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EpgProgrammesTable extends EpgProgrammes
    with TableInfo<$EpgProgrammesTable, EpgProgramme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpgProgrammesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelKeyMeta = const VerificationMeta(
    'channelKey',
  );
  @override
  late final GeneratedColumn<String> channelKey = GeneratedColumn<String>(
    'channel_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<int> start = GeneratedColumn<int>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stopMeta = const VerificationMeta('stop');
  @override
  late final GeneratedColumn<int> stop = GeneratedColumn<int>(
    'stop',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    channelKey,
    start,
    stop,
    title,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'epg_programmes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpgProgramme> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('channel_key')) {
      context.handle(
        _channelKeyMeta,
        channelKey.isAcceptableOrUnknown(data['channel_key']!, _channelKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_channelKeyMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('stop')) {
      context.handle(
        _stopMeta,
        stop.isAcceptableOrUnknown(data['stop']!, _stopMeta),
      );
    } else if (isInserting) {
      context.missing(_stopMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, channelKey, start};
  @override
  EpgProgramme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpgProgramme(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      channelKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_key'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start'],
      )!,
      stop: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stop'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $EpgProgrammesTable createAlias(String alias) {
    return $EpgProgrammesTable(attachedDatabase, alias);
  }
}

class EpgProgramme extends DataClass implements Insertable<EpgProgramme> {
  final String sourceId;
  final String channelKey;
  final int start;
  final int stop;
  final String title;
  final String? description;
  const EpgProgramme({
    required this.sourceId,
    required this.channelKey,
    required this.start,
    required this.stop,
    required this.title,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['channel_key'] = Variable<String>(channelKey);
    map['start'] = Variable<int>(start);
    map['stop'] = Variable<int>(stop);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  EpgProgrammesCompanion toCompanion(bool nullToAbsent) {
    return EpgProgrammesCompanion(
      sourceId: Value(sourceId),
      channelKey: Value(channelKey),
      start: Value(start),
      stop: Value(stop),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory EpgProgramme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpgProgramme(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      channelKey: serializer.fromJson<String>(json['channelKey']),
      start: serializer.fromJson<int>(json['start']),
      stop: serializer.fromJson<int>(json['stop']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'channelKey': serializer.toJson<String>(channelKey),
      'start': serializer.toJson<int>(start),
      'stop': serializer.toJson<int>(stop),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
    };
  }

  EpgProgramme copyWith({
    String? sourceId,
    String? channelKey,
    int? start,
    int? stop,
    String? title,
    Value<String?> description = const Value.absent(),
  }) => EpgProgramme(
    sourceId: sourceId ?? this.sourceId,
    channelKey: channelKey ?? this.channelKey,
    start: start ?? this.start,
    stop: stop ?? this.stop,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
  );
  EpgProgramme copyWithCompanion(EpgProgrammesCompanion data) {
    return EpgProgramme(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      channelKey: data.channelKey.present
          ? data.channelKey.value
          : this.channelKey,
      start: data.start.present ? data.start.value : this.start,
      stop: data.stop.present ? data.stop.value : this.stop,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgramme(')
          ..write('sourceId: $sourceId, ')
          ..write('channelKey: $channelKey, ')
          ..write('start: $start, ')
          ..write('stop: $stop, ')
          ..write('title: $title, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, channelKey, start, stop, title, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpgProgramme &&
          other.sourceId == this.sourceId &&
          other.channelKey == this.channelKey &&
          other.start == this.start &&
          other.stop == this.stop &&
          other.title == this.title &&
          other.description == this.description);
}

class EpgProgrammesCompanion extends UpdateCompanion<EpgProgramme> {
  final Value<String> sourceId;
  final Value<String> channelKey;
  final Value<int> start;
  final Value<int> stop;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> rowid;
  const EpgProgrammesCompanion({
    this.sourceId = const Value.absent(),
    this.channelKey = const Value.absent(),
    this.start = const Value.absent(),
    this.stop = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EpgProgrammesCompanion.insert({
    required String sourceId,
    required String channelKey,
    required int start,
    required int stop,
    required String title,
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       channelKey = Value(channelKey),
       start = Value(start),
       stop = Value(stop),
       title = Value(title);
  static Insertable<EpgProgramme> custom({
    Expression<String>? sourceId,
    Expression<String>? channelKey,
    Expression<int>? start,
    Expression<int>? stop,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (channelKey != null) 'channel_key': channelKey,
      if (start != null) 'start': start,
      if (stop != null) 'stop': stop,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EpgProgrammesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? channelKey,
    Value<int>? start,
    Value<int>? stop,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return EpgProgrammesCompanion(
      sourceId: sourceId ?? this.sourceId,
      channelKey: channelKey ?? this.channelKey,
      start: start ?? this.start,
      stop: stop ?? this.stop,
      title: title ?? this.title,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (channelKey.present) {
      map['channel_key'] = Variable<String>(channelKey.value);
    }
    if (start.present) {
      map['start'] = Variable<int>(start.value);
    }
    if (stop.present) {
      map['stop'] = Variable<int>(stop.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpgProgrammesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('channelKey: $channelKey, ')
          ..write('start: $start, ')
          ..write('stop: $stop, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceStatusTable extends SourceStatus
    with TableInfo<$SourceStatusTable, SourceStatusRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRefreshMeta = const VerificationMeta(
    'lastRefresh',
  );
  @override
  late final GeneratedColumn<int> lastRefresh = GeneratedColumn<int>(
    'last_refresh',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _liveCountMeta = const VerificationMeta(
    'liveCount',
  );
  @override
  late final GeneratedColumn<int> liveCount = GeneratedColumn<int>(
    'live_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movieCountMeta = const VerificationMeta(
    'movieCount',
  );
  @override
  late final GeneratedColumn<int> movieCount = GeneratedColumn<int>(
    'movie_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seriesCountMeta = const VerificationMeta(
    'seriesCount',
  );
  @override
  late final GeneratedColumn<int> seriesCount = GeneratedColumn<int>(
    'series_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastEpgRefreshMeta = const VerificationMeta(
    'lastEpgRefresh',
  );
  @override
  late final GeneratedColumn<int> lastEpgRefresh = GeneratedColumn<int>(
    'last_epg_refresh',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _epgErrorMeta = const VerificationMeta(
    'epgError',
  );
  @override
  late final GeneratedColumn<String> epgError = GeneratedColumn<String>(
    'epg_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epgProgrammesMeta = const VerificationMeta(
    'epgProgrammes',
  );
  @override
  late final GeneratedColumn<int> epgProgrammes = GeneratedColumn<int>(
    'epg_programmes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accountJsonMeta = const VerificationMeta(
    'accountJson',
  );
  @override
  late final GeneratedColumn<String> accountJson = GeneratedColumn<String>(
    'account_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    lastRefresh,
    lastError,
    liveCount,
    movieCount,
    seriesCount,
    lastEpgRefresh,
    epgError,
    epgProgrammes,
    accountJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_status';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceStatusRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('last_refresh')) {
      context.handle(
        _lastRefreshMeta,
        lastRefresh.isAcceptableOrUnknown(
          data['last_refresh']!,
          _lastRefreshMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('live_count')) {
      context.handle(
        _liveCountMeta,
        liveCount.isAcceptableOrUnknown(data['live_count']!, _liveCountMeta),
      );
    }
    if (data.containsKey('movie_count')) {
      context.handle(
        _movieCountMeta,
        movieCount.isAcceptableOrUnknown(data['movie_count']!, _movieCountMeta),
      );
    }
    if (data.containsKey('series_count')) {
      context.handle(
        _seriesCountMeta,
        seriesCount.isAcceptableOrUnknown(
          data['series_count']!,
          _seriesCountMeta,
        ),
      );
    }
    if (data.containsKey('last_epg_refresh')) {
      context.handle(
        _lastEpgRefreshMeta,
        lastEpgRefresh.isAcceptableOrUnknown(
          data['last_epg_refresh']!,
          _lastEpgRefreshMeta,
        ),
      );
    }
    if (data.containsKey('epg_error')) {
      context.handle(
        _epgErrorMeta,
        epgError.isAcceptableOrUnknown(data['epg_error']!, _epgErrorMeta),
      );
    }
    if (data.containsKey('epg_programmes')) {
      context.handle(
        _epgProgrammesMeta,
        epgProgrammes.isAcceptableOrUnknown(
          data['epg_programmes']!,
          _epgProgrammesMeta,
        ),
      );
    }
    if (data.containsKey('account_json')) {
      context.handle(
        _accountJsonMeta,
        accountJson.isAcceptableOrUnknown(
          data['account_json']!,
          _accountJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId};
  @override
  SourceStatusRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceStatusRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      lastRefresh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_refresh'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      liveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}live_count'],
      )!,
      movieCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}movie_count'],
      )!,
      seriesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_count'],
      )!,
      lastEpgRefresh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_epg_refresh'],
      )!,
      epgError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epg_error'],
      ),
      epgProgrammes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}epg_programmes'],
      )!,
      accountJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_json'],
      ),
    );
  }

  @override
  $SourceStatusTable createAlias(String alias) {
    return $SourceStatusTable(attachedDatabase, alias);
  }
}

class SourceStatusRow extends DataClass implements Insertable<SourceStatusRow> {
  final String sourceId;
  final int lastRefresh;
  final String? lastError;
  final int liveCount;
  final int movieCount;
  final int seriesCount;
  final int lastEpgRefresh;
  final String? epgError;
  final int epgProgrammes;
  final String? accountJson;
  const SourceStatusRow({
    required this.sourceId,
    required this.lastRefresh,
    this.lastError,
    required this.liveCount,
    required this.movieCount,
    required this.seriesCount,
    required this.lastEpgRefresh,
    this.epgError,
    required this.epgProgrammes,
    this.accountJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['last_refresh'] = Variable<int>(lastRefresh);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['live_count'] = Variable<int>(liveCount);
    map['movie_count'] = Variable<int>(movieCount);
    map['series_count'] = Variable<int>(seriesCount);
    map['last_epg_refresh'] = Variable<int>(lastEpgRefresh);
    if (!nullToAbsent || epgError != null) {
      map['epg_error'] = Variable<String>(epgError);
    }
    map['epg_programmes'] = Variable<int>(epgProgrammes);
    if (!nullToAbsent || accountJson != null) {
      map['account_json'] = Variable<String>(accountJson);
    }
    return map;
  }

  SourceStatusCompanion toCompanion(bool nullToAbsent) {
    return SourceStatusCompanion(
      sourceId: Value(sourceId),
      lastRefresh: Value(lastRefresh),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      liveCount: Value(liveCount),
      movieCount: Value(movieCount),
      seriesCount: Value(seriesCount),
      lastEpgRefresh: Value(lastEpgRefresh),
      epgError: epgError == null && nullToAbsent
          ? const Value.absent()
          : Value(epgError),
      epgProgrammes: Value(epgProgrammes),
      accountJson: accountJson == null && nullToAbsent
          ? const Value.absent()
          : Value(accountJson),
    );
  }

  factory SourceStatusRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceStatusRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      lastRefresh: serializer.fromJson<int>(json['lastRefresh']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      liveCount: serializer.fromJson<int>(json['liveCount']),
      movieCount: serializer.fromJson<int>(json['movieCount']),
      seriesCount: serializer.fromJson<int>(json['seriesCount']),
      lastEpgRefresh: serializer.fromJson<int>(json['lastEpgRefresh']),
      epgError: serializer.fromJson<String?>(json['epgError']),
      epgProgrammes: serializer.fromJson<int>(json['epgProgrammes']),
      accountJson: serializer.fromJson<String?>(json['accountJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'lastRefresh': serializer.toJson<int>(lastRefresh),
      'lastError': serializer.toJson<String?>(lastError),
      'liveCount': serializer.toJson<int>(liveCount),
      'movieCount': serializer.toJson<int>(movieCount),
      'seriesCount': serializer.toJson<int>(seriesCount),
      'lastEpgRefresh': serializer.toJson<int>(lastEpgRefresh),
      'epgError': serializer.toJson<String?>(epgError),
      'epgProgrammes': serializer.toJson<int>(epgProgrammes),
      'accountJson': serializer.toJson<String?>(accountJson),
    };
  }

  SourceStatusRow copyWith({
    String? sourceId,
    int? lastRefresh,
    Value<String?> lastError = const Value.absent(),
    int? liveCount,
    int? movieCount,
    int? seriesCount,
    int? lastEpgRefresh,
    Value<String?> epgError = const Value.absent(),
    int? epgProgrammes,
    Value<String?> accountJson = const Value.absent(),
  }) => SourceStatusRow(
    sourceId: sourceId ?? this.sourceId,
    lastRefresh: lastRefresh ?? this.lastRefresh,
    lastError: lastError.present ? lastError.value : this.lastError,
    liveCount: liveCount ?? this.liveCount,
    movieCount: movieCount ?? this.movieCount,
    seriesCount: seriesCount ?? this.seriesCount,
    lastEpgRefresh: lastEpgRefresh ?? this.lastEpgRefresh,
    epgError: epgError.present ? epgError.value : this.epgError,
    epgProgrammes: epgProgrammes ?? this.epgProgrammes,
    accountJson: accountJson.present ? accountJson.value : this.accountJson,
  );
  SourceStatusRow copyWithCompanion(SourceStatusCompanion data) {
    return SourceStatusRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      lastRefresh: data.lastRefresh.present
          ? data.lastRefresh.value
          : this.lastRefresh,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      liveCount: data.liveCount.present ? data.liveCount.value : this.liveCount,
      movieCount: data.movieCount.present
          ? data.movieCount.value
          : this.movieCount,
      seriesCount: data.seriesCount.present
          ? data.seriesCount.value
          : this.seriesCount,
      lastEpgRefresh: data.lastEpgRefresh.present
          ? data.lastEpgRefresh.value
          : this.lastEpgRefresh,
      epgError: data.epgError.present ? data.epgError.value : this.epgError,
      epgProgrammes: data.epgProgrammes.present
          ? data.epgProgrammes.value
          : this.epgProgrammes,
      accountJson: data.accountJson.present
          ? data.accountJson.value
          : this.accountJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceStatusRow(')
          ..write('sourceId: $sourceId, ')
          ..write('lastRefresh: $lastRefresh, ')
          ..write('lastError: $lastError, ')
          ..write('liveCount: $liveCount, ')
          ..write('movieCount: $movieCount, ')
          ..write('seriesCount: $seriesCount, ')
          ..write('lastEpgRefresh: $lastEpgRefresh, ')
          ..write('epgError: $epgError, ')
          ..write('epgProgrammes: $epgProgrammes, ')
          ..write('accountJson: $accountJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    lastRefresh,
    lastError,
    liveCount,
    movieCount,
    seriesCount,
    lastEpgRefresh,
    epgError,
    epgProgrammes,
    accountJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceStatusRow &&
          other.sourceId == this.sourceId &&
          other.lastRefresh == this.lastRefresh &&
          other.lastError == this.lastError &&
          other.liveCount == this.liveCount &&
          other.movieCount == this.movieCount &&
          other.seriesCount == this.seriesCount &&
          other.lastEpgRefresh == this.lastEpgRefresh &&
          other.epgError == this.epgError &&
          other.epgProgrammes == this.epgProgrammes &&
          other.accountJson == this.accountJson);
}

class SourceStatusCompanion extends UpdateCompanion<SourceStatusRow> {
  final Value<String> sourceId;
  final Value<int> lastRefresh;
  final Value<String?> lastError;
  final Value<int> liveCount;
  final Value<int> movieCount;
  final Value<int> seriesCount;
  final Value<int> lastEpgRefresh;
  final Value<String?> epgError;
  final Value<int> epgProgrammes;
  final Value<String?> accountJson;
  final Value<int> rowid;
  const SourceStatusCompanion({
    this.sourceId = const Value.absent(),
    this.lastRefresh = const Value.absent(),
    this.lastError = const Value.absent(),
    this.liveCount = const Value.absent(),
    this.movieCount = const Value.absent(),
    this.seriesCount = const Value.absent(),
    this.lastEpgRefresh = const Value.absent(),
    this.epgError = const Value.absent(),
    this.epgProgrammes = const Value.absent(),
    this.accountJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceStatusCompanion.insert({
    required String sourceId,
    this.lastRefresh = const Value.absent(),
    this.lastError = const Value.absent(),
    this.liveCount = const Value.absent(),
    this.movieCount = const Value.absent(),
    this.seriesCount = const Value.absent(),
    this.lastEpgRefresh = const Value.absent(),
    this.epgError = const Value.absent(),
    this.epgProgrammes = const Value.absent(),
    this.accountJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId);
  static Insertable<SourceStatusRow> custom({
    Expression<String>? sourceId,
    Expression<int>? lastRefresh,
    Expression<String>? lastError,
    Expression<int>? liveCount,
    Expression<int>? movieCount,
    Expression<int>? seriesCount,
    Expression<int>? lastEpgRefresh,
    Expression<String>? epgError,
    Expression<int>? epgProgrammes,
    Expression<String>? accountJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (lastRefresh != null) 'last_refresh': lastRefresh,
      if (lastError != null) 'last_error': lastError,
      if (liveCount != null) 'live_count': liveCount,
      if (movieCount != null) 'movie_count': movieCount,
      if (seriesCount != null) 'series_count': seriesCount,
      if (lastEpgRefresh != null) 'last_epg_refresh': lastEpgRefresh,
      if (epgError != null) 'epg_error': epgError,
      if (epgProgrammes != null) 'epg_programmes': epgProgrammes,
      if (accountJson != null) 'account_json': accountJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceStatusCompanion copyWith({
    Value<String>? sourceId,
    Value<int>? lastRefresh,
    Value<String?>? lastError,
    Value<int>? liveCount,
    Value<int>? movieCount,
    Value<int>? seriesCount,
    Value<int>? lastEpgRefresh,
    Value<String?>? epgError,
    Value<int>? epgProgrammes,
    Value<String?>? accountJson,
    Value<int>? rowid,
  }) {
    return SourceStatusCompanion(
      sourceId: sourceId ?? this.sourceId,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      lastError: lastError ?? this.lastError,
      liveCount: liveCount ?? this.liveCount,
      movieCount: movieCount ?? this.movieCount,
      seriesCount: seriesCount ?? this.seriesCount,
      lastEpgRefresh: lastEpgRefresh ?? this.lastEpgRefresh,
      epgError: epgError ?? this.epgError,
      epgProgrammes: epgProgrammes ?? this.epgProgrammes,
      accountJson: accountJson ?? this.accountJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (lastRefresh.present) {
      map['last_refresh'] = Variable<int>(lastRefresh.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (liveCount.present) {
      map['live_count'] = Variable<int>(liveCount.value);
    }
    if (movieCount.present) {
      map['movie_count'] = Variable<int>(movieCount.value);
    }
    if (seriesCount.present) {
      map['series_count'] = Variable<int>(seriesCount.value);
    }
    if (lastEpgRefresh.present) {
      map['last_epg_refresh'] = Variable<int>(lastEpgRefresh.value);
    }
    if (epgError.present) {
      map['epg_error'] = Variable<String>(epgError.value);
    }
    if (epgProgrammes.present) {
      map['epg_programmes'] = Variable<int>(epgProgrammes.value);
    }
    if (accountJson.present) {
      map['account_json'] = Variable<String>(accountJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceStatusCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('lastRefresh: $lastRefresh, ')
          ..write('lastError: $lastError, ')
          ..write('liveCount: $liveCount, ')
          ..write('movieCount: $movieCount, ')
          ..write('seriesCount: $seriesCount, ')
          ..write('lastEpgRefresh: $lastEpgRefresh, ')
          ..write('epgError: $epgError, ')
          ..write('epgProgrammes: $epgProgrammes, ')
          ..write('accountJson: $accountJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourcesTable extends Sources with TableInfo<$SourcesTable, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverMeta = const VerificationMeta('server');
  @override
  late final GeneratedColumn<String> server = GeneratedColumn<String>(
    'server',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _macMeta = const VerificationMeta('mac');
  @override
  late final GeneratedColumn<String> mac = GeneratedColumn<String>(
    'mac',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epgUrlMeta = const VerificationMeta('epgUrl');
  @override
  late final GeneratedColumn<String> epgUrl = GeneratedColumn<String>(
    'epg_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _epgEnabledMeta = const VerificationMeta(
    'epgEnabled',
  );
  @override
  late final GeneratedColumn<bool> epgEnabled = GeneratedColumn<bool>(
    'epg_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("epg_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _epgRefreshHoursMeta = const VerificationMeta(
    'epgRefreshHours',
  );
  @override
  late final GeneratedColumn<int> epgRefreshHours = GeneratedColumn<int>(
    'epg_refresh_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(24),
  );
  static const VerificationMeta _epgOffsetMinMeta = const VerificationMeta(
    'epgOffsetMin',
  );
  @override
  late final GeneratedColumn<int> epgOffsetMin = GeneratedColumn<int>(
    'epg_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refreshHoursMeta = const VerificationMeta(
    'refreshHours',
  );
  @override
  late final GeneratedColumn<int> refreshHours = GeneratedColumn<int>(
    'refresh_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    name,
    kind,
    url,
    filePath,
    server,
    username,
    password,
    mac,
    epgUrl,
    epgEnabled,
    epgRefreshHours,
    epgOffsetMin,
    refreshHours,
    position,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Source> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('server')) {
      context.handle(
        _serverMeta,
        server.isAcceptableOrUnknown(data['server']!, _serverMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    }
    if (data.containsKey('mac')) {
      context.handle(
        _macMeta,
        mac.isAcceptableOrUnknown(data['mac']!, _macMeta),
      );
    }
    if (data.containsKey('epg_url')) {
      context.handle(
        _epgUrlMeta,
        epgUrl.isAcceptableOrUnknown(data['epg_url']!, _epgUrlMeta),
      );
    }
    if (data.containsKey('epg_enabled')) {
      context.handle(
        _epgEnabledMeta,
        epgEnabled.isAcceptableOrUnknown(data['epg_enabled']!, _epgEnabledMeta),
      );
    }
    if (data.containsKey('epg_refresh_hours')) {
      context.handle(
        _epgRefreshHoursMeta,
        epgRefreshHours.isAcceptableOrUnknown(
          data['epg_refresh_hours']!,
          _epgRefreshHoursMeta,
        ),
      );
    }
    if (data.containsKey('epg_offset_min')) {
      context.handle(
        _epgOffsetMinMeta,
        epgOffsetMin.isAcceptableOrUnknown(
          data['epg_offset_min']!,
          _epgOffsetMinMeta,
        ),
      );
    }
    if (data.containsKey('refresh_hours')) {
      context.handle(
        _refreshHoursMeta,
        refreshHours.isAcceptableOrUnknown(
          data['refresh_hours']!,
          _refreshHoursMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      server: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server'],
      ),
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      ),
      mac: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mac'],
      ),
      epgUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epg_url'],
      ),
      epgEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}epg_enabled'],
      )!,
      epgRefreshHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}epg_refresh_hours'],
      )!,
      epgOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}epg_offset_min'],
      )!,
      refreshHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refresh_hours'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class Source extends DataClass implements Insertable<Source> {
  final String hlc;
  final bool deleted;
  final String id;
  final String name;
  final String kind;
  final String? url;
  final String? filePath;
  final String? server;
  final String? username;
  final String? password;
  final String? mac;
  final String? epgUrl;
  final bool epgEnabled;
  final int epgRefreshHours;
  final int epgOffsetMin;
  final int refreshHours;
  final int position;
  final int createdAt;
  const Source({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.name,
    required this.kind,
    this.url,
    this.filePath,
    this.server,
    this.username,
    this.password,
    this.mac,
    this.epgUrl,
    required this.epgEnabled,
    required this.epgRefreshHours,
    required this.epgOffsetMin,
    required this.refreshHours,
    required this.position,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || server != null) {
      map['server'] = Variable<String>(server);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || mac != null) {
      map['mac'] = Variable<String>(mac);
    }
    if (!nullToAbsent || epgUrl != null) {
      map['epg_url'] = Variable<String>(epgUrl);
    }
    map['epg_enabled'] = Variable<bool>(epgEnabled);
    map['epg_refresh_hours'] = Variable<int>(epgRefreshHours);
    map['epg_offset_min'] = Variable<int>(epgOffsetMin);
    map['refresh_hours'] = Variable<int>(refreshHours);
    map['position'] = Variable<int>(position);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      server: server == null && nullToAbsent
          ? const Value.absent()
          : Value(server),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      mac: mac == null && nullToAbsent ? const Value.absent() : Value(mac),
      epgUrl: epgUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(epgUrl),
      epgEnabled: Value(epgEnabled),
      epgRefreshHours: Value(epgRefreshHours),
      epgOffsetMin: Value(epgOffsetMin),
      refreshHours: Value(refreshHours),
      position: Value(position),
      createdAt: Value(createdAt),
    );
  }

  factory Source.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      url: serializer.fromJson<String?>(json['url']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      server: serializer.fromJson<String?>(json['server']),
      username: serializer.fromJson<String?>(json['username']),
      password: serializer.fromJson<String?>(json['password']),
      mac: serializer.fromJson<String?>(json['mac']),
      epgUrl: serializer.fromJson<String?>(json['epgUrl']),
      epgEnabled: serializer.fromJson<bool>(json['epgEnabled']),
      epgRefreshHours: serializer.fromJson<int>(json['epgRefreshHours']),
      epgOffsetMin: serializer.fromJson<int>(json['epgOffsetMin']),
      refreshHours: serializer.fromJson<int>(json['refreshHours']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'url': serializer.toJson<String?>(url),
      'filePath': serializer.toJson<String?>(filePath),
      'server': serializer.toJson<String?>(server),
      'username': serializer.toJson<String?>(username),
      'password': serializer.toJson<String?>(password),
      'mac': serializer.toJson<String?>(mac),
      'epgUrl': serializer.toJson<String?>(epgUrl),
      'epgEnabled': serializer.toJson<bool>(epgEnabled),
      'epgRefreshHours': serializer.toJson<int>(epgRefreshHours),
      'epgOffsetMin': serializer.toJson<int>(epgOffsetMin),
      'refreshHours': serializer.toJson<int>(refreshHours),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Source copyWith({
    String? hlc,
    bool? deleted,
    String? id,
    String? name,
    String? kind,
    Value<String?> url = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<String?> server = const Value.absent(),
    Value<String?> username = const Value.absent(),
    Value<String?> password = const Value.absent(),
    Value<String?> mac = const Value.absent(),
    Value<String?> epgUrl = const Value.absent(),
    bool? epgEnabled,
    int? epgRefreshHours,
    int? epgOffsetMin,
    int? refreshHours,
    int? position,
    int? createdAt,
  }) => Source(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    url: url.present ? url.value : this.url,
    filePath: filePath.present ? filePath.value : this.filePath,
    server: server.present ? server.value : this.server,
    username: username.present ? username.value : this.username,
    password: password.present ? password.value : this.password,
    mac: mac.present ? mac.value : this.mac,
    epgUrl: epgUrl.present ? epgUrl.value : this.epgUrl,
    epgEnabled: epgEnabled ?? this.epgEnabled,
    epgRefreshHours: epgRefreshHours ?? this.epgRefreshHours,
    epgOffsetMin: epgOffsetMin ?? this.epgOffsetMin,
    refreshHours: refreshHours ?? this.refreshHours,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
  );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      url: data.url.present ? data.url.value : this.url,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      server: data.server.present ? data.server.value : this.server,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      mac: data.mac.present ? data.mac.value : this.mac,
      epgUrl: data.epgUrl.present ? data.epgUrl.value : this.epgUrl,
      epgEnabled: data.epgEnabled.present
          ? data.epgEnabled.value
          : this.epgEnabled,
      epgRefreshHours: data.epgRefreshHours.present
          ? data.epgRefreshHours.value
          : this.epgRefreshHours,
      epgOffsetMin: data.epgOffsetMin.present
          ? data.epgOffsetMin.value
          : this.epgOffsetMin,
      refreshHours: data.refreshHours.present
          ? data.refreshHours.value
          : this.refreshHours,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('server: $server, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('mac: $mac, ')
          ..write('epgUrl: $epgUrl, ')
          ..write('epgEnabled: $epgEnabled, ')
          ..write('epgRefreshHours: $epgRefreshHours, ')
          ..write('epgOffsetMin: $epgOffsetMin, ')
          ..write('refreshHours: $refreshHours, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    hlc,
    deleted,
    id,
    name,
    kind,
    url,
    filePath,
    server,
    username,
    password,
    mac,
    epgUrl,
    epgEnabled,
    epgRefreshHours,
    epgOffsetMin,
    refreshHours,
    position,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.url == this.url &&
          other.filePath == this.filePath &&
          other.server == this.server &&
          other.username == this.username &&
          other.password == this.password &&
          other.mac == this.mac &&
          other.epgUrl == this.epgUrl &&
          other.epgEnabled == this.epgEnabled &&
          other.epgRefreshHours == this.epgRefreshHours &&
          other.epgOffsetMin == this.epgOffsetMin &&
          other.refreshHours == this.refreshHours &&
          other.position == this.position &&
          other.createdAt == this.createdAt);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> url;
  final Value<String?> filePath;
  final Value<String?> server;
  final Value<String?> username;
  final Value<String?> password;
  final Value<String?> mac;
  final Value<String?> epgUrl;
  final Value<bool> epgEnabled;
  final Value<int> epgRefreshHours;
  final Value<int> epgOffsetMin;
  final Value<int> refreshHours;
  final Value<int> position;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SourcesCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.url = const Value.absent(),
    this.filePath = const Value.absent(),
    this.server = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.mac = const Value.absent(),
    this.epgUrl = const Value.absent(),
    this.epgEnabled = const Value.absent(),
    this.epgRefreshHours = const Value.absent(),
    this.epgOffsetMin = const Value.absent(),
    this.refreshHours = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcesCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String id,
    required String name,
    required String kind,
    this.url = const Value.absent(),
    this.filePath = const Value.absent(),
    this.server = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.mac = const Value.absent(),
    this.epgUrl = const Value.absent(),
    this.epgEnabled = const Value.absent(),
    this.epgRefreshHours = const Value.absent(),
    this.epgOffsetMin = const Value.absent(),
    this.refreshHours = const Value.absent(),
    this.position = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       name = Value(name),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Source> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? url,
    Expression<String>? filePath,
    Expression<String>? server,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? mac,
    Expression<String>? epgUrl,
    Expression<bool>? epgEnabled,
    Expression<int>? epgRefreshHours,
    Expression<int>? epgOffsetMin,
    Expression<int>? refreshHours,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (url != null) 'url': url,
      if (filePath != null) 'file_path': filePath,
      if (server != null) 'server': server,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (mac != null) 'mac': mac,
      if (epgUrl != null) 'epg_url': epgUrl,
      if (epgEnabled != null) 'epg_enabled': epgEnabled,
      if (epgRefreshHours != null) 'epg_refresh_hours': epgRefreshHours,
      if (epgOffsetMin != null) 'epg_offset_min': epgOffsetMin,
      if (refreshHours != null) 'refresh_hours': refreshHours,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcesCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? url,
    Value<String?>? filePath,
    Value<String?>? server,
    Value<String?>? username,
    Value<String?>? password,
    Value<String?>? mac,
    Value<String?>? epgUrl,
    Value<bool>? epgEnabled,
    Value<int>? epgRefreshHours,
    Value<int>? epgOffsetMin,
    Value<int>? refreshHours,
    Value<int>? position,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SourcesCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      server: server ?? this.server,
      username: username ?? this.username,
      password: password ?? this.password,
      mac: mac ?? this.mac,
      epgUrl: epgUrl ?? this.epgUrl,
      epgEnabled: epgEnabled ?? this.epgEnabled,
      epgRefreshHours: epgRefreshHours ?? this.epgRefreshHours,
      epgOffsetMin: epgOffsetMin ?? this.epgOffsetMin,
      refreshHours: refreshHours ?? this.refreshHours,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (server.present) {
      map['server'] = Variable<String>(server.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (mac.present) {
      map['mac'] = Variable<String>(mac.value);
    }
    if (epgUrl.present) {
      map['epg_url'] = Variable<String>(epgUrl.value);
    }
    if (epgEnabled.present) {
      map['epg_enabled'] = Variable<bool>(epgEnabled.value);
    }
    if (epgRefreshHours.present) {
      map['epg_refresh_hours'] = Variable<int>(epgRefreshHours.value);
    }
    if (epgOffsetMin.present) {
      map['epg_offset_min'] = Variable<int>(epgOffsetMin.value);
    }
    if (refreshHours.present) {
      map['refresh_hours'] = Variable<int>(refreshHours.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('server: $server, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('mac: $mac, ')
          ..write('epgUrl: $epgUrl, ')
          ..write('epgEnabled: $epgEnabled, ')
          ..write('epgRefreshHours: $epgRefreshHours, ')
          ..write('epgOffsetMin: $epgOffsetMin, ')
          ..write('refreshHours: $refreshHours, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    sourceId,
    type,
    itemId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Favorite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, type, itemId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String hlc;
  final bool deleted;
  final String sourceId;
  final String type;
  final String itemId;
  final double position;
  const Favorite({
    required this.hlc,
    required this.deleted,
    required this.sourceId,
    required this.type,
    required this.itemId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['item_id'] = Variable<String>(itemId);
    map['position'] = Variable<double>(position);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      sourceId: Value(sourceId),
      type: Value(type),
      itemId: Value(itemId),
      position: Value(position),
    );
  }

  factory Favorite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      itemId: serializer.fromJson<String>(json['itemId']),
      position: serializer.fromJson<double>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'itemId': serializer.toJson<String>(itemId),
      'position': serializer.toJson<double>(position),
    };
  }

  Favorite copyWith({
    String? hlc,
    bool? deleted,
    String? sourceId,
    String? type,
    String? itemId,
    double? position,
  }) => Favorite(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    itemId: itemId ?? this.itemId,
    position: position ?? this.position,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, sourceId, type, itemId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.itemId == this.itemId &&
          other.position == this.position);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> itemId;
  final Value<double> position;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.itemId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String sourceId,
    required String type,
    required String itemId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       sourceId = Value(sourceId),
       type = Value(type),
       itemId = Value(itemId);
  static Insertable<Favorite> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? itemId,
    Expression<double>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (itemId != null) 'item_id': itemId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? itemId,
    Value<double>? position,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserGroupsTable extends UserGroups
    with TableInfo<$UserGroupsTable, UserGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    sourceId,
    type,
    name,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGroup(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $UserGroupsTable createAlias(String alias) {
    return $UserGroupsTable(attachedDatabase, alias);
  }
}

class UserGroup extends DataClass implements Insertable<UserGroup> {
  final String hlc;
  final bool deleted;
  final String id;
  final String sourceId;
  final String type;
  final String name;
  final double position;
  const UserGroup({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.sourceId,
    required this.type,
    required this.name,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<double>(position);
    return map;
  }

  UserGroupsCompanion toCompanion(bool nullToAbsent) {
    return UserGroupsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      sourceId: Value(sourceId),
      type: Value(type),
      name: Value(name),
      position: Value(position),
    );
  }

  factory UserGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGroup(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<double>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<double>(position),
    };
  }

  UserGroup copyWith({
    String? hlc,
    bool? deleted,
    String? id,
    String? sourceId,
    String? type,
    String? name,
    double? position,
  }) => UserGroup(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    name: name ?? this.name,
    position: position ?? this.position,
  );
  UserGroup copyWithCompanion(UserGroupsCompanion data) {
    return UserGroup(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGroup(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, id, sourceId, type, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGroup &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.name == this.name &&
          other.position == this.position);
}

class UserGroupsCompanion extends UpdateCompanion<UserGroup> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> name;
  final Value<double> position;
  final Value<int> rowid;
  const UserGroupsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserGroupsCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String id,
    required String sourceId,
    required String type,
    required String name,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       sourceId = Value(sourceId),
       type = Value(type),
       name = Value(name);
  static Insertable<UserGroup> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<double>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserGroupsCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? name,
    Value<double>? position,
    Value<int>? rowid,
  }) {
    return UserGroupsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      name: name ?? this.name,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGroupsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupItemsTable extends GroupItems
    with TableInfo<$GroupItemsTable, GroupItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    groupId,
    itemId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, itemId};
  @override
  GroupItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupItem(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $GroupItemsTable createAlias(String alias) {
    return $GroupItemsTable(attachedDatabase, alias);
  }
}

class GroupItem extends DataClass implements Insertable<GroupItem> {
  final String hlc;
  final bool deleted;
  final String groupId;
  final String itemId;
  final double position;
  const GroupItem({
    required this.hlc,
    required this.deleted,
    required this.groupId,
    required this.itemId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['group_id'] = Variable<String>(groupId);
    map['item_id'] = Variable<String>(itemId);
    map['position'] = Variable<double>(position);
    return map;
  }

  GroupItemsCompanion toCompanion(bool nullToAbsent) {
    return GroupItemsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      groupId: Value(groupId),
      itemId: Value(itemId),
      position: Value(position),
    );
  }

  factory GroupItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupItem(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      groupId: serializer.fromJson<String>(json['groupId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      position: serializer.fromJson<double>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'groupId': serializer.toJson<String>(groupId),
      'itemId': serializer.toJson<String>(itemId),
      'position': serializer.toJson<double>(position),
    };
  }

  GroupItem copyWith({
    String? hlc,
    bool? deleted,
    String? groupId,
    String? itemId,
    double? position,
  }) => GroupItem(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    groupId: groupId ?? this.groupId,
    itemId: itemId ?? this.itemId,
    position: position ?? this.position,
  );
  GroupItem copyWithCompanion(GroupItemsCompanion data) {
    return GroupItem(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupItem(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('groupId: $groupId, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, groupId, itemId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupItem &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.groupId == this.groupId &&
          other.itemId == this.itemId &&
          other.position == this.position);
}

class GroupItemsCompanion extends UpdateCompanion<GroupItem> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> groupId;
  final Value<String> itemId;
  final Value<double> position;
  final Value<int> rowid;
  const GroupItemsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.groupId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupItemsCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String groupId,
    required String itemId,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       groupId = Value(groupId),
       itemId = Value(itemId);
  static Insertable<GroupItem> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? groupId,
    Expression<String>? itemId,
    Expression<double>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (groupId != null) 'group_id': groupId,
      if (itemId != null) 'item_id': itemId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupItemsCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? groupId,
    Value<String>? itemId,
    Value<double>? position,
    Value<int>? rowid,
  }) {
    return GroupItemsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      groupId: groupId ?? this.groupId,
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupItemsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('groupId: $groupId, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HiddenTable extends Hidden with TableInfo<$HiddenTable, HiddenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HiddenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    sourceId,
    type,
    kind,
    refId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hidden';
  @override
  VerificationContext validateIntegrity(
    Insertable<HiddenRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, type, kind, refId};
  @override
  HiddenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HiddenRow(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      )!,
    );
  }

  @override
  $HiddenTable createAlias(String alias) {
    return $HiddenTable(attachedDatabase, alias);
  }
}

class HiddenRow extends DataClass implements Insertable<HiddenRow> {
  final String hlc;
  final bool deleted;
  final String sourceId;
  final String type;
  final String kind;
  final String refId;
  const HiddenRow({
    required this.hlc,
    required this.deleted,
    required this.sourceId,
    required this.type,
    required this.kind,
    required this.refId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['kind'] = Variable<String>(kind);
    map['ref_id'] = Variable<String>(refId);
    return map;
  }

  HiddenCompanion toCompanion(bool nullToAbsent) {
    return HiddenCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      sourceId: Value(sourceId),
      type: Value(type),
      kind: Value(kind),
      refId: Value(refId),
    );
  }

  factory HiddenRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HiddenRow(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      kind: serializer.fromJson<String>(json['kind']),
      refId: serializer.fromJson<String>(json['refId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'kind': serializer.toJson<String>(kind),
      'refId': serializer.toJson<String>(refId),
    };
  }

  HiddenRow copyWith({
    String? hlc,
    bool? deleted,
    String? sourceId,
    String? type,
    String? kind,
    String? refId,
  }) => HiddenRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    kind: kind ?? this.kind,
    refId: refId ?? this.refId,
  );
  HiddenRow copyWithCompanion(HiddenCompanion data) {
    return HiddenRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      kind: data.kind.present ? data.kind.value : this.kind,
      refId: data.refId.present ? data.refId.value : this.refId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HiddenRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('kind: $kind, ')
          ..write('refId: $refId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, sourceId, type, kind, refId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HiddenRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.kind == this.kind &&
          other.refId == this.refId);
}

class HiddenCompanion extends UpdateCompanion<HiddenRow> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> kind;
  final Value<String> refId;
  final Value<int> rowid;
  const HiddenCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.kind = const Value.absent(),
    this.refId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HiddenCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String sourceId,
    required String type,
    required String kind,
    required String refId,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       sourceId = Value(sourceId),
       type = Value(type),
       kind = Value(kind),
       refId = Value(refId);
  static Insertable<HiddenRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? kind,
    Expression<String>? refId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (kind != null) 'kind': kind,
      if (refId != null) 'ref_id': refId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HiddenCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? kind,
    Value<String>? refId,
    Value<int>? rowid,
  }) {
    return HiddenCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      kind: kind ?? this.kind,
      refId: refId ?? this.refId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HiddenCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('kind: $kind, ')
          ..write('refId: $refId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryOrderTable extends CategoryOrder
    with TableInfo<$CategoryOrderTable, CategoryOrderData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryOrderTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    sourceId,
    type,
    categoryId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_order';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryOrderData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, type, categoryId};
  @override
  CategoryOrderData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryOrderData(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CategoryOrderTable createAlias(String alias) {
    return $CategoryOrderTable(attachedDatabase, alias);
  }
}

class CategoryOrderData extends DataClass
    implements Insertable<CategoryOrderData> {
  final String hlc;
  final bool deleted;
  final String sourceId;
  final String type;
  final String categoryId;
  final double position;
  const CategoryOrderData({
    required this.hlc,
    required this.deleted,
    required this.sourceId,
    required this.type,
    required this.categoryId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['category_id'] = Variable<String>(categoryId);
    map['position'] = Variable<double>(position);
    return map;
  }

  CategoryOrderCompanion toCompanion(bool nullToAbsent) {
    return CategoryOrderCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      sourceId: Value(sourceId),
      type: Value(type),
      categoryId: Value(categoryId),
      position: Value(position),
    );
  }

  factory CategoryOrderData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryOrderData(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      position: serializer.fromJson<double>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<String>(categoryId),
      'position': serializer.toJson<double>(position),
    };
  }

  CategoryOrderData copyWith({
    String? hlc,
    bool? deleted,
    String? sourceId,
    String? type,
    String? categoryId,
    double? position,
  }) => CategoryOrderData(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    position: position ?? this.position,
  );
  CategoryOrderData copyWithCompanion(CategoryOrderCompanion data) {
    return CategoryOrderData(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryOrderData(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, sourceId, type, categoryId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryOrderData &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.position == this.position);
}

class CategoryOrderCompanion extends UpdateCompanion<CategoryOrderData> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> categoryId;
  final Value<double> position;
  final Value<int> rowid;
  const CategoryOrderCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryOrderCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String sourceId,
    required String type,
    required String categoryId,
    required double position,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       sourceId = Value(sourceId),
       type = Value(type),
       categoryId = Value(categoryId),
       position = Value(position);
  static Insertable<CategoryOrderData> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<double>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryOrderCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? categoryId,
    Value<double>? position,
    Value<int>? rowid,
  }) {
    return CategoryOrderCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryOrderCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchStateTable extends WatchState
    with TableInfo<$WatchStateTable, WatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeMeta = const VerificationMeta(
    'episode',
  );
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
    'episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<int> watchedAt = GeneratedColumn<int>(
    'watched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedMeta = const VerificationMeta(
    'finished',
  );
  @override
  late final GeneratedColumn<bool> finished = GeneratedColumn<bool>(
    'finished',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("finished" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    sourceId,
    type,
    itemId,
    seriesId,
    name,
    icon,
    season,
    episode,
    positionMs,
    durationMs,
    watchedAt,
    finished,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('episode')) {
      context.handle(
        _episodeMeta,
        episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_watchedAtMeta);
    }
    if (data.containsKey('finished')) {
      context.handle(
        _finishedMeta,
        finished.isAcceptableOrUnknown(data['finished']!, _finishedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, type, itemId};
  @override
  WatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchRow(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      ),
      episode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode'],
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watched_at'],
      )!,
      finished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}finished'],
      )!,
    );
  }

  @override
  $WatchStateTable createAlias(String alias) {
    return $WatchStateTable(attachedDatabase, alias);
  }
}

class WatchRow extends DataClass implements Insertable<WatchRow> {
  final String hlc;
  final bool deleted;
  final String sourceId;
  final String type;
  final String itemId;
  final String? seriesId;
  final String name;
  final String? icon;
  final int? season;
  final int? episode;
  final int positionMs;
  final int durationMs;
  final int watchedAt;
  final bool finished;
  const WatchRow({
    required this.hlc,
    required this.deleted,
    required this.sourceId,
    required this.type,
    required this.itemId,
    this.seriesId,
    required this.name,
    this.icon,
    this.season,
    this.episode,
    required this.positionMs,
    required this.durationMs,
    required this.watchedAt,
    required this.finished,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['source_id'] = Variable<String>(sourceId);
    map['type'] = Variable<String>(type);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    if (!nullToAbsent || episode != null) {
      map['episode'] = Variable<int>(episode);
    }
    map['position_ms'] = Variable<int>(positionMs);
    map['duration_ms'] = Variable<int>(durationMs);
    map['watched_at'] = Variable<int>(watchedAt);
    map['finished'] = Variable<bool>(finished);
    return map;
  }

  WatchStateCompanion toCompanion(bool nullToAbsent) {
    return WatchStateCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      sourceId: Value(sourceId),
      type: Value(type),
      itemId: Value(itemId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      episode: episode == null && nullToAbsent
          ? const Value.absent()
          : Value(episode),
      positionMs: Value(positionMs),
      durationMs: Value(durationMs),
      watchedAt: Value(watchedAt),
      finished: Value(finished),
    );
  }

  factory WatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchRow(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      type: serializer.fromJson<String>(json['type']),
      itemId: serializer.fromJson<String>(json['itemId']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      season: serializer.fromJson<int?>(json['season']),
      episode: serializer.fromJson<int?>(json['episode']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      watchedAt: serializer.fromJson<int>(json['watchedAt']),
      finished: serializer.fromJson<bool>(json['finished']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'sourceId': serializer.toJson<String>(sourceId),
      'type': serializer.toJson<String>(type),
      'itemId': serializer.toJson<String>(itemId),
      'seriesId': serializer.toJson<String?>(seriesId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'season': serializer.toJson<int?>(season),
      'episode': serializer.toJson<int?>(episode),
      'positionMs': serializer.toJson<int>(positionMs),
      'durationMs': serializer.toJson<int>(durationMs),
      'watchedAt': serializer.toJson<int>(watchedAt),
      'finished': serializer.toJson<bool>(finished),
    };
  }

  WatchRow copyWith({
    String? hlc,
    bool? deleted,
    String? sourceId,
    String? type,
    String? itemId,
    Value<String?> seriesId = const Value.absent(),
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<int?> season = const Value.absent(),
    Value<int?> episode = const Value.absent(),
    int? positionMs,
    int? durationMs,
    int? watchedAt,
    bool? finished,
  }) => WatchRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    sourceId: sourceId ?? this.sourceId,
    type: type ?? this.type,
    itemId: itemId ?? this.itemId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    season: season.present ? season.value : this.season,
    episode: episode.present ? episode.value : this.episode,
    positionMs: positionMs ?? this.positionMs,
    durationMs: durationMs ?? this.durationMs,
    watchedAt: watchedAt ?? this.watchedAt,
    finished: finished ?? this.finished,
  );
  WatchRow copyWithCompanion(WatchStateCompanion data) {
    return WatchRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      type: data.type.present ? data.type.value : this.type,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      season: data.season.present ? data.season.value : this.season,
      episode: data.episode.present ? data.episode.value : this.episode,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
      finished: data.finished.present ? data.finished.value : this.finished,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('seriesId: $seriesId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('finished: $finished')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    hlc,
    deleted,
    sourceId,
    type,
    itemId,
    seriesId,
    name,
    icon,
    season,
    episode,
    positionMs,
    durationMs,
    watchedAt,
    finished,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.sourceId == this.sourceId &&
          other.type == this.type &&
          other.itemId == this.itemId &&
          other.seriesId == this.seriesId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.season == this.season &&
          other.episode == this.episode &&
          other.positionMs == this.positionMs &&
          other.durationMs == this.durationMs &&
          other.watchedAt == this.watchedAt &&
          other.finished == this.finished);
}

class WatchStateCompanion extends UpdateCompanion<WatchRow> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> sourceId;
  final Value<String> type;
  final Value<String> itemId;
  final Value<String?> seriesId;
  final Value<String> name;
  final Value<String?> icon;
  final Value<int?> season;
  final Value<int?> episode;
  final Value<int> positionMs;
  final Value<int> durationMs;
  final Value<int> watchedAt;
  final Value<bool> finished;
  final Value<int> rowid;
  const WatchStateCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.type = const Value.absent(),
    this.itemId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.finished = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchStateCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String sourceId,
    required String type,
    required String itemId,
    this.seriesId = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.season = const Value.absent(),
    this.episode = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int watchedAt,
    this.finished = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       sourceId = Value(sourceId),
       type = Value(type),
       itemId = Value(itemId),
       name = Value(name),
       watchedAt = Value(watchedAt);
  static Insertable<WatchRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? sourceId,
    Expression<String>? type,
    Expression<String>? itemId,
    Expression<String>? seriesId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? season,
    Expression<int>? episode,
    Expression<int>? positionMs,
    Expression<int>? durationMs,
    Expression<int>? watchedAt,
    Expression<bool>? finished,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (sourceId != null) 'source_id': sourceId,
      if (type != null) 'type': type,
      if (itemId != null) 'item_id': itemId,
      if (seriesId != null) 'series_id': seriesId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (season != null) 'season': season,
      if (episode != null) 'episode': episode,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (watchedAt != null) 'watched_at': watchedAt,
      if (finished != null) 'finished': finished,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchStateCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? sourceId,
    Value<String>? type,
    Value<String>? itemId,
    Value<String?>? seriesId,
    Value<String>? name,
    Value<String?>? icon,
    Value<int?>? season,
    Value<int?>? episode,
    Value<int>? positionMs,
    Value<int>? durationMs,
    Value<int>? watchedAt,
    Value<bool>? finished,
    Value<int>? rowid,
  }) {
    return WatchStateCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      sourceId: sourceId ?? this.sourceId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      season: season ?? this.season,
      episode: episode ?? this.episode,
      positionMs: positionMs ?? this.positionMs,
      durationMs: durationMs ?? this.durationMs,
      watchedAt: watchedAt ?? this.watchedAt,
      finished: finished ?? this.finished,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<int>(watchedAt.value);
    }
    if (finished.present) {
      map['finished'] = Variable<bool>(finished.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchStateCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('sourceId: $sourceId, ')
          ..write('type: $type, ')
          ..write('itemId: $itemId, ')
          ..write('seriesId: $seriesId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('season: $season, ')
          ..write('episode: $episode, ')
          ..write('positionMs: $positionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('finished: $finished, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrefsTable extends Prefs with TableInfo<$PrefsTable, Pref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hlc, deleted, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Pref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pref(
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PrefsTable createAlias(String alias) {
    return $PrefsTable(attachedDatabase, alias);
  }
}

class Pref extends DataClass implements Insertable<Pref> {
  final String hlc;
  final bool deleted;
  final String key;
  final String value;
  const Pref({
    required this.hlc,
    required this.deleted,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hlc'] = Variable<String>(hlc);
    map['deleted'] = Variable<bool>(deleted);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PrefsCompanion toCompanion(bool nullToAbsent) {
    return PrefsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      key: Value(key),
      value: Value(value),
    );
  }

  factory Pref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pref(
      hlc: serializer.fromJson<String>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<String>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Pref copyWith({String? hlc, bool? deleted, String? key, String? value}) =>
      Pref(
        hlc: hlc ?? this.hlc,
        deleted: deleted ?? this.deleted,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Pref copyWithCompanion(PrefsCompanion data) {
    return Pref(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pref(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pref &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.key == this.key &&
          other.value == this.value);
}

class PrefsCompanion extends UpdateCompanion<Pref> {
  final Value<String> hlc;
  final Value<bool> deleted;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PrefsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrefsCompanion.insert({
    required String hlc,
    this.deleted = const Value.absent(),
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       key = Value(key),
       value = Value(value);
  static Insertable<Pref> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrefsCompanion copyWith({
    Value<String>? hlc,
    Value<bool>? deleted,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PrefsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrefsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $SeriesCacheTable seriesCache = $SeriesCacheTable(this);
  late final $MetaCacheTable metaCache = $MetaCacheTable(this);
  late final $EpgChannelsTable epgChannels = $EpgChannelsTable(this);
  late final $EpgProgrammesTable epgProgrammes = $EpgProgrammesTable(this);
  late final $SourceStatusTable sourceStatus = $SourceStatusTable(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $UserGroupsTable userGroups = $UserGroupsTable(this);
  late final $GroupItemsTable groupItems = $GroupItemsTable(this);
  late final $HiddenTable hidden = $HiddenTable(this);
  late final $CategoryOrderTable categoryOrder = $CategoryOrderTable(this);
  late final $WatchStateTable watchState = $WatchStateTable(this);
  late final $PrefsTable prefs = $PrefsTable(this);
  late final Index idxCategoriesSrc = Index(
    'idx_categories_src',
    'CREATE INDEX idx_categories_src ON categories (source_id, type)',
  );
  late final Index idxItemsCat = Index(
    'idx_items_cat',
    'CREATE INDEX idx_items_cat ON items (source_id, type, category_id)',
  );
  late final Index idxItemsName = Index(
    'idx_items_name',
    'CREATE INDEX idx_items_name ON items (source_id, type, name_norm)',
  );
  late final Index idxItemsEpg = Index(
    'idx_items_epg',
    'CREATE INDEX idx_items_epg ON items (source_id, epg_id)',
  );
  late final Index idxEpgTime = Index(
    'idx_epg_time',
    'CREATE INDEX idx_epg_time ON epg_programmes (source_id, channel_key, stop)',
  );
  late final Index idxWatchRecent = Index(
    'idx_watch_recent',
    'CREATE INDEX idx_watch_recent ON watch_state (source_id, type, watched_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    items,
    seriesCache,
    metaCache,
    epgChannels,
    epgProgrammes,
    sourceStatus,
    sources,
    favorites,
    userGroups,
    groupItems,
    hidden,
    categoryOrder,
    watchState,
    prefs,
    idxCategoriesSrc,
    idxItemsCat,
    idxItemsName,
    idxItemsEpg,
    idxEpgTime,
    idxWatchRecent,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String sourceId,
  required String type,
  required String id,
  required String name,
  Value<int> position,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> sourceId,
  Value<String> type,
  Value<String> id,
  Value<String> name,
  Value<int> position,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                sourceId: sourceId,
                type: type,
                id: id,
                name: name,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String type,
                required String id,
                required String name,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                sourceId: sourceId,
                type: type,
                id: id,
                name: name,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String sourceId,
  required String type,
  required String id,
  required String name,
  required String nameNorm,
  Value<String> categoryId,
  Value<String?> icon,
  Value<String?> lang,
  Value<double?> rating,
  Value<int> added,
  Value<int?> year,
  Value<String?> releaseDate,
  Value<int> position,
  Value<String?> epgId,
  Value<int?> tmdbId,
  Value<int> archiveDays,
  Value<String?> ext,
  Value<String?> url,
  Value<String?> plot,
  Value<String?> extra,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> sourceId,
  Value<String> type,
  Value<String> id,
  Value<String> name,
  Value<String> nameNorm,
  Value<String> categoryId,
  Value<String?> icon,
  Value<String?> lang,
  Value<double?> rating,
  Value<int> added,
  Value<int?> year,
  Value<String?> releaseDate,
  Value<int> position,
  Value<String?> epgId,
  Value<int?> tmdbId,
  Value<int> archiveDays,
  Value<String?> ext,
  Value<String?> url,
  Value<String?> plot,
  Value<String?> extra,
  Value<int> rowid,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epgId => $composableBuilder(
    column: $table.epgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get archiveDays => $composableBuilder(
    column: $table.archiveDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ext => $composableBuilder(
    column: $table.ext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epgId => $composableBuilder(
    column: $table.epgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archiveDays => $composableBuilder(
    column: $table.archiveDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ext => $composableBuilder(
    column: $table.ext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plot => $composableBuilder(
    column: $table.plot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extra => $composableBuilder(
    column: $table.extra,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get added =>
      $composableBuilder(column: $table.added, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get epgId =>
      $composableBuilder(column: $table.epgId, builder: (column) => column);

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<int> get archiveDays => $composableBuilder(
    column: $table.archiveDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ext =>
      $composableBuilder(column: $table.ext, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get plot =>
      $composableBuilder(column: $table.plot, builder: (column) => column);

  GeneratedColumn<String> get extra =>
      $composableBuilder(column: $table.extra, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
          Item,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameNorm = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int> added = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> epgId = const Value.absent(),
                Value<int?> tmdbId = const Value.absent(),
                Value<int> archiveDays = const Value.absent(),
                Value<String?> ext = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                sourceId: sourceId,
                type: type,
                id: id,
                name: name,
                nameNorm: nameNorm,
                categoryId: categoryId,
                icon: icon,
                lang: lang,
                rating: rating,
                added: added,
                year: year,
                releaseDate: releaseDate,
                position: position,
                epgId: epgId,
                tmdbId: tmdbId,
                archiveDays: archiveDays,
                ext: ext,
                url: url,
                plot: plot,
                extra: extra,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String type,
                required String id,
                required String name,
                required String nameNorm,
                Value<String> categoryId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<int> added = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> epgId = const Value.absent(),
                Value<int?> tmdbId = const Value.absent(),
                Value<int> archiveDays = const Value.absent(),
                Value<String?> ext = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> plot = const Value.absent(),
                Value<String?> extra = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                sourceId: sourceId,
                type: type,
                id: id,
                name: name,
                nameNorm: nameNorm,
                categoryId: categoryId,
                icon: icon,
                lang: lang,
                rating: rating,
                added: added,
                year: year,
                releaseDate: releaseDate,
                position: position,
                epgId: epgId,
                tmdbId: tmdbId,
                archiveDays: archiveDays,
                ext: ext,
                url: url,
                plot: plot,
                extra: extra,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, Item>(table),
                  BaseReferences<_$AppDatabase, $ItemsTable, Item>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
      Item,
      PrefetchHooks Function()
    >;
typedef $$SeriesCacheTableCreateCompanionBuilder =
    SeriesCacheCompanion Function({
      required String sourceId,
      required String seriesId,
      required int fetchedAt,
      required String json,
      Value<int> rowid,
    });
typedef $$SeriesCacheTableUpdateCompanionBuilder =
    SeriesCacheCompanion Function({
      Value<String> sourceId,
      Value<String> seriesId,
      Value<int> fetchedAt,
      Value<String> json,
      Value<int> rowid,
    });

class $$SeriesCacheTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesCacheTable> {
  $$SeriesCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesCacheTable> {
  $$SeriesCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesCacheTable> {
  $$SeriesCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$SeriesCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesCacheTable,
          SeriesCacheData,
          $$SeriesCacheTableFilterComposer,
          $$SeriesCacheTableOrderingComposer,
          $$SeriesCacheTableAnnotationComposer,
          $$SeriesCacheTableCreateCompanionBuilder,
          $$SeriesCacheTableUpdateCompanionBuilder,
          (
            SeriesCacheData,
            BaseReferences<_$AppDatabase, $SeriesCacheTable, SeriesCacheData>,
          ),
          SeriesCacheData,
          PrefetchHooks Function()
        > {
  $$SeriesCacheTableTableManager(_$AppDatabase db, $SeriesCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesCacheCompanion(
                sourceId: sourceId,
                seriesId: seriesId,
                fetchedAt: fetchedAt,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String seriesId,
                required int fetchedAt,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => SeriesCacheCompanion.insert(
                sourceId: sourceId,
                seriesId: seriesId,
                fetchedAt: fetchedAt,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesCacheTable, SeriesCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SeriesCacheTable,
                    SeriesCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesCacheTable,
      SeriesCacheData,
      $$SeriesCacheTableFilterComposer,
      $$SeriesCacheTableOrderingComposer,
      $$SeriesCacheTableAnnotationComposer,
      $$SeriesCacheTableCreateCompanionBuilder,
      $$SeriesCacheTableUpdateCompanionBuilder,
      (
        SeriesCacheData,
        BaseReferences<_$AppDatabase, $SeriesCacheTable, SeriesCacheData>,
      ),
      SeriesCacheData,
      PrefetchHooks Function()
    >;
typedef $$MetaCacheTableCreateCompanionBuilder = MetaCacheCompanion Function({
  required String key,
  required String value,
  required int fetchedAt,
  Value<int> rowid,
});
typedef $$MetaCacheTableUpdateCompanionBuilder = MetaCacheCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> fetchedAt,
  Value<int> rowid,
});

class $$MetaCacheTableFilterComposer
    extends Composer<_$AppDatabase, $MetaCacheTable> {
  $$MetaCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaCacheTable> {
  $$MetaCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaCacheTable> {
  $$MetaCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$MetaCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaCacheTable,
          MetaCacheData,
          $$MetaCacheTableFilterComposer,
          $$MetaCacheTableOrderingComposer,
          $$MetaCacheTableAnnotationComposer,
          $$MetaCacheTableCreateCompanionBuilder,
          $$MetaCacheTableUpdateCompanionBuilder,
          (
            MetaCacheData,
            BaseReferences<_$AppDatabase, $MetaCacheTable, MetaCacheData>,
          ),
          MetaCacheData,
          PrefetchHooks Function()
        > {
  $$MetaCacheTableTableManager(_$AppDatabase db, $MetaCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCacheCompanion(
                key: key,
                value: value,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => MetaCacheCompanion.insert(
                key: key,
                value: value,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaCacheTable, MetaCacheData>(table),
                  BaseReferences<_$AppDatabase, $MetaCacheTable, MetaCacheData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaCacheTable,
      MetaCacheData,
      $$MetaCacheTableFilterComposer,
      $$MetaCacheTableOrderingComposer,
      $$MetaCacheTableAnnotationComposer,
      $$MetaCacheTableCreateCompanionBuilder,
      $$MetaCacheTableUpdateCompanionBuilder,
      (
        MetaCacheData,
        BaseReferences<_$AppDatabase, $MetaCacheTable, MetaCacheData>,
      ),
      MetaCacheData,
      PrefetchHooks Function()
    >;
typedef $$EpgChannelsTableCreateCompanionBuilder =
    EpgChannelsCompanion Function({
      required String sourceId,
      required String channelKey,
      required String nameNorm,
      Value<String?> icon,
      Value<int> rowid,
    });
typedef $$EpgChannelsTableUpdateCompanionBuilder =
    EpgChannelsCompanion Function({
      Value<String> sourceId,
      Value<String> channelKey,
      Value<String> nameNorm,
      Value<String?> icon,
      Value<int> rowid,
    });

class $$EpgChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $EpgChannelsTable> {
  $$EpgChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EpgChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $EpgChannelsTable> {
  $$EpgChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EpgChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpgChannelsTable> {
  $$EpgChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$EpgChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpgChannelsTable,
          EpgChannel,
          $$EpgChannelsTableFilterComposer,
          $$EpgChannelsTableOrderingComposer,
          $$EpgChannelsTableAnnotationComposer,
          $$EpgChannelsTableCreateCompanionBuilder,
          $$EpgChannelsTableUpdateCompanionBuilder,
          (
            EpgChannel,
            BaseReferences<_$AppDatabase, $EpgChannelsTable, EpgChannel>,
          ),
          EpgChannel,
          PrefetchHooks Function()
        > {
  $$EpgChannelsTableTableManager(_$AppDatabase db, $EpgChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpgChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpgChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpgChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> channelKey = const Value.absent(),
                Value<String> nameNorm = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpgChannelsCompanion(
                sourceId: sourceId,
                channelKey: channelKey,
                nameNorm: nameNorm,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String channelKey,
                required String nameNorm,
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpgChannelsCompanion.insert(
                sourceId: sourceId,
                channelKey: channelKey,
                nameNorm: nameNorm,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpgChannelsTable, EpgChannel>(table),
                  BaseReferences<_$AppDatabase, $EpgChannelsTable, EpgChannel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EpgChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpgChannelsTable,
      EpgChannel,
      $$EpgChannelsTableFilterComposer,
      $$EpgChannelsTableOrderingComposer,
      $$EpgChannelsTableAnnotationComposer,
      $$EpgChannelsTableCreateCompanionBuilder,
      $$EpgChannelsTableUpdateCompanionBuilder,
      (
        EpgChannel,
        BaseReferences<_$AppDatabase, $EpgChannelsTable, EpgChannel>,
      ),
      EpgChannel,
      PrefetchHooks Function()
    >;
typedef $$EpgProgrammesTableCreateCompanionBuilder =
    EpgProgrammesCompanion Function({
      required String sourceId,
      required String channelKey,
      required int start,
      required int stop,
      required String title,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$EpgProgrammesTableUpdateCompanionBuilder =
    EpgProgrammesCompanion Function({
      Value<String> sourceId,
      Value<String> channelKey,
      Value<int> start,
      Value<int> stop,
      Value<String> title,
      Value<String?> description,
      Value<int> rowid,
    });

class $$EpgProgrammesTableFilterComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stop => $composableBuilder(
    column: $table.stop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EpgProgrammesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stop => $composableBuilder(
    column: $table.stop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EpgProgrammesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpgProgrammesTable> {
  $$EpgProgrammesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<int> get stop =>
      $composableBuilder(column: $table.stop, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$EpgProgrammesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpgProgrammesTable,
          EpgProgramme,
          $$EpgProgrammesTableFilterComposer,
          $$EpgProgrammesTableOrderingComposer,
          $$EpgProgrammesTableAnnotationComposer,
          $$EpgProgrammesTableCreateCompanionBuilder,
          $$EpgProgrammesTableUpdateCompanionBuilder,
          (
            EpgProgramme,
            BaseReferences<_$AppDatabase, $EpgProgrammesTable, EpgProgramme>,
          ),
          EpgProgramme,
          PrefetchHooks Function()
        > {
  $$EpgProgrammesTableTableManager(_$AppDatabase db, $EpgProgrammesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpgProgrammesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpgProgrammesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpgProgrammesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> channelKey = const Value.absent(),
                Value<int> start = const Value.absent(),
                Value<int> stop = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpgProgrammesCompanion(
                sourceId: sourceId,
                channelKey: channelKey,
                start: start,
                stop: stop,
                title: title,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String channelKey,
                required int start,
                required int stop,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EpgProgrammesCompanion.insert(
                sourceId: sourceId,
                channelKey: channelKey,
                start: start,
                stop: stop,
                title: title,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpgProgrammesTable, EpgProgramme>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EpgProgrammesTable,
                    EpgProgramme
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EpgProgrammesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpgProgrammesTable,
      EpgProgramme,
      $$EpgProgrammesTableFilterComposer,
      $$EpgProgrammesTableOrderingComposer,
      $$EpgProgrammesTableAnnotationComposer,
      $$EpgProgrammesTableCreateCompanionBuilder,
      $$EpgProgrammesTableUpdateCompanionBuilder,
      (
        EpgProgramme,
        BaseReferences<_$AppDatabase, $EpgProgrammesTable, EpgProgramme>,
      ),
      EpgProgramme,
      PrefetchHooks Function()
    >;
typedef $$SourceStatusTableCreateCompanionBuilder =
    SourceStatusCompanion Function({
      required String sourceId,
      Value<int> lastRefresh,
      Value<String?> lastError,
      Value<int> liveCount,
      Value<int> movieCount,
      Value<int> seriesCount,
      Value<int> lastEpgRefresh,
      Value<String?> epgError,
      Value<int> epgProgrammes,
      Value<String?> accountJson,
      Value<int> rowid,
    });
typedef $$SourceStatusTableUpdateCompanionBuilder =
    SourceStatusCompanion Function({
      Value<String> sourceId,
      Value<int> lastRefresh,
      Value<String?> lastError,
      Value<int> liveCount,
      Value<int> movieCount,
      Value<int> seriesCount,
      Value<int> lastEpgRefresh,
      Value<String?> epgError,
      Value<int> epgProgrammes,
      Value<String?> accountJson,
      Value<int> rowid,
    });

class $$SourceStatusTableFilterComposer
    extends Composer<_$AppDatabase, $SourceStatusTable> {
  $$SourceStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRefresh => $composableBuilder(
    column: $table.lastRefresh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get liveCount => $composableBuilder(
    column: $table.liveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movieCount => $composableBuilder(
    column: $table.movieCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastEpgRefresh => $composableBuilder(
    column: $table.lastEpgRefresh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epgError => $composableBuilder(
    column: $table.epgError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get epgProgrammes => $composableBuilder(
    column: $table.epgProgrammes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountJson => $composableBuilder(
    column: $table.accountJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourceStatusTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceStatusTable> {
  $$SourceStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRefresh => $composableBuilder(
    column: $table.lastRefresh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get liveCount => $composableBuilder(
    column: $table.liveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movieCount => $composableBuilder(
    column: $table.movieCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastEpgRefresh => $composableBuilder(
    column: $table.lastEpgRefresh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epgError => $composableBuilder(
    column: $table.epgError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get epgProgrammes => $composableBuilder(
    column: $table.epgProgrammes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountJson => $composableBuilder(
    column: $table.accountJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourceStatusTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceStatusTable> {
  $$SourceStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<int> get lastRefresh => $composableBuilder(
    column: $table.lastRefresh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get liveCount =>
      $composableBuilder(column: $table.liveCount, builder: (column) => column);

  GeneratedColumn<int> get movieCount => $composableBuilder(
    column: $table.movieCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastEpgRefresh => $composableBuilder(
    column: $table.lastEpgRefresh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get epgError =>
      $composableBuilder(column: $table.epgError, builder: (column) => column);

  GeneratedColumn<int> get epgProgrammes => $composableBuilder(
    column: $table.epgProgrammes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountJson => $composableBuilder(
    column: $table.accountJson,
    builder: (column) => column,
  );
}

class $$SourceStatusTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceStatusTable,
          SourceStatusRow,
          $$SourceStatusTableFilterComposer,
          $$SourceStatusTableOrderingComposer,
          $$SourceStatusTableAnnotationComposer,
          $$SourceStatusTableCreateCompanionBuilder,
          $$SourceStatusTableUpdateCompanionBuilder,
          (
            SourceStatusRow,
            BaseReferences<_$AppDatabase, $SourceStatusTable, SourceStatusRow>,
          ),
          SourceStatusRow,
          PrefetchHooks Function()
        > {
  $$SourceStatusTableTableManager(_$AppDatabase db, $SourceStatusTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<int> lastRefresh = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> liveCount = const Value.absent(),
                Value<int> movieCount = const Value.absent(),
                Value<int> seriesCount = const Value.absent(),
                Value<int> lastEpgRefresh = const Value.absent(),
                Value<String?> epgError = const Value.absent(),
                Value<int> epgProgrammes = const Value.absent(),
                Value<String?> accountJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceStatusCompanion(
                sourceId: sourceId,
                lastRefresh: lastRefresh,
                lastError: lastError,
                liveCount: liveCount,
                movieCount: movieCount,
                seriesCount: seriesCount,
                lastEpgRefresh: lastEpgRefresh,
                epgError: epgError,
                epgProgrammes: epgProgrammes,
                accountJson: accountJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                Value<int> lastRefresh = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> liveCount = const Value.absent(),
                Value<int> movieCount = const Value.absent(),
                Value<int> seriesCount = const Value.absent(),
                Value<int> lastEpgRefresh = const Value.absent(),
                Value<String?> epgError = const Value.absent(),
                Value<int> epgProgrammes = const Value.absent(),
                Value<String?> accountJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceStatusCompanion.insert(
                sourceId: sourceId,
                lastRefresh: lastRefresh,
                lastError: lastError,
                liveCount: liveCount,
                movieCount: movieCount,
                seriesCount: seriesCount,
                lastEpgRefresh: lastEpgRefresh,
                epgError: epgError,
                epgProgrammes: epgProgrammes,
                accountJson: accountJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourceStatusTable, SourceStatusRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SourceStatusTable,
                    SourceStatusRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourceStatusTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceStatusTable,
      SourceStatusRow,
      $$SourceStatusTableFilterComposer,
      $$SourceStatusTableOrderingComposer,
      $$SourceStatusTableAnnotationComposer,
      $$SourceStatusTableCreateCompanionBuilder,
      $$SourceStatusTableUpdateCompanionBuilder,
      (
        SourceStatusRow,
        BaseReferences<_$AppDatabase, $SourceStatusTable, SourceStatusRow>,
      ),
      SourceStatusRow,
      PrefetchHooks Function()
    >;
typedef $$SourcesTableCreateCompanionBuilder = SourcesCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String id,
  required String name,
  required String kind,
  Value<String?> url,
  Value<String?> filePath,
  Value<String?> server,
  Value<String?> username,
  Value<String?> password,
  Value<String?> mac,
  Value<String?> epgUrl,
  Value<bool> epgEnabled,
  Value<int> epgRefreshHours,
  Value<int> epgOffsetMin,
  Value<int> refreshHours,
  Value<int> position,
  required int createdAt,
  Value<int> rowid,
});
typedef $$SourcesTableUpdateCompanionBuilder = SourcesCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> id,
  Value<String> name,
  Value<String> kind,
  Value<String?> url,
  Value<String?> filePath,
  Value<String?> server,
  Value<String?> username,
  Value<String?> password,
  Value<String?> mac,
  Value<String?> epgUrl,
  Value<bool> epgEnabled,
  Value<int> epgRefreshHours,
  Value<int> epgOffsetMin,
  Value<int> refreshHours,
  Value<int> position,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mac => $composableBuilder(
    column: $table.mac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get epgUrl => $composableBuilder(
    column: $table.epgUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get epgEnabled => $composableBuilder(
    column: $table.epgEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get epgRefreshHours => $composableBuilder(
    column: $table.epgRefreshHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get epgOffsetMin => $composableBuilder(
    column: $table.epgOffsetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refreshHours => $composableBuilder(
    column: $table.refreshHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get server => $composableBuilder(
    column: $table.server,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mac => $composableBuilder(
    column: $table.mac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get epgUrl => $composableBuilder(
    column: $table.epgUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get epgEnabled => $composableBuilder(
    column: $table.epgEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get epgRefreshHours => $composableBuilder(
    column: $table.epgRefreshHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get epgOffsetMin => $composableBuilder(
    column: $table.epgOffsetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refreshHours => $composableBuilder(
    column: $table.refreshHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get server =>
      $composableBuilder(column: $table.server, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get mac =>
      $composableBuilder(column: $table.mac, builder: (column) => column);

  GeneratedColumn<String> get epgUrl =>
      $composableBuilder(column: $table.epgUrl, builder: (column) => column);

  GeneratedColumn<bool> get epgEnabled => $composableBuilder(
    column: $table.epgEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get epgRefreshHours => $composableBuilder(
    column: $table.epgRefreshHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get epgOffsetMin => $composableBuilder(
    column: $table.epgOffsetMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refreshHours => $composableBuilder(
    column: $table.refreshHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcesTable,
          Source,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (Source, BaseReferences<_$AppDatabase, $SourcesTable, Source>),
          Source,
          PrefetchHooks Function()
        > {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> server = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> mac = const Value.absent(),
                Value<String?> epgUrl = const Value.absent(),
                Value<bool> epgEnabled = const Value.absent(),
                Value<int> epgRefreshHours = const Value.absent(),
                Value<int> epgOffsetMin = const Value.absent(),
                Value<int> refreshHours = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                name: name,
                kind: kind,
                url: url,
                filePath: filePath,
                server: server,
                username: username,
                password: password,
                mac: mac,
                epgUrl: epgUrl,
                epgEnabled: epgEnabled,
                epgRefreshHours: epgRefreshHours,
                epgOffsetMin: epgOffsetMin,
                refreshHours: refreshHours,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String name,
                required String kind,
                Value<String?> url = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> server = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> password = const Value.absent(),
                Value<String?> mac = const Value.absent(),
                Value<String?> epgUrl = const Value.absent(),
                Value<bool> epgEnabled = const Value.absent(),
                Value<int> epgRefreshHours = const Value.absent(),
                Value<int> epgOffsetMin = const Value.absent(),
                Value<int> refreshHours = const Value.absent(),
                Value<int> position = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                name: name,
                kind: kind,
                url: url,
                filePath: filePath,
                server: server,
                username: username,
                password: password,
                mac: mac,
                epgUrl: epgUrl,
                epgEnabled: epgEnabled,
                epgRefreshHours: epgRefreshHours,
                epgOffsetMin: epgOffsetMin,
                refreshHours: refreshHours,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourcesTable, Source>(table),
                  BaseReferences<_$AppDatabase, $SourcesTable, Source>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcesTable,
      Source,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (Source, BaseReferences<_$AppDatabase, $SourcesTable, Source>),
      Source,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String sourceId,
  required String type,
  required String itemId,
  Value<double> position,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> sourceId,
  Value<String> type,
  Value<String> itemId,
  Value<double> position,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                itemId: itemId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String sourceId,
                required String type,
                required String itemId,
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                itemId: itemId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, Favorite>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$UserGroupsTableCreateCompanionBuilder = UserGroupsCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String id,
  required String sourceId,
  required String type,
  required String name,
  Value<double> position,
  Value<int> rowid,
});
typedef $$UserGroupsTableUpdateCompanionBuilder = UserGroupsCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> id,
  Value<String> sourceId,
  Value<String> type,
  Value<String> name,
  Value<double> position,
  Value<int> rowid,
});

class $$UserGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $UserGroupsTable> {
  $$UserGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserGroupsTable> {
  $$UserGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserGroupsTable> {
  $$UserGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$UserGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserGroupsTable,
          UserGroup,
          $$UserGroupsTableFilterComposer,
          $$UserGroupsTableOrderingComposer,
          $$UserGroupsTableAnnotationComposer,
          $$UserGroupsTableCreateCompanionBuilder,
          $$UserGroupsTableUpdateCompanionBuilder,
          (
            UserGroup,
            BaseReferences<_$AppDatabase, $UserGroupsTable, UserGroup>,
          ),
          UserGroup,
          PrefetchHooks Function()
        > {
  $$UserGroupsTableTableManager(_$AppDatabase db, $UserGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGroupsCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                sourceId: sourceId,
                type: type,
                name: name,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String sourceId,
                required String type,
                required String name,
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGroupsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                sourceId: sourceId,
                type: type,
                name: name,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserGroupsTable, UserGroup>(table),
                  BaseReferences<_$AppDatabase, $UserGroupsTable, UserGroup>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserGroupsTable,
      UserGroup,
      $$UserGroupsTableFilterComposer,
      $$UserGroupsTableOrderingComposer,
      $$UserGroupsTableAnnotationComposer,
      $$UserGroupsTableCreateCompanionBuilder,
      $$UserGroupsTableUpdateCompanionBuilder,
      (UserGroup, BaseReferences<_$AppDatabase, $UserGroupsTable, UserGroup>),
      UserGroup,
      PrefetchHooks Function()
    >;
typedef $$GroupItemsTableCreateCompanionBuilder = GroupItemsCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String groupId,
  required String itemId,
  Value<double> position,
  Value<int> rowid,
});
typedef $$GroupItemsTableUpdateCompanionBuilder = GroupItemsCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> groupId,
  Value<String> itemId,
  Value<double> position,
  Value<int> rowid,
});

class $$GroupItemsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupItemsTable> {
  $$GroupItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroupItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupItemsTable> {
  $$GroupItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupItemsTable> {
  $$GroupItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$GroupItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupItemsTable,
          GroupItem,
          $$GroupItemsTableFilterComposer,
          $$GroupItemsTableOrderingComposer,
          $$GroupItemsTableAnnotationComposer,
          $$GroupItemsTableCreateCompanionBuilder,
          $$GroupItemsTableUpdateCompanionBuilder,
          (
            GroupItem,
            BaseReferences<_$AppDatabase, $GroupItemsTable, GroupItem>,
          ),
          GroupItem,
          PrefetchHooks Function()
        > {
  $$GroupItemsTableTableManager(_$AppDatabase db, $GroupItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupItemsCompanion(
                hlc: hlc,
                deleted: deleted,
                groupId: groupId,
                itemId: itemId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String groupId,
                required String itemId,
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupItemsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                groupId: groupId,
                itemId: itemId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GroupItemsTable, GroupItem>(table),
                  BaseReferences<_$AppDatabase, $GroupItemsTable, GroupItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroupItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupItemsTable,
      GroupItem,
      $$GroupItemsTableFilterComposer,
      $$GroupItemsTableOrderingComposer,
      $$GroupItemsTableAnnotationComposer,
      $$GroupItemsTableCreateCompanionBuilder,
      $$GroupItemsTableUpdateCompanionBuilder,
      (GroupItem, BaseReferences<_$AppDatabase, $GroupItemsTable, GroupItem>),
      GroupItem,
      PrefetchHooks Function()
    >;
typedef $$HiddenTableCreateCompanionBuilder = HiddenCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String sourceId,
  required String type,
  required String kind,
  required String refId,
  Value<int> rowid,
});
typedef $$HiddenTableUpdateCompanionBuilder = HiddenCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> sourceId,
  Value<String> type,
  Value<String> kind,
  Value<String> refId,
  Value<int> rowid,
});

class $$HiddenTableFilterComposer
    extends Composer<_$AppDatabase, $HiddenTable> {
  $$HiddenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HiddenTableOrderingComposer
    extends Composer<_$AppDatabase, $HiddenTable> {
  $$HiddenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HiddenTableAnnotationComposer
    extends Composer<_$AppDatabase, $HiddenTable> {
  $$HiddenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);
}

class $$HiddenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HiddenTable,
          HiddenRow,
          $$HiddenTableFilterComposer,
          $$HiddenTableOrderingComposer,
          $$HiddenTableAnnotationComposer,
          $$HiddenTableCreateCompanionBuilder,
          $$HiddenTableUpdateCompanionBuilder,
          (HiddenRow, BaseReferences<_$AppDatabase, $HiddenTable, HiddenRow>),
          HiddenRow,
          PrefetchHooks Function()
        > {
  $$HiddenTableTableManager(_$AppDatabase db, $HiddenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HiddenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HiddenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HiddenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> refId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HiddenCompanion(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                kind: kind,
                refId: refId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String sourceId,
                required String type,
                required String kind,
                required String refId,
                Value<int> rowid = const Value.absent(),
              }) => HiddenCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                kind: kind,
                refId: refId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HiddenTable, HiddenRow>(table),
                  BaseReferences<_$AppDatabase, $HiddenTable, HiddenRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HiddenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HiddenTable,
      HiddenRow,
      $$HiddenTableFilterComposer,
      $$HiddenTableOrderingComposer,
      $$HiddenTableAnnotationComposer,
      $$HiddenTableCreateCompanionBuilder,
      $$HiddenTableUpdateCompanionBuilder,
      (HiddenRow, BaseReferences<_$AppDatabase, $HiddenTable, HiddenRow>),
      HiddenRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryOrderTableCreateCompanionBuilder =
    CategoryOrderCompanion Function({
      required String hlc,
      Value<bool> deleted,
      required String sourceId,
      required String type,
      required String categoryId,
      required double position,
      Value<int> rowid,
    });
typedef $$CategoryOrderTableUpdateCompanionBuilder =
    CategoryOrderCompanion Function({
      Value<String> hlc,
      Value<bool> deleted,
      Value<String> sourceId,
      Value<String> type,
      Value<String> categoryId,
      Value<double> position,
      Value<int> rowid,
    });

class $$CategoryOrderTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryOrderTable> {
  $$CategoryOrderTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryOrderTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryOrderTable> {
  $$CategoryOrderTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryOrderTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryOrderTable> {
  $$CategoryOrderTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$CategoryOrderTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryOrderTable,
          CategoryOrderData,
          $$CategoryOrderTableFilterComposer,
          $$CategoryOrderTableOrderingComposer,
          $$CategoryOrderTableAnnotationComposer,
          $$CategoryOrderTableCreateCompanionBuilder,
          $$CategoryOrderTableUpdateCompanionBuilder,
          (
            CategoryOrderData,
            BaseReferences<
              _$AppDatabase,
              $CategoryOrderTable,
              CategoryOrderData
            >,
          ),
          CategoryOrderData,
          PrefetchHooks Function()
        > {
  $$CategoryOrderTableTableManager(_$AppDatabase db, $CategoryOrderTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryOrderTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryOrderTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryOrderTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryOrderCompanion(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                categoryId: categoryId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String sourceId,
                required String type,
                required String categoryId,
                required double position,
                Value<int> rowid = const Value.absent(),
              }) => CategoryOrderCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                categoryId: categoryId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryOrderTable, CategoryOrderData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CategoryOrderTable,
                    CategoryOrderData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryOrderTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryOrderTable,
      CategoryOrderData,
      $$CategoryOrderTableFilterComposer,
      $$CategoryOrderTableOrderingComposer,
      $$CategoryOrderTableAnnotationComposer,
      $$CategoryOrderTableCreateCompanionBuilder,
      $$CategoryOrderTableUpdateCompanionBuilder,
      (
        CategoryOrderData,
        BaseReferences<_$AppDatabase, $CategoryOrderTable, CategoryOrderData>,
      ),
      CategoryOrderData,
      PrefetchHooks Function()
    >;
typedef $$WatchStateTableCreateCompanionBuilder = WatchStateCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String sourceId,
  required String type,
  required String itemId,
  Value<String?> seriesId,
  required String name,
  Value<String?> icon,
  Value<int?> season,
  Value<int?> episode,
  Value<int> positionMs,
  Value<int> durationMs,
  required int watchedAt,
  Value<bool> finished,
  Value<int> rowid,
});
typedef $$WatchStateTableUpdateCompanionBuilder = WatchStateCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> sourceId,
  Value<String> type,
  Value<String> itemId,
  Value<String?> seriesId,
  Value<String> name,
  Value<String?> icon,
  Value<int?> season,
  Value<int?> episode,
  Value<int> positionMs,
  Value<int> durationMs,
  Value<int> watchedAt,
  Value<bool> finished,
  Value<int> rowid,
});

class $$WatchStateTableFilterComposer
    extends Composer<_$AppDatabase, $WatchStateTable> {
  $$WatchStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get finished => $composableBuilder(
    column: $table.finished,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchStateTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchStateTable> {
  $$WatchStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episode => $composableBuilder(
    column: $table.episode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get finished => $composableBuilder(
    column: $table.finished,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchStateTable> {
  $$WatchStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  GeneratedColumn<bool> get finished =>
      $composableBuilder(column: $table.finished, builder: (column) => column);
}

class $$WatchStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchStateTable,
          WatchRow,
          $$WatchStateTableFilterComposer,
          $$WatchStateTableOrderingComposer,
          $$WatchStateTableAnnotationComposer,
          $$WatchStateTableCreateCompanionBuilder,
          $$WatchStateTableUpdateCompanionBuilder,
          (WatchRow, BaseReferences<_$AppDatabase, $WatchStateTable, WatchRow>),
          WatchRow,
          PrefetchHooks Function()
        > {
  $$WatchStateTableTableManager(_$AppDatabase db, $WatchStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<int?> episode = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> watchedAt = const Value.absent(),
                Value<bool> finished = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchStateCompanion(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                itemId: itemId,
                seriesId: seriesId,
                name: name,
                icon: icon,
                season: season,
                episode: episode,
                positionMs: positionMs,
                durationMs: durationMs,
                watchedAt: watchedAt,
                finished: finished,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String sourceId,
                required String type,
                required String itemId,
                Value<String?> seriesId = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<int?> episode = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required int watchedAt,
                Value<bool> finished = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchStateCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                sourceId: sourceId,
                type: type,
                itemId: itemId,
                seriesId: seriesId,
                name: name,
                icon: icon,
                season: season,
                episode: episode,
                positionMs: positionMs,
                durationMs: durationMs,
                watchedAt: watchedAt,
                finished: finished,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WatchStateTable, WatchRow>(table),
                  BaseReferences<_$AppDatabase, $WatchStateTable, WatchRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchStateTable,
      WatchRow,
      $$WatchStateTableFilterComposer,
      $$WatchStateTableOrderingComposer,
      $$WatchStateTableAnnotationComposer,
      $$WatchStateTableCreateCompanionBuilder,
      $$WatchStateTableUpdateCompanionBuilder,
      (WatchRow, BaseReferences<_$AppDatabase, $WatchStateTable, WatchRow>),
      WatchRow,
      PrefetchHooks Function()
    >;
typedef $$PrefsTableCreateCompanionBuilder = PrefsCompanion Function({
  required String hlc,
  Value<bool> deleted,
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$PrefsTableUpdateCompanionBuilder = PrefsCompanion Function({
  Value<String> hlc,
  Value<bool> deleted,
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$PrefsTableFilterComposer extends Composer<_$AppDatabase, $PrefsTable> {
  $$PrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrefsTable> {
  $$PrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrefsTable> {
  $$PrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrefsTable,
          Pref,
          $$PrefsTableFilterComposer,
          $$PrefsTableOrderingComposer,
          $$PrefsTableAnnotationComposer,
          $$PrefsTableCreateCompanionBuilder,
          $$PrefsTableUpdateCompanionBuilder,
          (Pref, BaseReferences<_$AppDatabase, $PrefsTable, Pref>),
          Pref,
          PrefetchHooks Function()
        > {
  $$PrefsTableTableManager(_$AppDatabase db, $PrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrefsCompanion(
                hlc: hlc,
                deleted: deleted,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hlc,
                Value<bool> deleted = const Value.absent(),
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PrefsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrefsTable, Pref>(table),
                  BaseReferences<_$AppDatabase, $PrefsTable, Pref>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrefsTable,
      Pref,
      $$PrefsTableFilterComposer,
      $$PrefsTableOrderingComposer,
      $$PrefsTableAnnotationComposer,
      $$PrefsTableCreateCompanionBuilder,
      $$PrefsTableUpdateCompanionBuilder,
      (Pref, BaseReferences<_$AppDatabase, $PrefsTable, Pref>),
      Pref,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$SeriesCacheTableTableManager get seriesCache =>
      $$SeriesCacheTableTableManager(_db, _db.seriesCache);
  $$MetaCacheTableTableManager get metaCache =>
      $$MetaCacheTableTableManager(_db, _db.metaCache);
  $$EpgChannelsTableTableManager get epgChannels =>
      $$EpgChannelsTableTableManager(_db, _db.epgChannels);
  $$EpgProgrammesTableTableManager get epgProgrammes =>
      $$EpgProgrammesTableTableManager(_db, _db.epgProgrammes);
  $$SourceStatusTableTableManager get sourceStatus =>
      $$SourceStatusTableTableManager(_db, _db.sourceStatus);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$UserGroupsTableTableManager get userGroups =>
      $$UserGroupsTableTableManager(_db, _db.userGroups);
  $$GroupItemsTableTableManager get groupItems =>
      $$GroupItemsTableTableManager(_db, _db.groupItems);
  $$HiddenTableTableManager get hidden =>
      $$HiddenTableTableManager(_db, _db.hidden);
  $$CategoryOrderTableTableManager get categoryOrder =>
      $$CategoryOrderTableTableManager(_db, _db.categoryOrder);
  $$WatchStateTableTableManager get watchState =>
      $$WatchStateTableTableManager(_db, _db.watchState);
  $$PrefsTableTableManager get prefs =>
      $$PrefsTableTableManager(_db, _db.prefs);
}
