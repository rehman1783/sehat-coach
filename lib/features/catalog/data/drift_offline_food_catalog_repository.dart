import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart' as db;
import '../domain/catalog_food.dart' as domain;
import '../domain/offline_food_catalog_repository.dart';

class DriftOfflineFoodCatalogRepository
    implements OfflineFoodCatalogRepository {
  const DriftOfflineFoodCatalogRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<List<domain.CatalogFood>> search(FoodSearchQuery query) async {
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
          SELECT DISTINCT f.*
          FROM catalog_foods AS f
          JOIN active_release AS active ON active.release_id = f.release_id
          LEFT JOIN catalog_food_synonyms AS synonym
            ON synonym.release_id = f.release_id AND synonym.food_id = f.food_id
          WHERE f.review_status = 'approved'
            AND f.reviewer_id IS NOT NULL
            AND f.reviewed_at IS NOT NULL
            AND EXISTS (
              SELECT 1 FROM catalog_serving_definitions AS serving
              WHERE serving.release_id = f.release_id
                AND serving.food_id = f.food_id
            )
            AND (
              f.normalized_name_english LIKE ? ESCAPE '\'
              OR f.normalized_name_roman_urdu LIKE ? ESCAPE '\'
              OR synonym.normalized_synonym LIKE ? ESCAPE '\'
            )
          ORDER BY f.normalized_name_english, f.food_id
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
            _database.catalogFoods,
            _database.catalogFoodSynonyms,
            _database.catalogServingDefinitions,
          },
        )
        .map((row) => _database.catalogFoods.map(row.data))
        .get();
    return _hydrate(rows);
  }

  @override
  Future<domain.CatalogFood?> findApprovedById(String foodId) async {
    final id = foodId.trim();
    if (id.isEmpty) throw ArgumentError('Food ID is required');
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
          SELECT f.*
          FROM catalog_foods AS f
          JOIN active_release AS active ON active.release_id = f.release_id
          WHERE f.food_id = ?
            AND f.review_status = 'approved'
            AND f.reviewer_id IS NOT NULL
            AND f.reviewed_at IS NOT NULL
            AND EXISTS (
              SELECT 1 FROM catalog_serving_definitions AS serving
              WHERE serving.release_id = f.release_id
                AND serving.food_id = f.food_id
            )
          LIMIT 1
          ''',
          variables: [Variable<String>(id)],
          readsFrom: {
            _database.catalogReleases,
            _database.catalogFoods,
            _database.catalogServingDefinitions,
          },
        )
        .map((row) => _database.catalogFoods.map(row.data))
        .get();
    if (rows.isEmpty) return null;
    return (await _hydrate(rows)).single;
  }

  Future<domain.CatalogFood?> findApprovedByReleaseAndId({
    required String releaseId,
    required String foodId,
  }) async {
    final release = releaseId.trim();
    final id = foodId.trim();
    if (release.isEmpty || id.isEmpty) {
      throw ArgumentError('Catalog release and food ID are required');
    }
    final releaseRow = await (_database.select(
      _database.catalogReleases,
    )..where((row) => row.releaseId.equals(release))).getSingleOrNull();
    if (releaseRow == null ||
        releaseRow.publishedAt == null ||
        (releaseRow.reviewStatus != 'approved' &&
            releaseRow.reviewStatus != 'retired')) {
      return null;
    }
    final rows =
        await (_database.select(_database.catalogFoods)..where(
              (row) =>
                  row.releaseId.equals(release) &
                  row.foodId.equals(id) &
                  row.reviewStatus.equals('approved') &
                  row.reviewerId.isNotNull() &
                  row.reviewedAt.isNotNull(),
            ))
            .get();
    if (rows.isEmpty) return null;
    final servingExists =
        await (_database.select(_database.catalogServingDefinitions)
              ..where(
                (row) => row.releaseId.equals(release) & row.foodId.equals(id),
              )
              ..limit(1))
            .getSingleOrNull();
    if (servingExists == null) return null;
    final hydrated = await _hydrate(rows);
    return hydrated.single;
  }

  Future<List<domain.CatalogFood>> _hydrate(List<db.CatalogFood> foods) async {
    if (foods.isEmpty) return const [];
    final releaseId = foods.first.releaseId;
    if (foods.any((food) => food.releaseId != releaseId)) {
      throw StateError('Catalog query mixed immutable releases');
    }
    final foodIds = foods.map((food) => food.foodId).toList(growable: false);
    final sourceKeys = foods
        .map((food) => food.sourceKey)
        .toSet()
        .toList(growable: false);

    final synonymRows =
        await (_database.select(_database.catalogFoodSynonyms)..where(
              (row) =>
                  row.releaseId.equals(releaseId) & row.foodId.isIn(foodIds),
            ))
            .get();
    final servingRows =
        await (_database.select(_database.catalogServingDefinitions)..where(
              (row) =>
                  row.releaseId.equals(releaseId) & row.foodId.isIn(foodIds),
            ))
            .get();
    final sourceRows = await (_database.select(
      _database.nutritionSources,
    )..where((row) => row.sourceKey.isIn(sourceKeys))).get();
    final sources = {for (final source in sourceRows) source.sourceKey: source};

    return [
      for (final food in foods)
        _mapFood(
          food,
          sources[food.sourceKey],
          synonymRows
              .where((row) => row.foodId == food.foodId)
              .map((row) => row.synonym),
          servingRows.where((row) => row.foodId == food.foodId),
        ),
    ];
  }

  domain.CatalogFood _mapFood(
    db.CatalogFood food,
    db.NutritionSource? source,
    Iterable<String> synonyms,
    Iterable<db.CatalogServingDefinition> servings,
  ) {
    if (source == null) throw StateError('Catalog source is missing');
    return domain.CatalogFood(
      id: food.foodId,
      releaseId: food.releaseId,
      nameEnglish: food.nameEnglish,
      nameRomanUrdu: food.nameRomanUrdu,
      synonyms: synonyms,
      region: food.region,
      preparation: food.preparation,
      nutrition: domain.NutritionPerReference(
        referenceGrams: food.referenceGrams,
        caloriesKcal: food.caloriesKcal,
        proteinGrams: food.proteinGrams,
        carbohydrateGrams: food.carbohydrateGrams,
        fatGrams: food.fatGrams,
        sodiumMilligrams: food.sodiumMilligrams,
      ),
      provenance: domain.NutritionProvenance(
        sourceId: source.sourceId,
        sourceVersion: source.sourceVersion,
        sourceRecordId: food.sourceRecordId,
        citation: source.citation,
        licenseId: source.licenseId,
        reviewStatus: _reviewStatus(food.reviewStatus),
        reviewerId: food.reviewerId,
        reviewedAt: food.reviewedAt,
      ),
      oilInclusion: _oilInclusion(food.oilInclusion),
      servings: [
        for (final serving in servings)
          domain.ServingDefinition(
            id: serving.servingId,
            label: serving.label,
            unitCode: serving.unitCode,
            gramsMinimum: serving.gramsMinimum,
            gramsMaximum: serving.gramsMaximum,
            confidence: serving.confidence,
          ),
      ],
    );
  }
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

domain.CatalogReviewStatus _reviewStatus(String value) => switch (value) {
  'draft' => domain.CatalogReviewStatus.draft,
  'inReview' => domain.CatalogReviewStatus.inReview,
  'approved' => domain.CatalogReviewStatus.approved,
  'rejected' => domain.CatalogReviewStatus.rejected,
  'retired' => domain.CatalogReviewStatus.retired,
  _ => throw FormatException('Unknown catalog review status'),
};

domain.OilInclusion _oilInclusion(String value) => switch (value) {
  'included' => domain.OilInclusion.included,
  'excluded' => domain.OilInclusion.excluded,
  'unknown' => domain.OilInclusion.unknown,
  _ => throw FormatException('Unknown oil-inclusion state'),
};
