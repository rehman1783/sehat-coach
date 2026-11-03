import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/user_food_records.dart' as domain;

class DriftUserFoodRecordRepository implements domain.UserFoodRecordRepository {
  factory DriftUserFoodRecordRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftUserFoodRecordRepository._(database, expectedOwnerId);

  const DriftUserFoodRecordRepository._(this._database, this._expectedOwnerId);

  static const customFoodEntityType = 'custom_food';
  static const notFoundEntityType = 'food_not_found';
  static const payloadSchemaVersion = 1;

  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Future<void> saveCustomFood(domain.CustomFoodRecord record) async {
    _verifyOwner(record.ownerId);
    final payload = <String, Object?>{
      'schemaVersion': payloadSchemaVersion,
      'id': record.id,
      'ownerId': record.ownerId,
      'name': record.name,
      'servingLabel': record.servingLabel,
      'unitCode': record.unitCode,
      'gramsPerServing': record.gramsPerServing,
      'caloriesKcal': record.caloriesKcal,
      'proteinGrams': record.proteinGrams,
      'carbohydrateGrams': record.carbohydrateGrams,
      'fatGrams': record.fatGrams,
      'sodiumMilligrams': record.sodiumMilligrams,
      'revision': record.revision,
      'createdAtUtc': record.createdAtUtc.toIso8601String(),
      'updatedAtUtc': record.updatedAtUtc.toIso8601String(),
      'origin': 'user_entered_unreviewed',
    };
    await _database.transaction(() async {
      await _database
          .into(_database.customFoods)
          .insert(
            db.CustomFoodsCompanion.insert(
              ownerId: record.ownerId,
              customFoodId: record.id,
              name: record.name,
              normalizedName: _normalize(record.name),
              servingLabel: record.servingLabel,
              unitCode: record.unitCode,
              gramsPerServing: Value.absentIfNull(record.gramsPerServing),
              caloriesKcal: record.caloriesKcal,
              proteinGrams: record.proteinGrams,
              carbohydrateGrams: record.carbohydrateGrams,
              fatGrams: record.fatGrams,
              sodiumMilligrams: Value.absentIfNull(record.sodiumMilligrams),
              revision: record.revision,
              createdAtUtc: record.createdAtUtc,
              updatedAtUtc: record.updatedAtUtc,
            ),
          );
      await _stage(
        ownerId: record.ownerId,
        entityType: customFoodEntityType,
        entityKey: record.id,
        revision: record.revision,
        payload: payload,
        createdAt: record.createdAtUtc,
        updatedAt: record.updatedAtUtc,
      );
    });
  }

  @override
  Future<void> saveNotFound(domain.FoodNotFoundRecord record) async {
    _verifyOwner(record.ownerId);
    final payload = <String, Object?>{
      'schemaVersion': payloadSchemaVersion,
      'id': record.id,
      'ownerId': record.ownerId,
      'searchText': record.searchText,
      'details': record.details,
      'status': record.status.name,
      'revision': record.revision,
      'createdAtUtc': record.createdAtUtc.toIso8601String(),
      'updatedAtUtc': record.updatedAtUtc.toIso8601String(),
    };
    await _database.transaction(() async {
      await _database
          .into(_database.foodNotFoundNotes)
          .insert(
            db.FoodNotFoundNotesCompanion.insert(
              ownerId: record.ownerId,
              noteId: record.id,
              searchText: record.searchText,
              normalizedSearchText: _normalize(record.searchText),
              details: record.details,
              status: Value(record.status.name),
              revision: record.revision,
              createdAtUtc: record.createdAtUtc,
              updatedAtUtc: record.updatedAtUtc,
            ),
          );
      await _stage(
        ownerId: record.ownerId,
        entityType: notFoundEntityType,
        entityKey: record.id,
        revision: record.revision,
        payload: payload,
        createdAt: record.createdAtUtc,
        updatedAt: record.updatedAtUtc,
      );
    });
  }

  @override
  Future<List<domain.CustomFoodRecord>> searchCustomFoods(String query) async {
    final normalized = _normalize(query);
    if (normalized.isEmpty) throw ArgumentError('Search text is required');
    final prefix = '${_escapeLike(normalized)}%';
    final rows =
        await (_database.select(_database.customFoods)
              ..where(
                (row) =>
                    row.ownerId.equals(_expectedOwnerId) &
                    row.isDeleted.equals(false) &
                    row.normalizedName.like(prefix, escapeChar: r'\'),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.normalizedName)])
              ..limit(50))
            .get();
    return rows.map(_mapCustomFood).toList(growable: false);
  }

  @override
  Future<List<domain.FoodNotFoundRecord>> pendingNotFound() async {
    final rows =
        await (_database.select(_database.foodNotFoundNotes)
              ..where(
                (row) =>
                    row.ownerId.equals(_expectedOwnerId) &
                    row.isDeleted.equals(false) &
                    row.status.equals(domain.FoodNotFoundStatus.pending.name),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAtUtc)]))
            .get();
    return rows.map(_mapNotFound).toList(growable: false);
  }

  Future<void> _stage({
    required String ownerId,
    required String entityType,
    required String entityKey,
    required int revision,
    required Map<String, Object?> payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    final payloadJson = jsonEncode(payload);
    await _database
        .into(_database.localRecords)
        .insert(
          db.LocalRecordsCompanion.insert(
            ownerId: ownerId,
            entityType: entityType,
            entityKey: entityKey,
            schemaVersion: payloadSchemaVersion,
            revision: revision,
            payloadJson: payloadJson,
            createdAtClient: createdAt,
            updatedAtClient: updatedAt,
          ),
        );
    await _database
        .into(_database.syncOutboxEntries)
        .insert(
          db.SyncOutboxEntriesCompanion.insert(
            ownerId: ownerId,
            operationId: '$entityType:$entityKey:r$revision',
            entityType: entityType,
            entityKey: entityKey,
            operationType: 'upsert',
            baseRevision: revision - 1,
            newRevision: revision,
            payloadJson: payloadJson,
            createdAtClient: updatedAt,
          ),
        );
  }

  domain.CustomFoodRecord _mapCustomFood(db.CustomFood row) =>
      domain.CustomFoodRecord(
        id: row.customFoodId,
        ownerId: row.ownerId,
        name: row.name,
        servingLabel: row.servingLabel,
        unitCode: row.unitCode,
        gramsPerServing: row.gramsPerServing,
        caloriesKcal: row.caloriesKcal,
        proteinGrams: row.proteinGrams,
        carbohydrateGrams: row.carbohydrateGrams,
        fatGrams: row.fatGrams,
        sodiumMilligrams: row.sodiumMilligrams,
        revision: row.revision,
        createdAtUtc: row.createdAtUtc.toUtc(),
        updatedAtUtc: row.updatedAtUtc.toUtc(),
      );

  domain.FoodNotFoundRecord _mapNotFound(db.FoodNotFoundNote row) =>
      domain.FoodNotFoundRecord(
        id: row.noteId,
        ownerId: row.ownerId,
        searchText: row.searchText,
        details: row.details,
        status: domain.FoodNotFoundStatus.values.byName(row.status),
        revision: row.revision,
        createdAtUtc: row.createdAtUtc.toUtc(),
        updatedAtUtc: row.updatedAtUtc.toUtc(),
      );

  void _verifyOwner(String ownerId) {
    if (ownerId != _expectedOwnerId) {
      throw StateError('User food owner does not match the active account');
    }
  }
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
