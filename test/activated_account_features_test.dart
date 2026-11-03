import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_repository.dart';
import 'package:sehat_coach/features/catalog/domain/catalog_food.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';
import 'package:sehat_coach/features/meals/domain/meal_event.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/recipes/domain/offline_recipe_catalog_repository.dart';
import 'package:sehat_coach/features/sync/data/drift_local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_cycle_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_pull_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_upload_coordinator.dart';

void main() {
  test('sync is bound to the activated owner database', () async {
    final harness = await _Harness.create('owner-a');
    addTearDown(harness.dispose);
    final database = await harness.service.open('owner-a');
    final local = DriftLocalChangeStore(database, 'owner-a');
    await local.commit(
      ownerId: 'owner-a',
      operationId: 'operation-1',
      entityType: 'profile',
      entityKey: 'main',
      expectedRevision: 0,
      payload: const {'ready': true},
    );
    final transport = _SyncTransport();
    final features = ActivatedAccountFeatures(
      databases: harness.service,
      ownerSession: harness.session,
      syncUpload: transport,
      syncPull: transport,
    );

    final triggers = await features.createSyncTriggers(const Stream.empty());
    final result = await triggers.triggerManual();
    final status = await features.createSyncStatus();

    expect(result.reason, SyncCycleStopReason.complete);
    expect(result.uploaded, 1);
    expect(result.pulled, 1);
    expect(await local.pending('owner-a'), isEmpty);
    expect(status.canRetry, isTrue);
    expect(transport.uploadedOwners, ['owner-a']);
    expect(transport.pulledOwners, ['owner-a']);
    expect((await local.read('owner-a', 'remote', 'remote-1'))?.revision, 1);
  });

  test('partial or missing sync transport never creates execution', () async {
    final harness = await _Harness.create('owner-a');
    addTearDown(harness.dispose);
    await expectLater(
      ActivatedAccountFeatures(
        databases: harness.service,
        ownerSession: harness.session,
      ).createSyncExecution(),
      throwsStateError,
    );
    await expectLater(
      ActivatedAccountFeatures(
        databases: harness.service,
        ownerSession: harness.session,
        syncUpload: _SyncTransport(),
      ).createSyncExecution(),
      throwsStateError,
    );
  });

  test(
    'composes meal logger against the authenticated owner database',
    () async {
      final harness = await _Harness.create('owner-a');
      addTearDown(harness.dispose);
      final features = ActivatedAccountFeatures(
        databases: harness.service,
        ownerSession: harness.session,
        mealIds: _IdsFake(),
        mealClock: _ClockFake(),
      );

      final controller = await features.createMealLogger();
      expect(controller.userFoodEntry, isNotNull);
      controller.addFood(_food());
      final event = await controller.save(
        occurredAt: DateTime(2026, 10, 22, 13),
        rawUserInput: 'fixture meal',
      );

      expect(event?.ownerId, 'owner-a');
      expect(harness.service.activeOwnerId, 'owner-a');
      final database = await harness.service.open('owner-a');
      expect(
        (await database.select(database.mealEvents).get()).single.eventId,
        'meal-1',
      );
      expect(
        await database.select(database.syncOutboxEntries).get(),
        hasLength(1),
      );
      final history = await features.createMealHistory();
      final summary = await history
          .watchDay(
            calendarDay: DateTime(2026, 10, 22),
            timezoneOffsetMinutes: 300,
          )
          .first;
      expect(summary.meals.single.eventId, 'meal-1');
      final correctionController = await features.createMealCorrection(
        event!.id,
      );
      expect(correctionController.draft.rawUserInput, 'fixture meal');
      final correction = await correctionController.save(
        'corrected fixture meal',
      );
      expect(correction?.id, 'meal-2');
      expect(correction?.revision, 2);
      expect(correction?.supersedesEventId, 'meal-1');
      final water = await features.createWaterTracker(
        initialDay: DateTime.now(),
      );
      expect(await water.quickAdd(250), isNotNull);
      expect(await database.select(database.waterEvents).get(), hasLength(1));
      final recipes = await features.createRecipeCatalog();
      expect(await recipes.search(RecipeSearchQuery('fixture')), isEmpty);
      final saveHealthPlan = await features.createHealthMealPlanSaver();
      await saveHealthPlan.execute(_healthPlan());
      final healthPlans = await features.createHealthPlanRepository();
      expect(
        (await healthPlans.readPlan('owner-a', 'plan-1'))?.originalText,
        'Immutable synthetic original',
      );
    },
  );

  test('cannot compose over a database activated for another owner', () async {
    final harness = await _Harness.create('owner-a');
    addTearDown(harness.dispose);
    await harness.service.open('owner-b');

    await expectLater(
      ActivatedAccountFeatures(
        databases: harness.service,
        ownerSession: harness.session,
      ).createMealLogger(),
      throwsStateError,
    );
    expect(harness.service.activeOwnerId, 'owner-b');
  });

  test(
    'composes Bachat from the profile and canonical verified city',
    () async {
      final harness = await _Harness.create('owner-a');
      addTearDown(harness.dispose);
      final repository = _BachatRepository();

      final controller =
          await ActivatedAccountFeatures(
            databases: harness.service,
            ownerSession: harness.session,
          ).createBachatPlanner(
            profile: OnboardingState(city: ' islamabad '),
            cities: _cities(),
            repository: repository,
          );

      expect(controller.cityId, 'islamabad');
      expect(controller.cityName, 'Islamabad');
      await controller.loadAndPlan();
      expect(repository.requestedCityId, 'islamabad');
    },
  );

  test(
    'Bachat composition rejects unsupported and Other city profiles',
    () async {
      final harness = await _Harness.create('owner-a');
      addTearDown(harness.dispose);
      final features = ActivatedAccountFeatures(
        databases: harness.service,
        ownerSession: harness.session,
      );

      for (final profile in [
        OnboardingState(city: 'Other city'),
        OnboardingState(city: 'Unverified City'),
        OnboardingState(city: 'Islamabad', countryCode: 'GB'),
      ]) {
        await expectLater(
          features.createBachatPlanner(
            profile: profile,
            cities: _cities(),
            repository: _BachatRepository(),
          ),
          throwsStateError,
        );
      }
    },
  );
}

