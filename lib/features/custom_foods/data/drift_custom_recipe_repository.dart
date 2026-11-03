import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../../catalog/domain/catalog_food.dart';
import '../../meals/domain/nutrition_calculator.dart';
import '../../recipes/domain/catalog_recipe.dart' show RecipeOilTreatment;
import '../domain/custom_recipe_records.dart';

class DriftCustomRecipeRepository implements CustomRecipeRepository {
  factory DriftCustomRecipeRepository({
    required db.AppDatabase database,
    required String expectedOwnerId,
  }) => DriftCustomRecipeRepository._(database, expectedOwnerId);

  const DriftCustomRecipeRepository._(this._database, this._expectedOwnerId);

  static const entityType = 'custom_recipe';
  static const payloadSchemaVersion = 1;

  final db.AppDatabase _database;
  final String _expectedOwnerId;

  @override
  Future<void> save(CustomRecipeRecord recipe) async {
    if (recipe.ownerId != _expectedOwnerId) {
      throw StateError('Custom recipe owner does not match active account');
    }
    final payloadJson = jsonEncode(_payload(recipe));
    await _database.transaction(() async {
      await _database
          .into(_database.customRecipes)
          .insert(
            db.CustomRecipesCompanion.insert(
              ownerId: recipe.ownerId,
              customRecipeId: recipe.id,
              name: recipe.name,
              normalizedName: _normalize(recipe.name),
              yieldServingsMinimum: recipe.yieldServingsMinimum,
              yieldServingsMaximum: recipe.yieldServingsMaximum,
              oilTreatment: recipe.oilTreatment.name,
              revision: recipe.revision,
              createdAtUtc: recipe.createdAtUtc,
              updatedAtUtc: recipe.updatedAtUtc,
            ),
          );
      for (final indexed in recipe.ingredients.indexed) {
        final (index, item) = indexed;
        final nutrition = item.nutrition;
        await _database
            .into(_database.customRecipeIngredients)
            .insert(
              db.CustomRecipeIngredientsCompanion.insert(
                ownerId: recipe.ownerId,
                customRecipeId: recipe.id,
                ingredientIndex: index,
                catalogItemType: item.catalogItemType.name,
                catalogReleaseId: item.catalogReleaseId,
                itemId: item.foodId,
                sourceId: item.sourceId,
                sourceVersion: item.sourceVersion,
                sourceRecordId: item.sourceRecordId,
                servingId: item.servingId,
                servingLabel: item.servingLabel,
                unitCode: item.unitCode,
                quantity: item.quantity,
                gramsMinimum: item.grams.minimum,
                gramsMaximum: item.grams.maximum,
                weightBasis: item.weightBasis.name,
                servingConfidence: item.servingConfidence,
                caloriesMinimum: nutrition.caloriesKcal.minimum,
                caloriesMaximum: nutrition.caloriesKcal.maximum,
                proteinMinimum: nutrition.proteinGrams.minimum,
                proteinMaximum: nutrition.proteinGrams.maximum,
                carbohydrateMinimum: nutrition.carbohydrateGrams.minimum,
                carbohydrateMaximum: nutrition.carbohydrateGrams.maximum,
                fatMinimum: nutrition.fatGrams.minimum,
                fatMaximum: nutrition.fatGrams.maximum,
                sodiumMinimum: Value.absentIfNull(
                  nutrition.sodiumMilligrams?.minimum,
                ),
                sodiumMaximum: Value.absentIfNull(
                  nutrition.sodiumMilligrams?.maximum,
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
              ownerId: recipe.ownerId,
              entityType: entityType,
              entityKey: recipe.id,
              schemaVersion: payloadSchemaVersion,
              revision: recipe.revision,
              payloadJson: payloadJson,
              createdAtClient: recipe.createdAtUtc,
              updatedAtClient: recipe.updatedAtUtc,
            ),
          );
      await _database
          .into(_database.syncOutboxEntries)
          .insert(
            db.SyncOutboxEntriesCompanion.insert(
              ownerId: recipe.ownerId,
              operationId: '$entityType:${recipe.id}:r${recipe.revision}',
              entityType: entityType,
              entityKey: recipe.id,
              operationType: 'upsert',
              baseRevision: recipe.revision - 1,
              newRevision: recipe.revision,
              payloadJson: payloadJson,
              createdAtClient: recipe.updatedAtUtc,
            ),
          );
    });
  }

  @override
  Future<List<CustomRecipeRecord>> search(String query) async {
    final normalized = _normalize(query);
    if (normalized.isEmpty) throw ArgumentError('Search text is required');
    final rows =
        await (_database.select(_database.customRecipes)
              ..where(
                (row) =>
                    row.ownerId.equals(_expectedOwnerId) &
                    row.isDeleted.equals(false) &
                    row.normalizedName.like(
                      '${_escapeLike(normalized)}%',
                      escapeChar: r'\',
                    ),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.normalizedName)])
              ..limit(50))
            .get();
    if (rows.isEmpty) return const [];
    final recipeIds = rows.map((row) => row.customRecipeId).toList();
    final ingredientRows =
        await (_database.select(_database.customRecipeIngredients)
              ..where(
                (row) =>
                    row.ownerId.equals(_expectedOwnerId) &
                    row.customRecipeId.isIn(recipeIds),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.customRecipeId),
                (row) => OrderingTerm.asc(row.ingredientIndex),
              ]))
            .get();
    return [
      for (final recipe in rows)
        CustomRecipeRecord(
          id: recipe.customRecipeId,
          ownerId: recipe.ownerId,
          name: recipe.name,
          ingredients: ingredientRows
              .where((row) => row.customRecipeId == recipe.customRecipeId)
              .map(_mapIngredient)
              .toList(growable: false),
          yieldServingsMinimum: recipe.yieldServingsMinimum,
          yieldServingsMaximum: recipe.yieldServingsMaximum,
          oilTreatment: RecipeOilTreatment.values.byName(recipe.oilTreatment),
          revision: recipe.revision,
          createdAtUtc: recipe.createdAtUtc.toUtc(),
          updatedAtUtc: recipe.updatedAtUtc.toUtc(),
        ),
    ];
  }

  MealItemCalculationSnapshot _mapIngredient(db.CustomRecipeIngredient row) =>
      MealItemCalculationSnapshot(
        calculationVersion: row.calculationVersion,
        catalogReleaseId: row.catalogReleaseId,
        foodId: row.itemId,
        sourceId: row.sourceId,
        sourceVersion: row.sourceVersion,
        sourceRecordId: row.sourceRecordId,
        servingId: row.servingId,
        servingLabel: row.servingLabel,
        unitCode: row.unitCode,
        quantity: row.quantity,
        grams: ValueRange(row.gramsMinimum, row.gramsMaximum),
        servingConfidence: row.servingConfidence,
        nutrition: NutritionRangeSnapshot(
          caloriesKcal: ValueRange(row.caloriesMinimum, row.caloriesMaximum),
          proteinGrams: ValueRange(row.proteinMinimum, row.proteinMaximum),
          carbohydrateGrams: ValueRange(
            row.carbohydrateMinimum,
            row.carbohydrateMaximum,
          ),
          fatGrams: ValueRange(row.fatMinimum, row.fatMaximum),
          sodiumMilligrams:
              row.sodiumMinimum == null || row.sodiumMaximum == null
              ? null
              : ValueRange(row.sodiumMinimum!, row.sodiumMaximum!),
        ),
        oilInclusion: OilInclusion.values.byName(row.oilInclusion),
        catalogItemType: CatalogItemType.values.byName(row.catalogItemType),
        weightBasis: WeightBasis.values.byName(row.weightBasis),
      );

  Map<String, Object?> _payload(CustomRecipeRecord recipe) => {
    'schemaVersion': payloadSchemaVersion,
    'id': recipe.id,
    'ownerId': recipe.ownerId,
    'name': recipe.name,
    'yieldServingsMinimum': recipe.yieldServingsMinimum,
    'yieldServingsMaximum': recipe.yieldServingsMaximum,
    'oilTreatment': recipe.oilTreatment.name,
    'revision': recipe.revision,
    'createdAtUtc': recipe.createdAtUtc.toIso8601String(),
    'updatedAtUtc': recipe.updatedAtUtc.toIso8601String(),
    'origin': 'user_entered_unreviewed',
    'ingredients': recipe.ingredients
        .map(
          (item) => {
            'catalogItemType': item.catalogItemType.name,
            'catalogReleaseId': item.catalogReleaseId,
            'itemId': item.foodId,
            'sourceId': item.sourceId,
            'sourceVersion': item.sourceVersion,
            'sourceRecordId': item.sourceRecordId,
            'servingId': item.servingId,
            'servingLabel': item.servingLabel,
            'unitCode': item.unitCode,
            'quantity': item.quantity,
            'gramsMinimum': item.grams.minimum,
            'gramsMaximum': item.grams.maximum,
            'weightBasis': item.weightBasis.name,
            'servingConfidence': item.servingConfidence,
            'caloriesMinimum': item.nutrition.caloriesKcal.minimum,
            'caloriesMaximum': item.nutrition.caloriesKcal.maximum,
            'proteinMinimum': item.nutrition.proteinGrams.minimum,
            'proteinMaximum': item.nutrition.proteinGrams.maximum,
            'carbohydrateMinimum': item.nutrition.carbohydrateGrams.minimum,
            'carbohydrateMaximum': item.nutrition.carbohydrateGrams.maximum,
            'fatMinimum': item.nutrition.fatGrams.minimum,
            'fatMaximum': item.nutrition.fatGrams.maximum,
            'sodiumMinimum': item.nutrition.sodiumMilligrams?.minimum,
            'sodiumMaximum': item.nutrition.sodiumMilligrams?.maximum,
            'oilInclusion': item.oilInclusion.name,
            'calculationVersion': item.calculationVersion,
          },
        )
        .toList(growable: false),
  };
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
