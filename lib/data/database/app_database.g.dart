// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class AppMetadata extends Table with TableInfo<AppMetadata, AppMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppMetadata(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataData> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataData(
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
  AppMetadata createAlias(String alias) {
    return AppMetadata(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AppMetadataData extends DataClass implements Insertable<AppMetadataData> {
  final String key;
  final String value;
  const AppMetadataData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetadataData copyWith({String? key, String? value}) =>
      AppMetadataData(key: key ?? this.key, value: value ?? this.value);
  AppMetadataData copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
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
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Workout extends Table with TableInfo<Workout, WorkoutData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Workout(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    notes,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  Workout createAlias(String alias) {
    return Workout(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class WorkoutData extends DataClass implements Insertable<WorkoutData> {
  final int id;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const WorkoutData({
    required this.id,
    required this.name,
    this.notes,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  WorkoutCompanion toCompanion(bool nullToAbsent) {
    return WorkoutCompanion(
      id: Value(id),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory WorkoutData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      archivedAt: serializer.fromJson<DateTime?>(json['archived_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'archived_at': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  WorkoutData copyWith({
    int? id,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => WorkoutData(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  WorkoutData copyWithCompanion(WorkoutCompanion data) {
    return WorkoutData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes, createdAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutData &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class WorkoutCompanion extends UpdateCompanion<WorkoutData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  const WorkoutCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  WorkoutCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<WorkoutData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  WorkoutCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
  }) {
    return WorkoutCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class WorkoutExercise extends Table
    with TableInfo<WorkoutExercise, WorkoutExerciseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  WorkoutExercise(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES workout(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedSetsMeta = const VerificationMeta(
    'plannedSets',
  );
  late final GeneratedColumn<int> plannedSets = GeneratedColumn<int>(
    'planned_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _repTypeMeta = const VerificationMeta(
    'repType',
  );
  late final GeneratedColumn<String> repType = GeneratedColumn<String>(
    'rep_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _minRepsMeta = const VerificationMeta(
    'minReps',
  );
  late final GeneratedColumn<int> minReps = GeneratedColumn<int>(
    'min_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _maxRepsMeta = const VerificationMeta(
    'maxReps',
  );
  late final GeneratedColumn<int> maxReps = GeneratedColumn<int>(
    'max_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _loadTypeMeta = const VerificationMeta(
    'loadType',
  );
  late final GeneratedColumn<String> loadType = GeneratedColumn<String>(
    'load_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _weightCanonicalMgMeta = const VerificationMeta(
    'weightCanonicalMg',
  );
  late final GeneratedColumn<int> weightCanonicalMg = GeneratedColumn<int>(
    'weight_canonical_mg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  late final GeneratedColumn<int> percentage = GeneratedColumn<int>(
    'percentage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _targetRpeMeta = const VerificationMeta(
    'targetRpe',
  );
  late final GeneratedColumn<double> targetRpe = GeneratedColumn<double>(
    'target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _freeformTextMeta = const VerificationMeta(
    'freeformText',
  );
  late final GeneratedColumn<String> freeformText = GeneratedColumn<String>(
    'freeform_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    name,
    normalizedName,
    orderIndex,
    plannedSets,
    repType,
    targetReps,
    minReps,
    maxReps,
    loadType,
    weightCanonicalMg,
    percentage,
    targetRpe,
    freeformText,
    restSeconds,
    supersetGroup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercise';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutExerciseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('planned_sets')) {
      context.handle(
        _plannedSetsMeta,
        plannedSets.isAcceptableOrUnknown(
          data['planned_sets']!,
          _plannedSetsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedSetsMeta);
    }
    if (data.containsKey('rep_type')) {
      context.handle(
        _repTypeMeta,
        repType.isAcceptableOrUnknown(data['rep_type']!, _repTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_repTypeMeta);
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    if (data.containsKey('min_reps')) {
      context.handle(
        _minRepsMeta,
        minReps.isAcceptableOrUnknown(data['min_reps']!, _minRepsMeta),
      );
    }
    if (data.containsKey('max_reps')) {
      context.handle(
        _maxRepsMeta,
        maxReps.isAcceptableOrUnknown(data['max_reps']!, _maxRepsMeta),
      );
    }
    if (data.containsKey('load_type')) {
      context.handle(
        _loadTypeMeta,
        loadType.isAcceptableOrUnknown(data['load_type']!, _loadTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_loadTypeMeta);
    }
    if (data.containsKey('weight_canonical_mg')) {
      context.handle(
        _weightCanonicalMgMeta,
        weightCanonicalMg.isAcceptableOrUnknown(
          data['weight_canonical_mg']!,
          _weightCanonicalMgMeta,
        ),
      );
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    }
    if (data.containsKey('target_rpe')) {
      context.handle(
        _targetRpeMeta,
        targetRpe.isAcceptableOrUnknown(data['target_rpe']!, _targetRpeMeta),
      );
    }
    if (data.containsKey('freeform_text')) {
      context.handle(
        _freeformTextMeta,
        freeformText.isAcceptableOrUnknown(
          data['freeform_text']!,
          _freeformTextMeta,
        ),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restSecondsMeta);
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExerciseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExerciseData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      plannedSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_sets'],
      )!,
      repType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rep_type'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      ),
      minReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_reps'],
      ),
      maxReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_reps'],
      ),
      loadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}load_type'],
      )!,
      weightCanonicalMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_canonical_mg'],
      ),
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percentage'],
      ),
      targetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_rpe'],
      ),
      freeformText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freeform_text'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
    );
  }

  @override
  WorkoutExercise createAlias(String alias) {
    return WorkoutExercise(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CONSTRAINT workout_exercise_order CHECK(order_index >= 0)',
    'CONSTRAINT workout_exercise_planned_sets CHECK(planned_sets >= 1)',
    'CONSTRAINT workout_exercise_rest CHECK(rest_seconds >= 0)',
    'CONSTRAINT workout_exercise_superset CHECK(superset_group IS NULL OR superset_group >= 0)',
    'CONSTRAINT workout_exercise_rep_fields CHECK((rep_type = \'fixed\' AND target_reps IS NOT NULL AND target_reps >= 1 AND min_reps IS NULL AND max_reps IS NULL)OR(rep_type = \'range\' AND target_reps IS NULL AND min_reps IS NOT NULL AND max_reps IS NOT NULL AND min_reps >= 1 AND max_reps >= min_reps)OR(rep_type = \'amrap\' AND target_reps IS NULL AND min_reps IS NULL AND max_reps IS NULL))',
    'CONSTRAINT workout_exercise_load_fields CHECK((load_type = \'none\' AND weight_canonical_mg IS NULL AND percentage IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'bodyweight\' AND weight_canonical_mg IS NULL AND percentage IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'absolute\' AND weight_canonical_mg IS NOT NULL AND weight_canonical_mg >= 0 AND percentage IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'percentage\' AND percentage IS NOT NULL AND percentage >= 0 AND percentage <= 100 AND weight_canonical_mg IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'target_rpe\' AND target_rpe IS NOT NULL AND target_rpe >= 0 AND target_rpe <= 10 AND weight_canonical_mg IS NULL AND percentage IS NULL AND freeform_text IS NULL)OR(load_type = \'text\' AND freeform_text IS NOT NULL AND length(freeform_text) > 0 AND weight_canonical_mg IS NULL AND percentage IS NULL AND target_rpe IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class WorkoutExerciseData extends DataClass
    implements Insertable<WorkoutExerciseData> {
  final int id;
  final int workoutId;
  final String name;
  final String normalizedName;
  final int orderIndex;
  final int plannedSets;
  final String repType;
  final int? targetReps;
  final int? minReps;
  final int? maxReps;
  final String loadType;
  final int? weightCanonicalMg;
  final int? percentage;
  final double? targetRpe;
  final String? freeformText;
  final int restSeconds;
  final int? supersetGroup;
  const WorkoutExerciseData({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.normalizedName,
    required this.orderIndex,
    required this.plannedSets,
    required this.repType,
    this.targetReps,
    this.minReps,
    this.maxReps,
    required this.loadType,
    this.weightCanonicalMg,
    this.percentage,
    this.targetRpe,
    this.freeformText,
    required this.restSeconds,
    this.supersetGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['order_index'] = Variable<int>(orderIndex);
    map['planned_sets'] = Variable<int>(plannedSets);
    map['rep_type'] = Variable<String>(repType);
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || minReps != null) {
      map['min_reps'] = Variable<int>(minReps);
    }
    if (!nullToAbsent || maxReps != null) {
      map['max_reps'] = Variable<int>(maxReps);
    }
    map['load_type'] = Variable<String>(loadType);
    if (!nullToAbsent || weightCanonicalMg != null) {
      map['weight_canonical_mg'] = Variable<int>(weightCanonicalMg);
    }
    if (!nullToAbsent || percentage != null) {
      map['percentage'] = Variable<int>(percentage);
    }
    if (!nullToAbsent || targetRpe != null) {
      map['target_rpe'] = Variable<double>(targetRpe);
    }
    if (!nullToAbsent || freeformText != null) {
      map['freeform_text'] = Variable<String>(freeformText);
    }
    map['rest_seconds'] = Variable<int>(restSeconds);
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    return map;
  }

  WorkoutExerciseCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExerciseCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      orderIndex: Value(orderIndex),
      plannedSets: Value(plannedSets),
      repType: Value(repType),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      minReps: minReps == null && nullToAbsent
          ? const Value.absent()
          : Value(minReps),
      maxReps: maxReps == null && nullToAbsent
          ? const Value.absent()
          : Value(maxReps),
      loadType: Value(loadType),
      weightCanonicalMg: weightCanonicalMg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightCanonicalMg),
      percentage: percentage == null && nullToAbsent
          ? const Value.absent()
          : Value(percentage),
      targetRpe: targetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRpe),
      freeformText: freeformText == null && nullToAbsent
          ? const Value.absent()
          : Value(freeformText),
      restSeconds: Value(restSeconds),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
    );
  }

  factory WorkoutExerciseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExerciseData(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workout_id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalized_name']),
      orderIndex: serializer.fromJson<int>(json['order_index']),
      plannedSets: serializer.fromJson<int>(json['planned_sets']),
      repType: serializer.fromJson<String>(json['rep_type']),
      targetReps: serializer.fromJson<int?>(json['target_reps']),
      minReps: serializer.fromJson<int?>(json['min_reps']),
      maxReps: serializer.fromJson<int?>(json['max_reps']),
      loadType: serializer.fromJson<String>(json['load_type']),
      weightCanonicalMg: serializer.fromJson<int?>(json['weight_canonical_mg']),
      percentage: serializer.fromJson<int?>(json['percentage']),
      targetRpe: serializer.fromJson<double?>(json['target_rpe']),
      freeformText: serializer.fromJson<String?>(json['freeform_text']),
      restSeconds: serializer.fromJson<int>(json['rest_seconds']),
      supersetGroup: serializer.fromJson<int?>(json['superset_group']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workout_id': serializer.toJson<int>(workoutId),
      'name': serializer.toJson<String>(name),
      'normalized_name': serializer.toJson<String>(normalizedName),
      'order_index': serializer.toJson<int>(orderIndex),
      'planned_sets': serializer.toJson<int>(plannedSets),
      'rep_type': serializer.toJson<String>(repType),
      'target_reps': serializer.toJson<int?>(targetReps),
      'min_reps': serializer.toJson<int?>(minReps),
      'max_reps': serializer.toJson<int?>(maxReps),
      'load_type': serializer.toJson<String>(loadType),
      'weight_canonical_mg': serializer.toJson<int?>(weightCanonicalMg),
      'percentage': serializer.toJson<int?>(percentage),
      'target_rpe': serializer.toJson<double?>(targetRpe),
      'freeform_text': serializer.toJson<String?>(freeformText),
      'rest_seconds': serializer.toJson<int>(restSeconds),
      'superset_group': serializer.toJson<int?>(supersetGroup),
    };
  }

  WorkoutExerciseData copyWith({
    int? id,
    int? workoutId,
    String? name,
    String? normalizedName,
    int? orderIndex,
    int? plannedSets,
    String? repType,
    Value<int?> targetReps = const Value.absent(),
    Value<int?> minReps = const Value.absent(),
    Value<int?> maxReps = const Value.absent(),
    String? loadType,
    Value<int?> weightCanonicalMg = const Value.absent(),
    Value<int?> percentage = const Value.absent(),
    Value<double?> targetRpe = const Value.absent(),
    Value<String?> freeformText = const Value.absent(),
    int? restSeconds,
    Value<int?> supersetGroup = const Value.absent(),
  }) => WorkoutExerciseData(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    orderIndex: orderIndex ?? this.orderIndex,
    plannedSets: plannedSets ?? this.plannedSets,
    repType: repType ?? this.repType,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    minReps: minReps.present ? minReps.value : this.minReps,
    maxReps: maxReps.present ? maxReps.value : this.maxReps,
    loadType: loadType ?? this.loadType,
    weightCanonicalMg: weightCanonicalMg.present
        ? weightCanonicalMg.value
        : this.weightCanonicalMg,
    percentage: percentage.present ? percentage.value : this.percentage,
    targetRpe: targetRpe.present ? targetRpe.value : this.targetRpe,
    freeformText: freeformText.present ? freeformText.value : this.freeformText,
    restSeconds: restSeconds ?? this.restSeconds,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
  );
  WorkoutExerciseData copyWithCompanion(WorkoutExerciseCompanion data) {
    return WorkoutExerciseData(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      plannedSets: data.plannedSets.present
          ? data.plannedSets.value
          : this.plannedSets,
      repType: data.repType.present ? data.repType.value : this.repType,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      minReps: data.minReps.present ? data.minReps.value : this.minReps,
      maxReps: data.maxReps.present ? data.maxReps.value : this.maxReps,
      loadType: data.loadType.present ? data.loadType.value : this.loadType,
      weightCanonicalMg: data.weightCanonicalMg.present
          ? data.weightCanonicalMg.value
          : this.weightCanonicalMg,
      percentage: data.percentage.present
          ? data.percentage.value
          : this.percentage,
      targetRpe: data.targetRpe.present ? data.targetRpe.value : this.targetRpe,
      freeformText: data.freeformText.present
          ? data.freeformText.value
          : this.freeformText,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExerciseData(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('plannedSets: $plannedSets, ')
          ..write('repType: $repType, ')
          ..write('targetReps: $targetReps, ')
          ..write('minReps: $minReps, ')
          ..write('maxReps: $maxReps, ')
          ..write('loadType: $loadType, ')
          ..write('weightCanonicalMg: $weightCanonicalMg, ')
          ..write('percentage: $percentage, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('freeformText: $freeformText, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('supersetGroup: $supersetGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    name,
    normalizedName,
    orderIndex,
    plannedSets,
    repType,
    targetReps,
    minReps,
    maxReps,
    loadType,
    weightCanonicalMg,
    percentage,
    targetRpe,
    freeformText,
    restSeconds,
    supersetGroup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExerciseData &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.orderIndex == this.orderIndex &&
          other.plannedSets == this.plannedSets &&
          other.repType == this.repType &&
          other.targetReps == this.targetReps &&
          other.minReps == this.minReps &&
          other.maxReps == this.maxReps &&
          other.loadType == this.loadType &&
          other.weightCanonicalMg == this.weightCanonicalMg &&
          other.percentage == this.percentage &&
          other.targetRpe == this.targetRpe &&
          other.freeformText == this.freeformText &&
          other.restSeconds == this.restSeconds &&
          other.supersetGroup == this.supersetGroup);
}

class WorkoutExerciseCompanion extends UpdateCompanion<WorkoutExerciseData> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int> orderIndex;
  final Value<int> plannedSets;
  final Value<String> repType;
  final Value<int?> targetReps;
  final Value<int?> minReps;
  final Value<int?> maxReps;
  final Value<String> loadType;
  final Value<int?> weightCanonicalMg;
  final Value<int?> percentage;
  final Value<double?> targetRpe;
  final Value<String?> freeformText;
  final Value<int> restSeconds;
  final Value<int?> supersetGroup;
  const WorkoutExerciseCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.plannedSets = const Value.absent(),
    this.repType = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.minReps = const Value.absent(),
    this.maxReps = const Value.absent(),
    this.loadType = const Value.absent(),
    this.weightCanonicalMg = const Value.absent(),
    this.percentage = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.freeformText = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.supersetGroup = const Value.absent(),
  });
  WorkoutExerciseCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required String name,
    required String normalizedName,
    required int orderIndex,
    required int plannedSets,
    required String repType,
    this.targetReps = const Value.absent(),
    this.minReps = const Value.absent(),
    this.maxReps = const Value.absent(),
    required String loadType,
    this.weightCanonicalMg = const Value.absent(),
    this.percentage = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.freeformText = const Value.absent(),
    required int restSeconds,
    this.supersetGroup = const Value.absent(),
  }) : workoutId = Value(workoutId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       orderIndex = Value(orderIndex),
       plannedSets = Value(plannedSets),
       repType = Value(repType),
       loadType = Value(loadType),
       restSeconds = Value(restSeconds);
  static Insertable<WorkoutExerciseData> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? orderIndex,
    Expression<int>? plannedSets,
    Expression<String>? repType,
    Expression<int>? targetReps,
    Expression<int>? minReps,
    Expression<int>? maxReps,
    Expression<String>? loadType,
    Expression<int>? weightCanonicalMg,
    Expression<int>? percentage,
    Expression<double>? targetRpe,
    Expression<String>? freeformText,
    Expression<int>? restSeconds,
    Expression<int>? supersetGroup,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (orderIndex != null) 'order_index': orderIndex,
      if (plannedSets != null) 'planned_sets': plannedSets,
      if (repType != null) 'rep_type': repType,
      if (targetReps != null) 'target_reps': targetReps,
      if (minReps != null) 'min_reps': minReps,
      if (maxReps != null) 'max_reps': maxReps,
      if (loadType != null) 'load_type': loadType,
      if (weightCanonicalMg != null) 'weight_canonical_mg': weightCanonicalMg,
      if (percentage != null) 'percentage': percentage,
      if (targetRpe != null) 'target_rpe': targetRpe,
      if (freeformText != null) 'freeform_text': freeformText,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (supersetGroup != null) 'superset_group': supersetGroup,
    });
  }

  WorkoutExerciseCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int>? orderIndex,
    Value<int>? plannedSets,
    Value<String>? repType,
    Value<int?>? targetReps,
    Value<int?>? minReps,
    Value<int?>? maxReps,
    Value<String>? loadType,
    Value<int?>? weightCanonicalMg,
    Value<int?>? percentage,
    Value<double?>? targetRpe,
    Value<String?>? freeformText,
    Value<int>? restSeconds,
    Value<int?>? supersetGroup,
  }) {
    return WorkoutExerciseCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      orderIndex: orderIndex ?? this.orderIndex,
      plannedSets: plannedSets ?? this.plannedSets,
      repType: repType ?? this.repType,
      targetReps: targetReps ?? this.targetReps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      loadType: loadType ?? this.loadType,
      weightCanonicalMg: weightCanonicalMg ?? this.weightCanonicalMg,
      percentage: percentage ?? this.percentage,
      targetRpe: targetRpe ?? this.targetRpe,
      freeformText: freeformText ?? this.freeformText,
      restSeconds: restSeconds ?? this.restSeconds,
      supersetGroup: supersetGroup ?? this.supersetGroup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (plannedSets.present) {
      map['planned_sets'] = Variable<int>(plannedSets.value);
    }
    if (repType.present) {
      map['rep_type'] = Variable<String>(repType.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (minReps.present) {
      map['min_reps'] = Variable<int>(minReps.value);
    }
    if (maxReps.present) {
      map['max_reps'] = Variable<int>(maxReps.value);
    }
    if (loadType.present) {
      map['load_type'] = Variable<String>(loadType.value);
    }
    if (weightCanonicalMg.present) {
      map['weight_canonical_mg'] = Variable<int>(weightCanonicalMg.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<int>(percentage.value);
    }
    if (targetRpe.present) {
      map['target_rpe'] = Variable<double>(targetRpe.value);
    }
    if (freeformText.present) {
      map['freeform_text'] = Variable<String>(freeformText.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExerciseCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('plannedSets: $plannedSets, ')
          ..write('repType: $repType, ')
          ..write('targetReps: $targetReps, ')
          ..write('minReps: $minReps, ')
          ..write('maxReps: $maxReps, ')
          ..write('loadType: $loadType, ')
          ..write('weightCanonicalMg: $weightCanonicalMg, ')
          ..write('percentage: $percentage, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('freeformText: $freeformText, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('supersetGroup: $supersetGroup')
          ..write(')'))
        .toString();
  }
}

class WorkoutSet extends Table with TableInfo<WorkoutSet, WorkoutSetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  WorkoutSet(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _workoutExerciseIdMeta = const VerificationMeta(
    'workoutExerciseId',
  );
  late final GeneratedColumn<int> workoutExerciseId = GeneratedColumn<int>(
    'workout_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES workout_exercise(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _repTypeMeta = const VerificationMeta(
    'repType',
  );
  late final GeneratedColumn<String> repType = GeneratedColumn<String>(
    'rep_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _minRepsMeta = const VerificationMeta(
    'minReps',
  );
  late final GeneratedColumn<int> minReps = GeneratedColumn<int>(
    'min_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _maxRepsMeta = const VerificationMeta(
    'maxReps',
  );
  late final GeneratedColumn<int> maxReps = GeneratedColumn<int>(
    'max_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _loadTypeMeta = const VerificationMeta(
    'loadType',
  );
  late final GeneratedColumn<String> loadType = GeneratedColumn<String>(
    'load_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _weightCanonicalMgMeta = const VerificationMeta(
    'weightCanonicalMg',
  );
  late final GeneratedColumn<int> weightCanonicalMg = GeneratedColumn<int>(
    'weight_canonical_mg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  late final GeneratedColumn<int> percentage = GeneratedColumn<int>(
    'percentage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _targetRpeMeta = const VerificationMeta(
    'targetRpe',
  );
  late final GeneratedColumn<double> targetRpe = GeneratedColumn<double>(
    'target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _freeformTextMeta = const VerificationMeta(
    'freeformText',
  );
  late final GeneratedColumn<String> freeformText = GeneratedColumn<String>(
    'freeform_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutExerciseId,
    setIndex,
    repType,
    targetReps,
    minReps,
    maxReps,
    loadType,
    weightCanonicalMg,
    percentage,
    targetRpe,
    freeformText,
    restSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_set';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSetData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_exercise_id')) {
      context.handle(
        _workoutExerciseIdMeta,
        workoutExerciseId.isAcceptableOrUnknown(
          data['workout_exercise_id']!,
          _workoutExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutExerciseIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('rep_type')) {
      context.handle(
        _repTypeMeta,
        repType.isAcceptableOrUnknown(data['rep_type']!, _repTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_repTypeMeta);
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    if (data.containsKey('min_reps')) {
      context.handle(
        _minRepsMeta,
        minReps.isAcceptableOrUnknown(data['min_reps']!, _minRepsMeta),
      );
    }
    if (data.containsKey('max_reps')) {
      context.handle(
        _maxRepsMeta,
        maxReps.isAcceptableOrUnknown(data['max_reps']!, _maxRepsMeta),
      );
    }
    if (data.containsKey('load_type')) {
      context.handle(
        _loadTypeMeta,
        loadType.isAcceptableOrUnknown(data['load_type']!, _loadTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_loadTypeMeta);
    }
    if (data.containsKey('weight_canonical_mg')) {
      context.handle(
        _weightCanonicalMgMeta,
        weightCanonicalMg.isAcceptableOrUnknown(
          data['weight_canonical_mg']!,
          _weightCanonicalMgMeta,
        ),
      );
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    }
    if (data.containsKey('target_rpe')) {
      context.handle(
        _targetRpeMeta,
        targetRpe.isAcceptableOrUnknown(data['target_rpe']!, _targetRpeMeta),
      );
    }
    if (data.containsKey('freeform_text')) {
      context.handle(
        _freeformTextMeta,
        freeformText.isAcceptableOrUnknown(
          data['freeform_text']!,
          _freeformTextMeta,
        ),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSetData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_exercise_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      repType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rep_type'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      ),
      minReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_reps'],
      ),
      maxReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_reps'],
      ),
      loadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}load_type'],
      )!,
      weightCanonicalMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight_canonical_mg'],
      ),
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percentage'],
      ),
      targetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_rpe'],
      ),
      freeformText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freeform_text'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
    );
  }

  @override
  WorkoutSet createAlias(String alias) {
    return WorkoutSet(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CONSTRAINT workout_set_index CHECK(set_index >= 0)',
    'CONSTRAINT workout_set_rest CHECK(rest_seconds >= 0)',
    'CONSTRAINT workout_set_rep_fields CHECK((rep_type = \'fixed\' AND target_reps IS NOT NULL AND target_reps >= 1 AND min_reps IS NULL AND max_reps IS NULL)OR(rep_type = \'range\' AND target_reps IS NULL AND min_reps IS NOT NULL AND max_reps IS NOT NULL AND min_reps >= 1 AND max_reps >= min_reps)OR(rep_type = \'amrap\' AND target_reps IS NULL AND min_reps IS NULL AND max_reps IS NULL))',
    'CONSTRAINT workout_set_load_fields CHECK((load_type = \'none\' AND weight_canonical_mg IS NULL AND percentage IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'bodyweight\' AND weight_canonical_mg IS NULL AND percentage IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'absolute\' AND weight_canonical_mg IS NOT NULL AND weight_canonical_mg >= 0 AND percentage IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'percentage\' AND percentage IS NOT NULL AND percentage >= 0 AND percentage <= 100 AND weight_canonical_mg IS NULL AND target_rpe IS NULL AND freeform_text IS NULL)OR(load_type = \'target_rpe\' AND target_rpe IS NOT NULL AND target_rpe >= 0 AND target_rpe <= 10 AND weight_canonical_mg IS NULL AND percentage IS NULL AND freeform_text IS NULL)OR(load_type = \'text\' AND freeform_text IS NOT NULL AND length(freeform_text) > 0 AND weight_canonical_mg IS NULL AND percentage IS NULL AND target_rpe IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class WorkoutSetData extends DataClass implements Insertable<WorkoutSetData> {
  final int id;
  final int workoutExerciseId;
  final int setIndex;
  final String repType;
  final int? targetReps;
  final int? minReps;
  final int? maxReps;
  final String loadType;
  final int? weightCanonicalMg;
  final int? percentage;
  final double? targetRpe;
  final String? freeformText;
  final int restSeconds;
  const WorkoutSetData({
    required this.id,
    required this.workoutExerciseId,
    required this.setIndex,
    required this.repType,
    this.targetReps,
    this.minReps,
    this.maxReps,
    required this.loadType,
    this.weightCanonicalMg,
    this.percentage,
    this.targetRpe,
    this.freeformText,
    required this.restSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_exercise_id'] = Variable<int>(workoutExerciseId);
    map['set_index'] = Variable<int>(setIndex);
    map['rep_type'] = Variable<String>(repType);
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || minReps != null) {
      map['min_reps'] = Variable<int>(minReps);
    }
    if (!nullToAbsent || maxReps != null) {
      map['max_reps'] = Variable<int>(maxReps);
    }
    map['load_type'] = Variable<String>(loadType);
    if (!nullToAbsent || weightCanonicalMg != null) {
      map['weight_canonical_mg'] = Variable<int>(weightCanonicalMg);
    }
    if (!nullToAbsent || percentage != null) {
      map['percentage'] = Variable<int>(percentage);
    }
    if (!nullToAbsent || targetRpe != null) {
      map['target_rpe'] = Variable<double>(targetRpe);
    }
    if (!nullToAbsent || freeformText != null) {
      map['freeform_text'] = Variable<String>(freeformText);
    }
    map['rest_seconds'] = Variable<int>(restSeconds);
    return map;
  }

  WorkoutSetCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetCompanion(
      id: Value(id),
      workoutExerciseId: Value(workoutExerciseId),
      setIndex: Value(setIndex),
      repType: Value(repType),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      minReps: minReps == null && nullToAbsent
          ? const Value.absent()
          : Value(minReps),
      maxReps: maxReps == null && nullToAbsent
          ? const Value.absent()
          : Value(maxReps),
      loadType: Value(loadType),
      weightCanonicalMg: weightCanonicalMg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightCanonicalMg),
      percentage: percentage == null && nullToAbsent
          ? const Value.absent()
          : Value(percentage),
      targetRpe: targetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRpe),
      freeformText: freeformText == null && nullToAbsent
          ? const Value.absent()
          : Value(freeformText),
      restSeconds: Value(restSeconds),
    );
  }

  factory WorkoutSetData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSetData(
      id: serializer.fromJson<int>(json['id']),
      workoutExerciseId: serializer.fromJson<int>(json['workout_exercise_id']),
      setIndex: serializer.fromJson<int>(json['set_index']),
      repType: serializer.fromJson<String>(json['rep_type']),
      targetReps: serializer.fromJson<int?>(json['target_reps']),
      minReps: serializer.fromJson<int?>(json['min_reps']),
      maxReps: serializer.fromJson<int?>(json['max_reps']),
      loadType: serializer.fromJson<String>(json['load_type']),
      weightCanonicalMg: serializer.fromJson<int?>(json['weight_canonical_mg']),
      percentage: serializer.fromJson<int?>(json['percentage']),
      targetRpe: serializer.fromJson<double?>(json['target_rpe']),
      freeformText: serializer.fromJson<String?>(json['freeform_text']),
      restSeconds: serializer.fromJson<int>(json['rest_seconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workout_exercise_id': serializer.toJson<int>(workoutExerciseId),
      'set_index': serializer.toJson<int>(setIndex),
      'rep_type': serializer.toJson<String>(repType),
      'target_reps': serializer.toJson<int?>(targetReps),
      'min_reps': serializer.toJson<int?>(minReps),
      'max_reps': serializer.toJson<int?>(maxReps),
      'load_type': serializer.toJson<String>(loadType),
      'weight_canonical_mg': serializer.toJson<int?>(weightCanonicalMg),
      'percentage': serializer.toJson<int?>(percentage),
      'target_rpe': serializer.toJson<double?>(targetRpe),
      'freeform_text': serializer.toJson<String?>(freeformText),
      'rest_seconds': serializer.toJson<int>(restSeconds),
    };
  }

  WorkoutSetData copyWith({
    int? id,
    int? workoutExerciseId,
    int? setIndex,
    String? repType,
    Value<int?> targetReps = const Value.absent(),
    Value<int?> minReps = const Value.absent(),
    Value<int?> maxReps = const Value.absent(),
    String? loadType,
    Value<int?> weightCanonicalMg = const Value.absent(),
    Value<int?> percentage = const Value.absent(),
    Value<double?> targetRpe = const Value.absent(),
    Value<String?> freeformText = const Value.absent(),
    int? restSeconds,
  }) => WorkoutSetData(
    id: id ?? this.id,
    workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
    setIndex: setIndex ?? this.setIndex,
    repType: repType ?? this.repType,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    minReps: minReps.present ? minReps.value : this.minReps,
    maxReps: maxReps.present ? maxReps.value : this.maxReps,
    loadType: loadType ?? this.loadType,
    weightCanonicalMg: weightCanonicalMg.present
        ? weightCanonicalMg.value
        : this.weightCanonicalMg,
    percentage: percentage.present ? percentage.value : this.percentage,
    targetRpe: targetRpe.present ? targetRpe.value : this.targetRpe,
    freeformText: freeformText.present ? freeformText.value : this.freeformText,
    restSeconds: restSeconds ?? this.restSeconds,
  );
  WorkoutSetData copyWithCompanion(WorkoutSetCompanion data) {
    return WorkoutSetData(
      id: data.id.present ? data.id.value : this.id,
      workoutExerciseId: data.workoutExerciseId.present
          ? data.workoutExerciseId.value
          : this.workoutExerciseId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      repType: data.repType.present ? data.repType.value : this.repType,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      minReps: data.minReps.present ? data.minReps.value : this.minReps,
      maxReps: data.maxReps.present ? data.maxReps.value : this.maxReps,
      loadType: data.loadType.present ? data.loadType.value : this.loadType,
      weightCanonicalMg: data.weightCanonicalMg.present
          ? data.weightCanonicalMg.value
          : this.weightCanonicalMg,
      percentage: data.percentage.present
          ? data.percentage.value
          : this.percentage,
      targetRpe: data.targetRpe.present ? data.targetRpe.value : this.targetRpe,
      freeformText: data.freeformText.present
          ? data.freeformText.value
          : this.freeformText,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetData(')
          ..write('id: $id, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('repType: $repType, ')
          ..write('targetReps: $targetReps, ')
          ..write('minReps: $minReps, ')
          ..write('maxReps: $maxReps, ')
          ..write('loadType: $loadType, ')
          ..write('weightCanonicalMg: $weightCanonicalMg, ')
          ..write('percentage: $percentage, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('freeformText: $freeformText, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutExerciseId,
    setIndex,
    repType,
    targetReps,
    minReps,
    maxReps,
    loadType,
    weightCanonicalMg,
    percentage,
    targetRpe,
    freeformText,
    restSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSetData &&
          other.id == this.id &&
          other.workoutExerciseId == this.workoutExerciseId &&
          other.setIndex == this.setIndex &&
          other.repType == this.repType &&
          other.targetReps == this.targetReps &&
          other.minReps == this.minReps &&
          other.maxReps == this.maxReps &&
          other.loadType == this.loadType &&
          other.weightCanonicalMg == this.weightCanonicalMg &&
          other.percentage == this.percentage &&
          other.targetRpe == this.targetRpe &&
          other.freeformText == this.freeformText &&
          other.restSeconds == this.restSeconds);
}

class WorkoutSetCompanion extends UpdateCompanion<WorkoutSetData> {
  final Value<int> id;
  final Value<int> workoutExerciseId;
  final Value<int> setIndex;
  final Value<String> repType;
  final Value<int?> targetReps;
  final Value<int?> minReps;
  final Value<int?> maxReps;
  final Value<String> loadType;
  final Value<int?> weightCanonicalMg;
  final Value<int?> percentage;
  final Value<double?> targetRpe;
  final Value<String?> freeformText;
  final Value<int> restSeconds;
  const WorkoutSetCompanion({
    this.id = const Value.absent(),
    this.workoutExerciseId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.repType = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.minReps = const Value.absent(),
    this.maxReps = const Value.absent(),
    this.loadType = const Value.absent(),
    this.weightCanonicalMg = const Value.absent(),
    this.percentage = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.freeformText = const Value.absent(),
    this.restSeconds = const Value.absent(),
  });
  WorkoutSetCompanion.insert({
    this.id = const Value.absent(),
    required int workoutExerciseId,
    required int setIndex,
    required String repType,
    this.targetReps = const Value.absent(),
    this.minReps = const Value.absent(),
    this.maxReps = const Value.absent(),
    required String loadType,
    this.weightCanonicalMg = const Value.absent(),
    this.percentage = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.freeformText = const Value.absent(),
    required int restSeconds,
  }) : workoutExerciseId = Value(workoutExerciseId),
       setIndex = Value(setIndex),
       repType = Value(repType),
       loadType = Value(loadType),
       restSeconds = Value(restSeconds);
  static Insertable<WorkoutSetData> custom({
    Expression<int>? id,
    Expression<int>? workoutExerciseId,
    Expression<int>? setIndex,
    Expression<String>? repType,
    Expression<int>? targetReps,
    Expression<int>? minReps,
    Expression<int>? maxReps,
    Expression<String>? loadType,
    Expression<int>? weightCanonicalMg,
    Expression<int>? percentage,
    Expression<double>? targetRpe,
    Expression<String>? freeformText,
    Expression<int>? restSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutExerciseId != null) 'workout_exercise_id': workoutExerciseId,
      if (setIndex != null) 'set_index': setIndex,
      if (repType != null) 'rep_type': repType,
      if (targetReps != null) 'target_reps': targetReps,
      if (minReps != null) 'min_reps': minReps,
      if (maxReps != null) 'max_reps': maxReps,
      if (loadType != null) 'load_type': loadType,
      if (weightCanonicalMg != null) 'weight_canonical_mg': weightCanonicalMg,
      if (percentage != null) 'percentage': percentage,
      if (targetRpe != null) 'target_rpe': targetRpe,
      if (freeformText != null) 'freeform_text': freeformText,
      if (restSeconds != null) 'rest_seconds': restSeconds,
    });
  }

  WorkoutSetCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutExerciseId,
    Value<int>? setIndex,
    Value<String>? repType,
    Value<int?>? targetReps,
    Value<int?>? minReps,
    Value<int?>? maxReps,
    Value<String>? loadType,
    Value<int?>? weightCanonicalMg,
    Value<int?>? percentage,
    Value<double?>? targetRpe,
    Value<String?>? freeformText,
    Value<int>? restSeconds,
  }) {
    return WorkoutSetCompanion(
      id: id ?? this.id,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      setIndex: setIndex ?? this.setIndex,
      repType: repType ?? this.repType,
      targetReps: targetReps ?? this.targetReps,
      minReps: minReps ?? this.minReps,
      maxReps: maxReps ?? this.maxReps,
      loadType: loadType ?? this.loadType,
      weightCanonicalMg: weightCanonicalMg ?? this.weightCanonicalMg,
      percentage: percentage ?? this.percentage,
      targetRpe: targetRpe ?? this.targetRpe,
      freeformText: freeformText ?? this.freeformText,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutExerciseId.present) {
      map['workout_exercise_id'] = Variable<int>(workoutExerciseId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (repType.present) {
      map['rep_type'] = Variable<String>(repType.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (minReps.present) {
      map['min_reps'] = Variable<int>(minReps.value);
    }
    if (maxReps.present) {
      map['max_reps'] = Variable<int>(maxReps.value);
    }
    if (loadType.present) {
      map['load_type'] = Variable<String>(loadType.value);
    }
    if (weightCanonicalMg.present) {
      map['weight_canonical_mg'] = Variable<int>(weightCanonicalMg.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<int>(percentage.value);
    }
    if (targetRpe.present) {
      map['target_rpe'] = Variable<double>(targetRpe.value);
    }
    if (freeformText.present) {
      map['freeform_text'] = Variable<String>(freeformText.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetCompanion(')
          ..write('id: $id, ')
          ..write('workoutExerciseId: $workoutExerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('repType: $repType, ')
          ..write('targetReps: $targetReps, ')
          ..write('minReps: $minReps, ')
          ..write('maxReps: $maxReps, ')
          ..write('loadType: $loadType, ')
          ..write('weightCanonicalMg: $weightCanonicalMg, ')
          ..write('percentage: $percentage, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('freeformText: $freeformText, ')
          ..write('restSeconds: $restSeconds')
          ..write(')'))
        .toString();
  }
}

class Session extends Table with TableInfo<Session, SessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Session(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES workout(id)ON DELETE SET NULL',
  );
  static const VerificationMeta _scheduleEntryIdMeta = const VerificationMeta(
    'scheduleEntryId',
  );
  late final GeneratedColumn<int> scheduleEntryId = GeneratedColumn<int>(
    'schedule_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES schedule_entry(id)ON DELETE SET NULL',
  );
  static const VerificationMeta _workoutNameSnapshotMeta =
      const VerificationMeta('workoutNameSnapshot');
  late final GeneratedColumn<String> workoutNameSnapshot =
      GeneratedColumn<String>(
        'workout_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _restStartedAtMeta = const VerificationMeta(
    'restStartedAt',
  );
  late final GeneratedColumn<DateTime> restStartedAt =
      GeneratedColumn<DateTime>(
        'rest_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _restDurationSecondsMeta =
      const VerificationMeta('restDurationSeconds');
  late final GeneratedColumn<int> restDurationSeconds = GeneratedColumn<int>(
    'rest_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _restTargetAtMeta = const VerificationMeta(
    'restTargetAt',
  );
  late final GeneratedColumn<DateTime> restTargetAt = GeneratedColumn<DateTime>(
    'rest_target_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    scheduleEntryId,
    workoutNameSnapshot,
    startedAt,
    endedAt,
    timezone,
    status,
    notes,
    restStartedAt,
    restDurationSeconds,
    restTargetAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    }
    if (data.containsKey('schedule_entry_id')) {
      context.handle(
        _scheduleEntryIdMeta,
        scheduleEntryId.isAcceptableOrUnknown(
          data['schedule_entry_id']!,
          _scheduleEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('workout_name_snapshot')) {
      context.handle(
        _workoutNameSnapshotMeta,
        workoutNameSnapshot.isAcceptableOrUnknown(
          data['workout_name_snapshot']!,
          _workoutNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutNameSnapshotMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('rest_started_at')) {
      context.handle(
        _restStartedAtMeta,
        restStartedAt.isAcceptableOrUnknown(
          data['rest_started_at']!,
          _restStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('rest_duration_seconds')) {
      context.handle(
        _restDurationSecondsMeta,
        restDurationSeconds.isAcceptableOrUnknown(
          data['rest_duration_seconds']!,
          _restDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rest_target_at')) {
      context.handle(
        _restTargetAtMeta,
        restTargetAt.isAcceptableOrUnknown(
          data['rest_target_at']!,
          _restTargetAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id, scheduleEntryId},
  ];
  @override
  SessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      ),
      scheduleEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_entry_id'],
      ),
      workoutNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_name_snapshot'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      restStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rest_started_at'],
      ),
      restDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_duration_seconds'],
      ),
      restTargetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rest_target_at'],
      ),
    );
  }

  @override
  Session createAlias(String alias) {
    return Session(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(id, schedule_entry_id)',
    'CONSTRAINT session_timezone CHECK(length(timezone) > 0)',
    'CONSTRAINT session_status CHECK(status IN (\'draft\', \'running\', \'paused\', \'finished\', \'abandoned\'))',
    'CONSTRAINT session_rest_group CHECK((rest_started_at IS NULL AND rest_duration_seconds IS NULL AND rest_target_at IS NULL)OR(rest_started_at IS NOT NULL AND rest_duration_seconds IS NOT NULL AND rest_duration_seconds >= 0 AND rest_target_at IS NOT NULL AND rest_target_at = rest_started_at + rest_duration_seconds))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SessionData extends DataClass implements Insertable<SessionData> {
  final int id;
  final int? workoutId;
  final int? scheduleEntryId;
  final String workoutNameSnapshot;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String timezone;
  final String status;
  final String? notes;
  final DateTime? restStartedAt;
  final int? restDurationSeconds;
  final DateTime? restTargetAt;
  const SessionData({
    required this.id,
    this.workoutId,
    this.scheduleEntryId,
    required this.workoutNameSnapshot,
    required this.startedAt,
    this.endedAt,
    required this.timezone,
    required this.status,
    this.notes,
    this.restStartedAt,
    this.restDurationSeconds,
    this.restTargetAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<int>(workoutId);
    }
    if (!nullToAbsent || scheduleEntryId != null) {
      map['schedule_entry_id'] = Variable<int>(scheduleEntryId);
    }
    map['workout_name_snapshot'] = Variable<String>(workoutNameSnapshot);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['timezone'] = Variable<String>(timezone);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || restStartedAt != null) {
      map['rest_started_at'] = Variable<DateTime>(restStartedAt);
    }
    if (!nullToAbsent || restDurationSeconds != null) {
      map['rest_duration_seconds'] = Variable<int>(restDurationSeconds);
    }
    if (!nullToAbsent || restTargetAt != null) {
      map['rest_target_at'] = Variable<DateTime>(restTargetAt);
    }
    return map;
  }

  SessionCompanion toCompanion(bool nullToAbsent) {
    return SessionCompanion(
      id: Value(id),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      scheduleEntryId: scheduleEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleEntryId),
      workoutNameSnapshot: Value(workoutNameSnapshot),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      timezone: Value(timezone),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      restStartedAt: restStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(restStartedAt),
      restDurationSeconds: restDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restDurationSeconds),
      restTargetAt: restTargetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(restTargetAt),
    );
  }

  factory SessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionData(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int?>(json['workout_id']),
      scheduleEntryId: serializer.fromJson<int?>(json['schedule_entry_id']),
      workoutNameSnapshot: serializer.fromJson<String>(
        json['workout_name_snapshot'],
      ),
      startedAt: serializer.fromJson<DateTime>(json['started_at']),
      endedAt: serializer.fromJson<DateTime?>(json['ended_at']),
      timezone: serializer.fromJson<String>(json['timezone']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      restStartedAt: serializer.fromJson<DateTime?>(json['rest_started_at']),
      restDurationSeconds: serializer.fromJson<int?>(
        json['rest_duration_seconds'],
      ),
      restTargetAt: serializer.fromJson<DateTime?>(json['rest_target_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workout_id': serializer.toJson<int?>(workoutId),
      'schedule_entry_id': serializer.toJson<int?>(scheduleEntryId),
      'workout_name_snapshot': serializer.toJson<String>(workoutNameSnapshot),
      'started_at': serializer.toJson<DateTime>(startedAt),
      'ended_at': serializer.toJson<DateTime?>(endedAt),
      'timezone': serializer.toJson<String>(timezone),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'rest_started_at': serializer.toJson<DateTime?>(restStartedAt),
      'rest_duration_seconds': serializer.toJson<int?>(restDurationSeconds),
      'rest_target_at': serializer.toJson<DateTime?>(restTargetAt),
    };
  }

  SessionData copyWith({
    int? id,
    Value<int?> workoutId = const Value.absent(),
    Value<int?> scheduleEntryId = const Value.absent(),
    String? workoutNameSnapshot,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? timezone,
    String? status,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> restStartedAt = const Value.absent(),
    Value<int?> restDurationSeconds = const Value.absent(),
    Value<DateTime?> restTargetAt = const Value.absent(),
  }) => SessionData(
    id: id ?? this.id,
    workoutId: workoutId.present ? workoutId.value : this.workoutId,
    scheduleEntryId: scheduleEntryId.present
        ? scheduleEntryId.value
        : this.scheduleEntryId,
    workoutNameSnapshot: workoutNameSnapshot ?? this.workoutNameSnapshot,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    timezone: timezone ?? this.timezone,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    restStartedAt: restStartedAt.present
        ? restStartedAt.value
        : this.restStartedAt,
    restDurationSeconds: restDurationSeconds.present
        ? restDurationSeconds.value
        : this.restDurationSeconds,
    restTargetAt: restTargetAt.present ? restTargetAt.value : this.restTargetAt,
  );
  SessionData copyWithCompanion(SessionCompanion data) {
    return SessionData(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      scheduleEntryId: data.scheduleEntryId.present
          ? data.scheduleEntryId.value
          : this.scheduleEntryId,
      workoutNameSnapshot: data.workoutNameSnapshot.present
          ? data.workoutNameSnapshot.value
          : this.workoutNameSnapshot,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      restStartedAt: data.restStartedAt.present
          ? data.restStartedAt.value
          : this.restStartedAt,
      restDurationSeconds: data.restDurationSeconds.present
          ? data.restDurationSeconds.value
          : this.restDurationSeconds,
      restTargetAt: data.restTargetAt.present
          ? data.restTargetAt.value
          : this.restTargetAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionData(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('scheduleEntryId: $scheduleEntryId, ')
          ..write('workoutNameSnapshot: $workoutNameSnapshot, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('timezone: $timezone, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('restStartedAt: $restStartedAt, ')
          ..write('restDurationSeconds: $restDurationSeconds, ')
          ..write('restTargetAt: $restTargetAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workoutId,
    scheduleEntryId,
    workoutNameSnapshot,
    startedAt,
    endedAt,
    timezone,
    status,
    notes,
    restStartedAt,
    restDurationSeconds,
    restTargetAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionData &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.scheduleEntryId == this.scheduleEntryId &&
          other.workoutNameSnapshot == this.workoutNameSnapshot &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.timezone == this.timezone &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.restStartedAt == this.restStartedAt &&
          other.restDurationSeconds == this.restDurationSeconds &&
          other.restTargetAt == this.restTargetAt);
}

class SessionCompanion extends UpdateCompanion<SessionData> {
  final Value<int> id;
  final Value<int?> workoutId;
  final Value<int?> scheduleEntryId;
  final Value<String> workoutNameSnapshot;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> timezone;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime?> restStartedAt;
  final Value<int?> restDurationSeconds;
  final Value<DateTime?> restTargetAt;
  const SessionCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.scheduleEntryId = const Value.absent(),
    this.workoutNameSnapshot = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.timezone = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.restStartedAt = const Value.absent(),
    this.restDurationSeconds = const Value.absent(),
    this.restTargetAt = const Value.absent(),
  });
  SessionCompanion.insert({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.scheduleEntryId = const Value.absent(),
    required String workoutNameSnapshot,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required String timezone,
    required String status,
    this.notes = const Value.absent(),
    this.restStartedAt = const Value.absent(),
    this.restDurationSeconds = const Value.absent(),
    this.restTargetAt = const Value.absent(),
  }) : workoutNameSnapshot = Value(workoutNameSnapshot),
       startedAt = Value(startedAt),
       timezone = Value(timezone),
       status = Value(status);
  static Insertable<SessionData> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<int>? scheduleEntryId,
    Expression<String>? workoutNameSnapshot,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? timezone,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? restStartedAt,
    Expression<int>? restDurationSeconds,
    Expression<DateTime>? restTargetAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (scheduleEntryId != null) 'schedule_entry_id': scheduleEntryId,
      if (workoutNameSnapshot != null)
        'workout_name_snapshot': workoutNameSnapshot,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (timezone != null) 'timezone': timezone,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (restStartedAt != null) 'rest_started_at': restStartedAt,
      if (restDurationSeconds != null)
        'rest_duration_seconds': restDurationSeconds,
      if (restTargetAt != null) 'rest_target_at': restTargetAt,
    });
  }

  SessionCompanion copyWith({
    Value<int>? id,
    Value<int?>? workoutId,
    Value<int?>? scheduleEntryId,
    Value<String>? workoutNameSnapshot,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? timezone,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime?>? restStartedAt,
    Value<int?>? restDurationSeconds,
    Value<DateTime?>? restTargetAt,
  }) {
    return SessionCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      scheduleEntryId: scheduleEntryId ?? this.scheduleEntryId,
      workoutNameSnapshot: workoutNameSnapshot ?? this.workoutNameSnapshot,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      restStartedAt: restStartedAt ?? this.restStartedAt,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      restTargetAt: restTargetAt ?? this.restTargetAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (scheduleEntryId.present) {
      map['schedule_entry_id'] = Variable<int>(scheduleEntryId.value);
    }
    if (workoutNameSnapshot.present) {
      map['workout_name_snapshot'] = Variable<String>(
        workoutNameSnapshot.value,
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (restStartedAt.present) {
      map['rest_started_at'] = Variable<DateTime>(restStartedAt.value);
    }
    if (restDurationSeconds.present) {
      map['rest_duration_seconds'] = Variable<int>(restDurationSeconds.value);
    }
    if (restTargetAt.present) {
      map['rest_target_at'] = Variable<DateTime>(restTargetAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('scheduleEntryId: $scheduleEntryId, ')
          ..write('workoutNameSnapshot: $workoutNameSnapshot, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('timezone: $timezone, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('restStartedAt: $restStartedAt, ')
          ..write('restDurationSeconds: $restDurationSeconds, ')
          ..write('restTargetAt: $restTargetAt')
          ..write(')'))
        .toString();
  }
}

class ScheduleEntry extends Table
    with TableInfo<ScheduleEntry, ScheduleEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ScheduleEntry(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _workoutIdMeta = const VerificationMeta(
    'workoutId',
  );
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
    'workout_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES workout(id)ON DELETE RESTRICT',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES session(id)ON DELETE RESTRICT',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutId,
    date,
    startTime,
    label,
    status,
    sessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_entry';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleEntryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(
        _workoutIdMeta,
        workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleEntryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
    );
  }

  @override
  ScheduleEntry createAlias(String alias) {
    return ScheduleEntry(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(session_id, id)REFERENCES session(id, schedule_entry_id)ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED',
    'CONSTRAINT schedule_entry_date CHECK(date GLOB \'[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\' AND date(date) = date)',
    'CONSTRAINT schedule_entry_start_time CHECK(start_time IS NULL OR(start_time >= 0 AND start_time <= 1439))',
    'CONSTRAINT schedule_entry_status_session CHECK((status = \'planned\' AND session_id IS NULL)OR(status = \'skipped\' AND session_id IS NULL)OR(status = \'completed_by_session\' AND session_id IS NOT NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ScheduleEntryData extends DataClass
    implements Insertable<ScheduleEntryData> {
  final int id;
  final int workoutId;
  final String date;
  final int? startTime;
  final String? label;
  final String status;
  final int? sessionId;
  const ScheduleEntryData({
    required this.id,
    required this.workoutId,
    required this.date,
    this.startTime,
    this.label,
    required this.status,
    this.sessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<int>(startTime);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    return map;
  }

  ScheduleEntryCompanion toCompanion(bool nullToAbsent) {
    return ScheduleEntryCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      date: Value(date),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      status: Value(status),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
    );
  }

  factory ScheduleEntryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleEntryData(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workout_id']),
      date: serializer.fromJson<String>(json['date']),
      startTime: serializer.fromJson<int?>(json['start_time']),
      label: serializer.fromJson<String?>(json['label']),
      status: serializer.fromJson<String>(json['status']),
      sessionId: serializer.fromJson<int?>(json['session_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workout_id': serializer.toJson<int>(workoutId),
      'date': serializer.toJson<String>(date),
      'start_time': serializer.toJson<int?>(startTime),
      'label': serializer.toJson<String?>(label),
      'status': serializer.toJson<String>(status),
      'session_id': serializer.toJson<int?>(sessionId),
    };
  }

  ScheduleEntryData copyWith({
    int? id,
    int? workoutId,
    String? date,
    Value<int?> startTime = const Value.absent(),
    Value<String?> label = const Value.absent(),
    String? status,
    Value<int?> sessionId = const Value.absent(),
  }) => ScheduleEntryData(
    id: id ?? this.id,
    workoutId: workoutId ?? this.workoutId,
    date: date ?? this.date,
    startTime: startTime.present ? startTime.value : this.startTime,
    label: label.present ? label.value : this.label,
    status: status ?? this.status,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
  );
  ScheduleEntryData copyWithCompanion(ScheduleEntryCompanion data) {
    return ScheduleEntryData(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      label: data.label.present ? data.label.value : this.label,
      status: data.status.present ? data.status.value : this.status,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleEntryData(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutId, date, startTime, label, status, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleEntryData &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.label == this.label &&
          other.status == this.status &&
          other.sessionId == this.sessionId);
}

class ScheduleEntryCompanion extends UpdateCompanion<ScheduleEntryData> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<String> date;
  final Value<int?> startTime;
  final Value<String?> label;
  final Value<String> status;
  final Value<int?> sessionId;
  const ScheduleEntryCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.label = const Value.absent(),
    this.status = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  ScheduleEntryCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required String date,
    this.startTime = const Value.absent(),
    this.label = const Value.absent(),
    required String status,
    this.sessionId = const Value.absent(),
  }) : workoutId = Value(workoutId),
       date = Value(date),
       status = Value(status);
  static Insertable<ScheduleEntryData> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<String>? date,
    Expression<int>? startTime,
    Expression<String>? label,
    Expression<String>? status,
    Expression<int>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (label != null) 'label': label,
      if (status != null) 'status': status,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  ScheduleEntryCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutId,
    Value<String>? date,
    Value<int?>? startTime,
    Value<String?>? label,
    Value<String>? status,
    Value<int?>? sessionId,
  }) {
    return ScheduleEntryCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      label: label ?? this.label,
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleEntryCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('label: $label, ')
          ..write('status: $status, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

class SessionExercise extends Table
    with TableInfo<SessionExercise, SessionExerciseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SessionExercise(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES session(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _nameSnapshotMeta = const VerificationMeta(
    'nameSnapshot',
  );
  late final GeneratedColumn<String> nameSnapshot = GeneratedColumn<String>(
    'name_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedSetsMeta = const VerificationMeta(
    'plannedSets',
  );
  late final GeneratedColumn<int> plannedSets = GeneratedColumn<int>(
    'planned_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedRepTypeMeta = const VerificationMeta(
    'plannedRepType',
  );
  late final GeneratedColumn<String> plannedRepType = GeneratedColumn<String>(
    'planned_rep_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedTargetRepsMeta = const VerificationMeta(
    'plannedTargetReps',
  );
  late final GeneratedColumn<int> plannedTargetReps = GeneratedColumn<int>(
    'planned_target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedMinRepsMeta = const VerificationMeta(
    'plannedMinReps',
  );
  late final GeneratedColumn<int> plannedMinReps = GeneratedColumn<int>(
    'planned_min_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedMaxRepsMeta = const VerificationMeta(
    'plannedMaxReps',
  );
  late final GeneratedColumn<int> plannedMaxReps = GeneratedColumn<int>(
    'planned_max_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedLoadTypeMeta = const VerificationMeta(
    'plannedLoadType',
  );
  late final GeneratedColumn<String> plannedLoadType = GeneratedColumn<String>(
    'planned_load_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedWeightCanonicalMgMeta =
      const VerificationMeta('plannedWeightCanonicalMg');
  late final GeneratedColumn<int> plannedWeightCanonicalMg =
      GeneratedColumn<int>(
        'planned_weight_canonical_mg',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _plannedPercentageMeta = const VerificationMeta(
    'plannedPercentage',
  );
  late final GeneratedColumn<int> plannedPercentage = GeneratedColumn<int>(
    'planned_percentage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedTargetRpeMeta = const VerificationMeta(
    'plannedTargetRpe',
  );
  late final GeneratedColumn<double> plannedTargetRpe = GeneratedColumn<double>(
    'planned_target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedFreeformTextMeta =
      const VerificationMeta('plannedFreeformText');
  late final GeneratedColumn<String> plannedFreeformText =
      GeneratedColumn<String>(
        'planned_freeform_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _plannedRestSecondsMeta =
      const VerificationMeta('plannedRestSeconds');
  late final GeneratedColumn<int> plannedRestSeconds = GeneratedColumn<int>(
    'planned_rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    nameSnapshot,
    normalizedName,
    orderIndex,
    plannedSets,
    plannedRepType,
    plannedTargetReps,
    plannedMinReps,
    plannedMaxReps,
    plannedLoadType,
    plannedWeightCanonicalMg,
    plannedPercentage,
    plannedTargetRpe,
    plannedFreeformText,
    plannedRestSeconds,
    supersetGroup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercise';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExerciseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('name_snapshot')) {
      context.handle(
        _nameSnapshotMeta,
        nameSnapshot.isAcceptableOrUnknown(
          data['name_snapshot']!,
          _nameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameSnapshotMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('planned_sets')) {
      context.handle(
        _plannedSetsMeta,
        plannedSets.isAcceptableOrUnknown(
          data['planned_sets']!,
          _plannedSetsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedSetsMeta);
    }
    if (data.containsKey('planned_rep_type')) {
      context.handle(
        _plannedRepTypeMeta,
        plannedRepType.isAcceptableOrUnknown(
          data['planned_rep_type']!,
          _plannedRepTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedRepTypeMeta);
    }
    if (data.containsKey('planned_target_reps')) {
      context.handle(
        _plannedTargetRepsMeta,
        plannedTargetReps.isAcceptableOrUnknown(
          data['planned_target_reps']!,
          _plannedTargetRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_min_reps')) {
      context.handle(
        _plannedMinRepsMeta,
        plannedMinReps.isAcceptableOrUnknown(
          data['planned_min_reps']!,
          _plannedMinRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_max_reps')) {
      context.handle(
        _plannedMaxRepsMeta,
        plannedMaxReps.isAcceptableOrUnknown(
          data['planned_max_reps']!,
          _plannedMaxRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_load_type')) {
      context.handle(
        _plannedLoadTypeMeta,
        plannedLoadType.isAcceptableOrUnknown(
          data['planned_load_type']!,
          _plannedLoadTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedLoadTypeMeta);
    }
    if (data.containsKey('planned_weight_canonical_mg')) {
      context.handle(
        _plannedWeightCanonicalMgMeta,
        plannedWeightCanonicalMg.isAcceptableOrUnknown(
          data['planned_weight_canonical_mg']!,
          _plannedWeightCanonicalMgMeta,
        ),
      );
    }
    if (data.containsKey('planned_percentage')) {
      context.handle(
        _plannedPercentageMeta,
        plannedPercentage.isAcceptableOrUnknown(
          data['planned_percentage']!,
          _plannedPercentageMeta,
        ),
      );
    }
    if (data.containsKey('planned_target_rpe')) {
      context.handle(
        _plannedTargetRpeMeta,
        plannedTargetRpe.isAcceptableOrUnknown(
          data['planned_target_rpe']!,
          _plannedTargetRpeMeta,
        ),
      );
    }
    if (data.containsKey('planned_freeform_text')) {
      context.handle(
        _plannedFreeformTextMeta,
        plannedFreeformText.isAcceptableOrUnknown(
          data['planned_freeform_text']!,
          _plannedFreeformTextMeta,
        ),
      );
    }
    if (data.containsKey('planned_rest_seconds')) {
      context.handle(
        _plannedRestSecondsMeta,
        plannedRestSeconds.isAcceptableOrUnknown(
          data['planned_rest_seconds']!,
          _plannedRestSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedRestSecondsMeta);
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExerciseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      nameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_snapshot'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      plannedSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_sets'],
      )!,
      plannedRepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_rep_type'],
      )!,
      plannedTargetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_target_reps'],
      ),
      plannedMinReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_min_reps'],
      ),
      plannedMaxReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_max_reps'],
      ),
      plannedLoadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_load_type'],
      )!,
      plannedWeightCanonicalMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_weight_canonical_mg'],
      ),
      plannedPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_percentage'],
      ),
      plannedTargetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_target_rpe'],
      ),
      plannedFreeformText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_freeform_text'],
      ),
      plannedRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_rest_seconds'],
      )!,
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
    );
  }

  @override
  SessionExercise createAlias(String alias) {
    return SessionExercise(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CONSTRAINT session_exercise_order CHECK(order_index >= 0)',
    'CONSTRAINT session_exercise_planned_sets CHECK(planned_sets >= 1)',
    'CONSTRAINT session_exercise_rest CHECK(planned_rest_seconds >= 0)',
    'CONSTRAINT session_exercise_superset CHECK(superset_group IS NULL OR superset_group >= 0)',
    'CONSTRAINT session_exercise_rep_fields CHECK((planned_rep_type = \'fixed\' AND planned_target_reps IS NOT NULL AND planned_target_reps >= 1 AND planned_min_reps IS NULL AND planned_max_reps IS NULL)OR(planned_rep_type = \'range\' AND planned_target_reps IS NULL AND planned_min_reps IS NOT NULL AND planned_max_reps IS NOT NULL AND planned_min_reps >= 1 AND planned_max_reps >= planned_min_reps)OR(planned_rep_type = \'amrap\' AND planned_target_reps IS NULL AND planned_min_reps IS NULL AND planned_max_reps IS NULL))',
    'CONSTRAINT session_exercise_load_fields CHECK((planned_load_type = \'none\' AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'bodyweight\' AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'absolute\' AND planned_weight_canonical_mg IS NOT NULL AND planned_weight_canonical_mg >= 0 AND planned_percentage IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'percentage\' AND planned_percentage IS NOT NULL AND planned_percentage >= 0 AND planned_percentage <= 100 AND planned_weight_canonical_mg IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'target_rpe\' AND planned_target_rpe IS NOT NULL AND planned_target_rpe >= 0 AND planned_target_rpe <= 10 AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'text\' AND planned_freeform_text IS NOT NULL AND length(planned_freeform_text) > 0 AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_target_rpe IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SessionExerciseData extends DataClass
    implements Insertable<SessionExerciseData> {
  final int id;
  final int sessionId;
  final String nameSnapshot;
  final String normalizedName;
  final int orderIndex;
  final int plannedSets;
  final String plannedRepType;
  final int? plannedTargetReps;
  final int? plannedMinReps;
  final int? plannedMaxReps;
  final String plannedLoadType;
  final int? plannedWeightCanonicalMg;
  final int? plannedPercentage;
  final double? plannedTargetRpe;
  final String? plannedFreeformText;
  final int plannedRestSeconds;
  final int? supersetGroup;
  const SessionExerciseData({
    required this.id,
    required this.sessionId,
    required this.nameSnapshot,
    required this.normalizedName,
    required this.orderIndex,
    required this.plannedSets,
    required this.plannedRepType,
    this.plannedTargetReps,
    this.plannedMinReps,
    this.plannedMaxReps,
    required this.plannedLoadType,
    this.plannedWeightCanonicalMg,
    this.plannedPercentage,
    this.plannedTargetRpe,
    this.plannedFreeformText,
    required this.plannedRestSeconds,
    this.supersetGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['name_snapshot'] = Variable<String>(nameSnapshot);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['order_index'] = Variable<int>(orderIndex);
    map['planned_sets'] = Variable<int>(plannedSets);
    map['planned_rep_type'] = Variable<String>(plannedRepType);
    if (!nullToAbsent || plannedTargetReps != null) {
      map['planned_target_reps'] = Variable<int>(plannedTargetReps);
    }
    if (!nullToAbsent || plannedMinReps != null) {
      map['planned_min_reps'] = Variable<int>(plannedMinReps);
    }
    if (!nullToAbsent || plannedMaxReps != null) {
      map['planned_max_reps'] = Variable<int>(plannedMaxReps);
    }
    map['planned_load_type'] = Variable<String>(plannedLoadType);
    if (!nullToAbsent || plannedWeightCanonicalMg != null) {
      map['planned_weight_canonical_mg'] = Variable<int>(
        plannedWeightCanonicalMg,
      );
    }
    if (!nullToAbsent || plannedPercentage != null) {
      map['planned_percentage'] = Variable<int>(plannedPercentage);
    }
    if (!nullToAbsent || plannedTargetRpe != null) {
      map['planned_target_rpe'] = Variable<double>(plannedTargetRpe);
    }
    if (!nullToAbsent || plannedFreeformText != null) {
      map['planned_freeform_text'] = Variable<String>(plannedFreeformText);
    }
    map['planned_rest_seconds'] = Variable<int>(plannedRestSeconds);
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    return map;
  }

  SessionExerciseCompanion toCompanion(bool nullToAbsent) {
    return SessionExerciseCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      nameSnapshot: Value(nameSnapshot),
      normalizedName: Value(normalizedName),
      orderIndex: Value(orderIndex),
      plannedSets: Value(plannedSets),
      plannedRepType: Value(plannedRepType),
      plannedTargetReps: plannedTargetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedTargetReps),
      plannedMinReps: plannedMinReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedMinReps),
      plannedMaxReps: plannedMaxReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedMaxReps),
      plannedLoadType: Value(plannedLoadType),
      plannedWeightCanonicalMg: plannedWeightCanonicalMg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightCanonicalMg),
      plannedPercentage: plannedPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedPercentage),
      plannedTargetRpe: plannedTargetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedTargetRpe),
      plannedFreeformText: plannedFreeformText == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedFreeformText),
      plannedRestSeconds: Value(plannedRestSeconds),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
    );
  }

  factory SessionExerciseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['session_id']),
      nameSnapshot: serializer.fromJson<String>(json['name_snapshot']),
      normalizedName: serializer.fromJson<String>(json['normalized_name']),
      orderIndex: serializer.fromJson<int>(json['order_index']),
      plannedSets: serializer.fromJson<int>(json['planned_sets']),
      plannedRepType: serializer.fromJson<String>(json['planned_rep_type']),
      plannedTargetReps: serializer.fromJson<int?>(json['planned_target_reps']),
      plannedMinReps: serializer.fromJson<int?>(json['planned_min_reps']),
      plannedMaxReps: serializer.fromJson<int?>(json['planned_max_reps']),
      plannedLoadType: serializer.fromJson<String>(json['planned_load_type']),
      plannedWeightCanonicalMg: serializer.fromJson<int?>(
        json['planned_weight_canonical_mg'],
      ),
      plannedPercentage: serializer.fromJson<int?>(json['planned_percentage']),
      plannedTargetRpe: serializer.fromJson<double?>(
        json['planned_target_rpe'],
      ),
      plannedFreeformText: serializer.fromJson<String?>(
        json['planned_freeform_text'],
      ),
      plannedRestSeconds: serializer.fromJson<int>(
        json['planned_rest_seconds'],
      ),
      supersetGroup: serializer.fromJson<int?>(json['superset_group']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'session_id': serializer.toJson<int>(sessionId),
      'name_snapshot': serializer.toJson<String>(nameSnapshot),
      'normalized_name': serializer.toJson<String>(normalizedName),
      'order_index': serializer.toJson<int>(orderIndex),
      'planned_sets': serializer.toJson<int>(plannedSets),
      'planned_rep_type': serializer.toJson<String>(plannedRepType),
      'planned_target_reps': serializer.toJson<int?>(plannedTargetReps),
      'planned_min_reps': serializer.toJson<int?>(plannedMinReps),
      'planned_max_reps': serializer.toJson<int?>(plannedMaxReps),
      'planned_load_type': serializer.toJson<String>(plannedLoadType),
      'planned_weight_canonical_mg': serializer.toJson<int?>(
        plannedWeightCanonicalMg,
      ),
      'planned_percentage': serializer.toJson<int?>(plannedPercentage),
      'planned_target_rpe': serializer.toJson<double?>(plannedTargetRpe),
      'planned_freeform_text': serializer.toJson<String?>(plannedFreeformText),
      'planned_rest_seconds': serializer.toJson<int>(plannedRestSeconds),
      'superset_group': serializer.toJson<int?>(supersetGroup),
    };
  }

  SessionExerciseData copyWith({
    int? id,
    int? sessionId,
    String? nameSnapshot,
    String? normalizedName,
    int? orderIndex,
    int? plannedSets,
    String? plannedRepType,
    Value<int?> plannedTargetReps = const Value.absent(),
    Value<int?> plannedMinReps = const Value.absent(),
    Value<int?> plannedMaxReps = const Value.absent(),
    String? plannedLoadType,
    Value<int?> plannedWeightCanonicalMg = const Value.absent(),
    Value<int?> plannedPercentage = const Value.absent(),
    Value<double?> plannedTargetRpe = const Value.absent(),
    Value<String?> plannedFreeformText = const Value.absent(),
    int? plannedRestSeconds,
    Value<int?> supersetGroup = const Value.absent(),
  }) => SessionExerciseData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    nameSnapshot: nameSnapshot ?? this.nameSnapshot,
    normalizedName: normalizedName ?? this.normalizedName,
    orderIndex: orderIndex ?? this.orderIndex,
    plannedSets: plannedSets ?? this.plannedSets,
    plannedRepType: plannedRepType ?? this.plannedRepType,
    plannedTargetReps: plannedTargetReps.present
        ? plannedTargetReps.value
        : this.plannedTargetReps,
    plannedMinReps: plannedMinReps.present
        ? plannedMinReps.value
        : this.plannedMinReps,
    plannedMaxReps: plannedMaxReps.present
        ? plannedMaxReps.value
        : this.plannedMaxReps,
    plannedLoadType: plannedLoadType ?? this.plannedLoadType,
    plannedWeightCanonicalMg: plannedWeightCanonicalMg.present
        ? plannedWeightCanonicalMg.value
        : this.plannedWeightCanonicalMg,
    plannedPercentage: plannedPercentage.present
        ? plannedPercentage.value
        : this.plannedPercentage,
    plannedTargetRpe: plannedTargetRpe.present
        ? plannedTargetRpe.value
        : this.plannedTargetRpe,
    plannedFreeformText: plannedFreeformText.present
        ? plannedFreeformText.value
        : this.plannedFreeformText,
    plannedRestSeconds: plannedRestSeconds ?? this.plannedRestSeconds,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
  );
  SessionExerciseData copyWithCompanion(SessionExerciseCompanion data) {
    return SessionExerciseData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      nameSnapshot: data.nameSnapshot.present
          ? data.nameSnapshot.value
          : this.nameSnapshot,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      plannedSets: data.plannedSets.present
          ? data.plannedSets.value
          : this.plannedSets,
      plannedRepType: data.plannedRepType.present
          ? data.plannedRepType.value
          : this.plannedRepType,
      plannedTargetReps: data.plannedTargetReps.present
          ? data.plannedTargetReps.value
          : this.plannedTargetReps,
      plannedMinReps: data.plannedMinReps.present
          ? data.plannedMinReps.value
          : this.plannedMinReps,
      plannedMaxReps: data.plannedMaxReps.present
          ? data.plannedMaxReps.value
          : this.plannedMaxReps,
      plannedLoadType: data.plannedLoadType.present
          ? data.plannedLoadType.value
          : this.plannedLoadType,
      plannedWeightCanonicalMg: data.plannedWeightCanonicalMg.present
          ? data.plannedWeightCanonicalMg.value
          : this.plannedWeightCanonicalMg,
      plannedPercentage: data.plannedPercentage.present
          ? data.plannedPercentage.value
          : this.plannedPercentage,
      plannedTargetRpe: data.plannedTargetRpe.present
          ? data.plannedTargetRpe.value
          : this.plannedTargetRpe,
      plannedFreeformText: data.plannedFreeformText.present
          ? data.plannedFreeformText.value
          : this.plannedFreeformText,
      plannedRestSeconds: data.plannedRestSeconds.present
          ? data.plannedRestSeconds.value
          : this.plannedRestSeconds,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('plannedSets: $plannedSets, ')
          ..write('plannedRepType: $plannedRepType, ')
          ..write('plannedTargetReps: $plannedTargetReps, ')
          ..write('plannedMinReps: $plannedMinReps, ')
          ..write('plannedMaxReps: $plannedMaxReps, ')
          ..write('plannedLoadType: $plannedLoadType, ')
          ..write('plannedWeightCanonicalMg: $plannedWeightCanonicalMg, ')
          ..write('plannedPercentage: $plannedPercentage, ')
          ..write('plannedTargetRpe: $plannedTargetRpe, ')
          ..write('plannedFreeformText: $plannedFreeformText, ')
          ..write('plannedRestSeconds: $plannedRestSeconds, ')
          ..write('supersetGroup: $supersetGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    nameSnapshot,
    normalizedName,
    orderIndex,
    plannedSets,
    plannedRepType,
    plannedTargetReps,
    plannedMinReps,
    plannedMaxReps,
    plannedLoadType,
    plannedWeightCanonicalMg,
    plannedPercentage,
    plannedTargetRpe,
    plannedFreeformText,
    plannedRestSeconds,
    supersetGroup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.nameSnapshot == this.nameSnapshot &&
          other.normalizedName == this.normalizedName &&
          other.orderIndex == this.orderIndex &&
          other.plannedSets == this.plannedSets &&
          other.plannedRepType == this.plannedRepType &&
          other.plannedTargetReps == this.plannedTargetReps &&
          other.plannedMinReps == this.plannedMinReps &&
          other.plannedMaxReps == this.plannedMaxReps &&
          other.plannedLoadType == this.plannedLoadType &&
          other.plannedWeightCanonicalMg == this.plannedWeightCanonicalMg &&
          other.plannedPercentage == this.plannedPercentage &&
          other.plannedTargetRpe == this.plannedTargetRpe &&
          other.plannedFreeformText == this.plannedFreeformText &&
          other.plannedRestSeconds == this.plannedRestSeconds &&
          other.supersetGroup == this.supersetGroup);
}

class SessionExerciseCompanion extends UpdateCompanion<SessionExerciseData> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> nameSnapshot;
  final Value<String> normalizedName;
  final Value<int> orderIndex;
  final Value<int> plannedSets;
  final Value<String> plannedRepType;
  final Value<int?> plannedTargetReps;
  final Value<int?> plannedMinReps;
  final Value<int?> plannedMaxReps;
  final Value<String> plannedLoadType;
  final Value<int?> plannedWeightCanonicalMg;
  final Value<int?> plannedPercentage;
  final Value<double?> plannedTargetRpe;
  final Value<String?> plannedFreeformText;
  final Value<int> plannedRestSeconds;
  final Value<int?> supersetGroup;
  const SessionExerciseCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.nameSnapshot = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.plannedSets = const Value.absent(),
    this.plannedRepType = const Value.absent(),
    this.plannedTargetReps = const Value.absent(),
    this.plannedMinReps = const Value.absent(),
    this.plannedMaxReps = const Value.absent(),
    this.plannedLoadType = const Value.absent(),
    this.plannedWeightCanonicalMg = const Value.absent(),
    this.plannedPercentage = const Value.absent(),
    this.plannedTargetRpe = const Value.absent(),
    this.plannedFreeformText = const Value.absent(),
    this.plannedRestSeconds = const Value.absent(),
    this.supersetGroup = const Value.absent(),
  });
  SessionExerciseCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String nameSnapshot,
    required String normalizedName,
    required int orderIndex,
    required int plannedSets,
    required String plannedRepType,
    this.plannedTargetReps = const Value.absent(),
    this.plannedMinReps = const Value.absent(),
    this.plannedMaxReps = const Value.absent(),
    required String plannedLoadType,
    this.plannedWeightCanonicalMg = const Value.absent(),
    this.plannedPercentage = const Value.absent(),
    this.plannedTargetRpe = const Value.absent(),
    this.plannedFreeformText = const Value.absent(),
    required int plannedRestSeconds,
    this.supersetGroup = const Value.absent(),
  }) : sessionId = Value(sessionId),
       nameSnapshot = Value(nameSnapshot),
       normalizedName = Value(normalizedName),
       orderIndex = Value(orderIndex),
       plannedSets = Value(plannedSets),
       plannedRepType = Value(plannedRepType),
       plannedLoadType = Value(plannedLoadType),
       plannedRestSeconds = Value(plannedRestSeconds);
  static Insertable<SessionExerciseData> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? nameSnapshot,
    Expression<String>? normalizedName,
    Expression<int>? orderIndex,
    Expression<int>? plannedSets,
    Expression<String>? plannedRepType,
    Expression<int>? plannedTargetReps,
    Expression<int>? plannedMinReps,
    Expression<int>? plannedMaxReps,
    Expression<String>? plannedLoadType,
    Expression<int>? plannedWeightCanonicalMg,
    Expression<int>? plannedPercentage,
    Expression<double>? plannedTargetRpe,
    Expression<String>? plannedFreeformText,
    Expression<int>? plannedRestSeconds,
    Expression<int>? supersetGroup,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (nameSnapshot != null) 'name_snapshot': nameSnapshot,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (orderIndex != null) 'order_index': orderIndex,
      if (plannedSets != null) 'planned_sets': plannedSets,
      if (plannedRepType != null) 'planned_rep_type': plannedRepType,
      if (plannedTargetReps != null) 'planned_target_reps': plannedTargetReps,
      if (plannedMinReps != null) 'planned_min_reps': plannedMinReps,
      if (plannedMaxReps != null) 'planned_max_reps': plannedMaxReps,
      if (plannedLoadType != null) 'planned_load_type': plannedLoadType,
      if (plannedWeightCanonicalMg != null)
        'planned_weight_canonical_mg': plannedWeightCanonicalMg,
      if (plannedPercentage != null) 'planned_percentage': plannedPercentage,
      if (plannedTargetRpe != null) 'planned_target_rpe': plannedTargetRpe,
      if (plannedFreeformText != null)
        'planned_freeform_text': plannedFreeformText,
      if (plannedRestSeconds != null)
        'planned_rest_seconds': plannedRestSeconds,
      if (supersetGroup != null) 'superset_group': supersetGroup,
    });
  }

  SessionExerciseCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? nameSnapshot,
    Value<String>? normalizedName,
    Value<int>? orderIndex,
    Value<int>? plannedSets,
    Value<String>? plannedRepType,
    Value<int?>? plannedTargetReps,
    Value<int?>? plannedMinReps,
    Value<int?>? plannedMaxReps,
    Value<String>? plannedLoadType,
    Value<int?>? plannedWeightCanonicalMg,
    Value<int?>? plannedPercentage,
    Value<double?>? plannedTargetRpe,
    Value<String?>? plannedFreeformText,
    Value<int>? plannedRestSeconds,
    Value<int?>? supersetGroup,
  }) {
    return SessionExerciseCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      normalizedName: normalizedName ?? this.normalizedName,
      orderIndex: orderIndex ?? this.orderIndex,
      plannedSets: plannedSets ?? this.plannedSets,
      plannedRepType: plannedRepType ?? this.plannedRepType,
      plannedTargetReps: plannedTargetReps ?? this.plannedTargetReps,
      plannedMinReps: plannedMinReps ?? this.plannedMinReps,
      plannedMaxReps: plannedMaxReps ?? this.plannedMaxReps,
      plannedLoadType: plannedLoadType ?? this.plannedLoadType,
      plannedWeightCanonicalMg:
          plannedWeightCanonicalMg ?? this.plannedWeightCanonicalMg,
      plannedPercentage: plannedPercentage ?? this.plannedPercentage,
      plannedTargetRpe: plannedTargetRpe ?? this.plannedTargetRpe,
      plannedFreeformText: plannedFreeformText ?? this.plannedFreeformText,
      plannedRestSeconds: plannedRestSeconds ?? this.plannedRestSeconds,
      supersetGroup: supersetGroup ?? this.supersetGroup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (nameSnapshot.present) {
      map['name_snapshot'] = Variable<String>(nameSnapshot.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (plannedSets.present) {
      map['planned_sets'] = Variable<int>(plannedSets.value);
    }
    if (plannedRepType.present) {
      map['planned_rep_type'] = Variable<String>(plannedRepType.value);
    }
    if (plannedTargetReps.present) {
      map['planned_target_reps'] = Variable<int>(plannedTargetReps.value);
    }
    if (plannedMinReps.present) {
      map['planned_min_reps'] = Variable<int>(plannedMinReps.value);
    }
    if (plannedMaxReps.present) {
      map['planned_max_reps'] = Variable<int>(plannedMaxReps.value);
    }
    if (plannedLoadType.present) {
      map['planned_load_type'] = Variable<String>(plannedLoadType.value);
    }
    if (plannedWeightCanonicalMg.present) {
      map['planned_weight_canonical_mg'] = Variable<int>(
        plannedWeightCanonicalMg.value,
      );
    }
    if (plannedPercentage.present) {
      map['planned_percentage'] = Variable<int>(plannedPercentage.value);
    }
    if (plannedTargetRpe.present) {
      map['planned_target_rpe'] = Variable<double>(plannedTargetRpe.value);
    }
    if (plannedFreeformText.present) {
      map['planned_freeform_text'] = Variable<String>(
        plannedFreeformText.value,
      );
    }
    if (plannedRestSeconds.present) {
      map['planned_rest_seconds'] = Variable<int>(plannedRestSeconds.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('nameSnapshot: $nameSnapshot, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('plannedSets: $plannedSets, ')
          ..write('plannedRepType: $plannedRepType, ')
          ..write('plannedTargetReps: $plannedTargetReps, ')
          ..write('plannedMinReps: $plannedMinReps, ')
          ..write('plannedMaxReps: $plannedMaxReps, ')
          ..write('plannedLoadType: $plannedLoadType, ')
          ..write('plannedWeightCanonicalMg: $plannedWeightCanonicalMg, ')
          ..write('plannedPercentage: $plannedPercentage, ')
          ..write('plannedTargetRpe: $plannedTargetRpe, ')
          ..write('plannedFreeformText: $plannedFreeformText, ')
          ..write('plannedRestSeconds: $plannedRestSeconds, ')
          ..write('supersetGroup: $supersetGroup')
          ..write(')'))
        .toString();
  }
}

class SessionSet extends Table with TableInfo<SessionSet, SessionSetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SessionSet(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  late final GeneratedColumn<int> sessionExerciseId = GeneratedColumn<int>(
    'session_exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES session_exercise(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedRepTypeMeta = const VerificationMeta(
    'plannedRepType',
  );
  late final GeneratedColumn<String> plannedRepType = GeneratedColumn<String>(
    'planned_rep_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedTargetRepsMeta = const VerificationMeta(
    'plannedTargetReps',
  );
  late final GeneratedColumn<int> plannedTargetReps = GeneratedColumn<int>(
    'planned_target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedMinRepsMeta = const VerificationMeta(
    'plannedMinReps',
  );
  late final GeneratedColumn<int> plannedMinReps = GeneratedColumn<int>(
    'planned_min_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedMaxRepsMeta = const VerificationMeta(
    'plannedMaxReps',
  );
  late final GeneratedColumn<int> plannedMaxReps = GeneratedColumn<int>(
    'planned_max_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedLoadTypeMeta = const VerificationMeta(
    'plannedLoadType',
  );
  late final GeneratedColumn<String> plannedLoadType = GeneratedColumn<String>(
    'planned_load_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _plannedWeightCanonicalMgMeta =
      const VerificationMeta('plannedWeightCanonicalMg');
  late final GeneratedColumn<int> plannedWeightCanonicalMg =
      GeneratedColumn<int>(
        'planned_weight_canonical_mg',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _plannedPercentageMeta = const VerificationMeta(
    'plannedPercentage',
  );
  late final GeneratedColumn<int> plannedPercentage = GeneratedColumn<int>(
    'planned_percentage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedTargetRpeMeta = const VerificationMeta(
    'plannedTargetRpe',
  );
  late final GeneratedColumn<double> plannedTargetRpe = GeneratedColumn<double>(
    'planned_target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedFreeformTextMeta =
      const VerificationMeta('plannedFreeformText');
  late final GeneratedColumn<String> plannedFreeformText =
      GeneratedColumn<String>(
        'planned_freeform_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _actualRepTypeMeta = const VerificationMeta(
    'actualRepType',
  );
  late final GeneratedColumn<String> actualRepType = GeneratedColumn<String>(
    'actual_rep_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualTargetRepsMeta = const VerificationMeta(
    'actualTargetReps',
  );
  late final GeneratedColumn<int> actualTargetReps = GeneratedColumn<int>(
    'actual_target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualMinRepsMeta = const VerificationMeta(
    'actualMinReps',
  );
  late final GeneratedColumn<int> actualMinReps = GeneratedColumn<int>(
    'actual_min_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualMaxRepsMeta = const VerificationMeta(
    'actualMaxReps',
  );
  late final GeneratedColumn<int> actualMaxReps = GeneratedColumn<int>(
    'actual_max_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualLoadTypeMeta = const VerificationMeta(
    'actualLoadType',
  );
  late final GeneratedColumn<String> actualLoadType = GeneratedColumn<String>(
    'actual_load_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualWeightCanonicalMgMeta =
      const VerificationMeta('actualWeightCanonicalMg');
  late final GeneratedColumn<int> actualWeightCanonicalMg =
      GeneratedColumn<int>(
        'actual_weight_canonical_mg',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _actualPercentageMeta = const VerificationMeta(
    'actualPercentage',
  );
  late final GeneratedColumn<int> actualPercentage = GeneratedColumn<int>(
    'actual_percentage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualTargetRpeMeta = const VerificationMeta(
    'actualTargetRpe',
  );
  late final GeneratedColumn<double> actualTargetRpe = GeneratedColumn<double>(
    'actual_target_rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actualFreeformTextMeta =
      const VerificationMeta('actualFreeformText');
  late final GeneratedColumn<String> actualFreeformText =
      GeneratedColumn<String>(
        'actual_freeform_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _plannedRestSecondsMeta =
      const VerificationMeta('plannedRestSeconds');
  late final GeneratedColumn<int> plannedRestSeconds = GeneratedColumn<int>(
    'planned_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (planned_rest_seconds IS NULL OR planned_rest_seconds >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionExerciseId,
    setIndex,
    plannedRepType,
    plannedTargetReps,
    plannedMinReps,
    plannedMaxReps,
    plannedLoadType,
    plannedWeightCanonicalMg,
    plannedPercentage,
    plannedTargetRpe,
    plannedFreeformText,
    actualRepType,
    actualTargetReps,
    actualMinReps,
    actualMaxReps,
    actualLoadType,
    actualWeightCanonicalMg,
    actualPercentage,
    actualTargetRpe,
    actualFreeformText,
    rpe,
    completed,
    completedAt,
    plannedRestSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_set';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSetData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('planned_rep_type')) {
      context.handle(
        _plannedRepTypeMeta,
        plannedRepType.isAcceptableOrUnknown(
          data['planned_rep_type']!,
          _plannedRepTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedRepTypeMeta);
    }
    if (data.containsKey('planned_target_reps')) {
      context.handle(
        _plannedTargetRepsMeta,
        plannedTargetReps.isAcceptableOrUnknown(
          data['planned_target_reps']!,
          _plannedTargetRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_min_reps')) {
      context.handle(
        _plannedMinRepsMeta,
        plannedMinReps.isAcceptableOrUnknown(
          data['planned_min_reps']!,
          _plannedMinRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_max_reps')) {
      context.handle(
        _plannedMaxRepsMeta,
        plannedMaxReps.isAcceptableOrUnknown(
          data['planned_max_reps']!,
          _plannedMaxRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_load_type')) {
      context.handle(
        _plannedLoadTypeMeta,
        plannedLoadType.isAcceptableOrUnknown(
          data['planned_load_type']!,
          _plannedLoadTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedLoadTypeMeta);
    }
    if (data.containsKey('planned_weight_canonical_mg')) {
      context.handle(
        _plannedWeightCanonicalMgMeta,
        plannedWeightCanonicalMg.isAcceptableOrUnknown(
          data['planned_weight_canonical_mg']!,
          _plannedWeightCanonicalMgMeta,
        ),
      );
    }
    if (data.containsKey('planned_percentage')) {
      context.handle(
        _plannedPercentageMeta,
        plannedPercentage.isAcceptableOrUnknown(
          data['planned_percentage']!,
          _plannedPercentageMeta,
        ),
      );
    }
    if (data.containsKey('planned_target_rpe')) {
      context.handle(
        _plannedTargetRpeMeta,
        plannedTargetRpe.isAcceptableOrUnknown(
          data['planned_target_rpe']!,
          _plannedTargetRpeMeta,
        ),
      );
    }
    if (data.containsKey('planned_freeform_text')) {
      context.handle(
        _plannedFreeformTextMeta,
        plannedFreeformText.isAcceptableOrUnknown(
          data['planned_freeform_text']!,
          _plannedFreeformTextMeta,
        ),
      );
    }
    if (data.containsKey('actual_rep_type')) {
      context.handle(
        _actualRepTypeMeta,
        actualRepType.isAcceptableOrUnknown(
          data['actual_rep_type']!,
          _actualRepTypeMeta,
        ),
      );
    }
    if (data.containsKey('actual_target_reps')) {
      context.handle(
        _actualTargetRepsMeta,
        actualTargetReps.isAcceptableOrUnknown(
          data['actual_target_reps']!,
          _actualTargetRepsMeta,
        ),
      );
    }
    if (data.containsKey('actual_min_reps')) {
      context.handle(
        _actualMinRepsMeta,
        actualMinReps.isAcceptableOrUnknown(
          data['actual_min_reps']!,
          _actualMinRepsMeta,
        ),
      );
    }
    if (data.containsKey('actual_max_reps')) {
      context.handle(
        _actualMaxRepsMeta,
        actualMaxReps.isAcceptableOrUnknown(
          data['actual_max_reps']!,
          _actualMaxRepsMeta,
        ),
      );
    }
    if (data.containsKey('actual_load_type')) {
      context.handle(
        _actualLoadTypeMeta,
        actualLoadType.isAcceptableOrUnknown(
          data['actual_load_type']!,
          _actualLoadTypeMeta,
        ),
      );
    }
    if (data.containsKey('actual_weight_canonical_mg')) {
      context.handle(
        _actualWeightCanonicalMgMeta,
        actualWeightCanonicalMg.isAcceptableOrUnknown(
          data['actual_weight_canonical_mg']!,
          _actualWeightCanonicalMgMeta,
        ),
      );
    }
    if (data.containsKey('actual_percentage')) {
      context.handle(
        _actualPercentageMeta,
        actualPercentage.isAcceptableOrUnknown(
          data['actual_percentage']!,
          _actualPercentageMeta,
        ),
      );
    }
    if (data.containsKey('actual_target_rpe')) {
      context.handle(
        _actualTargetRpeMeta,
        actualTargetRpe.isAcceptableOrUnknown(
          data['actual_target_rpe']!,
          _actualTargetRpeMeta,
        ),
      );
    }
    if (data.containsKey('actual_freeform_text')) {
      context.handle(
        _actualFreeformTextMeta,
        actualFreeformText.isAcceptableOrUnknown(
          data['actual_freeform_text']!,
          _actualFreeformTextMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('planned_rest_seconds')) {
      context.handle(
        _plannedRestSecondsMeta,
        plannedRestSeconds.isAcceptableOrUnknown(
          data['planned_rest_seconds']!,
          _plannedRestSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionSetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSetData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      plannedRepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_rep_type'],
      )!,
      plannedTargetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_target_reps'],
      ),
      plannedMinReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_min_reps'],
      ),
      plannedMaxReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_max_reps'],
      ),
      plannedLoadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_load_type'],
      )!,
      plannedWeightCanonicalMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_weight_canonical_mg'],
      ),
      plannedPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_percentage'],
      ),
      plannedTargetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_target_rpe'],
      ),
      plannedFreeformText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_freeform_text'],
      ),
      actualRepType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_rep_type'],
      ),
      actualTargetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_target_reps'],
      ),
      actualMinReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_min_reps'],
      ),
      actualMaxReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_max_reps'],
      ),
      actualLoadType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_load_type'],
      ),
      actualWeightCanonicalMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_weight_canonical_mg'],
      ),
      actualPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_percentage'],
      ),
      actualTargetRpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_target_rpe'],
      ),
      actualFreeformText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_freeform_text'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      plannedRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_rest_seconds'],
      ),
    );
  }

  @override
  SessionSet createAlias(String alias) {
    return SessionSet(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CONSTRAINT session_set_index CHECK(set_index >= 0)',
    'CONSTRAINT session_set_rpe CHECK(rpe IS NULL OR(rpe >= 0 AND rpe <= 10))',
    'CONSTRAINT session_set_completion CHECK((completed = 0 AND completed_at IS NULL)OR(completed = 1 AND completed_at IS NOT NULL))',
    'CONSTRAINT session_set_planned_rep_fields CHECK((planned_rep_type = \'fixed\' AND planned_target_reps IS NOT NULL AND planned_target_reps >= 1 AND planned_min_reps IS NULL AND planned_max_reps IS NULL)OR(planned_rep_type = \'range\' AND planned_target_reps IS NULL AND planned_min_reps IS NOT NULL AND planned_max_reps IS NOT NULL AND planned_min_reps >= 1 AND planned_max_reps >= planned_min_reps)OR(planned_rep_type = \'amrap\' AND planned_target_reps IS NULL AND planned_min_reps IS NULL AND planned_max_reps IS NULL))',
    'CONSTRAINT session_set_planned_load_fields CHECK((planned_load_type = \'none\' AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'bodyweight\' AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'absolute\' AND planned_weight_canonical_mg IS NOT NULL AND planned_weight_canonical_mg >= 0 AND planned_percentage IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'percentage\' AND planned_percentage IS NOT NULL AND planned_percentage >= 0 AND planned_percentage <= 100 AND planned_weight_canonical_mg IS NULL AND planned_target_rpe IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'target_rpe\' AND planned_target_rpe IS NOT NULL AND planned_target_rpe >= 0 AND planned_target_rpe <= 10 AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_freeform_text IS NULL)OR(planned_load_type = \'text\' AND planned_freeform_text IS NOT NULL AND length(planned_freeform_text) > 0 AND planned_weight_canonical_mg IS NULL AND planned_percentage IS NULL AND planned_target_rpe IS NULL))',
    'CONSTRAINT session_set_actual_rep_fields CHECK((actual_rep_type IS NULL AND actual_target_reps IS NULL AND actual_min_reps IS NULL AND actual_max_reps IS NULL)OR(actual_rep_type = \'fixed\' AND actual_target_reps IS NOT NULL AND actual_target_reps >= 1 AND actual_min_reps IS NULL AND actual_max_reps IS NULL)OR(actual_rep_type = \'range\' AND actual_target_reps IS NULL AND actual_min_reps IS NOT NULL AND actual_max_reps IS NOT NULL AND actual_min_reps >= 1 AND actual_max_reps >= actual_min_reps)OR(actual_rep_type = \'amrap\' AND actual_target_reps IS NULL AND actual_min_reps IS NULL AND actual_max_reps IS NULL))',
    'CONSTRAINT session_set_actual_load_fields CHECK((actual_load_type IS NULL AND actual_weight_canonical_mg IS NULL AND actual_percentage IS NULL AND actual_target_rpe IS NULL AND actual_freeform_text IS NULL)OR(actual_load_type = \'none\' AND actual_weight_canonical_mg IS NULL AND actual_percentage IS NULL AND actual_target_rpe IS NULL AND actual_freeform_text IS NULL)OR(actual_load_type = \'bodyweight\' AND actual_weight_canonical_mg IS NULL AND actual_percentage IS NULL AND actual_target_rpe IS NULL AND actual_freeform_text IS NULL)OR(actual_load_type = \'absolute\' AND actual_weight_canonical_mg IS NOT NULL AND actual_weight_canonical_mg >= 0 AND actual_percentage IS NULL AND actual_target_rpe IS NULL AND actual_freeform_text IS NULL)OR(actual_load_type = \'percentage\' AND actual_percentage IS NOT NULL AND actual_percentage >= 0 AND actual_percentage <= 100 AND actual_weight_canonical_mg IS NULL AND actual_target_rpe IS NULL AND actual_freeform_text IS NULL)OR(actual_load_type = \'target_rpe\' AND actual_target_rpe IS NOT NULL AND actual_target_rpe >= 0 AND actual_target_rpe <= 10 AND actual_weight_canonical_mg IS NULL AND actual_percentage IS NULL AND actual_freeform_text IS NULL)OR(actual_load_type = \'text\' AND actual_freeform_text IS NOT NULL AND length(actual_freeform_text) > 0 AND actual_weight_canonical_mg IS NULL AND actual_percentage IS NULL AND actual_target_rpe IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SessionSetData extends DataClass implements Insertable<SessionSetData> {
  final int id;
  final int sessionExerciseId;
  final int setIndex;
  final String plannedRepType;
  final int? plannedTargetReps;
  final int? plannedMinReps;
  final int? plannedMaxReps;
  final String plannedLoadType;
  final int? plannedWeightCanonicalMg;
  final int? plannedPercentage;
  final double? plannedTargetRpe;
  final String? plannedFreeformText;
  final String? actualRepType;
  final int? actualTargetReps;
  final int? actualMinReps;
  final int? actualMaxReps;
  final String? actualLoadType;
  final int? actualWeightCanonicalMg;
  final int? actualPercentage;
  final double? actualTargetRpe;
  final String? actualFreeformText;
  final double? rpe;
  final bool completed;
  final DateTime? completedAt;
  final int? plannedRestSeconds;
  const SessionSetData({
    required this.id,
    required this.sessionExerciseId,
    required this.setIndex,
    required this.plannedRepType,
    this.plannedTargetReps,
    this.plannedMinReps,
    this.plannedMaxReps,
    required this.plannedLoadType,
    this.plannedWeightCanonicalMg,
    this.plannedPercentage,
    this.plannedTargetRpe,
    this.plannedFreeformText,
    this.actualRepType,
    this.actualTargetReps,
    this.actualMinReps,
    this.actualMaxReps,
    this.actualLoadType,
    this.actualWeightCanonicalMg,
    this.actualPercentage,
    this.actualTargetRpe,
    this.actualFreeformText,
    this.rpe,
    required this.completed,
    this.completedAt,
    this.plannedRestSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_exercise_id'] = Variable<int>(sessionExerciseId);
    map['set_index'] = Variable<int>(setIndex);
    map['planned_rep_type'] = Variable<String>(plannedRepType);
    if (!nullToAbsent || plannedTargetReps != null) {
      map['planned_target_reps'] = Variable<int>(plannedTargetReps);
    }
    if (!nullToAbsent || plannedMinReps != null) {
      map['planned_min_reps'] = Variable<int>(plannedMinReps);
    }
    if (!nullToAbsent || plannedMaxReps != null) {
      map['planned_max_reps'] = Variable<int>(plannedMaxReps);
    }
    map['planned_load_type'] = Variable<String>(plannedLoadType);
    if (!nullToAbsent || plannedWeightCanonicalMg != null) {
      map['planned_weight_canonical_mg'] = Variable<int>(
        plannedWeightCanonicalMg,
      );
    }
    if (!nullToAbsent || plannedPercentage != null) {
      map['planned_percentage'] = Variable<int>(plannedPercentage);
    }
    if (!nullToAbsent || plannedTargetRpe != null) {
      map['planned_target_rpe'] = Variable<double>(plannedTargetRpe);
    }
    if (!nullToAbsent || plannedFreeformText != null) {
      map['planned_freeform_text'] = Variable<String>(plannedFreeformText);
    }
    if (!nullToAbsent || actualRepType != null) {
      map['actual_rep_type'] = Variable<String>(actualRepType);
    }
    if (!nullToAbsent || actualTargetReps != null) {
      map['actual_target_reps'] = Variable<int>(actualTargetReps);
    }
    if (!nullToAbsent || actualMinReps != null) {
      map['actual_min_reps'] = Variable<int>(actualMinReps);
    }
    if (!nullToAbsent || actualMaxReps != null) {
      map['actual_max_reps'] = Variable<int>(actualMaxReps);
    }
    if (!nullToAbsent || actualLoadType != null) {
      map['actual_load_type'] = Variable<String>(actualLoadType);
    }
    if (!nullToAbsent || actualWeightCanonicalMg != null) {
      map['actual_weight_canonical_mg'] = Variable<int>(
        actualWeightCanonicalMg,
      );
    }
    if (!nullToAbsent || actualPercentage != null) {
      map['actual_percentage'] = Variable<int>(actualPercentage);
    }
    if (!nullToAbsent || actualTargetRpe != null) {
      map['actual_target_rpe'] = Variable<double>(actualTargetRpe);
    }
    if (!nullToAbsent || actualFreeformText != null) {
      map['actual_freeform_text'] = Variable<String>(actualFreeformText);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || plannedRestSeconds != null) {
      map['planned_rest_seconds'] = Variable<int>(plannedRestSeconds);
    }
    return map;
  }

  SessionSetCompanion toCompanion(bool nullToAbsent) {
    return SessionSetCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      setIndex: Value(setIndex),
      plannedRepType: Value(plannedRepType),
      plannedTargetReps: plannedTargetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedTargetReps),
      plannedMinReps: plannedMinReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedMinReps),
      plannedMaxReps: plannedMaxReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedMaxReps),
      plannedLoadType: Value(plannedLoadType),
      plannedWeightCanonicalMg: plannedWeightCanonicalMg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightCanonicalMg),
      plannedPercentage: plannedPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedPercentage),
      plannedTargetRpe: plannedTargetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedTargetRpe),
      plannedFreeformText: plannedFreeformText == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedFreeformText),
      actualRepType: actualRepType == null && nullToAbsent
          ? const Value.absent()
          : Value(actualRepType),
      actualTargetReps: actualTargetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTargetReps),
      actualMinReps: actualMinReps == null && nullToAbsent
          ? const Value.absent()
          : Value(actualMinReps),
      actualMaxReps: actualMaxReps == null && nullToAbsent
          ? const Value.absent()
          : Value(actualMaxReps),
      actualLoadType: actualLoadType == null && nullToAbsent
          ? const Value.absent()
          : Value(actualLoadType),
      actualWeightCanonicalMg: actualWeightCanonicalMg == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWeightCanonicalMg),
      actualPercentage: actualPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(actualPercentage),
      actualTargetRpe: actualTargetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTargetRpe),
      actualFreeformText: actualFreeformText == null && nullToAbsent
          ? const Value.absent()
          : Value(actualFreeformText),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      plannedRestSeconds: plannedRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedRestSeconds),
    );
  }

  factory SessionSetData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSetData(
      id: serializer.fromJson<int>(json['id']),
      sessionExerciseId: serializer.fromJson<int>(json['session_exercise_id']),
      setIndex: serializer.fromJson<int>(json['set_index']),
      plannedRepType: serializer.fromJson<String>(json['planned_rep_type']),
      plannedTargetReps: serializer.fromJson<int?>(json['planned_target_reps']),
      plannedMinReps: serializer.fromJson<int?>(json['planned_min_reps']),
      plannedMaxReps: serializer.fromJson<int?>(json['planned_max_reps']),
      plannedLoadType: serializer.fromJson<String>(json['planned_load_type']),
      plannedWeightCanonicalMg: serializer.fromJson<int?>(
        json['planned_weight_canonical_mg'],
      ),
      plannedPercentage: serializer.fromJson<int?>(json['planned_percentage']),
      plannedTargetRpe: serializer.fromJson<double?>(
        json['planned_target_rpe'],
      ),
      plannedFreeformText: serializer.fromJson<String?>(
        json['planned_freeform_text'],
      ),
      actualRepType: serializer.fromJson<String?>(json['actual_rep_type']),
      actualTargetReps: serializer.fromJson<int?>(json['actual_target_reps']),
      actualMinReps: serializer.fromJson<int?>(json['actual_min_reps']),
      actualMaxReps: serializer.fromJson<int?>(json['actual_max_reps']),
      actualLoadType: serializer.fromJson<String?>(json['actual_load_type']),
      actualWeightCanonicalMg: serializer.fromJson<int?>(
        json['actual_weight_canonical_mg'],
      ),
      actualPercentage: serializer.fromJson<int?>(json['actual_percentage']),
      actualTargetRpe: serializer.fromJson<double?>(json['actual_target_rpe']),
      actualFreeformText: serializer.fromJson<String?>(
        json['actual_freeform_text'],
      ),
      rpe: serializer.fromJson<double?>(json['rpe']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completed_at']),
      plannedRestSeconds: serializer.fromJson<int?>(
        json['planned_rest_seconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'session_exercise_id': serializer.toJson<int>(sessionExerciseId),
      'set_index': serializer.toJson<int>(setIndex),
      'planned_rep_type': serializer.toJson<String>(plannedRepType),
      'planned_target_reps': serializer.toJson<int?>(plannedTargetReps),
      'planned_min_reps': serializer.toJson<int?>(plannedMinReps),
      'planned_max_reps': serializer.toJson<int?>(plannedMaxReps),
      'planned_load_type': serializer.toJson<String>(plannedLoadType),
      'planned_weight_canonical_mg': serializer.toJson<int?>(
        plannedWeightCanonicalMg,
      ),
      'planned_percentage': serializer.toJson<int?>(plannedPercentage),
      'planned_target_rpe': serializer.toJson<double?>(plannedTargetRpe),
      'planned_freeform_text': serializer.toJson<String?>(plannedFreeformText),
      'actual_rep_type': serializer.toJson<String?>(actualRepType),
      'actual_target_reps': serializer.toJson<int?>(actualTargetReps),
      'actual_min_reps': serializer.toJson<int?>(actualMinReps),
      'actual_max_reps': serializer.toJson<int?>(actualMaxReps),
      'actual_load_type': serializer.toJson<String?>(actualLoadType),
      'actual_weight_canonical_mg': serializer.toJson<int?>(
        actualWeightCanonicalMg,
      ),
      'actual_percentage': serializer.toJson<int?>(actualPercentage),
      'actual_target_rpe': serializer.toJson<double?>(actualTargetRpe),
      'actual_freeform_text': serializer.toJson<String?>(actualFreeformText),
      'rpe': serializer.toJson<double?>(rpe),
      'completed': serializer.toJson<bool>(completed),
      'completed_at': serializer.toJson<DateTime?>(completedAt),
      'planned_rest_seconds': serializer.toJson<int?>(plannedRestSeconds),
    };
  }

  SessionSetData copyWith({
    int? id,
    int? sessionExerciseId,
    int? setIndex,
    String? plannedRepType,
    Value<int?> plannedTargetReps = const Value.absent(),
    Value<int?> plannedMinReps = const Value.absent(),
    Value<int?> plannedMaxReps = const Value.absent(),
    String? plannedLoadType,
    Value<int?> plannedWeightCanonicalMg = const Value.absent(),
    Value<int?> plannedPercentage = const Value.absent(),
    Value<double?> plannedTargetRpe = const Value.absent(),
    Value<String?> plannedFreeformText = const Value.absent(),
    Value<String?> actualRepType = const Value.absent(),
    Value<int?> actualTargetReps = const Value.absent(),
    Value<int?> actualMinReps = const Value.absent(),
    Value<int?> actualMaxReps = const Value.absent(),
    Value<String?> actualLoadType = const Value.absent(),
    Value<int?> actualWeightCanonicalMg = const Value.absent(),
    Value<int?> actualPercentage = const Value.absent(),
    Value<double?> actualTargetRpe = const Value.absent(),
    Value<String?> actualFreeformText = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> plannedRestSeconds = const Value.absent(),
  }) => SessionSetData(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    setIndex: setIndex ?? this.setIndex,
    plannedRepType: plannedRepType ?? this.plannedRepType,
    plannedTargetReps: plannedTargetReps.present
        ? plannedTargetReps.value
        : this.plannedTargetReps,
    plannedMinReps: plannedMinReps.present
        ? plannedMinReps.value
        : this.plannedMinReps,
    plannedMaxReps: plannedMaxReps.present
        ? plannedMaxReps.value
        : this.plannedMaxReps,
    plannedLoadType: plannedLoadType ?? this.plannedLoadType,
    plannedWeightCanonicalMg: plannedWeightCanonicalMg.present
        ? plannedWeightCanonicalMg.value
        : this.plannedWeightCanonicalMg,
    plannedPercentage: plannedPercentage.present
        ? plannedPercentage.value
        : this.plannedPercentage,
    plannedTargetRpe: plannedTargetRpe.present
        ? plannedTargetRpe.value
        : this.plannedTargetRpe,
    plannedFreeformText: plannedFreeformText.present
        ? plannedFreeformText.value
        : this.plannedFreeformText,
    actualRepType: actualRepType.present
        ? actualRepType.value
        : this.actualRepType,
    actualTargetReps: actualTargetReps.present
        ? actualTargetReps.value
        : this.actualTargetReps,
    actualMinReps: actualMinReps.present
        ? actualMinReps.value
        : this.actualMinReps,
    actualMaxReps: actualMaxReps.present
        ? actualMaxReps.value
        : this.actualMaxReps,
    actualLoadType: actualLoadType.present
        ? actualLoadType.value
        : this.actualLoadType,
    actualWeightCanonicalMg: actualWeightCanonicalMg.present
        ? actualWeightCanonicalMg.value
        : this.actualWeightCanonicalMg,
    actualPercentage: actualPercentage.present
        ? actualPercentage.value
        : this.actualPercentage,
    actualTargetRpe: actualTargetRpe.present
        ? actualTargetRpe.value
        : this.actualTargetRpe,
    actualFreeformText: actualFreeformText.present
        ? actualFreeformText.value
        : this.actualFreeformText,
    rpe: rpe.present ? rpe.value : this.rpe,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    plannedRestSeconds: plannedRestSeconds.present
        ? plannedRestSeconds.value
        : this.plannedRestSeconds,
  );
  SessionSetData copyWithCompanion(SessionSetCompanion data) {
    return SessionSetData(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      plannedRepType: data.plannedRepType.present
          ? data.plannedRepType.value
          : this.plannedRepType,
      plannedTargetReps: data.plannedTargetReps.present
          ? data.plannedTargetReps.value
          : this.plannedTargetReps,
      plannedMinReps: data.plannedMinReps.present
          ? data.plannedMinReps.value
          : this.plannedMinReps,
      plannedMaxReps: data.plannedMaxReps.present
          ? data.plannedMaxReps.value
          : this.plannedMaxReps,
      plannedLoadType: data.plannedLoadType.present
          ? data.plannedLoadType.value
          : this.plannedLoadType,
      plannedWeightCanonicalMg: data.plannedWeightCanonicalMg.present
          ? data.plannedWeightCanonicalMg.value
          : this.plannedWeightCanonicalMg,
      plannedPercentage: data.plannedPercentage.present
          ? data.plannedPercentage.value
          : this.plannedPercentage,
      plannedTargetRpe: data.plannedTargetRpe.present
          ? data.plannedTargetRpe.value
          : this.plannedTargetRpe,
      plannedFreeformText: data.plannedFreeformText.present
          ? data.plannedFreeformText.value
          : this.plannedFreeformText,
      actualRepType: data.actualRepType.present
          ? data.actualRepType.value
          : this.actualRepType,
      actualTargetReps: data.actualTargetReps.present
          ? data.actualTargetReps.value
          : this.actualTargetReps,
      actualMinReps: data.actualMinReps.present
          ? data.actualMinReps.value
          : this.actualMinReps,
      actualMaxReps: data.actualMaxReps.present
          ? data.actualMaxReps.value
          : this.actualMaxReps,
      actualLoadType: data.actualLoadType.present
          ? data.actualLoadType.value
          : this.actualLoadType,
      actualWeightCanonicalMg: data.actualWeightCanonicalMg.present
          ? data.actualWeightCanonicalMg.value
          : this.actualWeightCanonicalMg,
      actualPercentage: data.actualPercentage.present
          ? data.actualPercentage.value
          : this.actualPercentage,
      actualTargetRpe: data.actualTargetRpe.present
          ? data.actualTargetRpe.value
          : this.actualTargetRpe,
      actualFreeformText: data.actualFreeformText.present
          ? data.actualFreeformText.value
          : this.actualFreeformText,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      plannedRestSeconds: data.plannedRestSeconds.present
          ? data.plannedRestSeconds.value
          : this.plannedRestSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSetData(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('plannedRepType: $plannedRepType, ')
          ..write('plannedTargetReps: $plannedTargetReps, ')
          ..write('plannedMinReps: $plannedMinReps, ')
          ..write('plannedMaxReps: $plannedMaxReps, ')
          ..write('plannedLoadType: $plannedLoadType, ')
          ..write('plannedWeightCanonicalMg: $plannedWeightCanonicalMg, ')
          ..write('plannedPercentage: $plannedPercentage, ')
          ..write('plannedTargetRpe: $plannedTargetRpe, ')
          ..write('plannedFreeformText: $plannedFreeformText, ')
          ..write('actualRepType: $actualRepType, ')
          ..write('actualTargetReps: $actualTargetReps, ')
          ..write('actualMinReps: $actualMinReps, ')
          ..write('actualMaxReps: $actualMaxReps, ')
          ..write('actualLoadType: $actualLoadType, ')
          ..write('actualWeightCanonicalMg: $actualWeightCanonicalMg, ')
          ..write('actualPercentage: $actualPercentage, ')
          ..write('actualTargetRpe: $actualTargetRpe, ')
          ..write('actualFreeformText: $actualFreeformText, ')
          ..write('rpe: $rpe, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('plannedRestSeconds: $plannedRestSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionExerciseId,
    setIndex,
    plannedRepType,
    plannedTargetReps,
    plannedMinReps,
    plannedMaxReps,
    plannedLoadType,
    plannedWeightCanonicalMg,
    plannedPercentage,
    plannedTargetRpe,
    plannedFreeformText,
    actualRepType,
    actualTargetReps,
    actualMinReps,
    actualMaxReps,
    actualLoadType,
    actualWeightCanonicalMg,
    actualPercentage,
    actualTargetRpe,
    actualFreeformText,
    rpe,
    completed,
    completedAt,
    plannedRestSeconds,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSetData &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.setIndex == this.setIndex &&
          other.plannedRepType == this.plannedRepType &&
          other.plannedTargetReps == this.plannedTargetReps &&
          other.plannedMinReps == this.plannedMinReps &&
          other.plannedMaxReps == this.plannedMaxReps &&
          other.plannedLoadType == this.plannedLoadType &&
          other.plannedWeightCanonicalMg == this.plannedWeightCanonicalMg &&
          other.plannedPercentage == this.plannedPercentage &&
          other.plannedTargetRpe == this.plannedTargetRpe &&
          other.plannedFreeformText == this.plannedFreeformText &&
          other.actualRepType == this.actualRepType &&
          other.actualTargetReps == this.actualTargetReps &&
          other.actualMinReps == this.actualMinReps &&
          other.actualMaxReps == this.actualMaxReps &&
          other.actualLoadType == this.actualLoadType &&
          other.actualWeightCanonicalMg == this.actualWeightCanonicalMg &&
          other.actualPercentage == this.actualPercentage &&
          other.actualTargetRpe == this.actualTargetRpe &&
          other.actualFreeformText == this.actualFreeformText &&
          other.rpe == this.rpe &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.plannedRestSeconds == this.plannedRestSeconds);
}

class SessionSetCompanion extends UpdateCompanion<SessionSetData> {
  final Value<int> id;
  final Value<int> sessionExerciseId;
  final Value<int> setIndex;
  final Value<String> plannedRepType;
  final Value<int?> plannedTargetReps;
  final Value<int?> plannedMinReps;
  final Value<int?> plannedMaxReps;
  final Value<String> plannedLoadType;
  final Value<int?> plannedWeightCanonicalMg;
  final Value<int?> plannedPercentage;
  final Value<double?> plannedTargetRpe;
  final Value<String?> plannedFreeformText;
  final Value<String?> actualRepType;
  final Value<int?> actualTargetReps;
  final Value<int?> actualMinReps;
  final Value<int?> actualMaxReps;
  final Value<String?> actualLoadType;
  final Value<int?> actualWeightCanonicalMg;
  final Value<int?> actualPercentage;
  final Value<double?> actualTargetRpe;
  final Value<String?> actualFreeformText;
  final Value<double?> rpe;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<int?> plannedRestSeconds;
  const SessionSetCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.plannedRepType = const Value.absent(),
    this.plannedTargetReps = const Value.absent(),
    this.plannedMinReps = const Value.absent(),
    this.plannedMaxReps = const Value.absent(),
    this.plannedLoadType = const Value.absent(),
    this.plannedWeightCanonicalMg = const Value.absent(),
    this.plannedPercentage = const Value.absent(),
    this.plannedTargetRpe = const Value.absent(),
    this.plannedFreeformText = const Value.absent(),
    this.actualRepType = const Value.absent(),
    this.actualTargetReps = const Value.absent(),
    this.actualMinReps = const Value.absent(),
    this.actualMaxReps = const Value.absent(),
    this.actualLoadType = const Value.absent(),
    this.actualWeightCanonicalMg = const Value.absent(),
    this.actualPercentage = const Value.absent(),
    this.actualTargetRpe = const Value.absent(),
    this.actualFreeformText = const Value.absent(),
    this.rpe = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.plannedRestSeconds = const Value.absent(),
  });
  SessionSetCompanion.insert({
    this.id = const Value.absent(),
    required int sessionExerciseId,
    required int setIndex,
    required String plannedRepType,
    this.plannedTargetReps = const Value.absent(),
    this.plannedMinReps = const Value.absent(),
    this.plannedMaxReps = const Value.absent(),
    required String plannedLoadType,
    this.plannedWeightCanonicalMg = const Value.absent(),
    this.plannedPercentage = const Value.absent(),
    this.plannedTargetRpe = const Value.absent(),
    this.plannedFreeformText = const Value.absent(),
    this.actualRepType = const Value.absent(),
    this.actualTargetReps = const Value.absent(),
    this.actualMinReps = const Value.absent(),
    this.actualMaxReps = const Value.absent(),
    this.actualLoadType = const Value.absent(),
    this.actualWeightCanonicalMg = const Value.absent(),
    this.actualPercentage = const Value.absent(),
    this.actualTargetRpe = const Value.absent(),
    this.actualFreeformText = const Value.absent(),
    this.rpe = const Value.absent(),
    required bool completed,
    this.completedAt = const Value.absent(),
    this.plannedRestSeconds = const Value.absent(),
  }) : sessionExerciseId = Value(sessionExerciseId),
       setIndex = Value(setIndex),
       plannedRepType = Value(plannedRepType),
       plannedLoadType = Value(plannedLoadType),
       completed = Value(completed);
  static Insertable<SessionSetData> custom({
    Expression<int>? id,
    Expression<int>? sessionExerciseId,
    Expression<int>? setIndex,
    Expression<String>? plannedRepType,
    Expression<int>? plannedTargetReps,
    Expression<int>? plannedMinReps,
    Expression<int>? plannedMaxReps,
    Expression<String>? plannedLoadType,
    Expression<int>? plannedWeightCanonicalMg,
    Expression<int>? plannedPercentage,
    Expression<double>? plannedTargetRpe,
    Expression<String>? plannedFreeformText,
    Expression<String>? actualRepType,
    Expression<int>? actualTargetReps,
    Expression<int>? actualMinReps,
    Expression<int>? actualMaxReps,
    Expression<String>? actualLoadType,
    Expression<int>? actualWeightCanonicalMg,
    Expression<int>? actualPercentage,
    Expression<double>? actualTargetRpe,
    Expression<String>? actualFreeformText,
    Expression<double>? rpe,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<int>? plannedRestSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (setIndex != null) 'set_index': setIndex,
      if (plannedRepType != null) 'planned_rep_type': plannedRepType,
      if (plannedTargetReps != null) 'planned_target_reps': plannedTargetReps,
      if (plannedMinReps != null) 'planned_min_reps': plannedMinReps,
      if (plannedMaxReps != null) 'planned_max_reps': plannedMaxReps,
      if (plannedLoadType != null) 'planned_load_type': plannedLoadType,
      if (plannedWeightCanonicalMg != null)
        'planned_weight_canonical_mg': plannedWeightCanonicalMg,
      if (plannedPercentage != null) 'planned_percentage': plannedPercentage,
      if (plannedTargetRpe != null) 'planned_target_rpe': plannedTargetRpe,
      if (plannedFreeformText != null)
        'planned_freeform_text': plannedFreeformText,
      if (actualRepType != null) 'actual_rep_type': actualRepType,
      if (actualTargetReps != null) 'actual_target_reps': actualTargetReps,
      if (actualMinReps != null) 'actual_min_reps': actualMinReps,
      if (actualMaxReps != null) 'actual_max_reps': actualMaxReps,
      if (actualLoadType != null) 'actual_load_type': actualLoadType,
      if (actualWeightCanonicalMg != null)
        'actual_weight_canonical_mg': actualWeightCanonicalMg,
      if (actualPercentage != null) 'actual_percentage': actualPercentage,
      if (actualTargetRpe != null) 'actual_target_rpe': actualTargetRpe,
      if (actualFreeformText != null)
        'actual_freeform_text': actualFreeformText,
      if (rpe != null) 'rpe': rpe,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (plannedRestSeconds != null)
        'planned_rest_seconds': plannedRestSeconds,
    });
  }

  SessionSetCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionExerciseId,
    Value<int>? setIndex,
    Value<String>? plannedRepType,
    Value<int?>? plannedTargetReps,
    Value<int?>? plannedMinReps,
    Value<int?>? plannedMaxReps,
    Value<String>? plannedLoadType,
    Value<int?>? plannedWeightCanonicalMg,
    Value<int?>? plannedPercentage,
    Value<double?>? plannedTargetRpe,
    Value<String?>? plannedFreeformText,
    Value<String?>? actualRepType,
    Value<int?>? actualTargetReps,
    Value<int?>? actualMinReps,
    Value<int?>? actualMaxReps,
    Value<String?>? actualLoadType,
    Value<int?>? actualWeightCanonicalMg,
    Value<int?>? actualPercentage,
    Value<double?>? actualTargetRpe,
    Value<String?>? actualFreeformText,
    Value<double?>? rpe,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<int?>? plannedRestSeconds,
  }) {
    return SessionSetCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      setIndex: setIndex ?? this.setIndex,
      plannedRepType: plannedRepType ?? this.plannedRepType,
      plannedTargetReps: plannedTargetReps ?? this.plannedTargetReps,
      plannedMinReps: plannedMinReps ?? this.plannedMinReps,
      plannedMaxReps: plannedMaxReps ?? this.plannedMaxReps,
      plannedLoadType: plannedLoadType ?? this.plannedLoadType,
      plannedWeightCanonicalMg:
          plannedWeightCanonicalMg ?? this.plannedWeightCanonicalMg,
      plannedPercentage: plannedPercentage ?? this.plannedPercentage,
      plannedTargetRpe: plannedTargetRpe ?? this.plannedTargetRpe,
      plannedFreeformText: plannedFreeformText ?? this.plannedFreeformText,
      actualRepType: actualRepType ?? this.actualRepType,
      actualTargetReps: actualTargetReps ?? this.actualTargetReps,
      actualMinReps: actualMinReps ?? this.actualMinReps,
      actualMaxReps: actualMaxReps ?? this.actualMaxReps,
      actualLoadType: actualLoadType ?? this.actualLoadType,
      actualWeightCanonicalMg:
          actualWeightCanonicalMg ?? this.actualWeightCanonicalMg,
      actualPercentage: actualPercentage ?? this.actualPercentage,
      actualTargetRpe: actualTargetRpe ?? this.actualTargetRpe,
      actualFreeformText: actualFreeformText ?? this.actualFreeformText,
      rpe: rpe ?? this.rpe,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      plannedRestSeconds: plannedRestSeconds ?? this.plannedRestSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<int>(sessionExerciseId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (plannedRepType.present) {
      map['planned_rep_type'] = Variable<String>(plannedRepType.value);
    }
    if (plannedTargetReps.present) {
      map['planned_target_reps'] = Variable<int>(plannedTargetReps.value);
    }
    if (plannedMinReps.present) {
      map['planned_min_reps'] = Variable<int>(plannedMinReps.value);
    }
    if (plannedMaxReps.present) {
      map['planned_max_reps'] = Variable<int>(plannedMaxReps.value);
    }
    if (plannedLoadType.present) {
      map['planned_load_type'] = Variable<String>(plannedLoadType.value);
    }
    if (plannedWeightCanonicalMg.present) {
      map['planned_weight_canonical_mg'] = Variable<int>(
        plannedWeightCanonicalMg.value,
      );
    }
    if (plannedPercentage.present) {
      map['planned_percentage'] = Variable<int>(plannedPercentage.value);
    }
    if (plannedTargetRpe.present) {
      map['planned_target_rpe'] = Variable<double>(plannedTargetRpe.value);
    }
    if (plannedFreeformText.present) {
      map['planned_freeform_text'] = Variable<String>(
        plannedFreeformText.value,
      );
    }
    if (actualRepType.present) {
      map['actual_rep_type'] = Variable<String>(actualRepType.value);
    }
    if (actualTargetReps.present) {
      map['actual_target_reps'] = Variable<int>(actualTargetReps.value);
    }
    if (actualMinReps.present) {
      map['actual_min_reps'] = Variable<int>(actualMinReps.value);
    }
    if (actualMaxReps.present) {
      map['actual_max_reps'] = Variable<int>(actualMaxReps.value);
    }
    if (actualLoadType.present) {
      map['actual_load_type'] = Variable<String>(actualLoadType.value);
    }
    if (actualWeightCanonicalMg.present) {
      map['actual_weight_canonical_mg'] = Variable<int>(
        actualWeightCanonicalMg.value,
      );
    }
    if (actualPercentage.present) {
      map['actual_percentage'] = Variable<int>(actualPercentage.value);
    }
    if (actualTargetRpe.present) {
      map['actual_target_rpe'] = Variable<double>(actualTargetRpe.value);
    }
    if (actualFreeformText.present) {
      map['actual_freeform_text'] = Variable<String>(actualFreeformText.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (plannedRestSeconds.present) {
      map['planned_rest_seconds'] = Variable<int>(plannedRestSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSetCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('plannedRepType: $plannedRepType, ')
          ..write('plannedTargetReps: $plannedTargetReps, ')
          ..write('plannedMinReps: $plannedMinReps, ')
          ..write('plannedMaxReps: $plannedMaxReps, ')
          ..write('plannedLoadType: $plannedLoadType, ')
          ..write('plannedWeightCanonicalMg: $plannedWeightCanonicalMg, ')
          ..write('plannedPercentage: $plannedPercentage, ')
          ..write('plannedTargetRpe: $plannedTargetRpe, ')
          ..write('plannedFreeformText: $plannedFreeformText, ')
          ..write('actualRepType: $actualRepType, ')
          ..write('actualTargetReps: $actualTargetReps, ')
          ..write('actualMinReps: $actualMinReps, ')
          ..write('actualMaxReps: $actualMaxReps, ')
          ..write('actualLoadType: $actualLoadType, ')
          ..write('actualWeightCanonicalMg: $actualWeightCanonicalMg, ')
          ..write('actualPercentage: $actualPercentage, ')
          ..write('actualTargetRpe: $actualTargetRpe, ')
          ..write('actualFreeformText: $actualFreeformText, ')
          ..write('rpe: $rpe, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('plannedRestSeconds: $plannedRestSeconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final AppMetadata appMetadata = AppMetadata(this);
  late final Settings settings = Settings(this);
  late final Workout workout = Workout(this);
  late final WorkoutExercise workoutExercise = WorkoutExercise(this);
  late final Index workoutExerciseParentOrder = Index(
    'workout_exercise_parent_order',
    'CREATE UNIQUE INDEX workout_exercise_parent_order ON workout_exercise (workout_id, order_index)',
  );
  late final Index workoutExerciseNormalizedName = Index(
    'workout_exercise_normalized_name',
    'CREATE INDEX workout_exercise_normalized_name ON workout_exercise (normalized_name)',
  );
  late final WorkoutSet workoutSet = WorkoutSet(this);
  late final Index workoutSetParentOrder = Index(
    'workout_set_parent_order',
    'CREATE UNIQUE INDEX workout_set_parent_order ON workout_set (workout_exercise_id, set_index)',
  );
  late final Session session = Session(this);
  late final ScheduleEntry scheduleEntry = ScheduleEntry(this);
  late final Index scheduleEntryDateStatus = Index(
    'schedule_entry_date_status',
    'CREATE INDEX schedule_entry_date_status ON schedule_entry (date, status)',
  );
  late final Index scheduleEntryWorkout = Index(
    'schedule_entry_workout',
    'CREATE INDEX schedule_entry_workout ON schedule_entry (workout_id)',
  );
  late final Index sessionWorkout = Index(
    'session_workout',
    'CREATE INDEX session_workout ON session (workout_id)',
  );
  late final Index sessionScheduleEntry = Index(
    'session_schedule_entry',
    'CREATE INDEX session_schedule_entry ON session (schedule_entry_id)',
  );
  late final Index sessionChronology = Index(
    'session_chronology',
    'CREATE INDEX session_chronology ON session (started_at)',
  );
  late final Index sessionResumeStatus = Index(
    'session_resume_status',
    'CREATE INDEX session_resume_status ON session (status) WHERE status IN (\'running\', \'paused\')',
  );
  late final Trigger scheduleEntryCompletedSessionOnInsert = Trigger(
    'CREATE TRIGGER schedule_entry_completed_session_on_insert BEFORE INSERT ON schedule_entry WHEN NEW.status = \'completed_by_session\' AND NOT EXISTS (SELECT 1 FROM session WHERE id = NEW.session_id AND schedule_entry_id = NEW.id AND workout_id = NEW.workout_id AND status = \'finished\') BEGIN SELECT RAISE (ABORT, \'completed schedule must reference its finished session\');END',
    'schedule_entry_completed_session_on_insert',
  );
  late final Trigger scheduleEntryCompletedSessionOnUpdate = Trigger(
    'CREATE TRIGGER schedule_entry_completed_session_on_update BEFORE UPDATE OF status, session_id, workout_id ON schedule_entry WHEN NEW.status = \'completed_by_session\' AND NOT EXISTS (SELECT 1 FROM session WHERE id = NEW.session_id AND schedule_entry_id = NEW.id AND workout_id = NEW.workout_id AND status = \'finished\') BEGIN SELECT RAISE (ABORT, \'completed schedule must reference its finished session\');END',
    'schedule_entry_completed_session_on_update',
  );
  late final Trigger sessionCompletedScheduleStatusOnUpdate = Trigger(
    'CREATE TRIGGER session_completed_schedule_status_on_update BEFORE UPDATE OF status, workout_id ON session WHEN EXISTS (SELECT 1 FROM schedule_entry WHERE session_id = OLD.id AND status = \'completed_by_session\') AND(NEW.status <> \'finished\' OR NEW.workout_id IS NOT OLD.workout_id)BEGIN SELECT RAISE (ABORT, \'cannot invalidate completed schedule session link\');END',
    'session_completed_schedule_status_on_update',
  );
  late final SessionExercise sessionExercise = SessionExercise(this);
  late final Index sessionExerciseParentOrder = Index(
    'session_exercise_parent_order',
    'CREATE UNIQUE INDEX session_exercise_parent_order ON session_exercise (session_id, order_index)',
  );
  late final Index sessionExerciseNormalizedName = Index(
    'session_exercise_normalized_name',
    'CREATE INDEX session_exercise_normalized_name ON session_exercise (normalized_name)',
  );
  late final SessionSet sessionSet = SessionSet(this);
  late final Index sessionSetParentOrder = Index(
    'session_set_parent_order',
    'CREATE UNIQUE INDEX session_set_parent_order ON session_set (session_exercise_id, set_index)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appMetadata,
    settings,
    workout,
    workoutExercise,
    workoutExerciseParentOrder,
    workoutExerciseNormalizedName,
    workoutSet,
    workoutSetParentOrder,
    session,
    scheduleEntry,
    scheduleEntryDateStatus,
    scheduleEntryWorkout,
    sessionWorkout,
    sessionScheduleEntry,
    sessionChronology,
    sessionResumeStatus,
    scheduleEntryCompletedSessionOnInsert,
    scheduleEntryCompletedSessionOnUpdate,
    sessionCompletedScheduleStatusOnUpdate,
    sessionExercise,
    sessionExerciseParentOrder,
    sessionExerciseNormalizedName,
    sessionSet,
    sessionSetParentOrder,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_exercise', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_set', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'schedule_entry',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'schedule_entry',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'schedule_entry',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_exercise', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_exercise',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_set', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $AppMetadataCreateCompanionBuilder = AppMetadataCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $AppMetadataUpdateCompanionBuilder = AppMetadataCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $AppMetadataFilterComposer extends Composer<_$AppDatabase, AppMetadata> {
  $AppMetadataFilterComposer({
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
}

class $AppMetadataOrderingComposer
    extends Composer<_$AppDatabase, AppMetadata> {
  $AppMetadataOrderingComposer({
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
}

class $AppMetadataAnnotationComposer
    extends Composer<_$AppDatabase, AppMetadata> {
  $AppMetadataAnnotationComposer({
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
}

class $AppMetadataTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AppMetadata,
          AppMetadataData,
          $AppMetadataFilterComposer,
          $AppMetadataOrderingComposer,
          $AppMetadataAnnotationComposer,
          $AppMetadataCreateCompanionBuilder,
          $AppMetadataUpdateCompanionBuilder,
          (
            AppMetadataData,
            BaseReferences<_$AppDatabase, AppMetadata, AppMetadataData>,
          ),
          AppMetadataData,
          PrefetchHooks Function()
        > {
  $AppMetadataTableManager(_$AppDatabase db, AppMetadata table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AppMetadataFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AppMetadataOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AppMetadataAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AppMetadata, AppMetadataData>(table),
                  BaseReferences<_$AppDatabase, AppMetadata, AppMetadataData>(
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

typedef $AppMetadataProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AppMetadata,
      AppMetadataData,
      $AppMetadataFilterComposer,
      $AppMetadataOrderingComposer,
      $AppMetadataAnnotationComposer,
      $AppMetadataCreateCompanionBuilder,
      $AppMetadataUpdateCompanionBuilder,
      (
        AppMetadataData,
        BaseReferences<_$AppDatabase, AppMetadata, AppMetadataData>,
      ),
      AppMetadataData,
      PrefetchHooks Function()
    >;
typedef $SettingsCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $SettingsUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $SettingsFilterComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsFilterComposer({
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
}

class $SettingsOrderingComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsOrderingComposer({
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
}

class $SettingsAnnotationComposer extends Composer<_$AppDatabase, Settings> {
  $SettingsAnnotationComposer({
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
}

class $SettingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Settings,
          Setting,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$AppDatabase db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Settings, Setting>(table),
                  BaseReferences<_$AppDatabase, Settings, Setting>(
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

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Settings,
      Setting,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, Settings, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $WorkoutCreateCompanionBuilder = WorkoutCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> notes,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
});
typedef $WorkoutUpdateCompanionBuilder = WorkoutCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
});

final class $WorkoutReferences
    extends BaseReferences<_$AppDatabase, Workout, WorkoutData> {
  $WorkoutReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<WorkoutExercise, List<WorkoutExerciseData>>
  _workoutExerciseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutExercise,
    aliasName: 'workout__id__workout_exercise__workout_id',
  );

  $WorkoutExerciseProcessedTableManager get workoutExerciseRefs {
    final manager = $WorkoutExerciseTableManager(
      $_db,
      $_db.workoutExercise,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Session, List<SessionData>> _sessionRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.session,
    aliasName: 'workout__id__session__workout_id',
  );

  $SessionProcessedTableManager get sessionRefs {
    final manager = $SessionTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ScheduleEntry, List<ScheduleEntryData>>
  _scheduleEntryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduleEntry,
    aliasName: 'workout__id__schedule_entry__workout_id',
  );

  $ScheduleEntryProcessedTableManager get scheduleEntryRefs {
    final manager = $ScheduleEntryTableManager(
      $_db,
      $_db.scheduleEntry,
    ).filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scheduleEntryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $WorkoutFilterComposer extends Composer<_$AppDatabase, Workout> {
  $WorkoutFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutExerciseRefs(
    Expression<bool> Function($WorkoutExerciseFilterComposer f) f,
  ) {
    final $WorkoutExerciseFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercise,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutExerciseFilterComposer(
            $db: $db,
            $table: $db.workoutExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionRefs(
    Expression<bool> Function($SessionFilterComposer f) f,
  ) {
    final $SessionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduleEntryRefs(
    Expression<bool> Function($ScheduleEntryFilterComposer f) f,
  ) {
    final $ScheduleEntryFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryFilterComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $WorkoutOrderingComposer extends Composer<_$AppDatabase, Workout> {
  $WorkoutOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $WorkoutAnnotationComposer extends Composer<_$AppDatabase, Workout> {
  $WorkoutAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> workoutExerciseRefs<T extends Object>(
    Expression<T> Function($WorkoutExerciseAnnotationComposer a) f,
  ) {
    final $WorkoutExerciseAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutExercise,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutExerciseAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionRefs<T extends Object>(
    Expression<T> Function($SessionAnnotationComposer a) f,
  ) {
    final $SessionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduleEntryRefs<T extends Object>(
    Expression<T> Function($ScheduleEntryAnnotationComposer a) f,
  ) {
    final $ScheduleEntryAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.workoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryAnnotationComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $WorkoutTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Workout,
          WorkoutData,
          $WorkoutFilterComposer,
          $WorkoutOrderingComposer,
          $WorkoutAnnotationComposer,
          $WorkoutCreateCompanionBuilder,
          $WorkoutUpdateCompanionBuilder,
          (WorkoutData, $WorkoutReferences),
          WorkoutData,
          PrefetchHooks Function({
            bool workoutExerciseRefs,
            bool sessionRefs,
            bool scheduleEntryRefs,
          })
        > {
  $WorkoutTableManager(_$AppDatabase db, Workout table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WorkoutFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WorkoutOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WorkoutAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => WorkoutCompanion(
                id: id,
                name: name,
                notes: notes,
                createdAt: createdAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => WorkoutCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                createdAt: createdAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Workout, WorkoutData>(table),
                  $WorkoutReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutExerciseRefs = false,
                sessionRefs = false,
                scheduleEntryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutExerciseRefs) db.workoutExercise,
                    if (sessionRefs) db.session,
                    if (scheduleEntryRefs) db.scheduleEntry,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutExerciseRefs)
                        await $_getPrefetchedData<
                          WorkoutData,
                          Workout,
                          WorkoutExerciseData
                        >(
                          currentTable: table,
                          referencedTable: $WorkoutReferences
                              ._workoutExerciseRefsTable(db),
                          managerFromTypedResult: (p0) => $WorkoutReferences(
                            db,
                            table,
                            p0,
                          ).workoutExerciseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionRefs)
                        await $_getPrefetchedData<
                          WorkoutData,
                          Workout,
                          SessionData
                        >(
                          currentTable: table,
                          referencedTable: $WorkoutReferences._sessionRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $WorkoutReferences(db, table, p0).sessionRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scheduleEntryRefs)
                        await $_getPrefetchedData<
                          WorkoutData,
                          Workout,
                          ScheduleEntryData
                        >(
                          currentTable: table,
                          referencedTable: $WorkoutReferences
                              ._scheduleEntryRefsTable(db),
                          managerFromTypedResult: (p0) => $WorkoutReferences(
                            db,
                            table,
                            p0,
                          ).scheduleEntryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $WorkoutProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Workout,
      WorkoutData,
      $WorkoutFilterComposer,
      $WorkoutOrderingComposer,
      $WorkoutAnnotationComposer,
      $WorkoutCreateCompanionBuilder,
      $WorkoutUpdateCompanionBuilder,
      (WorkoutData, $WorkoutReferences),
      WorkoutData,
      PrefetchHooks Function({
        bool workoutExerciseRefs,
        bool sessionRefs,
        bool scheduleEntryRefs,
      })
    >;
typedef $WorkoutExerciseCreateCompanionBuilder =
    WorkoutExerciseCompanion Function({
      Value<int> id,
      required int workoutId,
      required String name,
      required String normalizedName,
      required int orderIndex,
      required int plannedSets,
      required String repType,
      Value<int?> targetReps,
      Value<int?> minReps,
      Value<int?> maxReps,
      required String loadType,
      Value<int?> weightCanonicalMg,
      Value<int?> percentage,
      Value<double?> targetRpe,
      Value<String?> freeformText,
      required int restSeconds,
      Value<int?> supersetGroup,
    });
typedef $WorkoutExerciseUpdateCompanionBuilder =
    WorkoutExerciseCompanion Function({
      Value<int> id,
      Value<int> workoutId,
      Value<String> name,
      Value<String> normalizedName,
      Value<int> orderIndex,
      Value<int> plannedSets,
      Value<String> repType,
      Value<int?> targetReps,
      Value<int?> minReps,
      Value<int?> maxReps,
      Value<String> loadType,
      Value<int?> weightCanonicalMg,
      Value<int?> percentage,
      Value<double?> targetRpe,
      Value<String?> freeformText,
      Value<int> restSeconds,
      Value<int?> supersetGroup,
    });

final class $WorkoutExerciseReferences
    extends
        BaseReferences<_$AppDatabase, WorkoutExercise, WorkoutExerciseData> {
  $WorkoutExerciseReferences(super.$_db, super.$_table, super.$_typedResult);

  static Workout _workoutIdTable(_$AppDatabase db) =>
      db.workout.createAlias('workout_exercise__workout_id__workout__id');

  $WorkoutProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $WorkoutTableManager(
      $_db,
      $_db.workout,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<WorkoutSet, List<WorkoutSetData>>
  _workoutSetRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSet,
    aliasName: 'workout_exercise__id__workout_set__workout_exercise_id',
  );

  $WorkoutSetProcessedTableManager get workoutSetRefs {
    final manager = $WorkoutSetTableManager(
      $_db,
      $_db.workoutSet,
    ).filter((f) => f.workoutExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $WorkoutExerciseFilterComposer
    extends Composer<_$AppDatabase, WorkoutExercise> {
  $WorkoutExerciseFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSets => $composableBuilder(
    column: $table.plannedSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repType => $composableBuilder(
    column: $table.repType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minReps => $composableBuilder(
    column: $table.minReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxReps => $composableBuilder(
    column: $table.maxReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loadType => $composableBuilder(
    column: $table.loadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightCanonicalMg => $composableBuilder(
    column: $table.weightCanonicalMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeformText => $composableBuilder(
    column: $table.freeformText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  $WorkoutFilterComposer get workoutId {
    final $WorkoutFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutFilterComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSetRefs(
    Expression<bool> Function($WorkoutSetFilterComposer f) f,
  ) {
    final $WorkoutSetFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSet,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutSetFilterComposer(
            $db: $db,
            $table: $db.workoutSet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $WorkoutExerciseOrderingComposer
    extends Composer<_$AppDatabase, WorkoutExercise> {
  $WorkoutExerciseOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSets => $composableBuilder(
    column: $table.plannedSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repType => $composableBuilder(
    column: $table.repType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minReps => $composableBuilder(
    column: $table.minReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxReps => $composableBuilder(
    column: $table.maxReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loadType => $composableBuilder(
    column: $table.loadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightCanonicalMg => $composableBuilder(
    column: $table.weightCanonicalMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeformText => $composableBuilder(
    column: $table.freeformText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  $WorkoutOrderingComposer get workoutId {
    final $WorkoutOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutOrderingComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WorkoutExerciseAnnotationComposer
    extends Composer<_$AppDatabase, WorkoutExercise> {
  $WorkoutExerciseAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedSets => $composableBuilder(
    column: $table.plannedSets,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repType =>
      $composableBuilder(column: $table.repType, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minReps =>
      $composableBuilder(column: $table.minReps, builder: (column) => column);

  GeneratedColumn<int> get maxReps =>
      $composableBuilder(column: $table.maxReps, builder: (column) => column);

  GeneratedColumn<String> get loadType =>
      $composableBuilder(column: $table.loadType, builder: (column) => column);

  GeneratedColumn<int> get weightCanonicalMg => $composableBuilder(
    column: $table.weightCanonicalMg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetRpe =>
      $composableBuilder(column: $table.targetRpe, builder: (column) => column);

  GeneratedColumn<String> get freeformText => $composableBuilder(
    column: $table.freeformText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  $WorkoutAnnotationComposer get workoutId {
    final $WorkoutAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutAnnotationComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutSetRefs<T extends Object>(
    Expression<T> Function($WorkoutSetAnnotationComposer a) f,
  ) {
    final $WorkoutSetAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSet,
      getReferencedColumn: (t) => t.workoutExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutSetAnnotationComposer(
            $db: $db,
            $table: $db.workoutSet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $WorkoutExerciseTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          WorkoutExercise,
          WorkoutExerciseData,
          $WorkoutExerciseFilterComposer,
          $WorkoutExerciseOrderingComposer,
          $WorkoutExerciseAnnotationComposer,
          $WorkoutExerciseCreateCompanionBuilder,
          $WorkoutExerciseUpdateCompanionBuilder,
          (WorkoutExerciseData, $WorkoutExerciseReferences),
          WorkoutExerciseData,
          PrefetchHooks Function({bool workoutId, bool workoutSetRefs})
        > {
  $WorkoutExerciseTableManager(_$AppDatabase db, WorkoutExercise table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WorkoutExerciseFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WorkoutExerciseOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WorkoutExerciseAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> plannedSets = const Value.absent(),
                Value<String> repType = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> minReps = const Value.absent(),
                Value<int?> maxReps = const Value.absent(),
                Value<String> loadType = const Value.absent(),
                Value<int?> weightCanonicalMg = const Value.absent(),
                Value<int?> percentage = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<String?> freeformText = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
              }) => WorkoutExerciseCompanion(
                id: id,
                workoutId: workoutId,
                name: name,
                normalizedName: normalizedName,
                orderIndex: orderIndex,
                plannedSets: plannedSets,
                repType: repType,
                targetReps: targetReps,
                minReps: minReps,
                maxReps: maxReps,
                loadType: loadType,
                weightCanonicalMg: weightCanonicalMg,
                percentage: percentage,
                targetRpe: targetRpe,
                freeformText: freeformText,
                restSeconds: restSeconds,
                supersetGroup: supersetGroup,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutId,
                required String name,
                required String normalizedName,
                required int orderIndex,
                required int plannedSets,
                required String repType,
                Value<int?> targetReps = const Value.absent(),
                Value<int?> minReps = const Value.absent(),
                Value<int?> maxReps = const Value.absent(),
                required String loadType,
                Value<int?> weightCanonicalMg = const Value.absent(),
                Value<int?> percentage = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<String?> freeformText = const Value.absent(),
                required int restSeconds,
                Value<int?> supersetGroup = const Value.absent(),
              }) => WorkoutExerciseCompanion.insert(
                id: id,
                workoutId: workoutId,
                name: name,
                normalizedName: normalizedName,
                orderIndex: orderIndex,
                plannedSets: plannedSets,
                repType: repType,
                targetReps: targetReps,
                minReps: minReps,
                maxReps: maxReps,
                loadType: loadType,
                weightCanonicalMg: weightCanonicalMg,
                percentage: percentage,
                targetRpe: targetRpe,
                freeformText: freeformText,
                restSeconds: restSeconds,
                supersetGroup: supersetGroup,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<WorkoutExercise, WorkoutExerciseData>(table),
                  $WorkoutExerciseReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutId = false, workoutSetRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (workoutSetRefs) db.workoutSet],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workoutId,
                        referencedTable: $WorkoutExerciseReferences
                            ._workoutIdTable(db),
                        referencedColumn: $WorkoutExerciseReferences
                            ._workoutIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutSetRefs)
                    await $_getPrefetchedData<
                      WorkoutExerciseData,
                      WorkoutExercise,
                      WorkoutSetData
                    >(
                      currentTable: table,
                      referencedTable: $WorkoutExerciseReferences
                          ._workoutSetRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $WorkoutExerciseReferences(
                            db,
                            table,
                            p0,
                          ).workoutSetRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.workoutExerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $WorkoutExerciseProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      WorkoutExercise,
      WorkoutExerciseData,
      $WorkoutExerciseFilterComposer,
      $WorkoutExerciseOrderingComposer,
      $WorkoutExerciseAnnotationComposer,
      $WorkoutExerciseCreateCompanionBuilder,
      $WorkoutExerciseUpdateCompanionBuilder,
      (WorkoutExerciseData, $WorkoutExerciseReferences),
      WorkoutExerciseData,
      PrefetchHooks Function({bool workoutId, bool workoutSetRefs})
    >;
typedef $WorkoutSetCreateCompanionBuilder = WorkoutSetCompanion Function({
  Value<int> id,
  required int workoutExerciseId,
  required int setIndex,
  required String repType,
  Value<int?> targetReps,
  Value<int?> minReps,
  Value<int?> maxReps,
  required String loadType,
  Value<int?> weightCanonicalMg,
  Value<int?> percentage,
  Value<double?> targetRpe,
  Value<String?> freeformText,
  required int restSeconds,
});
typedef $WorkoutSetUpdateCompanionBuilder = WorkoutSetCompanion Function({
  Value<int> id,
  Value<int> workoutExerciseId,
  Value<int> setIndex,
  Value<String> repType,
  Value<int?> targetReps,
  Value<int?> minReps,
  Value<int?> maxReps,
  Value<String> loadType,
  Value<int?> weightCanonicalMg,
  Value<int?> percentage,
  Value<double?> targetRpe,
  Value<String?> freeformText,
  Value<int> restSeconds,
});

final class $WorkoutSetReferences
    extends BaseReferences<_$AppDatabase, WorkoutSet, WorkoutSetData> {
  $WorkoutSetReferences(super.$_db, super.$_table, super.$_typedResult);

  static WorkoutExercise _workoutExerciseIdTable(_$AppDatabase db) => db
      .workoutExercise
      .createAlias('workout_set__workout_exercise_id__workout_exercise__id');

  $WorkoutExerciseProcessedTableManager get workoutExerciseId {
    final $_column = $_itemColumn<int>('workout_exercise_id')!;

    final manager = $WorkoutExerciseTableManager(
      $_db,
      $_db.workoutExercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $WorkoutSetFilterComposer extends Composer<_$AppDatabase, WorkoutSet> {
  $WorkoutSetFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repType => $composableBuilder(
    column: $table.repType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minReps => $composableBuilder(
    column: $table.minReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxReps => $composableBuilder(
    column: $table.maxReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loadType => $composableBuilder(
    column: $table.loadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weightCanonicalMg => $composableBuilder(
    column: $table.weightCanonicalMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeformText => $composableBuilder(
    column: $table.freeformText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $WorkoutExerciseFilterComposer get workoutExerciseId {
    final $WorkoutExerciseFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutExerciseFilterComposer(
            $db: $db,
            $table: $db.workoutExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WorkoutSetOrderingComposer extends Composer<_$AppDatabase, WorkoutSet> {
  $WorkoutSetOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repType => $composableBuilder(
    column: $table.repType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minReps => $composableBuilder(
    column: $table.minReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxReps => $composableBuilder(
    column: $table.maxReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loadType => $composableBuilder(
    column: $table.loadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weightCanonicalMg => $composableBuilder(
    column: $table.weightCanonicalMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetRpe => $composableBuilder(
    column: $table.targetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeformText => $composableBuilder(
    column: $table.freeformText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $WorkoutExerciseOrderingComposer get workoutExerciseId {
    final $WorkoutExerciseOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutExerciseOrderingComposer(
            $db: $db,
            $table: $db.workoutExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WorkoutSetAnnotationComposer
    extends Composer<_$AppDatabase, WorkoutSet> {
  $WorkoutSetAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<String> get repType =>
      $composableBuilder(column: $table.repType, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minReps =>
      $composableBuilder(column: $table.minReps, builder: (column) => column);

  GeneratedColumn<int> get maxReps =>
      $composableBuilder(column: $table.maxReps, builder: (column) => column);

  GeneratedColumn<String> get loadType =>
      $composableBuilder(column: $table.loadType, builder: (column) => column);

  GeneratedColumn<int> get weightCanonicalMg => $composableBuilder(
    column: $table.weightCanonicalMg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetRpe =>
      $composableBuilder(column: $table.targetRpe, builder: (column) => column);

  GeneratedColumn<String> get freeformText => $composableBuilder(
    column: $table.freeformText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  $WorkoutExerciseAnnotationComposer get workoutExerciseId {
    final $WorkoutExerciseAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutExerciseId,
      referencedTable: $db.workoutExercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutExerciseAnnotationComposer(
            $db: $db,
            $table: $db.workoutExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $WorkoutSetTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          WorkoutSet,
          WorkoutSetData,
          $WorkoutSetFilterComposer,
          $WorkoutSetOrderingComposer,
          $WorkoutSetAnnotationComposer,
          $WorkoutSetCreateCompanionBuilder,
          $WorkoutSetUpdateCompanionBuilder,
          (WorkoutSetData, $WorkoutSetReferences),
          WorkoutSetData,
          PrefetchHooks Function({bool workoutExerciseId})
        > {
  $WorkoutSetTableManager(_$AppDatabase db, WorkoutSet table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WorkoutSetFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WorkoutSetOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WorkoutSetAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutExerciseId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<String> repType = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> minReps = const Value.absent(),
                Value<int?> maxReps = const Value.absent(),
                Value<String> loadType = const Value.absent(),
                Value<int?> weightCanonicalMg = const Value.absent(),
                Value<int?> percentage = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<String?> freeformText = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
              }) => WorkoutSetCompanion(
                id: id,
                workoutExerciseId: workoutExerciseId,
                setIndex: setIndex,
                repType: repType,
                targetReps: targetReps,
                minReps: minReps,
                maxReps: maxReps,
                loadType: loadType,
                weightCanonicalMg: weightCanonicalMg,
                percentage: percentage,
                targetRpe: targetRpe,
                freeformText: freeformText,
                restSeconds: restSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutExerciseId,
                required int setIndex,
                required String repType,
                Value<int?> targetReps = const Value.absent(),
                Value<int?> minReps = const Value.absent(),
                Value<int?> maxReps = const Value.absent(),
                required String loadType,
                Value<int?> weightCanonicalMg = const Value.absent(),
                Value<int?> percentage = const Value.absent(),
                Value<double?> targetRpe = const Value.absent(),
                Value<String?> freeformText = const Value.absent(),
                required int restSeconds,
              }) => WorkoutSetCompanion.insert(
                id: id,
                workoutExerciseId: workoutExerciseId,
                setIndex: setIndex,
                repType: repType,
                targetReps: targetReps,
                minReps: minReps,
                maxReps: maxReps,
                loadType: loadType,
                weightCanonicalMg: weightCanonicalMg,
                percentage: percentage,
                targetRpe: targetRpe,
                freeformText: freeformText,
                restSeconds: restSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<WorkoutSet, WorkoutSetData>(table),
                  $WorkoutSetReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workoutExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workoutExerciseId,
                        referencedTable: $WorkoutSetReferences
                            ._workoutExerciseIdTable(db),
                        referencedColumn: $WorkoutSetReferences
                            ._workoutExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $WorkoutSetProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      WorkoutSet,
      WorkoutSetData,
      $WorkoutSetFilterComposer,
      $WorkoutSetOrderingComposer,
      $WorkoutSetAnnotationComposer,
      $WorkoutSetCreateCompanionBuilder,
      $WorkoutSetUpdateCompanionBuilder,
      (WorkoutSetData, $WorkoutSetReferences),
      WorkoutSetData,
      PrefetchHooks Function({bool workoutExerciseId})
    >;
typedef $SessionCreateCompanionBuilder = SessionCompanion Function({
  Value<int> id,
  Value<int?> workoutId,
  Value<int?> scheduleEntryId,
  required String workoutNameSnapshot,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  required String timezone,
  required String status,
  Value<String?> notes,
  Value<DateTime?> restStartedAt,
  Value<int?> restDurationSeconds,
  Value<DateTime?> restTargetAt,
});
typedef $SessionUpdateCompanionBuilder = SessionCompanion Function({
  Value<int> id,
  Value<int?> workoutId,
  Value<int?> scheduleEntryId,
  Value<String> workoutNameSnapshot,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String> timezone,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime?> restStartedAt,
  Value<int?> restDurationSeconds,
  Value<DateTime?> restTargetAt,
});

final class $SessionReferences
    extends BaseReferences<_$AppDatabase, Session, SessionData> {
  $SessionReferences(super.$_db, super.$_table, super.$_typedResult);

  static Workout _workoutIdTable(_$AppDatabase db) =>
      db.workout.createAlias('session__workout_id__workout__id');

  $WorkoutProcessedTableManager? get workoutId {
    final $_column = $_itemColumn<int>('workout_id');
    if ($_column == null) return null;
    final manager = $WorkoutTableManager(
      $_db,
      $_db.workout,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static ScheduleEntry _scheduleEntryIdTable(_$AppDatabase db) => db
      .scheduleEntry
      .createAlias('session__schedule_entry_id__schedule_entry__id');

  $ScheduleEntryProcessedTableManager? get scheduleEntryId {
    final $_column = $_itemColumn<int>('schedule_entry_id');
    if ($_column == null) return null;
    final manager = $ScheduleEntryTableManager(
      $_db,
      $_db.scheduleEntry,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ScheduleEntry, List<ScheduleEntryData>>
  _scheduleEntryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduleEntry,
    aliasName: 'session__id__schedule_entry__session_id',
  );

  $ScheduleEntryProcessedTableManager get scheduleEntryRefs {
    final manager = $ScheduleEntryTableManager(
      $_db,
      $_db.scheduleEntry,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scheduleEntryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<SessionExercise, List<SessionExerciseData>>
  _sessionExerciseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionExercise,
    aliasName: 'session__id__session_exercise__session_id',
  );

  $SessionExerciseProcessedTableManager get sessionExerciseRefs {
    final manager = $SessionExerciseTableManager(
      $_db,
      $_db.sessionExercise,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExerciseRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SessionFilterComposer extends Composer<_$AppDatabase, Session> {
  $SessionFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutNameSnapshot => $composableBuilder(
    column: $table.workoutNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get restStartedAt => $composableBuilder(
    column: $table.restStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restDurationSeconds => $composableBuilder(
    column: $table.restDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get restTargetAt => $composableBuilder(
    column: $table.restTargetAt,
    builder: (column) => ColumnFilters(column),
  );

  $WorkoutFilterComposer get workoutId {
    final $WorkoutFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutFilterComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ScheduleEntryFilterComposer get scheduleEntryId {
    final $ScheduleEntryFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleEntryId,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryFilterComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> scheduleEntryRefs(
    Expression<bool> Function($ScheduleEntryFilterComposer f) f,
  ) {
    final $ScheduleEntryFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryFilterComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExerciseRefs(
    Expression<bool> Function($SessionExerciseFilterComposer f) f,
  ) {
    final $SessionExerciseFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionExerciseFilterComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SessionOrderingComposer extends Composer<_$AppDatabase, Session> {
  $SessionOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutNameSnapshot => $composableBuilder(
    column: $table.workoutNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get restStartedAt => $composableBuilder(
    column: $table.restStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDurationSeconds => $composableBuilder(
    column: $table.restDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get restTargetAt => $composableBuilder(
    column: $table.restTargetAt,
    builder: (column) => ColumnOrderings(column),
  );

  $WorkoutOrderingComposer get workoutId {
    final $WorkoutOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutOrderingComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ScheduleEntryOrderingComposer get scheduleEntryId {
    final $ScheduleEntryOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleEntryId,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryOrderingComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionAnnotationComposer extends Composer<_$AppDatabase, Session> {
  $SessionAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workoutNameSnapshot => $composableBuilder(
    column: $table.workoutNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get restStartedAt => $composableBuilder(
    column: $table.restStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restDurationSeconds => $composableBuilder(
    column: $table.restDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get restTargetAt => $composableBuilder(
    column: $table.restTargetAt,
    builder: (column) => column,
  );

  $WorkoutAnnotationComposer get workoutId {
    final $WorkoutAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutAnnotationComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ScheduleEntryAnnotationComposer get scheduleEntryId {
    final $ScheduleEntryAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleEntryId,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryAnnotationComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> scheduleEntryRefs<T extends Object>(
    Expression<T> Function($ScheduleEntryAnnotationComposer a) f,
  ) {
    final $ScheduleEntryAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleEntry,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ScheduleEntryAnnotationComposer(
            $db: $db,
            $table: $db.scheduleEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionExerciseRefs<T extends Object>(
    Expression<T> Function($SessionExerciseAnnotationComposer a) f,
  ) {
    final $SessionExerciseAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionExerciseAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SessionTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Session,
          SessionData,
          $SessionFilterComposer,
          $SessionOrderingComposer,
          $SessionAnnotationComposer,
          $SessionCreateCompanionBuilder,
          $SessionUpdateCompanionBuilder,
          (SessionData, $SessionReferences),
          SessionData,
          PrefetchHooks Function({
            bool workoutId,
            bool scheduleEntryId,
            bool scheduleEntryRefs,
            bool sessionExerciseRefs,
          })
        > {
  $SessionTableManager(_$AppDatabase db, Session table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SessionFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SessionOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SessionAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> workoutId = const Value.absent(),
                Value<int?> scheduleEntryId = const Value.absent(),
                Value<String> workoutNameSnapshot = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> restStartedAt = const Value.absent(),
                Value<int?> restDurationSeconds = const Value.absent(),
                Value<DateTime?> restTargetAt = const Value.absent(),
              }) => SessionCompanion(
                id: id,
                workoutId: workoutId,
                scheduleEntryId: scheduleEntryId,
                workoutNameSnapshot: workoutNameSnapshot,
                startedAt: startedAt,
                endedAt: endedAt,
                timezone: timezone,
                status: status,
                notes: notes,
                restStartedAt: restStartedAt,
                restDurationSeconds: restDurationSeconds,
                restTargetAt: restTargetAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> workoutId = const Value.absent(),
                Value<int?> scheduleEntryId = const Value.absent(),
                required String workoutNameSnapshot,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required String timezone,
                required String status,
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> restStartedAt = const Value.absent(),
                Value<int?> restDurationSeconds = const Value.absent(),
                Value<DateTime?> restTargetAt = const Value.absent(),
              }) => SessionCompanion.insert(
                id: id,
                workoutId: workoutId,
                scheduleEntryId: scheduleEntryId,
                workoutNameSnapshot: workoutNameSnapshot,
                startedAt: startedAt,
                endedAt: endedAt,
                timezone: timezone,
                status: status,
                notes: notes,
                restStartedAt: restStartedAt,
                restDurationSeconds: restDurationSeconds,
                restTargetAt: restTargetAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Session, SessionData>(table),
                  $SessionReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutId = false,
                scheduleEntryId = false,
                scheduleEntryRefs = false,
                sessionExerciseRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleEntryRefs) db.scheduleEntry,
                    if (sessionExerciseRefs) db.sessionExercise,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutId,
                            referencedTable: $SessionReferences._workoutIdTable(
                              db,
                            ),
                            referencedColumn: $SessionReferences
                                ._workoutIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (scheduleEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scheduleEntryId,
                            referencedTable: $SessionReferences
                                ._scheduleEntryIdTable(db),
                            referencedColumn: $SessionReferences
                                ._scheduleEntryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleEntryRefs)
                        await $_getPrefetchedData<
                          SessionData,
                          Session,
                          ScheduleEntryData
                        >(
                          currentTable: table,
                          referencedTable: $SessionReferences
                              ._scheduleEntryRefsTable(db),
                          managerFromTypedResult: (p0) => $SessionReferences(
                            db,
                            table,
                            p0,
                          ).scheduleEntryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionExerciseRefs)
                        await $_getPrefetchedData<
                          SessionData,
                          Session,
                          SessionExerciseData
                        >(
                          currentTable: table,
                          referencedTable: $SessionReferences
                              ._sessionExerciseRefsTable(db),
                          managerFromTypedResult: (p0) => $SessionReferences(
                            db,
                            table,
                            p0,
                          ).sessionExerciseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $SessionProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Session,
      SessionData,
      $SessionFilterComposer,
      $SessionOrderingComposer,
      $SessionAnnotationComposer,
      $SessionCreateCompanionBuilder,
      $SessionUpdateCompanionBuilder,
      (SessionData, $SessionReferences),
      SessionData,
      PrefetchHooks Function({
        bool workoutId,
        bool scheduleEntryId,
        bool scheduleEntryRefs,
        bool sessionExerciseRefs,
      })
    >;
typedef $ScheduleEntryCreateCompanionBuilder = ScheduleEntryCompanion Function({
  Value<int> id,
  required int workoutId,
  required String date,
  Value<int?> startTime,
  Value<String?> label,
  required String status,
  Value<int?> sessionId,
});
typedef $ScheduleEntryUpdateCompanionBuilder = ScheduleEntryCompanion Function({
  Value<int> id,
  Value<int> workoutId,
  Value<String> date,
  Value<int?> startTime,
  Value<String?> label,
  Value<String> status,
  Value<int?> sessionId,
});

final class $ScheduleEntryReferences
    extends BaseReferences<_$AppDatabase, ScheduleEntry, ScheduleEntryData> {
  $ScheduleEntryReferences(super.$_db, super.$_table, super.$_typedResult);

  static Workout _workoutIdTable(_$AppDatabase db) =>
      db.workout.createAlias('schedule_entry__workout_id__workout__id');

  $WorkoutProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $WorkoutTableManager(
      $_db,
      $_db.workout,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Session _sessionIdTable(_$AppDatabase db) =>
      db.session.createAlias('schedule_entry__session_id__session__id');

  $SessionProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $SessionTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Session, List<SessionData>> _sessionRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.session,
    aliasName: 'schedule_entry__id__session__schedule_entry_id',
  );

  $SessionProcessedTableManager get sessionRefs {
    final manager = $SessionTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.scheduleEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ScheduleEntryFilterComposer
    extends Composer<_$AppDatabase, ScheduleEntry> {
  $ScheduleEntryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $WorkoutFilterComposer get workoutId {
    final $WorkoutFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutFilterComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SessionFilterComposer get sessionId {
    final $SessionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionRefs(
    Expression<bool> Function($SessionFilterComposer f) f,
  ) {
    final $SessionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.scheduleEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ScheduleEntryOrderingComposer
    extends Composer<_$AppDatabase, ScheduleEntry> {
  $ScheduleEntryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $WorkoutOrderingComposer get workoutId {
    final $WorkoutOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutOrderingComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SessionOrderingComposer get sessionId {
    final $SessionOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionOrderingComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ScheduleEntryAnnotationComposer
    extends Composer<_$AppDatabase, ScheduleEntry> {
  $ScheduleEntryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $WorkoutAnnotationComposer get workoutId {
    final $WorkoutAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutId,
      referencedTable: $db.workout,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $WorkoutAnnotationComposer(
            $db: $db,
            $table: $db.workout,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $SessionAnnotationComposer get sessionId {
    final $SessionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionRefs<T extends Object>(
    Expression<T> Function($SessionAnnotationComposer a) f,
  ) {
    final $SessionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.scheduleEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ScheduleEntryTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ScheduleEntry,
          ScheduleEntryData,
          $ScheduleEntryFilterComposer,
          $ScheduleEntryOrderingComposer,
          $ScheduleEntryAnnotationComposer,
          $ScheduleEntryCreateCompanionBuilder,
          $ScheduleEntryUpdateCompanionBuilder,
          (ScheduleEntryData, $ScheduleEntryReferences),
          ScheduleEntryData,
          PrefetchHooks Function({
            bool workoutId,
            bool sessionId,
            bool sessionRefs,
          })
        > {
  $ScheduleEntryTableManager(_$AppDatabase db, ScheduleEntry table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ScheduleEntryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ScheduleEntryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ScheduleEntryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int?> startTime = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
              }) => ScheduleEntryCompanion(
                id: id,
                workoutId: workoutId,
                date: date,
                startTime: startTime,
                label: label,
                status: status,
                sessionId: sessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutId,
                required String date,
                Value<int?> startTime = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required String status,
                Value<int?> sessionId = const Value.absent(),
              }) => ScheduleEntryCompanion.insert(
                id: id,
                workoutId: workoutId,
                date: date,
                startTime: startTime,
                label: label,
                status: status,
                sessionId: sessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ScheduleEntry, ScheduleEntryData>(table),
                  $ScheduleEntryReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutId = false, sessionId = false, sessionRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (sessionRefs) db.session],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workoutId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutId,
                            referencedTable: $ScheduleEntryReferences
                                ._workoutIdTable(db),
                            referencedColumn: $ScheduleEntryReferences
                                ._workoutIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $ScheduleEntryReferences
                                ._sessionIdTable(db),
                            referencedColumn: $ScheduleEntryReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionRefs)
                        await $_getPrefetchedData<
                          ScheduleEntryData,
                          ScheduleEntry,
                          SessionData
                        >(
                          currentTable: table,
                          referencedTable: $ScheduleEntryReferences
                              ._sessionRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ScheduleEntryReferences(
                                db,
                                table,
                                p0,
                              ).sessionRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ScheduleEntryProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ScheduleEntry,
      ScheduleEntryData,
      $ScheduleEntryFilterComposer,
      $ScheduleEntryOrderingComposer,
      $ScheduleEntryAnnotationComposer,
      $ScheduleEntryCreateCompanionBuilder,
      $ScheduleEntryUpdateCompanionBuilder,
      (ScheduleEntryData, $ScheduleEntryReferences),
      ScheduleEntryData,
      PrefetchHooks Function({bool workoutId, bool sessionId, bool sessionRefs})
    >;
typedef $SessionExerciseCreateCompanionBuilder =
    SessionExerciseCompanion Function({
      Value<int> id,
      required int sessionId,
      required String nameSnapshot,
      required String normalizedName,
      required int orderIndex,
      required int plannedSets,
      required String plannedRepType,
      Value<int?> plannedTargetReps,
      Value<int?> plannedMinReps,
      Value<int?> plannedMaxReps,
      required String plannedLoadType,
      Value<int?> plannedWeightCanonicalMg,
      Value<int?> plannedPercentage,
      Value<double?> plannedTargetRpe,
      Value<String?> plannedFreeformText,
      required int plannedRestSeconds,
      Value<int?> supersetGroup,
    });
typedef $SessionExerciseUpdateCompanionBuilder =
    SessionExerciseCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> nameSnapshot,
      Value<String> normalizedName,
      Value<int> orderIndex,
      Value<int> plannedSets,
      Value<String> plannedRepType,
      Value<int?> plannedTargetReps,
      Value<int?> plannedMinReps,
      Value<int?> plannedMaxReps,
      Value<String> plannedLoadType,
      Value<int?> plannedWeightCanonicalMg,
      Value<int?> plannedPercentage,
      Value<double?> plannedTargetRpe,
      Value<String?> plannedFreeformText,
      Value<int> plannedRestSeconds,
      Value<int?> supersetGroup,
    });

final class $SessionExerciseReferences
    extends
        BaseReferences<_$AppDatabase, SessionExercise, SessionExerciseData> {
  $SessionExerciseReferences(super.$_db, super.$_table, super.$_typedResult);

  static Session _sessionIdTable(_$AppDatabase db) =>
      db.session.createAlias('session_exercise__session_id__session__id');

  $SessionProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $SessionTableManager(
      $_db,
      $_db.session,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<SessionSet, List<SessionSetData>>
  _sessionSetRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionSet,
    aliasName: 'session_exercise__id__session_set__session_exercise_id',
  );

  $SessionSetProcessedTableManager get sessionSetRefs {
    final manager = $SessionSetTableManager(
      $_db,
      $_db.sessionSet,
    ).filter((f) => f.sessionExerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionSetRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SessionExerciseFilterComposer
    extends Composer<_$AppDatabase, SessionExercise> {
  $SessionExerciseFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSnapshot => $composableBuilder(
    column: $table.nameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSets => $composableBuilder(
    column: $table.plannedSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedRepType => $composableBuilder(
    column: $table.plannedRepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedTargetReps => $composableBuilder(
    column: $table.plannedTargetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMinReps => $composableBuilder(
    column: $table.plannedMinReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMaxReps => $composableBuilder(
    column: $table.plannedMaxReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedLoadType => $composableBuilder(
    column: $table.plannedLoadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedWeightCanonicalMg => $composableBuilder(
    column: $table.plannedWeightCanonicalMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedPercentage => $composableBuilder(
    column: $table.plannedPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedTargetRpe => $composableBuilder(
    column: $table.plannedTargetRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedFreeformText => $composableBuilder(
    column: $table.plannedFreeformText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRestSeconds => $composableBuilder(
    column: $table.plannedRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  $SessionFilterComposer get sessionId {
    final $SessionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionFilterComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionSetRefs(
    Expression<bool> Function($SessionSetFilterComposer f) f,
  ) {
    final $SessionSetFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSet,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionSetFilterComposer(
            $db: $db,
            $table: $db.sessionSet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SessionExerciseOrderingComposer
    extends Composer<_$AppDatabase, SessionExercise> {
  $SessionExerciseOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSnapshot => $composableBuilder(
    column: $table.nameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSets => $composableBuilder(
    column: $table.plannedSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedRepType => $composableBuilder(
    column: $table.plannedRepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedTargetReps => $composableBuilder(
    column: $table.plannedTargetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMinReps => $composableBuilder(
    column: $table.plannedMinReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMaxReps => $composableBuilder(
    column: $table.plannedMaxReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedLoadType => $composableBuilder(
    column: $table.plannedLoadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedWeightCanonicalMg => $composableBuilder(
    column: $table.plannedWeightCanonicalMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedPercentage => $composableBuilder(
    column: $table.plannedPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedTargetRpe => $composableBuilder(
    column: $table.plannedTargetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedFreeformText => $composableBuilder(
    column: $table.plannedFreeformText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRestSeconds => $composableBuilder(
    column: $table.plannedRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  $SessionOrderingComposer get sessionId {
    final $SessionOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionOrderingComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionExerciseAnnotationComposer
    extends Composer<_$AppDatabase, SessionExercise> {
  $SessionExerciseAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameSnapshot => $composableBuilder(
    column: $table.nameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedSets => $composableBuilder(
    column: $table.plannedSets,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plannedRepType => $composableBuilder(
    column: $table.plannedRepType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedTargetReps => $composableBuilder(
    column: $table.plannedTargetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedMinReps => $composableBuilder(
    column: $table.plannedMinReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedMaxReps => $composableBuilder(
    column: $table.plannedMaxReps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plannedLoadType => $composableBuilder(
    column: $table.plannedLoadType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedWeightCanonicalMg => $composableBuilder(
    column: $table.plannedWeightCanonicalMg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedPercentage => $composableBuilder(
    column: $table.plannedPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedTargetRpe => $composableBuilder(
    column: $table.plannedTargetRpe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plannedFreeformText => $composableBuilder(
    column: $table.plannedFreeformText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedRestSeconds => $composableBuilder(
    column: $table.plannedRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  $SessionAnnotationComposer get sessionId {
    final $SessionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.session,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionAnnotationComposer(
            $db: $db,
            $table: $db.session,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionSetRefs<T extends Object>(
    Expression<T> Function($SessionSetAnnotationComposer a) f,
  ) {
    final $SessionSetAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSet,
      getReferencedColumn: (t) => t.sessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionSetAnnotationComposer(
            $db: $db,
            $table: $db.sessionSet,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SessionExerciseTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SessionExercise,
          SessionExerciseData,
          $SessionExerciseFilterComposer,
          $SessionExerciseOrderingComposer,
          $SessionExerciseAnnotationComposer,
          $SessionExerciseCreateCompanionBuilder,
          $SessionExerciseUpdateCompanionBuilder,
          (SessionExerciseData, $SessionExerciseReferences),
          SessionExerciseData,
          PrefetchHooks Function({bool sessionId, bool sessionSetRefs})
        > {
  $SessionExerciseTableManager(_$AppDatabase db, SessionExercise table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SessionExerciseFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SessionExerciseOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SessionExerciseAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> nameSnapshot = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> plannedSets = const Value.absent(),
                Value<String> plannedRepType = const Value.absent(),
                Value<int?> plannedTargetReps = const Value.absent(),
                Value<int?> plannedMinReps = const Value.absent(),
                Value<int?> plannedMaxReps = const Value.absent(),
                Value<String> plannedLoadType = const Value.absent(),
                Value<int?> plannedWeightCanonicalMg = const Value.absent(),
                Value<int?> plannedPercentage = const Value.absent(),
                Value<double?> plannedTargetRpe = const Value.absent(),
                Value<String?> plannedFreeformText = const Value.absent(),
                Value<int> plannedRestSeconds = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
              }) => SessionExerciseCompanion(
                id: id,
                sessionId: sessionId,
                nameSnapshot: nameSnapshot,
                normalizedName: normalizedName,
                orderIndex: orderIndex,
                plannedSets: plannedSets,
                plannedRepType: plannedRepType,
                plannedTargetReps: plannedTargetReps,
                plannedMinReps: plannedMinReps,
                plannedMaxReps: plannedMaxReps,
                plannedLoadType: plannedLoadType,
                plannedWeightCanonicalMg: plannedWeightCanonicalMg,
                plannedPercentage: plannedPercentage,
                plannedTargetRpe: plannedTargetRpe,
                plannedFreeformText: plannedFreeformText,
                plannedRestSeconds: plannedRestSeconds,
                supersetGroup: supersetGroup,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String nameSnapshot,
                required String normalizedName,
                required int orderIndex,
                required int plannedSets,
                required String plannedRepType,
                Value<int?> plannedTargetReps = const Value.absent(),
                Value<int?> plannedMinReps = const Value.absent(),
                Value<int?> plannedMaxReps = const Value.absent(),
                required String plannedLoadType,
                Value<int?> plannedWeightCanonicalMg = const Value.absent(),
                Value<int?> plannedPercentage = const Value.absent(),
                Value<double?> plannedTargetRpe = const Value.absent(),
                Value<String?> plannedFreeformText = const Value.absent(),
                required int plannedRestSeconds,
                Value<int?> supersetGroup = const Value.absent(),
              }) => SessionExerciseCompanion.insert(
                id: id,
                sessionId: sessionId,
                nameSnapshot: nameSnapshot,
                normalizedName: normalizedName,
                orderIndex: orderIndex,
                plannedSets: plannedSets,
                plannedRepType: plannedRepType,
                plannedTargetReps: plannedTargetReps,
                plannedMinReps: plannedMinReps,
                plannedMaxReps: plannedMaxReps,
                plannedLoadType: plannedLoadType,
                plannedWeightCanonicalMg: plannedWeightCanonicalMg,
                plannedPercentage: plannedPercentage,
                plannedTargetRpe: plannedTargetRpe,
                plannedFreeformText: plannedFreeformText,
                plannedRestSeconds: plannedRestSeconds,
                supersetGroup: supersetGroup,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SessionExercise, SessionExerciseData>(table),
                  $SessionExerciseReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, sessionSetRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionSetRefs) db.sessionSet],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $SessionExerciseReferences
                            ._sessionIdTable(db),
                        referencedColumn: $SessionExerciseReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionSetRefs)
                    await $_getPrefetchedData<
                      SessionExerciseData,
                      SessionExercise,
                      SessionSetData
                    >(
                      currentTable: table,
                      referencedTable: $SessionExerciseReferences
                          ._sessionSetRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $SessionExerciseReferences(
                            db,
                            table,
                            p0,
                          ).sessionSetRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sessionExerciseId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $SessionExerciseProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SessionExercise,
      SessionExerciseData,
      $SessionExerciseFilterComposer,
      $SessionExerciseOrderingComposer,
      $SessionExerciseAnnotationComposer,
      $SessionExerciseCreateCompanionBuilder,
      $SessionExerciseUpdateCompanionBuilder,
      (SessionExerciseData, $SessionExerciseReferences),
      SessionExerciseData,
      PrefetchHooks Function({bool sessionId, bool sessionSetRefs})
    >;
typedef $SessionSetCreateCompanionBuilder = SessionSetCompanion Function({
  Value<int> id,
  required int sessionExerciseId,
  required int setIndex,
  required String plannedRepType,
  Value<int?> plannedTargetReps,
  Value<int?> plannedMinReps,
  Value<int?> plannedMaxReps,
  required String plannedLoadType,
  Value<int?> plannedWeightCanonicalMg,
  Value<int?> plannedPercentage,
  Value<double?> plannedTargetRpe,
  Value<String?> plannedFreeformText,
  Value<String?> actualRepType,
  Value<int?> actualTargetReps,
  Value<int?> actualMinReps,
  Value<int?> actualMaxReps,
  Value<String?> actualLoadType,
  Value<int?> actualWeightCanonicalMg,
  Value<int?> actualPercentage,
  Value<double?> actualTargetRpe,
  Value<String?> actualFreeformText,
  Value<double?> rpe,
  required bool completed,
  Value<DateTime?> completedAt,
  Value<int?> plannedRestSeconds,
});
typedef $SessionSetUpdateCompanionBuilder = SessionSetCompanion Function({
  Value<int> id,
  Value<int> sessionExerciseId,
  Value<int> setIndex,
  Value<String> plannedRepType,
  Value<int?> plannedTargetReps,
  Value<int?> plannedMinReps,
  Value<int?> plannedMaxReps,
  Value<String> plannedLoadType,
  Value<int?> plannedWeightCanonicalMg,
  Value<int?> plannedPercentage,
  Value<double?> plannedTargetRpe,
  Value<String?> plannedFreeformText,
  Value<String?> actualRepType,
  Value<int?> actualTargetReps,
  Value<int?> actualMinReps,
  Value<int?> actualMaxReps,
  Value<String?> actualLoadType,
  Value<int?> actualWeightCanonicalMg,
  Value<int?> actualPercentage,
  Value<double?> actualTargetRpe,
  Value<String?> actualFreeformText,
  Value<double?> rpe,
  Value<bool> completed,
  Value<DateTime?> completedAt,
  Value<int?> plannedRestSeconds,
});

final class $SessionSetReferences
    extends BaseReferences<_$AppDatabase, SessionSet, SessionSetData> {
  $SessionSetReferences(super.$_db, super.$_table, super.$_typedResult);

  static SessionExercise _sessionExerciseIdTable(_$AppDatabase db) => db
      .sessionExercise
      .createAlias('session_set__session_exercise_id__session_exercise__id');

  $SessionExerciseProcessedTableManager get sessionExerciseId {
    final $_column = $_itemColumn<int>('session_exercise_id')!;

    final manager = $SessionExerciseTableManager(
      $_db,
      $_db.sessionExercise,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SessionSetFilterComposer extends Composer<_$AppDatabase, SessionSet> {
  $SessionSetFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedRepType => $composableBuilder(
    column: $table.plannedRepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedTargetReps => $composableBuilder(
    column: $table.plannedTargetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMinReps => $composableBuilder(
    column: $table.plannedMinReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedMaxReps => $composableBuilder(
    column: $table.plannedMaxReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedLoadType => $composableBuilder(
    column: $table.plannedLoadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedWeightCanonicalMg => $composableBuilder(
    column: $table.plannedWeightCanonicalMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedPercentage => $composableBuilder(
    column: $table.plannedPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedTargetRpe => $composableBuilder(
    column: $table.plannedTargetRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedFreeformText => $composableBuilder(
    column: $table.plannedFreeformText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualRepType => $composableBuilder(
    column: $table.actualRepType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualTargetReps => $composableBuilder(
    column: $table.actualTargetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMinReps => $composableBuilder(
    column: $table.actualMinReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMaxReps => $composableBuilder(
    column: $table.actualMaxReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualLoadType => $composableBuilder(
    column: $table.actualLoadType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualWeightCanonicalMg => $composableBuilder(
    column: $table.actualWeightCanonicalMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualPercentage => $composableBuilder(
    column: $table.actualPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualTargetRpe => $composableBuilder(
    column: $table.actualTargetRpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualFreeformText => $composableBuilder(
    column: $table.actualFreeformText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedRestSeconds => $composableBuilder(
    column: $table.plannedRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $SessionExerciseFilterComposer get sessionExerciseId {
    final $SessionExerciseFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionExerciseFilterComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionSetOrderingComposer extends Composer<_$AppDatabase, SessionSet> {
  $SessionSetOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedRepType => $composableBuilder(
    column: $table.plannedRepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedTargetReps => $composableBuilder(
    column: $table.plannedTargetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMinReps => $composableBuilder(
    column: $table.plannedMinReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedMaxReps => $composableBuilder(
    column: $table.plannedMaxReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedLoadType => $composableBuilder(
    column: $table.plannedLoadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedWeightCanonicalMg => $composableBuilder(
    column: $table.plannedWeightCanonicalMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedPercentage => $composableBuilder(
    column: $table.plannedPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedTargetRpe => $composableBuilder(
    column: $table.plannedTargetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedFreeformText => $composableBuilder(
    column: $table.plannedFreeformText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualRepType => $composableBuilder(
    column: $table.actualRepType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualTargetReps => $composableBuilder(
    column: $table.actualTargetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMinReps => $composableBuilder(
    column: $table.actualMinReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMaxReps => $composableBuilder(
    column: $table.actualMaxReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualLoadType => $composableBuilder(
    column: $table.actualLoadType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualWeightCanonicalMg => $composableBuilder(
    column: $table.actualWeightCanonicalMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualPercentage => $composableBuilder(
    column: $table.actualPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualTargetRpe => $composableBuilder(
    column: $table.actualTargetRpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualFreeformText => $composableBuilder(
    column: $table.actualFreeformText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedRestSeconds => $composableBuilder(
    column: $table.plannedRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $SessionExerciseOrderingComposer get sessionExerciseId {
    final $SessionExerciseOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionExerciseOrderingComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionSetAnnotationComposer
    extends Composer<_$AppDatabase, SessionSet> {
  $SessionSetAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<String> get plannedRepType => $composableBuilder(
    column: $table.plannedRepType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedTargetReps => $composableBuilder(
    column: $table.plannedTargetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedMinReps => $composableBuilder(
    column: $table.plannedMinReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedMaxReps => $composableBuilder(
    column: $table.plannedMaxReps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plannedLoadType => $composableBuilder(
    column: $table.plannedLoadType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedWeightCanonicalMg => $composableBuilder(
    column: $table.plannedWeightCanonicalMg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedPercentage => $composableBuilder(
    column: $table.plannedPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedTargetRpe => $composableBuilder(
    column: $table.plannedTargetRpe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plannedFreeformText => $composableBuilder(
    column: $table.plannedFreeformText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actualRepType => $composableBuilder(
    column: $table.actualRepType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualTargetReps => $composableBuilder(
    column: $table.actualTargetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualMinReps => $composableBuilder(
    column: $table.actualMinReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualMaxReps => $composableBuilder(
    column: $table.actualMaxReps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actualLoadType => $composableBuilder(
    column: $table.actualLoadType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualWeightCanonicalMg => $composableBuilder(
    column: $table.actualWeightCanonicalMg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualPercentage => $composableBuilder(
    column: $table.actualPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualTargetRpe => $composableBuilder(
    column: $table.actualTargetRpe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actualFreeformText => $composableBuilder(
    column: $table.actualFreeformText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedRestSeconds => $composableBuilder(
    column: $table.plannedRestSeconds,
    builder: (column) => column,
  );

  $SessionExerciseAnnotationComposer get sessionExerciseId {
    final $SessionExerciseAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionExerciseId,
      referencedTable: $db.sessionExercise,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionExerciseAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercise,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionSetTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SessionSet,
          SessionSetData,
          $SessionSetFilterComposer,
          $SessionSetOrderingComposer,
          $SessionSetAnnotationComposer,
          $SessionSetCreateCompanionBuilder,
          $SessionSetUpdateCompanionBuilder,
          (SessionSetData, $SessionSetReferences),
          SessionSetData,
          PrefetchHooks Function({bool sessionExerciseId})
        > {
  $SessionSetTableManager(_$AppDatabase db, SessionSet table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SessionSetFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SessionSetOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SessionSetAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionExerciseId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<String> plannedRepType = const Value.absent(),
                Value<int?> plannedTargetReps = const Value.absent(),
                Value<int?> plannedMinReps = const Value.absent(),
                Value<int?> plannedMaxReps = const Value.absent(),
                Value<String> plannedLoadType = const Value.absent(),
                Value<int?> plannedWeightCanonicalMg = const Value.absent(),
                Value<int?> plannedPercentage = const Value.absent(),
                Value<double?> plannedTargetRpe = const Value.absent(),
                Value<String?> plannedFreeformText = const Value.absent(),
                Value<String?> actualRepType = const Value.absent(),
                Value<int?> actualTargetReps = const Value.absent(),
                Value<int?> actualMinReps = const Value.absent(),
                Value<int?> actualMaxReps = const Value.absent(),
                Value<String?> actualLoadType = const Value.absent(),
                Value<int?> actualWeightCanonicalMg = const Value.absent(),
                Value<int?> actualPercentage = const Value.absent(),
                Value<double?> actualTargetRpe = const Value.absent(),
                Value<String?> actualFreeformText = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> plannedRestSeconds = const Value.absent(),
              }) => SessionSetCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                setIndex: setIndex,
                plannedRepType: plannedRepType,
                plannedTargetReps: plannedTargetReps,
                plannedMinReps: plannedMinReps,
                plannedMaxReps: plannedMaxReps,
                plannedLoadType: plannedLoadType,
                plannedWeightCanonicalMg: plannedWeightCanonicalMg,
                plannedPercentage: plannedPercentage,
                plannedTargetRpe: plannedTargetRpe,
                plannedFreeformText: plannedFreeformText,
                actualRepType: actualRepType,
                actualTargetReps: actualTargetReps,
                actualMinReps: actualMinReps,
                actualMaxReps: actualMaxReps,
                actualLoadType: actualLoadType,
                actualWeightCanonicalMg: actualWeightCanonicalMg,
                actualPercentage: actualPercentage,
                actualTargetRpe: actualTargetRpe,
                actualFreeformText: actualFreeformText,
                rpe: rpe,
                completed: completed,
                completedAt: completedAt,
                plannedRestSeconds: plannedRestSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionExerciseId,
                required int setIndex,
                required String plannedRepType,
                Value<int?> plannedTargetReps = const Value.absent(),
                Value<int?> plannedMinReps = const Value.absent(),
                Value<int?> plannedMaxReps = const Value.absent(),
                required String plannedLoadType,
                Value<int?> plannedWeightCanonicalMg = const Value.absent(),
                Value<int?> plannedPercentage = const Value.absent(),
                Value<double?> plannedTargetRpe = const Value.absent(),
                Value<String?> plannedFreeformText = const Value.absent(),
                Value<String?> actualRepType = const Value.absent(),
                Value<int?> actualTargetReps = const Value.absent(),
                Value<int?> actualMinReps = const Value.absent(),
                Value<int?> actualMaxReps = const Value.absent(),
                Value<String?> actualLoadType = const Value.absent(),
                Value<int?> actualWeightCanonicalMg = const Value.absent(),
                Value<int?> actualPercentage = const Value.absent(),
                Value<double?> actualTargetRpe = const Value.absent(),
                Value<String?> actualFreeformText = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                required bool completed,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> plannedRestSeconds = const Value.absent(),
              }) => SessionSetCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                setIndex: setIndex,
                plannedRepType: plannedRepType,
                plannedTargetReps: plannedTargetReps,
                plannedMinReps: plannedMinReps,
                plannedMaxReps: plannedMaxReps,
                plannedLoadType: plannedLoadType,
                plannedWeightCanonicalMg: plannedWeightCanonicalMg,
                plannedPercentage: plannedPercentage,
                plannedTargetRpe: plannedTargetRpe,
                plannedFreeformText: plannedFreeformText,
                actualRepType: actualRepType,
                actualTargetReps: actualTargetReps,
                actualMinReps: actualMinReps,
                actualMaxReps: actualMaxReps,
                actualLoadType: actualLoadType,
                actualWeightCanonicalMg: actualWeightCanonicalMg,
                actualPercentage: actualPercentage,
                actualTargetRpe: actualTargetRpe,
                actualFreeformText: actualFreeformText,
                rpe: rpe,
                completed: completed,
                completedAt: completedAt,
                plannedRestSeconds: plannedRestSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SessionSet, SessionSetData>(table),
                  $SessionSetReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionExerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionExerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionExerciseId,
                        referencedTable: $SessionSetReferences
                            ._sessionExerciseIdTable(db),
                        referencedColumn: $SessionSetReferences
                            ._sessionExerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $SessionSetProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SessionSet,
      SessionSetData,
      $SessionSetFilterComposer,
      $SessionSetOrderingComposer,
      $SessionSetAnnotationComposer,
      $SessionSetCreateCompanionBuilder,
      $SessionSetUpdateCompanionBuilder,
      (SessionSetData, $SessionSetReferences),
      SessionSetData,
      PrefetchHooks Function({bool sessionExerciseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $AppMetadataTableManager get appMetadata =>
      $AppMetadataTableManager(_db, _db.appMetadata);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
  $WorkoutTableManager get workout => $WorkoutTableManager(_db, _db.workout);
  $WorkoutExerciseTableManager get workoutExercise =>
      $WorkoutExerciseTableManager(_db, _db.workoutExercise);
  $WorkoutSetTableManager get workoutSet =>
      $WorkoutSetTableManager(_db, _db.workoutSet);
  $SessionTableManager get session => $SessionTableManager(_db, _db.session);
  $ScheduleEntryTableManager get scheduleEntry =>
      $ScheduleEntryTableManager(_db, _db.scheduleEntry);
  $SessionExerciseTableManager get sessionExercise =>
      $SessionExerciseTableManager(_db, _db.sessionExercise);
  $SessionSetTableManager get sessionSet =>
      $SessionSetTableManager(_db, _db.sessionSet);
}
