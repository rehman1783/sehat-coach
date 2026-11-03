import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/features/catalog/data/drift_offline_food_catalog_repository.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';

void main() {
  late AppDatabase database;
  late DriftOfflineFoodCatalogRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftOfflineFoodCatalogRepository(database);
    await _insertFixture(database);
  });
  tearDown(() => database.close());

  test('searches approved release by English and Roman Urdu prefix', () async {
    final english = await repository.search(FoodSearchQuery('  Lent  '));
    final romanUrdu = await repository.search(FoodSearchQuery('da'));

    expect(english.map((food) => food.id), ['lentil-approved']);
    expect(romanUrdu.map((food) => food.id), ['lentil-approved']);
  });

  test('searches localized synonym and hydrates source and servings', () async {
    final result = (await repository.search(FoodSearchQuery('mas'))).single;

    expect(result.id, 'lentil-approved');
    expect(result.synonyms, contains('Masoor'));
    expect(result.provenance.sourceId, 'licensed-source');
    expect(result.provenance.sourceVersion, '2026.1');
    expect(result.provenance.isApproved, isTrue);
    expect(result.oilInclusion, OilInclusion.excluded);
    expect(result.servings.single.unitCode, 'katori');
  });

  test('draft food and newer draft release never surface', () async {
    expect(await repository.search(FoodSearchQuery('hidden')), isEmpty);
    expect(await repository.search(FoodSearchQuery('new draft')), isEmpty);
    expect(await repository.findApprovedById('hidden-draft'), isNull);
  });

  test('find by ID is restricted to active approved release', () async {
    final found = await repository.findApprovedById('lentil-approved');
    expect(found?.nameEnglish, 'Lentil bowl');
    expect(await repository.findApprovedById('newer-draft'), isNull);
    await expectLater(repository.findApprovedById('  '), throwsArgumentError);
  });

  test('exact-release lookup never falls forward to another release', () async {
    final found = await repository.findApprovedByReleaseAndId(
      releaseId: 'approved-release',
      foodId: 'lentil-approved',
    );
    expect(found?.releaseId, 'approved-release');
    expect(found?.servings.single.id, 'katori-1');
    expect(
      await repository.findApprovedByReleaseAndId(
        releaseId: 'newer-draft-release',
        foodId: 'newer-draft',
      ),
      isNull,
    );
    expect(
      await repository.findApprovedByReleaseAndId(
        releaseId: 'approved-release',
        foodId: 'missing',
      ),
      isNull,
    );
  });

  test('SQL wildcard characters are treated as literal search text', () async {
    expect(await repository.search(FoodSearchQuery('%')), isEmpty);
    expect(await repository.search(FoodSearchQuery('_')), isEmpty);
  });
}

Future<void> _insertFixture(AppDatabase database) async {
  final published = DateTime.utc(2026, 10, 20);
  final reviewed = DateTime.utc(2026, 10, 19);
  await database.batch((batch) {
    batch.insertAll(database.catalogReleases, [
      CatalogReleasesCompanion.insert(
        releaseId: 'approved-release',
        version: '1.0.0',
        reviewStatus: 'approved',
        contentChecksum: 'approved-checksum',
        publishedAt: Value(published),
        importedAt: published,
      ),
      CatalogReleasesCompanion.insert(
        releaseId: 'newer-draft-release',
        version: '2.0.0-draft',
        reviewStatus: 'draft',
        contentChecksum: 'draft-checksum',
        importedAt: published.add(const Duration(days: 1)),
      ),
    ]);
    batch.insert(
      database.nutritionSources,
      NutritionSourcesCompanion.insert(
        sourceKey: 'licensed-source@2026.1',
        sourceId: 'licensed-source',
        sourceVersion: '2026.1',
        citation: 'Licensed fixture citation',
        licenseId: 'fixture-license',
      ),
    );
    batch.insertAll(database.catalogFoods, [
      _food(
        releaseId: 'approved-release',
        foodId: 'lentil-approved',
        english: 'Lentil bowl',
        romanUrdu: 'Daal katori',
        reviewedAt: reviewed,
      ),
      _food(
        releaseId: 'approved-release',
        foodId: 'hidden-draft',
        english: 'Hidden food',
        romanUrdu: 'Chupa khana',
        reviewStatus: 'draft',
      ),
      _food(
        releaseId: 'newer-draft-release',
        foodId: 'newer-draft',
        english: 'New draft food',
        romanUrdu: 'Naya draft',
        reviewedAt: reviewed,
      ),
    ]);
    batch.insert(
      database.catalogFoodSynonyms,
      CatalogFoodSynonymsCompanion.insert(
        releaseId: 'approved-release',
        foodId: 'lentil-approved',
        locale: 'ur-Latn-PK',
        synonym: 'Masoor',
        normalizedSynonym: 'masoor',
      ),
    );
    batch.insert(
      database.catalogServingDefinitions,
      CatalogServingDefinitionsCompanion.insert(
        releaseId: 'approved-release',
        foodId: 'lentil-approved',
        servingId: 'katori-1',
        label: '1 katori',
        unitCode: 'katori',
        gramsMinimum: 180,
        gramsMaximum: 220,
        confidence: 0.8,
      ),
    );
  });
}

CatalogFoodsCompanion _food({
  required String releaseId,
  required String foodId,
  required String english,
  required String romanUrdu,
  String reviewStatus = 'approved',
  DateTime? reviewedAt,
}) => CatalogFoodsCompanion.insert(
  releaseId: releaseId,
  foodId: foodId,
  nameEnglish: english,
  nameRomanUrdu: romanUrdu,
  normalizedNameEnglish: english.toLowerCase(),
  normalizedNameRomanUrdu: romanUrdu.toLowerCase(),
  referenceGrams: 100,
  caloriesKcal: 120,
  proteinGrams: 7,
  carbohydrateGrams: 18,
  fatGrams: 2,
  oilInclusion: 'excluded',
  sourceKey: 'licensed-source@2026.1',
  sourceRecordId: foodId,
  reviewStatus: reviewStatus,
  reviewerId: reviewedAt == null
      ? const Value.absent()
      : const Value('reviewer-1'),
  reviewedAt: Value.absentIfNull(reviewedAt),
);
