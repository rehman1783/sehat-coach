import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../../catalog/domain/catalog_food.dart' show OilInclusion;
import '../domain/meal_event.dart' as domain;
import '../domain/nutrition_calculator.dart';

/// Persists the typed meal projection and its generic sync record together.
/// A failure in any write rolls back the complete operation.
class DriftMealEventRepository
    implements
        domain.MealEventRepository,
        domain.ActiveMealRevisionReader,
        domain.ActiveMealDraftReader {
  factory DriftMealEventRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftMealEventRepository._(
    database: database,
    expectedOwnerId: expectedOwnerId,
  );

  DriftMealEventRepository._({
    required this._database,
    required this._expectedOwnerId,
  });

  static const entityType = 'meal_event';
  static const payloadSchemaVersion = 2;

  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Future<int?> readActiveRevision({
    required String ownerId,
    required String eventId,
  }) async {
    if (ownerId != _expectedOwnerId || eventId.trim().isEmpty) {
      throw StateError('Meal correction owner or event is invalid');
    }
    final original =
        await (_database.select(_database.mealEvents)..where(
              (row) =>
                  row.ownerId.equals(ownerId) & row.eventId.equals(eventId),
            ))
            .getSingleOrNull();
    if (original == null || original.isDeleted) return null;
    final correction =
        await (_database.select(_database.mealEvents)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.supersedesEventId.equals(eventId) &
                  row.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return correction == null ? original.revision : null;
  }

  @override
  Future<domain.MealCorrectionDraft?> readActiveDraft({
    required String ownerId,
    required String eventId,
  }) async {
    final revision = await readActiveRevision(
      ownerId: ownerId,
      eventId: eventId,
    );
    if (revision == null) return null;
    final event =
        await (_database.select(_database.mealEvents)..where(
              (row) =>
                  row.ownerId.equals(ownerId) & row.eventId.equals(eventId),
            ))
            .getSingle();
    final items =
        await (_database.select(_database.mealItems)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.eventId.equals(eventId),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.itemIndex)]))
            .get();
    if (items.isEmpty) return null;
    return domain.MealCorrectionDraft(
      originalEventId: event.eventId,
      mealType: domain.MealType.values.byName(event.mealType),
      occurredAtUtc: event.occurredAtUtc.toUtc(),
      timezoneOffsetMinutes: event.timezoneOffsetMinutes,
      rawUserInput: event.rawUserInput,
      calculation: MealCalculationSnapshot(
        items: items.map(_mapItem).toList(growable: false),
        total: _mapNutrition(
          caloriesMinimum: event.caloriesMinimum,
          caloriesMaximum: event.caloriesMaximum,
          proteinMinimum: event.proteinMinimum,
          proteinMaximum: event.proteinMaximum,
          carbohydrateMinimum: event.carbohydrateMinimum,
          carbohydrateMaximum: event.carbohydrateMaximum,
          fatMinimum: event.fatMinimum,
          fatMaximum: event.fatMaximum,
          sodiumMinimum: event.sodiumMinimum,
          sodiumMaximum: event.sodiumMaximum,
        ),
      ),
    );
  }

  MealItemCalculationSnapshot _mapItem(db.MealItem item) =>
      MealItemCalculationSnapshot(
        calculationVersion: item.calculationVersion,
        catalogReleaseId: item.catalogReleaseId,
        foodId: item.foodId,
        sourceId: item.sourceId,
        sourceVersion: item.sourceVersion,
        sourceRecordId: item.sourceRecordId,
        servingId: item.servingId,
        servingLabel: item.servingLabel,
        unitCode: item.unitCode,
        quantity: item.quantity,
        grams: ValueRange(item.gramsMinimum, item.gramsMaximum),
        servingConfidence: item.servingConfidence,
        nutrition: _mapNutrition(
          caloriesMinimum: item.caloriesMinimum,
          caloriesMaximum: item.caloriesMaximum,
          proteinMinimum: item.proteinMinimum,
          proteinMaximum: item.proteinMaximum,
          carbohydrateMinimum: item.carbohydrateMinimum,
          carbohydrateMaximum: item.carbohydrateMaximum,
          fatMinimum: item.fatMinimum,
          fatMaximum: item.fatMaximum,
          sodiumMinimum: item.sodiumMinimum,
          sodiumMaximum: item.sodiumMaximum,
        ),
        oilInclusion: OilInclusion.values.byName(item.oilInclusion),
        catalogItemType: CatalogItemType.values.byName(item.catalogItemType),
        weightBasis: WeightBasis.values.byName(item.weightBasis),
      );

  NutritionRangeSnapshot _mapNutrition({
    required double caloriesMinimum,
    required double caloriesMaximum,
    required double proteinMinimum,
    required double proteinMaximum,
    required double carbohydrateMinimum,
    required double carbohydrateMaximum,
    required double fatMinimum,
    required double fatMaximum,
    required double? sodiumMinimum,
    required double? sodiumMaximum,
  }) => NutritionRangeSnapshot(
    caloriesKcal: ValueRange(caloriesMinimum, caloriesMaximum),
    proteinGrams: ValueRange(proteinMinimum, proteinMaximum),
    carbohydrateGrams: ValueRange(carbohydrateMinimum, carbohydrateMaximum),
    fatGrams: ValueRange(fatMinimum, fatMaximum),
    sodiumMilligrams: sodiumMinimum == null || sodiumMaximum == null
        ? null
        : ValueRange(sodiumMinimum, sodiumMaximum),
  );

  @override
  Future<void> save(domain.MealEvent event) async {
    if (event.ownerId != _expectedOwnerId) {
      throw StateError('Meal owner does not match the active account');
    }
    if (event.calculation.items.isEmpty) {
      throw ArgumentError('Meal calculation must contain at least one item');
    }
    if (event.supersedesEventId == null && event.revision != 1) {
      throw ArgumentError('An initial meal event must use revision 1');
    }
    if (event.supersedesEventId != null && event.revision < 2) {
      throw ArgumentError('A correction must use revision 2 or later');
    }

    final calculationVersions = event.calculation.items
        .map((item) => item.calculationVersion)
        .toSet();
    final calculationVersion = calculationVersions.length == 1
        ? calculationVersions.single
        : 'mixed-item-calculations-v1';

    final payloadJson = jsonEncode(_payload(event));
    final total = event.calculation.total;
    final operationId = 'meal:${event.id}:r${event.revision}';

    await _database.transaction(() async {
      if (event.supersedesEventId case final originalId?) {
        final original =
            await (_database.select(_database.mealEvents)..where(
                  (row) =>
                      row.ownerId.equals(event.ownerId) &
                      row.eventId.equals(originalId),
                ))
                .getSingleOrNull();
        if (original == null ||
            original.isDeleted ||
            original.revision + 1 != event.revision) {
          throw const domain.MealCorrectionUnavailable();
        }
        final existingCorrection =
            await (_database.select(_database.mealEvents)..where(
                  (row) =>
                      row.ownerId.equals(event.ownerId) &
                      row.supersedesEventId.equals(originalId) &
                      row.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (existingCorrection != null) {
          throw const domain.MealCorrectionUnavailable();
        }
      }
      await _database
          .into(_database.mealEvents)
          .insert(
            db.MealEventsCompanion.insert(
              ownerId: event.ownerId,
              eventId: event.id,
              mealType: event.mealType.name,
              occurredAtUtc: event.occurredAtUtc,
              timezoneOffsetMinutes: event.timezoneOffsetMinutes,
              createdAtUtc: event.createdAtUtc,
              rawUserInput: event.rawUserInput,
              aiProvenanceJson: Value.absentIfNull(
                event.aiProvenance == null
                    ? null
                    : jsonEncode(_aiProvenancePayload(event.aiProvenance!)),
              ),
              supersedesEventId: Value.absentIfNull(event.supersedesEventId),
              revision: event.revision,
              calculationVersion: calculationVersion,
              caloriesMinimum: total.caloriesKcal.minimum,
              caloriesMaximum: total.caloriesKcal.maximum,
              proteinMinimum: total.proteinGrams.minimum,
              proteinMaximum: total.proteinGrams.maximum,
              carbohydrateMinimum: total.carbohydrateGrams.minimum,
              carbohydrateMaximum: total.carbohydrateGrams.maximum,
              fatMinimum: total.fatGrams.minimum,
              fatMaximum: total.fatGrams.maximum,
              sodiumMinimum: Value.absentIfNull(
                total.sodiumMilligrams?.minimum,
              ),
              sodiumMaximum: Value.absentIfNull(
                total.sodiumMilligrams?.maximum,
              ),
            ),
          );

      for (final indexed in event.calculation.items.indexed) {
        final (index, item) = indexed;
        await _database
            .into(_database.mealItems)
            .insert(
              db.MealItemsCompanion.insert(
                ownerId: event.ownerId,
                eventId: event.id,
                itemIndex: index,
                catalogItemType: Value(item.catalogItemType.name),
                weightBasis: Value(item.weightBasis.name),
                catalogReleaseId: item.catalogReleaseId,
                foodId: item.foodId,
                sourceId: item.sourceId,
                sourceVersion: item.sourceVersion,
                sourceRecordId: item.sourceRecordId,
                servingId: item.servingId,
                servingLabel: item.servingLabel,
                unitCode: item.unitCode,
                quantity: item.quantity,
                gramsMinimum: item.grams.minimum,
                gramsMaximum: item.grams.maximum,
                servingConfidence: item.servingConfidence,
                caloriesMinimum: item.nutrition.caloriesKcal.minimum,
                caloriesMaximum: item.nutrition.caloriesKcal.maximum,
                proteinMinimum: item.nutrition.proteinGrams.minimum,
                proteinMaximum: item.nutrition.proteinGrams.maximum,
                carbohydrateMinimum: item.nutrition.carbohydrateGrams.minimum,
                carbohydrateMaximum: item.nutrition.carbohydrateGrams.maximum,
                fatMinimum: item.nutrition.fatGrams.minimum,
                fatMaximum: item.nutrition.fatGrams.maximum,
                sodiumMinimum: Value.absentIfNull(
                  item.nutrition.sodiumMilligrams?.minimum,
                ),
                sodiumMaximum: Value.absentIfNull(
                  item.nutrition.sodiumMilligrams?.maximum,
                ),
                oilInclusion: item.oilInclusion.name,
                calculationVersion: item.calculationVersion,
              ),
            );
      }

      await _database
          .into(_database.localRecords)
          .insert(
            db.LocalRecordsCompanion.insert(
              ownerId: event.ownerId,
              entityType: entityType,
              entityKey: event.id,
              schemaVersion: payloadSchemaVersion,
              revision: event.revision,
              payloadJson: payloadJson,
              createdAtClient: event.createdAtUtc,
              updatedAtClient: event.createdAtUtc,
            ),
          );
      await _database
          .into(_database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: event.ownerId,
              operationId: operationId,
              entityType: entityType,
              entityKey: event.id,
              operationType: 'upsert',
              baseRevision: event.revision - 1,
              newRevision: event.revision,
              payloadJson: payloadJson,
              createdAtClient: event.createdAtUtc,
            ),
          );
    });
  }

  Map<String, Object?> _payload(domain.MealEvent event) => {
    'schemaVersion': payloadSchemaVersion,
    'id': event.id,
    'ownerId': event.ownerId,
    'mealType': event.mealType.name,
    'occurredAtUtc': event.occurredAtUtc.toIso8601String(),
    'timezoneOffsetMinutes': event.timezoneOffsetMinutes,
    'createdAtUtc': event.createdAtUtc.toIso8601String(),
    'rawUserInput': event.rawUserInput,
    'supersedesEventId': event.supersedesEventId,
    'revision': event.revision,
    'aiProvenance': event.aiProvenance == null
        ? null
        : _aiProvenancePayload(event.aiProvenance!),
    'calculation': {
      'items': event.calculation.items
          .map(_itemPayload)
          .toList(growable: false),
      'total': _nutritionPayload(event.calculation.total),
    },
  };

  Map<String, Object?> _aiProvenancePayload(
    domain.MealAiProvenance provenance,
  ) => {
    'requestId': provenance.requestId,
    'schemaVersion': provenance.schemaVersion,
    'promptVersion': provenance.promptVersion,
    'modelId': provenance.modelId,
    'proposalCreatedAtUtc': provenance.proposalCreatedAtUtc.toIso8601String(),
    'confirmedAtUtc': provenance.confirmedAtUtc.toIso8601String(),
    'acceptedMatches': provenance.acceptedMatches
        .map(
          (match) => {
            'catalogFoodId': match.catalogFoodId,
            'servingId': match.servingId,
            'quantity': match.quantity,
            'confidence': match.confidence,
          },
        )
        .toList(growable: false),
  };

  Map<String, Object?> _itemPayload(MealItemCalculationSnapshot item) => {
    'calculationVersion': item.calculationVersion,
    'catalogItemType': item.catalogItemType.name,
    'weightBasis': item.weightBasis.name,
    'catalogReleaseId': item.catalogReleaseId,
    'foodId': item.foodId,
    'sourceId': item.sourceId,
    'sourceVersion': item.sourceVersion,
    'sourceRecordId': item.sourceRecordId,
    'servingId': item.servingId,
    'servingLabel': item.servingLabel,
    'unitCode': item.unitCode,
    'quantity': item.quantity,
    'grams': _rangePayload(item.grams),
    'servingConfidence': item.servingConfidence,
    'nutrition': _nutritionPayload(item.nutrition),
    'oilInclusion': item.oilInclusion.name,
  };

  Map<String, Object?> _nutritionPayload(NutritionRangeSnapshot value) => {
    'caloriesKcal': _rangePayload(value.caloriesKcal),
    'proteinGrams': _rangePayload(value.proteinGrams),
    'carbohydrateGrams': _rangePayload(value.carbohydrateGrams),
    'fatGrams': _rangePayload(value.fatGrams),
    'sodiumMilligrams': value.sodiumMilligrams == null
        ? null
        : _rangePayload(value.sodiumMilligrams!),
  };

  Map<String, double> _rangePayload(ValueRange value) => {
    'minimum': value.minimum,
    'maximum': value.maximum,
  };
}