class _SyncTransport implements SyncUploadTransport, SyncPullTransport {
  final uploadedOwners = <String>[];
  final pulledOwners = <String>[];

  @override
  Future<UploadReceipt> upload(OutboxChange change) async {
    uploadedOwners.add(change.ownerId);
    return UploadReceipt(
      ownerId: change.ownerId,
      operationId: change.operationId,
      serverRevision: change.newRevision,
    );
  }

  @override
  Future<PullPage> fetch({
    required String ownerId,
    required String? cursor,
  }) async {
    pulledOwners.add(ownerId);
    return PullPage(
      ownerId: ownerId,
      requestCursor: cursor,
      nextCursor: 'cursor-1',
      changes: [
        RemoteChange(
          ownerId: ownerId,
          entityType: 'remote',
          entityKey: 'remote-1',
          serverRevision: 1,
          deleted: false,
          payload: const {'value': 1},
        ),
      ],
      hasMore: false,
    );
  }
}

PublishedCityConfiguration _cities() => PublishedCityConfiguration(
  releaseId: 'cities-1',
  version: '1',
  countryCode: 'PK',
  contentChecksum: 'fixture-checksum',
  publishedAtUtc: DateTime.utc(2026, 10, 25),
  cities: [
    CityConfigurationEntry(
      cityId: 'islamabad',
      displayName: 'Islamabad',
      sortOrder: 1,
    ),
    CityConfigurationEntry(
      cityId: 'other',
      displayName: 'Other city',
      sortOrder: 2,
      isOther: true,
    ),
  ],
);

class _BachatRepository implements BachatRepository {
  String? requestedCityId;

  @override
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(String cityId) async {
    requestedCityId = cityId;
    return const [];
  }
}

class _Harness {
  _Harness(this.directory, this.service, this.session);

  final Directory directory;
  final AccountDatabaseService service;
  final AuthenticatedOwnerSession session;

  static Future<_Harness> create(String ownerId) async {
    final directory = await Directory.systemTemp.createTemp('sehat-features-');
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(_Vault()),
    );
    return _Harness(directory, service, _SessionFake(ownerId));
  }

  Future<void> dispose() async {
    await service.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

class _Vault implements AccountKeyVault {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String ownerId) async => values[ownerId];

  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async =>
      values.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));

  @override
  Future<void> delete(String ownerId) async => values.remove(ownerId);
}

class _SessionFake implements AuthenticatedOwnerSession {
  const _SessionFake(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class _IdsFake implements MealEventIdGenerator {
  var value = 0;

  @override
  String nextId() => 'meal-${++value}';
}

class _ClockFake implements MealClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22, 12);
}

CatalogFood _food() => CatalogFood(
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

HealthMealPlan _healthPlan() => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Synthetic plan',
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Immutable synthetic original',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'instruction-1',
      label: 'Breakfast',
      instructions: 'Synthetic fixture instruction',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);
