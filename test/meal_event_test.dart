import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';

class MealSessionFake implements AuthenticatedOwnerSession {
  MealSessionFake(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class MealRepositoryFake implements MealEventRepository {
  final saved = <MealEvent>[];
  Object? failure;

  @override
  Future<void> save(MealEvent event) async {
    if (failure case final error?) throw error;
    saved.add(event);
  }
}

class MealIdsFake implements MealEventIdGenerator {
  String value = 'meal-1';

  @override
  String nextId() => value;
}

class MealClockFake implements MealClock {
  final value = DateTime.utc(2026, 10, 22, 12);

  @override
  DateTime nowUtc() => value;
}

class MealRevisionReaderFake implements ActiveMealRevisionReader {
  int? revision = 1;

  @override
  Future<int?> readActiveRevision({
    required String ownerId,
    required String eventId,
  }) async => revision;
}

CatalogFood mealFood() => CatalogFood(
  id: 'food-1',
  releaseId: 'release-1',
  nameEnglish: 'Fixture food',
  nameRomanUrdu: 'Fixture khana',
  synonyms: const [],
  nutrition: NutritionPerReference(
    referenceGrams: 100,
    caloriesKcal: 200,
    proteinGrams: 10,
    carbohydrateGrams: 30,
    fatGrams: 5,
  ),
  provenance: NutritionProvenance(
    sourceId: 'source-1',
    sourceVersion: '2026.1',
    sourceRecordId: 'record-1',
    citation: 'Synthetic test fixture',
    licenseId: 'test-only',
    reviewStatus: CatalogReviewStatus.approved,
    reviewerId: 'reviewer-1',
    reviewedAt: DateTime.utc(2026, 10, 22),
  ),
  oilInclusion: OilInclusion.excluded,
  servings: [
    ServingDefinition(
      id: 'katori',
      label: '1 katori',
      unitCode: 'katori',
      gramsMinimum: 150,
      gramsMaximum: 200,
      confidence: 0.75,
    ),
  ],
);

MealCalculationSnapshot calculation() =>
    const DeterministicNutritionCalculator().calculateMeal([
      MealItemInput(food: mealFood(), servingId: 'katori', quantity: 1),
    ]);

void main() {
  test('logs meal for stable authenticated owner with audit inputs', () async {
    final repository = MealRepositoryFake();
    final clock = MealClockFake();
    final event =
        await LogMealUseCase(
          session: MealSessionFake('owner-a'),
          repository: repository,
          ids: MealIdsFake(),
          clock: clock,
        ).execute(
          LogMealCommand(
            mealType: MealType.lunch,
            occurredAtUtc: DateTime.utc(2026, 10, 22, 8, 30),
            timezoneOffsetMinutes: 300,
            rawUserInput: '1 katori daal',
            calculation: calculation(),
          ),
        );

    expect(event.id, 'meal-1');
    expect(event.ownerId, 'owner-a');
    expect(event.createdAtUtc, clock.value);
    expect(event.rawUserInput, '1 katori daal');
    expect(event.calculation.items.single.foodId, 'food-1');
    expect(repository.saved.single, same(event));
  });

  test('repository failure does not report a saved event', () async {
    final repository = MealRepositoryFake()
      ..failure = StateError('disk failed');
    await expectLater(
      LogMealUseCase(
        session: MealSessionFake('owner-a'),
        repository: repository,
        ids: MealIdsFake(),
        clock: MealClockFake(),
      ).execute(
        LogMealCommand(
          mealType: MealType.dinner,
          occurredAtUtc: DateTime.utc(2026, 10, 22),
          timezoneOffsetMinutes: 300,
          calculation: calculation(),
        ),
      ),
      throwsStateError,
    );
    expect(repository.saved, isEmpty);
  });

  test('meal metadata rejects invalid timestamps, offsets and IDs', () async {
    expect(
      () => LogMealCommand(
        mealType: MealType.other,
        occurredAtUtc: DateTime(2026, 10, 22),
        timezoneOffsetMinutes: 300,
        calculation: calculation(),
      ),
      throwsArgumentError,
    );
    expect(
      () => LogMealCommand(
        mealType: MealType.other,
        occurredAtUtc: DateTime.utc(2026, 10, 22),
        timezoneOffsetMinutes: 900,
        calculation: calculation(),
      ),
      throwsArgumentError,
    );
    final ids = MealIdsFake()..value = ' ';
    await expectLater(
      LogMealUseCase(
        session: MealSessionFake('owner-a'),
        repository: MealRepositoryFake(),
        ids: ids,
        clock: MealClockFake(),
      ).execute(
        LogMealCommand(
          mealType: MealType.other,
          occurredAtUtc: DateTime.utc(2026, 10, 22),
          timezoneOffsetMinutes: 300,
          calculation: calculation(),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('correction metadata cannot self-reference or use invalid revision', () {
    expect(
      () => MealEvent(
        id: 'meal-1',
        ownerId: 'owner-a',
        mealType: MealType.lunch,
        occurredAtUtc: DateTime.utc(2026, 10, 22),
        timezoneOffsetMinutes: 300,
        createdAtUtc: DateTime.utc(2026, 10, 22),
        calculation: calculation(),
        rawUserInput: '',
        supersedesEventId: 'meal-1',
      ),
      throwsArgumentError,
    );
    expect(
      () => MealEvent(
        id: 'meal-2',
        ownerId: 'owner-a',
        mealType: MealType.lunch,
        occurredAtUtc: DateTime.utc(2026, 10, 22),
        timezoneOffsetMinutes: 300,
        createdAtUtc: DateTime.utc(2026, 10, 22),
        calculation: calculation(),
        rawUserInput: '',
        revision: 0,
      ),
      throwsArgumentError,
    );
  });

  test(
    'correction use case creates a new revision without overwrite',
    () async {
      final repository = MealRepositoryFake();
      final ids = MealIdsFake()..value = 'meal-2';
      final correction =
          await CorrectMealUseCase(
            session: MealSessionFake('owner-a'),
            revisions: MealRevisionReaderFake(),
            repository: repository,
            ids: ids,
            clock: MealClockFake(),
          ).execute(
            CorrectMealCommand(
              originalEventId: 'meal-1',
              mealType: MealType.dinner,
              occurredAtUtc: DateTime.utc(2026, 10, 22, 14),
              timezoneOffsetMinutes: 300,
              calculation: calculation(),
              rawUserInput: 'corrected meal',
            ),
          );

      expect(correction.id, 'meal-2');
      expect(correction.supersedesEventId, 'meal-1');
      expect(correction.revision, 2);
      expect(repository.saved.single, same(correction));
    },
  );

  test('cannot correct a missing or already superseded meal', () async {
    final revisions = MealRevisionReaderFake()..revision = null;
    await expectLater(
      CorrectMealUseCase(
        session: MealSessionFake('owner-a'),
        revisions: revisions,
        repository: MealRepositoryFake(),
        ids: MealIdsFake(),
        clock: MealClockFake(),
      ).execute(
        CorrectMealCommand(
          originalEventId: 'meal-1',
          mealType: MealType.lunch,
          occurredAtUtc: DateTime.utc(2026, 10, 22),
          timezoneOffsetMinutes: 300,
          calculation: calculation(),
        ),
      ),
      throwsA(isA<MealCorrectionUnavailable>()),
    );
  });
}
