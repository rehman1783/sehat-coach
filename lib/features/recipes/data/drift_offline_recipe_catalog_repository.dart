import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../../catalog/data/drift_offline_food_catalog_repository.dart';
import '../../catalog/domain/catalog_food.dart' as food_domain;
import '../domain/catalog_recipe.dart' as domain;
import '../domain/offline_recipe_catalog_repository.dart';

class DriftOfflineRecipeCatalogRepository
    implements OfflineRecipeCatalogRepository {
  DriftOfflineRecipeCatalogRepository(this._database)
    : _foods = DriftOfflineFoodCatalogRepository(_database);

  final db.AppDatabase _database;
  final DriftOfflineFoodCatalogRepository _foods;

  @override
  Future<List<domain.CatalogRecipe>> search(RecipeSearchQuery query) async {
    final prefix = '${_escapeLike(_normalize(query.text))}%';
    final rows = await _database
        .customSelect(
          r'''
          WITH active_release AS (
            SELECT release_id
            FROM catalog_releases
            WHERE review_status = 'approved' AND published_at IS NOT NULL
            ORDER BY published_at DESC, release_id DESC
            LIMIT 1
          )
          SELECT DISTINCT recipe.*
          FROM catalog_recipes AS recipe
          JOIN active_release AS active
            ON active.release_id = recipe.release_id
          LEFT JOIN catalog_recipe_synonyms AS synonym
            ON synonym.release_id = recipe.release_id
            AND synonym.recipe_id = recipe.recipe_id
          WHERE recipe.review_status = 'approved'
            AND recipe.reviewer_id IS NOT NULL
            AND recipe.reviewed_at IS NOT NULL
            AND EXISTS (
              SELECT 1 FROM catalog_recipe_ingredients AS ingredient
              WHERE ingredient.release_id = recipe.release_id
                AND ingredient.recipe_id = recipe.recipe_id
            )
            AND (
              recipe.normalized_name_english LIKE ? ESCAPE '\'
              OR recipe.normalized_name_roman_urdu LIKE ? ESCAPE '\'
              OR synonym.normalized_synonym LIKE ? ESCAPE '\'
            )
          ORDER BY recipe.normalized_name_english, recipe.recipe_id
          LIMIT ?
          ''',
          variables: [
            Variable<String>(prefix),
            Variable<String>(prefix),
            Variable<String>(prefix),
            Variable<int>(query.limit),
          ],
          readsFrom: {
            _database.catalogReleases,
            _database.catalogRecipes,
            _database.catalogRecipeSynonyms,
            _database.catalogRecipeIngredients,
          },
        )
        .map((row) => _database.catalogRecipes.map(row.data))
        .get();
    return _hydrate(rows);
  }

  @override
  Future<domain.CatalogRecipe?> findApprovedById(String recipeId) async {
    final id = recipeId.trim();
    if (id.isEmpty) throw ArgumentError('Recipe ID is required');
    final rows = await _database
        .customSelect(
          r'''
          WITH active_release AS (
            SELECT release_id
            FROM catalog_releases
            WHERE review_status = 'approved' AND published_at IS NOT NULL
            ORDER BY published_at DESC, release_id DESC
            LIMIT 1
          )
          SELECT recipe.*
          FROM catalog_recipes AS recipe
          JOIN active_release AS active
            ON active.release_id = recipe.release_id
          WHERE recipe.recipe_id = ?
            AND recipe.review_status = 'approved'
            AND recipe.reviewer_id IS NOT NULL
            AND recipe.reviewed_at IS NOT NULL
            AND EXISTS (
              SELECT 1 FROM catalog_recipe_ingredients AS ingredient
              WHERE ingredient.release_id = recipe.release_id
                AND ingredient.recipe_id = recipe.recipe_id
            )
          LIMIT 1
          ''',
          variables: [Variable<String>(id)],
          readsFrom: {
            _database.catalogReleases,
            _database.catalogRecipes,
            _database.catalogRecipeIngredients,
          },
        )
        .map((row) => _database.catalogRecipes.map(row.data))
        .get();
    if (rows.isEmpty) return null;
    return (await _hydrate(rows)).single;
  }

  Future<List<domain.CatalogRecipe>> _hydrate(
    List<db.CatalogRecipe> recipes,
  ) async {
    if (recipes.isEmpty) return const [];
    final releaseId = recipes.first.releaseId;
    if (recipes.any((recipe) => recipe.releaseId != releaseId)) {
      throw StateError('Recipe query mixed immutable releases');
    }
    final recipeIds = recipes.map((recipe) => recipe.recipeId).toList();
    final synonyms =
        await (_database.select(_database.catalogRecipeSynonyms)..where(
              (row) =>
                  row.releaseId.equals(releaseId) &
                  row.recipeId.isIn(recipeIds),
            ))
            .get();
    final ingredients =
        await (_database.select(_database.catalogRecipeIngredients)
              ..where(
                (row) =>
                    row.releaseId.equals(releaseId) &
                    row.recipeId.isIn(recipeIds),
              )
              ..orderBy([
                (row) => OrderingTerm.asc(row.recipeId),
                (row) => OrderingTerm.asc(row.ingredientIndex),
              ]))
            .get();
    final sourceKeys = recipes.map((recipe) => recipe.sourceKey).toSet();
    final sourceRows = await (_database.select(
      _database.nutritionSources,
    )..where((row) => row.sourceKey.isIn(sourceKeys))).get();
    final sources = {for (final source in sourceRows) source.sourceKey: source};
    final foodIds = ingredients.map((row) => row.foodId).toSet();
    final foods = <String, food_domain.CatalogFood>{};
    for (final foodId in foodIds) {
      final food = await _foods.findApprovedById(foodId);
      if (food == null || food.releaseId != releaseId) {
        throw StateError('Approved recipe ingredient food is unavailable');
      }
      foods[foodId] = food;
    }

    return [
      for (final recipe in recipes)
        _mapRecipe(
          recipe,
          sources[recipe.sourceKey],
          synonyms
              .where((row) => row.recipeId == recipe.recipeId)
              .map((row) => row.synonym),
          ingredients.where((row) => row.recipeId == recipe.recipeId),
          foods,
        ),
    ];
  }

  domain.CatalogRecipe _mapRecipe(
    db.CatalogRecipe recipe,
    db.NutritionSource? source,
    Iterable<String> synonyms,
    Iterable<db.CatalogRecipeIngredient> ingredients,
    Map<String, food_domain.CatalogFood> foods,
  ) {
    if (source == null) throw StateError('Recipe source is missing');
    return domain.CatalogRecipe(
      id: recipe.recipeId,
      releaseId: recipe.releaseId,
      nameEnglish: recipe.nameEnglish,
      nameRomanUrdu: recipe.nameRomanUrdu,
      synonyms: synonyms,
      ingredients: [
        for (final ingredient in ingredients)
          domain.RecipeIngredient(
            food: foods[ingredient.foodId]!,
            servingId: ingredient.servingId,
            quantity: ingredient.quantity,
            exactGramsPerServing: ingredient.exactGramsPerServing,
          ),
      ],
      yieldServingsMinimum: recipe.yieldServingsMinimum,
      yieldServingsMaximum: recipe.yieldServingsMaximum,
      oilTreatment: _oilTreatment(recipe.oilTreatment),
      provenance: food_domain.NutritionProvenance(
        sourceId: source.sourceId,
        sourceVersion: source.sourceVersion,
        sourceRecordId: recipe.sourceRecordId,
        citation: source.citation,
        licenseId: source.licenseId,
        reviewStatus: _reviewStatus(recipe.reviewStatus),
        reviewerId: recipe.reviewerId,
        reviewedAt: recipe.reviewedAt,
      ),
      region: recipe.region,
      preparationVariant: recipe.preparationVariant,
    );
  }
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

food_domain.CatalogReviewStatus _reviewStatus(String value) => switch (value) {
  'draft' => food_domain.CatalogReviewStatus.draft,
  'inReview' => food_domain.CatalogReviewStatus.inReview,
  'approved' => food_domain.CatalogReviewStatus.approved,
  'rejected' => food_domain.CatalogReviewStatus.rejected,
  'retired' => food_domain.CatalogReviewStatus.retired,
  _ => throw FormatException('Unknown recipe review status'),
};

domain.RecipeOilTreatment _oilTreatment(String value) => switch (value) {
  'includedInIngredients' => domain.RecipeOilTreatment.includedInIngredients,
  'excludedFromCalculation' =>
    domain.RecipeOilTreatment.excludedFromCalculation,
  'unknown' => domain.RecipeOilTreatment.unknown,
  _ => throw FormatException('Unknown recipe oil treatment'),
};
