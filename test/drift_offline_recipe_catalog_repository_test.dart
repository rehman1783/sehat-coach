import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart'
    hide CatalogFood, CatalogRecipe, CatalogRelease;
import 'package:sehat_coach/features/catalog/data/drift_catalog_importer.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_import.dart';
import 'package:sehat_coach/features/recipes/data/drift_offline_recipe_catalog_repository.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';
import 'package:sehat_coach/features/recipes/domain/offline_recipe_catalog_repository.dart';

class _Verifier implements CatalogImportVerificationPort {
  @override
  Future<bool> verify(CatalogImportBundle bundle) async => true;
}

void main() {
  late AppDatabase database;
  late DriftOfflineRecipeCatalogRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await DriftCatalogImporter(database, _Verifier()).importBundle(_bundle());
    repository = DriftOfflineRecipeCatalogRepository(database);
  });
  tearDown(() => database.close());

  test('searches English, Roman Urdu and synonym prefixes', () async {
    expect(
      (await repository.search(RecipeSearchQuery(' lent '))).single.id,
      'recipe-1',
    );
    expect(
      (await repository.search(RecipeSearchQuery('daal'))).single.id,
      'recipe-1',
    );
    expect(
      (await repository.search(RecipeSearchQuery('masoor'))).single.id,
      'recipe-1',
    );
  });

  test('hydrates ordered ingredients, food and recipe provenance', () async {
    final recipe = (await repository.search(RecipeSearchQuery('lentil curry')))
        .single;

    expect(recipe.ingredients, hasLength(1));
    expect(recipe.ingredients.single.food.id, 'food-1');
    expect(recipe.ingredients.single.servingId, 'katori-1');
    expect(recipe.ingredients.single.quantity, 2);
    expect(recipe.provenance.sourceId, 'recipe-source');
    expect(recipe.provenance.isApproved, isTrue);
    expect(recipe.oilTreatment, RecipeOilTreatment.includedInIngredients);
    expect(recipe.yieldServingsMaximum, 4);
  });

  test('find by ID is limited to the active approved release', () async {
    expect((await repository.findApprovedById('recipe-1'))?.id, 'recipe-1');
    expect(await repository.findApprovedById('missing'), isNull);
    await expectLater(repository.findApprovedById('  '), throwsArgumentError);

    final now = DateTime.utc(2026, 10, 23);
    await database
        .into(database.catalogReleases)
        .insert(
          CatalogReleasesCompanion.insert(
            releaseId: 'newer-draft',
            version: '2.0.0-draft',
            reviewStatus: 'draft',
            contentChecksum: 'draft-checksum',
            importedAt: now,
            publishedAt: Value(now),
          ),
        );
    expect((await repository.findApprovedById('recipe-1'))?.id, 'recipe-1');
  });

  test('SQL wildcards are literal and query limits are validated', () async {
    expect(await repository.search(RecipeSearchQuery('%')), isEmpty);
    expect(await repository.search(RecipeSearchQuery('_')), isEmpty);
    expect(() => RecipeSearchQuery(''), throwsArgumentError);
    expect(() => RecipeSearchQuery('recipe', limit: 0), throwsArgumentError);
  });
}

CatalogImportBundle _bundle() {
  final reviewedAt = DateTime.utc(2026, 10, 22);
  const releaseId = 'release-1';
  final food = CatalogFood(
    id: 'food-1',
    releaseId: releaseId,
    nameEnglish: 'Lentil bowl',
    nameRomanUrdu: 'Daal katori',
    synonyms: const ['Daal'],
    nutrition: NutritionPerReference(
      referenceGrams: 100,
      caloriesKcal: 120,
      proteinGrams: 7,
      carbohydrateGrams: 18,
      fatGrams: 2,
    ),
    provenance: NutritionProvenance(
      sourceId: 'food-source',
      sourceVersion: '2026.1',
      sourceRecordId: 'food-record-1',
      citation: 'Synthetic food fixture',
      licenseId: 'fixture-only',
      reviewStatus: CatalogReviewStatus.approved,
      reviewerId: 'reviewer-1',
      reviewedAt: reviewedAt,
    ),
    oilInclusion: OilInclusion.excluded,
    servings: [
      ServingDefinition(
        id: 'katori-1',
        label: '1 katori',
        unitCode: 'katori',
        gramsMinimum: 180,
        gramsMaximum: 220,
        confidence: 0.8,
      ),
    ],
  );
  return CatalogImportBundle(
    release: CatalogRelease(
      id: releaseId,
      version: '1.0.0',
      reviewStatus: CatalogReviewStatus.approved,
      contentChecksum: 'checksum-1',
      publishedAt: reviewedAt,
    ),
    foods: [food],
    recipes: [
      CatalogRecipe(
        id: 'recipe-1',
        releaseId: releaseId,
        nameEnglish: 'Lentil curry',
        nameRomanUrdu: 'Daal salan',
        synonyms: const ['Masoor salan'],
        ingredients: [
          RecipeIngredient(food: food, servingId: 'katori-1', quantity: 2),
        ],
        yieldServingsMinimum: 3,
        yieldServingsMaximum: 4,
        oilTreatment: RecipeOilTreatment.includedInIngredients,
        provenance: NutritionProvenance(
          sourceId: 'recipe-source',
          sourceVersion: '2026.1',
          sourceRecordId: 'recipe-record-1',
          citation: 'Synthetic recipe fixture',
          licenseId: 'fixture-only',
          reviewStatus: CatalogReviewStatus.approved,
          reviewerId: 'reviewer-1',
          reviewedAt: reviewedAt,
        ),
      ),
    ],
  );
}
