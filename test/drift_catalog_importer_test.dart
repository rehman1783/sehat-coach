import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart'
    hide CatalogFood, CatalogRecipe, CatalogRelease;
import 'package:sehat_coach/features/catalog/data/drift_catalog_importer.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_import.dart';
import 'package:sehat_coach/features/recipes/domain/catalog_recipe.dart';

class ImportVerifierFake implements CatalogImportVerificationPort {
  bool accepted = true;

  @override
  Future<bool> verify(CatalogImportBundle bundle) async => accepted;
}

CatalogImportBundle bundle({
  String releaseId = 'release-1',
  String checksum = 'checksum-1',
  String citation = 'Licensed fixture citation',
  List<String> synonyms = const ['Daal'],
  bool includeRecipe = false,
  List<String> recipeSynonyms = const ['Daal salan'],
}) {
  final reviewedAt = DateTime.utc(2026, 10, 22);
  final release = CatalogRelease(
    id: releaseId,
    version: '1.0.0',
    reviewStatus: CatalogReviewStatus.approved,
    contentChecksum: checksum,
    publishedAt: reviewedAt,
  );
  final food = CatalogFood(
    id: 'food-1',
    releaseId: releaseId,
    nameEnglish: 'Lentil bowl',
    nameRomanUrdu: 'Daal katori',
    synonyms: synonyms,
    nutrition: NutritionPerReference(
      referenceGrams: 100,
      caloriesKcal: 120,
      proteinGrams: 7,
      carbohydrateGrams: 18,
      fatGrams: 2,
    ),
    provenance: NutritionProvenance(
      sourceId: 'source-1',
      sourceVersion: '2026.1',
      sourceRecordId: 'record-1',
      citation: citation,
      licenseId: 'license-1',
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
    release: release,
    foods: [food],
    recipes: includeRecipe
        ? [
            CatalogRecipe(
              id: 'recipe-1',
              releaseId: releaseId,
              nameEnglish: 'Lentil curry',
              nameRomanUrdu: 'Daal salan',
              synonyms: recipeSynonyms,
              ingredients: [
                RecipeIngredient(
                  food: food,
                  servingId: 'katori-1',
                  quantity: 2,
                ),
              ],
              yieldServingsMinimum: 3,
              yieldServingsMaximum: 4,
              oilTreatment: RecipeOilTreatment.excludedFromCalculation,
              provenance: NutritionProvenance(
                sourceId: 'recipe-source-1',
                sourceVersion: '2026.1',
                sourceRecordId: 'recipe-record-1',
                citation: 'Synthetic recipe fixture',
                licenseId: 'fixture-only',
                reviewStatus: CatalogReviewStatus.approved,
                reviewerId: 'reviewer-1',
                reviewedAt: reviewedAt,
              ),
              region: 'Punjab',
              preparationVariant: 'home-style',
            ),
          ]
        : const [],
  );
}

void main() {
  late AppDatabase database;
  late ImportVerifierFake verifier;
  late DriftCatalogImporter importer;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    verifier = ImportVerifierFake();
    importer = DriftCatalogImporter(database, verifier);
  });
  tearDown(() => database.close());

  test('verified bundle imports complete relational graph', () async {
    expect(await importer.importBundle(bundle()), CatalogImportStatus.imported);
    expect(await database.select(database.catalogReleases).get(), hasLength(1));
    expect(
      await database.select(database.nutritionSources).get(),
      hasLength(1),
    );
    expect(await database.select(database.catalogFoods).get(), hasLength(1));
    expect(
      await database.select(database.catalogFoodSynonyms).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.catalogServingDefinitions).get(),
      hasLength(1),
    );
  });

  test('verified bundle atomically imports complete recipe graph', () async {
    expect(
      await importer.importBundle(bundle(includeRecipe: true)),
      CatalogImportStatus.imported,
    );
    expect(await database.select(database.catalogRecipes).get(), hasLength(1));
    expect(
      await database.select(database.catalogRecipeSynonyms).get(),
      hasLength(1),
    );
    final ingredients = await database
        .select(database.catalogRecipeIngredients)
        .get();
    expect(ingredients, hasLength(1));
    expect(ingredients.single.ingredientIndex, 0);
    expect(ingredients.single.foodId, 'food-1');
    expect(
      (await database.select(database.catalogRecipes).get())
          .single
          .oilTreatment,
      'excludedFromCalculation',
    );
  });

  test('failed recipe child insert rolls back the complete release', () async {
    final invalid = bundle(
      includeRecipe: true,
      recipeSynonyms: const ['Daal salan', ' daal salan '],
    );
    await expectLater(
      importer.importBundle(invalid),
      throwsA(isA<Exception>()),
    );
    expect(await database.select(database.catalogReleases).get(), isEmpty);
    expect(await database.select(database.catalogFoods).get(), isEmpty);
    expect(await database.select(database.catalogRecipes).get(), isEmpty);
    expect(await database.select(database.nutritionSources).get(), isEmpty);
  });

  test('unverified package makes no database changes', () async {
    verifier.accepted = false;
    await expectLater(
      importer.importBundle(bundle()),
      throwsA(isA<CatalogPackageVerificationFailed>()),
    );
    expect(await database.select(database.catalogReleases).get(), isEmpty);
    expect(await database.select(database.nutritionSources).get(), isEmpty);
  });

  test('same release and checksum is idempotent', () async {
    expect(await importer.importBundle(bundle()), CatalogImportStatus.imported);
    expect(
      await importer.importBundle(bundle()),
      CatalogImportStatus.alreadyPresent,
    );
    expect(await database.select(database.catalogFoods).get(), hasLength(1));
  });

  test('release ID cannot be reused with different content', () async {
    await importer.importBundle(bundle());
    await expectLater(
      importer.importBundle(bundle(checksum: 'changed-checksum')),
      throwsA(isA<ImmutableCatalogReleaseViolation>()),
    );
    expect(
      (await database.select(database.catalogReleases).get())
          .single
          .contentChecksum,
      'checksum-1',
    );
  });

  test('source metadata conflict rolls back entire later release', () async {
    await importer.importBundle(bundle());
    await expectLater(
      importer.importBundle(
        bundle(
          releaseId: 'release-2',
          checksum: 'checksum-2',
          citation: 'Conflicting citation',
        ),
      ),
      throwsA(isA<NutritionSourceContinuityViolation>()),
    );
    expect(await database.select(database.catalogReleases).get(), hasLength(1));
    expect(await database.select(database.catalogFoods).get(), hasLength(1));
  });

  test('failed child insert rolls back source and release', () async {
    final invalid = bundle(synonyms: const ['Daal', ' daal ']);
    await expectLater(
      importer.importBundle(invalid),
      throwsA(isA<Exception>()),
    );
    expect(await database.select(database.catalogReleases).get(), isEmpty);
    expect(await database.select(database.nutritionSources).get(), isEmpty);
    expect(await database.select(database.catalogFoods).get(), isEmpty);
  });
}
