import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/ai_logging/application/ai_meal_draft_handoff.dart';
import 'package:sehat_coach/features/ai_logging/domain/ai_assisted_logging.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/catalog/domain/offline_food_catalog_repository.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/presentation/controllers/meal_logger_controller.dart';

void main() {
  test('confirmed candidates become an unsaved reviewed meal draft', () async {
    final food = _food();
    final catalog = _Catalog({'food-1': food});
    final mealDraft = _mealDraft(catalog);

    final result = await _handoff(catalog)
        .apply(confirmation: _confirmation(), mealDraft: mealDraft);

    expect(result, isA<AiMealDraftApplied>());
    expect(mealDraft.selected.single.food.id, 'food-1');
    expect(mealDraft.selected.single.serving.id, 'katori');
    expect(mealDraft.selected.single.quantity, 1.5);
    expect(mealDraft.savedEvent.value, isNull);
    expect(mealDraft.hasUnsavedMeal, isTrue);
    expect(mealDraft.aiProvenance.value?.requestId, 'request-1');
    expect(
      mealDraft.aiProvenance.value?.acceptedMatches.single.confidence,
      0.9,
    );
  });

  test('unverified serving leaves the existing meal draft unchanged', () async {
    final food = _food();
    final catalog = _Catalog({'food-1': food});
    final mealDraft = _mealDraft(catalog)..addFood(food);
    final before = List<SelectedMealFood>.of(mealDraft.selected);

    final result = await _handoff(catalog).apply(
      confirmation: _confirmation(servingId: 'unverified-serving'),
      mealDraft: mealDraft,
    );

    expect(result, isA<AiMealDraftNeedsManualReview>());
    expect(mealDraft.selected, orderedEquals(before));
  });

  test('missing catalog item causes no partial meal mutation', () async {
    final catalog = _Catalog({'food-1': _food()});
    final mealDraft = _mealDraft(catalog);
    final proposal = _proposal([
      _candidate(foodId: 'food-1'),
      _candidate(foodId: 'missing-food'),
    ]);

    final result = await _handoff(catalog).apply(
      confirmation: AiProposalConfirmation(
        proposal: proposal,
        acceptedCandidateIndexes: const [0, 1],
      ),
      mealDraft: mealDraft,
    );

    expect(result, isA<AiMealDraftNeedsManualReview>());
    expect(mealDraft.selected, isEmpty);
  });
}

AiMealDraftHandoff _handoff(_Catalog catalog) => AiMealDraftHandoff(
  catalog: catalog,
  clock: () => DateTime.utc(2026, 10, 25, 10, 5),
);

AiProposalConfirmation _confirmation({String servingId = 'katori'}) {
  final proposal = _proposal([_candidate(servingId: servingId)]);
  return AiProposalConfirmation(
    proposal: proposal,
    acceptedCandidateIndexes: const [0],
  );
}

AiLoggingProposal _proposal(List<AiFoodCandidate> candidates) =>
    AiLoggingProposal(
      requestId: 'request-1',
      schemaVersion: 'ai-log-v1',
      promptVersion: 'prompt-v1',
      modelId: 'backend-model',
      createdAtUtc: DateTime.utc(2026, 10, 25, 10),
      expiresAtUtc: DateTime.utc(2026, 10, 25, 10, 10),
      candidates: candidates,
    );

AiFoodCandidate _candidate({
  String foodId = 'food-1',
  String servingId = 'katori',
}) => AiFoodCandidate(
  catalogFoodId: foodId,
  servingId: servingId,
  quantity: 1.5,
  confidence: 0.9,
  explanation: 'Synthetic approved-catalog match',
);

MealLoggerController _mealDraft(_Catalog catalog) => MealLoggerController(
  catalog: catalog,
  logMeal: LogMealUseCase(
    session: _Session(),
    repository: _MealRepository(),
    ids: _Ids(),
    clock: _Clock(),
  ),
);

CatalogFood _food() => CatalogFood(
  id: 'food-1',
  releaseId: 'release-1',
  nameEnglish: 'Daal',
  nameRomanUrdu: 'Daal',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 120,
    proteinGrams: 8,
    carbohydrateGrams: 20,
    fatGrams: 2,
  ),
  provenance: NutritionProvenance(
    sourceId: 'synthetic-source',
    sourceVersion: '1',
    sourceRecordId: 'food-1',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-a',
    reviewedAt: DateTime.utc(2026, 10, 1),
  ),
  oilInclusion: OilInclusion.included,
  servings: [
    ServingDefinition(
      id: 'katori',
      label: 'Katori',
      unitCode: 'bowl',
      gramsMinimum: 140,
      gramsMaximum: 180,
      confidence: 0.8,
    ),
  ],
);

class _Catalog implements OfflineFoodCatalogRepository {
  _Catalog(this.foods);
  final Map<String, CatalogFood> foods;

  @override
  Future<CatalogFood?> findApprovedById(String foodId) async => foods[foodId];

  @override
  Future<List<CatalogFood>> search(FoodSearchQuery query) async => [];
}

class _Session implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _MealRepository implements MealEventRepository {
  @override
  Future<void> save(MealEvent event) async {}
}

class _Ids implements MealEventIdGenerator {
  @override
  String nextId() => 'meal-1';
}

class _Clock implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 25, 10);
}
