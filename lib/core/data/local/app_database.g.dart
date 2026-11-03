// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalRecordsTable extends LocalRecords
    with TableInfo<$LocalRecordsTable, LocalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtClientMeta = const VerificationMeta(
    'createdAtClient',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtClient =
      GeneratedColumn<DateTime>(
        'created_at_client',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtClientMeta = const VerificationMeta(
    'updatedAtClient',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtClient =
      GeneratedColumn<DateTime>(
        'updated_at_client',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtServerMeta = const VerificationMeta(
    'updatedAtServer',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtServer =
      GeneratedColumn<DateTime>(
        'updated_at_server',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    entityType,
    entityKey,
    schemaVersion,
    revision,
    payloadJson,
    isDeleted,
    createdAtClient,
    updatedAtClient,
    updatedAtServer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at_client')) {
      context.handle(
        _createdAtClientMeta,
        createdAtClient.isAcceptableOrUnknown(
          data['created_at_client']!,
          _createdAtClientMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtClientMeta);
    }
    if (data.containsKey('updated_at_client')) {
      context.handle(
        _updatedAtClientMeta,
        updatedAtClient.isAcceptableOrUnknown(
          data['updated_at_client']!,
          _updatedAtClientMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtClientMeta);
    }
    if (data.containsKey('updated_at_server')) {
      context.handle(
        _updatedAtServerMeta,
        updatedAtServer.isAcceptableOrUnknown(
          data['updated_at_server']!,
          _updatedAtServerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, entityType, entityKey};
  @override
  LocalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecord(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAtClient: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_client'],
      )!,
      updatedAtClient: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_client'],
      )!,
      updatedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_server'],
      ),
    );
  }

  @override
  $LocalRecordsTable createAlias(String alias) {
    return $LocalRecordsTable(attachedDatabase, alias);
  }
}

class LocalRecord extends DataClass implements Insertable<LocalRecord> {
  final String ownerId;
  final String entityType;
  final String entityKey;
  final int schemaVersion;
  final int revision;
  final String payloadJson;
  final bool isDeleted;
  final DateTime createdAtClient;
  final DateTime updatedAtClient;
  final DateTime? updatedAtServer;
  const LocalRecord({
    required this.ownerId,
    required this.entityType,
    required this.entityKey,
    required this.schemaVersion,
    required this.revision,
    required this.payloadJson,
    required this.isDeleted,
    required this.createdAtClient,
    required this.updatedAtClient,
    this.updatedAtServer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_key'] = Variable<String>(entityKey);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['revision'] = Variable<int>(revision);
    map['payload_json'] = Variable<String>(payloadJson);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at_client'] = Variable<DateTime>(createdAtClient);
    map['updated_at_client'] = Variable<DateTime>(updatedAtClient);
    if (!nullToAbsent || updatedAtServer != null) {
      map['updated_at_server'] = Variable<DateTime>(updatedAtServer);
    }
    return map;
  }

  LocalRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalRecordsCompanion(
      ownerId: Value(ownerId),
      entityType: Value(entityType),
      entityKey: Value(entityKey),
      schemaVersion: Value(schemaVersion),
      revision: Value(revision),
      payloadJson: Value(payloadJson),
      isDeleted: Value(isDeleted),
      createdAtClient: Value(createdAtClient),
      updatedAtClient: Value(updatedAtClient),
      updatedAtServer: updatedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAtServer),
    );
  }

  factory LocalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecord(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityKey: serializer.fromJson<String>(json['entityKey']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      revision: serializer.fromJson<int>(json['revision']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAtClient: serializer.fromJson<DateTime>(json['createdAtClient']),
      updatedAtClient: serializer.fromJson<DateTime>(json['updatedAtClient']),
      updatedAtServer: serializer.fromJson<DateTime?>(json['updatedAtServer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityKey': serializer.toJson<String>(entityKey),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'revision': serializer.toJson<int>(revision),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAtClient': serializer.toJson<DateTime>(createdAtClient),
      'updatedAtClient': serializer.toJson<DateTime>(updatedAtClient),
      'updatedAtServer': serializer.toJson<DateTime?>(updatedAtServer),
    };
  }

  LocalRecord copyWith({
    String? ownerId,
    String? entityType,
    String? entityKey,
    int? schemaVersion,
    int? revision,
    String? payloadJson,
    bool? isDeleted,
    DateTime? createdAtClient,
    DateTime? updatedAtClient,
    Value<DateTime?> updatedAtServer = const Value.absent(),
  }) => LocalRecord(
    ownerId: ownerId ?? this.ownerId,
    entityType: entityType ?? this.entityType,
    entityKey: entityKey ?? this.entityKey,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    revision: revision ?? this.revision,
    payloadJson: payloadJson ?? this.payloadJson,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAtClient: createdAtClient ?? this.createdAtClient,
    updatedAtClient: updatedAtClient ?? this.updatedAtClient,
    updatedAtServer: updatedAtServer.present
        ? updatedAtServer.value
        : this.updatedAtServer,
  );
  LocalRecord copyWithCompanion(LocalRecordsCompanion data) {
    return LocalRecord(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      revision: data.revision.present ? data.revision.value : this.revision,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAtClient: data.createdAtClient.present
          ? data.createdAtClient.value
          : this.createdAtClient,
      updatedAtClient: data.updatedAtClient.present
          ? data.updatedAtClient.value
          : this.updatedAtClient,
      updatedAtServer: data.updatedAtServer.present
          ? data.updatedAtServer.value
          : this.updatedAtServer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecord(')
          ..write('ownerId: $ownerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityKey: $entityKey, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('revision: $revision, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAtClient: $createdAtClient, ')
          ..write('updatedAtClient: $updatedAtClient, ')
          ..write('updatedAtServer: $updatedAtServer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    entityType,
    entityKey,
    schemaVersion,
    revision,
    payloadJson,
    isDeleted,
    createdAtClient,
    updatedAtClient,
    updatedAtServer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecord &&
          other.ownerId == this.ownerId &&
          other.entityType == this.entityType &&
          other.entityKey == this.entityKey &&
          other.schemaVersion == this.schemaVersion &&
          other.revision == this.revision &&
          other.payloadJson == this.payloadJson &&
          other.isDeleted == this.isDeleted &&
          other.createdAtClient == this.createdAtClient &&
          other.updatedAtClient == this.updatedAtClient &&
          other.updatedAtServer == this.updatedAtServer);
}

class LocalRecordsCompanion extends UpdateCompanion<LocalRecord> {
  final Value<String> ownerId;
  final Value<String> entityType;
  final Value<String> entityKey;
  final Value<int> schemaVersion;
  final Value<int> revision;
  final Value<String> payloadJson;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAtClient;
  final Value<DateTime> updatedAtClient;
  final Value<DateTime?> updatedAtServer;
  final Value<int> rowid;
  const LocalRecordsCompanion({
    this.ownerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityKey = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.revision = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAtClient = const Value.absent(),
    this.updatedAtClient = const Value.absent(),
    this.updatedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecordsCompanion.insert({
    required String ownerId,
    required String entityType,
    required String entityKey,
    required int schemaVersion,
    required int revision,
    required String payloadJson,
    this.isDeleted = const Value.absent(),
    required DateTime createdAtClient,
    required DateTime updatedAtClient,
    this.updatedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       entityType = Value(entityType),
       entityKey = Value(entityKey),
       schemaVersion = Value(schemaVersion),
       revision = Value(revision),
       payloadJson = Value(payloadJson),
       createdAtClient = Value(createdAtClient),
       updatedAtClient = Value(updatedAtClient);
  static Insertable<LocalRecord> custom({
    Expression<String>? ownerId,
    Expression<String>? entityType,
    Expression<String>? entityKey,
    Expression<int>? schemaVersion,
    Expression<int>? revision,
    Expression<String>? payloadJson,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAtClient,
    Expression<DateTime>? updatedAtClient,
    Expression<DateTime>? updatedAtServer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityKey != null) 'entity_key': entityKey,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (revision != null) 'revision': revision,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAtClient != null) 'created_at_client': createdAtClient,
      if (updatedAtClient != null) 'updated_at_client': updatedAtClient,
      if (updatedAtServer != null) 'updated_at_server': updatedAtServer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecordsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? entityType,
    Value<String>? entityKey,
    Value<int>? schemaVersion,
    Value<int>? revision,
    Value<String>? payloadJson,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAtClient,
    Value<DateTime>? updatedAtClient,
    Value<DateTime?>? updatedAtServer,
    Value<int>? rowid,
  }) {
    return LocalRecordsCompanion(
      ownerId: ownerId ?? this.ownerId,
      entityType: entityType ?? this.entityType,
      entityKey: entityKey ?? this.entityKey,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      revision: revision ?? this.revision,
      payloadJson: payloadJson ?? this.payloadJson,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAtClient: createdAtClient ?? this.createdAtClient,
      updatedAtClient: updatedAtClient ?? this.updatedAtClient,
      updatedAtServer: updatedAtServer ?? this.updatedAtServer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAtClient.present) {
      map['created_at_client'] = Variable<DateTime>(createdAtClient.value);
    }
    if (updatedAtClient.present) {
      map['updated_at_client'] = Variable<DateTime>(updatedAtClient.value);
    }
    if (updatedAtServer.present) {
      map['updated_at_server'] = Variable<DateTime>(updatedAtServer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecordsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityKey: $entityKey, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('revision: $revision, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAtClient: $createdAtClient, ')
          ..write('updatedAtClient: $updatedAtClient, ')
          ..write('updatedAtServer: $updatedAtServer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEntriesTable extends SyncOutboxEntries
    with TableInfo<$SyncOutboxEntriesTable, SyncOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<String> entityKey = GeneratedColumn<String>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newRevisionMeta = const VerificationMeta(
    'newRevision',
  );
  @override
  late final GeneratedColumn<int> newRevision = GeneratedColumn<int>(
    'new_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtClientMeta = const VerificationMeta(
    'createdAtClient',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtClient =
      GeneratedColumn<DateTime>(
        'created_at_client',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
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
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    operationId,
    entityType,
    entityKey,
    operationType,
    baseRevision,
    newRevision,
    payloadJson,
    createdAtClient,
    attemptCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseRevisionMeta);
    }
    if (data.containsKey('new_revision')) {
      context.handle(
        _newRevisionMeta,
        newRevision.isAcceptableOrUnknown(
          data['new_revision']!,
          _newRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newRevisionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at_client')) {
      context.handle(
        _createdAtClientMeta,
        createdAtClient.isAcceptableOrUnknown(
          data['created_at_client']!,
          _createdAtClientMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtClientMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, operationId};
  @override
  SyncOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEntry(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_key'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      )!,
      newRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_revision'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAtClient: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_client'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncOutboxEntriesTable createAlias(String alias) {
    return $SyncOutboxEntriesTable(attachedDatabase, alias);
  }
}

class SyncOutboxEntry extends DataClass implements Insertable<SyncOutboxEntry> {
  final String ownerId;
  final String operationId;
  final String entityType;
  final String entityKey;
  final String operationType;
  final int baseRevision;
  final int newRevision;
  final String payloadJson;
  final DateTime createdAtClient;
  final int attemptCount;
  final String? lastError;
  const SyncOutboxEntry({
    required this.ownerId,
    required this.operationId,
    required this.entityType,
    required this.entityKey,
    required this.operationType,
    required this.baseRevision,
    required this.newRevision,
    required this.payloadJson,
    required this.createdAtClient,
    required this.attemptCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['operation_id'] = Variable<String>(operationId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_key'] = Variable<String>(entityKey);
    map['operation_type'] = Variable<String>(operationType);
    map['base_revision'] = Variable<int>(baseRevision);
    map['new_revision'] = Variable<int>(newRevision);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at_client'] = Variable<DateTime>(createdAtClient);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncOutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEntriesCompanion(
      ownerId: Value(ownerId),
      operationId: Value(operationId),
      entityType: Value(entityType),
      entityKey: Value(entityKey),
      operationType: Value(operationType),
      baseRevision: Value(baseRevision),
      newRevision: Value(newRevision),
      payloadJson: Value(payloadJson),
      createdAtClient: Value(createdAtClient),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEntry(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      operationId: serializer.fromJson<String>(json['operationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityKey: serializer.fromJson<String>(json['entityKey']),
      operationType: serializer.fromJson<String>(json['operationType']),
      baseRevision: serializer.fromJson<int>(json['baseRevision']),
      newRevision: serializer.fromJson<int>(json['newRevision']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAtClient: serializer.fromJson<DateTime>(json['createdAtClient']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'operationId': serializer.toJson<String>(operationId),
      'entityType': serializer.toJson<String>(entityType),
      'entityKey': serializer.toJson<String>(entityKey),
      'operationType': serializer.toJson<String>(operationType),
      'baseRevision': serializer.toJson<int>(baseRevision),
      'newRevision': serializer.toJson<int>(newRevision),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAtClient': serializer.toJson<DateTime>(createdAtClient),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncOutboxEntry copyWith({
    String? ownerId,
    String? operationId,
    String? entityType,
    String? entityKey,
    String? operationType,
    int? baseRevision,
    int? newRevision,
    String? payloadJson,
    DateTime? createdAtClient,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncOutboxEntry(
    ownerId: ownerId ?? this.ownerId,
    operationId: operationId ?? this.operationId,
    entityType: entityType ?? this.entityType,
    entityKey: entityKey ?? this.entityKey,
    operationType: operationType ?? this.operationType,
    baseRevision: baseRevision ?? this.baseRevision,
    newRevision: newRevision ?? this.newRevision,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAtClient: createdAtClient ?? this.createdAtClient,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncOutboxEntry copyWithCompanion(SyncOutboxEntriesCompanion data) {
    return SyncOutboxEntry(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      newRevision: data.newRevision.present
          ? data.newRevision.value
          : this.newRevision,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAtClient: data.createdAtClient.present
          ? data.createdAtClient.value
          : this.createdAtClient,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntry(')
          ..write('ownerId: $ownerId, ')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityKey: $entityKey, ')
          ..write('operationType: $operationType, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('newRevision: $newRevision, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAtClient: $createdAtClient, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    operationId,
    entityType,
    entityKey,
    operationType,
    baseRevision,
    newRevision,
    payloadJson,
    createdAtClient,
    attemptCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEntry &&
          other.ownerId == this.ownerId &&
          other.operationId == this.operationId &&
          other.entityType == this.entityType &&
          other.entityKey == this.entityKey &&
          other.operationType == this.operationType &&
          other.baseRevision == this.baseRevision &&
          other.newRevision == this.newRevision &&
          other.payloadJson == this.payloadJson &&
          other.createdAtClient == this.createdAtClient &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError);
}

class SyncOutboxEntriesCompanion extends UpdateCompanion<SyncOutboxEntry> {
  final Value<String> ownerId;
  final Value<String> operationId;
  final Value<String> entityType;
  final Value<String> entityKey;
  final Value<String> operationType;
  final Value<int> baseRevision;
  final Value<int> newRevision;
  final Value<String> payloadJson;
  final Value<DateTime> createdAtClient;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncOutboxEntriesCompanion({
    this.ownerId = const Value.absent(),
    this.operationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityKey = const Value.absent(),
    this.operationType = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.newRevision = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAtClient = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxEntriesCompanion.insert({
    required String ownerId,
    required String operationId,
    required String entityType,
    required String entityKey,
    required String operationType,
    required int baseRevision,
    required int newRevision,
    required String payloadJson,
    required DateTime createdAtClient,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       operationId = Value(operationId),
       entityType = Value(entityType),
       entityKey = Value(entityKey),
       operationType = Value(operationType),
       baseRevision = Value(baseRevision),
       newRevision = Value(newRevision),
       payloadJson = Value(payloadJson),
       createdAtClient = Value(createdAtClient);
  static Insertable<SyncOutboxEntry> custom({
    Expression<String>? ownerId,
    Expression<String>? operationId,
    Expression<String>? entityType,
    Expression<String>? entityKey,
    Expression<String>? operationType,
    Expression<int>? baseRevision,
    Expression<int>? newRevision,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAtClient,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (operationId != null) 'operation_id': operationId,
      if (entityType != null) 'entity_type': entityType,
      if (entityKey != null) 'entity_key': entityKey,
      if (operationType != null) 'operation_type': operationType,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (newRevision != null) 'new_revision': newRevision,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAtClient != null) 'created_at_client': createdAtClient,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxEntriesCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? operationId,
    Value<String>? entityType,
    Value<String>? entityKey,
    Value<String>? operationType,
    Value<int>? baseRevision,
    Value<int>? newRevision,
    Value<String>? payloadJson,
    Value<DateTime>? createdAtClient,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncOutboxEntriesCompanion(
      ownerId: ownerId ?? this.ownerId,
      operationId: operationId ?? this.operationId,
      entityType: entityType ?? this.entityType,
      entityKey: entityKey ?? this.entityKey,
      operationType: operationType ?? this.operationType,
      baseRevision: baseRevision ?? this.baseRevision,
      newRevision: newRevision ?? this.newRevision,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAtClient: createdAtClient ?? this.createdAtClient,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityKey.present) {
      map['entity_key'] = Variable<String>(entityKey.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (newRevision.present) {
      map['new_revision'] = Variable<int>(newRevision.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAtClient.present) {
      map['created_at_client'] = Variable<DateTime>(createdAtClient.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntriesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityKey: $entityKey, ')
          ..write('operationType: $operationType, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('newRevision: $newRevision, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAtClient: $createdAtClient, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtClientMeta = const VerificationMeta(
    'updatedAtClient',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtClient =
      GeneratedColumn<DateTime>(
        'updated_at_client',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [ownerId, cursor, updatedAtClient];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('updated_at_client')) {
      context.handle(
        _updatedAtClientMeta,
        updatedAtClient.isAcceptableOrUnknown(
          data['updated_at_client']!,
          _updatedAtClientMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtClientMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      updatedAtClient: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_client'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String ownerId;
  final String cursor;
  final DateTime updatedAtClient;
  const SyncCursor({
    required this.ownerId,
    required this.cursor,
    required this.updatedAtClient,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['cursor'] = Variable<String>(cursor);
    map['updated_at_client'] = Variable<DateTime>(updatedAtClient);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      ownerId: Value(ownerId),
      cursor: Value(cursor),
      updatedAtClient: Value(updatedAtClient),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      cursor: serializer.fromJson<String>(json['cursor']),
      updatedAtClient: serializer.fromJson<DateTime>(json['updatedAtClient']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'cursor': serializer.toJson<String>(cursor),
      'updatedAtClient': serializer.toJson<DateTime>(updatedAtClient),
    };
  }

  SyncCursor copyWith({
    String? ownerId,
    String? cursor,
    DateTime? updatedAtClient,
  }) => SyncCursor(
    ownerId: ownerId ?? this.ownerId,
    cursor: cursor ?? this.cursor,
    updatedAtClient: updatedAtClient ?? this.updatedAtClient,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      updatedAtClient: data.updatedAtClient.present
          ? data.updatedAtClient.value
          : this.updatedAtClient,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('ownerId: $ownerId, ')
          ..write('cursor: $cursor, ')
          ..write('updatedAtClient: $updatedAtClient')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerId, cursor, updatedAtClient);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.ownerId == this.ownerId &&
          other.cursor == this.cursor &&
          other.updatedAtClient == this.updatedAtClient);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> ownerId;
  final Value<String> cursor;
  final Value<DateTime> updatedAtClient;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.ownerId = const Value.absent(),
    this.cursor = const Value.absent(),
    this.updatedAtClient = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String ownerId,
    required String cursor,
    required DateTime updatedAtClient,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       cursor = Value(cursor),
       updatedAtClient = Value(updatedAtClient);
  static Insertable<SyncCursor> custom({
    Expression<String>? ownerId,
    Expression<String>? cursor,
    Expression<DateTime>? updatedAtClient,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (cursor != null) 'cursor': cursor,
      if (updatedAtClient != null) 'updated_at_client': updatedAtClient,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? cursor,
    Value<DateTime>? updatedAtClient,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      ownerId: ownerId ?? this.ownerId,
      cursor: cursor ?? this.cursor,
      updatedAtClient: updatedAtClient ?? this.updatedAtClient,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (updatedAtClient.present) {
      map['updated_at_client'] = Variable<DateTime>(updatedAtClient.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('cursor: $cursor, ')
          ..write('updatedAtClient: $updatedAtClient, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogReleasesTable extends CatalogReleases
    with TableInfo<$CatalogReleasesTable, CatalogRelease> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogReleasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentChecksumMeta = const VerificationMeta(
    'contentChecksum',
  );
  @override
  late final GeneratedColumn<String> contentChecksum = GeneratedColumn<String>(
    'content_checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    version,
    reviewStatus,
    contentChecksum,
    publishedAt,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_releases';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogRelease> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('content_checksum')) {
      context.handle(
        _contentChecksumMeta,
        contentChecksum.isAcceptableOrUnknown(
          data['content_checksum']!,
          _contentChecksumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentChecksumMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {releaseId};
  @override
  CatalogRelease map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRelease(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      contentChecksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_checksum'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $CatalogReleasesTable createAlias(String alias) {
    return $CatalogReleasesTable(attachedDatabase, alias);
  }
}

class CatalogRelease extends DataClass implements Insertable<CatalogRelease> {
  final String releaseId;
  final String version;
  final String reviewStatus;
  final String contentChecksum;
  final DateTime? publishedAt;
  final DateTime importedAt;
  const CatalogRelease({
    required this.releaseId,
    required this.version,
    required this.reviewStatus,
    required this.contentChecksum,
    this.publishedAt,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['version'] = Variable<String>(version);
    map['review_status'] = Variable<String>(reviewStatus);
    map['content_checksum'] = Variable<String>(contentChecksum);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  CatalogReleasesCompanion toCompanion(bool nullToAbsent) {
    return CatalogReleasesCompanion(
      releaseId: Value(releaseId),
      version: Value(version),
      reviewStatus: Value(reviewStatus),
      contentChecksum: Value(contentChecksum),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      importedAt: Value(importedAt),
    );
  }

  factory CatalogRelease.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRelease(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      version: serializer.fromJson<String>(json['version']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      contentChecksum: serializer.fromJson<String>(json['contentChecksum']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'version': serializer.toJson<String>(version),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'contentChecksum': serializer.toJson<String>(contentChecksum),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  CatalogRelease copyWith({
    String? releaseId,
    String? version,
    String? reviewStatus,
    String? contentChecksum,
    Value<DateTime?> publishedAt = const Value.absent(),
    DateTime? importedAt,
  }) => CatalogRelease(
    releaseId: releaseId ?? this.releaseId,
    version: version ?? this.version,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    contentChecksum: contentChecksum ?? this.contentChecksum,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    importedAt: importedAt ?? this.importedAt,
  );
  CatalogRelease copyWithCompanion(CatalogReleasesCompanion data) {
    return CatalogRelease(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      version: data.version.present ? data.version.value : this.version,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      contentChecksum: data.contentChecksum.present
          ? data.contentChecksum.value
          : this.contentChecksum,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRelease(')
          ..write('releaseId: $releaseId, ')
          ..write('version: $version, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('contentChecksum: $contentChecksum, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    releaseId,
    version,
    reviewStatus,
    contentChecksum,
    publishedAt,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRelease &&
          other.releaseId == this.releaseId &&
          other.version == this.version &&
          other.reviewStatus == this.reviewStatus &&
          other.contentChecksum == this.contentChecksum &&
          other.publishedAt == this.publishedAt &&
          other.importedAt == this.importedAt);
}

class CatalogReleasesCompanion extends UpdateCompanion<CatalogRelease> {
  final Value<String> releaseId;
  final Value<String> version;
  final Value<String> reviewStatus;
  final Value<String> contentChecksum;
  final Value<DateTime?> publishedAt;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const CatalogReleasesCompanion({
    this.releaseId = const Value.absent(),
    this.version = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.contentChecksum = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogReleasesCompanion.insert({
    required String releaseId,
    required String version,
    required String reviewStatus,
    required String contentChecksum,
    this.publishedAt = const Value.absent(),
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       version = Value(version),
       reviewStatus = Value(reviewStatus),
       contentChecksum = Value(contentChecksum),
       importedAt = Value(importedAt);
  static Insertable<CatalogRelease> custom({
    Expression<String>? releaseId,
    Expression<String>? version,
    Expression<String>? reviewStatus,
    Expression<String>? contentChecksum,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (version != null) 'version': version,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (contentChecksum != null) 'content_checksum': contentChecksum,
      if (publishedAt != null) 'published_at': publishedAt,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogReleasesCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? version,
    Value<String>? reviewStatus,
    Value<String>? contentChecksum,
    Value<DateTime?>? publishedAt,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return CatalogReleasesCompanion(
      releaseId: releaseId ?? this.releaseId,
      version: version ?? this.version,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      contentChecksum: contentChecksum ?? this.contentChecksum,
      publishedAt: publishedAt ?? this.publishedAt,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (contentChecksum.present) {
      map['content_checksum'] = Variable<String>(contentChecksum.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogReleasesCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('version: $version, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('contentChecksum: $contentChecksum, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionSourcesTable extends NutritionSources
    with TableInfo<$NutritionSourcesTable, NutritionSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
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
  static const VerificationMeta _sourceVersionMeta = const VerificationMeta(
    'sourceVersion',
  );
  @override
  late final GeneratedColumn<String> sourceVersion = GeneratedColumn<String>(
    'source_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationMeta = const VerificationMeta(
    'citation',
  );
  @override
  late final GeneratedColumn<String> citation = GeneratedColumn<String>(
    'citation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseIdMeta = const VerificationMeta(
    'licenseId',
  );
  @override
  late final GeneratedColumn<String> licenseId = GeneratedColumn<String>(
    'license_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceKey,
    sourceId,
    sourceVersion,
    citation,
    licenseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_version')) {
      context.handle(
        _sourceVersionMeta,
        sourceVersion.isAcceptableOrUnknown(
          data['source_version']!,
          _sourceVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceVersionMeta);
    }
    if (data.containsKey('citation')) {
      context.handle(
        _citationMeta,
        citation.isAcceptableOrUnknown(data['citation']!, _citationMeta),
      );
    } else if (isInserting) {
      context.missing(_citationMeta);
    }
    if (data.containsKey('license_id')) {
      context.handle(
        _licenseIdMeta,
        licenseId.isAcceptableOrUnknown(data['license_id']!, _licenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_licenseIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceKey};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceId, sourceVersion},
  ];
  @override
  NutritionSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionSource(
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_version'],
      )!,
      citation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citation'],
      )!,
      licenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_id'],
      )!,
    );
  }

  @override
  $NutritionSourcesTable createAlias(String alias) {
    return $NutritionSourcesTable(attachedDatabase, alias);
  }
}

class NutritionSource extends DataClass implements Insertable<NutritionSource> {
  final String sourceKey;
  final String sourceId;
  final String sourceVersion;
  final String citation;
  final String licenseId;
  const NutritionSource({
    required this.sourceKey,
    required this.sourceId,
    required this.sourceVersion,
    required this.citation,
    required this.licenseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_key'] = Variable<String>(sourceKey);
    map['source_id'] = Variable<String>(sourceId);
    map['source_version'] = Variable<String>(sourceVersion);
    map['citation'] = Variable<String>(citation);
    map['license_id'] = Variable<String>(licenseId);
    return map;
  }

  NutritionSourcesCompanion toCompanion(bool nullToAbsent) {
    return NutritionSourcesCompanion(
      sourceKey: Value(sourceKey),
      sourceId: Value(sourceId),
      sourceVersion: Value(sourceVersion),
      citation: Value(citation),
      licenseId: Value(licenseId),
    );
  }

  factory NutritionSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionSource(
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceVersion: serializer.fromJson<String>(json['sourceVersion']),
      citation: serializer.fromJson<String>(json['citation']),
      licenseId: serializer.fromJson<String>(json['licenseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceKey': serializer.toJson<String>(sourceKey),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceVersion': serializer.toJson<String>(sourceVersion),
      'citation': serializer.toJson<String>(citation),
      'licenseId': serializer.toJson<String>(licenseId),
    };
  }

  NutritionSource copyWith({
    String? sourceKey,
    String? sourceId,
    String? sourceVersion,
    String? citation,
    String? licenseId,
  }) => NutritionSource(
    sourceKey: sourceKey ?? this.sourceKey,
    sourceId: sourceId ?? this.sourceId,
    sourceVersion: sourceVersion ?? this.sourceVersion,
    citation: citation ?? this.citation,
    licenseId: licenseId ?? this.licenseId,
  );
  NutritionSource copyWithCompanion(NutritionSourcesCompanion data) {
    return NutritionSource(
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      citation: data.citation.present ? data.citation.value : this.citation,
      licenseId: data.licenseId.present ? data.licenseId.value : this.licenseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionSource(')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('citation: $citation, ')
          ..write('licenseId: $licenseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceKey, sourceId, sourceVersion, citation, licenseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionSource &&
          other.sourceKey == this.sourceKey &&
          other.sourceId == this.sourceId &&
          other.sourceVersion == this.sourceVersion &&
          other.citation == this.citation &&
          other.licenseId == this.licenseId);
}

class NutritionSourcesCompanion extends UpdateCompanion<NutritionSource> {
  final Value<String> sourceKey;
  final Value<String> sourceId;
  final Value<String> sourceVersion;
  final Value<String> citation;
  final Value<String> licenseId;
  final Value<int> rowid;
  const NutritionSourcesCompanion({
    this.sourceKey = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.citation = const Value.absent(),
    this.licenseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionSourcesCompanion.insert({
    required String sourceKey,
    required String sourceId,
    required String sourceVersion,
    required String citation,
    required String licenseId,
    this.rowid = const Value.absent(),
  }) : sourceKey = Value(sourceKey),
       sourceId = Value(sourceId),
       sourceVersion = Value(sourceVersion),
       citation = Value(citation),
       licenseId = Value(licenseId);
  static Insertable<NutritionSource> custom({
    Expression<String>? sourceKey,
    Expression<String>? sourceId,
    Expression<String>? sourceVersion,
    Expression<String>? citation,
    Expression<String>? licenseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceKey != null) 'source_key': sourceKey,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (citation != null) 'citation': citation,
      if (licenseId != null) 'license_id': licenseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionSourcesCompanion copyWith({
    Value<String>? sourceKey,
    Value<String>? sourceId,
    Value<String>? sourceVersion,
    Value<String>? citation,
    Value<String>? licenseId,
    Value<int>? rowid,
  }) {
    return NutritionSourcesCompanion(
      sourceKey: sourceKey ?? this.sourceKey,
      sourceId: sourceId ?? this.sourceId,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      citation: citation ?? this.citation,
      licenseId: licenseId ?? this.licenseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<String>(sourceVersion.value);
    }
    if (citation.present) {
      map['citation'] = Variable<String>(citation.value);
    }
    if (licenseId.present) {
      map['license_id'] = Variable<String>(licenseId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionSourcesCompanion(')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('citation: $citation, ')
          ..write('licenseId: $licenseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogFoodsTable extends CatalogFoods
    with TableInfo<$CatalogFoodsTable, CatalogFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_releases (release_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnglishMeta = const VerificationMeta(
    'nameEnglish',
  );
  @override
  late final GeneratedColumn<String> nameEnglish = GeneratedColumn<String>(
    'name_english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameRomanUrduMeta = const VerificationMeta(
    'nameRomanUrdu',
  );
  @override
  late final GeneratedColumn<String> nameRomanUrdu = GeneratedColumn<String>(
    'name_roman_urdu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameEnglishMeta =
      const VerificationMeta('normalizedNameEnglish');
  @override
  late final GeneratedColumn<String> normalizedNameEnglish =
      GeneratedColumn<String>(
        'normalized_name_english',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _normalizedNameRomanUrduMeta =
      const VerificationMeta('normalizedNameRomanUrdu');
  @override
  late final GeneratedColumn<String> normalizedNameRomanUrdu =
      GeneratedColumn<String>(
        'normalized_name_roman_urdu',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preparationMeta = const VerificationMeta(
    'preparation',
  );
  @override
  late final GeneratedColumn<String> preparation = GeneratedColumn<String>(
    'preparation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceGramsMeta = const VerificationMeta(
    'referenceGrams',
  );
  @override
  late final GeneratedColumn<double> referenceGrams = GeneratedColumn<double>(
    'reference_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<double> caloriesKcal = GeneratedColumn<double>(
    'calories_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbohydrateGramsMeta = const VerificationMeta(
    'carbohydrateGrams',
  );
  @override
  late final GeneratedColumn<double> carbohydrateGrams =
      GeneratedColumn<double>(
        'carbohydrate_grams',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMilligramsMeta = const VerificationMeta(
    'sodiumMilligrams',
  );
  @override
  late final GeneratedColumn<double> sodiumMilligrams = GeneratedColumn<double>(
    'sodium_milligrams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilInclusionMeta = const VerificationMeta(
    'oilInclusion',
  );
  @override
  late final GeneratedColumn<String> oilInclusion = GeneratedColumn<String>(
    'oil_inclusion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrition_sources (source_key)',
    ),
  );
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<String> sourceRecordId = GeneratedColumn<String>(
    'source_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewerIdMeta = const VerificationMeta(
    'reviewerId',
  );
  @override
  late final GeneratedColumn<String> reviewerId = GeneratedColumn<String>(
    'reviewer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    foodId,
    nameEnglish,
    nameRomanUrdu,
    normalizedNameEnglish,
    normalizedNameRomanUrdu,
    region,
    preparation,
    referenceGrams,
    caloriesKcal,
    proteinGrams,
    carbohydrateGrams,
    fatGrams,
    sodiumMilligrams,
    oilInclusion,
    sourceKey,
    sourceRecordId,
    reviewStatus,
    reviewerId,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('name_english')) {
      context.handle(
        _nameEnglishMeta,
        nameEnglish.isAcceptableOrUnknown(
          data['name_english']!,
          _nameEnglishMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameEnglishMeta);
    }
    if (data.containsKey('name_roman_urdu')) {
      context.handle(
        _nameRomanUrduMeta,
        nameRomanUrdu.isAcceptableOrUnknown(
          data['name_roman_urdu']!,
          _nameRomanUrduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameRomanUrduMeta);
    }
    if (data.containsKey('normalized_name_english')) {
      context.handle(
        _normalizedNameEnglishMeta,
        normalizedNameEnglish.isAcceptableOrUnknown(
          data['normalized_name_english']!,
          _normalizedNameEnglishMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameEnglishMeta);
    }
    if (data.containsKey('normalized_name_roman_urdu')) {
      context.handle(
        _normalizedNameRomanUrduMeta,
        normalizedNameRomanUrdu.isAcceptableOrUnknown(
          data['normalized_name_roman_urdu']!,
          _normalizedNameRomanUrduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameRomanUrduMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('preparation')) {
      context.handle(
        _preparationMeta,
        preparation.isAcceptableOrUnknown(
          data['preparation']!,
          _preparationMeta,
        ),
      );
    }
    if (data.containsKey('reference_grams')) {
      context.handle(
        _referenceGramsMeta,
        referenceGrams.isAcceptableOrUnknown(
          data['reference_grams']!,
          _referenceGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceGramsMeta);
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesKcalMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbohydrate_grams')) {
      context.handle(
        _carbohydrateGramsMeta,
        carbohydrateGrams.isAcceptableOrUnknown(
          data['carbohydrate_grams']!,
          _carbohydrateGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('sodium_milligrams')) {
      context.handle(
        _sodiumMilligramsMeta,
        sodiumMilligrams.isAcceptableOrUnknown(
          data['sodium_milligrams']!,
          _sodiumMilligramsMeta,
        ),
      );
    }
    if (data.containsKey('oil_inclusion')) {
      context.handle(
        _oilInclusionMeta,
        oilInclusion.isAcceptableOrUnknown(
          data['oil_inclusion']!,
          _oilInclusionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oilInclusionMeta);
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRecordIdMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('reviewer_id')) {
      context.handle(
        _reviewerIdMeta,
        reviewerId.isAcceptableOrUnknown(data['reviewer_id']!, _reviewerIdMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {releaseId, foodId};
  @override
  CatalogFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogFood(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      nameEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_english'],
      )!,
      nameRomanUrdu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_roman_urdu'],
      )!,
      normalizedNameEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name_english'],
      )!,
      normalizedNameRomanUrdu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name_roman_urdu'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      preparation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preparation'],
      ),
      referenceGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_grams'],
      )!,
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_kcal'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbohydrateGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      sodiumMilligrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_milligrams'],
      ),
      oilInclusion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oil_inclusion'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_record_id'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      reviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewer_id'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
    );
  }

  @override
  $CatalogFoodsTable createAlias(String alias) {
    return $CatalogFoodsTable(attachedDatabase, alias);
  }
}

class CatalogFood extends DataClass implements Insertable<CatalogFood> {
  final String releaseId;
  final String foodId;
  final String nameEnglish;
  final String nameRomanUrdu;
  final String normalizedNameEnglish;
  final String normalizedNameRomanUrdu;
  final String? region;
  final String? preparation;
  final double referenceGrams;
  final double caloriesKcal;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double? sodiumMilligrams;
  final String oilInclusion;
  final String sourceKey;
  final String sourceRecordId;
  final String reviewStatus;
  final String? reviewerId;
  final DateTime? reviewedAt;
  const CatalogFood({
    required this.releaseId,
    required this.foodId,
    required this.nameEnglish,
    required this.nameRomanUrdu,
    required this.normalizedNameEnglish,
    required this.normalizedNameRomanUrdu,
    this.region,
    this.preparation,
    required this.referenceGrams,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.sodiumMilligrams,
    required this.oilInclusion,
    required this.sourceKey,
    required this.sourceRecordId,
    required this.reviewStatus,
    this.reviewerId,
    this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['food_id'] = Variable<String>(foodId);
    map['name_english'] = Variable<String>(nameEnglish);
    map['name_roman_urdu'] = Variable<String>(nameRomanUrdu);
    map['normalized_name_english'] = Variable<String>(normalizedNameEnglish);
    map['normalized_name_roman_urdu'] = Variable<String>(
      normalizedNameRomanUrdu,
    );
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || preparation != null) {
      map['preparation'] = Variable<String>(preparation);
    }
    map['reference_grams'] = Variable<double>(referenceGrams);
    map['calories_kcal'] = Variable<double>(caloriesKcal);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbohydrate_grams'] = Variable<double>(carbohydrateGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    if (!nullToAbsent || sodiumMilligrams != null) {
      map['sodium_milligrams'] = Variable<double>(sodiumMilligrams);
    }
    map['oil_inclusion'] = Variable<String>(oilInclusion);
    map['source_key'] = Variable<String>(sourceKey);
    map['source_record_id'] = Variable<String>(sourceRecordId);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || reviewerId != null) {
      map['reviewer_id'] = Variable<String>(reviewerId);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    return map;
  }

  CatalogFoodsCompanion toCompanion(bool nullToAbsent) {
    return CatalogFoodsCompanion(
      releaseId: Value(releaseId),
      foodId: Value(foodId),
      nameEnglish: Value(nameEnglish),
      nameRomanUrdu: Value(nameRomanUrdu),
      normalizedNameEnglish: Value(normalizedNameEnglish),
      normalizedNameRomanUrdu: Value(normalizedNameRomanUrdu),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      preparation: preparation == null && nullToAbsent
          ? const Value.absent()
          : Value(preparation),
      referenceGrams: Value(referenceGrams),
      caloriesKcal: Value(caloriesKcal),
      proteinGrams: Value(proteinGrams),
      carbohydrateGrams: Value(carbohydrateGrams),
      fatGrams: Value(fatGrams),
      sodiumMilligrams: sodiumMilligrams == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMilligrams),
      oilInclusion: Value(oilInclusion),
      sourceKey: Value(sourceKey),
      sourceRecordId: Value(sourceRecordId),
      reviewStatus: Value(reviewStatus),
      reviewerId: reviewerId == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewerId),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory CatalogFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogFood(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      nameEnglish: serializer.fromJson<String>(json['nameEnglish']),
      nameRomanUrdu: serializer.fromJson<String>(json['nameRomanUrdu']),
      normalizedNameEnglish: serializer.fromJson<String>(
        json['normalizedNameEnglish'],
      ),
      normalizedNameRomanUrdu: serializer.fromJson<String>(
        json['normalizedNameRomanUrdu'],
      ),
      region: serializer.fromJson<String?>(json['region']),
      preparation: serializer.fromJson<String?>(json['preparation']),
      referenceGrams: serializer.fromJson<double>(json['referenceGrams']),
      caloriesKcal: serializer.fromJson<double>(json['caloriesKcal']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbohydrateGrams: serializer.fromJson<double>(json['carbohydrateGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      sodiumMilligrams: serializer.fromJson<double?>(json['sodiumMilligrams']),
      oilInclusion: serializer.fromJson<String>(json['oilInclusion']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      sourceRecordId: serializer.fromJson<String>(json['sourceRecordId']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      reviewerId: serializer.fromJson<String?>(json['reviewerId']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'foodId': serializer.toJson<String>(foodId),
      'nameEnglish': serializer.toJson<String>(nameEnglish),
      'nameRomanUrdu': serializer.toJson<String>(nameRomanUrdu),
      'normalizedNameEnglish': serializer.toJson<String>(normalizedNameEnglish),
      'normalizedNameRomanUrdu': serializer.toJson<String>(
        normalizedNameRomanUrdu,
      ),
      'region': serializer.toJson<String?>(region),
      'preparation': serializer.toJson<String?>(preparation),
      'referenceGrams': serializer.toJson<double>(referenceGrams),
      'caloriesKcal': serializer.toJson<double>(caloriesKcal),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbohydrateGrams': serializer.toJson<double>(carbohydrateGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'sodiumMilligrams': serializer.toJson<double?>(sodiumMilligrams),
      'oilInclusion': serializer.toJson<String>(oilInclusion),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'sourceRecordId': serializer.toJson<String>(sourceRecordId),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'reviewerId': serializer.toJson<String?>(reviewerId),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
    };
  }

  CatalogFood copyWith({
    String? releaseId,
    String? foodId,
    String? nameEnglish,
    String? nameRomanUrdu,
    String? normalizedNameEnglish,
    String? normalizedNameRomanUrdu,
    Value<String?> region = const Value.absent(),
    Value<String?> preparation = const Value.absent(),
    double? referenceGrams,
    double? caloriesKcal,
    double? proteinGrams,
    double? carbohydrateGrams,
    double? fatGrams,
    Value<double?> sodiumMilligrams = const Value.absent(),
    String? oilInclusion,
    String? sourceKey,
    String? sourceRecordId,
    String? reviewStatus,
    Value<String?> reviewerId = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
  }) => CatalogFood(
    releaseId: releaseId ?? this.releaseId,
    foodId: foodId ?? this.foodId,
    nameEnglish: nameEnglish ?? this.nameEnglish,
    nameRomanUrdu: nameRomanUrdu ?? this.nameRomanUrdu,
    normalizedNameEnglish: normalizedNameEnglish ?? this.normalizedNameEnglish,
    normalizedNameRomanUrdu:
        normalizedNameRomanUrdu ?? this.normalizedNameRomanUrdu,
    region: region.present ? region.value : this.region,
    preparation: preparation.present ? preparation.value : this.preparation,
    referenceGrams: referenceGrams ?? this.referenceGrams,
    caloriesKcal: caloriesKcal ?? this.caloriesKcal,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    sodiumMilligrams: sodiumMilligrams.present
        ? sodiumMilligrams.value
        : this.sodiumMilligrams,
    oilInclusion: oilInclusion ?? this.oilInclusion,
    sourceKey: sourceKey ?? this.sourceKey,
    sourceRecordId: sourceRecordId ?? this.sourceRecordId,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    reviewerId: reviewerId.present ? reviewerId.value : this.reviewerId,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
  );
  CatalogFood copyWithCompanion(CatalogFoodsCompanion data) {
    return CatalogFood(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      nameEnglish: data.nameEnglish.present
          ? data.nameEnglish.value
          : this.nameEnglish,
      nameRomanUrdu: data.nameRomanUrdu.present
          ? data.nameRomanUrdu.value
          : this.nameRomanUrdu,
      normalizedNameEnglish: data.normalizedNameEnglish.present
          ? data.normalizedNameEnglish.value
          : this.normalizedNameEnglish,
      normalizedNameRomanUrdu: data.normalizedNameRomanUrdu.present
          ? data.normalizedNameRomanUrdu.value
          : this.normalizedNameRomanUrdu,
      region: data.region.present ? data.region.value : this.region,
      preparation: data.preparation.present
          ? data.preparation.value
          : this.preparation,
      referenceGrams: data.referenceGrams.present
          ? data.referenceGrams.value
          : this.referenceGrams,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbohydrateGrams: data.carbohydrateGrams.present
          ? data.carbohydrateGrams.value
          : this.carbohydrateGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      sodiumMilligrams: data.sodiumMilligrams.present
          ? data.sodiumMilligrams.value
          : this.sodiumMilligrams,
      oilInclusion: data.oilInclusion.present
          ? data.oilInclusion.value
          : this.oilInclusion,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      reviewerId: data.reviewerId.present
          ? data.reviewerId.value
          : this.reviewerId,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogFood(')
          ..write('releaseId: $releaseId, ')
          ..write('foodId: $foodId, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('nameRomanUrdu: $nameRomanUrdu, ')
          ..write('normalizedNameEnglish: $normalizedNameEnglish, ')
          ..write('normalizedNameRomanUrdu: $normalizedNameRomanUrdu, ')
          ..write('region: $region, ')
          ..write('preparation: $preparation, ')
          ..write('referenceGrams: $referenceGrams, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbohydrateGrams: $carbohydrateGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('sodiumMilligrams: $sodiumMilligrams, ')
          ..write('oilInclusion: $oilInclusion, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    releaseId,
    foodId,
    nameEnglish,
    nameRomanUrdu,
    normalizedNameEnglish,
    normalizedNameRomanUrdu,
    region,
    preparation,
    referenceGrams,
    caloriesKcal,
    proteinGrams,
    carbohydrateGrams,
    fatGrams,
    sodiumMilligrams,
    oilInclusion,
    sourceKey,
    sourceRecordId,
    reviewStatus,
    reviewerId,
    reviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogFood &&
          other.releaseId == this.releaseId &&
          other.foodId == this.foodId &&
          other.nameEnglish == this.nameEnglish &&
          other.nameRomanUrdu == this.nameRomanUrdu &&
          other.normalizedNameEnglish == this.normalizedNameEnglish &&
          other.normalizedNameRomanUrdu == this.normalizedNameRomanUrdu &&
          other.region == this.region &&
          other.preparation == this.preparation &&
          other.referenceGrams == this.referenceGrams &&
          other.caloriesKcal == this.caloriesKcal &&
          other.proteinGrams == this.proteinGrams &&
          other.carbohydrateGrams == this.carbohydrateGrams &&
          other.fatGrams == this.fatGrams &&
          other.sodiumMilligrams == this.sodiumMilligrams &&
          other.oilInclusion == this.oilInclusion &&
          other.sourceKey == this.sourceKey &&
          other.sourceRecordId == this.sourceRecordId &&
          other.reviewStatus == this.reviewStatus &&
          other.reviewerId == this.reviewerId &&
          other.reviewedAt == this.reviewedAt);
}

class CatalogFoodsCompanion extends UpdateCompanion<CatalogFood> {
  final Value<String> releaseId;
  final Value<String> foodId;
  final Value<String> nameEnglish;
  final Value<String> nameRomanUrdu;
  final Value<String> normalizedNameEnglish;
  final Value<String> normalizedNameRomanUrdu;
  final Value<String?> region;
  final Value<String?> preparation;
  final Value<double> referenceGrams;
  final Value<double> caloriesKcal;
  final Value<double> proteinGrams;
  final Value<double> carbohydrateGrams;
  final Value<double> fatGrams;
  final Value<double?> sodiumMilligrams;
  final Value<String> oilInclusion;
  final Value<String> sourceKey;
  final Value<String> sourceRecordId;
  final Value<String> reviewStatus;
  final Value<String?> reviewerId;
  final Value<DateTime?> reviewedAt;
  final Value<int> rowid;
  const CatalogFoodsCompanion({
    this.releaseId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.nameEnglish = const Value.absent(),
    this.nameRomanUrdu = const Value.absent(),
    this.normalizedNameEnglish = const Value.absent(),
    this.normalizedNameRomanUrdu = const Value.absent(),
    this.region = const Value.absent(),
    this.preparation = const Value.absent(),
    this.referenceGrams = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbohydrateGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.sodiumMilligrams = const Value.absent(),
    this.oilInclusion = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.reviewerId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogFoodsCompanion.insert({
    required String releaseId,
    required String foodId,
    required String nameEnglish,
    required String nameRomanUrdu,
    required String normalizedNameEnglish,
    required String normalizedNameRomanUrdu,
    this.region = const Value.absent(),
    this.preparation = const Value.absent(),
    required double referenceGrams,
    required double caloriesKcal,
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
    this.sodiumMilligrams = const Value.absent(),
    required String oilInclusion,
    required String sourceKey,
    required String sourceRecordId,
    required String reviewStatus,
    this.reviewerId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       foodId = Value(foodId),
       nameEnglish = Value(nameEnglish),
       nameRomanUrdu = Value(nameRomanUrdu),
       normalizedNameEnglish = Value(normalizedNameEnglish),
       normalizedNameRomanUrdu = Value(normalizedNameRomanUrdu),
       referenceGrams = Value(referenceGrams),
       caloriesKcal = Value(caloriesKcal),
       proteinGrams = Value(proteinGrams),
       carbohydrateGrams = Value(carbohydrateGrams),
       fatGrams = Value(fatGrams),
       oilInclusion = Value(oilInclusion),
       sourceKey = Value(sourceKey),
       sourceRecordId = Value(sourceRecordId),
       reviewStatus = Value(reviewStatus);
  static Insertable<CatalogFood> custom({
    Expression<String>? releaseId,
    Expression<String>? foodId,
    Expression<String>? nameEnglish,
    Expression<String>? nameRomanUrdu,
    Expression<String>? normalizedNameEnglish,
    Expression<String>? normalizedNameRomanUrdu,
    Expression<String>? region,
    Expression<String>? preparation,
    Expression<double>? referenceGrams,
    Expression<double>? caloriesKcal,
    Expression<double>? proteinGrams,
    Expression<double>? carbohydrateGrams,
    Expression<double>? fatGrams,
    Expression<double>? sodiumMilligrams,
    Expression<String>? oilInclusion,
    Expression<String>? sourceKey,
    Expression<String>? sourceRecordId,
    Expression<String>? reviewStatus,
    Expression<String>? reviewerId,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (foodId != null) 'food_id': foodId,
      if (nameEnglish != null) 'name_english': nameEnglish,
      if (nameRomanUrdu != null) 'name_roman_urdu': nameRomanUrdu,
      if (normalizedNameEnglish != null)
        'normalized_name_english': normalizedNameEnglish,
      if (normalizedNameRomanUrdu != null)
        'normalized_name_roman_urdu': normalizedNameRomanUrdu,
      if (region != null) 'region': region,
      if (preparation != null) 'preparation': preparation,
      if (referenceGrams != null) 'reference_grams': referenceGrams,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbohydrateGrams != null) 'carbohydrate_grams': carbohydrateGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (sodiumMilligrams != null) 'sodium_milligrams': sodiumMilligrams,
      if (oilInclusion != null) 'oil_inclusion': oilInclusion,
      if (sourceKey != null) 'source_key': sourceKey,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogFoodsCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? foodId,
    Value<String>? nameEnglish,
    Value<String>? nameRomanUrdu,
    Value<String>? normalizedNameEnglish,
    Value<String>? normalizedNameRomanUrdu,
    Value<String?>? region,
    Value<String?>? preparation,
    Value<double>? referenceGrams,
    Value<double>? caloriesKcal,
    Value<double>? proteinGrams,
    Value<double>? carbohydrateGrams,
    Value<double>? fatGrams,
    Value<double?>? sodiumMilligrams,
    Value<String>? oilInclusion,
    Value<String>? sourceKey,
    Value<String>? sourceRecordId,
    Value<String>? reviewStatus,
    Value<String?>? reviewerId,
    Value<DateTime?>? reviewedAt,
    Value<int>? rowid,
  }) {
    return CatalogFoodsCompanion(
      releaseId: releaseId ?? this.releaseId,
      foodId: foodId ?? this.foodId,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameRomanUrdu: nameRomanUrdu ?? this.nameRomanUrdu,
      normalizedNameEnglish:
          normalizedNameEnglish ?? this.normalizedNameEnglish,
      normalizedNameRomanUrdu:
          normalizedNameRomanUrdu ?? this.normalizedNameRomanUrdu,
      region: region ?? this.region,
      preparation: preparation ?? this.preparation,
      referenceGrams: referenceGrams ?? this.referenceGrams,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      sodiumMilligrams: sodiumMilligrams ?? this.sodiumMilligrams,
      oilInclusion: oilInclusion ?? this.oilInclusion,
      sourceKey: sourceKey ?? this.sourceKey,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (nameEnglish.present) {
      map['name_english'] = Variable<String>(nameEnglish.value);
    }
    if (nameRomanUrdu.present) {
      map['name_roman_urdu'] = Variable<String>(nameRomanUrdu.value);
    }
    if (normalizedNameEnglish.present) {
      map['normalized_name_english'] = Variable<String>(
        normalizedNameEnglish.value,
      );
    }
    if (normalizedNameRomanUrdu.present) {
      map['normalized_name_roman_urdu'] = Variable<String>(
        normalizedNameRomanUrdu.value,
      );
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (preparation.present) {
      map['preparation'] = Variable<String>(preparation.value);
    }
    if (referenceGrams.present) {
      map['reference_grams'] = Variable<double>(referenceGrams.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<double>(caloriesKcal.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbohydrateGrams.present) {
      map['carbohydrate_grams'] = Variable<double>(carbohydrateGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (sodiumMilligrams.present) {
      map['sodium_milligrams'] = Variable<double>(sodiumMilligrams.value);
    }
    if (oilInclusion.present) {
      map['oil_inclusion'] = Variable<String>(oilInclusion.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<String>(sourceRecordId.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (reviewerId.present) {
      map['reviewer_id'] = Variable<String>(reviewerId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogFoodsCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('foodId: $foodId, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('nameRomanUrdu: $nameRomanUrdu, ')
          ..write('normalizedNameEnglish: $normalizedNameEnglish, ')
          ..write('normalizedNameRomanUrdu: $normalizedNameRomanUrdu, ')
          ..write('region: $region, ')
          ..write('preparation: $preparation, ')
          ..write('referenceGrams: $referenceGrams, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbohydrateGrams: $carbohydrateGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('sodiumMilligrams: $sodiumMilligrams, ')
          ..write('oilInclusion: $oilInclusion, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogFoodSynonymsTable extends CatalogFoodSynonyms
    with TableInfo<$CatalogFoodSynonymsTable, CatalogFoodSynonym> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogFoodSynonymsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _synonymMeta = const VerificationMeta(
    'synonym',
  );
  @override
  late final GeneratedColumn<String> synonym = GeneratedColumn<String>(
    'synonym',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedSynonymMeta = const VerificationMeta(
    'normalizedSynonym',
  );
  @override
  late final GeneratedColumn<String> normalizedSynonym =
      GeneratedColumn<String>(
        'normalized_synonym',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    foodId,
    locale,
    synonym,
    normalizedSynonym,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_food_synonyms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogFoodSynonym> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('synonym')) {
      context.handle(
        _synonymMeta,
        synonym.isAcceptableOrUnknown(data['synonym']!, _synonymMeta),
      );
    } else if (isInserting) {
      context.missing(_synonymMeta);
    }
    if (data.containsKey('normalized_synonym')) {
      context.handle(
        _normalizedSynonymMeta,
        normalizedSynonym.isAcceptableOrUnknown(
          data['normalized_synonym']!,
          _normalizedSynonymMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedSynonymMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    releaseId,
    foodId,
    locale,
    normalizedSynonym,
  };
  @override
  CatalogFoodSynonym map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogFoodSynonym(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      synonym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synonym'],
      )!,
      normalizedSynonym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_synonym'],
      )!,
    );
  }

  @override
  $CatalogFoodSynonymsTable createAlias(String alias) {
    return $CatalogFoodSynonymsTable(attachedDatabase, alias);
  }
}

class CatalogFoodSynonym extends DataClass
    implements Insertable<CatalogFoodSynonym> {
  final String releaseId;
  final String foodId;
  final String locale;
  final String synonym;
  final String normalizedSynonym;
  const CatalogFoodSynonym({
    required this.releaseId,
    required this.foodId,
    required this.locale,
    required this.synonym,
    required this.normalizedSynonym,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['food_id'] = Variable<String>(foodId);
    map['locale'] = Variable<String>(locale);
    map['synonym'] = Variable<String>(synonym);
    map['normalized_synonym'] = Variable<String>(normalizedSynonym);
    return map;
  }

  CatalogFoodSynonymsCompanion toCompanion(bool nullToAbsent) {
    return CatalogFoodSynonymsCompanion(
      releaseId: Value(releaseId),
      foodId: Value(foodId),
      locale: Value(locale),
      synonym: Value(synonym),
      normalizedSynonym: Value(normalizedSynonym),
    );
  }

  factory CatalogFoodSynonym.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogFoodSynonym(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      locale: serializer.fromJson<String>(json['locale']),
      synonym: serializer.fromJson<String>(json['synonym']),
      normalizedSynonym: serializer.fromJson<String>(json['normalizedSynonym']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'foodId': serializer.toJson<String>(foodId),
      'locale': serializer.toJson<String>(locale),
      'synonym': serializer.toJson<String>(synonym),
      'normalizedSynonym': serializer.toJson<String>(normalizedSynonym),
    };
  }

  CatalogFoodSynonym copyWith({
    String? releaseId,
    String? foodId,
    String? locale,
    String? synonym,
    String? normalizedSynonym,
  }) => CatalogFoodSynonym(
    releaseId: releaseId ?? this.releaseId,
    foodId: foodId ?? this.foodId,
    locale: locale ?? this.locale,
    synonym: synonym ?? this.synonym,
    normalizedSynonym: normalizedSynonym ?? this.normalizedSynonym,
  );
  CatalogFoodSynonym copyWithCompanion(CatalogFoodSynonymsCompanion data) {
    return CatalogFoodSynonym(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      locale: data.locale.present ? data.locale.value : this.locale,
      synonym: data.synonym.present ? data.synonym.value : this.synonym,
      normalizedSynonym: data.normalizedSynonym.present
          ? data.normalizedSynonym.value
          : this.normalizedSynonym,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogFoodSynonym(')
          ..write('releaseId: $releaseId, ')
          ..write('foodId: $foodId, ')
          ..write('locale: $locale, ')
          ..write('synonym: $synonym, ')
          ..write('normalizedSynonym: $normalizedSynonym')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(releaseId, foodId, locale, synonym, normalizedSynonym);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogFoodSynonym &&
          other.releaseId == this.releaseId &&
          other.foodId == this.foodId &&
          other.locale == this.locale &&
          other.synonym == this.synonym &&
          other.normalizedSynonym == this.normalizedSynonym);
}

class CatalogFoodSynonymsCompanion extends UpdateCompanion<CatalogFoodSynonym> {
  final Value<String> releaseId;
  final Value<String> foodId;
  final Value<String> locale;
  final Value<String> synonym;
  final Value<String> normalizedSynonym;
  final Value<int> rowid;
  const CatalogFoodSynonymsCompanion({
    this.releaseId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.locale = const Value.absent(),
    this.synonym = const Value.absent(),
    this.normalizedSynonym = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogFoodSynonymsCompanion.insert({
    required String releaseId,
    required String foodId,
    required String locale,
    required String synonym,
    required String normalizedSynonym,
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       foodId = Value(foodId),
       locale = Value(locale),
       synonym = Value(synonym),
       normalizedSynonym = Value(normalizedSynonym);
  static Insertable<CatalogFoodSynonym> custom({
    Expression<String>? releaseId,
    Expression<String>? foodId,
    Expression<String>? locale,
    Expression<String>? synonym,
    Expression<String>? normalizedSynonym,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (foodId != null) 'food_id': foodId,
      if (locale != null) 'locale': locale,
      if (synonym != null) 'synonym': synonym,
      if (normalizedSynonym != null) 'normalized_synonym': normalizedSynonym,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogFoodSynonymsCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? foodId,
    Value<String>? locale,
    Value<String>? synonym,
    Value<String>? normalizedSynonym,
    Value<int>? rowid,
  }) {
    return CatalogFoodSynonymsCompanion(
      releaseId: releaseId ?? this.releaseId,
      foodId: foodId ?? this.foodId,
      locale: locale ?? this.locale,
      synonym: synonym ?? this.synonym,
      normalizedSynonym: normalizedSynonym ?? this.normalizedSynonym,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (synonym.present) {
      map['synonym'] = Variable<String>(synonym.value);
    }
    if (normalizedSynonym.present) {
      map['normalized_synonym'] = Variable<String>(normalizedSynonym.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogFoodSynonymsCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('foodId: $foodId, ')
          ..write('locale: $locale, ')
          ..write('synonym: $synonym, ')
          ..write('normalizedSynonym: $normalizedSynonym, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogServingDefinitionsTable extends CatalogServingDefinitions
    with TableInfo<$CatalogServingDefinitionsTable, CatalogServingDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogServingDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingIdMeta = const VerificationMeta(
    'servingId',
  );
  @override
  late final GeneratedColumn<String> servingId = GeneratedColumn<String>(
    'serving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMinimumMeta = const VerificationMeta(
    'gramsMinimum',
  );
  @override
  late final GeneratedColumn<double> gramsMinimum = GeneratedColumn<double>(
    'grams_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMaximumMeta = const VerificationMeta(
    'gramsMaximum',
  );
  @override
  late final GeneratedColumn<double> gramsMaximum = GeneratedColumn<double>(
    'grams_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    foodId,
    servingId,
    label,
    unitCode,
    gramsMinimum,
    gramsMaximum,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_serving_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogServingDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('serving_id')) {
      context.handle(
        _servingIdMeta,
        servingId.isAcceptableOrUnknown(data['serving_id']!, _servingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_servingIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('grams_minimum')) {
      context.handle(
        _gramsMinimumMeta,
        gramsMinimum.isAcceptableOrUnknown(
          data['grams_minimum']!,
          _gramsMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gramsMinimumMeta);
    }
    if (data.containsKey('grams_maximum')) {
      context.handle(
        _gramsMaximumMeta,
        gramsMaximum.isAcceptableOrUnknown(
          data['grams_maximum']!,
          _gramsMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gramsMaximumMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {releaseId, foodId, servingId};
  @override
  CatalogServingDefinition map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogServingDefinition(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      servingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      gramsMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_minimum'],
      )!,
      gramsMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_maximum'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
    );
  }

  @override
  $CatalogServingDefinitionsTable createAlias(String alias) {
    return $CatalogServingDefinitionsTable(attachedDatabase, alias);
  }
}

class CatalogServingDefinition extends DataClass
    implements Insertable<CatalogServingDefinition> {
  final String releaseId;
  final String foodId;
  final String servingId;
  final String label;
  final String unitCode;
  final double gramsMinimum;
  final double gramsMaximum;
  final double confidence;
  const CatalogServingDefinition({
    required this.releaseId,
    required this.foodId,
    required this.servingId,
    required this.label,
    required this.unitCode,
    required this.gramsMinimum,
    required this.gramsMaximum,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['food_id'] = Variable<String>(foodId);
    map['serving_id'] = Variable<String>(servingId);
    map['label'] = Variable<String>(label);
    map['unit_code'] = Variable<String>(unitCode);
    map['grams_minimum'] = Variable<double>(gramsMinimum);
    map['grams_maximum'] = Variable<double>(gramsMaximum);
    map['confidence'] = Variable<double>(confidence);
    return map;
  }

  CatalogServingDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CatalogServingDefinitionsCompanion(
      releaseId: Value(releaseId),
      foodId: Value(foodId),
      servingId: Value(servingId),
      label: Value(label),
      unitCode: Value(unitCode),
      gramsMinimum: Value(gramsMinimum),
      gramsMaximum: Value(gramsMaximum),
      confidence: Value(confidence),
    );
  }

  factory CatalogServingDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogServingDefinition(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      servingId: serializer.fromJson<String>(json['servingId']),
      label: serializer.fromJson<String>(json['label']),
      unitCode: serializer.fromJson<String>(json['unitCode']),
      gramsMinimum: serializer.fromJson<double>(json['gramsMinimum']),
      gramsMaximum: serializer.fromJson<double>(json['gramsMaximum']),
      confidence: serializer.fromJson<double>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'foodId': serializer.toJson<String>(foodId),
      'servingId': serializer.toJson<String>(servingId),
      'label': serializer.toJson<String>(label),
      'unitCode': serializer.toJson<String>(unitCode),
      'gramsMinimum': serializer.toJson<double>(gramsMinimum),
      'gramsMaximum': serializer.toJson<double>(gramsMaximum),
      'confidence': serializer.toJson<double>(confidence),
    };
  }

  CatalogServingDefinition copyWith({
    String? releaseId,
    String? foodId,
    String? servingId,
    String? label,
    String? unitCode,
    double? gramsMinimum,
    double? gramsMaximum,
    double? confidence,
  }) => CatalogServingDefinition(
    releaseId: releaseId ?? this.releaseId,
    foodId: foodId ?? this.foodId,
    servingId: servingId ?? this.servingId,
    label: label ?? this.label,
    unitCode: unitCode ?? this.unitCode,
    gramsMinimum: gramsMinimum ?? this.gramsMinimum,
    gramsMaximum: gramsMaximum ?? this.gramsMaximum,
    confidence: confidence ?? this.confidence,
  );
  CatalogServingDefinition copyWithCompanion(
    CatalogServingDefinitionsCompanion data,
  ) {
    return CatalogServingDefinition(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      servingId: data.servingId.present ? data.servingId.value : this.servingId,
      label: data.label.present ? data.label.value : this.label,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      gramsMinimum: data.gramsMinimum.present
          ? data.gramsMinimum.value
          : this.gramsMinimum,
      gramsMaximum: data.gramsMaximum.present
          ? data.gramsMaximum.value
          : this.gramsMaximum,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogServingDefinition(')
          ..write('releaseId: $releaseId, ')
          ..write('foodId: $foodId, ')
          ..write('servingId: $servingId, ')
          ..write('label: $label, ')
          ..write('unitCode: $unitCode, ')
          ..write('gramsMinimum: $gramsMinimum, ')
          ..write('gramsMaximum: $gramsMaximum, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    releaseId,
    foodId,
    servingId,
    label,
    unitCode,
    gramsMinimum,
    gramsMaximum,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogServingDefinition &&
          other.releaseId == this.releaseId &&
          other.foodId == this.foodId &&
          other.servingId == this.servingId &&
          other.label == this.label &&
          other.unitCode == this.unitCode &&
          other.gramsMinimum == this.gramsMinimum &&
          other.gramsMaximum == this.gramsMaximum &&
          other.confidence == this.confidence);
}

class CatalogServingDefinitionsCompanion
    extends UpdateCompanion<CatalogServingDefinition> {
  final Value<String> releaseId;
  final Value<String> foodId;
  final Value<String> servingId;
  final Value<String> label;
  final Value<String> unitCode;
  final Value<double> gramsMinimum;
  final Value<double> gramsMaximum;
  final Value<double> confidence;
  final Value<int> rowid;
  const CatalogServingDefinitionsCompanion({
    this.releaseId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.servingId = const Value.absent(),
    this.label = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.gramsMinimum = const Value.absent(),
    this.gramsMaximum = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogServingDefinitionsCompanion.insert({
    required String releaseId,
    required String foodId,
    required String servingId,
    required String label,
    required String unitCode,
    required double gramsMinimum,
    required double gramsMaximum,
    required double confidence,
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       foodId = Value(foodId),
       servingId = Value(servingId),
       label = Value(label),
       unitCode = Value(unitCode),
       gramsMinimum = Value(gramsMinimum),
       gramsMaximum = Value(gramsMaximum),
       confidence = Value(confidence);
  static Insertable<CatalogServingDefinition> custom({
    Expression<String>? releaseId,
    Expression<String>? foodId,
    Expression<String>? servingId,
    Expression<String>? label,
    Expression<String>? unitCode,
    Expression<double>? gramsMinimum,
    Expression<double>? gramsMaximum,
    Expression<double>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (foodId != null) 'food_id': foodId,
      if (servingId != null) 'serving_id': servingId,
      if (label != null) 'label': label,
      if (unitCode != null) 'unit_code': unitCode,
      if (gramsMinimum != null) 'grams_minimum': gramsMinimum,
      if (gramsMaximum != null) 'grams_maximum': gramsMaximum,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogServingDefinitionsCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? foodId,
    Value<String>? servingId,
    Value<String>? label,
    Value<String>? unitCode,
    Value<double>? gramsMinimum,
    Value<double>? gramsMaximum,
    Value<double>? confidence,
    Value<int>? rowid,
  }) {
    return CatalogServingDefinitionsCompanion(
      releaseId: releaseId ?? this.releaseId,
      foodId: foodId ?? this.foodId,
      servingId: servingId ?? this.servingId,
      label: label ?? this.label,
      unitCode: unitCode ?? this.unitCode,
      gramsMinimum: gramsMinimum ?? this.gramsMinimum,
      gramsMaximum: gramsMaximum ?? this.gramsMaximum,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (servingId.present) {
      map['serving_id'] = Variable<String>(servingId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (gramsMinimum.present) {
      map['grams_minimum'] = Variable<double>(gramsMinimum.value);
    }
    if (gramsMaximum.present) {
      map['grams_maximum'] = Variable<double>(gramsMaximum.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogServingDefinitionsCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('foodId: $foodId, ')
          ..write('servingId: $servingId, ')
          ..write('label: $label, ')
          ..write('unitCode: $unitCode, ')
          ..write('gramsMinimum: $gramsMinimum, ')
          ..write('gramsMaximum: $gramsMaximum, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogRecipesTable extends CatalogRecipes
    with TableInfo<$CatalogRecipesTable, CatalogRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_releases (release_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnglishMeta = const VerificationMeta(
    'nameEnglish',
  );
  @override
  late final GeneratedColumn<String> nameEnglish = GeneratedColumn<String>(
    'name_english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameRomanUrduMeta = const VerificationMeta(
    'nameRomanUrdu',
  );
  @override
  late final GeneratedColumn<String> nameRomanUrdu = GeneratedColumn<String>(
    'name_roman_urdu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameEnglishMeta =
      const VerificationMeta('normalizedNameEnglish');
  @override
  late final GeneratedColumn<String> normalizedNameEnglish =
      GeneratedColumn<String>(
        'normalized_name_english',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _normalizedNameRomanUrduMeta =
      const VerificationMeta('normalizedNameRomanUrdu');
  @override
  late final GeneratedColumn<String> normalizedNameRomanUrdu =
      GeneratedColumn<String>(
        'normalized_name_roman_urdu',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preparationVariantMeta =
      const VerificationMeta('preparationVariant');
  @override
  late final GeneratedColumn<String> preparationVariant =
      GeneratedColumn<String>(
        'preparation_variant',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _yieldServingsMinimumMeta =
      const VerificationMeta('yieldServingsMinimum');
  @override
  late final GeneratedColumn<double> yieldServingsMinimum =
      GeneratedColumn<double>(
        'yield_servings_minimum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _yieldServingsMaximumMeta =
      const VerificationMeta('yieldServingsMaximum');
  @override
  late final GeneratedColumn<double> yieldServingsMaximum =
      GeneratedColumn<double>(
        'yield_servings_maximum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _oilTreatmentMeta = const VerificationMeta(
    'oilTreatment',
  );
  @override
  late final GeneratedColumn<String> oilTreatment = GeneratedColumn<String>(
    'oil_treatment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKeyMeta = const VerificationMeta(
    'sourceKey',
  );
  @override
  late final GeneratedColumn<String> sourceKey = GeneratedColumn<String>(
    'source_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nutrition_sources (source_key)',
    ),
  );
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<String> sourceRecordId = GeneratedColumn<String>(
    'source_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewerIdMeta = const VerificationMeta(
    'reviewerId',
  );
  @override
  late final GeneratedColumn<String> reviewerId = GeneratedColumn<String>(
    'reviewer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    recipeId,
    nameEnglish,
    nameRomanUrdu,
    normalizedNameEnglish,
    normalizedNameRomanUrdu,
    region,
    preparationVariant,
    yieldServingsMinimum,
    yieldServingsMaximum,
    oilTreatment,
    sourceKey,
    sourceRecordId,
    reviewStatus,
    reviewerId,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogRecipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('name_english')) {
      context.handle(
        _nameEnglishMeta,
        nameEnglish.isAcceptableOrUnknown(
          data['name_english']!,
          _nameEnglishMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameEnglishMeta);
    }
    if (data.containsKey('name_roman_urdu')) {
      context.handle(
        _nameRomanUrduMeta,
        nameRomanUrdu.isAcceptableOrUnknown(
          data['name_roman_urdu']!,
          _nameRomanUrduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameRomanUrduMeta);
    }
    if (data.containsKey('normalized_name_english')) {
      context.handle(
        _normalizedNameEnglishMeta,
        normalizedNameEnglish.isAcceptableOrUnknown(
          data['normalized_name_english']!,
          _normalizedNameEnglishMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameEnglishMeta);
    }
    if (data.containsKey('normalized_name_roman_urdu')) {
      context.handle(
        _normalizedNameRomanUrduMeta,
        normalizedNameRomanUrdu.isAcceptableOrUnknown(
          data['normalized_name_roman_urdu']!,
          _normalizedNameRomanUrduMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameRomanUrduMeta);
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('preparation_variant')) {
      context.handle(
        _preparationVariantMeta,
        preparationVariant.isAcceptableOrUnknown(
          data['preparation_variant']!,
          _preparationVariantMeta,
        ),
      );
    }
    if (data.containsKey('yield_servings_minimum')) {
      context.handle(
        _yieldServingsMinimumMeta,
        yieldServingsMinimum.isAcceptableOrUnknown(
          data['yield_servings_minimum']!,
          _yieldServingsMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_yieldServingsMinimumMeta);
    }
    if (data.containsKey('yield_servings_maximum')) {
      context.handle(
        _yieldServingsMaximumMeta,
        yieldServingsMaximum.isAcceptableOrUnknown(
          data['yield_servings_maximum']!,
          _yieldServingsMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_yieldServingsMaximumMeta);
    }
    if (data.containsKey('oil_treatment')) {
      context.handle(
        _oilTreatmentMeta,
        oilTreatment.isAcceptableOrUnknown(
          data['oil_treatment']!,
          _oilTreatmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oilTreatmentMeta);
    }
    if (data.containsKey('source_key')) {
      context.handle(
        _sourceKeyMeta,
        sourceKey.isAcceptableOrUnknown(data['source_key']!, _sourceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKeyMeta);
    }
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRecordIdMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewStatusMeta);
    }
    if (data.containsKey('reviewer_id')) {
      context.handle(
        _reviewerIdMeta,
        reviewerId.isAcceptableOrUnknown(data['reviewer_id']!, _reviewerIdMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {releaseId, recipeId};
  @override
  CatalogRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRecipe(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      nameEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_english'],
      )!,
      nameRomanUrdu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_roman_urdu'],
      )!,
      normalizedNameEnglish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name_english'],
      )!,
      normalizedNameRomanUrdu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name_roman_urdu'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      preparationVariant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preparation_variant'],
      ),
      yieldServingsMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yield_servings_minimum'],
      )!,
      yieldServingsMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yield_servings_maximum'],
      )!,
      oilTreatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oil_treatment'],
      )!,
      sourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_key'],
      )!,
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_record_id'],
      )!,
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      )!,
      reviewerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewer_id'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
    );
  }

  @override
  $CatalogRecipesTable createAlias(String alias) {
    return $CatalogRecipesTable(attachedDatabase, alias);
  }
}

class CatalogRecipe extends DataClass implements Insertable<CatalogRecipe> {
  final String releaseId;
  final String recipeId;
  final String nameEnglish;
  final String nameRomanUrdu;
  final String normalizedNameEnglish;
  final String normalizedNameRomanUrdu;
  final String? region;
  final String? preparationVariant;
  final double yieldServingsMinimum;
  final double yieldServingsMaximum;
  final String oilTreatment;
  final String sourceKey;
  final String sourceRecordId;
  final String reviewStatus;
  final String? reviewerId;
  final DateTime? reviewedAt;
  const CatalogRecipe({
    required this.releaseId,
    required this.recipeId,
    required this.nameEnglish,
    required this.nameRomanUrdu,
    required this.normalizedNameEnglish,
    required this.normalizedNameRomanUrdu,
    this.region,
    this.preparationVariant,
    required this.yieldServingsMinimum,
    required this.yieldServingsMaximum,
    required this.oilTreatment,
    required this.sourceKey,
    required this.sourceRecordId,
    required this.reviewStatus,
    this.reviewerId,
    this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['recipe_id'] = Variable<String>(recipeId);
    map['name_english'] = Variable<String>(nameEnglish);
    map['name_roman_urdu'] = Variable<String>(nameRomanUrdu);
    map['normalized_name_english'] = Variable<String>(normalizedNameEnglish);
    map['normalized_name_roman_urdu'] = Variable<String>(
      normalizedNameRomanUrdu,
    );
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || preparationVariant != null) {
      map['preparation_variant'] = Variable<String>(preparationVariant);
    }
    map['yield_servings_minimum'] = Variable<double>(yieldServingsMinimum);
    map['yield_servings_maximum'] = Variable<double>(yieldServingsMaximum);
    map['oil_treatment'] = Variable<String>(oilTreatment);
    map['source_key'] = Variable<String>(sourceKey);
    map['source_record_id'] = Variable<String>(sourceRecordId);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || reviewerId != null) {
      map['reviewer_id'] = Variable<String>(reviewerId);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    return map;
  }

  CatalogRecipesCompanion toCompanion(bool nullToAbsent) {
    return CatalogRecipesCompanion(
      releaseId: Value(releaseId),
      recipeId: Value(recipeId),
      nameEnglish: Value(nameEnglish),
      nameRomanUrdu: Value(nameRomanUrdu),
      normalizedNameEnglish: Value(normalizedNameEnglish),
      normalizedNameRomanUrdu: Value(normalizedNameRomanUrdu),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      preparationVariant: preparationVariant == null && nullToAbsent
          ? const Value.absent()
          : Value(preparationVariant),
      yieldServingsMinimum: Value(yieldServingsMinimum),
      yieldServingsMaximum: Value(yieldServingsMaximum),
      oilTreatment: Value(oilTreatment),
      sourceKey: Value(sourceKey),
      sourceRecordId: Value(sourceRecordId),
      reviewStatus: Value(reviewStatus),
      reviewerId: reviewerId == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewerId),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory CatalogRecipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRecipe(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      nameEnglish: serializer.fromJson<String>(json['nameEnglish']),
      nameRomanUrdu: serializer.fromJson<String>(json['nameRomanUrdu']),
      normalizedNameEnglish: serializer.fromJson<String>(
        json['normalizedNameEnglish'],
      ),
      normalizedNameRomanUrdu: serializer.fromJson<String>(
        json['normalizedNameRomanUrdu'],
      ),
      region: serializer.fromJson<String?>(json['region']),
      preparationVariant: serializer.fromJson<String?>(
        json['preparationVariant'],
      ),
      yieldServingsMinimum: serializer.fromJson<double>(
        json['yieldServingsMinimum'],
      ),
      yieldServingsMaximum: serializer.fromJson<double>(
        json['yieldServingsMaximum'],
      ),
      oilTreatment: serializer.fromJson<String>(json['oilTreatment']),
      sourceKey: serializer.fromJson<String>(json['sourceKey']),
      sourceRecordId: serializer.fromJson<String>(json['sourceRecordId']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      reviewerId: serializer.fromJson<String?>(json['reviewerId']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'recipeId': serializer.toJson<String>(recipeId),
      'nameEnglish': serializer.toJson<String>(nameEnglish),
      'nameRomanUrdu': serializer.toJson<String>(nameRomanUrdu),
      'normalizedNameEnglish': serializer.toJson<String>(normalizedNameEnglish),
      'normalizedNameRomanUrdu': serializer.toJson<String>(
        normalizedNameRomanUrdu,
      ),
      'region': serializer.toJson<String?>(region),
      'preparationVariant': serializer.toJson<String?>(preparationVariant),
      'yieldServingsMinimum': serializer.toJson<double>(yieldServingsMinimum),
      'yieldServingsMaximum': serializer.toJson<double>(yieldServingsMaximum),
      'oilTreatment': serializer.toJson<String>(oilTreatment),
      'sourceKey': serializer.toJson<String>(sourceKey),
      'sourceRecordId': serializer.toJson<String>(sourceRecordId),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'reviewerId': serializer.toJson<String?>(reviewerId),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
    };
  }

  CatalogRecipe copyWith({
    String? releaseId,
    String? recipeId,
    String? nameEnglish,
    String? nameRomanUrdu,
    String? normalizedNameEnglish,
    String? normalizedNameRomanUrdu,
    Value<String?> region = const Value.absent(),
    Value<String?> preparationVariant = const Value.absent(),
    double? yieldServingsMinimum,
    double? yieldServingsMaximum,
    String? oilTreatment,
    String? sourceKey,
    String? sourceRecordId,
    String? reviewStatus,
    Value<String?> reviewerId = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
  }) => CatalogRecipe(
    releaseId: releaseId ?? this.releaseId,
    recipeId: recipeId ?? this.recipeId,
    nameEnglish: nameEnglish ?? this.nameEnglish,
    nameRomanUrdu: nameRomanUrdu ?? this.nameRomanUrdu,
    normalizedNameEnglish: normalizedNameEnglish ?? this.normalizedNameEnglish,
    normalizedNameRomanUrdu:
        normalizedNameRomanUrdu ?? this.normalizedNameRomanUrdu,
    region: region.present ? region.value : this.region,
    preparationVariant: preparationVariant.present
        ? preparationVariant.value
        : this.preparationVariant,
    yieldServingsMinimum: yieldServingsMinimum ?? this.yieldServingsMinimum,
    yieldServingsMaximum: yieldServingsMaximum ?? this.yieldServingsMaximum,
    oilTreatment: oilTreatment ?? this.oilTreatment,
    sourceKey: sourceKey ?? this.sourceKey,
    sourceRecordId: sourceRecordId ?? this.sourceRecordId,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    reviewerId: reviewerId.present ? reviewerId.value : this.reviewerId,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
  );
  CatalogRecipe copyWithCompanion(CatalogRecipesCompanion data) {
    return CatalogRecipe(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      nameEnglish: data.nameEnglish.present
          ? data.nameEnglish.value
          : this.nameEnglish,
      nameRomanUrdu: data.nameRomanUrdu.present
          ? data.nameRomanUrdu.value
          : this.nameRomanUrdu,
      normalizedNameEnglish: data.normalizedNameEnglish.present
          ? data.normalizedNameEnglish.value
          : this.normalizedNameEnglish,
      normalizedNameRomanUrdu: data.normalizedNameRomanUrdu.present
          ? data.normalizedNameRomanUrdu.value
          : this.normalizedNameRomanUrdu,
      region: data.region.present ? data.region.value : this.region,
      preparationVariant: data.preparationVariant.present
          ? data.preparationVariant.value
          : this.preparationVariant,
      yieldServingsMinimum: data.yieldServingsMinimum.present
          ? data.yieldServingsMinimum.value
          : this.yieldServingsMinimum,
      yieldServingsMaximum: data.yieldServingsMaximum.present
          ? data.yieldServingsMaximum.value
          : this.yieldServingsMaximum,
      oilTreatment: data.oilTreatment.present
          ? data.oilTreatment.value
          : this.oilTreatment,
      sourceKey: data.sourceKey.present ? data.sourceKey.value : this.sourceKey,
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      reviewerId: data.reviewerId.present
          ? data.reviewerId.value
          : this.reviewerId,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRecipe(')
          ..write('releaseId: $releaseId, ')
          ..write('recipeId: $recipeId, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('nameRomanUrdu: $nameRomanUrdu, ')
          ..write('normalizedNameEnglish: $normalizedNameEnglish, ')
          ..write('normalizedNameRomanUrdu: $normalizedNameRomanUrdu, ')
          ..write('region: $region, ')
          ..write('preparationVariant: $preparationVariant, ')
          ..write('yieldServingsMinimum: $yieldServingsMinimum, ')
          ..write('yieldServingsMaximum: $yieldServingsMaximum, ')
          ..write('oilTreatment: $oilTreatment, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    releaseId,
    recipeId,
    nameEnglish,
    nameRomanUrdu,
    normalizedNameEnglish,
    normalizedNameRomanUrdu,
    region,
    preparationVariant,
    yieldServingsMinimum,
    yieldServingsMaximum,
    oilTreatment,
    sourceKey,
    sourceRecordId,
    reviewStatus,
    reviewerId,
    reviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRecipe &&
          other.releaseId == this.releaseId &&
          other.recipeId == this.recipeId &&
          other.nameEnglish == this.nameEnglish &&
          other.nameRomanUrdu == this.nameRomanUrdu &&
          other.normalizedNameEnglish == this.normalizedNameEnglish &&
          other.normalizedNameRomanUrdu == this.normalizedNameRomanUrdu &&
          other.region == this.region &&
          other.preparationVariant == this.preparationVariant &&
          other.yieldServingsMinimum == this.yieldServingsMinimum &&
          other.yieldServingsMaximum == this.yieldServingsMaximum &&
          other.oilTreatment == this.oilTreatment &&
          other.sourceKey == this.sourceKey &&
          other.sourceRecordId == this.sourceRecordId &&
          other.reviewStatus == this.reviewStatus &&
          other.reviewerId == this.reviewerId &&
          other.reviewedAt == this.reviewedAt);
}

class CatalogRecipesCompanion extends UpdateCompanion<CatalogRecipe> {
  final Value<String> releaseId;
  final Value<String> recipeId;
  final Value<String> nameEnglish;
  final Value<String> nameRomanUrdu;
  final Value<String> normalizedNameEnglish;
  final Value<String> normalizedNameRomanUrdu;
  final Value<String?> region;
  final Value<String?> preparationVariant;
  final Value<double> yieldServingsMinimum;
  final Value<double> yieldServingsMaximum;
  final Value<String> oilTreatment;
  final Value<String> sourceKey;
  final Value<String> sourceRecordId;
  final Value<String> reviewStatus;
  final Value<String?> reviewerId;
  final Value<DateTime?> reviewedAt;
  final Value<int> rowid;
  const CatalogRecipesCompanion({
    this.releaseId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.nameEnglish = const Value.absent(),
    this.nameRomanUrdu = const Value.absent(),
    this.normalizedNameEnglish = const Value.absent(),
    this.normalizedNameRomanUrdu = const Value.absent(),
    this.region = const Value.absent(),
    this.preparationVariant = const Value.absent(),
    this.yieldServingsMinimum = const Value.absent(),
    this.yieldServingsMaximum = const Value.absent(),
    this.oilTreatment = const Value.absent(),
    this.sourceKey = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.reviewerId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogRecipesCompanion.insert({
    required String releaseId,
    required String recipeId,
    required String nameEnglish,
    required String nameRomanUrdu,
    required String normalizedNameEnglish,
    required String normalizedNameRomanUrdu,
    this.region = const Value.absent(),
    this.preparationVariant = const Value.absent(),
    required double yieldServingsMinimum,
    required double yieldServingsMaximum,
    required String oilTreatment,
    required String sourceKey,
    required String sourceRecordId,
    required String reviewStatus,
    this.reviewerId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       recipeId = Value(recipeId),
       nameEnglish = Value(nameEnglish),
       nameRomanUrdu = Value(nameRomanUrdu),
       normalizedNameEnglish = Value(normalizedNameEnglish),
       normalizedNameRomanUrdu = Value(normalizedNameRomanUrdu),
       yieldServingsMinimum = Value(yieldServingsMinimum),
       yieldServingsMaximum = Value(yieldServingsMaximum),
       oilTreatment = Value(oilTreatment),
       sourceKey = Value(sourceKey),
       sourceRecordId = Value(sourceRecordId),
       reviewStatus = Value(reviewStatus);
  static Insertable<CatalogRecipe> custom({
    Expression<String>? releaseId,
    Expression<String>? recipeId,
    Expression<String>? nameEnglish,
    Expression<String>? nameRomanUrdu,
    Expression<String>? normalizedNameEnglish,
    Expression<String>? normalizedNameRomanUrdu,
    Expression<String>? region,
    Expression<String>? preparationVariant,
    Expression<double>? yieldServingsMinimum,
    Expression<double>? yieldServingsMaximum,
    Expression<String>? oilTreatment,
    Expression<String>? sourceKey,
    Expression<String>? sourceRecordId,
    Expression<String>? reviewStatus,
    Expression<String>? reviewerId,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (nameEnglish != null) 'name_english': nameEnglish,
      if (nameRomanUrdu != null) 'name_roman_urdu': nameRomanUrdu,
      if (normalizedNameEnglish != null)
        'normalized_name_english': normalizedNameEnglish,
      if (normalizedNameRomanUrdu != null)
        'normalized_name_roman_urdu': normalizedNameRomanUrdu,
      if (region != null) 'region': region,
      if (preparationVariant != null) 'preparation_variant': preparationVariant,
      if (yieldServingsMinimum != null)
        'yield_servings_minimum': yieldServingsMinimum,
      if (yieldServingsMaximum != null)
        'yield_servings_maximum': yieldServingsMaximum,
      if (oilTreatment != null) 'oil_treatment': oilTreatment,
      if (sourceKey != null) 'source_key': sourceKey,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (reviewerId != null) 'reviewer_id': reviewerId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogRecipesCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? recipeId,
    Value<String>? nameEnglish,
    Value<String>? nameRomanUrdu,
    Value<String>? normalizedNameEnglish,
    Value<String>? normalizedNameRomanUrdu,
    Value<String?>? region,
    Value<String?>? preparationVariant,
    Value<double>? yieldServingsMinimum,
    Value<double>? yieldServingsMaximum,
    Value<String>? oilTreatment,
    Value<String>? sourceKey,
    Value<String>? sourceRecordId,
    Value<String>? reviewStatus,
    Value<String?>? reviewerId,
    Value<DateTime?>? reviewedAt,
    Value<int>? rowid,
  }) {
    return CatalogRecipesCompanion(
      releaseId: releaseId ?? this.releaseId,
      recipeId: recipeId ?? this.recipeId,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameRomanUrdu: nameRomanUrdu ?? this.nameRomanUrdu,
      normalizedNameEnglish:
          normalizedNameEnglish ?? this.normalizedNameEnglish,
      normalizedNameRomanUrdu:
          normalizedNameRomanUrdu ?? this.normalizedNameRomanUrdu,
      region: region ?? this.region,
      preparationVariant: preparationVariant ?? this.preparationVariant,
      yieldServingsMinimum: yieldServingsMinimum ?? this.yieldServingsMinimum,
      yieldServingsMaximum: yieldServingsMaximum ?? this.yieldServingsMaximum,
      oilTreatment: oilTreatment ?? this.oilTreatment,
      sourceKey: sourceKey ?? this.sourceKey,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (nameEnglish.present) {
      map['name_english'] = Variable<String>(nameEnglish.value);
    }
    if (nameRomanUrdu.present) {
      map['name_roman_urdu'] = Variable<String>(nameRomanUrdu.value);
    }
    if (normalizedNameEnglish.present) {
      map['normalized_name_english'] = Variable<String>(
        normalizedNameEnglish.value,
      );
    }
    if (normalizedNameRomanUrdu.present) {
      map['normalized_name_roman_urdu'] = Variable<String>(
        normalizedNameRomanUrdu.value,
      );
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (preparationVariant.present) {
      map['preparation_variant'] = Variable<String>(preparationVariant.value);
    }
    if (yieldServingsMinimum.present) {
      map['yield_servings_minimum'] = Variable<double>(
        yieldServingsMinimum.value,
      );
    }
    if (yieldServingsMaximum.present) {
      map['yield_servings_maximum'] = Variable<double>(
        yieldServingsMaximum.value,
      );
    }
    if (oilTreatment.present) {
      map['oil_treatment'] = Variable<String>(oilTreatment.value);
    }
    if (sourceKey.present) {
      map['source_key'] = Variable<String>(sourceKey.value);
    }
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<String>(sourceRecordId.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (reviewerId.present) {
      map['reviewer_id'] = Variable<String>(reviewerId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRecipesCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('recipeId: $recipeId, ')
          ..write('nameEnglish: $nameEnglish, ')
          ..write('nameRomanUrdu: $nameRomanUrdu, ')
          ..write('normalizedNameEnglish: $normalizedNameEnglish, ')
          ..write('normalizedNameRomanUrdu: $normalizedNameRomanUrdu, ')
          ..write('region: $region, ')
          ..write('preparationVariant: $preparationVariant, ')
          ..write('yieldServingsMinimum: $yieldServingsMinimum, ')
          ..write('yieldServingsMaximum: $yieldServingsMaximum, ')
          ..write('oilTreatment: $oilTreatment, ')
          ..write('sourceKey: $sourceKey, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('reviewerId: $reviewerId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogRecipeSynonymsTable extends CatalogRecipeSynonyms
    with TableInfo<$CatalogRecipeSynonymsTable, CatalogRecipeSynonym> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogRecipeSynonymsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _synonymMeta = const VerificationMeta(
    'synonym',
  );
  @override
  late final GeneratedColumn<String> synonym = GeneratedColumn<String>(
    'synonym',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedSynonymMeta = const VerificationMeta(
    'normalizedSynonym',
  );
  @override
  late final GeneratedColumn<String> normalizedSynonym =
      GeneratedColumn<String>(
        'normalized_synonym',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    recipeId,
    locale,
    synonym,
    normalizedSynonym,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_recipe_synonyms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogRecipeSynonym> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('synonym')) {
      context.handle(
        _synonymMeta,
        synonym.isAcceptableOrUnknown(data['synonym']!, _synonymMeta),
      );
    } else if (isInserting) {
      context.missing(_synonymMeta);
    }
    if (data.containsKey('normalized_synonym')) {
      context.handle(
        _normalizedSynonymMeta,
        normalizedSynonym.isAcceptableOrUnknown(
          data['normalized_synonym']!,
          _normalizedSynonymMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedSynonymMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    releaseId,
    recipeId,
    locale,
    normalizedSynonym,
  };
  @override
  CatalogRecipeSynonym map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRecipeSynonym(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      synonym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synonym'],
      )!,
      normalizedSynonym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_synonym'],
      )!,
    );
  }

  @override
  $CatalogRecipeSynonymsTable createAlias(String alias) {
    return $CatalogRecipeSynonymsTable(attachedDatabase, alias);
  }
}

class CatalogRecipeSynonym extends DataClass
    implements Insertable<CatalogRecipeSynonym> {
  final String releaseId;
  final String recipeId;
  final String locale;
  final String synonym;
  final String normalizedSynonym;
  const CatalogRecipeSynonym({
    required this.releaseId,
    required this.recipeId,
    required this.locale,
    required this.synonym,
    required this.normalizedSynonym,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['recipe_id'] = Variable<String>(recipeId);
    map['locale'] = Variable<String>(locale);
    map['synonym'] = Variable<String>(synonym);
    map['normalized_synonym'] = Variable<String>(normalizedSynonym);
    return map;
  }

  CatalogRecipeSynonymsCompanion toCompanion(bool nullToAbsent) {
    return CatalogRecipeSynonymsCompanion(
      releaseId: Value(releaseId),
      recipeId: Value(recipeId),
      locale: Value(locale),
      synonym: Value(synonym),
      normalizedSynonym: Value(normalizedSynonym),
    );
  }

  factory CatalogRecipeSynonym.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRecipeSynonym(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      locale: serializer.fromJson<String>(json['locale']),
      synonym: serializer.fromJson<String>(json['synonym']),
      normalizedSynonym: serializer.fromJson<String>(json['normalizedSynonym']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'recipeId': serializer.toJson<String>(recipeId),
      'locale': serializer.toJson<String>(locale),
      'synonym': serializer.toJson<String>(synonym),
      'normalizedSynonym': serializer.toJson<String>(normalizedSynonym),
    };
  }

  CatalogRecipeSynonym copyWith({
    String? releaseId,
    String? recipeId,
    String? locale,
    String? synonym,
    String? normalizedSynonym,
  }) => CatalogRecipeSynonym(
    releaseId: releaseId ?? this.releaseId,
    recipeId: recipeId ?? this.recipeId,
    locale: locale ?? this.locale,
    synonym: synonym ?? this.synonym,
    normalizedSynonym: normalizedSynonym ?? this.normalizedSynonym,
  );
  CatalogRecipeSynonym copyWithCompanion(CatalogRecipeSynonymsCompanion data) {
    return CatalogRecipeSynonym(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      locale: data.locale.present ? data.locale.value : this.locale,
      synonym: data.synonym.present ? data.synonym.value : this.synonym,
      normalizedSynonym: data.normalizedSynonym.present
          ? data.normalizedSynonym.value
          : this.normalizedSynonym,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRecipeSynonym(')
          ..write('releaseId: $releaseId, ')
          ..write('recipeId: $recipeId, ')
          ..write('locale: $locale, ')
          ..write('synonym: $synonym, ')
          ..write('normalizedSynonym: $normalizedSynonym')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(releaseId, recipeId, locale, synonym, normalizedSynonym);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRecipeSynonym &&
          other.releaseId == this.releaseId &&
          other.recipeId == this.recipeId &&
          other.locale == this.locale &&
          other.synonym == this.synonym &&
          other.normalizedSynonym == this.normalizedSynonym);
}

class CatalogRecipeSynonymsCompanion
    extends UpdateCompanion<CatalogRecipeSynonym> {
  final Value<String> releaseId;
  final Value<String> recipeId;
  final Value<String> locale;
  final Value<String> synonym;
  final Value<String> normalizedSynonym;
  final Value<int> rowid;
  const CatalogRecipeSynonymsCompanion({
    this.releaseId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.locale = const Value.absent(),
    this.synonym = const Value.absent(),
    this.normalizedSynonym = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogRecipeSynonymsCompanion.insert({
    required String releaseId,
    required String recipeId,
    required String locale,
    required String synonym,
    required String normalizedSynonym,
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       recipeId = Value(recipeId),
       locale = Value(locale),
       synonym = Value(synonym),
       normalizedSynonym = Value(normalizedSynonym);
  static Insertable<CatalogRecipeSynonym> custom({
    Expression<String>? releaseId,
    Expression<String>? recipeId,
    Expression<String>? locale,
    Expression<String>? synonym,
    Expression<String>? normalizedSynonym,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (locale != null) 'locale': locale,
      if (synonym != null) 'synonym': synonym,
      if (normalizedSynonym != null) 'normalized_synonym': normalizedSynonym,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogRecipeSynonymsCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? recipeId,
    Value<String>? locale,
    Value<String>? synonym,
    Value<String>? normalizedSynonym,
    Value<int>? rowid,
  }) {
    return CatalogRecipeSynonymsCompanion(
      releaseId: releaseId ?? this.releaseId,
      recipeId: recipeId ?? this.recipeId,
      locale: locale ?? this.locale,
      synonym: synonym ?? this.synonym,
      normalizedSynonym: normalizedSynonym ?? this.normalizedSynonym,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (synonym.present) {
      map['synonym'] = Variable<String>(synonym.value);
    }
    if (normalizedSynonym.present) {
      map['normalized_synonym'] = Variable<String>(normalizedSynonym.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRecipeSynonymsCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('recipeId: $recipeId, ')
          ..write('locale: $locale, ')
          ..write('synonym: $synonym, ')
          ..write('normalizedSynonym: $normalizedSynonym, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogRecipeIngredientsTable extends CatalogRecipeIngredients
    with TableInfo<$CatalogRecipeIngredientsTable, CatalogRecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogRecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIndexMeta = const VerificationMeta(
    'ingredientIndex',
  );
  @override
  late final GeneratedColumn<int> ingredientIndex = GeneratedColumn<int>(
    'ingredient_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingIdMeta = const VerificationMeta(
    'servingId',
  );
  @override
  late final GeneratedColumn<String> servingId = GeneratedColumn<String>(
    'serving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exactGramsPerServingMeta =
      const VerificationMeta('exactGramsPerServing');
  @override
  late final GeneratedColumn<double> exactGramsPerServing =
      GeneratedColumn<double>(
        'exact_grams_per_serving',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    releaseId,
    recipeId,
    ingredientIndex,
    foodId,
    servingId,
    quantity,
    exactGramsPerServing,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogRecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('ingredient_index')) {
      context.handle(
        _ingredientIndexMeta,
        ingredientIndex.isAcceptableOrUnknown(
          data['ingredient_index']!,
          _ingredientIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIndexMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('serving_id')) {
      context.handle(
        _servingIdMeta,
        servingId.isAcceptableOrUnknown(data['serving_id']!, _servingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_servingIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('exact_grams_per_serving')) {
      context.handle(
        _exactGramsPerServingMeta,
        exactGramsPerServing.isAcceptableOrUnknown(
          data['exact_grams_per_serving']!,
          _exactGramsPerServingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    releaseId,
    recipeId,
    ingredientIndex,
  };
  @override
  CatalogRecipeIngredient map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogRecipeIngredient(
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      ingredientIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_index'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      servingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      exactGramsPerServing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exact_grams_per_serving'],
      ),
    );
  }

  @override
  $CatalogRecipeIngredientsTable createAlias(String alias) {
    return $CatalogRecipeIngredientsTable(attachedDatabase, alias);
  }
}

class CatalogRecipeIngredient extends DataClass
    implements Insertable<CatalogRecipeIngredient> {
  final String releaseId;
  final String recipeId;
  final int ingredientIndex;
  final String foodId;
  final String servingId;
  final double quantity;
  final double? exactGramsPerServing;
  const CatalogRecipeIngredient({
    required this.releaseId,
    required this.recipeId,
    required this.ingredientIndex,
    required this.foodId,
    required this.servingId,
    required this.quantity,
    this.exactGramsPerServing,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['release_id'] = Variable<String>(releaseId);
    map['recipe_id'] = Variable<String>(recipeId);
    map['ingredient_index'] = Variable<int>(ingredientIndex);
    map['food_id'] = Variable<String>(foodId);
    map['serving_id'] = Variable<String>(servingId);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || exactGramsPerServing != null) {
      map['exact_grams_per_serving'] = Variable<double>(exactGramsPerServing);
    }
    return map;
  }

  CatalogRecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return CatalogRecipeIngredientsCompanion(
      releaseId: Value(releaseId),
      recipeId: Value(recipeId),
      ingredientIndex: Value(ingredientIndex),
      foodId: Value(foodId),
      servingId: Value(servingId),
      quantity: Value(quantity),
      exactGramsPerServing: exactGramsPerServing == null && nullToAbsent
          ? const Value.absent()
          : Value(exactGramsPerServing),
    );
  }

  factory CatalogRecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogRecipeIngredient(
      releaseId: serializer.fromJson<String>(json['releaseId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      ingredientIndex: serializer.fromJson<int>(json['ingredientIndex']),
      foodId: serializer.fromJson<String>(json['foodId']),
      servingId: serializer.fromJson<String>(json['servingId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      exactGramsPerServing: serializer.fromJson<double?>(
        json['exactGramsPerServing'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'releaseId': serializer.toJson<String>(releaseId),
      'recipeId': serializer.toJson<String>(recipeId),
      'ingredientIndex': serializer.toJson<int>(ingredientIndex),
      'foodId': serializer.toJson<String>(foodId),
      'servingId': serializer.toJson<String>(servingId),
      'quantity': serializer.toJson<double>(quantity),
      'exactGramsPerServing': serializer.toJson<double?>(exactGramsPerServing),
    };
  }

  CatalogRecipeIngredient copyWith({
    String? releaseId,
    String? recipeId,
    int? ingredientIndex,
    String? foodId,
    String? servingId,
    double? quantity,
    Value<double?> exactGramsPerServing = const Value.absent(),
  }) => CatalogRecipeIngredient(
    releaseId: releaseId ?? this.releaseId,
    recipeId: recipeId ?? this.recipeId,
    ingredientIndex: ingredientIndex ?? this.ingredientIndex,
    foodId: foodId ?? this.foodId,
    servingId: servingId ?? this.servingId,
    quantity: quantity ?? this.quantity,
    exactGramsPerServing: exactGramsPerServing.present
        ? exactGramsPerServing.value
        : this.exactGramsPerServing,
  );
  CatalogRecipeIngredient copyWithCompanion(
    CatalogRecipeIngredientsCompanion data,
  ) {
    return CatalogRecipeIngredient(
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      ingredientIndex: data.ingredientIndex.present
          ? data.ingredientIndex.value
          : this.ingredientIndex,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      servingId: data.servingId.present ? data.servingId.value : this.servingId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      exactGramsPerServing: data.exactGramsPerServing.present
          ? data.exactGramsPerServing.value
          : this.exactGramsPerServing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRecipeIngredient(')
          ..write('releaseId: $releaseId, ')
          ..write('recipeId: $recipeId, ')
          ..write('ingredientIndex: $ingredientIndex, ')
          ..write('foodId: $foodId, ')
          ..write('servingId: $servingId, ')
          ..write('quantity: $quantity, ')
          ..write('exactGramsPerServing: $exactGramsPerServing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    releaseId,
    recipeId,
    ingredientIndex,
    foodId,
    servingId,
    quantity,
    exactGramsPerServing,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogRecipeIngredient &&
          other.releaseId == this.releaseId &&
          other.recipeId == this.recipeId &&
          other.ingredientIndex == this.ingredientIndex &&
          other.foodId == this.foodId &&
          other.servingId == this.servingId &&
          other.quantity == this.quantity &&
          other.exactGramsPerServing == this.exactGramsPerServing);
}

class CatalogRecipeIngredientsCompanion
    extends UpdateCompanion<CatalogRecipeIngredient> {
  final Value<String> releaseId;
  final Value<String> recipeId;
  final Value<int> ingredientIndex;
  final Value<String> foodId;
  final Value<String> servingId;
  final Value<double> quantity;
  final Value<double?> exactGramsPerServing;
  final Value<int> rowid;
  const CatalogRecipeIngredientsCompanion({
    this.releaseId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.ingredientIndex = const Value.absent(),
    this.foodId = const Value.absent(),
    this.servingId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.exactGramsPerServing = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogRecipeIngredientsCompanion.insert({
    required String releaseId,
    required String recipeId,
    required int ingredientIndex,
    required String foodId,
    required String servingId,
    required double quantity,
    this.exactGramsPerServing = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : releaseId = Value(releaseId),
       recipeId = Value(recipeId),
       ingredientIndex = Value(ingredientIndex),
       foodId = Value(foodId),
       servingId = Value(servingId),
       quantity = Value(quantity);
  static Insertable<CatalogRecipeIngredient> custom({
    Expression<String>? releaseId,
    Expression<String>? recipeId,
    Expression<int>? ingredientIndex,
    Expression<String>? foodId,
    Expression<String>? servingId,
    Expression<double>? quantity,
    Expression<double>? exactGramsPerServing,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (releaseId != null) 'release_id': releaseId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (ingredientIndex != null) 'ingredient_index': ingredientIndex,
      if (foodId != null) 'food_id': foodId,
      if (servingId != null) 'serving_id': servingId,
      if (quantity != null) 'quantity': quantity,
      if (exactGramsPerServing != null)
        'exact_grams_per_serving': exactGramsPerServing,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogRecipeIngredientsCompanion copyWith({
    Value<String>? releaseId,
    Value<String>? recipeId,
    Value<int>? ingredientIndex,
    Value<String>? foodId,
    Value<String>? servingId,
    Value<double>? quantity,
    Value<double?>? exactGramsPerServing,
    Value<int>? rowid,
  }) {
    return CatalogRecipeIngredientsCompanion(
      releaseId: releaseId ?? this.releaseId,
      recipeId: recipeId ?? this.recipeId,
      ingredientIndex: ingredientIndex ?? this.ingredientIndex,
      foodId: foodId ?? this.foodId,
      servingId: servingId ?? this.servingId,
      quantity: quantity ?? this.quantity,
      exactGramsPerServing: exactGramsPerServing ?? this.exactGramsPerServing,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (ingredientIndex.present) {
      map['ingredient_index'] = Variable<int>(ingredientIndex.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (servingId.present) {
      map['serving_id'] = Variable<String>(servingId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (exactGramsPerServing.present) {
      map['exact_grams_per_serving'] = Variable<double>(
        exactGramsPerServing.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogRecipeIngredientsCompanion(')
          ..write('releaseId: $releaseId, ')
          ..write('recipeId: $recipeId, ')
          ..write('ingredientIndex: $ingredientIndex, ')
          ..write('foodId: $foodId, ')
          ..write('servingId: $servingId, ')
          ..write('quantity: $quantity, ')
          ..write('exactGramsPerServing: $exactGramsPerServing, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealEventsTable extends MealEvents
    with TableInfo<$MealEventsTable, MealEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawUserInputMeta = const VerificationMeta(
    'rawUserInput',
  );
  @override
  late final GeneratedColumn<String> rawUserInput = GeneratedColumn<String>(
    'raw_user_input',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aiProvenanceJsonMeta = const VerificationMeta(
    'aiProvenanceJson',
  );
  @override
  late final GeneratedColumn<String> aiProvenanceJson = GeneratedColumn<String>(
    'ai_provenance_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersedesEventIdMeta = const VerificationMeta(
    'supersedesEventId',
  );
  @override
  late final GeneratedColumn<String> supersedesEventId =
      GeneratedColumn<String>(
        'supersedes_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculationVersionMeta =
      const VerificationMeta('calculationVersion');
  @override
  late final GeneratedColumn<String> calculationVersion =
      GeneratedColumn<String>(
        'calculation_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _caloriesMinimumMeta = const VerificationMeta(
    'caloriesMinimum',
  );
  @override
  late final GeneratedColumn<double> caloriesMinimum = GeneratedColumn<double>(
    'calories_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMaximumMeta = const VerificationMeta(
    'caloriesMaximum',
  );
  @override
  late final GeneratedColumn<double> caloriesMaximum = GeneratedColumn<double>(
    'calories_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMinimumMeta = const VerificationMeta(
    'proteinMinimum',
  );
  @override
  late final GeneratedColumn<double> proteinMinimum = GeneratedColumn<double>(
    'protein_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMaximumMeta = const VerificationMeta(
    'proteinMaximum',
  );
  @override
  late final GeneratedColumn<double> proteinMaximum = GeneratedColumn<double>(
    'protein_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbohydrateMinimumMeta =
      const VerificationMeta('carbohydrateMinimum');
  @override
  late final GeneratedColumn<double> carbohydrateMinimum =
      GeneratedColumn<double>(
        'carbohydrate_minimum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _carbohydrateMaximumMeta =
      const VerificationMeta('carbohydrateMaximum');
  @override
  late final GeneratedColumn<double> carbohydrateMaximum =
      GeneratedColumn<double>(
        'carbohydrate_maximum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fatMinimumMeta = const VerificationMeta(
    'fatMinimum',
  );
  @override
  late final GeneratedColumn<double> fatMinimum = GeneratedColumn<double>(
    'fat_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMaximumMeta = const VerificationMeta(
    'fatMaximum',
  );
  @override
  late final GeneratedColumn<double> fatMaximum = GeneratedColumn<double>(
    'fat_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMinimumMeta = const VerificationMeta(
    'sodiumMinimum',
  );
  @override
  late final GeneratedColumn<double> sodiumMinimum = GeneratedColumn<double>(
    'sodium_minimum',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMaximumMeta = const VerificationMeta(
    'sodiumMaximum',
  );
  @override
  late final GeneratedColumn<double> sodiumMaximum = GeneratedColumn<double>(
    'sodium_maximum',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    eventId,
    mealType,
    occurredAtUtc,
    timezoneOffsetMinutes,
    createdAtUtc,
    rawUserInput,
    aiProvenanceJson,
    supersedesEventId,
    revision,
    calculationVersion,
    caloriesMinimum,
    caloriesMaximum,
    proteinMinimum,
    proteinMaximum,
    carbohydrateMinimum,
    carbohydrateMaximum,
    fatMinimum,
    fatMaximum,
    sodiumMinimum,
    sodiumMaximum,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('raw_user_input')) {
      context.handle(
        _rawUserInputMeta,
        rawUserInput.isAcceptableOrUnknown(
          data['raw_user_input']!,
          _rawUserInputMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawUserInputMeta);
    }
    if (data.containsKey('ai_provenance_json')) {
      context.handle(
        _aiProvenanceJsonMeta,
        aiProvenanceJson.isAcceptableOrUnknown(
          data['ai_provenance_json']!,
          _aiProvenanceJsonMeta,
        ),
      );
    }
    if (data.containsKey('supersedes_event_id')) {
      context.handle(
        _supersedesEventIdMeta,
        supersedesEventId.isAcceptableOrUnknown(
          data['supersedes_event_id']!,
          _supersedesEventIdMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('calculation_version')) {
      context.handle(
        _calculationVersionMeta,
        calculationVersion.isAcceptableOrUnknown(
          data['calculation_version']!,
          _calculationVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculationVersionMeta);
    }
    if (data.containsKey('calories_minimum')) {
      context.handle(
        _caloriesMinimumMeta,
        caloriesMinimum.isAcceptableOrUnknown(
          data['calories_minimum']!,
          _caloriesMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesMinimumMeta);
    }
    if (data.containsKey('calories_maximum')) {
      context.handle(
        _caloriesMaximumMeta,
        caloriesMaximum.isAcceptableOrUnknown(
          data['calories_maximum']!,
          _caloriesMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesMaximumMeta);
    }
    if (data.containsKey('protein_minimum')) {
      context.handle(
        _proteinMinimumMeta,
        proteinMinimum.isAcceptableOrUnknown(
          data['protein_minimum']!,
          _proteinMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinMinimumMeta);
    }
    if (data.containsKey('protein_maximum')) {
      context.handle(
        _proteinMaximumMeta,
        proteinMaximum.isAcceptableOrUnknown(
          data['protein_maximum']!,
          _proteinMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinMaximumMeta);
    }
    if (data.containsKey('carbohydrate_minimum')) {
      context.handle(
        _carbohydrateMinimumMeta,
        carbohydrateMinimum.isAcceptableOrUnknown(
          data['carbohydrate_minimum']!,
          _carbohydrateMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateMinimumMeta);
    }
    if (data.containsKey('carbohydrate_maximum')) {
      context.handle(
        _carbohydrateMaximumMeta,
        carbohydrateMaximum.isAcceptableOrUnknown(
          data['carbohydrate_maximum']!,
          _carbohydrateMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateMaximumMeta);
    }
    if (data.containsKey('fat_minimum')) {
      context.handle(
        _fatMinimumMeta,
        fatMinimum.isAcceptableOrUnknown(data['fat_minimum']!, _fatMinimumMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMinimumMeta);
    }
    if (data.containsKey('fat_maximum')) {
      context.handle(
        _fatMaximumMeta,
        fatMaximum.isAcceptableOrUnknown(data['fat_maximum']!, _fatMaximumMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMaximumMeta);
    }
    if (data.containsKey('sodium_minimum')) {
      context.handle(
        _sodiumMinimumMeta,
        sodiumMinimum.isAcceptableOrUnknown(
          data['sodium_minimum']!,
          _sodiumMinimumMeta,
        ),
      );
    }
    if (data.containsKey('sodium_maximum')) {
      context.handle(
        _sodiumMaximumMeta,
        sodiumMaximum.isAcceptableOrUnknown(
          data['sodium_maximum']!,
          _sodiumMaximumMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, eventId};
  @override
  MealEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEvent(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      rawUserInput: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_user_input'],
      )!,
      aiProvenanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_provenance_json'],
      ),
      supersedesEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_event_id'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      calculationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_version'],
      )!,
      caloriesMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_minimum'],
      )!,
      caloriesMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_maximum'],
      )!,
      proteinMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_minimum'],
      )!,
      proteinMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_maximum'],
      )!,
      carbohydrateMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_minimum'],
      )!,
      carbohydrateMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_maximum'],
      )!,
      fatMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_minimum'],
      )!,
      fatMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_maximum'],
      )!,
      sodiumMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_minimum'],
      ),
      sodiumMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_maximum'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $MealEventsTable createAlias(String alias) {
    return $MealEventsTable(attachedDatabase, alias);
  }
}

class MealEvent extends DataClass implements Insertable<MealEvent> {
  final String ownerId;
  final String eventId;
  final String mealType;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime createdAtUtc;
  final String rawUserInput;
  final String? aiProvenanceJson;
  final String? supersedesEventId;
  final int revision;
  final String calculationVersion;
  final double caloriesMinimum;
  final double caloriesMaximum;
  final double proteinMinimum;
  final double proteinMaximum;
  final double carbohydrateMinimum;
  final double carbohydrateMaximum;
  final double fatMinimum;
  final double fatMaximum;
  final double? sodiumMinimum;
  final double? sodiumMaximum;
  final bool isDeleted;
  const MealEvent({
    required this.ownerId,
    required this.eventId,
    required this.mealType,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.createdAtUtc,
    required this.rawUserInput,
    this.aiProvenanceJson,
    this.supersedesEventId,
    required this.revision,
    required this.calculationVersion,
    required this.caloriesMinimum,
    required this.caloriesMaximum,
    required this.proteinMinimum,
    required this.proteinMaximum,
    required this.carbohydrateMinimum,
    required this.carbohydrateMaximum,
    required this.fatMinimum,
    required this.fatMaximum,
    this.sodiumMinimum,
    this.sodiumMaximum,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['event_id'] = Variable<String>(eventId);
    map['meal_type'] = Variable<String>(mealType);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['raw_user_input'] = Variable<String>(rawUserInput);
    if (!nullToAbsent || aiProvenanceJson != null) {
      map['ai_provenance_json'] = Variable<String>(aiProvenanceJson);
    }
    if (!nullToAbsent || supersedesEventId != null) {
      map['supersedes_event_id'] = Variable<String>(supersedesEventId);
    }
    map['revision'] = Variable<int>(revision);
    map['calculation_version'] = Variable<String>(calculationVersion);
    map['calories_minimum'] = Variable<double>(caloriesMinimum);
    map['calories_maximum'] = Variable<double>(caloriesMaximum);
    map['protein_minimum'] = Variable<double>(proteinMinimum);
    map['protein_maximum'] = Variable<double>(proteinMaximum);
    map['carbohydrate_minimum'] = Variable<double>(carbohydrateMinimum);
    map['carbohydrate_maximum'] = Variable<double>(carbohydrateMaximum);
    map['fat_minimum'] = Variable<double>(fatMinimum);
    map['fat_maximum'] = Variable<double>(fatMaximum);
    if (!nullToAbsent || sodiumMinimum != null) {
      map['sodium_minimum'] = Variable<double>(sodiumMinimum);
    }
    if (!nullToAbsent || sodiumMaximum != null) {
      map['sodium_maximum'] = Variable<double>(sodiumMaximum);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  MealEventsCompanion toCompanion(bool nullToAbsent) {
    return MealEventsCompanion(
      ownerId: Value(ownerId),
      eventId: Value(eventId),
      mealType: Value(mealType),
      occurredAtUtc: Value(occurredAtUtc),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      createdAtUtc: Value(createdAtUtc),
      rawUserInput: Value(rawUserInput),
      aiProvenanceJson: aiProvenanceJson == null && nullToAbsent
          ? const Value.absent()
          : Value(aiProvenanceJson),
      supersedesEventId: supersedesEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesEventId),
      revision: Value(revision),
      calculationVersion: Value(calculationVersion),
      caloriesMinimum: Value(caloriesMinimum),
      caloriesMaximum: Value(caloriesMaximum),
      proteinMinimum: Value(proteinMinimum),
      proteinMaximum: Value(proteinMaximum),
      carbohydrateMinimum: Value(carbohydrateMinimum),
      carbohydrateMaximum: Value(carbohydrateMaximum),
      fatMinimum: Value(fatMinimum),
      fatMaximum: Value(fatMaximum),
      sodiumMinimum: sodiumMinimum == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMinimum),
      sodiumMaximum: sodiumMaximum == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMaximum),
      isDeleted: Value(isDeleted),
    );
  }

  factory MealEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEvent(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      mealType: serializer.fromJson<String>(json['mealType']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      rawUserInput: serializer.fromJson<String>(json['rawUserInput']),
      aiProvenanceJson: serializer.fromJson<String?>(json['aiProvenanceJson']),
      supersedesEventId: serializer.fromJson<String?>(
        json['supersedesEventId'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      calculationVersion: serializer.fromJson<String>(
        json['calculationVersion'],
      ),
      caloriesMinimum: serializer.fromJson<double>(json['caloriesMinimum']),
      caloriesMaximum: serializer.fromJson<double>(json['caloriesMaximum']),
      proteinMinimum: serializer.fromJson<double>(json['proteinMinimum']),
      proteinMaximum: serializer.fromJson<double>(json['proteinMaximum']),
      carbohydrateMinimum: serializer.fromJson<double>(
        json['carbohydrateMinimum'],
      ),
      carbohydrateMaximum: serializer.fromJson<double>(
        json['carbohydrateMaximum'],
      ),
      fatMinimum: serializer.fromJson<double>(json['fatMinimum']),
      fatMaximum: serializer.fromJson<double>(json['fatMaximum']),
      sodiumMinimum: serializer.fromJson<double?>(json['sodiumMinimum']),
      sodiumMaximum: serializer.fromJson<double?>(json['sodiumMaximum']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'eventId': serializer.toJson<String>(eventId),
      'mealType': serializer.toJson<String>(mealType),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'rawUserInput': serializer.toJson<String>(rawUserInput),
      'aiProvenanceJson': serializer.toJson<String?>(aiProvenanceJson),
      'supersedesEventId': serializer.toJson<String?>(supersedesEventId),
      'revision': serializer.toJson<int>(revision),
      'calculationVersion': serializer.toJson<String>(calculationVersion),
      'caloriesMinimum': serializer.toJson<double>(caloriesMinimum),
      'caloriesMaximum': serializer.toJson<double>(caloriesMaximum),
      'proteinMinimum': serializer.toJson<double>(proteinMinimum),
      'proteinMaximum': serializer.toJson<double>(proteinMaximum),
      'carbohydrateMinimum': serializer.toJson<double>(carbohydrateMinimum),
      'carbohydrateMaximum': serializer.toJson<double>(carbohydrateMaximum),
      'fatMinimum': serializer.toJson<double>(fatMinimum),
      'fatMaximum': serializer.toJson<double>(fatMaximum),
      'sodiumMinimum': serializer.toJson<double?>(sodiumMinimum),
      'sodiumMaximum': serializer.toJson<double?>(sodiumMaximum),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  MealEvent copyWith({
    String? ownerId,
    String? eventId,
    String? mealType,
    DateTime? occurredAtUtc,
    int? timezoneOffsetMinutes,
    DateTime? createdAtUtc,
    String? rawUserInput,
    Value<String?> aiProvenanceJson = const Value.absent(),
    Value<String?> supersedesEventId = const Value.absent(),
    int? revision,
    String? calculationVersion,
    double? caloriesMinimum,
    double? caloriesMaximum,
    double? proteinMinimum,
    double? proteinMaximum,
    double? carbohydrateMinimum,
    double? carbohydrateMaximum,
    double? fatMinimum,
    double? fatMaximum,
    Value<double?> sodiumMinimum = const Value.absent(),
    Value<double?> sodiumMaximum = const Value.absent(),
    bool? isDeleted,
  }) => MealEvent(
    ownerId: ownerId ?? this.ownerId,
    eventId: eventId ?? this.eventId,
    mealType: mealType ?? this.mealType,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    rawUserInput: rawUserInput ?? this.rawUserInput,
    aiProvenanceJson: aiProvenanceJson.present
        ? aiProvenanceJson.value
        : this.aiProvenanceJson,
    supersedesEventId: supersedesEventId.present
        ? supersedesEventId.value
        : this.supersedesEventId,
    revision: revision ?? this.revision,
    calculationVersion: calculationVersion ?? this.calculationVersion,
    caloriesMinimum: caloriesMinimum ?? this.caloriesMinimum,
    caloriesMaximum: caloriesMaximum ?? this.caloriesMaximum,
    proteinMinimum: proteinMinimum ?? this.proteinMinimum,
    proteinMaximum: proteinMaximum ?? this.proteinMaximum,
    carbohydrateMinimum: carbohydrateMinimum ?? this.carbohydrateMinimum,
    carbohydrateMaximum: carbohydrateMaximum ?? this.carbohydrateMaximum,
    fatMinimum: fatMinimum ?? this.fatMinimum,
    fatMaximum: fatMaximum ?? this.fatMaximum,
    sodiumMinimum: sodiumMinimum.present
        ? sodiumMinimum.value
        : this.sodiumMinimum,
    sodiumMaximum: sodiumMaximum.present
        ? sodiumMaximum.value
        : this.sodiumMaximum,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  MealEvent copyWithCompanion(MealEventsCompanion data) {
    return MealEvent(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      rawUserInput: data.rawUserInput.present
          ? data.rawUserInput.value
          : this.rawUserInput,
      aiProvenanceJson: data.aiProvenanceJson.present
          ? data.aiProvenanceJson.value
          : this.aiProvenanceJson,
      supersedesEventId: data.supersedesEventId.present
          ? data.supersedesEventId.value
          : this.supersedesEventId,
      revision: data.revision.present ? data.revision.value : this.revision,
      calculationVersion: data.calculationVersion.present
          ? data.calculationVersion.value
          : this.calculationVersion,
      caloriesMinimum: data.caloriesMinimum.present
          ? data.caloriesMinimum.value
          : this.caloriesMinimum,
      caloriesMaximum: data.caloriesMaximum.present
          ? data.caloriesMaximum.value
          : this.caloriesMaximum,
      proteinMinimum: data.proteinMinimum.present
          ? data.proteinMinimum.value
          : this.proteinMinimum,
      proteinMaximum: data.proteinMaximum.present
          ? data.proteinMaximum.value
          : this.proteinMaximum,
      carbohydrateMinimum: data.carbohydrateMinimum.present
          ? data.carbohydrateMinimum.value
          : this.carbohydrateMinimum,
      carbohydrateMaximum: data.carbohydrateMaximum.present
          ? data.carbohydrateMaximum.value
          : this.carbohydrateMaximum,
      fatMinimum: data.fatMinimum.present
          ? data.fatMinimum.value
          : this.fatMinimum,
      fatMaximum: data.fatMaximum.present
          ? data.fatMaximum.value
          : this.fatMaximum,
      sodiumMinimum: data.sodiumMinimum.present
          ? data.sodiumMinimum.value
          : this.sodiumMinimum,
      sodiumMaximum: data.sodiumMaximum.present
          ? data.sodiumMaximum.value
          : this.sodiumMaximum,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealEvent(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('mealType: $mealType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rawUserInput: $rawUserInput, ')
          ..write('aiProvenanceJson: $aiProvenanceJson, ')
          ..write('supersedesEventId: $supersedesEventId, ')
          ..write('revision: $revision, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('caloriesMinimum: $caloriesMinimum, ')
          ..write('caloriesMaximum: $caloriesMaximum, ')
          ..write('proteinMinimum: $proteinMinimum, ')
          ..write('proteinMaximum: $proteinMaximum, ')
          ..write('carbohydrateMinimum: $carbohydrateMinimum, ')
          ..write('carbohydrateMaximum: $carbohydrateMaximum, ')
          ..write('fatMinimum: $fatMinimum, ')
          ..write('fatMaximum: $fatMaximum, ')
          ..write('sodiumMinimum: $sodiumMinimum, ')
          ..write('sodiumMaximum: $sodiumMaximum, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ownerId,
    eventId,
    mealType,
    occurredAtUtc,
    timezoneOffsetMinutes,
    createdAtUtc,
    rawUserInput,
    aiProvenanceJson,
    supersedesEventId,
    revision,
    calculationVersion,
    caloriesMinimum,
    caloriesMaximum,
    proteinMinimum,
    proteinMaximum,
    carbohydrateMinimum,
    carbohydrateMaximum,
    fatMinimum,
    fatMaximum,
    sodiumMinimum,
    sodiumMaximum,
    isDeleted,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEvent &&
          other.ownerId == this.ownerId &&
          other.eventId == this.eventId &&
          other.mealType == this.mealType &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.rawUserInput == this.rawUserInput &&
          other.aiProvenanceJson == this.aiProvenanceJson &&
          other.supersedesEventId == this.supersedesEventId &&
          other.revision == this.revision &&
          other.calculationVersion == this.calculationVersion &&
          other.caloriesMinimum == this.caloriesMinimum &&
          other.caloriesMaximum == this.caloriesMaximum &&
          other.proteinMinimum == this.proteinMinimum &&
          other.proteinMaximum == this.proteinMaximum &&
          other.carbohydrateMinimum == this.carbohydrateMinimum &&
          other.carbohydrateMaximum == this.carbohydrateMaximum &&
          other.fatMinimum == this.fatMinimum &&
          other.fatMaximum == this.fatMaximum &&
          other.sodiumMinimum == this.sodiumMinimum &&
          other.sodiumMaximum == this.sodiumMaximum &&
          other.isDeleted == this.isDeleted);
}

class MealEventsCompanion extends UpdateCompanion<MealEvent> {
  final Value<String> ownerId;
  final Value<String> eventId;
  final Value<String> mealType;
  final Value<DateTime> occurredAtUtc;
  final Value<int> timezoneOffsetMinutes;
  final Value<DateTime> createdAtUtc;
  final Value<String> rawUserInput;
  final Value<String?> aiProvenanceJson;
  final Value<String?> supersedesEventId;
  final Value<int> revision;
  final Value<String> calculationVersion;
  final Value<double> caloriesMinimum;
  final Value<double> caloriesMaximum;
  final Value<double> proteinMinimum;
  final Value<double> proteinMaximum;
  final Value<double> carbohydrateMinimum;
  final Value<double> carbohydrateMaximum;
  final Value<double> fatMinimum;
  final Value<double> fatMaximum;
  final Value<double?> sodiumMinimum;
  final Value<double?> sodiumMaximum;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const MealEventsCompanion({
    this.ownerId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.mealType = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rawUserInput = const Value.absent(),
    this.aiProvenanceJson = const Value.absent(),
    this.supersedesEventId = const Value.absent(),
    this.revision = const Value.absent(),
    this.calculationVersion = const Value.absent(),
    this.caloriesMinimum = const Value.absent(),
    this.caloriesMaximum = const Value.absent(),
    this.proteinMinimum = const Value.absent(),
    this.proteinMaximum = const Value.absent(),
    this.carbohydrateMinimum = const Value.absent(),
    this.carbohydrateMaximum = const Value.absent(),
    this.fatMinimum = const Value.absent(),
    this.fatMaximum = const Value.absent(),
    this.sodiumMinimum = const Value.absent(),
    this.sodiumMaximum = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealEventsCompanion.insert({
    required String ownerId,
    required String eventId,
    required String mealType,
    required DateTime occurredAtUtc,
    required int timezoneOffsetMinutes,
    required DateTime createdAtUtc,
    required String rawUserInput,
    this.aiProvenanceJson = const Value.absent(),
    this.supersedesEventId = const Value.absent(),
    required int revision,
    required String calculationVersion,
    required double caloriesMinimum,
    required double caloriesMaximum,
    required double proteinMinimum,
    required double proteinMaximum,
    required double carbohydrateMinimum,
    required double carbohydrateMaximum,
    required double fatMinimum,
    required double fatMaximum,
    this.sodiumMinimum = const Value.absent(),
    this.sodiumMaximum = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       eventId = Value(eventId),
       mealType = Value(mealType),
       occurredAtUtc = Value(occurredAtUtc),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes),
       createdAtUtc = Value(createdAtUtc),
       rawUserInput = Value(rawUserInput),
       revision = Value(revision),
       calculationVersion = Value(calculationVersion),
       caloriesMinimum = Value(caloriesMinimum),
       caloriesMaximum = Value(caloriesMaximum),
       proteinMinimum = Value(proteinMinimum),
       proteinMaximum = Value(proteinMaximum),
       carbohydrateMinimum = Value(carbohydrateMinimum),
       carbohydrateMaximum = Value(carbohydrateMaximum),
       fatMinimum = Value(fatMinimum),
       fatMaximum = Value(fatMaximum);
  static Insertable<MealEvent> custom({
    Expression<String>? ownerId,
    Expression<String>? eventId,
    Expression<String>? mealType,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? timezoneOffsetMinutes,
    Expression<DateTime>? createdAtUtc,
    Expression<String>? rawUserInput,
    Expression<String>? aiProvenanceJson,
    Expression<String>? supersedesEventId,
    Expression<int>? revision,
    Expression<String>? calculationVersion,
    Expression<double>? caloriesMinimum,
    Expression<double>? caloriesMaximum,
    Expression<double>? proteinMinimum,
    Expression<double>? proteinMaximum,
    Expression<double>? carbohydrateMinimum,
    Expression<double>? carbohydrateMaximum,
    Expression<double>? fatMinimum,
    Expression<double>? fatMaximum,
    Expression<double>? sodiumMinimum,
    Expression<double>? sodiumMaximum,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (eventId != null) 'event_id': eventId,
      if (mealType != null) 'meal_type': mealType,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rawUserInput != null) 'raw_user_input': rawUserInput,
      if (aiProvenanceJson != null) 'ai_provenance_json': aiProvenanceJson,
      if (supersedesEventId != null) 'supersedes_event_id': supersedesEventId,
      if (revision != null) 'revision': revision,
      if (calculationVersion != null) 'calculation_version': calculationVersion,
      if (caloriesMinimum != null) 'calories_minimum': caloriesMinimum,
      if (caloriesMaximum != null) 'calories_maximum': caloriesMaximum,
      if (proteinMinimum != null) 'protein_minimum': proteinMinimum,
      if (proteinMaximum != null) 'protein_maximum': proteinMaximum,
      if (carbohydrateMinimum != null)
        'carbohydrate_minimum': carbohydrateMinimum,
      if (carbohydrateMaximum != null)
        'carbohydrate_maximum': carbohydrateMaximum,
      if (fatMinimum != null) 'fat_minimum': fatMinimum,
      if (fatMaximum != null) 'fat_maximum': fatMaximum,
      if (sodiumMinimum != null) 'sodium_minimum': sodiumMinimum,
      if (sodiumMaximum != null) 'sodium_maximum': sodiumMaximum,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealEventsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? eventId,
    Value<String>? mealType,
    Value<DateTime>? occurredAtUtc,
    Value<int>? timezoneOffsetMinutes,
    Value<DateTime>? createdAtUtc,
    Value<String>? rawUserInput,
    Value<String?>? aiProvenanceJson,
    Value<String?>? supersedesEventId,
    Value<int>? revision,
    Value<String>? calculationVersion,
    Value<double>? caloriesMinimum,
    Value<double>? caloriesMaximum,
    Value<double>? proteinMinimum,
    Value<double>? proteinMaximum,
    Value<double>? carbohydrateMinimum,
    Value<double>? carbohydrateMaximum,
    Value<double>? fatMinimum,
    Value<double>? fatMaximum,
    Value<double?>? sodiumMinimum,
    Value<double?>? sodiumMaximum,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return MealEventsCompanion(
      ownerId: ownerId ?? this.ownerId,
      eventId: eventId ?? this.eventId,
      mealType: mealType ?? this.mealType,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rawUserInput: rawUserInput ?? this.rawUserInput,
      aiProvenanceJson: aiProvenanceJson ?? this.aiProvenanceJson,
      supersedesEventId: supersedesEventId ?? this.supersedesEventId,
      revision: revision ?? this.revision,
      calculationVersion: calculationVersion ?? this.calculationVersion,
      caloriesMinimum: caloriesMinimum ?? this.caloriesMinimum,
      caloriesMaximum: caloriesMaximum ?? this.caloriesMaximum,
      proteinMinimum: proteinMinimum ?? this.proteinMinimum,
      proteinMaximum: proteinMaximum ?? this.proteinMaximum,
      carbohydrateMinimum: carbohydrateMinimum ?? this.carbohydrateMinimum,
      carbohydrateMaximum: carbohydrateMaximum ?? this.carbohydrateMaximum,
      fatMinimum: fatMinimum ?? this.fatMinimum,
      fatMaximum: fatMaximum ?? this.fatMaximum,
      sodiumMinimum: sodiumMinimum ?? this.sodiumMinimum,
      sodiumMaximum: sodiumMaximum ?? this.sodiumMaximum,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (rawUserInput.present) {
      map['raw_user_input'] = Variable<String>(rawUserInput.value);
    }
    if (aiProvenanceJson.present) {
      map['ai_provenance_json'] = Variable<String>(aiProvenanceJson.value);
    }
    if (supersedesEventId.present) {
      map['supersedes_event_id'] = Variable<String>(supersedesEventId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (calculationVersion.present) {
      map['calculation_version'] = Variable<String>(calculationVersion.value);
    }
    if (caloriesMinimum.present) {
      map['calories_minimum'] = Variable<double>(caloriesMinimum.value);
    }
    if (caloriesMaximum.present) {
      map['calories_maximum'] = Variable<double>(caloriesMaximum.value);
    }
    if (proteinMinimum.present) {
      map['protein_minimum'] = Variable<double>(proteinMinimum.value);
    }
    if (proteinMaximum.present) {
      map['protein_maximum'] = Variable<double>(proteinMaximum.value);
    }
    if (carbohydrateMinimum.present) {
      map['carbohydrate_minimum'] = Variable<double>(carbohydrateMinimum.value);
    }
    if (carbohydrateMaximum.present) {
      map['carbohydrate_maximum'] = Variable<double>(carbohydrateMaximum.value);
    }
    if (fatMinimum.present) {
      map['fat_minimum'] = Variable<double>(fatMinimum.value);
    }
    if (fatMaximum.present) {
      map['fat_maximum'] = Variable<double>(fatMaximum.value);
    }
    if (sodiumMinimum.present) {
      map['sodium_minimum'] = Variable<double>(sodiumMinimum.value);
    }
    if (sodiumMaximum.present) {
      map['sodium_maximum'] = Variable<double>(sodiumMaximum.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealEventsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('mealType: $mealType, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rawUserInput: $rawUserInput, ')
          ..write('aiProvenanceJson: $aiProvenanceJson, ')
          ..write('supersedesEventId: $supersedesEventId, ')
          ..write('revision: $revision, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('caloriesMinimum: $caloriesMinimum, ')
          ..write('caloriesMaximum: $caloriesMaximum, ')
          ..write('proteinMinimum: $proteinMinimum, ')
          ..write('proteinMaximum: $proteinMaximum, ')
          ..write('carbohydrateMinimum: $carbohydrateMinimum, ')
          ..write('carbohydrateMaximum: $carbohydrateMaximum, ')
          ..write('fatMinimum: $fatMinimum, ')
          ..write('fatMaximum: $fatMaximum, ')
          ..write('sodiumMinimum: $sodiumMinimum, ')
          ..write('sodiumMaximum: $sodiumMaximum, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealItemsTable extends MealItems
    with TableInfo<$MealItemsTable, MealItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIndexMeta = const VerificationMeta(
    'itemIndex',
  );
  @override
  late final GeneratedColumn<int> itemIndex = GeneratedColumn<int>(
    'item_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogItemTypeMeta = const VerificationMeta(
    'catalogItemType',
  );
  @override
  late final GeneratedColumn<String> catalogItemType = GeneratedColumn<String>(
    'catalog_item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('food'),
  );
  static const VerificationMeta _weightBasisMeta = const VerificationMeta(
    'weightBasis',
  );
  @override
  late final GeneratedColumn<String> weightBasis = GeneratedColumn<String>(
    'weight_basis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('catalogConversion'),
  );
  static const VerificationMeta _catalogReleaseIdMeta = const VerificationMeta(
    'catalogReleaseId',
  );
  @override
  late final GeneratedColumn<String> catalogReleaseId = GeneratedColumn<String>(
    'catalog_release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
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
  static const VerificationMeta _sourceVersionMeta = const VerificationMeta(
    'sourceVersion',
  );
  @override
  late final GeneratedColumn<String> sourceVersion = GeneratedColumn<String>(
    'source_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<String> sourceRecordId = GeneratedColumn<String>(
    'source_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingIdMeta = const VerificationMeta(
    'servingId',
  );
  @override
  late final GeneratedColumn<String> servingId = GeneratedColumn<String>(
    'serving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMinimumMeta = const VerificationMeta(
    'gramsMinimum',
  );
  @override
  late final GeneratedColumn<double> gramsMinimum = GeneratedColumn<double>(
    'grams_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMaximumMeta = const VerificationMeta(
    'gramsMaximum',
  );
  @override
  late final GeneratedColumn<double> gramsMaximum = GeneratedColumn<double>(
    'grams_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingConfidenceMeta = const VerificationMeta(
    'servingConfidence',
  );
  @override
  late final GeneratedColumn<double> servingConfidence =
      GeneratedColumn<double>(
        'serving_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _caloriesMinimumMeta = const VerificationMeta(
    'caloriesMinimum',
  );
  @override
  late final GeneratedColumn<double> caloriesMinimum = GeneratedColumn<double>(
    'calories_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMaximumMeta = const VerificationMeta(
    'caloriesMaximum',
  );
  @override
  late final GeneratedColumn<double> caloriesMaximum = GeneratedColumn<double>(
    'calories_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMinimumMeta = const VerificationMeta(
    'proteinMinimum',
  );
  @override
  late final GeneratedColumn<double> proteinMinimum = GeneratedColumn<double>(
    'protein_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMaximumMeta = const VerificationMeta(
    'proteinMaximum',
  );
  @override
  late final GeneratedColumn<double> proteinMaximum = GeneratedColumn<double>(
    'protein_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbohydrateMinimumMeta =
      const VerificationMeta('carbohydrateMinimum');
  @override
  late final GeneratedColumn<double> carbohydrateMinimum =
      GeneratedColumn<double>(
        'carbohydrate_minimum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _carbohydrateMaximumMeta =
      const VerificationMeta('carbohydrateMaximum');
  @override
  late final GeneratedColumn<double> carbohydrateMaximum =
      GeneratedColumn<double>(
        'carbohydrate_maximum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fatMinimumMeta = const VerificationMeta(
    'fatMinimum',
  );
  @override
  late final GeneratedColumn<double> fatMinimum = GeneratedColumn<double>(
    'fat_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMaximumMeta = const VerificationMeta(
    'fatMaximum',
  );
  @override
  late final GeneratedColumn<double> fatMaximum = GeneratedColumn<double>(
    'fat_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMinimumMeta = const VerificationMeta(
    'sodiumMinimum',
  );
  @override
  late final GeneratedColumn<double> sodiumMinimum = GeneratedColumn<double>(
    'sodium_minimum',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMaximumMeta = const VerificationMeta(
    'sodiumMaximum',
  );
  @override
  late final GeneratedColumn<double> sodiumMaximum = GeneratedColumn<double>(
    'sodium_maximum',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilInclusionMeta = const VerificationMeta(
    'oilInclusion',
  );
  @override
  late final GeneratedColumn<String> oilInclusion = GeneratedColumn<String>(
    'oil_inclusion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculationVersionMeta =
      const VerificationMeta('calculationVersion');
  @override
  late final GeneratedColumn<String> calculationVersion =
      GeneratedColumn<String>(
        'calculation_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    eventId,
    itemIndex,
    catalogItemType,
    weightBasis,
    catalogReleaseId,
    foodId,
    sourceId,
    sourceVersion,
    sourceRecordId,
    servingId,
    servingLabel,
    unitCode,
    quantity,
    gramsMinimum,
    gramsMaximum,
    servingConfidence,
    caloriesMinimum,
    caloriesMaximum,
    proteinMinimum,
    proteinMaximum,
    carbohydrateMinimum,
    carbohydrateMaximum,
    fatMinimum,
    fatMaximum,
    sodiumMinimum,
    sodiumMaximum,
    oilInclusion,
    calculationVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('item_index')) {
      context.handle(
        _itemIndexMeta,
        itemIndex.isAcceptableOrUnknown(data['item_index']!, _itemIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIndexMeta);
    }
    if (data.containsKey('catalog_item_type')) {
      context.handle(
        _catalogItemTypeMeta,
        catalogItemType.isAcceptableOrUnknown(
          data['catalog_item_type']!,
          _catalogItemTypeMeta,
        ),
      );
    }
    if (data.containsKey('weight_basis')) {
      context.handle(
        _weightBasisMeta,
        weightBasis.isAcceptableOrUnknown(
          data['weight_basis']!,
          _weightBasisMeta,
        ),
      );
    }
    if (data.containsKey('catalog_release_id')) {
      context.handle(
        _catalogReleaseIdMeta,
        catalogReleaseId.isAcceptableOrUnknown(
          data['catalog_release_id']!,
          _catalogReleaseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogReleaseIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_version')) {
      context.handle(
        _sourceVersionMeta,
        sourceVersion.isAcceptableOrUnknown(
          data['source_version']!,
          _sourceVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceVersionMeta);
    }
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRecordIdMeta);
    }
    if (data.containsKey('serving_id')) {
      context.handle(
        _servingIdMeta,
        servingId.isAcceptableOrUnknown(data['serving_id']!, _servingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_servingIdMeta);
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingLabelMeta);
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('grams_minimum')) {
      context.handle(
        _gramsMinimumMeta,
        gramsMinimum.isAcceptableOrUnknown(
          data['grams_minimum']!,
          _gramsMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gramsMinimumMeta);
    }
    if (data.containsKey('grams_maximum')) {
      context.handle(
        _gramsMaximumMeta,
        gramsMaximum.isAcceptableOrUnknown(
          data['grams_maximum']!,
          _gramsMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gramsMaximumMeta);
    }
    if (data.containsKey('serving_confidence')) {
      context.handle(
        _servingConfidenceMeta,
        servingConfidence.isAcceptableOrUnknown(
          data['serving_confidence']!,
          _servingConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingConfidenceMeta);
    }
    if (data.containsKey('calories_minimum')) {
      context.handle(
        _caloriesMinimumMeta,
        caloriesMinimum.isAcceptableOrUnknown(
          data['calories_minimum']!,
          _caloriesMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesMinimumMeta);
    }
    if (data.containsKey('calories_maximum')) {
      context.handle(
        _caloriesMaximumMeta,
        caloriesMaximum.isAcceptableOrUnknown(
          data['calories_maximum']!,
          _caloriesMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesMaximumMeta);
    }
    if (data.containsKey('protein_minimum')) {
      context.handle(
        _proteinMinimumMeta,
        proteinMinimum.isAcceptableOrUnknown(
          data['protein_minimum']!,
          _proteinMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinMinimumMeta);
    }
    if (data.containsKey('protein_maximum')) {
      context.handle(
        _proteinMaximumMeta,
        proteinMaximum.isAcceptableOrUnknown(
          data['protein_maximum']!,
          _proteinMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinMaximumMeta);
    }
    if (data.containsKey('carbohydrate_minimum')) {
      context.handle(
        _carbohydrateMinimumMeta,
        carbohydrateMinimum.isAcceptableOrUnknown(
          data['carbohydrate_minimum']!,
          _carbohydrateMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateMinimumMeta);
    }
    if (data.containsKey('carbohydrate_maximum')) {
      context.handle(
        _carbohydrateMaximumMeta,
        carbohydrateMaximum.isAcceptableOrUnknown(
          data['carbohydrate_maximum']!,
          _carbohydrateMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateMaximumMeta);
    }
    if (data.containsKey('fat_minimum')) {
      context.handle(
        _fatMinimumMeta,
        fatMinimum.isAcceptableOrUnknown(data['fat_minimum']!, _fatMinimumMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMinimumMeta);
    }
    if (data.containsKey('fat_maximum')) {
      context.handle(
        _fatMaximumMeta,
        fatMaximum.isAcceptableOrUnknown(data['fat_maximum']!, _fatMaximumMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMaximumMeta);
    }
    if (data.containsKey('sodium_minimum')) {
      context.handle(
        _sodiumMinimumMeta,
        sodiumMinimum.isAcceptableOrUnknown(
          data['sodium_minimum']!,
          _sodiumMinimumMeta,
        ),
      );
    }
    if (data.containsKey('sodium_maximum')) {
      context.handle(
        _sodiumMaximumMeta,
        sodiumMaximum.isAcceptableOrUnknown(
          data['sodium_maximum']!,
          _sodiumMaximumMeta,
        ),
      );
    }
    if (data.containsKey('oil_inclusion')) {
      context.handle(
        _oilInclusionMeta,
        oilInclusion.isAcceptableOrUnknown(
          data['oil_inclusion']!,
          _oilInclusionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oilInclusionMeta);
    }
    if (data.containsKey('calculation_version')) {
      context.handle(
        _calculationVersionMeta,
        calculationVersion.isAcceptableOrUnknown(
          data['calculation_version']!,
          _calculationVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculationVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, eventId, itemIndex};
  @override
  MealItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealItem(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      itemIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_index'],
      )!,
      catalogItemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_item_type'],
      )!,
      weightBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_basis'],
      )!,
      catalogReleaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_release_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_version'],
      )!,
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_record_id'],
      )!,
      servingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_id'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      gramsMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_minimum'],
      )!,
      gramsMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_maximum'],
      )!,
      servingConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_confidence'],
      )!,
      caloriesMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_minimum'],
      )!,
      caloriesMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_maximum'],
      )!,
      proteinMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_minimum'],
      )!,
      proteinMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_maximum'],
      )!,
      carbohydrateMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_minimum'],
      )!,
      carbohydrateMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_maximum'],
      )!,
      fatMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_minimum'],
      )!,
      fatMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_maximum'],
      )!,
      sodiumMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_minimum'],
      ),
      sodiumMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_maximum'],
      ),
      oilInclusion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oil_inclusion'],
      )!,
      calculationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_version'],
      )!,
    );
  }

  @override
  $MealItemsTable createAlias(String alias) {
    return $MealItemsTable(attachedDatabase, alias);
  }
}

class MealItem extends DataClass implements Insertable<MealItem> {
  final String ownerId;
  final String eventId;
  final int itemIndex;
  final String catalogItemType;
  final String weightBasis;
  final String catalogReleaseId;
  final String foodId;
  final String sourceId;
  final String sourceVersion;
  final String sourceRecordId;
  final String servingId;
  final String servingLabel;
  final String unitCode;
  final double quantity;
  final double gramsMinimum;
  final double gramsMaximum;
  final double servingConfidence;
  final double caloriesMinimum;
  final double caloriesMaximum;
  final double proteinMinimum;
  final double proteinMaximum;
  final double carbohydrateMinimum;
  final double carbohydrateMaximum;
  final double fatMinimum;
  final double fatMaximum;
  final double? sodiumMinimum;
  final double? sodiumMaximum;
  final String oilInclusion;
  final String calculationVersion;
  const MealItem({
    required this.ownerId,
    required this.eventId,
    required this.itemIndex,
    required this.catalogItemType,
    required this.weightBasis,
    required this.catalogReleaseId,
    required this.foodId,
    required this.sourceId,
    required this.sourceVersion,
    required this.sourceRecordId,
    required this.servingId,
    required this.servingLabel,
    required this.unitCode,
    required this.quantity,
    required this.gramsMinimum,
    required this.gramsMaximum,
    required this.servingConfidence,
    required this.caloriesMinimum,
    required this.caloriesMaximum,
    required this.proteinMinimum,
    required this.proteinMaximum,
    required this.carbohydrateMinimum,
    required this.carbohydrateMaximum,
    required this.fatMinimum,
    required this.fatMaximum,
    this.sodiumMinimum,
    this.sodiumMaximum,
    required this.oilInclusion,
    required this.calculationVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['event_id'] = Variable<String>(eventId);
    map['item_index'] = Variable<int>(itemIndex);
    map['catalog_item_type'] = Variable<String>(catalogItemType);
    map['weight_basis'] = Variable<String>(weightBasis);
    map['catalog_release_id'] = Variable<String>(catalogReleaseId);
    map['food_id'] = Variable<String>(foodId);
    map['source_id'] = Variable<String>(sourceId);
    map['source_version'] = Variable<String>(sourceVersion);
    map['source_record_id'] = Variable<String>(sourceRecordId);
    map['serving_id'] = Variable<String>(servingId);
    map['serving_label'] = Variable<String>(servingLabel);
    map['unit_code'] = Variable<String>(unitCode);
    map['quantity'] = Variable<double>(quantity);
    map['grams_minimum'] = Variable<double>(gramsMinimum);
    map['grams_maximum'] = Variable<double>(gramsMaximum);
    map['serving_confidence'] = Variable<double>(servingConfidence);
    map['calories_minimum'] = Variable<double>(caloriesMinimum);
    map['calories_maximum'] = Variable<double>(caloriesMaximum);
    map['protein_minimum'] = Variable<double>(proteinMinimum);
    map['protein_maximum'] = Variable<double>(proteinMaximum);
    map['carbohydrate_minimum'] = Variable<double>(carbohydrateMinimum);
    map['carbohydrate_maximum'] = Variable<double>(carbohydrateMaximum);
    map['fat_minimum'] = Variable<double>(fatMinimum);
    map['fat_maximum'] = Variable<double>(fatMaximum);
    if (!nullToAbsent || sodiumMinimum != null) {
      map['sodium_minimum'] = Variable<double>(sodiumMinimum);
    }
    if (!nullToAbsent || sodiumMaximum != null) {
      map['sodium_maximum'] = Variable<double>(sodiumMaximum);
    }
    map['oil_inclusion'] = Variable<String>(oilInclusion);
    map['calculation_version'] = Variable<String>(calculationVersion);
    return map;
  }

  MealItemsCompanion toCompanion(bool nullToAbsent) {
    return MealItemsCompanion(
      ownerId: Value(ownerId),
      eventId: Value(eventId),
      itemIndex: Value(itemIndex),
      catalogItemType: Value(catalogItemType),
      weightBasis: Value(weightBasis),
      catalogReleaseId: Value(catalogReleaseId),
      foodId: Value(foodId),
      sourceId: Value(sourceId),
      sourceVersion: Value(sourceVersion),
      sourceRecordId: Value(sourceRecordId),
      servingId: Value(servingId),
      servingLabel: Value(servingLabel),
      unitCode: Value(unitCode),
      quantity: Value(quantity),
      gramsMinimum: Value(gramsMinimum),
      gramsMaximum: Value(gramsMaximum),
      servingConfidence: Value(servingConfidence),
      caloriesMinimum: Value(caloriesMinimum),
      caloriesMaximum: Value(caloriesMaximum),
      proteinMinimum: Value(proteinMinimum),
      proteinMaximum: Value(proteinMaximum),
      carbohydrateMinimum: Value(carbohydrateMinimum),
      carbohydrateMaximum: Value(carbohydrateMaximum),
      fatMinimum: Value(fatMinimum),
      fatMaximum: Value(fatMaximum),
      sodiumMinimum: sodiumMinimum == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMinimum),
      sodiumMaximum: sodiumMaximum == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMaximum),
      oilInclusion: Value(oilInclusion),
      calculationVersion: Value(calculationVersion),
    );
  }

  factory MealItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealItem(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      itemIndex: serializer.fromJson<int>(json['itemIndex']),
      catalogItemType: serializer.fromJson<String>(json['catalogItemType']),
      weightBasis: serializer.fromJson<String>(json['weightBasis']),
      catalogReleaseId: serializer.fromJson<String>(json['catalogReleaseId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceVersion: serializer.fromJson<String>(json['sourceVersion']),
      sourceRecordId: serializer.fromJson<String>(json['sourceRecordId']),
      servingId: serializer.fromJson<String>(json['servingId']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      unitCode: serializer.fromJson<String>(json['unitCode']),
      quantity: serializer.fromJson<double>(json['quantity']),
      gramsMinimum: serializer.fromJson<double>(json['gramsMinimum']),
      gramsMaximum: serializer.fromJson<double>(json['gramsMaximum']),
      servingConfidence: serializer.fromJson<double>(json['servingConfidence']),
      caloriesMinimum: serializer.fromJson<double>(json['caloriesMinimum']),
      caloriesMaximum: serializer.fromJson<double>(json['caloriesMaximum']),
      proteinMinimum: serializer.fromJson<double>(json['proteinMinimum']),
      proteinMaximum: serializer.fromJson<double>(json['proteinMaximum']),
      carbohydrateMinimum: serializer.fromJson<double>(
        json['carbohydrateMinimum'],
      ),
      carbohydrateMaximum: serializer.fromJson<double>(
        json['carbohydrateMaximum'],
      ),
      fatMinimum: serializer.fromJson<double>(json['fatMinimum']),
      fatMaximum: serializer.fromJson<double>(json['fatMaximum']),
      sodiumMinimum: serializer.fromJson<double?>(json['sodiumMinimum']),
      sodiumMaximum: serializer.fromJson<double?>(json['sodiumMaximum']),
      oilInclusion: serializer.fromJson<String>(json['oilInclusion']),
      calculationVersion: serializer.fromJson<String>(
        json['calculationVersion'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'eventId': serializer.toJson<String>(eventId),
      'itemIndex': serializer.toJson<int>(itemIndex),
      'catalogItemType': serializer.toJson<String>(catalogItemType),
      'weightBasis': serializer.toJson<String>(weightBasis),
      'catalogReleaseId': serializer.toJson<String>(catalogReleaseId),
      'foodId': serializer.toJson<String>(foodId),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceVersion': serializer.toJson<String>(sourceVersion),
      'sourceRecordId': serializer.toJson<String>(sourceRecordId),
      'servingId': serializer.toJson<String>(servingId),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'unitCode': serializer.toJson<String>(unitCode),
      'quantity': serializer.toJson<double>(quantity),
      'gramsMinimum': serializer.toJson<double>(gramsMinimum),
      'gramsMaximum': serializer.toJson<double>(gramsMaximum),
      'servingConfidence': serializer.toJson<double>(servingConfidence),
      'caloriesMinimum': serializer.toJson<double>(caloriesMinimum),
      'caloriesMaximum': serializer.toJson<double>(caloriesMaximum),
      'proteinMinimum': serializer.toJson<double>(proteinMinimum),
      'proteinMaximum': serializer.toJson<double>(proteinMaximum),
      'carbohydrateMinimum': serializer.toJson<double>(carbohydrateMinimum),
      'carbohydrateMaximum': serializer.toJson<double>(carbohydrateMaximum),
      'fatMinimum': serializer.toJson<double>(fatMinimum),
      'fatMaximum': serializer.toJson<double>(fatMaximum),
      'sodiumMinimum': serializer.toJson<double?>(sodiumMinimum),
      'sodiumMaximum': serializer.toJson<double?>(sodiumMaximum),
      'oilInclusion': serializer.toJson<String>(oilInclusion),
      'calculationVersion': serializer.toJson<String>(calculationVersion),
    };
  }

  MealItem copyWith({
    String? ownerId,
    String? eventId,
    int? itemIndex,
    String? catalogItemType,
    String? weightBasis,
    String? catalogReleaseId,
    String? foodId,
    String? sourceId,
    String? sourceVersion,
    String? sourceRecordId,
    String? servingId,
    String? servingLabel,
    String? unitCode,
    double? quantity,
    double? gramsMinimum,
    double? gramsMaximum,
    double? servingConfidence,
    double? caloriesMinimum,
    double? caloriesMaximum,
    double? proteinMinimum,
    double? proteinMaximum,
    double? carbohydrateMinimum,
    double? carbohydrateMaximum,
    double? fatMinimum,
    double? fatMaximum,
    Value<double?> sodiumMinimum = const Value.absent(),
    Value<double?> sodiumMaximum = const Value.absent(),
    String? oilInclusion,
    String? calculationVersion,
  }) => MealItem(
    ownerId: ownerId ?? this.ownerId,
    eventId: eventId ?? this.eventId,
    itemIndex: itemIndex ?? this.itemIndex,
    catalogItemType: catalogItemType ?? this.catalogItemType,
    weightBasis: weightBasis ?? this.weightBasis,
    catalogReleaseId: catalogReleaseId ?? this.catalogReleaseId,
    foodId: foodId ?? this.foodId,
    sourceId: sourceId ?? this.sourceId,
    sourceVersion: sourceVersion ?? this.sourceVersion,
    sourceRecordId: sourceRecordId ?? this.sourceRecordId,
    servingId: servingId ?? this.servingId,
    servingLabel: servingLabel ?? this.servingLabel,
    unitCode: unitCode ?? this.unitCode,
    quantity: quantity ?? this.quantity,
    gramsMinimum: gramsMinimum ?? this.gramsMinimum,
    gramsMaximum: gramsMaximum ?? this.gramsMaximum,
    servingConfidence: servingConfidence ?? this.servingConfidence,
    caloriesMinimum: caloriesMinimum ?? this.caloriesMinimum,
    caloriesMaximum: caloriesMaximum ?? this.caloriesMaximum,
    proteinMinimum: proteinMinimum ?? this.proteinMinimum,
    proteinMaximum: proteinMaximum ?? this.proteinMaximum,
    carbohydrateMinimum: carbohydrateMinimum ?? this.carbohydrateMinimum,
    carbohydrateMaximum: carbohydrateMaximum ?? this.carbohydrateMaximum,
    fatMinimum: fatMinimum ?? this.fatMinimum,
    fatMaximum: fatMaximum ?? this.fatMaximum,
    sodiumMinimum: sodiumMinimum.present
        ? sodiumMinimum.value
        : this.sodiumMinimum,
    sodiumMaximum: sodiumMaximum.present
        ? sodiumMaximum.value
        : this.sodiumMaximum,
    oilInclusion: oilInclusion ?? this.oilInclusion,
    calculationVersion: calculationVersion ?? this.calculationVersion,
  );
  MealItem copyWithCompanion(MealItemsCompanion data) {
    return MealItem(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      itemIndex: data.itemIndex.present ? data.itemIndex.value : this.itemIndex,
      catalogItemType: data.catalogItemType.present
          ? data.catalogItemType.value
          : this.catalogItemType,
      weightBasis: data.weightBasis.present
          ? data.weightBasis.value
          : this.weightBasis,
      catalogReleaseId: data.catalogReleaseId.present
          ? data.catalogReleaseId.value
          : this.catalogReleaseId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
      servingId: data.servingId.present ? data.servingId.value : this.servingId,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      gramsMinimum: data.gramsMinimum.present
          ? data.gramsMinimum.value
          : this.gramsMinimum,
      gramsMaximum: data.gramsMaximum.present
          ? data.gramsMaximum.value
          : this.gramsMaximum,
      servingConfidence: data.servingConfidence.present
          ? data.servingConfidence.value
          : this.servingConfidence,
      caloriesMinimum: data.caloriesMinimum.present
          ? data.caloriesMinimum.value
          : this.caloriesMinimum,
      caloriesMaximum: data.caloriesMaximum.present
          ? data.caloriesMaximum.value
          : this.caloriesMaximum,
      proteinMinimum: data.proteinMinimum.present
          ? data.proteinMinimum.value
          : this.proteinMinimum,
      proteinMaximum: data.proteinMaximum.present
          ? data.proteinMaximum.value
          : this.proteinMaximum,
      carbohydrateMinimum: data.carbohydrateMinimum.present
          ? data.carbohydrateMinimum.value
          : this.carbohydrateMinimum,
      carbohydrateMaximum: data.carbohydrateMaximum.present
          ? data.carbohydrateMaximum.value
          : this.carbohydrateMaximum,
      fatMinimum: data.fatMinimum.present
          ? data.fatMinimum.value
          : this.fatMinimum,
      fatMaximum: data.fatMaximum.present
          ? data.fatMaximum.value
          : this.fatMaximum,
      sodiumMinimum: data.sodiumMinimum.present
          ? data.sodiumMinimum.value
          : this.sodiumMinimum,
      sodiumMaximum: data.sodiumMaximum.present
          ? data.sodiumMaximum.value
          : this.sodiumMaximum,
      oilInclusion: data.oilInclusion.present
          ? data.oilInclusion.value
          : this.oilInclusion,
      calculationVersion: data.calculationVersion.present
          ? data.calculationVersion.value
          : this.calculationVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealItem(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('catalogItemType: $catalogItemType, ')
          ..write('weightBasis: $weightBasis, ')
          ..write('catalogReleaseId: $catalogReleaseId, ')
          ..write('foodId: $foodId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('servingId: $servingId, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('unitCode: $unitCode, ')
          ..write('quantity: $quantity, ')
          ..write('gramsMinimum: $gramsMinimum, ')
          ..write('gramsMaximum: $gramsMaximum, ')
          ..write('servingConfidence: $servingConfidence, ')
          ..write('caloriesMinimum: $caloriesMinimum, ')
          ..write('caloriesMaximum: $caloriesMaximum, ')
          ..write('proteinMinimum: $proteinMinimum, ')
          ..write('proteinMaximum: $proteinMaximum, ')
          ..write('carbohydrateMinimum: $carbohydrateMinimum, ')
          ..write('carbohydrateMaximum: $carbohydrateMaximum, ')
          ..write('fatMinimum: $fatMinimum, ')
          ..write('fatMaximum: $fatMaximum, ')
          ..write('sodiumMinimum: $sodiumMinimum, ')
          ..write('sodiumMaximum: $sodiumMaximum, ')
          ..write('oilInclusion: $oilInclusion, ')
          ..write('calculationVersion: $calculationVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ownerId,
    eventId,
    itemIndex,
    catalogItemType,
    weightBasis,
    catalogReleaseId,
    foodId,
    sourceId,
    sourceVersion,
    sourceRecordId,
    servingId,
    servingLabel,
    unitCode,
    quantity,
    gramsMinimum,
    gramsMaximum,
    servingConfidence,
    caloriesMinimum,
    caloriesMaximum,
    proteinMinimum,
    proteinMaximum,
    carbohydrateMinimum,
    carbohydrateMaximum,
    fatMinimum,
    fatMaximum,
    sodiumMinimum,
    sodiumMaximum,
    oilInclusion,
    calculationVersion,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealItem &&
          other.ownerId == this.ownerId &&
          other.eventId == this.eventId &&
          other.itemIndex == this.itemIndex &&
          other.catalogItemType == this.catalogItemType &&
          other.weightBasis == this.weightBasis &&
          other.catalogReleaseId == this.catalogReleaseId &&
          other.foodId == this.foodId &&
          other.sourceId == this.sourceId &&
          other.sourceVersion == this.sourceVersion &&
          other.sourceRecordId == this.sourceRecordId &&
          other.servingId == this.servingId &&
          other.servingLabel == this.servingLabel &&
          other.unitCode == this.unitCode &&
          other.quantity == this.quantity &&
          other.gramsMinimum == this.gramsMinimum &&
          other.gramsMaximum == this.gramsMaximum &&
          other.servingConfidence == this.servingConfidence &&
          other.caloriesMinimum == this.caloriesMinimum &&
          other.caloriesMaximum == this.caloriesMaximum &&
          other.proteinMinimum == this.proteinMinimum &&
          other.proteinMaximum == this.proteinMaximum &&
          other.carbohydrateMinimum == this.carbohydrateMinimum &&
          other.carbohydrateMaximum == this.carbohydrateMaximum &&
          other.fatMinimum == this.fatMinimum &&
          other.fatMaximum == this.fatMaximum &&
          other.sodiumMinimum == this.sodiumMinimum &&
          other.sodiumMaximum == this.sodiumMaximum &&
          other.oilInclusion == this.oilInclusion &&
          other.calculationVersion == this.calculationVersion);
}

class MealItemsCompanion extends UpdateCompanion<MealItem> {
  final Value<String> ownerId;
  final Value<String> eventId;
  final Value<int> itemIndex;
  final Value<String> catalogItemType;
  final Value<String> weightBasis;
  final Value<String> catalogReleaseId;
  final Value<String> foodId;
  final Value<String> sourceId;
  final Value<String> sourceVersion;
  final Value<String> sourceRecordId;
  final Value<String> servingId;
  final Value<String> servingLabel;
  final Value<String> unitCode;
  final Value<double> quantity;
  final Value<double> gramsMinimum;
  final Value<double> gramsMaximum;
  final Value<double> servingConfidence;
  final Value<double> caloriesMinimum;
  final Value<double> caloriesMaximum;
  final Value<double> proteinMinimum;
  final Value<double> proteinMaximum;
  final Value<double> carbohydrateMinimum;
  final Value<double> carbohydrateMaximum;
  final Value<double> fatMinimum;
  final Value<double> fatMaximum;
  final Value<double?> sodiumMinimum;
  final Value<double?> sodiumMaximum;
  final Value<String> oilInclusion;
  final Value<String> calculationVersion;
  final Value<int> rowid;
  const MealItemsCompanion({
    this.ownerId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.itemIndex = const Value.absent(),
    this.catalogItemType = const Value.absent(),
    this.weightBasis = const Value.absent(),
    this.catalogReleaseId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
    this.servingId = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.quantity = const Value.absent(),
    this.gramsMinimum = const Value.absent(),
    this.gramsMaximum = const Value.absent(),
    this.servingConfidence = const Value.absent(),
    this.caloriesMinimum = const Value.absent(),
    this.caloriesMaximum = const Value.absent(),
    this.proteinMinimum = const Value.absent(),
    this.proteinMaximum = const Value.absent(),
    this.carbohydrateMinimum = const Value.absent(),
    this.carbohydrateMaximum = const Value.absent(),
    this.fatMinimum = const Value.absent(),
    this.fatMaximum = const Value.absent(),
    this.sodiumMinimum = const Value.absent(),
    this.sodiumMaximum = const Value.absent(),
    this.oilInclusion = const Value.absent(),
    this.calculationVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealItemsCompanion.insert({
    required String ownerId,
    required String eventId,
    required int itemIndex,
    this.catalogItemType = const Value.absent(),
    this.weightBasis = const Value.absent(),
    required String catalogReleaseId,
    required String foodId,
    required String sourceId,
    required String sourceVersion,
    required String sourceRecordId,
    required String servingId,
    required String servingLabel,
    required String unitCode,
    required double quantity,
    required double gramsMinimum,
    required double gramsMaximum,
    required double servingConfidence,
    required double caloriesMinimum,
    required double caloriesMaximum,
    required double proteinMinimum,
    required double proteinMaximum,
    required double carbohydrateMinimum,
    required double carbohydrateMaximum,
    required double fatMinimum,
    required double fatMaximum,
    this.sodiumMinimum = const Value.absent(),
    this.sodiumMaximum = const Value.absent(),
    required String oilInclusion,
    required String calculationVersion,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       eventId = Value(eventId),
       itemIndex = Value(itemIndex),
       catalogReleaseId = Value(catalogReleaseId),
       foodId = Value(foodId),
       sourceId = Value(sourceId),
       sourceVersion = Value(sourceVersion),
       sourceRecordId = Value(sourceRecordId),
       servingId = Value(servingId),
       servingLabel = Value(servingLabel),
       unitCode = Value(unitCode),
       quantity = Value(quantity),
       gramsMinimum = Value(gramsMinimum),
       gramsMaximum = Value(gramsMaximum),
       servingConfidence = Value(servingConfidence),
       caloriesMinimum = Value(caloriesMinimum),
       caloriesMaximum = Value(caloriesMaximum),
       proteinMinimum = Value(proteinMinimum),
       proteinMaximum = Value(proteinMaximum),
       carbohydrateMinimum = Value(carbohydrateMinimum),
       carbohydrateMaximum = Value(carbohydrateMaximum),
       fatMinimum = Value(fatMinimum),
       fatMaximum = Value(fatMaximum),
       oilInclusion = Value(oilInclusion),
       calculationVersion = Value(calculationVersion);
  static Insertable<MealItem> custom({
    Expression<String>? ownerId,
    Expression<String>? eventId,
    Expression<int>? itemIndex,
    Expression<String>? catalogItemType,
    Expression<String>? weightBasis,
    Expression<String>? catalogReleaseId,
    Expression<String>? foodId,
    Expression<String>? sourceId,
    Expression<String>? sourceVersion,
    Expression<String>? sourceRecordId,
    Expression<String>? servingId,
    Expression<String>? servingLabel,
    Expression<String>? unitCode,
    Expression<double>? quantity,
    Expression<double>? gramsMinimum,
    Expression<double>? gramsMaximum,
    Expression<double>? servingConfidence,
    Expression<double>? caloriesMinimum,
    Expression<double>? caloriesMaximum,
    Expression<double>? proteinMinimum,
    Expression<double>? proteinMaximum,
    Expression<double>? carbohydrateMinimum,
    Expression<double>? carbohydrateMaximum,
    Expression<double>? fatMinimum,
    Expression<double>? fatMaximum,
    Expression<double>? sodiumMinimum,
    Expression<double>? sodiumMaximum,
    Expression<String>? oilInclusion,
    Expression<String>? calculationVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (eventId != null) 'event_id': eventId,
      if (itemIndex != null) 'item_index': itemIndex,
      if (catalogItemType != null) 'catalog_item_type': catalogItemType,
      if (weightBasis != null) 'weight_basis': weightBasis,
      if (catalogReleaseId != null) 'catalog_release_id': catalogReleaseId,
      if (foodId != null) 'food_id': foodId,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
      if (servingId != null) 'serving_id': servingId,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (unitCode != null) 'unit_code': unitCode,
      if (quantity != null) 'quantity': quantity,
      if (gramsMinimum != null) 'grams_minimum': gramsMinimum,
      if (gramsMaximum != null) 'grams_maximum': gramsMaximum,
      if (servingConfidence != null) 'serving_confidence': servingConfidence,
      if (caloriesMinimum != null) 'calories_minimum': caloriesMinimum,
      if (caloriesMaximum != null) 'calories_maximum': caloriesMaximum,
      if (proteinMinimum != null) 'protein_minimum': proteinMinimum,
      if (proteinMaximum != null) 'protein_maximum': proteinMaximum,
      if (carbohydrateMinimum != null)
        'carbohydrate_minimum': carbohydrateMinimum,
      if (carbohydrateMaximum != null)
        'carbohydrate_maximum': carbohydrateMaximum,
      if (fatMinimum != null) 'fat_minimum': fatMinimum,
      if (fatMaximum != null) 'fat_maximum': fatMaximum,
      if (sodiumMinimum != null) 'sodium_minimum': sodiumMinimum,
      if (sodiumMaximum != null) 'sodium_maximum': sodiumMaximum,
      if (oilInclusion != null) 'oil_inclusion': oilInclusion,
      if (calculationVersion != null) 'calculation_version': calculationVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealItemsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? eventId,
    Value<int>? itemIndex,
    Value<String>? catalogItemType,
    Value<String>? weightBasis,
    Value<String>? catalogReleaseId,
    Value<String>? foodId,
    Value<String>? sourceId,
    Value<String>? sourceVersion,
    Value<String>? sourceRecordId,
    Value<String>? servingId,
    Value<String>? servingLabel,
    Value<String>? unitCode,
    Value<double>? quantity,
    Value<double>? gramsMinimum,
    Value<double>? gramsMaximum,
    Value<double>? servingConfidence,
    Value<double>? caloriesMinimum,
    Value<double>? caloriesMaximum,
    Value<double>? proteinMinimum,
    Value<double>? proteinMaximum,
    Value<double>? carbohydrateMinimum,
    Value<double>? carbohydrateMaximum,
    Value<double>? fatMinimum,
    Value<double>? fatMaximum,
    Value<double?>? sodiumMinimum,
    Value<double?>? sodiumMaximum,
    Value<String>? oilInclusion,
    Value<String>? calculationVersion,
    Value<int>? rowid,
  }) {
    return MealItemsCompanion(
      ownerId: ownerId ?? this.ownerId,
      eventId: eventId ?? this.eventId,
      itemIndex: itemIndex ?? this.itemIndex,
      catalogItemType: catalogItemType ?? this.catalogItemType,
      weightBasis: weightBasis ?? this.weightBasis,
      catalogReleaseId: catalogReleaseId ?? this.catalogReleaseId,
      foodId: foodId ?? this.foodId,
      sourceId: sourceId ?? this.sourceId,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      servingId: servingId ?? this.servingId,
      servingLabel: servingLabel ?? this.servingLabel,
      unitCode: unitCode ?? this.unitCode,
      quantity: quantity ?? this.quantity,
      gramsMinimum: gramsMinimum ?? this.gramsMinimum,
      gramsMaximum: gramsMaximum ?? this.gramsMaximum,
      servingConfidence: servingConfidence ?? this.servingConfidence,
      caloriesMinimum: caloriesMinimum ?? this.caloriesMinimum,
      caloriesMaximum: caloriesMaximum ?? this.caloriesMaximum,
      proteinMinimum: proteinMinimum ?? this.proteinMinimum,
      proteinMaximum: proteinMaximum ?? this.proteinMaximum,
      carbohydrateMinimum: carbohydrateMinimum ?? this.carbohydrateMinimum,
      carbohydrateMaximum: carbohydrateMaximum ?? this.carbohydrateMaximum,
      fatMinimum: fatMinimum ?? this.fatMinimum,
      fatMaximum: fatMaximum ?? this.fatMaximum,
      sodiumMinimum: sodiumMinimum ?? this.sodiumMinimum,
      sodiumMaximum: sodiumMaximum ?? this.sodiumMaximum,
      oilInclusion: oilInclusion ?? this.oilInclusion,
      calculationVersion: calculationVersion ?? this.calculationVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (itemIndex.present) {
      map['item_index'] = Variable<int>(itemIndex.value);
    }
    if (catalogItemType.present) {
      map['catalog_item_type'] = Variable<String>(catalogItemType.value);
    }
    if (weightBasis.present) {
      map['weight_basis'] = Variable<String>(weightBasis.value);
    }
    if (catalogReleaseId.present) {
      map['catalog_release_id'] = Variable<String>(catalogReleaseId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<String>(sourceVersion.value);
    }
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<String>(sourceRecordId.value);
    }
    if (servingId.present) {
      map['serving_id'] = Variable<String>(servingId.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (gramsMinimum.present) {
      map['grams_minimum'] = Variable<double>(gramsMinimum.value);
    }
    if (gramsMaximum.present) {
      map['grams_maximum'] = Variable<double>(gramsMaximum.value);
    }
    if (servingConfidence.present) {
      map['serving_confidence'] = Variable<double>(servingConfidence.value);
    }
    if (caloriesMinimum.present) {
      map['calories_minimum'] = Variable<double>(caloriesMinimum.value);
    }
    if (caloriesMaximum.present) {
      map['calories_maximum'] = Variable<double>(caloriesMaximum.value);
    }
    if (proteinMinimum.present) {
      map['protein_minimum'] = Variable<double>(proteinMinimum.value);
    }
    if (proteinMaximum.present) {
      map['protein_maximum'] = Variable<double>(proteinMaximum.value);
    }
    if (carbohydrateMinimum.present) {
      map['carbohydrate_minimum'] = Variable<double>(carbohydrateMinimum.value);
    }
    if (carbohydrateMaximum.present) {
      map['carbohydrate_maximum'] = Variable<double>(carbohydrateMaximum.value);
    }
    if (fatMinimum.present) {
      map['fat_minimum'] = Variable<double>(fatMinimum.value);
    }
    if (fatMaximum.present) {
      map['fat_maximum'] = Variable<double>(fatMaximum.value);
    }
    if (sodiumMinimum.present) {
      map['sodium_minimum'] = Variable<double>(sodiumMinimum.value);
    }
    if (sodiumMaximum.present) {
      map['sodium_maximum'] = Variable<double>(sodiumMaximum.value);
    }
    if (oilInclusion.present) {
      map['oil_inclusion'] = Variable<String>(oilInclusion.value);
    }
    if (calculationVersion.present) {
      map['calculation_version'] = Variable<String>(calculationVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealItemsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('catalogItemType: $catalogItemType, ')
          ..write('weightBasis: $weightBasis, ')
          ..write('catalogReleaseId: $catalogReleaseId, ')
          ..write('foodId: $foodId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('servingId: $servingId, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('unitCode: $unitCode, ')
          ..write('quantity: $quantity, ')
          ..write('gramsMinimum: $gramsMinimum, ')
          ..write('gramsMaximum: $gramsMaximum, ')
          ..write('servingConfidence: $servingConfidence, ')
          ..write('caloriesMinimum: $caloriesMinimum, ')
          ..write('caloriesMaximum: $caloriesMaximum, ')
          ..write('proteinMinimum: $proteinMinimum, ')
          ..write('proteinMaximum: $proteinMaximum, ')
          ..write('carbohydrateMinimum: $carbohydrateMinimum, ')
          ..write('carbohydrateMaximum: $carbohydrateMaximum, ')
          ..write('fatMinimum: $fatMinimum, ')
          ..write('fatMaximum: $fatMaximum, ')
          ..write('sodiumMinimum: $sodiumMinimum, ')
          ..write('sodiumMaximum: $sodiumMaximum, ')
          ..write('oilInclusion: $oilInclusion, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterEventsTable extends WaterEvents
    with TableInfo<$WaterEventsTable, WaterEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMillilitersMeta = const VerificationMeta(
    'volumeMilliliters',
  );
  @override
  late final GeneratedColumn<int> volumeMilliliters = GeneratedColumn<int>(
    'volume_milliliters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersedesEventIdMeta = const VerificationMeta(
    'supersedesEventId',
  );
  @override
  late final GeneratedColumn<String> supersedesEventId =
      GeneratedColumn<String>(
        'supersedes_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    eventId,
    occurredAtUtc,
    timezoneOffsetMinutes,
    createdAtUtc,
    volumeMilliliters,
    supersedesEventId,
    revision,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('volume_milliliters')) {
      context.handle(
        _volumeMillilitersMeta,
        volumeMilliliters.isAcceptableOrUnknown(
          data['volume_milliliters']!,
          _volumeMillilitersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_volumeMillilitersMeta);
    }
    if (data.containsKey('supersedes_event_id')) {
      context.handle(
        _supersedesEventIdMeta,
        supersedesEventId.isAcceptableOrUnknown(
          data['supersedes_event_id']!,
          _supersedesEventIdMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, eventId};
  @override
  WaterEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterEvent(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      volumeMilliliters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_milliliters'],
      )!,
      supersedesEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_event_id'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $WaterEventsTable createAlias(String alias) {
    return $WaterEventsTable(attachedDatabase, alias);
  }
}

class WaterEvent extends DataClass implements Insertable<WaterEvent> {
  final String ownerId;
  final String eventId;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime createdAtUtc;
  final int volumeMilliliters;
  final String? supersedesEventId;
  final int revision;
  final bool isDeleted;
  const WaterEvent({
    required this.ownerId,
    required this.eventId,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.createdAtUtc,
    required this.volumeMilliliters,
    this.supersedesEventId,
    required this.revision,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['event_id'] = Variable<String>(eventId);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['volume_milliliters'] = Variable<int>(volumeMilliliters);
    if (!nullToAbsent || supersedesEventId != null) {
      map['supersedes_event_id'] = Variable<String>(supersedesEventId);
    }
    map['revision'] = Variable<int>(revision);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  WaterEventsCompanion toCompanion(bool nullToAbsent) {
    return WaterEventsCompanion(
      ownerId: Value(ownerId),
      eventId: Value(eventId),
      occurredAtUtc: Value(occurredAtUtc),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      createdAtUtc: Value(createdAtUtc),
      volumeMilliliters: Value(volumeMilliliters),
      supersedesEventId: supersedesEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesEventId),
      revision: Value(revision),
      isDeleted: Value(isDeleted),
    );
  }

  factory WaterEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterEvent(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      volumeMilliliters: serializer.fromJson<int>(json['volumeMilliliters']),
      supersedesEventId: serializer.fromJson<String?>(
        json['supersedesEventId'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'eventId': serializer.toJson<String>(eventId),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'volumeMilliliters': serializer.toJson<int>(volumeMilliliters),
      'supersedesEventId': serializer.toJson<String?>(supersedesEventId),
      'revision': serializer.toJson<int>(revision),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  WaterEvent copyWith({
    String? ownerId,
    String? eventId,
    DateTime? occurredAtUtc,
    int? timezoneOffsetMinutes,
    DateTime? createdAtUtc,
    int? volumeMilliliters,
    Value<String?> supersedesEventId = const Value.absent(),
    int? revision,
    bool? isDeleted,
  }) => WaterEvent(
    ownerId: ownerId ?? this.ownerId,
    eventId: eventId ?? this.eventId,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    volumeMilliliters: volumeMilliliters ?? this.volumeMilliliters,
    supersedesEventId: supersedesEventId.present
        ? supersedesEventId.value
        : this.supersedesEventId,
    revision: revision ?? this.revision,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  WaterEvent copyWithCompanion(WaterEventsCompanion data) {
    return WaterEvent(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      volumeMilliliters: data.volumeMilliliters.present
          ? data.volumeMilliliters.value
          : this.volumeMilliliters,
      supersedesEventId: data.supersedesEventId.present
          ? data.supersedesEventId.value
          : this.supersedesEventId,
      revision: data.revision.present ? data.revision.value : this.revision,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterEvent(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('volumeMilliliters: $volumeMilliliters, ')
          ..write('supersedesEventId: $supersedesEventId, ')
          ..write('revision: $revision, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    eventId,
    occurredAtUtc,
    timezoneOffsetMinutes,
    createdAtUtc,
    volumeMilliliters,
    supersedesEventId,
    revision,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterEvent &&
          other.ownerId == this.ownerId &&
          other.eventId == this.eventId &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.volumeMilliliters == this.volumeMilliliters &&
          other.supersedesEventId == this.supersedesEventId &&
          other.revision == this.revision &&
          other.isDeleted == this.isDeleted);
}

class WaterEventsCompanion extends UpdateCompanion<WaterEvent> {
  final Value<String> ownerId;
  final Value<String> eventId;
  final Value<DateTime> occurredAtUtc;
  final Value<int> timezoneOffsetMinutes;
  final Value<DateTime> createdAtUtc;
  final Value<int> volumeMilliliters;
  final Value<String?> supersedesEventId;
  final Value<int> revision;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const WaterEventsCompanion({
    this.ownerId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.volumeMilliliters = const Value.absent(),
    this.supersedesEventId = const Value.absent(),
    this.revision = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterEventsCompanion.insert({
    required String ownerId,
    required String eventId,
    required DateTime occurredAtUtc,
    required int timezoneOffsetMinutes,
    required DateTime createdAtUtc,
    required int volumeMilliliters,
    this.supersedesEventId = const Value.absent(),
    required int revision,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       eventId = Value(eventId),
       occurredAtUtc = Value(occurredAtUtc),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes),
       createdAtUtc = Value(createdAtUtc),
       volumeMilliliters = Value(volumeMilliliters),
       revision = Value(revision);
  static Insertable<WaterEvent> custom({
    Expression<String>? ownerId,
    Expression<String>? eventId,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? timezoneOffsetMinutes,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? volumeMilliliters,
    Expression<String>? supersedesEventId,
    Expression<int>? revision,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (eventId != null) 'event_id': eventId,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (volumeMilliliters != null) 'volume_milliliters': volumeMilliliters,
      if (supersedesEventId != null) 'supersedes_event_id': supersedesEventId,
      if (revision != null) 'revision': revision,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterEventsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? eventId,
    Value<DateTime>? occurredAtUtc,
    Value<int>? timezoneOffsetMinutes,
    Value<DateTime>? createdAtUtc,
    Value<int>? volumeMilliliters,
    Value<String?>? supersedesEventId,
    Value<int>? revision,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return WaterEventsCompanion(
      ownerId: ownerId ?? this.ownerId,
      eventId: eventId ?? this.eventId,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      volumeMilliliters: volumeMilliliters ?? this.volumeMilliliters,
      supersedesEventId: supersedesEventId ?? this.supersedesEventId,
      revision: revision ?? this.revision,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (volumeMilliliters.present) {
      map['volume_milliliters'] = Variable<int>(volumeMilliliters.value);
    }
    if (supersedesEventId.present) {
      map['supersedes_event_id'] = Variable<String>(supersedesEventId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterEventsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('volumeMilliliters: $volumeMilliliters, ')
          ..write('supersedesEventId: $supersedesEventId, ')
          ..write('revision: $revision, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEventsTable extends WeightEvents
    with TableInfo<$WeightEventsTable, WeightEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timezoneOffsetMinutesMeta =
      const VerificationMeta('timezoneOffsetMinutes');
  @override
  late final GeneratedColumn<int> timezoneOffsetMinutes = GeneratedColumn<int>(
    'timezone_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKilogramsMeta = const VerificationMeta(
    'weightKilograms',
  );
  @override
  late final GeneratedColumn<double> weightKilograms = GeneratedColumn<double>(
    'weight_kilograms',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _supersedesEventIdMeta = const VerificationMeta(
    'supersedesEventId',
  );
  @override
  late final GeneratedColumn<String> supersedesEventId =
      GeneratedColumn<String>(
        'supersedes_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    eventId,
    occurredAtUtc,
    timezoneOffsetMinutes,
    createdAtUtc,
    weightKilograms,
    note,
    supersedesEventId,
    revision,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('timezone_offset_minutes')) {
      context.handle(
        _timezoneOffsetMinutesMeta,
        timezoneOffsetMinutes.isAcceptableOrUnknown(
          data['timezone_offset_minutes']!,
          _timezoneOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timezoneOffsetMinutesMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('weight_kilograms')) {
      context.handle(
        _weightKilogramsMeta,
        weightKilograms.isAcceptableOrUnknown(
          data['weight_kilograms']!,
          _weightKilogramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightKilogramsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('supersedes_event_id')) {
      context.handle(
        _supersedesEventIdMeta,
        supersedesEventId.isAcceptableOrUnknown(
          data['supersedes_event_id']!,
          _supersedesEventIdMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, eventId};
  @override
  WeightEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEvent(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      timezoneOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timezone_offset_minutes'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      weightKilograms: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kilograms'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      supersedesEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_event_id'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $WeightEventsTable createAlias(String alias) {
    return $WeightEventsTable(attachedDatabase, alias);
  }
}

class WeightEvent extends DataClass implements Insertable<WeightEvent> {
  final String ownerId;
  final String eventId;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime createdAtUtc;
  final double weightKilograms;
  final String note;
  final String? supersedesEventId;
  final int revision;
  final bool isDeleted;
  const WeightEvent({
    required this.ownerId,
    required this.eventId,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.createdAtUtc,
    required this.weightKilograms,
    required this.note,
    this.supersedesEventId,
    required this.revision,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['event_id'] = Variable<String>(eventId);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['timezone_offset_minutes'] = Variable<int>(timezoneOffsetMinutes);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['weight_kilograms'] = Variable<double>(weightKilograms);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || supersedesEventId != null) {
      map['supersedes_event_id'] = Variable<String>(supersedesEventId);
    }
    map['revision'] = Variable<int>(revision);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  WeightEventsCompanion toCompanion(bool nullToAbsent) {
    return WeightEventsCompanion(
      ownerId: Value(ownerId),
      eventId: Value(eventId),
      occurredAtUtc: Value(occurredAtUtc),
      timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      createdAtUtc: Value(createdAtUtc),
      weightKilograms: Value(weightKilograms),
      note: Value(note),
      supersedesEventId: supersedesEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersedesEventId),
      revision: Value(revision),
      isDeleted: Value(isDeleted),
    );
  }

  factory WeightEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEvent(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      timezoneOffsetMinutes: serializer.fromJson<int>(
        json['timezoneOffsetMinutes'],
      ),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      weightKilograms: serializer.fromJson<double>(json['weightKilograms']),
      note: serializer.fromJson<String>(json['note']),
      supersedesEventId: serializer.fromJson<String?>(
        json['supersedesEventId'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'eventId': serializer.toJson<String>(eventId),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'timezoneOffsetMinutes': serializer.toJson<int>(timezoneOffsetMinutes),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'weightKilograms': serializer.toJson<double>(weightKilograms),
      'note': serializer.toJson<String>(note),
      'supersedesEventId': serializer.toJson<String?>(supersedesEventId),
      'revision': serializer.toJson<int>(revision),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  WeightEvent copyWith({
    String? ownerId,
    String? eventId,
    DateTime? occurredAtUtc,
    int? timezoneOffsetMinutes,
    DateTime? createdAtUtc,
    double? weightKilograms,
    String? note,
    Value<String?> supersedesEventId = const Value.absent(),
    int? revision,
    bool? isDeleted,
  }) => WeightEvent(
    ownerId: ownerId ?? this.ownerId,
    eventId: eventId ?? this.eventId,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    timezoneOffsetMinutes: timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    weightKilograms: weightKilograms ?? this.weightKilograms,
    note: note ?? this.note,
    supersedesEventId: supersedesEventId.present
        ? supersedesEventId.value
        : this.supersedesEventId,
    revision: revision ?? this.revision,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  WeightEvent copyWithCompanion(WeightEventsCompanion data) {
    return WeightEvent(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      timezoneOffsetMinutes: data.timezoneOffsetMinutes.present
          ? data.timezoneOffsetMinutes.value
          : this.timezoneOffsetMinutes,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      weightKilograms: data.weightKilograms.present
          ? data.weightKilograms.value
          : this.weightKilograms,
      note: data.note.present ? data.note.value : this.note,
      supersedesEventId: data.supersedesEventId.present
          ? data.supersedesEventId.value
          : this.supersedesEventId,
      revision: data.revision.present ? data.revision.value : this.revision,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEvent(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('weightKilograms: $weightKilograms, ')
          ..write('note: $note, ')
          ..write('supersedesEventId: $supersedesEventId, ')
          ..write('revision: $revision, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    eventId,
    occurredAtUtc,
    timezoneOffsetMinutes,
    createdAtUtc,
    weightKilograms,
    note,
    supersedesEventId,
    revision,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEvent &&
          other.ownerId == this.ownerId &&
          other.eventId == this.eventId &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.timezoneOffsetMinutes == this.timezoneOffsetMinutes &&
          other.createdAtUtc == this.createdAtUtc &&
          other.weightKilograms == this.weightKilograms &&
          other.note == this.note &&
          other.supersedesEventId == this.supersedesEventId &&
          other.revision == this.revision &&
          other.isDeleted == this.isDeleted);
}

class WeightEventsCompanion extends UpdateCompanion<WeightEvent> {
  final Value<String> ownerId;
  final Value<String> eventId;
  final Value<DateTime> occurredAtUtc;
  final Value<int> timezoneOffsetMinutes;
  final Value<DateTime> createdAtUtc;
  final Value<double> weightKilograms;
  final Value<String> note;
  final Value<String?> supersedesEventId;
  final Value<int> revision;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const WeightEventsCompanion({
    this.ownerId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.timezoneOffsetMinutes = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.weightKilograms = const Value.absent(),
    this.note = const Value.absent(),
    this.supersedesEventId = const Value.absent(),
    this.revision = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEventsCompanion.insert({
    required String ownerId,
    required String eventId,
    required DateTime occurredAtUtc,
    required int timezoneOffsetMinutes,
    required DateTime createdAtUtc,
    required double weightKilograms,
    this.note = const Value.absent(),
    this.supersedesEventId = const Value.absent(),
    required int revision,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       eventId = Value(eventId),
       occurredAtUtc = Value(occurredAtUtc),
       timezoneOffsetMinutes = Value(timezoneOffsetMinutes),
       createdAtUtc = Value(createdAtUtc),
       weightKilograms = Value(weightKilograms),
       revision = Value(revision);
  static Insertable<WeightEvent> custom({
    Expression<String>? ownerId,
    Expression<String>? eventId,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? timezoneOffsetMinutes,
    Expression<DateTime>? createdAtUtc,
    Expression<double>? weightKilograms,
    Expression<String>? note,
    Expression<String>? supersedesEventId,
    Expression<int>? revision,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (eventId != null) 'event_id': eventId,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (weightKilograms != null) 'weight_kilograms': weightKilograms,
      if (note != null) 'note': note,
      if (supersedesEventId != null) 'supersedes_event_id': supersedesEventId,
      if (revision != null) 'revision': revision,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEventsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? eventId,
    Value<DateTime>? occurredAtUtc,
    Value<int>? timezoneOffsetMinutes,
    Value<DateTime>? createdAtUtc,
    Value<double>? weightKilograms,
    Value<String>? note,
    Value<String?>? supersedesEventId,
    Value<int>? revision,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return WeightEventsCompanion(
      ownerId: ownerId ?? this.ownerId,
      eventId: eventId ?? this.eventId,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      timezoneOffsetMinutes:
          timezoneOffsetMinutes ?? this.timezoneOffsetMinutes,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      weightKilograms: weightKilograms ?? this.weightKilograms,
      note: note ?? this.note,
      supersedesEventId: supersedesEventId ?? this.supersedesEventId,
      revision: revision ?? this.revision,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (timezoneOffsetMinutes.present) {
      map['timezone_offset_minutes'] = Variable<int>(
        timezoneOffsetMinutes.value,
      );
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (weightKilograms.present) {
      map['weight_kilograms'] = Variable<double>(weightKilograms.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (supersedesEventId.present) {
      map['supersedes_event_id'] = Variable<String>(supersedesEventId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEventsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('eventId: $eventId, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('timezoneOffsetMinutes: $timezoneOffsetMinutes, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('weightKilograms: $weightKilograms, ')
          ..write('note: $note, ')
          ..write('supersedesEventId: $supersedesEventId, ')
          ..write('revision: $revision, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HydrationPreferencesTable extends HydrationPreferences
    with TableInfo<$HydrationPreferencesTable, HydrationPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HydrationPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMillilitersMeta = const VerificationMeta(
    'targetMilliliters',
  );
  @override
  late final GeneratedColumn<int> targetMilliliters = GeneratedColumn<int>(
    'target_milliliters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSourceMeta = const VerificationMeta(
    'targetSource',
  );
  @override
  late final GeneratedColumn<String> targetSource = GeneratedColumn<String>(
    'target_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _restrictionNoteMeta = const VerificationMeta(
    'restrictionNote',
  );
  @override
  late final GeneratedColumn<String> restrictionNote = GeneratedColumn<String>(
    'restriction_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderStartMinuteMeta =
      const VerificationMeta('reminderStartMinute');
  @override
  late final GeneratedColumn<int> reminderStartMinute = GeneratedColumn<int>(
    'reminder_start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _reminderEndMinuteMeta = const VerificationMeta(
    'reminderEndMinute',
  );
  @override
  late final GeneratedColumn<int> reminderEndMinute = GeneratedColumn<int>(
    'reminder_end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1200),
  );
  static const VerificationMeta _reminderIntervalMinutesMeta =
      const VerificationMeta('reminderIntervalMinutes');
  @override
  late final GeneratedColumn<int> reminderIntervalMinutes =
      GeneratedColumn<int>(
        'reminder_interval_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(120),
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    targetMilliliters,
    targetSource,
    restrictionNote,
    remindersEnabled,
    reminderStartMinute,
    reminderEndMinute,
    reminderIntervalMinutes,
    revision,
    updatedAtUtc,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hydration_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<HydrationPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('target_milliliters')) {
      context.handle(
        _targetMillilitersMeta,
        targetMilliliters.isAcceptableOrUnknown(
          data['target_milliliters']!,
          _targetMillilitersMeta,
        ),
      );
    }
    if (data.containsKey('target_source')) {
      context.handle(
        _targetSourceMeta,
        targetSource.isAcceptableOrUnknown(
          data['target_source']!,
          _targetSourceMeta,
        ),
      );
    }
    if (data.containsKey('restriction_note')) {
      context.handle(
        _restrictionNoteMeta,
        restrictionNote.isAcceptableOrUnknown(
          data['restriction_note']!,
          _restrictionNoteMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_start_minute')) {
      context.handle(
        _reminderStartMinuteMeta,
        reminderStartMinute.isAcceptableOrUnknown(
          data['reminder_start_minute']!,
          _reminderStartMinuteMeta,
        ),
      );
    }
    if (data.containsKey('reminder_end_minute')) {
      context.handle(
        _reminderEndMinuteMeta,
        reminderEndMinute.isAcceptableOrUnknown(
          data['reminder_end_minute']!,
          _reminderEndMinuteMeta,
        ),
      );
    }
    if (data.containsKey('reminder_interval_minutes')) {
      context.handle(
        _reminderIntervalMinutesMeta,
        reminderIntervalMinutes.isAcceptableOrUnknown(
          data['reminder_interval_minutes']!,
          _reminderIntervalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId};
  @override
  HydrationPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HydrationPreference(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      targetMilliliters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_milliliters'],
      ),
      targetSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_source'],
      )!,
      restrictionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restriction_note'],
      )!,
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      reminderStartMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_start_minute'],
      )!,
      reminderEndMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_end_minute'],
      )!,
      reminderIntervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_interval_minutes'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $HydrationPreferencesTable createAlias(String alias) {
    return $HydrationPreferencesTable(attachedDatabase, alias);
  }
}

class HydrationPreference extends DataClass
    implements Insertable<HydrationPreference> {
  final String ownerId;
  final int? targetMilliliters;
  final String targetSource;
  final String restrictionNote;
  final bool remindersEnabled;
  final int reminderStartMinute;
  final int reminderEndMinute;
  final int reminderIntervalMinutes;
  final int revision;
  final DateTime updatedAtUtc;
  final bool isDeleted;
  const HydrationPreference({
    required this.ownerId,
    this.targetMilliliters,
    required this.targetSource,
    required this.restrictionNote,
    required this.remindersEnabled,
    required this.reminderStartMinute,
    required this.reminderEndMinute,
    required this.reminderIntervalMinutes,
    required this.revision,
    required this.updatedAtUtc,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || targetMilliliters != null) {
      map['target_milliliters'] = Variable<int>(targetMilliliters);
    }
    map['target_source'] = Variable<String>(targetSource);
    map['restriction_note'] = Variable<String>(restrictionNote);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['reminder_start_minute'] = Variable<int>(reminderStartMinute);
    map['reminder_end_minute'] = Variable<int>(reminderEndMinute);
    map['reminder_interval_minutes'] = Variable<int>(reminderIntervalMinutes);
    map['revision'] = Variable<int>(revision);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  HydrationPreferencesCompanion toCompanion(bool nullToAbsent) {
    return HydrationPreferencesCompanion(
      ownerId: Value(ownerId),
      targetMilliliters: targetMilliliters == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMilliliters),
      targetSource: Value(targetSource),
      restrictionNote: Value(restrictionNote),
      remindersEnabled: Value(remindersEnabled),
      reminderStartMinute: Value(reminderStartMinute),
      reminderEndMinute: Value(reminderEndMinute),
      reminderIntervalMinutes: Value(reminderIntervalMinutes),
      revision: Value(revision),
      updatedAtUtc: Value(updatedAtUtc),
      isDeleted: Value(isDeleted),
    );
  }

  factory HydrationPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HydrationPreference(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      targetMilliliters: serializer.fromJson<int?>(json['targetMilliliters']),
      targetSource: serializer.fromJson<String>(json['targetSource']),
      restrictionNote: serializer.fromJson<String>(json['restrictionNote']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      reminderStartMinute: serializer.fromJson<int>(
        json['reminderStartMinute'],
      ),
      reminderEndMinute: serializer.fromJson<int>(json['reminderEndMinute']),
      reminderIntervalMinutes: serializer.fromJson<int>(
        json['reminderIntervalMinutes'],
      ),
      revision: serializer.fromJson<int>(json['revision']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'targetMilliliters': serializer.toJson<int?>(targetMilliliters),
      'targetSource': serializer.toJson<String>(targetSource),
      'restrictionNote': serializer.toJson<String>(restrictionNote),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'reminderStartMinute': serializer.toJson<int>(reminderStartMinute),
      'reminderEndMinute': serializer.toJson<int>(reminderEndMinute),
      'reminderIntervalMinutes': serializer.toJson<int>(
        reminderIntervalMinutes,
      ),
      'revision': serializer.toJson<int>(revision),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  HydrationPreference copyWith({
    String? ownerId,
    Value<int?> targetMilliliters = const Value.absent(),
    String? targetSource,
    String? restrictionNote,
    bool? remindersEnabled,
    int? reminderStartMinute,
    int? reminderEndMinute,
    int? reminderIntervalMinutes,
    int? revision,
    DateTime? updatedAtUtc,
    bool? isDeleted,
  }) => HydrationPreference(
    ownerId: ownerId ?? this.ownerId,
    targetMilliliters: targetMilliliters.present
        ? targetMilliliters.value
        : this.targetMilliliters,
    targetSource: targetSource ?? this.targetSource,
    restrictionNote: restrictionNote ?? this.restrictionNote,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    reminderStartMinute: reminderStartMinute ?? this.reminderStartMinute,
    reminderEndMinute: reminderEndMinute ?? this.reminderEndMinute,
    reminderIntervalMinutes:
        reminderIntervalMinutes ?? this.reminderIntervalMinutes,
    revision: revision ?? this.revision,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  HydrationPreference copyWithCompanion(HydrationPreferencesCompanion data) {
    return HydrationPreference(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      targetMilliliters: data.targetMilliliters.present
          ? data.targetMilliliters.value
          : this.targetMilliliters,
      targetSource: data.targetSource.present
          ? data.targetSource.value
          : this.targetSource,
      restrictionNote: data.restrictionNote.present
          ? data.restrictionNote.value
          : this.restrictionNote,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      reminderStartMinute: data.reminderStartMinute.present
          ? data.reminderStartMinute.value
          : this.reminderStartMinute,
      reminderEndMinute: data.reminderEndMinute.present
          ? data.reminderEndMinute.value
          : this.reminderEndMinute,
      reminderIntervalMinutes: data.reminderIntervalMinutes.present
          ? data.reminderIntervalMinutes.value
          : this.reminderIntervalMinutes,
      revision: data.revision.present ? data.revision.value : this.revision,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HydrationPreference(')
          ..write('ownerId: $ownerId, ')
          ..write('targetMilliliters: $targetMilliliters, ')
          ..write('targetSource: $targetSource, ')
          ..write('restrictionNote: $restrictionNote, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderStartMinute: $reminderStartMinute, ')
          ..write('reminderEndMinute: $reminderEndMinute, ')
          ..write('reminderIntervalMinutes: $reminderIntervalMinutes, ')
          ..write('revision: $revision, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    targetMilliliters,
    targetSource,
    restrictionNote,
    remindersEnabled,
    reminderStartMinute,
    reminderEndMinute,
    reminderIntervalMinutes,
    revision,
    updatedAtUtc,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HydrationPreference &&
          other.ownerId == this.ownerId &&
          other.targetMilliliters == this.targetMilliliters &&
          other.targetSource == this.targetSource &&
          other.restrictionNote == this.restrictionNote &&
          other.remindersEnabled == this.remindersEnabled &&
          other.reminderStartMinute == this.reminderStartMinute &&
          other.reminderEndMinute == this.reminderEndMinute &&
          other.reminderIntervalMinutes == this.reminderIntervalMinutes &&
          other.revision == this.revision &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.isDeleted == this.isDeleted);
}

class HydrationPreferencesCompanion
    extends UpdateCompanion<HydrationPreference> {
  final Value<String> ownerId;
  final Value<int?> targetMilliliters;
  final Value<String> targetSource;
  final Value<String> restrictionNote;
  final Value<bool> remindersEnabled;
  final Value<int> reminderStartMinute;
  final Value<int> reminderEndMinute;
  final Value<int> reminderIntervalMinutes;
  final Value<int> revision;
  final Value<DateTime> updatedAtUtc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const HydrationPreferencesCompanion({
    this.ownerId = const Value.absent(),
    this.targetMilliliters = const Value.absent(),
    this.targetSource = const Value.absent(),
    this.restrictionNote = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderStartMinute = const Value.absent(),
    this.reminderEndMinute = const Value.absent(),
    this.reminderIntervalMinutes = const Value.absent(),
    this.revision = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HydrationPreferencesCompanion.insert({
    required String ownerId,
    this.targetMilliliters = const Value.absent(),
    this.targetSource = const Value.absent(),
    this.restrictionNote = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.reminderStartMinute = const Value.absent(),
    this.reminderEndMinute = const Value.absent(),
    this.reminderIntervalMinutes = const Value.absent(),
    required int revision,
    required DateTime updatedAtUtc,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       revision = Value(revision),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<HydrationPreference> custom({
    Expression<String>? ownerId,
    Expression<int>? targetMilliliters,
    Expression<String>? targetSource,
    Expression<String>? restrictionNote,
    Expression<bool>? remindersEnabled,
    Expression<int>? reminderStartMinute,
    Expression<int>? reminderEndMinute,
    Expression<int>? reminderIntervalMinutes,
    Expression<int>? revision,
    Expression<DateTime>? updatedAtUtc,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (targetMilliliters != null) 'target_milliliters': targetMilliliters,
      if (targetSource != null) 'target_source': targetSource,
      if (restrictionNote != null) 'restriction_note': restrictionNote,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (reminderStartMinute != null)
        'reminder_start_minute': reminderStartMinute,
      if (reminderEndMinute != null) 'reminder_end_minute': reminderEndMinute,
      if (reminderIntervalMinutes != null)
        'reminder_interval_minutes': reminderIntervalMinutes,
      if (revision != null) 'revision': revision,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HydrationPreferencesCompanion copyWith({
    Value<String>? ownerId,
    Value<int?>? targetMilliliters,
    Value<String>? targetSource,
    Value<String>? restrictionNote,
    Value<bool>? remindersEnabled,
    Value<int>? reminderStartMinute,
    Value<int>? reminderEndMinute,
    Value<int>? reminderIntervalMinutes,
    Value<int>? revision,
    Value<DateTime>? updatedAtUtc,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return HydrationPreferencesCompanion(
      ownerId: ownerId ?? this.ownerId,
      targetMilliliters: targetMilliliters ?? this.targetMilliliters,
      targetSource: targetSource ?? this.targetSource,
      restrictionNote: restrictionNote ?? this.restrictionNote,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderStartMinute: reminderStartMinute ?? this.reminderStartMinute,
      reminderEndMinute: reminderEndMinute ?? this.reminderEndMinute,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      revision: revision ?? this.revision,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (targetMilliliters.present) {
      map['target_milliliters'] = Variable<int>(targetMilliliters.value);
    }
    if (targetSource.present) {
      map['target_source'] = Variable<String>(targetSource.value);
    }
    if (restrictionNote.present) {
      map['restriction_note'] = Variable<String>(restrictionNote.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (reminderStartMinute.present) {
      map['reminder_start_minute'] = Variable<int>(reminderStartMinute.value);
    }
    if (reminderEndMinute.present) {
      map['reminder_end_minute'] = Variable<int>(reminderEndMinute.value);
    }
    if (reminderIntervalMinutes.present) {
      map['reminder_interval_minutes'] = Variable<int>(
        reminderIntervalMinutes.value,
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HydrationPreferencesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('targetMilliliters: $targetMilliliters, ')
          ..write('targetSource: $targetSource, ')
          ..write('restrictionNote: $restrictionNote, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('reminderStartMinute: $reminderStartMinute, ')
          ..write('reminderEndMinute: $reminderEndMinute, ')
          ..write('reminderIntervalMinutes: $reminderIntervalMinutes, ')
          ..write('revision: $revision, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomFoodsTable extends CustomFoods
    with TableInfo<$CustomFoodsTable, CustomFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customFoodIdMeta = const VerificationMeta(
    'customFoodId',
  );
  @override
  late final GeneratedColumn<String> customFoodId = GeneratedColumn<String>(
    'custom_food_id',
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsPerServingMeta = const VerificationMeta(
    'gramsPerServing',
  );
  @override
  late final GeneratedColumn<double> gramsPerServing = GeneratedColumn<double>(
    'grams_per_serving',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<double> caloriesKcal = GeneratedColumn<double>(
    'calories_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbohydrateGramsMeta = const VerificationMeta(
    'carbohydrateGrams',
  );
  @override
  late final GeneratedColumn<double> carbohydrateGrams =
      GeneratedColumn<double>(
        'carbohydrate_grams',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMilligramsMeta = const VerificationMeta(
    'sodiumMilligrams',
  );
  @override
  late final GeneratedColumn<double> sodiumMilligrams = GeneratedColumn<double>(
    'sodium_milligrams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    customFoodId,
    name,
    normalizedName,
    servingLabel,
    unitCode,
    gramsPerServing,
    caloriesKcal,
    proteinGrams,
    carbohydrateGrams,
    fatGrams,
    sodiumMilligrams,
    revision,
    createdAtUtc,
    updatedAtUtc,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('custom_food_id')) {
      context.handle(
        _customFoodIdMeta,
        customFoodId.isAcceptableOrUnknown(
          data['custom_food_id']!,
          _customFoodIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customFoodIdMeta);
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
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingLabelMeta);
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('grams_per_serving')) {
      context.handle(
        _gramsPerServingMeta,
        gramsPerServing.isAcceptableOrUnknown(
          data['grams_per_serving']!,
          _gramsPerServingMeta,
        ),
      );
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesKcalMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbohydrate_grams')) {
      context.handle(
        _carbohydrateGramsMeta,
        carbohydrateGrams.isAcceptableOrUnknown(
          data['carbohydrate_grams']!,
          _carbohydrateGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('sodium_milligrams')) {
      context.handle(
        _sodiumMilligramsMeta,
        sodiumMilligrams.isAcceptableOrUnknown(
          data['sodium_milligrams']!,
          _sodiumMilligramsMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, customFoodId};
  @override
  CustomFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomFood(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      customFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_food_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      gramsPerServing: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_per_serving'],
      ),
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_kcal'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbohydrateGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      sodiumMilligrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_milligrams'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CustomFoodsTable createAlias(String alias) {
    return $CustomFoodsTable(attachedDatabase, alias);
  }
}

class CustomFood extends DataClass implements Insertable<CustomFood> {
  final String ownerId;
  final String customFoodId;
  final String name;
  final String normalizedName;
  final String servingLabel;
  final String unitCode;
  final double? gramsPerServing;
  final double caloriesKcal;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double? sodiumMilligrams;
  final int revision;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final bool isDeleted;
  const CustomFood({
    required this.ownerId,
    required this.customFoodId,
    required this.name,
    required this.normalizedName,
    required this.servingLabel,
    required this.unitCode,
    this.gramsPerServing,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.sodiumMilligrams,
    required this.revision,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['custom_food_id'] = Variable<String>(customFoodId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['serving_label'] = Variable<String>(servingLabel);
    map['unit_code'] = Variable<String>(unitCode);
    if (!nullToAbsent || gramsPerServing != null) {
      map['grams_per_serving'] = Variable<double>(gramsPerServing);
    }
    map['calories_kcal'] = Variable<double>(caloriesKcal);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbohydrate_grams'] = Variable<double>(carbohydrateGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    if (!nullToAbsent || sodiumMilligrams != null) {
      map['sodium_milligrams'] = Variable<double>(sodiumMilligrams);
    }
    map['revision'] = Variable<int>(revision);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CustomFoodsCompanion toCompanion(bool nullToAbsent) {
    return CustomFoodsCompanion(
      ownerId: Value(ownerId),
      customFoodId: Value(customFoodId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      servingLabel: Value(servingLabel),
      unitCode: Value(unitCode),
      gramsPerServing: gramsPerServing == null && nullToAbsent
          ? const Value.absent()
          : Value(gramsPerServing),
      caloriesKcal: Value(caloriesKcal),
      proteinGrams: Value(proteinGrams),
      carbohydrateGrams: Value(carbohydrateGrams),
      fatGrams: Value(fatGrams),
      sodiumMilligrams: sodiumMilligrams == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMilligrams),
      revision: Value(revision),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      isDeleted: Value(isDeleted),
    );
  }

  factory CustomFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomFood(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      customFoodId: serializer.fromJson<String>(json['customFoodId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      unitCode: serializer.fromJson<String>(json['unitCode']),
      gramsPerServing: serializer.fromJson<double?>(json['gramsPerServing']),
      caloriesKcal: serializer.fromJson<double>(json['caloriesKcal']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbohydrateGrams: serializer.fromJson<double>(json['carbohydrateGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      sodiumMilligrams: serializer.fromJson<double?>(json['sodiumMilligrams']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'customFoodId': serializer.toJson<String>(customFoodId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'unitCode': serializer.toJson<String>(unitCode),
      'gramsPerServing': serializer.toJson<double?>(gramsPerServing),
      'caloriesKcal': serializer.toJson<double>(caloriesKcal),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbohydrateGrams': serializer.toJson<double>(carbohydrateGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'sodiumMilligrams': serializer.toJson<double?>(sodiumMilligrams),
      'revision': serializer.toJson<int>(revision),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  CustomFood copyWith({
    String? ownerId,
    String? customFoodId,
    String? name,
    String? normalizedName,
    String? servingLabel,
    String? unitCode,
    Value<double?> gramsPerServing = const Value.absent(),
    double? caloriesKcal,
    double? proteinGrams,
    double? carbohydrateGrams,
    double? fatGrams,
    Value<double?> sodiumMilligrams = const Value.absent(),
    int? revision,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    bool? isDeleted,
  }) => CustomFood(
    ownerId: ownerId ?? this.ownerId,
    customFoodId: customFoodId ?? this.customFoodId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    servingLabel: servingLabel ?? this.servingLabel,
    unitCode: unitCode ?? this.unitCode,
    gramsPerServing: gramsPerServing.present
        ? gramsPerServing.value
        : this.gramsPerServing,
    caloriesKcal: caloriesKcal ?? this.caloriesKcal,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    sodiumMilligrams: sodiumMilligrams.present
        ? sodiumMilligrams.value
        : this.sodiumMilligrams,
    revision: revision ?? this.revision,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  CustomFood copyWithCompanion(CustomFoodsCompanion data) {
    return CustomFood(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      customFoodId: data.customFoodId.present
          ? data.customFoodId.value
          : this.customFoodId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      gramsPerServing: data.gramsPerServing.present
          ? data.gramsPerServing.value
          : this.gramsPerServing,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbohydrateGrams: data.carbohydrateGrams.present
          ? data.carbohydrateGrams.value
          : this.carbohydrateGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      sodiumMilligrams: data.sodiumMilligrams.present
          ? data.sodiumMilligrams.value
          : this.sodiumMilligrams,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomFood(')
          ..write('ownerId: $ownerId, ')
          ..write('customFoodId: $customFoodId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('unitCode: $unitCode, ')
          ..write('gramsPerServing: $gramsPerServing, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbohydrateGrams: $carbohydrateGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('sodiumMilligrams: $sodiumMilligrams, ')
          ..write('revision: $revision, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    customFoodId,
    name,
    normalizedName,
    servingLabel,
    unitCode,
    gramsPerServing,
    caloriesKcal,
    proteinGrams,
    carbohydrateGrams,
    fatGrams,
    sodiumMilligrams,
    revision,
    createdAtUtc,
    updatedAtUtc,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomFood &&
          other.ownerId == this.ownerId &&
          other.customFoodId == this.customFoodId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.servingLabel == this.servingLabel &&
          other.unitCode == this.unitCode &&
          other.gramsPerServing == this.gramsPerServing &&
          other.caloriesKcal == this.caloriesKcal &&
          other.proteinGrams == this.proteinGrams &&
          other.carbohydrateGrams == this.carbohydrateGrams &&
          other.fatGrams == this.fatGrams &&
          other.sodiumMilligrams == this.sodiumMilligrams &&
          other.revision == this.revision &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.isDeleted == this.isDeleted);
}

class CustomFoodsCompanion extends UpdateCompanion<CustomFood> {
  final Value<String> ownerId;
  final Value<String> customFoodId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> servingLabel;
  final Value<String> unitCode;
  final Value<double?> gramsPerServing;
  final Value<double> caloriesKcal;
  final Value<double> proteinGrams;
  final Value<double> carbohydrateGrams;
  final Value<double> fatGrams;
  final Value<double?> sodiumMilligrams;
  final Value<int> revision;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CustomFoodsCompanion({
    this.ownerId = const Value.absent(),
    this.customFoodId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.gramsPerServing = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbohydrateGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.sodiumMilligrams = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomFoodsCompanion.insert({
    required String ownerId,
    required String customFoodId,
    required String name,
    required String normalizedName,
    required String servingLabel,
    required String unitCode,
    this.gramsPerServing = const Value.absent(),
    required double caloriesKcal,
    required double proteinGrams,
    required double carbohydrateGrams,
    required double fatGrams,
    this.sodiumMilligrams = const Value.absent(),
    required int revision,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       customFoodId = Value(customFoodId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       servingLabel = Value(servingLabel),
       unitCode = Value(unitCode),
       caloriesKcal = Value(caloriesKcal),
       proteinGrams = Value(proteinGrams),
       carbohydrateGrams = Value(carbohydrateGrams),
       fatGrams = Value(fatGrams),
       revision = Value(revision),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CustomFood> custom({
    Expression<String>? ownerId,
    Expression<String>? customFoodId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? servingLabel,
    Expression<String>? unitCode,
    Expression<double>? gramsPerServing,
    Expression<double>? caloriesKcal,
    Expression<double>? proteinGrams,
    Expression<double>? carbohydrateGrams,
    Expression<double>? fatGrams,
    Expression<double>? sodiumMilligrams,
    Expression<int>? revision,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (customFoodId != null) 'custom_food_id': customFoodId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (unitCode != null) 'unit_code': unitCode,
      if (gramsPerServing != null) 'grams_per_serving': gramsPerServing,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbohydrateGrams != null) 'carbohydrate_grams': carbohydrateGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (sodiumMilligrams != null) 'sodium_milligrams': sodiumMilligrams,
      if (revision != null) 'revision': revision,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomFoodsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? customFoodId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? servingLabel,
    Value<String>? unitCode,
    Value<double?>? gramsPerServing,
    Value<double>? caloriesKcal,
    Value<double>? proteinGrams,
    Value<double>? carbohydrateGrams,
    Value<double>? fatGrams,
    Value<double?>? sodiumMilligrams,
    Value<int>? revision,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CustomFoodsCompanion(
      ownerId: ownerId ?? this.ownerId,
      customFoodId: customFoodId ?? this.customFoodId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      servingLabel: servingLabel ?? this.servingLabel,
      unitCode: unitCode ?? this.unitCode,
      gramsPerServing: gramsPerServing ?? this.gramsPerServing,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbohydrateGrams: carbohydrateGrams ?? this.carbohydrateGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      sodiumMilligrams: sodiumMilligrams ?? this.sodiumMilligrams,
      revision: revision ?? this.revision,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (customFoodId.present) {
      map['custom_food_id'] = Variable<String>(customFoodId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (gramsPerServing.present) {
      map['grams_per_serving'] = Variable<double>(gramsPerServing.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<double>(caloriesKcal.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbohydrateGrams.present) {
      map['carbohydrate_grams'] = Variable<double>(carbohydrateGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (sodiumMilligrams.present) {
      map['sodium_milligrams'] = Variable<double>(sodiumMilligrams.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomFoodsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('customFoodId: $customFoodId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('unitCode: $unitCode, ')
          ..write('gramsPerServing: $gramsPerServing, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbohydrateGrams: $carbohydrateGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('sodiumMilligrams: $sodiumMilligrams, ')
          ..write('revision: $revision, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodNotFoundNotesTable extends FoodNotFoundNotes
    with TableInfo<$FoodNotFoundNotesTable, FoodNotFoundNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodNotFoundNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedSearchTextMeta =
      const VerificationMeta('normalizedSearchText');
  @override
  late final GeneratedColumn<String> normalizedSearchText =
      GeneratedColumn<String>(
        'normalized_search_text',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    noteId,
    searchText,
    normalizedSearchText,
    details,
    status,
    revision,
    createdAtUtc,
    updatedAtUtc,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_not_found_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodNotFoundNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('normalized_search_text')) {
      context.handle(
        _normalizedSearchTextMeta,
        normalizedSearchText.isAcceptableOrUnknown(
          data['normalized_search_text']!,
          _normalizedSearchTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedSearchTextMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, noteId};
  @override
  FoodNotFoundNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodNotFoundNote(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      normalizedSearchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_search_text'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $FoodNotFoundNotesTable createAlias(String alias) {
    return $FoodNotFoundNotesTable(attachedDatabase, alias);
  }
}

class FoodNotFoundNote extends DataClass
    implements Insertable<FoodNotFoundNote> {
  final String ownerId;
  final String noteId;
  final String searchText;
  final String normalizedSearchText;
  final String details;
  final String status;
  final int revision;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final bool isDeleted;
  const FoodNotFoundNote({
    required this.ownerId,
    required this.noteId,
    required this.searchText,
    required this.normalizedSearchText,
    required this.details,
    required this.status,
    required this.revision,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['note_id'] = Variable<String>(noteId);
    map['search_text'] = Variable<String>(searchText);
    map['normalized_search_text'] = Variable<String>(normalizedSearchText);
    map['details'] = Variable<String>(details);
    map['status'] = Variable<String>(status);
    map['revision'] = Variable<int>(revision);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  FoodNotFoundNotesCompanion toCompanion(bool nullToAbsent) {
    return FoodNotFoundNotesCompanion(
      ownerId: Value(ownerId),
      noteId: Value(noteId),
      searchText: Value(searchText),
      normalizedSearchText: Value(normalizedSearchText),
      details: Value(details),
      status: Value(status),
      revision: Value(revision),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      isDeleted: Value(isDeleted),
    );
  }

  factory FoodNotFoundNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodNotFoundNote(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      noteId: serializer.fromJson<String>(json['noteId']),
      searchText: serializer.fromJson<String>(json['searchText']),
      normalizedSearchText: serializer.fromJson<String>(
        json['normalizedSearchText'],
      ),
      details: serializer.fromJson<String>(json['details']),
      status: serializer.fromJson<String>(json['status']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'noteId': serializer.toJson<String>(noteId),
      'searchText': serializer.toJson<String>(searchText),
      'normalizedSearchText': serializer.toJson<String>(normalizedSearchText),
      'details': serializer.toJson<String>(details),
      'status': serializer.toJson<String>(status),
      'revision': serializer.toJson<int>(revision),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  FoodNotFoundNote copyWith({
    String? ownerId,
    String? noteId,
    String? searchText,
    String? normalizedSearchText,
    String? details,
    String? status,
    int? revision,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    bool? isDeleted,
  }) => FoodNotFoundNote(
    ownerId: ownerId ?? this.ownerId,
    noteId: noteId ?? this.noteId,
    searchText: searchText ?? this.searchText,
    normalizedSearchText: normalizedSearchText ?? this.normalizedSearchText,
    details: details ?? this.details,
    status: status ?? this.status,
    revision: revision ?? this.revision,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  FoodNotFoundNote copyWithCompanion(FoodNotFoundNotesCompanion data) {
    return FoodNotFoundNote(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      normalizedSearchText: data.normalizedSearchText.present
          ? data.normalizedSearchText.value
          : this.normalizedSearchText,
      details: data.details.present ? data.details.value : this.details,
      status: data.status.present ? data.status.value : this.status,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodNotFoundNote(')
          ..write('ownerId: $ownerId, ')
          ..write('noteId: $noteId, ')
          ..write('searchText: $searchText, ')
          ..write('normalizedSearchText: $normalizedSearchText, ')
          ..write('details: $details, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    noteId,
    searchText,
    normalizedSearchText,
    details,
    status,
    revision,
    createdAtUtc,
    updatedAtUtc,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodNotFoundNote &&
          other.ownerId == this.ownerId &&
          other.noteId == this.noteId &&
          other.searchText == this.searchText &&
          other.normalizedSearchText == this.normalizedSearchText &&
          other.details == this.details &&
          other.status == this.status &&
          other.revision == this.revision &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.isDeleted == this.isDeleted);
}

class FoodNotFoundNotesCompanion extends UpdateCompanion<FoodNotFoundNote> {
  final Value<String> ownerId;
  final Value<String> noteId;
  final Value<String> searchText;
  final Value<String> normalizedSearchText;
  final Value<String> details;
  final Value<String> status;
  final Value<int> revision;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const FoodNotFoundNotesCompanion({
    this.ownerId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.searchText = const Value.absent(),
    this.normalizedSearchText = const Value.absent(),
    this.details = const Value.absent(),
    this.status = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodNotFoundNotesCompanion.insert({
    required String ownerId,
    required String noteId,
    required String searchText,
    required String normalizedSearchText,
    required String details,
    this.status = const Value.absent(),
    required int revision,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       noteId = Value(noteId),
       searchText = Value(searchText),
       normalizedSearchText = Value(normalizedSearchText),
       details = Value(details),
       revision = Value(revision),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<FoodNotFoundNote> custom({
    Expression<String>? ownerId,
    Expression<String>? noteId,
    Expression<String>? searchText,
    Expression<String>? normalizedSearchText,
    Expression<String>? details,
    Expression<String>? status,
    Expression<int>? revision,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (noteId != null) 'note_id': noteId,
      if (searchText != null) 'search_text': searchText,
      if (normalizedSearchText != null)
        'normalized_search_text': normalizedSearchText,
      if (details != null) 'details': details,
      if (status != null) 'status': status,
      if (revision != null) 'revision': revision,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodNotFoundNotesCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? noteId,
    Value<String>? searchText,
    Value<String>? normalizedSearchText,
    Value<String>? details,
    Value<String>? status,
    Value<int>? revision,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return FoodNotFoundNotesCompanion(
      ownerId: ownerId ?? this.ownerId,
      noteId: noteId ?? this.noteId,
      searchText: searchText ?? this.searchText,
      normalizedSearchText: normalizedSearchText ?? this.normalizedSearchText,
      details: details ?? this.details,
      status: status ?? this.status,
      revision: revision ?? this.revision,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (normalizedSearchText.present) {
      map['normalized_search_text'] = Variable<String>(
        normalizedSearchText.value,
      );
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodNotFoundNotesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('noteId: $noteId, ')
          ..write('searchText: $searchText, ')
          ..write('normalizedSearchText: $normalizedSearchText, ')
          ..write('details: $details, ')
          ..write('status: $status, ')
          ..write('revision: $revision, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomRecipesTable extends CustomRecipes
    with TableInfo<$CustomRecipesTable, CustomRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customRecipeIdMeta = const VerificationMeta(
    'customRecipeId',
  );
  @override
  late final GeneratedColumn<String> customRecipeId = GeneratedColumn<String>(
    'custom_recipe_id',
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
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yieldServingsMinimumMeta =
      const VerificationMeta('yieldServingsMinimum');
  @override
  late final GeneratedColumn<double> yieldServingsMinimum =
      GeneratedColumn<double>(
        'yield_servings_minimum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _yieldServingsMaximumMeta =
      const VerificationMeta('yieldServingsMaximum');
  @override
  late final GeneratedColumn<double> yieldServingsMaximum =
      GeneratedColumn<double>(
        'yield_servings_maximum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _oilTreatmentMeta = const VerificationMeta(
    'oilTreatment',
  );
  @override
  late final GeneratedColumn<String> oilTreatment = GeneratedColumn<String>(
    'oil_treatment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    customRecipeId,
    name,
    normalizedName,
    yieldServingsMinimum,
    yieldServingsMaximum,
    oilTreatment,
    revision,
    createdAtUtc,
    updatedAtUtc,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomRecipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('custom_recipe_id')) {
      context.handle(
        _customRecipeIdMeta,
        customRecipeId.isAcceptableOrUnknown(
          data['custom_recipe_id']!,
          _customRecipeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customRecipeIdMeta);
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
    if (data.containsKey('yield_servings_minimum')) {
      context.handle(
        _yieldServingsMinimumMeta,
        yieldServingsMinimum.isAcceptableOrUnknown(
          data['yield_servings_minimum']!,
          _yieldServingsMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_yieldServingsMinimumMeta);
    }
    if (data.containsKey('yield_servings_maximum')) {
      context.handle(
        _yieldServingsMaximumMeta,
        yieldServingsMaximum.isAcceptableOrUnknown(
          data['yield_servings_maximum']!,
          _yieldServingsMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_yieldServingsMaximumMeta);
    }
    if (data.containsKey('oil_treatment')) {
      context.handle(
        _oilTreatmentMeta,
        oilTreatment.isAcceptableOrUnknown(
          data['oil_treatment']!,
          _oilTreatmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oilTreatmentMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, customRecipeId};
  @override
  CustomRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomRecipe(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      customRecipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_recipe_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      yieldServingsMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yield_servings_minimum'],
      )!,
      yieldServingsMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yield_servings_maximum'],
      )!,
      oilTreatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oil_treatment'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $CustomRecipesTable createAlias(String alias) {
    return $CustomRecipesTable(attachedDatabase, alias);
  }
}

class CustomRecipe extends DataClass implements Insertable<CustomRecipe> {
  final String ownerId;
  final String customRecipeId;
  final String name;
  final String normalizedName;
  final double yieldServingsMinimum;
  final double yieldServingsMaximum;
  final String oilTreatment;
  final int revision;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final bool isDeleted;
  const CustomRecipe({
    required this.ownerId,
    required this.customRecipeId,
    required this.name,
    required this.normalizedName,
    required this.yieldServingsMinimum,
    required this.yieldServingsMaximum,
    required this.oilTreatment,
    required this.revision,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['custom_recipe_id'] = Variable<String>(customRecipeId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['yield_servings_minimum'] = Variable<double>(yieldServingsMinimum);
    map['yield_servings_maximum'] = Variable<double>(yieldServingsMaximum);
    map['oil_treatment'] = Variable<String>(oilTreatment);
    map['revision'] = Variable<int>(revision);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  CustomRecipesCompanion toCompanion(bool nullToAbsent) {
    return CustomRecipesCompanion(
      ownerId: Value(ownerId),
      customRecipeId: Value(customRecipeId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      yieldServingsMinimum: Value(yieldServingsMinimum),
      yieldServingsMaximum: Value(yieldServingsMaximum),
      oilTreatment: Value(oilTreatment),
      revision: Value(revision),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      isDeleted: Value(isDeleted),
    );
  }

  factory CustomRecipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomRecipe(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      customRecipeId: serializer.fromJson<String>(json['customRecipeId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      yieldServingsMinimum: serializer.fromJson<double>(
        json['yieldServingsMinimum'],
      ),
      yieldServingsMaximum: serializer.fromJson<double>(
        json['yieldServingsMaximum'],
      ),
      oilTreatment: serializer.fromJson<String>(json['oilTreatment']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'customRecipeId': serializer.toJson<String>(customRecipeId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'yieldServingsMinimum': serializer.toJson<double>(yieldServingsMinimum),
      'yieldServingsMaximum': serializer.toJson<double>(yieldServingsMaximum),
      'oilTreatment': serializer.toJson<String>(oilTreatment),
      'revision': serializer.toJson<int>(revision),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  CustomRecipe copyWith({
    String? ownerId,
    String? customRecipeId,
    String? name,
    String? normalizedName,
    double? yieldServingsMinimum,
    double? yieldServingsMaximum,
    String? oilTreatment,
    int? revision,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    bool? isDeleted,
  }) => CustomRecipe(
    ownerId: ownerId ?? this.ownerId,
    customRecipeId: customRecipeId ?? this.customRecipeId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    yieldServingsMinimum: yieldServingsMinimum ?? this.yieldServingsMinimum,
    yieldServingsMaximum: yieldServingsMaximum ?? this.yieldServingsMaximum,
    oilTreatment: oilTreatment ?? this.oilTreatment,
    revision: revision ?? this.revision,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  CustomRecipe copyWithCompanion(CustomRecipesCompanion data) {
    return CustomRecipe(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      customRecipeId: data.customRecipeId.present
          ? data.customRecipeId.value
          : this.customRecipeId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      yieldServingsMinimum: data.yieldServingsMinimum.present
          ? data.yieldServingsMinimum.value
          : this.yieldServingsMinimum,
      yieldServingsMaximum: data.yieldServingsMaximum.present
          ? data.yieldServingsMaximum.value
          : this.yieldServingsMaximum,
      oilTreatment: data.oilTreatment.present
          ? data.oilTreatment.value
          : this.oilTreatment,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomRecipe(')
          ..write('ownerId: $ownerId, ')
          ..write('customRecipeId: $customRecipeId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('yieldServingsMinimum: $yieldServingsMinimum, ')
          ..write('yieldServingsMaximum: $yieldServingsMaximum, ')
          ..write('oilTreatment: $oilTreatment, ')
          ..write('revision: $revision, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    customRecipeId,
    name,
    normalizedName,
    yieldServingsMinimum,
    yieldServingsMaximum,
    oilTreatment,
    revision,
    createdAtUtc,
    updatedAtUtc,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomRecipe &&
          other.ownerId == this.ownerId &&
          other.customRecipeId == this.customRecipeId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.yieldServingsMinimum == this.yieldServingsMinimum &&
          other.yieldServingsMaximum == this.yieldServingsMaximum &&
          other.oilTreatment == this.oilTreatment &&
          other.revision == this.revision &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.isDeleted == this.isDeleted);
}

class CustomRecipesCompanion extends UpdateCompanion<CustomRecipe> {
  final Value<String> ownerId;
  final Value<String> customRecipeId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<double> yieldServingsMinimum;
  final Value<double> yieldServingsMaximum;
  final Value<String> oilTreatment;
  final Value<int> revision;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const CustomRecipesCompanion({
    this.ownerId = const Value.absent(),
    this.customRecipeId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.yieldServingsMinimum = const Value.absent(),
    this.yieldServingsMaximum = const Value.absent(),
    this.oilTreatment = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomRecipesCompanion.insert({
    required String ownerId,
    required String customRecipeId,
    required String name,
    required String normalizedName,
    required double yieldServingsMinimum,
    required double yieldServingsMaximum,
    required String oilTreatment,
    required int revision,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       customRecipeId = Value(customRecipeId),
       name = Value(name),
       normalizedName = Value(normalizedName),
       yieldServingsMinimum = Value(yieldServingsMinimum),
       yieldServingsMaximum = Value(yieldServingsMaximum),
       oilTreatment = Value(oilTreatment),
       revision = Value(revision),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CustomRecipe> custom({
    Expression<String>? ownerId,
    Expression<String>? customRecipeId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<double>? yieldServingsMinimum,
    Expression<double>? yieldServingsMaximum,
    Expression<String>? oilTreatment,
    Expression<int>? revision,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (customRecipeId != null) 'custom_recipe_id': customRecipeId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (yieldServingsMinimum != null)
        'yield_servings_minimum': yieldServingsMinimum,
      if (yieldServingsMaximum != null)
        'yield_servings_maximum': yieldServingsMaximum,
      if (oilTreatment != null) 'oil_treatment': oilTreatment,
      if (revision != null) 'revision': revision,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomRecipesCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? customRecipeId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<double>? yieldServingsMinimum,
    Value<double>? yieldServingsMaximum,
    Value<String>? oilTreatment,
    Value<int>? revision,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return CustomRecipesCompanion(
      ownerId: ownerId ?? this.ownerId,
      customRecipeId: customRecipeId ?? this.customRecipeId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      yieldServingsMinimum: yieldServingsMinimum ?? this.yieldServingsMinimum,
      yieldServingsMaximum: yieldServingsMaximum ?? this.yieldServingsMaximum,
      oilTreatment: oilTreatment ?? this.oilTreatment,
      revision: revision ?? this.revision,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (customRecipeId.present) {
      map['custom_recipe_id'] = Variable<String>(customRecipeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (yieldServingsMinimum.present) {
      map['yield_servings_minimum'] = Variable<double>(
        yieldServingsMinimum.value,
      );
    }
    if (yieldServingsMaximum.present) {
      map['yield_servings_maximum'] = Variable<double>(
        yieldServingsMaximum.value,
      );
    }
    if (oilTreatment.present) {
      map['oil_treatment'] = Variable<String>(oilTreatment.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomRecipesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('customRecipeId: $customRecipeId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('yieldServingsMinimum: $yieldServingsMinimum, ')
          ..write('yieldServingsMaximum: $yieldServingsMaximum, ')
          ..write('oilTreatment: $oilTreatment, ')
          ..write('revision: $revision, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomRecipeIngredientsTable extends CustomRecipeIngredients
    with TableInfo<$CustomRecipeIngredientsTable, CustomRecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomRecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customRecipeIdMeta = const VerificationMeta(
    'customRecipeId',
  );
  @override
  late final GeneratedColumn<String> customRecipeId = GeneratedColumn<String>(
    'custom_recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIndexMeta = const VerificationMeta(
    'ingredientIndex',
  );
  @override
  late final GeneratedColumn<int> ingredientIndex = GeneratedColumn<int>(
    'ingredient_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogItemTypeMeta = const VerificationMeta(
    'catalogItemType',
  );
  @override
  late final GeneratedColumn<String> catalogItemType = GeneratedColumn<String>(
    'catalog_item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _catalogReleaseIdMeta = const VerificationMeta(
    'catalogReleaseId',
  );
  @override
  late final GeneratedColumn<String> catalogReleaseId = GeneratedColumn<String>(
    'catalog_release_id',
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
  static const VerificationMeta _sourceVersionMeta = const VerificationMeta(
    'sourceVersion',
  );
  @override
  late final GeneratedColumn<String> sourceVersion = GeneratedColumn<String>(
    'source_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRecordIdMeta = const VerificationMeta(
    'sourceRecordId',
  );
  @override
  late final GeneratedColumn<String> sourceRecordId = GeneratedColumn<String>(
    'source_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingIdMeta = const VerificationMeta(
    'servingId',
  );
  @override
  late final GeneratedColumn<String> servingId = GeneratedColumn<String>(
    'serving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingLabelMeta = const VerificationMeta(
    'servingLabel',
  );
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
    'serving_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMinimumMeta = const VerificationMeta(
    'gramsMinimum',
  );
  @override
  late final GeneratedColumn<double> gramsMinimum = GeneratedColumn<double>(
    'grams_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMaximumMeta = const VerificationMeta(
    'gramsMaximum',
  );
  @override
  late final GeneratedColumn<double> gramsMaximum = GeneratedColumn<double>(
    'grams_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightBasisMeta = const VerificationMeta(
    'weightBasis',
  );
  @override
  late final GeneratedColumn<String> weightBasis = GeneratedColumn<String>(
    'weight_basis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingConfidenceMeta = const VerificationMeta(
    'servingConfidence',
  );
  @override
  late final GeneratedColumn<double> servingConfidence =
      GeneratedColumn<double>(
        'serving_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _caloriesMinimumMeta = const VerificationMeta(
    'caloriesMinimum',
  );
  @override
  late final GeneratedColumn<double> caloriesMinimum = GeneratedColumn<double>(
    'calories_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMaximumMeta = const VerificationMeta(
    'caloriesMaximum',
  );
  @override
  late final GeneratedColumn<double> caloriesMaximum = GeneratedColumn<double>(
    'calories_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMinimumMeta = const VerificationMeta(
    'proteinMinimum',
  );
  @override
  late final GeneratedColumn<double> proteinMinimum = GeneratedColumn<double>(
    'protein_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMaximumMeta = const VerificationMeta(
    'proteinMaximum',
  );
  @override
  late final GeneratedColumn<double> proteinMaximum = GeneratedColumn<double>(
    'protein_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbohydrateMinimumMeta =
      const VerificationMeta('carbohydrateMinimum');
  @override
  late final GeneratedColumn<double> carbohydrateMinimum =
      GeneratedColumn<double>(
        'carbohydrate_minimum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _carbohydrateMaximumMeta =
      const VerificationMeta('carbohydrateMaximum');
  @override
  late final GeneratedColumn<double> carbohydrateMaximum =
      GeneratedColumn<double>(
        'carbohydrate_maximum',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fatMinimumMeta = const VerificationMeta(
    'fatMinimum',
  );
  @override
  late final GeneratedColumn<double> fatMinimum = GeneratedColumn<double>(
    'fat_minimum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMaximumMeta = const VerificationMeta(
    'fatMaximum',
  );
  @override
  late final GeneratedColumn<double> fatMaximum = GeneratedColumn<double>(
    'fat_maximum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMinimumMeta = const VerificationMeta(
    'sodiumMinimum',
  );
  @override
  late final GeneratedColumn<double> sodiumMinimum = GeneratedColumn<double>(
    'sodium_minimum',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMaximumMeta = const VerificationMeta(
    'sodiumMaximum',
  );
  @override
  late final GeneratedColumn<double> sodiumMaximum = GeneratedColumn<double>(
    'sodium_maximum',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilInclusionMeta = const VerificationMeta(
    'oilInclusion',
  );
  @override
  late final GeneratedColumn<String> oilInclusion = GeneratedColumn<String>(
    'oil_inclusion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculationVersionMeta =
      const VerificationMeta('calculationVersion');
  @override
  late final GeneratedColumn<String> calculationVersion =
      GeneratedColumn<String>(
        'calculation_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    customRecipeId,
    ingredientIndex,
    catalogItemType,
    catalogReleaseId,
    itemId,
    sourceId,
    sourceVersion,
    sourceRecordId,
    servingId,
    servingLabel,
    unitCode,
    quantity,
    gramsMinimum,
    gramsMaximum,
    weightBasis,
    servingConfidence,
    caloriesMinimum,
    caloriesMaximum,
    proteinMinimum,
    proteinMaximum,
    carbohydrateMinimum,
    carbohydrateMaximum,
    fatMinimum,
    fatMaximum,
    sodiumMinimum,
    sodiumMaximum,
    oilInclusion,
    calculationVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomRecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('custom_recipe_id')) {
      context.handle(
        _customRecipeIdMeta,
        customRecipeId.isAcceptableOrUnknown(
          data['custom_recipe_id']!,
          _customRecipeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customRecipeIdMeta);
    }
    if (data.containsKey('ingredient_index')) {
      context.handle(
        _ingredientIndexMeta,
        ingredientIndex.isAcceptableOrUnknown(
          data['ingredient_index']!,
          _ingredientIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIndexMeta);
    }
    if (data.containsKey('catalog_item_type')) {
      context.handle(
        _catalogItemTypeMeta,
        catalogItemType.isAcceptableOrUnknown(
          data['catalog_item_type']!,
          _catalogItemTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogItemTypeMeta);
    }
    if (data.containsKey('catalog_release_id')) {
      context.handle(
        _catalogReleaseIdMeta,
        catalogReleaseId.isAcceptableOrUnknown(
          data['catalog_release_id']!,
          _catalogReleaseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_catalogReleaseIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_version')) {
      context.handle(
        _sourceVersionMeta,
        sourceVersion.isAcceptableOrUnknown(
          data['source_version']!,
          _sourceVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceVersionMeta);
    }
    if (data.containsKey('source_record_id')) {
      context.handle(
        _sourceRecordIdMeta,
        sourceRecordId.isAcceptableOrUnknown(
          data['source_record_id']!,
          _sourceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceRecordIdMeta);
    }
    if (data.containsKey('serving_id')) {
      context.handle(
        _servingIdMeta,
        servingId.isAcceptableOrUnknown(data['serving_id']!, _servingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_servingIdMeta);
    }
    if (data.containsKey('serving_label')) {
      context.handle(
        _servingLabelMeta,
        servingLabel.isAcceptableOrUnknown(
          data['serving_label']!,
          _servingLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingLabelMeta);
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('grams_minimum')) {
      context.handle(
        _gramsMinimumMeta,
        gramsMinimum.isAcceptableOrUnknown(
          data['grams_minimum']!,
          _gramsMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gramsMinimumMeta);
    }
    if (data.containsKey('grams_maximum')) {
      context.handle(
        _gramsMaximumMeta,
        gramsMaximum.isAcceptableOrUnknown(
          data['grams_maximum']!,
          _gramsMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gramsMaximumMeta);
    }
    if (data.containsKey('weight_basis')) {
      context.handle(
        _weightBasisMeta,
        weightBasis.isAcceptableOrUnknown(
          data['weight_basis']!,
          _weightBasisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightBasisMeta);
    }
    if (data.containsKey('serving_confidence')) {
      context.handle(
        _servingConfidenceMeta,
        servingConfidence.isAcceptableOrUnknown(
          data['serving_confidence']!,
          _servingConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingConfidenceMeta);
    }
    if (data.containsKey('calories_minimum')) {
      context.handle(
        _caloriesMinimumMeta,
        caloriesMinimum.isAcceptableOrUnknown(
          data['calories_minimum']!,
          _caloriesMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesMinimumMeta);
    }
    if (data.containsKey('calories_maximum')) {
      context.handle(
        _caloriesMaximumMeta,
        caloriesMaximum.isAcceptableOrUnknown(
          data['calories_maximum']!,
          _caloriesMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesMaximumMeta);
    }
    if (data.containsKey('protein_minimum')) {
      context.handle(
        _proteinMinimumMeta,
        proteinMinimum.isAcceptableOrUnknown(
          data['protein_minimum']!,
          _proteinMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinMinimumMeta);
    }
    if (data.containsKey('protein_maximum')) {
      context.handle(
        _proteinMaximumMeta,
        proteinMaximum.isAcceptableOrUnknown(
          data['protein_maximum']!,
          _proteinMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinMaximumMeta);
    }
    if (data.containsKey('carbohydrate_minimum')) {
      context.handle(
        _carbohydrateMinimumMeta,
        carbohydrateMinimum.isAcceptableOrUnknown(
          data['carbohydrate_minimum']!,
          _carbohydrateMinimumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateMinimumMeta);
    }
    if (data.containsKey('carbohydrate_maximum')) {
      context.handle(
        _carbohydrateMaximumMeta,
        carbohydrateMaximum.isAcceptableOrUnknown(
          data['carbohydrate_maximum']!,
          _carbohydrateMaximumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbohydrateMaximumMeta);
    }
    if (data.containsKey('fat_minimum')) {
      context.handle(
        _fatMinimumMeta,
        fatMinimum.isAcceptableOrUnknown(data['fat_minimum']!, _fatMinimumMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMinimumMeta);
    }
    if (data.containsKey('fat_maximum')) {
      context.handle(
        _fatMaximumMeta,
        fatMaximum.isAcceptableOrUnknown(data['fat_maximum']!, _fatMaximumMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMaximumMeta);
    }
    if (data.containsKey('sodium_minimum')) {
      context.handle(
        _sodiumMinimumMeta,
        sodiumMinimum.isAcceptableOrUnknown(
          data['sodium_minimum']!,
          _sodiumMinimumMeta,
        ),
      );
    }
    if (data.containsKey('sodium_maximum')) {
      context.handle(
        _sodiumMaximumMeta,
        sodiumMaximum.isAcceptableOrUnknown(
          data['sodium_maximum']!,
          _sodiumMaximumMeta,
        ),
      );
    }
    if (data.containsKey('oil_inclusion')) {
      context.handle(
        _oilInclusionMeta,
        oilInclusion.isAcceptableOrUnknown(
          data['oil_inclusion']!,
          _oilInclusionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oilInclusionMeta);
    }
    if (data.containsKey('calculation_version')) {
      context.handle(
        _calculationVersionMeta,
        calculationVersion.isAcceptableOrUnknown(
          data['calculation_version']!,
          _calculationVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calculationVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    ownerId,
    customRecipeId,
    ingredientIndex,
  };
  @override
  CustomRecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomRecipeIngredient(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      customRecipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_recipe_id'],
      )!,
      ingredientIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_index'],
      )!,
      catalogItemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_item_type'],
      )!,
      catalogReleaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_release_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_version'],
      )!,
      sourceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_record_id'],
      )!,
      servingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_id'],
      )!,
      servingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_label'],
      )!,
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      gramsMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_minimum'],
      )!,
      gramsMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams_maximum'],
      )!,
      weightBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_basis'],
      )!,
      servingConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_confidence'],
      )!,
      caloriesMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_minimum'],
      )!,
      caloriesMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_maximum'],
      )!,
      proteinMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_minimum'],
      )!,
      proteinMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_maximum'],
      )!,
      carbohydrateMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_minimum'],
      )!,
      carbohydrateMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrate_maximum'],
      )!,
      fatMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_minimum'],
      )!,
      fatMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_maximum'],
      )!,
      sodiumMinimum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_minimum'],
      ),
      sodiumMaximum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_maximum'],
      ),
      oilInclusion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oil_inclusion'],
      )!,
      calculationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculation_version'],
      )!,
    );
  }

  @override
  $CustomRecipeIngredientsTable createAlias(String alias) {
    return $CustomRecipeIngredientsTable(attachedDatabase, alias);
  }
}

class CustomRecipeIngredient extends DataClass
    implements Insertable<CustomRecipeIngredient> {
  final String ownerId;
  final String customRecipeId;
  final int ingredientIndex;
  final String catalogItemType;
  final String catalogReleaseId;
  final String itemId;
  final String sourceId;
  final String sourceVersion;
  final String sourceRecordId;
  final String servingId;
  final String servingLabel;
  final String unitCode;
  final double quantity;
  final double gramsMinimum;
  final double gramsMaximum;
  final String weightBasis;
  final double servingConfidence;
  final double caloriesMinimum;
  final double caloriesMaximum;
  final double proteinMinimum;
  final double proteinMaximum;
  final double carbohydrateMinimum;
  final double carbohydrateMaximum;
  final double fatMinimum;
  final double fatMaximum;
  final double? sodiumMinimum;
  final double? sodiumMaximum;
  final String oilInclusion;
  final String calculationVersion;
  const CustomRecipeIngredient({
    required this.ownerId,
    required this.customRecipeId,
    required this.ingredientIndex,
    required this.catalogItemType,
    required this.catalogReleaseId,
    required this.itemId,
    required this.sourceId,
    required this.sourceVersion,
    required this.sourceRecordId,
    required this.servingId,
    required this.servingLabel,
    required this.unitCode,
    required this.quantity,
    required this.gramsMinimum,
    required this.gramsMaximum,
    required this.weightBasis,
    required this.servingConfidence,
    required this.caloriesMinimum,
    required this.caloriesMaximum,
    required this.proteinMinimum,
    required this.proteinMaximum,
    required this.carbohydrateMinimum,
    required this.carbohydrateMaximum,
    required this.fatMinimum,
    required this.fatMaximum,
    this.sodiumMinimum,
    this.sodiumMaximum,
    required this.oilInclusion,
    required this.calculationVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['custom_recipe_id'] = Variable<String>(customRecipeId);
    map['ingredient_index'] = Variable<int>(ingredientIndex);
    map['catalog_item_type'] = Variable<String>(catalogItemType);
    map['catalog_release_id'] = Variable<String>(catalogReleaseId);
    map['item_id'] = Variable<String>(itemId);
    map['source_id'] = Variable<String>(sourceId);
    map['source_version'] = Variable<String>(sourceVersion);
    map['source_record_id'] = Variable<String>(sourceRecordId);
    map['serving_id'] = Variable<String>(servingId);
    map['serving_label'] = Variable<String>(servingLabel);
    map['unit_code'] = Variable<String>(unitCode);
    map['quantity'] = Variable<double>(quantity);
    map['grams_minimum'] = Variable<double>(gramsMinimum);
    map['grams_maximum'] = Variable<double>(gramsMaximum);
    map['weight_basis'] = Variable<String>(weightBasis);
    map['serving_confidence'] = Variable<double>(servingConfidence);
    map['calories_minimum'] = Variable<double>(caloriesMinimum);
    map['calories_maximum'] = Variable<double>(caloriesMaximum);
    map['protein_minimum'] = Variable<double>(proteinMinimum);
    map['protein_maximum'] = Variable<double>(proteinMaximum);
    map['carbohydrate_minimum'] = Variable<double>(carbohydrateMinimum);
    map['carbohydrate_maximum'] = Variable<double>(carbohydrateMaximum);
    map['fat_minimum'] = Variable<double>(fatMinimum);
    map['fat_maximum'] = Variable<double>(fatMaximum);
    if (!nullToAbsent || sodiumMinimum != null) {
      map['sodium_minimum'] = Variable<double>(sodiumMinimum);
    }
    if (!nullToAbsent || sodiumMaximum != null) {
      map['sodium_maximum'] = Variable<double>(sodiumMaximum);
    }
    map['oil_inclusion'] = Variable<String>(oilInclusion);
    map['calculation_version'] = Variable<String>(calculationVersion);
    return map;
  }

  CustomRecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return CustomRecipeIngredientsCompanion(
      ownerId: Value(ownerId),
      customRecipeId: Value(customRecipeId),
      ingredientIndex: Value(ingredientIndex),
      catalogItemType: Value(catalogItemType),
      catalogReleaseId: Value(catalogReleaseId),
      itemId: Value(itemId),
      sourceId: Value(sourceId),
      sourceVersion: Value(sourceVersion),
      sourceRecordId: Value(sourceRecordId),
      servingId: Value(servingId),
      servingLabel: Value(servingLabel),
      unitCode: Value(unitCode),
      quantity: Value(quantity),
      gramsMinimum: Value(gramsMinimum),
      gramsMaximum: Value(gramsMaximum),
      weightBasis: Value(weightBasis),
      servingConfidence: Value(servingConfidence),
      caloriesMinimum: Value(caloriesMinimum),
      caloriesMaximum: Value(caloriesMaximum),
      proteinMinimum: Value(proteinMinimum),
      proteinMaximum: Value(proteinMaximum),
      carbohydrateMinimum: Value(carbohydrateMinimum),
      carbohydrateMaximum: Value(carbohydrateMaximum),
      fatMinimum: Value(fatMinimum),
      fatMaximum: Value(fatMaximum),
      sodiumMinimum: sodiumMinimum == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMinimum),
      sodiumMaximum: sodiumMaximum == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMaximum),
      oilInclusion: Value(oilInclusion),
      calculationVersion: Value(calculationVersion),
    );
  }

  factory CustomRecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomRecipeIngredient(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      customRecipeId: serializer.fromJson<String>(json['customRecipeId']),
      ingredientIndex: serializer.fromJson<int>(json['ingredientIndex']),
      catalogItemType: serializer.fromJson<String>(json['catalogItemType']),
      catalogReleaseId: serializer.fromJson<String>(json['catalogReleaseId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceVersion: serializer.fromJson<String>(json['sourceVersion']),
      sourceRecordId: serializer.fromJson<String>(json['sourceRecordId']),
      servingId: serializer.fromJson<String>(json['servingId']),
      servingLabel: serializer.fromJson<String>(json['servingLabel']),
      unitCode: serializer.fromJson<String>(json['unitCode']),
      quantity: serializer.fromJson<double>(json['quantity']),
      gramsMinimum: serializer.fromJson<double>(json['gramsMinimum']),
      gramsMaximum: serializer.fromJson<double>(json['gramsMaximum']),
      weightBasis: serializer.fromJson<String>(json['weightBasis']),
      servingConfidence: serializer.fromJson<double>(json['servingConfidence']),
      caloriesMinimum: serializer.fromJson<double>(json['caloriesMinimum']),
      caloriesMaximum: serializer.fromJson<double>(json['caloriesMaximum']),
      proteinMinimum: serializer.fromJson<double>(json['proteinMinimum']),
      proteinMaximum: serializer.fromJson<double>(json['proteinMaximum']),
      carbohydrateMinimum: serializer.fromJson<double>(
        json['carbohydrateMinimum'],
      ),
      carbohydrateMaximum: serializer.fromJson<double>(
        json['carbohydrateMaximum'],
      ),
      fatMinimum: serializer.fromJson<double>(json['fatMinimum']),
      fatMaximum: serializer.fromJson<double>(json['fatMaximum']),
      sodiumMinimum: serializer.fromJson<double?>(json['sodiumMinimum']),
      sodiumMaximum: serializer.fromJson<double?>(json['sodiumMaximum']),
      oilInclusion: serializer.fromJson<String>(json['oilInclusion']),
      calculationVersion: serializer.fromJson<String>(
        json['calculationVersion'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'customRecipeId': serializer.toJson<String>(customRecipeId),
      'ingredientIndex': serializer.toJson<int>(ingredientIndex),
      'catalogItemType': serializer.toJson<String>(catalogItemType),
      'catalogReleaseId': serializer.toJson<String>(catalogReleaseId),
      'itemId': serializer.toJson<String>(itemId),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceVersion': serializer.toJson<String>(sourceVersion),
      'sourceRecordId': serializer.toJson<String>(sourceRecordId),
      'servingId': serializer.toJson<String>(servingId),
      'servingLabel': serializer.toJson<String>(servingLabel),
      'unitCode': serializer.toJson<String>(unitCode),
      'quantity': serializer.toJson<double>(quantity),
      'gramsMinimum': serializer.toJson<double>(gramsMinimum),
      'gramsMaximum': serializer.toJson<double>(gramsMaximum),
      'weightBasis': serializer.toJson<String>(weightBasis),
      'servingConfidence': serializer.toJson<double>(servingConfidence),
      'caloriesMinimum': serializer.toJson<double>(caloriesMinimum),
      'caloriesMaximum': serializer.toJson<double>(caloriesMaximum),
      'proteinMinimum': serializer.toJson<double>(proteinMinimum),
      'proteinMaximum': serializer.toJson<double>(proteinMaximum),
      'carbohydrateMinimum': serializer.toJson<double>(carbohydrateMinimum),
      'carbohydrateMaximum': serializer.toJson<double>(carbohydrateMaximum),
      'fatMinimum': serializer.toJson<double>(fatMinimum),
      'fatMaximum': serializer.toJson<double>(fatMaximum),
      'sodiumMinimum': serializer.toJson<double?>(sodiumMinimum),
      'sodiumMaximum': serializer.toJson<double?>(sodiumMaximum),
      'oilInclusion': serializer.toJson<String>(oilInclusion),
      'calculationVersion': serializer.toJson<String>(calculationVersion),
    };
  }

  CustomRecipeIngredient copyWith({
    String? ownerId,
    String? customRecipeId,
    int? ingredientIndex,
    String? catalogItemType,
    String? catalogReleaseId,
    String? itemId,
    String? sourceId,
    String? sourceVersion,
    String? sourceRecordId,
    String? servingId,
    String? servingLabel,
    String? unitCode,
    double? quantity,
    double? gramsMinimum,
    double? gramsMaximum,
    String? weightBasis,
    double? servingConfidence,
    double? caloriesMinimum,
    double? caloriesMaximum,
    double? proteinMinimum,
    double? proteinMaximum,
    double? carbohydrateMinimum,
    double? carbohydrateMaximum,
    double? fatMinimum,
    double? fatMaximum,
    Value<double?> sodiumMinimum = const Value.absent(),
    Value<double?> sodiumMaximum = const Value.absent(),
    String? oilInclusion,
    String? calculationVersion,
  }) => CustomRecipeIngredient(
    ownerId: ownerId ?? this.ownerId,
    customRecipeId: customRecipeId ?? this.customRecipeId,
    ingredientIndex: ingredientIndex ?? this.ingredientIndex,
    catalogItemType: catalogItemType ?? this.catalogItemType,
    catalogReleaseId: catalogReleaseId ?? this.catalogReleaseId,
    itemId: itemId ?? this.itemId,
    sourceId: sourceId ?? this.sourceId,
    sourceVersion: sourceVersion ?? this.sourceVersion,
    sourceRecordId: sourceRecordId ?? this.sourceRecordId,
    servingId: servingId ?? this.servingId,
    servingLabel: servingLabel ?? this.servingLabel,
    unitCode: unitCode ?? this.unitCode,
    quantity: quantity ?? this.quantity,
    gramsMinimum: gramsMinimum ?? this.gramsMinimum,
    gramsMaximum: gramsMaximum ?? this.gramsMaximum,
    weightBasis: weightBasis ?? this.weightBasis,
    servingConfidence: servingConfidence ?? this.servingConfidence,
    caloriesMinimum: caloriesMinimum ?? this.caloriesMinimum,
    caloriesMaximum: caloriesMaximum ?? this.caloriesMaximum,
    proteinMinimum: proteinMinimum ?? this.proteinMinimum,
    proteinMaximum: proteinMaximum ?? this.proteinMaximum,
    carbohydrateMinimum: carbohydrateMinimum ?? this.carbohydrateMinimum,
    carbohydrateMaximum: carbohydrateMaximum ?? this.carbohydrateMaximum,
    fatMinimum: fatMinimum ?? this.fatMinimum,
    fatMaximum: fatMaximum ?? this.fatMaximum,
    sodiumMinimum: sodiumMinimum.present
        ? sodiumMinimum.value
        : this.sodiumMinimum,
    sodiumMaximum: sodiumMaximum.present
        ? sodiumMaximum.value
        : this.sodiumMaximum,
    oilInclusion: oilInclusion ?? this.oilInclusion,
    calculationVersion: calculationVersion ?? this.calculationVersion,
  );
  CustomRecipeIngredient copyWithCompanion(
    CustomRecipeIngredientsCompanion data,
  ) {
    return CustomRecipeIngredient(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      customRecipeId: data.customRecipeId.present
          ? data.customRecipeId.value
          : this.customRecipeId,
      ingredientIndex: data.ingredientIndex.present
          ? data.ingredientIndex.value
          : this.ingredientIndex,
      catalogItemType: data.catalogItemType.present
          ? data.catalogItemType.value
          : this.catalogItemType,
      catalogReleaseId: data.catalogReleaseId.present
          ? data.catalogReleaseId.value
          : this.catalogReleaseId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      sourceRecordId: data.sourceRecordId.present
          ? data.sourceRecordId.value
          : this.sourceRecordId,
      servingId: data.servingId.present ? data.servingId.value : this.servingId,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      gramsMinimum: data.gramsMinimum.present
          ? data.gramsMinimum.value
          : this.gramsMinimum,
      gramsMaximum: data.gramsMaximum.present
          ? data.gramsMaximum.value
          : this.gramsMaximum,
      weightBasis: data.weightBasis.present
          ? data.weightBasis.value
          : this.weightBasis,
      servingConfidence: data.servingConfidence.present
          ? data.servingConfidence.value
          : this.servingConfidence,
      caloriesMinimum: data.caloriesMinimum.present
          ? data.caloriesMinimum.value
          : this.caloriesMinimum,
      caloriesMaximum: data.caloriesMaximum.present
          ? data.caloriesMaximum.value
          : this.caloriesMaximum,
      proteinMinimum: data.proteinMinimum.present
          ? data.proteinMinimum.value
          : this.proteinMinimum,
      proteinMaximum: data.proteinMaximum.present
          ? data.proteinMaximum.value
          : this.proteinMaximum,
      carbohydrateMinimum: data.carbohydrateMinimum.present
          ? data.carbohydrateMinimum.value
          : this.carbohydrateMinimum,
      carbohydrateMaximum: data.carbohydrateMaximum.present
          ? data.carbohydrateMaximum.value
          : this.carbohydrateMaximum,
      fatMinimum: data.fatMinimum.present
          ? data.fatMinimum.value
          : this.fatMinimum,
      fatMaximum: data.fatMaximum.present
          ? data.fatMaximum.value
          : this.fatMaximum,
      sodiumMinimum: data.sodiumMinimum.present
          ? data.sodiumMinimum.value
          : this.sodiumMinimum,
      sodiumMaximum: data.sodiumMaximum.present
          ? data.sodiumMaximum.value
          : this.sodiumMaximum,
      oilInclusion: data.oilInclusion.present
          ? data.oilInclusion.value
          : this.oilInclusion,
      calculationVersion: data.calculationVersion.present
          ? data.calculationVersion.value
          : this.calculationVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomRecipeIngredient(')
          ..write('ownerId: $ownerId, ')
          ..write('customRecipeId: $customRecipeId, ')
          ..write('ingredientIndex: $ingredientIndex, ')
          ..write('catalogItemType: $catalogItemType, ')
          ..write('catalogReleaseId: $catalogReleaseId, ')
          ..write('itemId: $itemId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('servingId: $servingId, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('unitCode: $unitCode, ')
          ..write('quantity: $quantity, ')
          ..write('gramsMinimum: $gramsMinimum, ')
          ..write('gramsMaximum: $gramsMaximum, ')
          ..write('weightBasis: $weightBasis, ')
          ..write('servingConfidence: $servingConfidence, ')
          ..write('caloriesMinimum: $caloriesMinimum, ')
          ..write('caloriesMaximum: $caloriesMaximum, ')
          ..write('proteinMinimum: $proteinMinimum, ')
          ..write('proteinMaximum: $proteinMaximum, ')
          ..write('carbohydrateMinimum: $carbohydrateMinimum, ')
          ..write('carbohydrateMaximum: $carbohydrateMaximum, ')
          ..write('fatMinimum: $fatMinimum, ')
          ..write('fatMaximum: $fatMaximum, ')
          ..write('sodiumMinimum: $sodiumMinimum, ')
          ..write('sodiumMaximum: $sodiumMaximum, ')
          ..write('oilInclusion: $oilInclusion, ')
          ..write('calculationVersion: $calculationVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    ownerId,
    customRecipeId,
    ingredientIndex,
    catalogItemType,
    catalogReleaseId,
    itemId,
    sourceId,
    sourceVersion,
    sourceRecordId,
    servingId,
    servingLabel,
    unitCode,
    quantity,
    gramsMinimum,
    gramsMaximum,
    weightBasis,
    servingConfidence,
    caloriesMinimum,
    caloriesMaximum,
    proteinMinimum,
    proteinMaximum,
    carbohydrateMinimum,
    carbohydrateMaximum,
    fatMinimum,
    fatMaximum,
    sodiumMinimum,
    sodiumMaximum,
    oilInclusion,
    calculationVersion,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomRecipeIngredient &&
          other.ownerId == this.ownerId &&
          other.customRecipeId == this.customRecipeId &&
          other.ingredientIndex == this.ingredientIndex &&
          other.catalogItemType == this.catalogItemType &&
          other.catalogReleaseId == this.catalogReleaseId &&
          other.itemId == this.itemId &&
          other.sourceId == this.sourceId &&
          other.sourceVersion == this.sourceVersion &&
          other.sourceRecordId == this.sourceRecordId &&
          other.servingId == this.servingId &&
          other.servingLabel == this.servingLabel &&
          other.unitCode == this.unitCode &&
          other.quantity == this.quantity &&
          other.gramsMinimum == this.gramsMinimum &&
          other.gramsMaximum == this.gramsMaximum &&
          other.weightBasis == this.weightBasis &&
          other.servingConfidence == this.servingConfidence &&
          other.caloriesMinimum == this.caloriesMinimum &&
          other.caloriesMaximum == this.caloriesMaximum &&
          other.proteinMinimum == this.proteinMinimum &&
          other.proteinMaximum == this.proteinMaximum &&
          other.carbohydrateMinimum == this.carbohydrateMinimum &&
          other.carbohydrateMaximum == this.carbohydrateMaximum &&
          other.fatMinimum == this.fatMinimum &&
          other.fatMaximum == this.fatMaximum &&
          other.sodiumMinimum == this.sodiumMinimum &&
          other.sodiumMaximum == this.sodiumMaximum &&
          other.oilInclusion == this.oilInclusion &&
          other.calculationVersion == this.calculationVersion);
}

class CustomRecipeIngredientsCompanion
    extends UpdateCompanion<CustomRecipeIngredient> {
  final Value<String> ownerId;
  final Value<String> customRecipeId;
  final Value<int> ingredientIndex;
  final Value<String> catalogItemType;
  final Value<String> catalogReleaseId;
  final Value<String> itemId;
  final Value<String> sourceId;
  final Value<String> sourceVersion;
  final Value<String> sourceRecordId;
  final Value<String> servingId;
  final Value<String> servingLabel;
  final Value<String> unitCode;
  final Value<double> quantity;
  final Value<double> gramsMinimum;
  final Value<double> gramsMaximum;
  final Value<String> weightBasis;
  final Value<double> servingConfidence;
  final Value<double> caloriesMinimum;
  final Value<double> caloriesMaximum;
  final Value<double> proteinMinimum;
  final Value<double> proteinMaximum;
  final Value<double> carbohydrateMinimum;
  final Value<double> carbohydrateMaximum;
  final Value<double> fatMinimum;
  final Value<double> fatMaximum;
  final Value<double?> sodiumMinimum;
  final Value<double?> sodiumMaximum;
  final Value<String> oilInclusion;
  final Value<String> calculationVersion;
  final Value<int> rowid;
  const CustomRecipeIngredientsCompanion({
    this.ownerId = const Value.absent(),
    this.customRecipeId = const Value.absent(),
    this.ingredientIndex = const Value.absent(),
    this.catalogItemType = const Value.absent(),
    this.catalogReleaseId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.sourceRecordId = const Value.absent(),
    this.servingId = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.quantity = const Value.absent(),
    this.gramsMinimum = const Value.absent(),
    this.gramsMaximum = const Value.absent(),
    this.weightBasis = const Value.absent(),
    this.servingConfidence = const Value.absent(),
    this.caloriesMinimum = const Value.absent(),
    this.caloriesMaximum = const Value.absent(),
    this.proteinMinimum = const Value.absent(),
    this.proteinMaximum = const Value.absent(),
    this.carbohydrateMinimum = const Value.absent(),
    this.carbohydrateMaximum = const Value.absent(),
    this.fatMinimum = const Value.absent(),
    this.fatMaximum = const Value.absent(),
    this.sodiumMinimum = const Value.absent(),
    this.sodiumMaximum = const Value.absent(),
    this.oilInclusion = const Value.absent(),
    this.calculationVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomRecipeIngredientsCompanion.insert({
    required String ownerId,
    required String customRecipeId,
    required int ingredientIndex,
    required String catalogItemType,
    required String catalogReleaseId,
    required String itemId,
    required String sourceId,
    required String sourceVersion,
    required String sourceRecordId,
    required String servingId,
    required String servingLabel,
    required String unitCode,
    required double quantity,
    required double gramsMinimum,
    required double gramsMaximum,
    required String weightBasis,
    required double servingConfidence,
    required double caloriesMinimum,
    required double caloriesMaximum,
    required double proteinMinimum,
    required double proteinMaximum,
    required double carbohydrateMinimum,
    required double carbohydrateMaximum,
    required double fatMinimum,
    required double fatMaximum,
    this.sodiumMinimum = const Value.absent(),
    this.sodiumMaximum = const Value.absent(),
    required String oilInclusion,
    required String calculationVersion,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       customRecipeId = Value(customRecipeId),
       ingredientIndex = Value(ingredientIndex),
       catalogItemType = Value(catalogItemType),
       catalogReleaseId = Value(catalogReleaseId),
       itemId = Value(itemId),
       sourceId = Value(sourceId),
       sourceVersion = Value(sourceVersion),
       sourceRecordId = Value(sourceRecordId),
       servingId = Value(servingId),
       servingLabel = Value(servingLabel),
       unitCode = Value(unitCode),
       quantity = Value(quantity),
       gramsMinimum = Value(gramsMinimum),
       gramsMaximum = Value(gramsMaximum),
       weightBasis = Value(weightBasis),
       servingConfidence = Value(servingConfidence),
       caloriesMinimum = Value(caloriesMinimum),
       caloriesMaximum = Value(caloriesMaximum),
       proteinMinimum = Value(proteinMinimum),
       proteinMaximum = Value(proteinMaximum),
       carbohydrateMinimum = Value(carbohydrateMinimum),
       carbohydrateMaximum = Value(carbohydrateMaximum),
       fatMinimum = Value(fatMinimum),
       fatMaximum = Value(fatMaximum),
       oilInclusion = Value(oilInclusion),
       calculationVersion = Value(calculationVersion);
  static Insertable<CustomRecipeIngredient> custom({
    Expression<String>? ownerId,
    Expression<String>? customRecipeId,
    Expression<int>? ingredientIndex,
    Expression<String>? catalogItemType,
    Expression<String>? catalogReleaseId,
    Expression<String>? itemId,
    Expression<String>? sourceId,
    Expression<String>? sourceVersion,
    Expression<String>? sourceRecordId,
    Expression<String>? servingId,
    Expression<String>? servingLabel,
    Expression<String>? unitCode,
    Expression<double>? quantity,
    Expression<double>? gramsMinimum,
    Expression<double>? gramsMaximum,
    Expression<String>? weightBasis,
    Expression<double>? servingConfidence,
    Expression<double>? caloriesMinimum,
    Expression<double>? caloriesMaximum,
    Expression<double>? proteinMinimum,
    Expression<double>? proteinMaximum,
    Expression<double>? carbohydrateMinimum,
    Expression<double>? carbohydrateMaximum,
    Expression<double>? fatMinimum,
    Expression<double>? fatMaximum,
    Expression<double>? sodiumMinimum,
    Expression<double>? sodiumMaximum,
    Expression<String>? oilInclusion,
    Expression<String>? calculationVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (customRecipeId != null) 'custom_recipe_id': customRecipeId,
      if (ingredientIndex != null) 'ingredient_index': ingredientIndex,
      if (catalogItemType != null) 'catalog_item_type': catalogItemType,
      if (catalogReleaseId != null) 'catalog_release_id': catalogReleaseId,
      if (itemId != null) 'item_id': itemId,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (sourceRecordId != null) 'source_record_id': sourceRecordId,
      if (servingId != null) 'serving_id': servingId,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (unitCode != null) 'unit_code': unitCode,
      if (quantity != null) 'quantity': quantity,
      if (gramsMinimum != null) 'grams_minimum': gramsMinimum,
      if (gramsMaximum != null) 'grams_maximum': gramsMaximum,
      if (weightBasis != null) 'weight_basis': weightBasis,
      if (servingConfidence != null) 'serving_confidence': servingConfidence,
      if (caloriesMinimum != null) 'calories_minimum': caloriesMinimum,
      if (caloriesMaximum != null) 'calories_maximum': caloriesMaximum,
      if (proteinMinimum != null) 'protein_minimum': proteinMinimum,
      if (proteinMaximum != null) 'protein_maximum': proteinMaximum,
      if (carbohydrateMinimum != null)
        'carbohydrate_minimum': carbohydrateMinimum,
      if (carbohydrateMaximum != null)
        'carbohydrate_maximum': carbohydrateMaximum,
      if (fatMinimum != null) 'fat_minimum': fatMinimum,
      if (fatMaximum != null) 'fat_maximum': fatMaximum,
      if (sodiumMinimum != null) 'sodium_minimum': sodiumMinimum,
      if (sodiumMaximum != null) 'sodium_maximum': sodiumMaximum,
      if (oilInclusion != null) 'oil_inclusion': oilInclusion,
      if (calculationVersion != null) 'calculation_version': calculationVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomRecipeIngredientsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? customRecipeId,
    Value<int>? ingredientIndex,
    Value<String>? catalogItemType,
    Value<String>? catalogReleaseId,
    Value<String>? itemId,
    Value<String>? sourceId,
    Value<String>? sourceVersion,
    Value<String>? sourceRecordId,
    Value<String>? servingId,
    Value<String>? servingLabel,
    Value<String>? unitCode,
    Value<double>? quantity,
    Value<double>? gramsMinimum,
    Value<double>? gramsMaximum,
    Value<String>? weightBasis,
    Value<double>? servingConfidence,
    Value<double>? caloriesMinimum,
    Value<double>? caloriesMaximum,
    Value<double>? proteinMinimum,
    Value<double>? proteinMaximum,
    Value<double>? carbohydrateMinimum,
    Value<double>? carbohydrateMaximum,
    Value<double>? fatMinimum,
    Value<double>? fatMaximum,
    Value<double?>? sodiumMinimum,
    Value<double?>? sodiumMaximum,
    Value<String>? oilInclusion,
    Value<String>? calculationVersion,
    Value<int>? rowid,
  }) {
    return CustomRecipeIngredientsCompanion(
      ownerId: ownerId ?? this.ownerId,
      customRecipeId: customRecipeId ?? this.customRecipeId,
      ingredientIndex: ingredientIndex ?? this.ingredientIndex,
      catalogItemType: catalogItemType ?? this.catalogItemType,
      catalogReleaseId: catalogReleaseId ?? this.catalogReleaseId,
      itemId: itemId ?? this.itemId,
      sourceId: sourceId ?? this.sourceId,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      sourceRecordId: sourceRecordId ?? this.sourceRecordId,
      servingId: servingId ?? this.servingId,
      servingLabel: servingLabel ?? this.servingLabel,
      unitCode: unitCode ?? this.unitCode,
      quantity: quantity ?? this.quantity,
      gramsMinimum: gramsMinimum ?? this.gramsMinimum,
      gramsMaximum: gramsMaximum ?? this.gramsMaximum,
      weightBasis: weightBasis ?? this.weightBasis,
      servingConfidence: servingConfidence ?? this.servingConfidence,
      caloriesMinimum: caloriesMinimum ?? this.caloriesMinimum,
      caloriesMaximum: caloriesMaximum ?? this.caloriesMaximum,
      proteinMinimum: proteinMinimum ?? this.proteinMinimum,
      proteinMaximum: proteinMaximum ?? this.proteinMaximum,
      carbohydrateMinimum: carbohydrateMinimum ?? this.carbohydrateMinimum,
      carbohydrateMaximum: carbohydrateMaximum ?? this.carbohydrateMaximum,
      fatMinimum: fatMinimum ?? this.fatMinimum,
      fatMaximum: fatMaximum ?? this.fatMaximum,
      sodiumMinimum: sodiumMinimum ?? this.sodiumMinimum,
      sodiumMaximum: sodiumMaximum ?? this.sodiumMaximum,
      oilInclusion: oilInclusion ?? this.oilInclusion,
      calculationVersion: calculationVersion ?? this.calculationVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (customRecipeId.present) {
      map['custom_recipe_id'] = Variable<String>(customRecipeId.value);
    }
    if (ingredientIndex.present) {
      map['ingredient_index'] = Variable<int>(ingredientIndex.value);
    }
    if (catalogItemType.present) {
      map['catalog_item_type'] = Variable<String>(catalogItemType.value);
    }
    if (catalogReleaseId.present) {
      map['catalog_release_id'] = Variable<String>(catalogReleaseId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<String>(sourceVersion.value);
    }
    if (sourceRecordId.present) {
      map['source_record_id'] = Variable<String>(sourceRecordId.value);
    }
    if (servingId.present) {
      map['serving_id'] = Variable<String>(servingId.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (gramsMinimum.present) {
      map['grams_minimum'] = Variable<double>(gramsMinimum.value);
    }
    if (gramsMaximum.present) {
      map['grams_maximum'] = Variable<double>(gramsMaximum.value);
    }
    if (weightBasis.present) {
      map['weight_basis'] = Variable<String>(weightBasis.value);
    }
    if (servingConfidence.present) {
      map['serving_confidence'] = Variable<double>(servingConfidence.value);
    }
    if (caloriesMinimum.present) {
      map['calories_minimum'] = Variable<double>(caloriesMinimum.value);
    }
    if (caloriesMaximum.present) {
      map['calories_maximum'] = Variable<double>(caloriesMaximum.value);
    }
    if (proteinMinimum.present) {
      map['protein_minimum'] = Variable<double>(proteinMinimum.value);
    }
    if (proteinMaximum.present) {
      map['protein_maximum'] = Variable<double>(proteinMaximum.value);
    }
    if (carbohydrateMinimum.present) {
      map['carbohydrate_minimum'] = Variable<double>(carbohydrateMinimum.value);
    }
    if (carbohydrateMaximum.present) {
      map['carbohydrate_maximum'] = Variable<double>(carbohydrateMaximum.value);
    }
    if (fatMinimum.present) {
      map['fat_minimum'] = Variable<double>(fatMinimum.value);
    }
    if (fatMaximum.present) {
      map['fat_maximum'] = Variable<double>(fatMaximum.value);
    }
    if (sodiumMinimum.present) {
      map['sodium_minimum'] = Variable<double>(sodiumMinimum.value);
    }
    if (sodiumMaximum.present) {
      map['sodium_maximum'] = Variable<double>(sodiumMaximum.value);
    }
    if (oilInclusion.present) {
      map['oil_inclusion'] = Variable<String>(oilInclusion.value);
    }
    if (calculationVersion.present) {
      map['calculation_version'] = Variable<String>(calculationVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomRecipeIngredientsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('customRecipeId: $customRecipeId, ')
          ..write('ingredientIndex: $ingredientIndex, ')
          ..write('catalogItemType: $catalogItemType, ')
          ..write('catalogReleaseId: $catalogReleaseId, ')
          ..write('itemId: $itemId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('sourceRecordId: $sourceRecordId, ')
          ..write('servingId: $servingId, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('unitCode: $unitCode, ')
          ..write('quantity: $quantity, ')
          ..write('gramsMinimum: $gramsMinimum, ')
          ..write('gramsMaximum: $gramsMaximum, ')
          ..write('weightBasis: $weightBasis, ')
          ..write('servingConfidence: $servingConfidence, ')
          ..write('caloriesMinimum: $caloriesMinimum, ')
          ..write('caloriesMaximum: $caloriesMaximum, ')
          ..write('proteinMinimum: $proteinMinimum, ')
          ..write('proteinMaximum: $proteinMaximum, ')
          ..write('carbohydrateMinimum: $carbohydrateMinimum, ')
          ..write('carbohydrateMaximum: $carbohydrateMaximum, ')
          ..write('fatMinimum: $fatMinimum, ')
          ..write('fatMaximum: $fatMaximum, ')
          ..write('sodiumMinimum: $sodiumMinimum, ')
          ..write('sodiumMaximum: $sodiumMaximum, ')
          ..write('oilInclusion: $oilInclusion, ')
          ..write('calculationVersion: $calculationVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalRecordsTable localRecords = $LocalRecordsTable(this);
  late final $SyncOutboxEntriesTable syncOutboxEntries =
      $SyncOutboxEntriesTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $CatalogReleasesTable catalogReleases = $CatalogReleasesTable(
    this,
  );
  late final $NutritionSourcesTable nutritionSources = $NutritionSourcesTable(
    this,
  );
  late final $CatalogFoodsTable catalogFoods = $CatalogFoodsTable(this);
  late final $CatalogFoodSynonymsTable catalogFoodSynonyms =
      $CatalogFoodSynonymsTable(this);
  late final $CatalogServingDefinitionsTable catalogServingDefinitions =
      $CatalogServingDefinitionsTable(this);
  late final $CatalogRecipesTable catalogRecipes = $CatalogRecipesTable(this);
  late final $CatalogRecipeSynonymsTable catalogRecipeSynonyms =
      $CatalogRecipeSynonymsTable(this);
  late final $CatalogRecipeIngredientsTable catalogRecipeIngredients =
      $CatalogRecipeIngredientsTable(this);
  late final $MealEventsTable mealEvents = $MealEventsTable(this);
  late final $MealItemsTable mealItems = $MealItemsTable(this);
  late final $WaterEventsTable waterEvents = $WaterEventsTable(this);
  late final $WeightEventsTable weightEvents = $WeightEventsTable(this);
  late final $HydrationPreferencesTable hydrationPreferences =
      $HydrationPreferencesTable(this);
  late final $CustomFoodsTable customFoods = $CustomFoodsTable(this);
  late final $FoodNotFoundNotesTable foodNotFoundNotes =
      $FoodNotFoundNotesTable(this);
  late final $CustomRecipesTable customRecipes = $CustomRecipesTable(this);
  late final $CustomRecipeIngredientsTable customRecipeIngredients =
      $CustomRecipeIngredientsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localRecords,
    syncOutboxEntries,
    syncCursors,
    catalogReleases,
    nutritionSources,
    catalogFoods,
    catalogFoodSynonyms,
    catalogServingDefinitions,
    catalogRecipes,
    catalogRecipeSynonyms,
    catalogRecipeIngredients,
    mealEvents,
    mealItems,
    waterEvents,
    weightEvents,
    hydrationPreferences,
    customFoods,
    foodNotFoundNotes,
    customRecipes,
    customRecipeIngredients,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_releases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('catalog_foods', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_releases',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('catalog_recipes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LocalRecordsTableCreateCompanionBuilder =
    LocalRecordsCompanion Function({
      required String ownerId,
      required String entityType,
      required String entityKey,
      required int schemaVersion,
      required int revision,
      required String payloadJson,
      Value<bool> isDeleted,
      required DateTime createdAtClient,
      required DateTime updatedAtClient,
      Value<DateTime?> updatedAtServer,
      Value<int> rowid,
    });
typedef $$LocalRecordsTableUpdateCompanionBuilder =
    LocalRecordsCompanion Function({
      Value<String> ownerId,
      Value<String> entityType,
      Value<String> entityKey,
      Value<int> schemaVersion,
      Value<int> revision,
      Value<String> payloadJson,
      Value<bool> isDeleted,
      Value<DateTime> createdAtClient,
      Value<DateTime> updatedAtClient,
      Value<DateTime?> updatedAtServer,
      Value<int> rowid,
    });

class $$LocalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtClient => $composableBuilder(
    column: $table.createdAtClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtClient => $composableBuilder(
    column: $table.updatedAtClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtClient => $composableBuilder(
    column: $table.createdAtClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtClient => $composableBuilder(
    column: $table.updatedAtClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRecordsTable> {
  $$LocalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtClient => $composableBuilder(
    column: $table.createdAtClient,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtClient => $composableBuilder(
    column: $table.updatedAtClient,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtServer => $composableBuilder(
    column: $table.updatedAtServer,
    builder: (column) => column,
  );
}

class $$LocalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRecordsTable,
          LocalRecord,
          $$LocalRecordsTableFilterComposer,
          $$LocalRecordsTableOrderingComposer,
          $$LocalRecordsTableAnnotationComposer,
          $$LocalRecordsTableCreateCompanionBuilder,
          $$LocalRecordsTableUpdateCompanionBuilder,
          (
            LocalRecord,
            BaseReferences<_$AppDatabase, $LocalRecordsTable, LocalRecord>,
          ),
          LocalRecord,
          PrefetchHooks Function()
        > {
  $$LocalRecordsTableTableManager(_$AppDatabase db, $LocalRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityKey = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAtClient = const Value.absent(),
                Value<DateTime> updatedAtClient = const Value.absent(),
                Value<DateTime?> updatedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion(
                ownerId: ownerId,
                entityType: entityType,
                entityKey: entityKey,
                schemaVersion: schemaVersion,
                revision: revision,
                payloadJson: payloadJson,
                isDeleted: isDeleted,
                createdAtClient: createdAtClient,
                updatedAtClient: updatedAtClient,
                updatedAtServer: updatedAtServer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String entityType,
                required String entityKey,
                required int schemaVersion,
                required int revision,
                required String payloadJson,
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAtClient,
                required DateTime updatedAtClient,
                Value<DateTime?> updatedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecordsCompanion.insert(
                ownerId: ownerId,
                entityType: entityType,
                entityKey: entityKey,
                schemaVersion: schemaVersion,
                revision: revision,
                payloadJson: payloadJson,
                isDeleted: isDeleted,
                createdAtClient: createdAtClient,
                updatedAtClient: updatedAtClient,
                updatedAtServer: updatedAtServer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalRecordsTable, LocalRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocalRecordsTable,
                    LocalRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRecordsTable,
      LocalRecord,
      $$LocalRecordsTableFilterComposer,
      $$LocalRecordsTableOrderingComposer,
      $$LocalRecordsTableAnnotationComposer,
      $$LocalRecordsTableCreateCompanionBuilder,
      $$LocalRecordsTableUpdateCompanionBuilder,
      (
        LocalRecord,
        BaseReferences<_$AppDatabase, $LocalRecordsTable, LocalRecord>,
      ),
      LocalRecord,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxEntriesTableCreateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      required String ownerId,
      required String operationId,
      required String entityType,
      required String entityKey,
      required String operationType,
      required int baseRevision,
      required int newRevision,
      required String payloadJson,
      required DateTime createdAtClient,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncOutboxEntriesTableUpdateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      Value<String> ownerId,
      Value<String> operationId,
      Value<String> entityType,
      Value<String> entityKey,
      Value<String> operationType,
      Value<int> baseRevision,
      Value<int> newRevision,
      Value<String> payloadJson,
      Value<DateTime> createdAtClient,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncOutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newRevision => $composableBuilder(
    column: $table.newRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtClient => $composableBuilder(
    column: $table.createdAtClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newRevision => $composableBuilder(
    column: $table.newRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtClient => $composableBuilder(
    column: $table.createdAtClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newRevision => $composableBuilder(
    column: $table.newRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtClient => $composableBuilder(
    column: $table.createdAtClient,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncOutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxEntriesTable,
          SyncOutboxEntry,
          $$SyncOutboxEntriesTableFilterComposer,
          $$SyncOutboxEntriesTableOrderingComposer,
          $$SyncOutboxEntriesTableAnnotationComposer,
          $$SyncOutboxEntriesTableCreateCompanionBuilder,
          $$SyncOutboxEntriesTableUpdateCompanionBuilder,
          (
            SyncOutboxEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncOutboxEntriesTable,
              SyncOutboxEntry
            >,
          ),
          SyncOutboxEntry,
          PrefetchHooks Function()
        > {
  $$SyncOutboxEntriesTableTableManager(
    _$AppDatabase db,
    $SyncOutboxEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityKey = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<int> baseRevision = const Value.absent(),
                Value<int> newRevision = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAtClient = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion(
                ownerId: ownerId,
                operationId: operationId,
                entityType: entityType,
                entityKey: entityKey,
                operationType: operationType,
                baseRevision: baseRevision,
                newRevision: newRevision,
                payloadJson: payloadJson,
                createdAtClient: createdAtClient,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String operationId,
                required String entityType,
                required String entityKey,
                required String operationType,
                required int baseRevision,
                required int newRevision,
                required String payloadJson,
                required DateTime createdAtClient,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion.insert(
                ownerId: ownerId,
                operationId: operationId,
                entityType: entityType,
                entityKey: entityKey,
                operationType: operationType,
                baseRevision: baseRevision,
                newRevision: newRevision,
                payloadJson: payloadJson,
                createdAtClient: createdAtClient,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxEntriesTable, SyncOutboxEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxEntriesTable,
                    SyncOutboxEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxEntriesTable,
      SyncOutboxEntry,
      $$SyncOutboxEntriesTableFilterComposer,
      $$SyncOutboxEntriesTableOrderingComposer,
      $$SyncOutboxEntriesTableAnnotationComposer,
      $$SyncOutboxEntriesTableCreateCompanionBuilder,
      $$SyncOutboxEntriesTableUpdateCompanionBuilder,
      (
        SyncOutboxEntry,
        BaseReferences<_$AppDatabase, $SyncOutboxEntriesTable, SyncOutboxEntry>,
      ),
      SyncOutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String ownerId,
      required String cursor,
      required DateTime updatedAtClient,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> ownerId,
      Value<String> cursor,
      Value<DateTime> updatedAtClient,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtClient => $composableBuilder(
    column: $table.updatedAtClient,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtClient => $composableBuilder(
    column: $table.updatedAtClient,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtClient => $composableBuilder(
    column: $table.updatedAtClient,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime> updatedAtClient = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                ownerId: ownerId,
                cursor: cursor,
                updatedAtClient: updatedAtClient,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String cursor,
                required DateTime updatedAtClient,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                ownerId: ownerId,
                cursor: cursor,
                updatedAtClient: updatedAtClient,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>(
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

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$CatalogReleasesTableCreateCompanionBuilder =
    CatalogReleasesCompanion Function({
      required String releaseId,
      required String version,
      required String reviewStatus,
      required String contentChecksum,
      Value<DateTime?> publishedAt,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$CatalogReleasesTableUpdateCompanionBuilder =
    CatalogReleasesCompanion Function({
      Value<String> releaseId,
      Value<String> version,
      Value<String> reviewStatus,
      Value<String> contentChecksum,
      Value<DateTime?> publishedAt,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

final class $$CatalogReleasesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CatalogReleasesTable, CatalogRelease> {
  $$CatalogReleasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CatalogFoodsTable, List<CatalogFood>>
  _catalogFoodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catalogFoods,
    aliasName: 'catalog_releases__release_id__catalog_foods__release_id',
  );

  $$CatalogFoodsTableProcessedTableManager get catalogFoodsRefs {
    final manager = $$CatalogFoodsTableTableManager($_db, $_db.catalogFoods)
        .filter(
          (f) => f.releaseId.releaseId.sqlEquals(
            $_itemColumn<String>('release_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_catalogFoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CatalogRecipesTable, List<CatalogRecipe>>
  _catalogRecipesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catalogRecipes,
    aliasName: 'catalog_releases__release_id__catalog_recipes__release_id',
  );

  $$CatalogRecipesTableProcessedTableManager get catalogRecipesRefs {
    final manager = $$CatalogRecipesTableTableManager($_db, $_db.catalogRecipes)
        .filter(
          (f) => f.releaseId.releaseId.sqlEquals(
            $_itemColumn<String>('release_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_catalogRecipesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogReleasesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogReleasesTable> {
  $$CatalogReleasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentChecksum => $composableBuilder(
    column: $table.contentChecksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> catalogFoodsRefs(
    Expression<bool> Function($$CatalogFoodsTableFilterComposer f) f,
  ) {
    final $$CatalogFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogFoods,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogFoodsTableFilterComposer(
            $db: $db,
            $table: $db.catalogFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> catalogRecipesRefs(
    Expression<bool> Function($$CatalogRecipesTableFilterComposer f) f,
  ) {
    final $$CatalogRecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogRecipes,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogRecipesTableFilterComposer(
            $db: $db,
            $table: $db.catalogRecipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogReleasesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogReleasesTable> {
  $$CatalogReleasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentChecksum => $composableBuilder(
    column: $table.contentChecksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogReleasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogReleasesTable> {
  $$CatalogReleasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentChecksum => $composableBuilder(
    column: $table.contentChecksum,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> catalogFoodsRefs<T extends Object>(
    Expression<T> Function($$CatalogFoodsTableAnnotationComposer a) f,
  ) {
    final $$CatalogFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogFoods,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> catalogRecipesRefs<T extends Object>(
    Expression<T> Function($$CatalogRecipesTableAnnotationComposer a) f,
  ) {
    final $$CatalogRecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogRecipes,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogRecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogRecipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogReleasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogReleasesTable,
          CatalogRelease,
          $$CatalogReleasesTableFilterComposer,
          $$CatalogReleasesTableOrderingComposer,
          $$CatalogReleasesTableAnnotationComposer,
          $$CatalogReleasesTableCreateCompanionBuilder,
          $$CatalogReleasesTableUpdateCompanionBuilder,
          (CatalogRelease, $$CatalogReleasesTableReferences),
          CatalogRelease,
          PrefetchHooks Function({
            bool catalogFoodsRefs,
            bool catalogRecipesRefs,
          })
        > {
  $$CatalogReleasesTableTableManager(
    _$AppDatabase db,
    $CatalogReleasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogReleasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogReleasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogReleasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String> contentChecksum = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogReleasesCompanion(
                releaseId: releaseId,
                version: version,
                reviewStatus: reviewStatus,
                contentChecksum: contentChecksum,
                publishedAt: publishedAt,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String version,
                required String reviewStatus,
                required String contentChecksum,
                Value<DateTime?> publishedAt = const Value.absent(),
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => CatalogReleasesCompanion.insert(
                releaseId: releaseId,
                version: version,
                reviewStatus: reviewStatus,
                contentChecksum: contentChecksum,
                publishedAt: publishedAt,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogReleasesTable, CatalogRelease>(table),
                  $$CatalogReleasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({catalogFoodsRefs = false, catalogRecipesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (catalogFoodsRefs) db.catalogFoods,
                    if (catalogRecipesRefs) db.catalogRecipes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (catalogFoodsRefs)
                        await $_getPrefetchedDataByColumns<
                          CatalogRelease,
                          $CatalogReleasesTable,
                          CatalogFood,
                          $CatalogFoodsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogReleasesTableReferences
                              ._catalogFoodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogReleasesTableReferences(
                                db,
                                table,
                                p0,
                              ).catalogFoodsRefs,
                          currentColumn: 'release_id',
                          referencedColumn: 'release_id',
                          typedResults: items,
                        ),
                      if (catalogRecipesRefs)
                        await $_getPrefetchedDataByColumns<
                          CatalogRelease,
                          $CatalogReleasesTable,
                          CatalogRecipe,
                          $CatalogRecipesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogReleasesTableReferences
                              ._catalogRecipesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogReleasesTableReferences(
                                db,
                                table,
                                p0,
                              ).catalogRecipesRefs,
                          currentColumn: 'release_id',
                          referencedColumn: 'release_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CatalogReleasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogReleasesTable,
      CatalogRelease,
      $$CatalogReleasesTableFilterComposer,
      $$CatalogReleasesTableOrderingComposer,
      $$CatalogReleasesTableAnnotationComposer,
      $$CatalogReleasesTableCreateCompanionBuilder,
      $$CatalogReleasesTableUpdateCompanionBuilder,
      (CatalogRelease, $$CatalogReleasesTableReferences),
      CatalogRelease,
      PrefetchHooks Function({bool catalogFoodsRefs, bool catalogRecipesRefs})
    >;
typedef $$NutritionSourcesTableCreateCompanionBuilder =
    NutritionSourcesCompanion Function({
      required String sourceKey,
      required String sourceId,
      required String sourceVersion,
      required String citation,
      required String licenseId,
      Value<int> rowid,
    });
typedef $$NutritionSourcesTableUpdateCompanionBuilder =
    NutritionSourcesCompanion Function({
      Value<String> sourceKey,
      Value<String> sourceId,
      Value<String> sourceVersion,
      Value<String> citation,
      Value<String> licenseId,
      Value<int> rowid,
    });

final class $$NutritionSourcesTableReferences
    extends
        BaseReferences<_$AppDatabase, $NutritionSourcesTable, NutritionSource> {
  $$NutritionSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CatalogFoodsTable, List<CatalogFood>>
  _catalogFoodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catalogFoods,
    aliasName: 'nutrition_sources__source_key__catalog_foods__source_key',
  );

  $$CatalogFoodsTableProcessedTableManager get catalogFoodsRefs {
    final manager = $$CatalogFoodsTableTableManager($_db, $_db.catalogFoods)
        .filter(
          (f) => f.sourceKey.sourceKey.sqlEquals(
            $_itemColumn<String>('source_key')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_catalogFoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CatalogRecipesTable, List<CatalogRecipe>>
  _catalogRecipesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.catalogRecipes,
    aliasName: 'nutrition_sources__source_key__catalog_recipes__source_key',
  );

  $$CatalogRecipesTableProcessedTableManager get catalogRecipesRefs {
    final manager = $$CatalogRecipesTableTableManager($_db, $_db.catalogRecipes)
        .filter(
          (f) => f.sourceKey.sourceKey.sqlEquals(
            $_itemColumn<String>('source_key')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_catalogRecipesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NutritionSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionSourcesTable> {
  $$NutritionSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citation => $composableBuilder(
    column: $table.citation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseId => $composableBuilder(
    column: $table.licenseId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> catalogFoodsRefs(
    Expression<bool> Function($$CatalogFoodsTableFilterComposer f) f,
  ) {
    final $$CatalogFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.catalogFoods,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogFoodsTableFilterComposer(
            $db: $db,
            $table: $db.catalogFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> catalogRecipesRefs(
    Expression<bool> Function($$CatalogRecipesTableFilterComposer f) f,
  ) {
    final $$CatalogRecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.catalogRecipes,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogRecipesTableFilterComposer(
            $db: $db,
            $table: $db.catalogRecipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NutritionSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionSourcesTable> {
  $$NutritionSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceKey => $composableBuilder(
    column: $table.sourceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citation => $composableBuilder(
    column: $table.citation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseId => $composableBuilder(
    column: $table.licenseId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionSourcesTable> {
  $$NutritionSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceKey =>
      $composableBuilder(column: $table.sourceKey, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get citation =>
      $composableBuilder(column: $table.citation, builder: (column) => column);

  GeneratedColumn<String> get licenseId =>
      $composableBuilder(column: $table.licenseId, builder: (column) => column);

  Expression<T> catalogFoodsRefs<T extends Object>(
    Expression<T> Function($$CatalogFoodsTableAnnotationComposer a) f,
  ) {
    final $$CatalogFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.catalogFoods,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> catalogRecipesRefs<T extends Object>(
    Expression<T> Function($$CatalogRecipesTableAnnotationComposer a) f,
  ) {
    final $$CatalogRecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.catalogRecipes,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogRecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogRecipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NutritionSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionSourcesTable,
          NutritionSource,
          $$NutritionSourcesTableFilterComposer,
          $$NutritionSourcesTableOrderingComposer,
          $$NutritionSourcesTableAnnotationComposer,
          $$NutritionSourcesTableCreateCompanionBuilder,
          $$NutritionSourcesTableUpdateCompanionBuilder,
          (NutritionSource, $$NutritionSourcesTableReferences),
          NutritionSource,
          PrefetchHooks Function({
            bool catalogFoodsRefs,
            bool catalogRecipesRefs,
          })
        > {
  $$NutritionSourcesTableTableManager(
    _$AppDatabase db,
    $NutritionSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceKey = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceVersion = const Value.absent(),
                Value<String> citation = const Value.absent(),
                Value<String> licenseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionSourcesCompanion(
                sourceKey: sourceKey,
                sourceId: sourceId,
                sourceVersion: sourceVersion,
                citation: citation,
                licenseId: licenseId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceKey,
                required String sourceId,
                required String sourceVersion,
                required String citation,
                required String licenseId,
                Value<int> rowid = const Value.absent(),
              }) => NutritionSourcesCompanion.insert(
                sourceKey: sourceKey,
                sourceId: sourceId,
                sourceVersion: sourceVersion,
                citation: citation,
                licenseId: licenseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NutritionSourcesTable, NutritionSource>(table),
                  $$NutritionSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({catalogFoodsRefs = false, catalogRecipesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (catalogFoodsRefs) db.catalogFoods,
                    if (catalogRecipesRefs) db.catalogRecipes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (catalogFoodsRefs)
                        await $_getPrefetchedDataByColumns<
                          NutritionSource,
                          $NutritionSourcesTable,
                          CatalogFood,
                          $CatalogFoodsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NutritionSourcesTableReferences
                              ._catalogFoodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutritionSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).catalogFoodsRefs,
                          currentColumn: 'source_key',
                          referencedColumn: 'source_key',
                          typedResults: items,
                        ),
                      if (catalogRecipesRefs)
                        await $_getPrefetchedDataByColumns<
                          NutritionSource,
                          $NutritionSourcesTable,
                          CatalogRecipe,
                          $CatalogRecipesTable
                        >(
                          currentTable: table,
                          referencedTable: $$NutritionSourcesTableReferences
                              ._catalogRecipesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NutritionSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).catalogRecipesRefs,
                          currentColumn: 'source_key',
                          referencedColumn: 'source_key',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NutritionSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionSourcesTable,
      NutritionSource,
      $$NutritionSourcesTableFilterComposer,
      $$NutritionSourcesTableOrderingComposer,
      $$NutritionSourcesTableAnnotationComposer,
      $$NutritionSourcesTableCreateCompanionBuilder,
      $$NutritionSourcesTableUpdateCompanionBuilder,
      (NutritionSource, $$NutritionSourcesTableReferences),
      NutritionSource,
      PrefetchHooks Function({bool catalogFoodsRefs, bool catalogRecipesRefs})
    >;
typedef $$CatalogFoodsTableCreateCompanionBuilder =
    CatalogFoodsCompanion Function({
      required String releaseId,
      required String foodId,
      required String nameEnglish,
      required String nameRomanUrdu,
      required String normalizedNameEnglish,
      required String normalizedNameRomanUrdu,
      Value<String?> region,
      Value<String?> preparation,
      required double referenceGrams,
      required double caloriesKcal,
      required double proteinGrams,
      required double carbohydrateGrams,
      required double fatGrams,
      Value<double?> sodiumMilligrams,
      required String oilInclusion,
      required String sourceKey,
      required String sourceRecordId,
      required String reviewStatus,
      Value<String?> reviewerId,
      Value<DateTime?> reviewedAt,
      Value<int> rowid,
    });
typedef $$CatalogFoodsTableUpdateCompanionBuilder =
    CatalogFoodsCompanion Function({
      Value<String> releaseId,
      Value<String> foodId,
      Value<String> nameEnglish,
      Value<String> nameRomanUrdu,
      Value<String> normalizedNameEnglish,
      Value<String> normalizedNameRomanUrdu,
      Value<String?> region,
      Value<String?> preparation,
      Value<double> referenceGrams,
      Value<double> caloriesKcal,
      Value<double> proteinGrams,
      Value<double> carbohydrateGrams,
      Value<double> fatGrams,
      Value<double?> sodiumMilligrams,
      Value<String> oilInclusion,
      Value<String> sourceKey,
      Value<String> sourceRecordId,
      Value<String> reviewStatus,
      Value<String?> reviewerId,
      Value<DateTime?> reviewedAt,
      Value<int> rowid,
    });

final class $$CatalogFoodsTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogFoodsTable, CatalogFood> {
  $$CatalogFoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogReleasesTable _releaseIdTable(_$AppDatabase db) => db
      .catalogReleases
      .createAlias('catalog_foods__release_id__catalog_releases__release_id');

  $$CatalogReleasesTableProcessedTableManager get releaseId {
    final $_column = $_itemColumn<String>('release_id')!;

    final manager = $$CatalogReleasesTableTableManager(
      $_db,
      $_db.catalogReleases,
    ).filter((f) => f.releaseId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_releaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NutritionSourcesTable _sourceKeyTable(_$AppDatabase db) => db
      .nutritionSources
      .createAlias('catalog_foods__source_key__nutrition_sources__source_key');

  $$NutritionSourcesTableProcessedTableManager get sourceKey {
    final $_column = $_itemColumn<String>('source_key')!;

    final manager = $$NutritionSourcesTableTableManager(
      $_db,
      $_db.nutritionSources,
    ).filter((f) => f.sourceKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CatalogFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogFoodsTable> {
  $$CatalogFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameRomanUrdu => $composableBuilder(
    column: $table.nameRomanUrdu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNameEnglish => $composableBuilder(
    column: $table.normalizedNameEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNameRomanUrdu => $composableBuilder(
    column: $table.normalizedNameRomanUrdu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceGrams => $composableBuilder(
    column: $table.referenceGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateGrams => $composableBuilder(
    column: $table.carbohydrateGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMilligrams => $composableBuilder(
    column: $table.sodiumMilligrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogReleasesTableFilterComposer get releaseId {
    final $$CatalogReleasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogReleases,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogReleasesTableFilterComposer(
            $db: $db,
            $table: $db.catalogReleases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NutritionSourcesTableFilterComposer get sourceKey {
    final $$NutritionSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.nutritionSources,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionSourcesTableFilterComposer(
            $db: $db,
            $table: $db.nutritionSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogFoodsTable> {
  $$CatalogFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameRomanUrdu => $composableBuilder(
    column: $table.nameRomanUrdu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNameEnglish => $composableBuilder(
    column: $table.normalizedNameEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNameRomanUrdu => $composableBuilder(
    column: $table.normalizedNameRomanUrdu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceGrams => $composableBuilder(
    column: $table.referenceGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateGrams => $composableBuilder(
    column: $table.carbohydrateGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMilligrams => $composableBuilder(
    column: $table.sodiumMilligrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogReleasesTableOrderingComposer get releaseId {
    final $$CatalogReleasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogReleases,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogReleasesTableOrderingComposer(
            $db: $db,
            $table: $db.catalogReleases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NutritionSourcesTableOrderingComposer get sourceKey {
    final $$NutritionSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.nutritionSources,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.nutritionSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogFoodsTable> {
  $$CatalogFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameRomanUrdu => $composableBuilder(
    column: $table.nameRomanUrdu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedNameEnglish => $composableBuilder(
    column: $table.normalizedNameEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedNameRomanUrdu => $composableBuilder(
    column: $table.normalizedNameRomanUrdu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceGrams => $composableBuilder(
    column: $table.referenceGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateGrams => $composableBuilder(
    column: $table.carbohydrateGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get sodiumMilligrams => $composableBuilder(
    column: $table.sodiumMilligrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$CatalogReleasesTableAnnotationComposer get releaseId {
    final $$CatalogReleasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogReleases,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogReleasesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogReleases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NutritionSourcesTableAnnotationComposer get sourceKey {
    final $$NutritionSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.nutritionSources,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogFoodsTable,
          CatalogFood,
          $$CatalogFoodsTableFilterComposer,
          $$CatalogFoodsTableOrderingComposer,
          $$CatalogFoodsTableAnnotationComposer,
          $$CatalogFoodsTableCreateCompanionBuilder,
          $$CatalogFoodsTableUpdateCompanionBuilder,
          (CatalogFood, $$CatalogFoodsTableReferences),
          CatalogFood,
          PrefetchHooks Function({bool releaseId, bool sourceKey})
        > {
  $$CatalogFoodsTableTableManager(_$AppDatabase db, $CatalogFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> nameEnglish = const Value.absent(),
                Value<String> nameRomanUrdu = const Value.absent(),
                Value<String> normalizedNameEnglish = const Value.absent(),
                Value<String> normalizedNameRomanUrdu = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> preparation = const Value.absent(),
                Value<double> referenceGrams = const Value.absent(),
                Value<double> caloriesKcal = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbohydrateGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double?> sodiumMilligrams = const Value.absent(),
                Value<String> oilInclusion = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String> sourceRecordId = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String?> reviewerId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogFoodsCompanion(
                releaseId: releaseId,
                foodId: foodId,
                nameEnglish: nameEnglish,
                nameRomanUrdu: nameRomanUrdu,
                normalizedNameEnglish: normalizedNameEnglish,
                normalizedNameRomanUrdu: normalizedNameRomanUrdu,
                region: region,
                preparation: preparation,
                referenceGrams: referenceGrams,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbohydrateGrams: carbohydrateGrams,
                fatGrams: fatGrams,
                sodiumMilligrams: sodiumMilligrams,
                oilInclusion: oilInclusion,
                sourceKey: sourceKey,
                sourceRecordId: sourceRecordId,
                reviewStatus: reviewStatus,
                reviewerId: reviewerId,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String foodId,
                required String nameEnglish,
                required String nameRomanUrdu,
                required String normalizedNameEnglish,
                required String normalizedNameRomanUrdu,
                Value<String?> region = const Value.absent(),
                Value<String?> preparation = const Value.absent(),
                required double referenceGrams,
                required double caloriesKcal,
                required double proteinGrams,
                required double carbohydrateGrams,
                required double fatGrams,
                Value<double?> sodiumMilligrams = const Value.absent(),
                required String oilInclusion,
                required String sourceKey,
                required String sourceRecordId,
                required String reviewStatus,
                Value<String?> reviewerId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogFoodsCompanion.insert(
                releaseId: releaseId,
                foodId: foodId,
                nameEnglish: nameEnglish,
                nameRomanUrdu: nameRomanUrdu,
                normalizedNameEnglish: normalizedNameEnglish,
                normalizedNameRomanUrdu: normalizedNameRomanUrdu,
                region: region,
                preparation: preparation,
                referenceGrams: referenceGrams,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbohydrateGrams: carbohydrateGrams,
                fatGrams: fatGrams,
                sodiumMilligrams: sodiumMilligrams,
                oilInclusion: oilInclusion,
                sourceKey: sourceKey,
                sourceRecordId: sourceRecordId,
                reviewStatus: reviewStatus,
                reviewerId: reviewerId,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogFoodsTable, CatalogFood>(table),
                  $$CatalogFoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({releaseId = false, sourceKey = false}) {
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
                    if (releaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.releaseId,
                        referencedTable: $$CatalogFoodsTableReferences
                            ._releaseIdTable(db),
                        referencedColumn: $$CatalogFoodsTableReferences
                            ._releaseIdTable(db)
                            .releaseId,
                      ) as T;
                    }
                    if (sourceKey) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceKey,
                        referencedTable: $$CatalogFoodsTableReferences
                            ._sourceKeyTable(db),
                        referencedColumn: $$CatalogFoodsTableReferences
                            ._sourceKeyTable(db)
                            .sourceKey,
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

typedef $$CatalogFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogFoodsTable,
      CatalogFood,
      $$CatalogFoodsTableFilterComposer,
      $$CatalogFoodsTableOrderingComposer,
      $$CatalogFoodsTableAnnotationComposer,
      $$CatalogFoodsTableCreateCompanionBuilder,
      $$CatalogFoodsTableUpdateCompanionBuilder,
      (CatalogFood, $$CatalogFoodsTableReferences),
      CatalogFood,
      PrefetchHooks Function({bool releaseId, bool sourceKey})
    >;
typedef $$CatalogFoodSynonymsTableCreateCompanionBuilder =
    CatalogFoodSynonymsCompanion Function({
      required String releaseId,
      required String foodId,
      required String locale,
      required String synonym,
      required String normalizedSynonym,
      Value<int> rowid,
    });
typedef $$CatalogFoodSynonymsTableUpdateCompanionBuilder =
    CatalogFoodSynonymsCompanion Function({
      Value<String> releaseId,
      Value<String> foodId,
      Value<String> locale,
      Value<String> synonym,
      Value<String> normalizedSynonym,
      Value<int> rowid,
    });

class $$CatalogFoodSynonymsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogFoodSynonymsTable> {
  $$CatalogFoodSynonymsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synonym => $composableBuilder(
    column: $table.synonym,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedSynonym => $composableBuilder(
    column: $table.normalizedSynonym,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogFoodSynonymsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogFoodSynonymsTable> {
  $$CatalogFoodSynonymsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synonym => $composableBuilder(
    column: $table.synonym,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedSynonym => $composableBuilder(
    column: $table.normalizedSynonym,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogFoodSynonymsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogFoodSynonymsTable> {
  $$CatalogFoodSynonymsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get synonym =>
      $composableBuilder(column: $table.synonym, builder: (column) => column);

  GeneratedColumn<String> get normalizedSynonym => $composableBuilder(
    column: $table.normalizedSynonym,
    builder: (column) => column,
  );
}

class $$CatalogFoodSynonymsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogFoodSynonymsTable,
          CatalogFoodSynonym,
          $$CatalogFoodSynonymsTableFilterComposer,
          $$CatalogFoodSynonymsTableOrderingComposer,
          $$CatalogFoodSynonymsTableAnnotationComposer,
          $$CatalogFoodSynonymsTableCreateCompanionBuilder,
          $$CatalogFoodSynonymsTableUpdateCompanionBuilder,
          (
            CatalogFoodSynonym,
            BaseReferences<
              _$AppDatabase,
              $CatalogFoodSynonymsTable,
              CatalogFoodSynonym
            >,
          ),
          CatalogFoodSynonym,
          PrefetchHooks Function()
        > {
  $$CatalogFoodSynonymsTableTableManager(
    _$AppDatabase db,
    $CatalogFoodSynonymsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogFoodSynonymsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogFoodSynonymsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogFoodSynonymsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> synonym = const Value.absent(),
                Value<String> normalizedSynonym = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogFoodSynonymsCompanion(
                releaseId: releaseId,
                foodId: foodId,
                locale: locale,
                synonym: synonym,
                normalizedSynonym: normalizedSynonym,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String foodId,
                required String locale,
                required String synonym,
                required String normalizedSynonym,
                Value<int> rowid = const Value.absent(),
              }) => CatalogFoodSynonymsCompanion.insert(
                releaseId: releaseId,
                foodId: foodId,
                locale: locale,
                synonym: synonym,
                normalizedSynonym: normalizedSynonym,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogFoodSynonymsTable, CatalogFoodSynonym>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogFoodSynonymsTable,
                    CatalogFoodSynonym
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogFoodSynonymsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogFoodSynonymsTable,
      CatalogFoodSynonym,
      $$CatalogFoodSynonymsTableFilterComposer,
      $$CatalogFoodSynonymsTableOrderingComposer,
      $$CatalogFoodSynonymsTableAnnotationComposer,
      $$CatalogFoodSynonymsTableCreateCompanionBuilder,
      $$CatalogFoodSynonymsTableUpdateCompanionBuilder,
      (
        CatalogFoodSynonym,
        BaseReferences<
          _$AppDatabase,
          $CatalogFoodSynonymsTable,
          CatalogFoodSynonym
        >,
      ),
      CatalogFoodSynonym,
      PrefetchHooks Function()
    >;
typedef $$CatalogServingDefinitionsTableCreateCompanionBuilder =
    CatalogServingDefinitionsCompanion Function({
      required String releaseId,
      required String foodId,
      required String servingId,
      required String label,
      required String unitCode,
      required double gramsMinimum,
      required double gramsMaximum,
      required double confidence,
      Value<int> rowid,
    });
typedef $$CatalogServingDefinitionsTableUpdateCompanionBuilder =
    CatalogServingDefinitionsCompanion Function({
      Value<String> releaseId,
      Value<String> foodId,
      Value<String> servingId,
      Value<String> label,
      Value<String> unitCode,
      Value<double> gramsMinimum,
      Value<double> gramsMaximum,
      Value<double> confidence,
      Value<int> rowid,
    });

class $$CatalogServingDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogServingDefinitionsTable> {
  $$CatalogServingDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogServingDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogServingDefinitionsTable> {
  $$CatalogServingDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogServingDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogServingDefinitionsTable> {
  $$CatalogServingDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get servingId =>
      $composableBuilder(column: $table.servingId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );
}

class $$CatalogServingDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogServingDefinitionsTable,
          CatalogServingDefinition,
          $$CatalogServingDefinitionsTableFilterComposer,
          $$CatalogServingDefinitionsTableOrderingComposer,
          $$CatalogServingDefinitionsTableAnnotationComposer,
          $$CatalogServingDefinitionsTableCreateCompanionBuilder,
          $$CatalogServingDefinitionsTableUpdateCompanionBuilder,
          (
            CatalogServingDefinition,
            BaseReferences<
              _$AppDatabase,
              $CatalogServingDefinitionsTable,
              CatalogServingDefinition
            >,
          ),
          CatalogServingDefinition,
          PrefetchHooks Function()
        > {
  $$CatalogServingDefinitionsTableTableManager(
    _$AppDatabase db,
    $CatalogServingDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogServingDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CatalogServingDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogServingDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> servingId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<double> gramsMinimum = const Value.absent(),
                Value<double> gramsMaximum = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogServingDefinitionsCompanion(
                releaseId: releaseId,
                foodId: foodId,
                servingId: servingId,
                label: label,
                unitCode: unitCode,
                gramsMinimum: gramsMinimum,
                gramsMaximum: gramsMaximum,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String foodId,
                required String servingId,
                required String label,
                required String unitCode,
                required double gramsMinimum,
                required double gramsMaximum,
                required double confidence,
                Value<int> rowid = const Value.absent(),
              }) => CatalogServingDefinitionsCompanion.insert(
                releaseId: releaseId,
                foodId: foodId,
                servingId: servingId,
                label: label,
                unitCode: unitCode,
                gramsMinimum: gramsMinimum,
                gramsMaximum: gramsMaximum,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CatalogServingDefinitionsTable,
                    CatalogServingDefinition
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogServingDefinitionsTable,
                    CatalogServingDefinition
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogServingDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogServingDefinitionsTable,
      CatalogServingDefinition,
      $$CatalogServingDefinitionsTableFilterComposer,
      $$CatalogServingDefinitionsTableOrderingComposer,
      $$CatalogServingDefinitionsTableAnnotationComposer,
      $$CatalogServingDefinitionsTableCreateCompanionBuilder,
      $$CatalogServingDefinitionsTableUpdateCompanionBuilder,
      (
        CatalogServingDefinition,
        BaseReferences<
          _$AppDatabase,
          $CatalogServingDefinitionsTable,
          CatalogServingDefinition
        >,
      ),
      CatalogServingDefinition,
      PrefetchHooks Function()
    >;
typedef $$CatalogRecipesTableCreateCompanionBuilder =
    CatalogRecipesCompanion Function({
      required String releaseId,
      required String recipeId,
      required String nameEnglish,
      required String nameRomanUrdu,
      required String normalizedNameEnglish,
      required String normalizedNameRomanUrdu,
      Value<String?> region,
      Value<String?> preparationVariant,
      required double yieldServingsMinimum,
      required double yieldServingsMaximum,
      required String oilTreatment,
      required String sourceKey,
      required String sourceRecordId,
      required String reviewStatus,
      Value<String?> reviewerId,
      Value<DateTime?> reviewedAt,
      Value<int> rowid,
    });
typedef $$CatalogRecipesTableUpdateCompanionBuilder =
    CatalogRecipesCompanion Function({
      Value<String> releaseId,
      Value<String> recipeId,
      Value<String> nameEnglish,
      Value<String> nameRomanUrdu,
      Value<String> normalizedNameEnglish,
      Value<String> normalizedNameRomanUrdu,
      Value<String?> region,
      Value<String?> preparationVariant,
      Value<double> yieldServingsMinimum,
      Value<double> yieldServingsMaximum,
      Value<String> oilTreatment,
      Value<String> sourceKey,
      Value<String> sourceRecordId,
      Value<String> reviewStatus,
      Value<String?> reviewerId,
      Value<DateTime?> reviewedAt,
      Value<int> rowid,
    });

final class $$CatalogRecipesTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogRecipesTable, CatalogRecipe> {
  $$CatalogRecipesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CatalogReleasesTable _releaseIdTable(_$AppDatabase db) => db
      .catalogReleases
      .createAlias('catalog_recipes__release_id__catalog_releases__release_id');

  $$CatalogReleasesTableProcessedTableManager get releaseId {
    final $_column = $_itemColumn<String>('release_id')!;

    final manager = $$CatalogReleasesTableTableManager(
      $_db,
      $_db.catalogReleases,
    ).filter((f) => f.releaseId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_releaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NutritionSourcesTable _sourceKeyTable(_$AppDatabase db) =>
      db.nutritionSources.createAlias(
        'catalog_recipes__source_key__nutrition_sources__source_key',
      );

  $$NutritionSourcesTableProcessedTableManager get sourceKey {
    final $_column = $_itemColumn<String>('source_key')!;

    final manager = $$NutritionSourcesTableTableManager(
      $_db,
      $_db.nutritionSources,
    ).filter((f) => f.sourceKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CatalogRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogRecipesTable> {
  $$CatalogRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameRomanUrdu => $composableBuilder(
    column: $table.nameRomanUrdu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNameEnglish => $composableBuilder(
    column: $table.normalizedNameEnglish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedNameRomanUrdu => $composableBuilder(
    column: $table.normalizedNameRomanUrdu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preparationVariant => $composableBuilder(
    column: $table.preparationVariant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yieldServingsMinimum => $composableBuilder(
    column: $table.yieldServingsMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yieldServingsMaximum => $composableBuilder(
    column: $table.yieldServingsMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oilTreatment => $composableBuilder(
    column: $table.oilTreatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogReleasesTableFilterComposer get releaseId {
    final $$CatalogReleasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogReleases,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogReleasesTableFilterComposer(
            $db: $db,
            $table: $db.catalogReleases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NutritionSourcesTableFilterComposer get sourceKey {
    final $$NutritionSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.nutritionSources,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionSourcesTableFilterComposer(
            $db: $db,
            $table: $db.nutritionSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogRecipesTable> {
  $$CatalogRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameRomanUrdu => $composableBuilder(
    column: $table.nameRomanUrdu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNameEnglish => $composableBuilder(
    column: $table.normalizedNameEnglish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedNameRomanUrdu => $composableBuilder(
    column: $table.normalizedNameRomanUrdu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preparationVariant => $composableBuilder(
    column: $table.preparationVariant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yieldServingsMinimum => $composableBuilder(
    column: $table.yieldServingsMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yieldServingsMaximum => $composableBuilder(
    column: $table.yieldServingsMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oilTreatment => $composableBuilder(
    column: $table.oilTreatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogReleasesTableOrderingComposer get releaseId {
    final $$CatalogReleasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogReleases,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogReleasesTableOrderingComposer(
            $db: $db,
            $table: $db.catalogReleases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NutritionSourcesTableOrderingComposer get sourceKey {
    final $$NutritionSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.nutritionSources,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.nutritionSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogRecipesTable> {
  $$CatalogRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get nameEnglish => $composableBuilder(
    column: $table.nameEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameRomanUrdu => $composableBuilder(
    column: $table.nameRomanUrdu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedNameEnglish => $composableBuilder(
    column: $table.normalizedNameEnglish,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedNameRomanUrdu => $composableBuilder(
    column: $table.normalizedNameRomanUrdu,
    builder: (column) => column,
  );

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get preparationVariant => $composableBuilder(
    column: $table.preparationVariant,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yieldServingsMinimum => $composableBuilder(
    column: $table.yieldServingsMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yieldServingsMaximum => $composableBuilder(
    column: $table.yieldServingsMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oilTreatment => $composableBuilder(
    column: $table.oilTreatment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewerId => $composableBuilder(
    column: $table.reviewerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$CatalogReleasesTableAnnotationComposer get releaseId {
    final $$CatalogReleasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.releaseId,
      referencedTable: $db.catalogReleases,
      getReferencedColumn: (t) => t.releaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogReleasesTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogReleases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NutritionSourcesTableAnnotationComposer get sourceKey {
    final $$NutritionSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceKey,
      referencedTable: $db.nutritionSources,
      getReferencedColumn: (t) => t.sourceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NutritionSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.nutritionSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogRecipesTable,
          CatalogRecipe,
          $$CatalogRecipesTableFilterComposer,
          $$CatalogRecipesTableOrderingComposer,
          $$CatalogRecipesTableAnnotationComposer,
          $$CatalogRecipesTableCreateCompanionBuilder,
          $$CatalogRecipesTableUpdateCompanionBuilder,
          (CatalogRecipe, $$CatalogRecipesTableReferences),
          CatalogRecipe,
          PrefetchHooks Function({bool releaseId, bool sourceKey})
        > {
  $$CatalogRecipesTableTableManager(
    _$AppDatabase db,
    $CatalogRecipesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> nameEnglish = const Value.absent(),
                Value<String> nameRomanUrdu = const Value.absent(),
                Value<String> normalizedNameEnglish = const Value.absent(),
                Value<String> normalizedNameRomanUrdu = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> preparationVariant = const Value.absent(),
                Value<double> yieldServingsMinimum = const Value.absent(),
                Value<double> yieldServingsMaximum = const Value.absent(),
                Value<String> oilTreatment = const Value.absent(),
                Value<String> sourceKey = const Value.absent(),
                Value<String> sourceRecordId = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String?> reviewerId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRecipesCompanion(
                releaseId: releaseId,
                recipeId: recipeId,
                nameEnglish: nameEnglish,
                nameRomanUrdu: nameRomanUrdu,
                normalizedNameEnglish: normalizedNameEnglish,
                normalizedNameRomanUrdu: normalizedNameRomanUrdu,
                region: region,
                preparationVariant: preparationVariant,
                yieldServingsMinimum: yieldServingsMinimum,
                yieldServingsMaximum: yieldServingsMaximum,
                oilTreatment: oilTreatment,
                sourceKey: sourceKey,
                sourceRecordId: sourceRecordId,
                reviewStatus: reviewStatus,
                reviewerId: reviewerId,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String recipeId,
                required String nameEnglish,
                required String nameRomanUrdu,
                required String normalizedNameEnglish,
                required String normalizedNameRomanUrdu,
                Value<String?> region = const Value.absent(),
                Value<String?> preparationVariant = const Value.absent(),
                required double yieldServingsMinimum,
                required double yieldServingsMaximum,
                required String oilTreatment,
                required String sourceKey,
                required String sourceRecordId,
                required String reviewStatus,
                Value<String?> reviewerId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRecipesCompanion.insert(
                releaseId: releaseId,
                recipeId: recipeId,
                nameEnglish: nameEnglish,
                nameRomanUrdu: nameRomanUrdu,
                normalizedNameEnglish: normalizedNameEnglish,
                normalizedNameRomanUrdu: normalizedNameRomanUrdu,
                region: region,
                preparationVariant: preparationVariant,
                yieldServingsMinimum: yieldServingsMinimum,
                yieldServingsMaximum: yieldServingsMaximum,
                oilTreatment: oilTreatment,
                sourceKey: sourceKey,
                sourceRecordId: sourceRecordId,
                reviewStatus: reviewStatus,
                reviewerId: reviewerId,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatalogRecipesTable, CatalogRecipe>(table),
                  $$CatalogRecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({releaseId = false, sourceKey = false}) {
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
                    if (releaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.releaseId,
                        referencedTable: $$CatalogRecipesTableReferences
                            ._releaseIdTable(db),
                        referencedColumn: $$CatalogRecipesTableReferences
                            ._releaseIdTable(db)
                            .releaseId,
                      ) as T;
                    }
                    if (sourceKey) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceKey,
                        referencedTable: $$CatalogRecipesTableReferences
                            ._sourceKeyTable(db),
                        referencedColumn: $$CatalogRecipesTableReferences
                            ._sourceKeyTable(db)
                            .sourceKey,
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

typedef $$CatalogRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogRecipesTable,
      CatalogRecipe,
      $$CatalogRecipesTableFilterComposer,
      $$CatalogRecipesTableOrderingComposer,
      $$CatalogRecipesTableAnnotationComposer,
      $$CatalogRecipesTableCreateCompanionBuilder,
      $$CatalogRecipesTableUpdateCompanionBuilder,
      (CatalogRecipe, $$CatalogRecipesTableReferences),
      CatalogRecipe,
      PrefetchHooks Function({bool releaseId, bool sourceKey})
    >;
typedef $$CatalogRecipeSynonymsTableCreateCompanionBuilder =
    CatalogRecipeSynonymsCompanion Function({
      required String releaseId,
      required String recipeId,
      required String locale,
      required String synonym,
      required String normalizedSynonym,
      Value<int> rowid,
    });
typedef $$CatalogRecipeSynonymsTableUpdateCompanionBuilder =
    CatalogRecipeSynonymsCompanion Function({
      Value<String> releaseId,
      Value<String> recipeId,
      Value<String> locale,
      Value<String> synonym,
      Value<String> normalizedSynonym,
      Value<int> rowid,
    });

class $$CatalogRecipeSynonymsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogRecipeSynonymsTable> {
  $$CatalogRecipeSynonymsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synonym => $composableBuilder(
    column: $table.synonym,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedSynonym => $composableBuilder(
    column: $table.normalizedSynonym,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogRecipeSynonymsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogRecipeSynonymsTable> {
  $$CatalogRecipeSynonymsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synonym => $composableBuilder(
    column: $table.synonym,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedSynonym => $composableBuilder(
    column: $table.normalizedSynonym,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogRecipeSynonymsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogRecipeSynonymsTable> {
  $$CatalogRecipeSynonymsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get synonym =>
      $composableBuilder(column: $table.synonym, builder: (column) => column);

  GeneratedColumn<String> get normalizedSynonym => $composableBuilder(
    column: $table.normalizedSynonym,
    builder: (column) => column,
  );
}

class $$CatalogRecipeSynonymsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogRecipeSynonymsTable,
          CatalogRecipeSynonym,
          $$CatalogRecipeSynonymsTableFilterComposer,
          $$CatalogRecipeSynonymsTableOrderingComposer,
          $$CatalogRecipeSynonymsTableAnnotationComposer,
          $$CatalogRecipeSynonymsTableCreateCompanionBuilder,
          $$CatalogRecipeSynonymsTableUpdateCompanionBuilder,
          (
            CatalogRecipeSynonym,
            BaseReferences<
              _$AppDatabase,
              $CatalogRecipeSynonymsTable,
              CatalogRecipeSynonym
            >,
          ),
          CatalogRecipeSynonym,
          PrefetchHooks Function()
        > {
  $$CatalogRecipeSynonymsTableTableManager(
    _$AppDatabase db,
    $CatalogRecipeSynonymsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogRecipeSynonymsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CatalogRecipeSynonymsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogRecipeSynonymsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> synonym = const Value.absent(),
                Value<String> normalizedSynonym = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRecipeSynonymsCompanion(
                releaseId: releaseId,
                recipeId: recipeId,
                locale: locale,
                synonym: synonym,
                normalizedSynonym: normalizedSynonym,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String recipeId,
                required String locale,
                required String synonym,
                required String normalizedSynonym,
                Value<int> rowid = const Value.absent(),
              }) => CatalogRecipeSynonymsCompanion.insert(
                releaseId: releaseId,
                recipeId: recipeId,
                locale: locale,
                synonym: synonym,
                normalizedSynonym: normalizedSynonym,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CatalogRecipeSynonymsTable,
                    CatalogRecipeSynonym
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogRecipeSynonymsTable,
                    CatalogRecipeSynonym
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogRecipeSynonymsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogRecipeSynonymsTable,
      CatalogRecipeSynonym,
      $$CatalogRecipeSynonymsTableFilterComposer,
      $$CatalogRecipeSynonymsTableOrderingComposer,
      $$CatalogRecipeSynonymsTableAnnotationComposer,
      $$CatalogRecipeSynonymsTableCreateCompanionBuilder,
      $$CatalogRecipeSynonymsTableUpdateCompanionBuilder,
      (
        CatalogRecipeSynonym,
        BaseReferences<
          _$AppDatabase,
          $CatalogRecipeSynonymsTable,
          CatalogRecipeSynonym
        >,
      ),
      CatalogRecipeSynonym,
      PrefetchHooks Function()
    >;
typedef $$CatalogRecipeIngredientsTableCreateCompanionBuilder =
    CatalogRecipeIngredientsCompanion Function({
      required String releaseId,
      required String recipeId,
      required int ingredientIndex,
      required String foodId,
      required String servingId,
      required double quantity,
      Value<double?> exactGramsPerServing,
      Value<int> rowid,
    });
typedef $$CatalogRecipeIngredientsTableUpdateCompanionBuilder =
    CatalogRecipeIngredientsCompanion Function({
      Value<String> releaseId,
      Value<String> recipeId,
      Value<int> ingredientIndex,
      Value<String> foodId,
      Value<String> servingId,
      Value<double> quantity,
      Value<double?> exactGramsPerServing,
      Value<int> rowid,
    });

class $$CatalogRecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogRecipeIngredientsTable> {
  $$CatalogRecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ingredientIndex => $composableBuilder(
    column: $table.ingredientIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exactGramsPerServing => $composableBuilder(
    column: $table.exactGramsPerServing,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogRecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogRecipeIngredientsTable> {
  $$CatalogRecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ingredientIndex => $composableBuilder(
    column: $table.ingredientIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exactGramsPerServing => $composableBuilder(
    column: $table.exactGramsPerServing,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogRecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogRecipeIngredientsTable> {
  $$CatalogRecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get ingredientIndex => $composableBuilder(
    column: $table.ingredientIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get servingId =>
      $composableBuilder(column: $table.servingId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get exactGramsPerServing => $composableBuilder(
    column: $table.exactGramsPerServing,
    builder: (column) => column,
  );
}

class $$CatalogRecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogRecipeIngredientsTable,
          CatalogRecipeIngredient,
          $$CatalogRecipeIngredientsTableFilterComposer,
          $$CatalogRecipeIngredientsTableOrderingComposer,
          $$CatalogRecipeIngredientsTableAnnotationComposer,
          $$CatalogRecipeIngredientsTableCreateCompanionBuilder,
          $$CatalogRecipeIngredientsTableUpdateCompanionBuilder,
          (
            CatalogRecipeIngredient,
            BaseReferences<
              _$AppDatabase,
              $CatalogRecipeIngredientsTable,
              CatalogRecipeIngredient
            >,
          ),
          CatalogRecipeIngredient,
          PrefetchHooks Function()
        > {
  $$CatalogRecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $CatalogRecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogRecipeIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CatalogRecipeIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CatalogRecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> releaseId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> ingredientIndex = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> servingId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> exactGramsPerServing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRecipeIngredientsCompanion(
                releaseId: releaseId,
                recipeId: recipeId,
                ingredientIndex: ingredientIndex,
                foodId: foodId,
                servingId: servingId,
                quantity: quantity,
                exactGramsPerServing: exactGramsPerServing,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String releaseId,
                required String recipeId,
                required int ingredientIndex,
                required String foodId,
                required String servingId,
                required double quantity,
                Value<double?> exactGramsPerServing = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogRecipeIngredientsCompanion.insert(
                releaseId: releaseId,
                recipeId: recipeId,
                ingredientIndex: ingredientIndex,
                foodId: foodId,
                servingId: servingId,
                quantity: quantity,
                exactGramsPerServing: exactGramsPerServing,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CatalogRecipeIngredientsTable,
                    CatalogRecipeIngredient
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CatalogRecipeIngredientsTable,
                    CatalogRecipeIngredient
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogRecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogRecipeIngredientsTable,
      CatalogRecipeIngredient,
      $$CatalogRecipeIngredientsTableFilterComposer,
      $$CatalogRecipeIngredientsTableOrderingComposer,
      $$CatalogRecipeIngredientsTableAnnotationComposer,
      $$CatalogRecipeIngredientsTableCreateCompanionBuilder,
      $$CatalogRecipeIngredientsTableUpdateCompanionBuilder,
      (
        CatalogRecipeIngredient,
        BaseReferences<
          _$AppDatabase,
          $CatalogRecipeIngredientsTable,
          CatalogRecipeIngredient
        >,
      ),
      CatalogRecipeIngredient,
      PrefetchHooks Function()
    >;
typedef $$MealEventsTableCreateCompanionBuilder = MealEventsCompanion Function({
  required String ownerId,
  required String eventId,
  required String mealType,
  required DateTime occurredAtUtc,
  required int timezoneOffsetMinutes,
  required DateTime createdAtUtc,
  required String rawUserInput,
  Value<String?> aiProvenanceJson,
  Value<String?> supersedesEventId,
  required int revision,
  required String calculationVersion,
  required double caloriesMinimum,
  required double caloriesMaximum,
  required double proteinMinimum,
  required double proteinMaximum,
  required double carbohydrateMinimum,
  required double carbohydrateMaximum,
  required double fatMinimum,
  required double fatMaximum,
  Value<double?> sodiumMinimum,
  Value<double?> sodiumMaximum,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$MealEventsTableUpdateCompanionBuilder = MealEventsCompanion Function({
  Value<String> ownerId,
  Value<String> eventId,
  Value<String> mealType,
  Value<DateTime> occurredAtUtc,
  Value<int> timezoneOffsetMinutes,
  Value<DateTime> createdAtUtc,
  Value<String> rawUserInput,
  Value<String?> aiProvenanceJson,
  Value<String?> supersedesEventId,
  Value<int> revision,
  Value<String> calculationVersion,
  Value<double> caloriesMinimum,
  Value<double> caloriesMaximum,
  Value<double> proteinMinimum,
  Value<double> proteinMaximum,
  Value<double> carbohydrateMinimum,
  Value<double> carbohydrateMaximum,
  Value<double> fatMinimum,
  Value<double> fatMaximum,
  Value<double?> sodiumMinimum,
  Value<double?> sodiumMaximum,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$MealEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MealEventsTable> {
  $$MealEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawUserInput => $composableBuilder(
    column: $table.rawUserInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiProvenanceJson => $composableBuilder(
    column: $table.aiProvenanceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEventsTable> {
  $$MealEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawUserInput => $composableBuilder(
    column: $table.rawUserInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiProvenanceJson => $composableBuilder(
    column: $table.aiProvenanceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEventsTable> {
  $$MealEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawUserInput => $composableBuilder(
    column: $table.rawUserInput,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiProvenanceJson => $composableBuilder(
    column: $table.aiProvenanceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$MealEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEventsTable,
          MealEvent,
          $$MealEventsTableFilterComposer,
          $$MealEventsTableOrderingComposer,
          $$MealEventsTableAnnotationComposer,
          $$MealEventsTableCreateCompanionBuilder,
          $$MealEventsTableUpdateCompanionBuilder,
          (
            MealEvent,
            BaseReferences<_$AppDatabase, $MealEventsTable, MealEvent>,
          ),
          MealEvent,
          PrefetchHooks Function()
        > {
  $$MealEventsTableTableManager(_$AppDatabase db, $MealEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<String> rawUserInput = const Value.absent(),
                Value<String?> aiProvenanceJson = const Value.absent(),
                Value<String?> supersedesEventId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> calculationVersion = const Value.absent(),
                Value<double> caloriesMinimum = const Value.absent(),
                Value<double> caloriesMaximum = const Value.absent(),
                Value<double> proteinMinimum = const Value.absent(),
                Value<double> proteinMaximum = const Value.absent(),
                Value<double> carbohydrateMinimum = const Value.absent(),
                Value<double> carbohydrateMaximum = const Value.absent(),
                Value<double> fatMinimum = const Value.absent(),
                Value<double> fatMaximum = const Value.absent(),
                Value<double?> sodiumMinimum = const Value.absent(),
                Value<double?> sodiumMaximum = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEventsCompanion(
                ownerId: ownerId,
                eventId: eventId,
                mealType: mealType,
                occurredAtUtc: occurredAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAtUtc: createdAtUtc,
                rawUserInput: rawUserInput,
                aiProvenanceJson: aiProvenanceJson,
                supersedesEventId: supersedesEventId,
                revision: revision,
                calculationVersion: calculationVersion,
                caloriesMinimum: caloriesMinimum,
                caloriesMaximum: caloriesMaximum,
                proteinMinimum: proteinMinimum,
                proteinMaximum: proteinMaximum,
                carbohydrateMinimum: carbohydrateMinimum,
                carbohydrateMaximum: carbohydrateMaximum,
                fatMinimum: fatMinimum,
                fatMaximum: fatMaximum,
                sodiumMinimum: sodiumMinimum,
                sodiumMaximum: sodiumMaximum,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String eventId,
                required String mealType,
                required DateTime occurredAtUtc,
                required int timezoneOffsetMinutes,
                required DateTime createdAtUtc,
                required String rawUserInput,
                Value<String?> aiProvenanceJson = const Value.absent(),
                Value<String?> supersedesEventId = const Value.absent(),
                required int revision,
                required String calculationVersion,
                required double caloriesMinimum,
                required double caloriesMaximum,
                required double proteinMinimum,
                required double proteinMaximum,
                required double carbohydrateMinimum,
                required double carbohydrateMaximum,
                required double fatMinimum,
                required double fatMaximum,
                Value<double?> sodiumMinimum = const Value.absent(),
                Value<double?> sodiumMaximum = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEventsCompanion.insert(
                ownerId: ownerId,
                eventId: eventId,
                mealType: mealType,
                occurredAtUtc: occurredAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAtUtc: createdAtUtc,
                rawUserInput: rawUserInput,
                aiProvenanceJson: aiProvenanceJson,
                supersedesEventId: supersedesEventId,
                revision: revision,
                calculationVersion: calculationVersion,
                caloriesMinimum: caloriesMinimum,
                caloriesMaximum: caloriesMaximum,
                proteinMinimum: proteinMinimum,
                proteinMaximum: proteinMaximum,
                carbohydrateMinimum: carbohydrateMinimum,
                carbohydrateMaximum: carbohydrateMaximum,
                fatMinimum: fatMinimum,
                fatMaximum: fatMaximum,
                sodiumMinimum: sodiumMinimum,
                sodiumMaximum: sodiumMaximum,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MealEventsTable, MealEvent>(table),
                  BaseReferences<_$AppDatabase, $MealEventsTable, MealEvent>(
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

typedef $$MealEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEventsTable,
      MealEvent,
      $$MealEventsTableFilterComposer,
      $$MealEventsTableOrderingComposer,
      $$MealEventsTableAnnotationComposer,
      $$MealEventsTableCreateCompanionBuilder,
      $$MealEventsTableUpdateCompanionBuilder,
      (MealEvent, BaseReferences<_$AppDatabase, $MealEventsTable, MealEvent>),
      MealEvent,
      PrefetchHooks Function()
    >;
typedef $$MealItemsTableCreateCompanionBuilder = MealItemsCompanion Function({
  required String ownerId,
  required String eventId,
  required int itemIndex,
  Value<String> catalogItemType,
  Value<String> weightBasis,
  required String catalogReleaseId,
  required String foodId,
  required String sourceId,
  required String sourceVersion,
  required String sourceRecordId,
  required String servingId,
  required String servingLabel,
  required String unitCode,
  required double quantity,
  required double gramsMinimum,
  required double gramsMaximum,
  required double servingConfidence,
  required double caloriesMinimum,
  required double caloriesMaximum,
  required double proteinMinimum,
  required double proteinMaximum,
  required double carbohydrateMinimum,
  required double carbohydrateMaximum,
  required double fatMinimum,
  required double fatMaximum,
  Value<double?> sodiumMinimum,
  Value<double?> sodiumMaximum,
  required String oilInclusion,
  required String calculationVersion,
  Value<int> rowid,
});
typedef $$MealItemsTableUpdateCompanionBuilder = MealItemsCompanion Function({
  Value<String> ownerId,
  Value<String> eventId,
  Value<int> itemIndex,
  Value<String> catalogItemType,
  Value<String> weightBasis,
  Value<String> catalogReleaseId,
  Value<String> foodId,
  Value<String> sourceId,
  Value<String> sourceVersion,
  Value<String> sourceRecordId,
  Value<String> servingId,
  Value<String> servingLabel,
  Value<String> unitCode,
  Value<double> quantity,
  Value<double> gramsMinimum,
  Value<double> gramsMaximum,
  Value<double> servingConfidence,
  Value<double> caloriesMinimum,
  Value<double> caloriesMaximum,
  Value<double> proteinMinimum,
  Value<double> proteinMaximum,
  Value<double> carbohydrateMinimum,
  Value<double> carbohydrateMaximum,
  Value<double> fatMinimum,
  Value<double> fatMaximum,
  Value<double?> sodiumMinimum,
  Value<double?> sodiumMaximum,
  Value<String> oilInclusion,
  Value<String> calculationVersion,
  Value<int> rowid,
});

class $$MealItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogItemType => $composableBuilder(
    column: $table.catalogItemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightBasis => $composableBuilder(
    column: $table.weightBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogReleaseId => $composableBuilder(
    column: $table.catalogReleaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingConfidence => $composableBuilder(
    column: $table.servingConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogItemType => $composableBuilder(
    column: $table.catalogItemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightBasis => $composableBuilder(
    column: $table.weightBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogReleaseId => $composableBuilder(
    column: $table.catalogReleaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingConfidence => $composableBuilder(
    column: $table.servingConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<int> get itemIndex =>
      $composableBuilder(column: $table.itemIndex, builder: (column) => column);

  GeneratedColumn<String> get catalogItemType => $composableBuilder(
    column: $table.catalogItemType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightBasis => $composableBuilder(
    column: $table.weightBasis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogReleaseId => $composableBuilder(
    column: $table.catalogReleaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingId =>
      $composableBuilder(column: $table.servingId, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingConfidence => $composableBuilder(
    column: $table.servingConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => column,
  );
}

class $$MealItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealItemsTable,
          MealItem,
          $$MealItemsTableFilterComposer,
          $$MealItemsTableOrderingComposer,
          $$MealItemsTableAnnotationComposer,
          $$MealItemsTableCreateCompanionBuilder,
          $$MealItemsTableUpdateCompanionBuilder,
          (MealItem, BaseReferences<_$AppDatabase, $MealItemsTable, MealItem>),
          MealItem,
          PrefetchHooks Function()
        > {
  $$MealItemsTableTableManager(_$AppDatabase db, $MealItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> itemIndex = const Value.absent(),
                Value<String> catalogItemType = const Value.absent(),
                Value<String> weightBasis = const Value.absent(),
                Value<String> catalogReleaseId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceVersion = const Value.absent(),
                Value<String> sourceRecordId = const Value.absent(),
                Value<String> servingId = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> gramsMinimum = const Value.absent(),
                Value<double> gramsMaximum = const Value.absent(),
                Value<double> servingConfidence = const Value.absent(),
                Value<double> caloriesMinimum = const Value.absent(),
                Value<double> caloriesMaximum = const Value.absent(),
                Value<double> proteinMinimum = const Value.absent(),
                Value<double> proteinMaximum = const Value.absent(),
                Value<double> carbohydrateMinimum = const Value.absent(),
                Value<double> carbohydrateMaximum = const Value.absent(),
                Value<double> fatMinimum = const Value.absent(),
                Value<double> fatMaximum = const Value.absent(),
                Value<double?> sodiumMinimum = const Value.absent(),
                Value<double?> sodiumMaximum = const Value.absent(),
                Value<String> oilInclusion = const Value.absent(),
                Value<String> calculationVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealItemsCompanion(
                ownerId: ownerId,
                eventId: eventId,
                itemIndex: itemIndex,
                catalogItemType: catalogItemType,
                weightBasis: weightBasis,
                catalogReleaseId: catalogReleaseId,
                foodId: foodId,
                sourceId: sourceId,
                sourceVersion: sourceVersion,
                sourceRecordId: sourceRecordId,
                servingId: servingId,
                servingLabel: servingLabel,
                unitCode: unitCode,
                quantity: quantity,
                gramsMinimum: gramsMinimum,
                gramsMaximum: gramsMaximum,
                servingConfidence: servingConfidence,
                caloriesMinimum: caloriesMinimum,
                caloriesMaximum: caloriesMaximum,
                proteinMinimum: proteinMinimum,
                proteinMaximum: proteinMaximum,
                carbohydrateMinimum: carbohydrateMinimum,
                carbohydrateMaximum: carbohydrateMaximum,
                fatMinimum: fatMinimum,
                fatMaximum: fatMaximum,
                sodiumMinimum: sodiumMinimum,
                sodiumMaximum: sodiumMaximum,
                oilInclusion: oilInclusion,
                calculationVersion: calculationVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String eventId,
                required int itemIndex,
                Value<String> catalogItemType = const Value.absent(),
                Value<String> weightBasis = const Value.absent(),
                required String catalogReleaseId,
                required String foodId,
                required String sourceId,
                required String sourceVersion,
                required String sourceRecordId,
                required String servingId,
                required String servingLabel,
                required String unitCode,
                required double quantity,
                required double gramsMinimum,
                required double gramsMaximum,
                required double servingConfidence,
                required double caloriesMinimum,
                required double caloriesMaximum,
                required double proteinMinimum,
                required double proteinMaximum,
                required double carbohydrateMinimum,
                required double carbohydrateMaximum,
                required double fatMinimum,
                required double fatMaximum,
                Value<double?> sodiumMinimum = const Value.absent(),
                Value<double?> sodiumMaximum = const Value.absent(),
                required String oilInclusion,
                required String calculationVersion,
                Value<int> rowid = const Value.absent(),
              }) => MealItemsCompanion.insert(
                ownerId: ownerId,
                eventId: eventId,
                itemIndex: itemIndex,
                catalogItemType: catalogItemType,
                weightBasis: weightBasis,
                catalogReleaseId: catalogReleaseId,
                foodId: foodId,
                sourceId: sourceId,
                sourceVersion: sourceVersion,
                sourceRecordId: sourceRecordId,
                servingId: servingId,
                servingLabel: servingLabel,
                unitCode: unitCode,
                quantity: quantity,
                gramsMinimum: gramsMinimum,
                gramsMaximum: gramsMaximum,
                servingConfidence: servingConfidence,
                caloriesMinimum: caloriesMinimum,
                caloriesMaximum: caloriesMaximum,
                proteinMinimum: proteinMinimum,
                proteinMaximum: proteinMaximum,
                carbohydrateMinimum: carbohydrateMinimum,
                carbohydrateMaximum: carbohydrateMaximum,
                fatMinimum: fatMinimum,
                fatMaximum: fatMaximum,
                sodiumMinimum: sodiumMinimum,
                sodiumMaximum: sodiumMaximum,
                oilInclusion: oilInclusion,
                calculationVersion: calculationVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MealItemsTable, MealItem>(table),
                  BaseReferences<_$AppDatabase, $MealItemsTable, MealItem>(
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

typedef $$MealItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealItemsTable,
      MealItem,
      $$MealItemsTableFilterComposer,
      $$MealItemsTableOrderingComposer,
      $$MealItemsTableAnnotationComposer,
      $$MealItemsTableCreateCompanionBuilder,
      $$MealItemsTableUpdateCompanionBuilder,
      (MealItem, BaseReferences<_$AppDatabase, $MealItemsTable, MealItem>),
      MealItem,
      PrefetchHooks Function()
    >;
typedef $$WaterEventsTableCreateCompanionBuilder =
    WaterEventsCompanion Function({
      required String ownerId,
      required String eventId,
      required DateTime occurredAtUtc,
      required int timezoneOffsetMinutes,
      required DateTime createdAtUtc,
      required int volumeMilliliters,
      Value<String?> supersedesEventId,
      required int revision,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$WaterEventsTableUpdateCompanionBuilder =
    WaterEventsCompanion Function({
      Value<String> ownerId,
      Value<String> eventId,
      Value<DateTime> occurredAtUtc,
      Value<int> timezoneOffsetMinutes,
      Value<DateTime> createdAtUtc,
      Value<int> volumeMilliliters,
      Value<String?> supersedesEventId,
      Value<int> revision,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$WaterEventsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterEventsTable> {
  $$WaterEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volumeMilliliters => $composableBuilder(
    column: $table.volumeMilliliters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterEventsTable> {
  $$WaterEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volumeMilliliters => $composableBuilder(
    column: $table.volumeMilliliters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterEventsTable> {
  $$WaterEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get volumeMilliliters => $composableBuilder(
    column: $table.volumeMilliliters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$WaterEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterEventsTable,
          WaterEvent,
          $$WaterEventsTableFilterComposer,
          $$WaterEventsTableOrderingComposer,
          $$WaterEventsTableAnnotationComposer,
          $$WaterEventsTableCreateCompanionBuilder,
          $$WaterEventsTableUpdateCompanionBuilder,
          (
            WaterEvent,
            BaseReferences<_$AppDatabase, $WaterEventsTable, WaterEvent>,
          ),
          WaterEvent,
          PrefetchHooks Function()
        > {
  $$WaterEventsTableTableManager(_$AppDatabase db, $WaterEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<int> volumeMilliliters = const Value.absent(),
                Value<String?> supersedesEventId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterEventsCompanion(
                ownerId: ownerId,
                eventId: eventId,
                occurredAtUtc: occurredAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAtUtc: createdAtUtc,
                volumeMilliliters: volumeMilliliters,
                supersedesEventId: supersedesEventId,
                revision: revision,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String eventId,
                required DateTime occurredAtUtc,
                required int timezoneOffsetMinutes,
                required DateTime createdAtUtc,
                required int volumeMilliliters,
                Value<String?> supersedesEventId = const Value.absent(),
                required int revision,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterEventsCompanion.insert(
                ownerId: ownerId,
                eventId: eventId,
                occurredAtUtc: occurredAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAtUtc: createdAtUtc,
                volumeMilliliters: volumeMilliliters,
                supersedesEventId: supersedesEventId,
                revision: revision,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterEventsTable, WaterEvent>(table),
                  BaseReferences<_$AppDatabase, $WaterEventsTable, WaterEvent>(
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

typedef $$WaterEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterEventsTable,
      WaterEvent,
      $$WaterEventsTableFilterComposer,
      $$WaterEventsTableOrderingComposer,
      $$WaterEventsTableAnnotationComposer,
      $$WaterEventsTableCreateCompanionBuilder,
      $$WaterEventsTableUpdateCompanionBuilder,
      (
        WaterEvent,
        BaseReferences<_$AppDatabase, $WaterEventsTable, WaterEvent>,
      ),
      WaterEvent,
      PrefetchHooks Function()
    >;
typedef $$WeightEventsTableCreateCompanionBuilder =
    WeightEventsCompanion Function({
      required String ownerId,
      required String eventId,
      required DateTime occurredAtUtc,
      required int timezoneOffsetMinutes,
      required DateTime createdAtUtc,
      required double weightKilograms,
      Value<String> note,
      Value<String?> supersedesEventId,
      required int revision,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$WeightEventsTableUpdateCompanionBuilder =
    WeightEventsCompanion Function({
      Value<String> ownerId,
      Value<String> eventId,
      Value<DateTime> occurredAtUtc,
      Value<int> timezoneOffsetMinutes,
      Value<DateTime> createdAtUtc,
      Value<double> weightKilograms,
      Value<String> note,
      Value<String?> supersedesEventId,
      Value<int> revision,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$WeightEventsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEventsTable> {
  $$WeightEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKilograms => $composableBuilder(
    column: $table.weightKilograms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEventsTable> {
  $$WeightEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKilograms => $composableBuilder(
    column: $table.weightKilograms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEventsTable> {
  $$WeightEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timezoneOffsetMinutes => $composableBuilder(
    column: $table.timezoneOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKilograms => $composableBuilder(
    column: $table.weightKilograms,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get supersedesEventId => $composableBuilder(
    column: $table.supersedesEventId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$WeightEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEventsTable,
          WeightEvent,
          $$WeightEventsTableFilterComposer,
          $$WeightEventsTableOrderingComposer,
          $$WeightEventsTableAnnotationComposer,
          $$WeightEventsTableCreateCompanionBuilder,
          $$WeightEventsTableUpdateCompanionBuilder,
          (
            WeightEvent,
            BaseReferences<_$AppDatabase, $WeightEventsTable, WeightEvent>,
          ),
          WeightEvent,
          PrefetchHooks Function()
        > {
  $$WeightEventsTableTableManager(_$AppDatabase db, $WeightEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> timezoneOffsetMinutes = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<double> weightKilograms = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> supersedesEventId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEventsCompanion(
                ownerId: ownerId,
                eventId: eventId,
                occurredAtUtc: occurredAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAtUtc: createdAtUtc,
                weightKilograms: weightKilograms,
                note: note,
                supersedesEventId: supersedesEventId,
                revision: revision,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String eventId,
                required DateTime occurredAtUtc,
                required int timezoneOffsetMinutes,
                required DateTime createdAtUtc,
                required double weightKilograms,
                Value<String> note = const Value.absent(),
                Value<String?> supersedesEventId = const Value.absent(),
                required int revision,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEventsCompanion.insert(
                ownerId: ownerId,
                eventId: eventId,
                occurredAtUtc: occurredAtUtc,
                timezoneOffsetMinutes: timezoneOffsetMinutes,
                createdAtUtc: createdAtUtc,
                weightKilograms: weightKilograms,
                note: note,
                supersedesEventId: supersedesEventId,
                revision: revision,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeightEventsTable, WeightEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeightEventsTable,
                    WeightEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEventsTable,
      WeightEvent,
      $$WeightEventsTableFilterComposer,
      $$WeightEventsTableOrderingComposer,
      $$WeightEventsTableAnnotationComposer,
      $$WeightEventsTableCreateCompanionBuilder,
      $$WeightEventsTableUpdateCompanionBuilder,
      (
        WeightEvent,
        BaseReferences<_$AppDatabase, $WeightEventsTable, WeightEvent>,
      ),
      WeightEvent,
      PrefetchHooks Function()
    >;
typedef $$HydrationPreferencesTableCreateCompanionBuilder =
    HydrationPreferencesCompanion Function({
      required String ownerId,
      Value<int?> targetMilliliters,
      Value<String> targetSource,
      Value<String> restrictionNote,
      Value<bool> remindersEnabled,
      Value<int> reminderStartMinute,
      Value<int> reminderEndMinute,
      Value<int> reminderIntervalMinutes,
      required int revision,
      required DateTime updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$HydrationPreferencesTableUpdateCompanionBuilder =
    HydrationPreferencesCompanion Function({
      Value<String> ownerId,
      Value<int?> targetMilliliters,
      Value<String> targetSource,
      Value<String> restrictionNote,
      Value<bool> remindersEnabled,
      Value<int> reminderStartMinute,
      Value<int> reminderEndMinute,
      Value<int> reminderIntervalMinutes,
      Value<int> revision,
      Value<DateTime> updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$HydrationPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $HydrationPreferencesTable> {
  $$HydrationPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMilliliters => $composableBuilder(
    column: $table.targetMilliliters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetSource => $composableBuilder(
    column: $table.targetSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restrictionNote => $composableBuilder(
    column: $table.restrictionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderStartMinute => $composableBuilder(
    column: $table.reminderStartMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderEndMinute => $composableBuilder(
    column: $table.reminderEndMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderIntervalMinutes => $composableBuilder(
    column: $table.reminderIntervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HydrationPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $HydrationPreferencesTable> {
  $$HydrationPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMilliliters => $composableBuilder(
    column: $table.targetMilliliters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetSource => $composableBuilder(
    column: $table.targetSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restrictionNote => $composableBuilder(
    column: $table.restrictionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderStartMinute => $composableBuilder(
    column: $table.reminderStartMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderEndMinute => $composableBuilder(
    column: $table.reminderEndMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderIntervalMinutes => $composableBuilder(
    column: $table.reminderIntervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HydrationPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HydrationPreferencesTable> {
  $$HydrationPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get targetMilliliters => $composableBuilder(
    column: $table.targetMilliliters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetSource => $composableBuilder(
    column: $table.targetSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restrictionNote => $composableBuilder(
    column: $table.restrictionNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderStartMinute => $composableBuilder(
    column: $table.reminderStartMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderEndMinute => $composableBuilder(
    column: $table.reminderEndMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderIntervalMinutes => $composableBuilder(
    column: $table.reminderIntervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$HydrationPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HydrationPreferencesTable,
          HydrationPreference,
          $$HydrationPreferencesTableFilterComposer,
          $$HydrationPreferencesTableOrderingComposer,
          $$HydrationPreferencesTableAnnotationComposer,
          $$HydrationPreferencesTableCreateCompanionBuilder,
          $$HydrationPreferencesTableUpdateCompanionBuilder,
          (
            HydrationPreference,
            BaseReferences<
              _$AppDatabase,
              $HydrationPreferencesTable,
              HydrationPreference
            >,
          ),
          HydrationPreference,
          PrefetchHooks Function()
        > {
  $$HydrationPreferencesTableTableManager(
    _$AppDatabase db,
    $HydrationPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HydrationPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HydrationPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HydrationPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<int?> targetMilliliters = const Value.absent(),
                Value<String> targetSource = const Value.absent(),
                Value<String> restrictionNote = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int> reminderStartMinute = const Value.absent(),
                Value<int> reminderEndMinute = const Value.absent(),
                Value<int> reminderIntervalMinutes = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HydrationPreferencesCompanion(
                ownerId: ownerId,
                targetMilliliters: targetMilliliters,
                targetSource: targetSource,
                restrictionNote: restrictionNote,
                remindersEnabled: remindersEnabled,
                reminderStartMinute: reminderStartMinute,
                reminderEndMinute: reminderEndMinute,
                reminderIntervalMinutes: reminderIntervalMinutes,
                revision: revision,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<int?> targetMilliliters = const Value.absent(),
                Value<String> targetSource = const Value.absent(),
                Value<String> restrictionNote = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<int> reminderStartMinute = const Value.absent(),
                Value<int> reminderEndMinute = const Value.absent(),
                Value<int> reminderIntervalMinutes = const Value.absent(),
                required int revision,
                required DateTime updatedAtUtc,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HydrationPreferencesCompanion.insert(
                ownerId: ownerId,
                targetMilliliters: targetMilliliters,
                targetSource: targetSource,
                restrictionNote: restrictionNote,
                remindersEnabled: remindersEnabled,
                reminderStartMinute: reminderStartMinute,
                reminderEndMinute: reminderEndMinute,
                reminderIntervalMinutes: reminderIntervalMinutes,
                revision: revision,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HydrationPreferencesTable, HydrationPreference>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $HydrationPreferencesTable,
                    HydrationPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HydrationPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HydrationPreferencesTable,
      HydrationPreference,
      $$HydrationPreferencesTableFilterComposer,
      $$HydrationPreferencesTableOrderingComposer,
      $$HydrationPreferencesTableAnnotationComposer,
      $$HydrationPreferencesTableCreateCompanionBuilder,
      $$HydrationPreferencesTableUpdateCompanionBuilder,
      (
        HydrationPreference,
        BaseReferences<
          _$AppDatabase,
          $HydrationPreferencesTable,
          HydrationPreference
        >,
      ),
      HydrationPreference,
      PrefetchHooks Function()
    >;
typedef $$CustomFoodsTableCreateCompanionBuilder =
    CustomFoodsCompanion Function({
      required String ownerId,
      required String customFoodId,
      required String name,
      required String normalizedName,
      required String servingLabel,
      required String unitCode,
      Value<double?> gramsPerServing,
      required double caloriesKcal,
      required double proteinGrams,
      required double carbohydrateGrams,
      required double fatGrams,
      Value<double?> sodiumMilligrams,
      required int revision,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$CustomFoodsTableUpdateCompanionBuilder =
    CustomFoodsCompanion Function({
      Value<String> ownerId,
      Value<String> customFoodId,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> servingLabel,
      Value<String> unitCode,
      Value<double?> gramsPerServing,
      Value<double> caloriesKcal,
      Value<double> proteinGrams,
      Value<double> carbohydrateGrams,
      Value<double> fatGrams,
      Value<double?> sodiumMilligrams,
      Value<int> revision,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$CustomFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customFoodId => $composableBuilder(
    column: $table.customFoodId,
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

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsPerServing => $composableBuilder(
    column: $table.gramsPerServing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateGrams => $composableBuilder(
    column: $table.carbohydrateGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMilligrams => $composableBuilder(
    column: $table.sodiumMilligrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customFoodId => $composableBuilder(
    column: $table.customFoodId,
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

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsPerServing => $composableBuilder(
    column: $table.gramsPerServing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateGrams => $composableBuilder(
    column: $table.carbohydrateGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMilligrams => $composableBuilder(
    column: $table.sodiumMilligrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomFoodsTable> {
  $$CustomFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get customFoodId => $composableBuilder(
    column: $table.customFoodId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<double> get gramsPerServing => $composableBuilder(
    column: $table.gramsPerServing,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateGrams => $composableBuilder(
    column: $table.carbohydrateGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get sodiumMilligrams => $composableBuilder(
    column: $table.sodiumMilligrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CustomFoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomFoodsTable,
          CustomFood,
          $$CustomFoodsTableFilterComposer,
          $$CustomFoodsTableOrderingComposer,
          $$CustomFoodsTableAnnotationComposer,
          $$CustomFoodsTableCreateCompanionBuilder,
          $$CustomFoodsTableUpdateCompanionBuilder,
          (
            CustomFood,
            BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>,
          ),
          CustomFood,
          PrefetchHooks Function()
        > {
  $$CustomFoodsTableTableManager(_$AppDatabase db, $CustomFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> customFoodId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<double?> gramsPerServing = const Value.absent(),
                Value<double> caloriesKcal = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbohydrateGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double?> sodiumMilligrams = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFoodsCompanion(
                ownerId: ownerId,
                customFoodId: customFoodId,
                name: name,
                normalizedName: normalizedName,
                servingLabel: servingLabel,
                unitCode: unitCode,
                gramsPerServing: gramsPerServing,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbohydrateGrams: carbohydrateGrams,
                fatGrams: fatGrams,
                sodiumMilligrams: sodiumMilligrams,
                revision: revision,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String customFoodId,
                required String name,
                required String normalizedName,
                required String servingLabel,
                required String unitCode,
                Value<double?> gramsPerServing = const Value.absent(),
                required double caloriesKcal,
                required double proteinGrams,
                required double carbohydrateGrams,
                required double fatGrams,
                Value<double?> sodiumMilligrams = const Value.absent(),
                required int revision,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomFoodsCompanion.insert(
                ownerId: ownerId,
                customFoodId: customFoodId,
                name: name,
                normalizedName: normalizedName,
                servingLabel: servingLabel,
                unitCode: unitCode,
                gramsPerServing: gramsPerServing,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbohydrateGrams: carbohydrateGrams,
                fatGrams: fatGrams,
                sodiumMilligrams: sodiumMilligrams,
                revision: revision,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomFoodsTable, CustomFood>(table),
                  BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>(
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

typedef $$CustomFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomFoodsTable,
      CustomFood,
      $$CustomFoodsTableFilterComposer,
      $$CustomFoodsTableOrderingComposer,
      $$CustomFoodsTableAnnotationComposer,
      $$CustomFoodsTableCreateCompanionBuilder,
      $$CustomFoodsTableUpdateCompanionBuilder,
      (
        CustomFood,
        BaseReferences<_$AppDatabase, $CustomFoodsTable, CustomFood>,
      ),
      CustomFood,
      PrefetchHooks Function()
    >;
typedef $$FoodNotFoundNotesTableCreateCompanionBuilder =
    FoodNotFoundNotesCompanion Function({
      required String ownerId,
      required String noteId,
      required String searchText,
      required String normalizedSearchText,
      required String details,
      Value<String> status,
      required int revision,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$FoodNotFoundNotesTableUpdateCompanionBuilder =
    FoodNotFoundNotesCompanion Function({
      Value<String> ownerId,
      Value<String> noteId,
      Value<String> searchText,
      Value<String> normalizedSearchText,
      Value<String> details,
      Value<String> status,
      Value<int> revision,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$FoodNotFoundNotesTableFilterComposer
    extends Composer<_$AppDatabase, $FoodNotFoundNotesTable> {
  $$FoodNotFoundNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedSearchText => $composableBuilder(
    column: $table.normalizedSearchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodNotFoundNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodNotFoundNotesTable> {
  $$FoodNotFoundNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedSearchText => $composableBuilder(
    column: $table.normalizedSearchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodNotFoundNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodNotFoundNotesTable> {
  $$FoodNotFoundNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedSearchText => $composableBuilder(
    column: $table.normalizedSearchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$FoodNotFoundNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodNotFoundNotesTable,
          FoodNotFoundNote,
          $$FoodNotFoundNotesTableFilterComposer,
          $$FoodNotFoundNotesTableOrderingComposer,
          $$FoodNotFoundNotesTableAnnotationComposer,
          $$FoodNotFoundNotesTableCreateCompanionBuilder,
          $$FoodNotFoundNotesTableUpdateCompanionBuilder,
          (
            FoodNotFoundNote,
            BaseReferences<
              _$AppDatabase,
              $FoodNotFoundNotesTable,
              FoodNotFoundNote
            >,
          ),
          FoodNotFoundNote,
          PrefetchHooks Function()
        > {
  $$FoodNotFoundNotesTableTableManager(
    _$AppDatabase db,
    $FoodNotFoundNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodNotFoundNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodNotFoundNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodNotFoundNotesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String> normalizedSearchText = const Value.absent(),
                Value<String> details = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodNotFoundNotesCompanion(
                ownerId: ownerId,
                noteId: noteId,
                searchText: searchText,
                normalizedSearchText: normalizedSearchText,
                details: details,
                status: status,
                revision: revision,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String noteId,
                required String searchText,
                required String normalizedSearchText,
                required String details,
                Value<String> status = const Value.absent(),
                required int revision,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodNotFoundNotesCompanion.insert(
                ownerId: ownerId,
                noteId: noteId,
                searchText: searchText,
                normalizedSearchText: normalizedSearchText,
                details: details,
                status: status,
                revision: revision,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodNotFoundNotesTable, FoodNotFoundNote>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FoodNotFoundNotesTable,
                    FoodNotFoundNote
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodNotFoundNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodNotFoundNotesTable,
      FoodNotFoundNote,
      $$FoodNotFoundNotesTableFilterComposer,
      $$FoodNotFoundNotesTableOrderingComposer,
      $$FoodNotFoundNotesTableAnnotationComposer,
      $$FoodNotFoundNotesTableCreateCompanionBuilder,
      $$FoodNotFoundNotesTableUpdateCompanionBuilder,
      (
        FoodNotFoundNote,
        BaseReferences<
          _$AppDatabase,
          $FoodNotFoundNotesTable,
          FoodNotFoundNote
        >,
      ),
      FoodNotFoundNote,
      PrefetchHooks Function()
    >;
typedef $$CustomRecipesTableCreateCompanionBuilder =
    CustomRecipesCompanion Function({
      required String ownerId,
      required String customRecipeId,
      required String name,
      required String normalizedName,
      required double yieldServingsMinimum,
      required double yieldServingsMaximum,
      required String oilTreatment,
      required int revision,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$CustomRecipesTableUpdateCompanionBuilder =
    CustomRecipesCompanion Function({
      Value<String> ownerId,
      Value<String> customRecipeId,
      Value<String> name,
      Value<String> normalizedName,
      Value<double> yieldServingsMinimum,
      Value<double> yieldServingsMaximum,
      Value<String> oilTreatment,
      Value<int> revision,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$CustomRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomRecipesTable> {
  $$CustomRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customRecipeId => $composableBuilder(
    column: $table.customRecipeId,
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

  ColumnFilters<double> get yieldServingsMinimum => $composableBuilder(
    column: $table.yieldServingsMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yieldServingsMaximum => $composableBuilder(
    column: $table.yieldServingsMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oilTreatment => $composableBuilder(
    column: $table.oilTreatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomRecipesTable> {
  $$CustomRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customRecipeId => $composableBuilder(
    column: $table.customRecipeId,
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

  ColumnOrderings<double> get yieldServingsMinimum => $composableBuilder(
    column: $table.yieldServingsMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yieldServingsMaximum => $composableBuilder(
    column: $table.yieldServingsMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oilTreatment => $composableBuilder(
    column: $table.oilTreatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomRecipesTable> {
  $$CustomRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get customRecipeId => $composableBuilder(
    column: $table.customRecipeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yieldServingsMinimum => $composableBuilder(
    column: $table.yieldServingsMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yieldServingsMaximum => $composableBuilder(
    column: $table.yieldServingsMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oilTreatment => $composableBuilder(
    column: $table.oilTreatment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$CustomRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomRecipesTable,
          CustomRecipe,
          $$CustomRecipesTableFilterComposer,
          $$CustomRecipesTableOrderingComposer,
          $$CustomRecipesTableAnnotationComposer,
          $$CustomRecipesTableCreateCompanionBuilder,
          $$CustomRecipesTableUpdateCompanionBuilder,
          (
            CustomRecipe,
            BaseReferences<_$AppDatabase, $CustomRecipesTable, CustomRecipe>,
          ),
          CustomRecipe,
          PrefetchHooks Function()
        > {
  $$CustomRecipesTableTableManager(_$AppDatabase db, $CustomRecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> customRecipeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<double> yieldServingsMinimum = const Value.absent(),
                Value<double> yieldServingsMaximum = const Value.absent(),
                Value<String> oilTreatment = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomRecipesCompanion(
                ownerId: ownerId,
                customRecipeId: customRecipeId,
                name: name,
                normalizedName: normalizedName,
                yieldServingsMinimum: yieldServingsMinimum,
                yieldServingsMaximum: yieldServingsMaximum,
                oilTreatment: oilTreatment,
                revision: revision,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String customRecipeId,
                required String name,
                required String normalizedName,
                required double yieldServingsMinimum,
                required double yieldServingsMaximum,
                required String oilTreatment,
                required int revision,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomRecipesCompanion.insert(
                ownerId: ownerId,
                customRecipeId: customRecipeId,
                name: name,
                normalizedName: normalizedName,
                yieldServingsMinimum: yieldServingsMinimum,
                yieldServingsMaximum: yieldServingsMaximum,
                oilTreatment: oilTreatment,
                revision: revision,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomRecipesTable, CustomRecipe>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomRecipesTable,
                    CustomRecipe
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomRecipesTable,
      CustomRecipe,
      $$CustomRecipesTableFilterComposer,
      $$CustomRecipesTableOrderingComposer,
      $$CustomRecipesTableAnnotationComposer,
      $$CustomRecipesTableCreateCompanionBuilder,
      $$CustomRecipesTableUpdateCompanionBuilder,
      (
        CustomRecipe,
        BaseReferences<_$AppDatabase, $CustomRecipesTable, CustomRecipe>,
      ),
      CustomRecipe,
      PrefetchHooks Function()
    >;
typedef $$CustomRecipeIngredientsTableCreateCompanionBuilder =
    CustomRecipeIngredientsCompanion Function({
      required String ownerId,
      required String customRecipeId,
      required int ingredientIndex,
      required String catalogItemType,
      required String catalogReleaseId,
      required String itemId,
      required String sourceId,
      required String sourceVersion,
      required String sourceRecordId,
      required String servingId,
      required String servingLabel,
      required String unitCode,
      required double quantity,
      required double gramsMinimum,
      required double gramsMaximum,
      required String weightBasis,
      required double servingConfidence,
      required double caloriesMinimum,
      required double caloriesMaximum,
      required double proteinMinimum,
      required double proteinMaximum,
      required double carbohydrateMinimum,
      required double carbohydrateMaximum,
      required double fatMinimum,
      required double fatMaximum,
      Value<double?> sodiumMinimum,
      Value<double?> sodiumMaximum,
      required String oilInclusion,
      required String calculationVersion,
      Value<int> rowid,
    });
typedef $$CustomRecipeIngredientsTableUpdateCompanionBuilder =
    CustomRecipeIngredientsCompanion Function({
      Value<String> ownerId,
      Value<String> customRecipeId,
      Value<int> ingredientIndex,
      Value<String> catalogItemType,
      Value<String> catalogReleaseId,
      Value<String> itemId,
      Value<String> sourceId,
      Value<String> sourceVersion,
      Value<String> sourceRecordId,
      Value<String> servingId,
      Value<String> servingLabel,
      Value<String> unitCode,
      Value<double> quantity,
      Value<double> gramsMinimum,
      Value<double> gramsMaximum,
      Value<String> weightBasis,
      Value<double> servingConfidence,
      Value<double> caloriesMinimum,
      Value<double> caloriesMaximum,
      Value<double> proteinMinimum,
      Value<double> proteinMaximum,
      Value<double> carbohydrateMinimum,
      Value<double> carbohydrateMaximum,
      Value<double> fatMinimum,
      Value<double> fatMaximum,
      Value<double?> sodiumMinimum,
      Value<double?> sodiumMaximum,
      Value<String> oilInclusion,
      Value<String> calculationVersion,
      Value<int> rowid,
    });

class $$CustomRecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomRecipeIngredientsTable> {
  $$CustomRecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customRecipeId => $composableBuilder(
    column: $table.customRecipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ingredientIndex => $composableBuilder(
    column: $table.ingredientIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogItemType => $composableBuilder(
    column: $table.catalogItemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogReleaseId => $composableBuilder(
    column: $table.catalogReleaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightBasis => $composableBuilder(
    column: $table.weightBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingConfidence => $composableBuilder(
    column: $table.servingConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomRecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomRecipeIngredientsTable> {
  $$CustomRecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customRecipeId => $composableBuilder(
    column: $table.customRecipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ingredientIndex => $composableBuilder(
    column: $table.ingredientIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogItemType => $composableBuilder(
    column: $table.catalogItemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogReleaseId => $composableBuilder(
    column: $table.catalogReleaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightBasis => $composableBuilder(
    column: $table.weightBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingConfidence => $composableBuilder(
    column: $table.servingConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomRecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomRecipeIngredientsTable> {
  $$CustomRecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get customRecipeId => $composableBuilder(
    column: $table.customRecipeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ingredientIndex => $composableBuilder(
    column: $table.ingredientIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogItemType => $composableBuilder(
    column: $table.catalogItemType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogReleaseId => $composableBuilder(
    column: $table.catalogReleaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceRecordId => $composableBuilder(
    column: $table.sourceRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingId =>
      $composableBuilder(column: $table.servingId, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
    column: $table.servingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get gramsMinimum => $composableBuilder(
    column: $table.gramsMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gramsMaximum => $composableBuilder(
    column: $table.gramsMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightBasis => $composableBuilder(
    column: $table.weightBasis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingConfidence => $composableBuilder(
    column: $table.servingConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesMinimum => $composableBuilder(
    column: $table.caloriesMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesMaximum => $composableBuilder(
    column: $table.caloriesMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinMinimum => $composableBuilder(
    column: $table.proteinMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinMaximum => $composableBuilder(
    column: $table.proteinMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateMinimum => $composableBuilder(
    column: $table.carbohydrateMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbohydrateMaximum => $composableBuilder(
    column: $table.carbohydrateMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatMinimum => $composableBuilder(
    column: $table.fatMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatMaximum => $composableBuilder(
    column: $table.fatMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMinimum => $composableBuilder(
    column: $table.sodiumMinimum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMaximum => $composableBuilder(
    column: $table.sodiumMaximum,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oilInclusion => $composableBuilder(
    column: $table.oilInclusion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculationVersion => $composableBuilder(
    column: $table.calculationVersion,
    builder: (column) => column,
  );
}

class $$CustomRecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomRecipeIngredientsTable,
          CustomRecipeIngredient,
          $$CustomRecipeIngredientsTableFilterComposer,
          $$CustomRecipeIngredientsTableOrderingComposer,
          $$CustomRecipeIngredientsTableAnnotationComposer,
          $$CustomRecipeIngredientsTableCreateCompanionBuilder,
          $$CustomRecipeIngredientsTableUpdateCompanionBuilder,
          (
            CustomRecipeIngredient,
            BaseReferences<
              _$AppDatabase,
              $CustomRecipeIngredientsTable,
              CustomRecipeIngredient
            >,
          ),
          CustomRecipeIngredient,
          PrefetchHooks Function()
        > {
  $$CustomRecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $CustomRecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomRecipeIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomRecipeIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomRecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> customRecipeId = const Value.absent(),
                Value<int> ingredientIndex = const Value.absent(),
                Value<String> catalogItemType = const Value.absent(),
                Value<String> catalogReleaseId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceVersion = const Value.absent(),
                Value<String> sourceRecordId = const Value.absent(),
                Value<String> servingId = const Value.absent(),
                Value<String> servingLabel = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> gramsMinimum = const Value.absent(),
                Value<double> gramsMaximum = const Value.absent(),
                Value<String> weightBasis = const Value.absent(),
                Value<double> servingConfidence = const Value.absent(),
                Value<double> caloriesMinimum = const Value.absent(),
                Value<double> caloriesMaximum = const Value.absent(),
                Value<double> proteinMinimum = const Value.absent(),
                Value<double> proteinMaximum = const Value.absent(),
                Value<double> carbohydrateMinimum = const Value.absent(),
                Value<double> carbohydrateMaximum = const Value.absent(),
                Value<double> fatMinimum = const Value.absent(),
                Value<double> fatMaximum = const Value.absent(),
                Value<double?> sodiumMinimum = const Value.absent(),
                Value<double?> sodiumMaximum = const Value.absent(),
                Value<String> oilInclusion = const Value.absent(),
                Value<String> calculationVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomRecipeIngredientsCompanion(
                ownerId: ownerId,
                customRecipeId: customRecipeId,
                ingredientIndex: ingredientIndex,
                catalogItemType: catalogItemType,
                catalogReleaseId: catalogReleaseId,
                itemId: itemId,
                sourceId: sourceId,
                sourceVersion: sourceVersion,
                sourceRecordId: sourceRecordId,
                servingId: servingId,
                servingLabel: servingLabel,
                unitCode: unitCode,
                quantity: quantity,
                gramsMinimum: gramsMinimum,
                gramsMaximum: gramsMaximum,
                weightBasis: weightBasis,
                servingConfidence: servingConfidence,
                caloriesMinimum: caloriesMinimum,
                caloriesMaximum: caloriesMaximum,
                proteinMinimum: proteinMinimum,
                proteinMaximum: proteinMaximum,
                carbohydrateMinimum: carbohydrateMinimum,
                carbohydrateMaximum: carbohydrateMaximum,
                fatMinimum: fatMinimum,
                fatMaximum: fatMaximum,
                sodiumMinimum: sodiumMinimum,
                sodiumMaximum: sodiumMaximum,
                oilInclusion: oilInclusion,
                calculationVersion: calculationVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String customRecipeId,
                required int ingredientIndex,
                required String catalogItemType,
                required String catalogReleaseId,
                required String itemId,
                required String sourceId,
                required String sourceVersion,
                required String sourceRecordId,
                required String servingId,
                required String servingLabel,
                required String unitCode,
                required double quantity,
                required double gramsMinimum,
                required double gramsMaximum,
                required String weightBasis,
                required double servingConfidence,
                required double caloriesMinimum,
                required double caloriesMaximum,
                required double proteinMinimum,
                required double proteinMaximum,
                required double carbohydrateMinimum,
                required double carbohydrateMaximum,
                required double fatMinimum,
                required double fatMaximum,
                Value<double?> sodiumMinimum = const Value.absent(),
                Value<double?> sodiumMaximum = const Value.absent(),
                required String oilInclusion,
                required String calculationVersion,
                Value<int> rowid = const Value.absent(),
              }) => CustomRecipeIngredientsCompanion.insert(
                ownerId: ownerId,
                customRecipeId: customRecipeId,
                ingredientIndex: ingredientIndex,
                catalogItemType: catalogItemType,
                catalogReleaseId: catalogReleaseId,
                itemId: itemId,
                sourceId: sourceId,
                sourceVersion: sourceVersion,
                sourceRecordId: sourceRecordId,
                servingId: servingId,
                servingLabel: servingLabel,
                unitCode: unitCode,
                quantity: quantity,
                gramsMinimum: gramsMinimum,
                gramsMaximum: gramsMaximum,
                weightBasis: weightBasis,
                servingConfidence: servingConfidence,
                caloriesMinimum: caloriesMinimum,
                caloriesMaximum: caloriesMaximum,
                proteinMinimum: proteinMinimum,
                proteinMaximum: proteinMaximum,
                carbohydrateMinimum: carbohydrateMinimum,
                carbohydrateMaximum: carbohydrateMaximum,
                fatMinimum: fatMinimum,
                fatMaximum: fatMaximum,
                sodiumMinimum: sodiumMinimum,
                sodiumMaximum: sodiumMaximum,
                oilInclusion: oilInclusion,
                calculationVersion: calculationVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CustomRecipeIngredientsTable,
                    CustomRecipeIngredient
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomRecipeIngredientsTable,
                    CustomRecipeIngredient
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomRecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomRecipeIngredientsTable,
      CustomRecipeIngredient,
      $$CustomRecipeIngredientsTableFilterComposer,
      $$CustomRecipeIngredientsTableOrderingComposer,
      $$CustomRecipeIngredientsTableAnnotationComposer,
      $$CustomRecipeIngredientsTableCreateCompanionBuilder,
      $$CustomRecipeIngredientsTableUpdateCompanionBuilder,
      (
        CustomRecipeIngredient,
        BaseReferences<
          _$AppDatabase,
          $CustomRecipeIngredientsTable,
          CustomRecipeIngredient
        >,
      ),
      CustomRecipeIngredient,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalRecordsTableTableManager get localRecords =>
      $$LocalRecordsTableTableManager(_db, _db.localRecords);
  $$SyncOutboxEntriesTableTableManager get syncOutboxEntries =>
      $$SyncOutboxEntriesTableTableManager(_db, _db.syncOutboxEntries);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$CatalogReleasesTableTableManager get catalogReleases =>
      $$CatalogReleasesTableTableManager(_db, _db.catalogReleases);
  $$NutritionSourcesTableTableManager get nutritionSources =>
      $$NutritionSourcesTableTableManager(_db, _db.nutritionSources);
  $$CatalogFoodsTableTableManager get catalogFoods =>
      $$CatalogFoodsTableTableManager(_db, _db.catalogFoods);
  $$CatalogFoodSynonymsTableTableManager get catalogFoodSynonyms =>
      $$CatalogFoodSynonymsTableTableManager(_db, _db.catalogFoodSynonyms);
  $$CatalogServingDefinitionsTableTableManager get catalogServingDefinitions =>
      $$CatalogServingDefinitionsTableTableManager(
        _db,
        _db.catalogServingDefinitions,
      );
  $$CatalogRecipesTableTableManager get catalogRecipes =>
      $$CatalogRecipesTableTableManager(_db, _db.catalogRecipes);
  $$CatalogRecipeSynonymsTableTableManager get catalogRecipeSynonyms =>
      $$CatalogRecipeSynonymsTableTableManager(_db, _db.catalogRecipeSynonyms);
  $$CatalogRecipeIngredientsTableTableManager get catalogRecipeIngredients =>
      $$CatalogRecipeIngredientsTableTableManager(
        _db,
        _db.catalogRecipeIngredients,
      );
  $$MealEventsTableTableManager get mealEvents =>
      $$MealEventsTableTableManager(_db, _db.mealEvents);
  $$MealItemsTableTableManager get mealItems =>
      $$MealItemsTableTableManager(_db, _db.mealItems);
  $$WaterEventsTableTableManager get waterEvents =>
      $$WaterEventsTableTableManager(_db, _db.waterEvents);
  $$WeightEventsTableTableManager get weightEvents =>
      $$WeightEventsTableTableManager(_db, _db.weightEvents);
  $$HydrationPreferencesTableTableManager get hydrationPreferences =>
      $$HydrationPreferencesTableTableManager(_db, _db.hydrationPreferences);
  $$CustomFoodsTableTableManager get customFoods =>
      $$CustomFoodsTableTableManager(_db, _db.customFoods);
  $$FoodNotFoundNotesTableTableManager get foodNotFoundNotes =>
      $$FoodNotFoundNotesTableTableManager(_db, _db.foodNotFoundNotes);
  $$CustomRecipesTableTableManager get customRecipes =>
      $$CustomRecipesTableTableManager(_db, _db.customRecipes);
  $$CustomRecipeIngredientsTableTableManager get customRecipeIngredients =>
      $$CustomRecipeIngredientsTableTableManager(
        _db,
        _db.customRecipeIngredients,
      );
}
