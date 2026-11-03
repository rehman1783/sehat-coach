import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';

NutritionProvenance provenance({
  CatalogReviewStatus status = CatalogReviewStatus.approved,
}) => NutritionProvenance(
  sourceId: 'source-1',
  sourceVersion: '2026.1',
  sourceRecordId: 'record-1',
  citation: 'Licensed source citation',
  licenseId: 'license-1',
  reviewStatus: status,
  reviewerId: status == CatalogReviewStatus.approved ? 'reviewer-1' : null,
  reviewedAt: status == CatalogReviewStatus.approved
      ? DateTime.utc(2026, 10, 22)
      : null,
);

CatalogFood food({
  String releaseId = 'release-1',
  CatalogReviewStatus status = CatalogReviewStatus.approved,
}) => CatalogFood(
  id: 'food-1',
  releaseId: releaseId,
  nameEnglish: 'Example food',
  nameRomanUrdu: 'Misali khana',
  synonyms: const ['example'],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 120,
    proteinGrams: 5,
    carbohydrateGrams: 20,
    fatGrams: 3,
  ),
  provenance: provenance(status: status),
  oilInclusion: OilInclusion.unknown,
  servings: [
    ServingDefinition(
      id: 'serving-1',
      label: '1 serving',
      unitCode: 'serving',
      gramsMinimum: 90,
      gramsMaximum: 110,
      confidence: 0.8,
    ),
  ],
);

CatalogRelease release({
  String id = 'release-1',
  CatalogReviewStatus status = CatalogReviewStatus.approved,
}) => CatalogRelease(
  id: id,
  version: '1.0.0',
  reviewStatus: status,
  contentChecksum: 'sha256-placeholder-for-domain-test',
  publishedAt: status == CatalogReviewStatus.approved
      ? DateTime.utc(2026, 10, 22)
      : null,
);

void main() {
  test('approved food requires explicit provenance and review evidence', () {
    expect(canExposeAsApprovedFood(release(), food()), isTrue);
    expect(
      () => NutritionProvenance(
        sourceId: 'source-1',
        sourceVersion: '1',
        sourceRecordId: 'record-1',
        citation: 'citation',
        licenseId: 'license-1',
        reviewStatus: CatalogReviewStatus.approved,
      ),
      throwsArgumentError,
    );
  });

  test('draft source, draft release or release mismatch cannot be exposed', () {
    expect(
      canExposeAsApprovedFood(
        release(status: CatalogReviewStatus.draft),
        food(),
      ),
      isFalse,
    );
    expect(
      canExposeAsApprovedFood(
        release(),
        food(status: CatalogReviewStatus.inReview),
      ),
      isFalse,
    );
    expect(
      canExposeAsApprovedFood(release(), food(releaseId: 'other-release')),
      isFalse,
    );
  });

  test('nutrition and serving values reject impossible ranges', () {
    expect(
      () => NutritionPerReference(
        referenceGrams: 0,
        caloriesKcal: 10,
        proteinGrams: 1,
        carbohydrateGrams: 1,
        fatGrams: 1,
      ),
      throwsArgumentError,
    );
    expect(
      () => ServingDefinition(
        id: 'serving',
        label: 'Katori',
        unitCode: 'katori',
        gramsMinimum: 200,
        gramsMaximum: 100,
        confidence: 0.5,
      ),
      throwsArgumentError,
    );
  });

  test('catalog food requires a serving and unique serving IDs', () {
    final baseServing = ServingDefinition(
      id: 'same',
      label: 'Piece',
      unitCode: 'piece',
      gramsMinimum: 40,
      gramsMaximum: 50,
      confidence: 0.7,
    );
    expect(
      () => CatalogFood(
        id: 'food',
        releaseId: 'release',
        nameEnglish: 'Food',
        nameRomanUrdu: 'Khana',
        synonyms: const [],
        nutrition: NutritionPerReference(
          referenceGrams: 100,
          caloriesKcal: 1,
          proteinGrams: 1,
          carbohydrateGrams: 1,
          fatGrams: 1,
        ),
        provenance: provenance(),
        oilInclusion: OilInclusion.excluded,
        servings: [baseServing, baseServing],
      ),
      throwsArgumentError,
    );
  });

  test('offline search query is trimmed and bounded', () {
    final query = FoodSearchQuery('  daal  ', limit: 10);
    expect(query.text, 'daal');
    expect(query.limit, 10);
    expect(() => FoodSearchQuery('   '), throwsArgumentError);
    expect(() => FoodSearchQuery('food', limit: 0), throwsArgumentError);
  });
}
