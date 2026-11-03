import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/catalog_food.dart' as domain;
import '../domain/catalog_import.dart';
import '../../recipes/domain/catalog_recipe.dart' as recipe_domain;

class DriftCatalogImporter implements CatalogImporter {
  const DriftCatalogImporter(this._database, this._verification);

  final db.AppDatabase _database;
  final CatalogImportVerificationPort _verification;

  @override
  Future<CatalogImportStatus> importBundle(CatalogImportBundle bundle) async {
    if (!await _verification.verify(bundle)) {
      throw const CatalogPackageVerificationFailed();
    }
    return _database.transaction(() async {
      final existing =
          await (_database.select(_database.catalogReleases)
                ..where((row) => row.releaseId.equals(bundle.release.id)))
              .getSingleOrNull();
      if (existing != null) {
        if (existing.contentChecksum != bundle.release.contentChecksum) {
          throw const ImmutableCatalogReleaseViolation();
        }
        return CatalogImportStatus.alreadyPresent;
      }

      final sources = <String, domain.NutritionProvenance>{};
      for (final food in bundle.foods) {
        final key = _sourceKey(food.provenance);
        final previous = sources[key];
        if (previous != null && !_sameSource(previous, food.provenance)) {
          throw const NutritionSourceContinuityViolation();
        }
        sources[key] = food.provenance;
      }
      for (final recipe in bundle.recipes) {
        final key = _sourceKey(recipe.provenance);
        final previous = sources[key];
        if (previous != null && !_sameSource(previous, recipe.provenance)) {
          throw const NutritionSourceContinuityViolation();
        }
        sources[key] = recipe.provenance;
      }
      for (final entry in sources.entries) {
        final existingSource = await (_database.select(
          _database.nutritionSources,
        )..where((row) => row.sourceKey.equals(entry.key))).getSingleOrNull();
        if (existingSource != null) {
          if (existingSource.sourceId != entry.value.sourceId ||
              existingSource.sourceVersion != entry.value.sourceVersion ||
              existingSource.citation != entry.value.citation ||
              existingSource.licenseId != entry.value.licenseId) {
            throw const NutritionSourceContinuityViolation();
          }
          continue;
        }
        await _database
            .into(_database.nutritionSources)
            .insert(
              db.NutritionSourcesCompanion.insert(
                sourceKey: entry.key,
                sourceId: entry.value.sourceId,
                sourceVersion: entry.value.sourceVersion,
                citation: entry.value.citation,
                licenseId: entry.value.licenseId,
              ),
            );
      }

      final now = DateTime.now().toUtc();
      await _database
          .into(_database.catalogReleases)
          .insert(
            db.CatalogReleasesCompanion.insert(
              releaseId: bundle.release.id,
              version: bundle.release.version,
              reviewStatus: _reviewStatus(bundle.release.reviewStatus),
              contentChecksum: bundle.release.contentChecksum,
              publishedAt: Value(bundle.release.publishedAt!),
              importedAt: now,
            ),
          );
      for (final food in bundle.foods) {
        await _insertFood(food);
      }
      for (final recipe in bundle.recipes) {
        await _insertRecipe(recipe);
      }
      return CatalogImportStatus.imported;
    });
  }

  Future<void> _insertFood(domain.CatalogFood food) async {
    await _database
        .into(_database.catalogFoods)
        .insert(
          db.CatalogFoodsCompanion.insert(
            releaseId: food.releaseId,
            foodId: food.id,
            nameEnglish: food.nameEnglish,
            nameRomanUrdu: food.nameRomanUrdu,
            normalizedNameEnglish: _normalize(food.nameEnglish),
            normalizedNameRomanUrdu: _normalize(food.nameRomanUrdu),
            region: Value.absentIfNull(food.region),
            preparation: Value.absentIfNull(food.preparation),
            referenceGrams: food.nutrition.referenceGrams,
            caloriesKcal: food.nutrition.caloriesKcal,
            proteinGrams: food.nutrition.proteinGrams,
            carbohydrateGrams: food.nutrition.carbohydrateGrams,
            fatGrams: food.nutrition.fatGrams,
            sodiumMilligrams: Value.absentIfNull(
              food.nutrition.sodiumMilligrams,
            ),
            oilInclusion: _oilInclusion(food.oilInclusion),
            sourceKey: _sourceKey(food.provenance),
            sourceRecordId: food.provenance.sourceRecordId,
            reviewStatus: _reviewStatus(food.provenance.reviewStatus),
            reviewerId: Value.absentIfNull(food.provenance.reviewerId),
            reviewedAt: Value.absentIfNull(food.provenance.reviewedAt),
          ),
        );
    for (final synonym in food.synonyms) {
      await _database
          .into(_database.catalogFoodSynonyms)
          .insert(
            db.CatalogFoodSynonymsCompanion.insert(
              releaseId: food.releaseId,
              foodId: food.id,
              locale: 'und',
              synonym: synonym,
              normalizedSynonym: _normalize(synonym),
            ),
          );
    }
    for (final serving in food.servings) {
      await _database
          .into(_database.catalogServingDefinitions)
          .insert(
            db.CatalogServingDefinitionsCompanion.insert(
              releaseId: food.releaseId,
              foodId: food.id,
              servingId: serving.id,
              label: serving.label,
              unitCode: serving.unitCode,
              gramsMinimum: serving.gramsMinimum,
              gramsMaximum: serving.gramsMaximum,
              confidence: serving.confidence,
            ),
          );
    }
  }

  Future<void> _insertRecipe(recipe_domain.CatalogRecipe recipe) async {
    await _database
        .into(_database.catalogRecipes)
        .insert(
          db.CatalogRecipesCompanion.insert(
            releaseId: recipe.releaseId,
            recipeId: recipe.id,
            nameEnglish: recipe.nameEnglish,
            nameRomanUrdu: recipe.nameRomanUrdu,
            normalizedNameEnglish: _normalize(recipe.nameEnglish),
            normalizedNameRomanUrdu: _normalize(recipe.nameRomanUrdu),
            region: Value.absentIfNull(recipe.region),
            preparationVariant: Value.absentIfNull(recipe.preparationVariant),
            yieldServingsMinimum: recipe.yieldServingsMinimum,
            yieldServingsMaximum: recipe.yieldServingsMaximum,
            oilTreatment: _recipeOilTreatment(recipe.oilTreatment),
            sourceKey: _sourceKey(recipe.provenance),
            sourceRecordId: recipe.provenance.sourceRecordId,
            reviewStatus: _reviewStatus(recipe.provenance.reviewStatus),
            reviewerId: Value.absentIfNull(recipe.provenance.reviewerId),
            reviewedAt: Value.absentIfNull(recipe.provenance.reviewedAt),
          ),
        );
    for (final synonym in recipe.synonyms) {
      await _database
          .into(_database.catalogRecipeSynonyms)
          .insert(
            db.CatalogRecipeSynonymsCompanion.insert(
              releaseId: recipe.releaseId,
              recipeId: recipe.id,
              locale: 'und',
              synonym: synonym,
              normalizedSynonym: _normalize(synonym),
            ),
          );
    }
    for (var index = 0; index < recipe.ingredients.length; index++) {
      final ingredient = recipe.ingredients[index];
      await _database
          .into(_database.catalogRecipeIngredients)
          .insert(
            db.CatalogRecipeIngredientsCompanion.insert(
              releaseId: recipe.releaseId,
              recipeId: recipe.id,
              ingredientIndex: index,
              foodId: ingredient.food.id,
              servingId: ingredient.servingId,
              quantity: ingredient.quantity,
              exactGramsPerServing: Value.absentIfNull(
                ingredient.exactGramsPerServing,
              ),
            ),
          );
    }
  }
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _sourceKey(domain.NutritionProvenance source) =>
    '${source.sourceId.length}:${source.sourceId}${source.sourceVersion}';

bool _sameSource(
  domain.NutritionProvenance first,
  domain.NutritionProvenance second,
) =>
    first.sourceId == second.sourceId &&
    first.sourceVersion == second.sourceVersion &&
    first.citation == second.citation &&
    first.licenseId == second.licenseId;

String _reviewStatus(domain.CatalogReviewStatus status) => switch (status) {
  domain.CatalogReviewStatus.draft => 'draft',
  domain.CatalogReviewStatus.inReview => 'inReview',
  domain.CatalogReviewStatus.approved => 'approved',
  domain.CatalogReviewStatus.rejected => 'rejected',
  domain.CatalogReviewStatus.retired => 'retired',
};

String _oilInclusion(domain.OilInclusion value) => switch (value) {
  domain.OilInclusion.included => 'included',
  domain.OilInclusion.excluded => 'excluded',
  domain.OilInclusion.unknown => 'unknown',
};

String _recipeOilTreatment(recipe_domain.RecipeOilTreatment value) =>
    switch (value) {
      recipe_domain.RecipeOilTreatment.includedInIngredients =>
        'includedInIngredients',
      recipe_domain.RecipeOilTreatment.excludedFromCalculation =>
        'excludedFromCalculation',
      recipe_domain.RecipeOilTreatment.unknown => 'unknown',
    };
