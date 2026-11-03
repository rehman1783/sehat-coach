import '../../features/account/domain/create_profile_use_case.dart';
import '../../features/bachat/domain/bachat_repository.dart';
import '../../features/bachat/presentation/controllers/bachat_planner_controller.dart';
import '../../features/catalog/data/drift_offline_food_catalog_repository.dart';
import '../../features/catalog/domain/catalog_food.dart';
import '../../features/custom_foods/data/drift_user_food_record_repository.dart';
import '../../features/custom_foods/data/drift_custom_recipe_repository.dart';
import '../../features/custom_foods/data/secure_user_food_support.dart';
import '../../features/custom_foods/domain/user_food_commands.dart';
import '../../features/custom_foods/domain/user_food_records.dart';
import '../../features/custom_foods/domain/custom_recipe_commands.dart';
import '../../features/custom_foods/presentation/controllers/custom_recipe_entry_controller.dart';
import '../../features/custom_foods/presentation/controllers/user_food_entry_controller.dart';
import '../../features/fasting/data/local_change_fasting_preferences_repository.dart';
import '../../features/fasting/domain/fasting_preferences.dart';
import '../../features/fasting/presentation/controllers/fasting_settings_controller.dart';
import '../../features/entitlements/data/drift_verified_entitlement_cache.dart';
import '../../features/entitlements/domain/verified_entitlement_cache.dart';
import '../../features/home/presentation/controllers/daily_dashboard_controller.dart';
import '../../features/health_plans/data/local_change_health_plan_repository.dart';
import '../../features/health_plans/data/file_selector_health_plan_document_picker.dart';
import '../../features/health_plans/domain/health_plan_repository.dart';
import '../../features/health_plans/domain/health_plan_capture.dart';
import '../../features/health_plans/domain/health_plan_adherence.dart';
import '../../features/health_plans/domain/health_plan_reminder.dart';
import '../../features/health_plans/presentation/controllers/health_plan_controller.dart';
import '../../features/meals/data/drift_meal_history_repository.dart';
import '../../features/meals/data/drift_meal_event_repository.dart';
import '../../features/meals/data/secure_meal_event_support.dart';
import '../../features/meals/domain/meal_event.dart';
import '../../features/meals/domain/meal_history.dart';
import '../../features/meals/domain/nutrition_calculator.dart';
import '../../features/meals/presentation/controllers/meal_logger_controller.dart';
import '../../features/meals/presentation/controllers/meal_correction_controller.dart';
import '../../features/recipes/data/drift_offline_recipe_catalog_repository.dart';
import '../../features/recipes/domain/offline_recipe_catalog_repository.dart';
import '../../features/recipes/presentation/controllers/recipe_meal_logger_controller.dart';
import '../../features/sync/data/drift_sync_queue_status_repository.dart';
import '../../features/sync/data/drift_local_change_store.dart';
import '../../features/sync/data/drift_pull_apply_store.dart';
import '../../features/sync/domain/sync_cycle_coordinator.dart';
import '../../features/sync/domain/sync_execution_coordinator.dart';
import '../../features/sync/domain/sync_pull_coordinator.dart';
import '../../features/sync/domain/sync_upload_coordinator.dart';
import '../../features/sync/domain/sync_trigger_coordinator.dart';
import '../../features/sync/presentation/controllers/sync_status_controller.dart';
import '../../features/water/data/drift_water_repository.dart';
import '../../features/water/data/drift_hydration_preferences_repository.dart';
import '../../features/water/data/secure_water_event_support.dart';
import '../../features/water/domain/water_tracking.dart';
import '../../features/water/domain/hydration_preferences.dart';
import '../../features/water/presentation/controllers/water_tracker_controller.dart';
import '../../features/weight/data/drift_weight_repository.dart';
import '../../features/weight/data/secure_weight_event_support.dart';
import '../../features/weight/domain/weight_tracking.dart';
import '../../features/weight/presentation/controllers/weight_tracker_controller.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/onboarding/domain/onboarding_profile_handoff.dart';
import '../../features/onboarding/data/repositories/drift_profile_repository.dart';
import '../../features/location/domain/city_configuration.dart';
import '../data/local/account_database_service.dart';
import '../data/local/app_database.dart' as db;

/// Application composition root for features that require a verified account.
///
/// It resolves the database through the same stable owner session used by each
/// command, preventing UI code from choosing or caching an account identifier.
class ActivatedAccountFeatures {
  factory ActivatedAccountFeatures({
    required AccountDatabaseService databases,
    required AuthenticatedOwnerSession ownerSession,
    MealEventIdGenerator? mealIds,
    MealClock mealClock = const SystemMealClock(),
    WaterEventIdGenerator? waterIds,
    WaterClock waterClock = const SystemWaterClock(),
    UserFoodIdGenerator? userFoodIds,
    UserFoodClock userFoodClock = const SystemUserFoodClock(),
    CustomRecipeIdGenerator? customRecipeIds,
    CustomRecipeClock customRecipeClock = const SystemCustomRecipeClock(),
    WeightEventIdGenerator? weightIds,
    WeightClock weightClock = const SystemWeightClock(),
    HealthPlanIdGenerator? healthPlanIds,
    HealthPlanClock healthPlanClock = const SystemHealthPlanClock(),
    SyncUploadTransport? syncUpload,
    SyncPullTransport? syncPull,
  }) => ActivatedAccountFeatures._(
    databases: databases,
    ownerSession: ownerSession,
    mealIds: mealIds ?? SecureMealEventIdGenerator(),
    mealClock: mealClock,
    waterIds: waterIds ?? SecureWaterEventIdGenerator(),
    waterClock: waterClock,
    userFoodIds: userFoodIds ?? SecureUserFoodIdGenerator(),
    userFoodClock: userFoodClock,
    customRecipeIds: customRecipeIds ?? SecureCustomRecipeIdGenerator(),
    customRecipeClock: customRecipeClock,
    weightIds: weightIds ?? SecureWeightEventIdGenerator(),
    weightClock: weightClock,
    healthPlanIds: healthPlanIds ?? SecureHealthPlanIdGenerator(),
    healthPlanClock: healthPlanClock,
    syncUpload: syncUpload,
    syncPull: syncPull,
  );

  ActivatedAccountFeatures._({
    required this._databases,
    required this._ownerSession,
    required this._mealIds,
    required this._mealClock,
    required this._waterIds,
    required this._waterClock,
    required this._userFoodIds,
    required this._userFoodClock,
    required this._customRecipeIds,
    required this._customRecipeClock,
    required this._weightIds,
    required this._weightClock,
    required this._healthPlanIds,
    required this._healthPlanClock,
    required this._syncUpload,
    required this._syncPull,
  });

  final AccountDatabaseService _databases;
  final AuthenticatedOwnerSession _ownerSession;
  final MealEventIdGenerator _mealIds;
  final MealClock _mealClock;
  final WaterEventIdGenerator _waterIds;
  final WaterClock _waterClock;
  final UserFoodIdGenerator _userFoodIds;
  final UserFoodClock _userFoodClock;
  final CustomRecipeIdGenerator _customRecipeIds;
  final CustomRecipeClock _customRecipeClock;
  final WeightEventIdGenerator _weightIds;
  final WeightClock _weightClock;
  final HealthPlanIdGenerator _healthPlanIds;
  final HealthPlanClock _healthPlanClock;
  final SyncUploadTransport? _syncUpload;
  final SyncPullTransport? _syncPull;

  /// Creates the authenticated onboarding boundary against the currently
  /// verified owner's encrypted database. The returned handoff is one-shot so
  /// repeated CTA taps cannot enqueue duplicate profile revisions.
  Future<OnboardingProfileHandoff> createOnboardingProfileHandoff({
    required Future<void> Function(OnboardingState profile) onCommitted,
  }) {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return OnboardingProfileHandoff(
        CreateProfileUseCase(
          DriftProfileRepository(database, ownerId),
          _ownerSession,
        ),
        onCommitted,
      );
    });
  }

  /// Creates a loader bound to the active encrypted owner database. The
  /// loader revalidates the session owner every time it reads.
  Future<LoadProfileUseCase> createProfileLoader() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return LoadProfileUseCase(
        DriftProfileRepository(database, ownerId),
        _ownerSession,
      );
    });
  }

  Future<MealLoggerController> createMealLogger() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final userFoods = DriftUserFoodRecordRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      return MealLoggerController(
        catalog: DriftOfflineFoodCatalogRepository(database),
        userFoodEntry: _createUserFoodEntry(userFoods),
        customFoods: userFoods,
        logMeal: LogMealUseCase(
          session: _ownerSession,
          repository: DriftMealEventRepository(
            database: database,
            expectedOwnerId: ownerId,
          ),
          ids: _mealIds,
          clock: _mealClock,
        ),
      );
    });
  }

  UserFoodEntryController _createUserFoodEntry(
    UserFoodRecordRepository repository,
  ) {
    return UserFoodEntryController(
      createCustomFood: CreateCustomFoodUseCase(
        session: _ownerSession,
        repository: repository,
        ids: _userFoodIds,
        clock: _userFoodClock,
      ),
      saveNotFound: SaveFoodNotFoundUseCase(
        session: _ownerSession,
        repository: repository,
        ids: _userFoodIds,
        clock: _userFoodClock,
      ),
    );
  }

  Future<OfflineRecipeCatalogRepository> createRecipeCatalog() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return DriftOfflineRecipeCatalogRepository(database);
    });
  }

  Future<RecipeMealLoggerController> createRecipeMealLogger() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final catalog = DriftOfflineFoodCatalogRepository(database);
      final customFoods = DriftUserFoodRecordRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      final customRecipes = DriftCustomRecipeRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      return RecipeMealLoggerController(
        catalog: DriftOfflineRecipeCatalogRepository(database),
        customRecipes: customRecipes,
        customRecipeEntry: CustomRecipeEntryController(
          catalog: catalog,
          customFoods: customFoods,
          createRecipe: CreateCustomRecipeUseCase(
            session: _ownerSession,
            repository: customRecipes,
            ids: _customRecipeIds,
            clock: _customRecipeClock,
          ),
        ),
        logMeal: LogMealUseCase(
          session: _ownerSession,
          repository: DriftMealEventRepository(
            database: database,
            expectedOwnerId: ownerId,
          ),
          ids: _mealIds,
          clock: _mealClock,
        ),
      );
    });
  }

  Future<CorrectMealUseCase> createMealCorrector() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final repository = DriftMealEventRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      return CorrectMealUseCase(
        session: _ownerSession,
        revisions: repository,
        repository: repository,
        ids: _mealIds,
        clock: _mealClock,
      );
    });
  }

  Future<MealCorrectionController> createMealCorrection(String eventId) {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final repository = DriftMealEventRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      final draft = await repository.readActiveDraft(
        ownerId: ownerId,
        eventId: eventId,
      );
      if (draft == null) throw const MealCorrectionUnavailable();
      final catalog = DriftOfflineFoodCatalogRepository(database);
      final customFoods = DriftUserFoodRecordRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      final customRecipes = DriftCustomRecipeRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      final servingCatalog = <int, CatalogFood>{};
      for (final indexed in draft.calculation.items.indexed) {
        final (index, item) = indexed;
        if (item.catalogItemType != CatalogItemType.food) continue;
        final food = await catalog.findApprovedByReleaseAndId(
          releaseId: item.catalogReleaseId,
          foodId: item.foodId,
        );
        if (food != null) servingCatalog[index] = food;
      }
      return MealCorrectionController(
        draft: draft,
        servingCatalog: servingCatalog,
        replacementCatalog: catalog,
        customFoodCatalog: customFoods,
        replacementRecipeCatalog: DriftOfflineRecipeCatalogRepository(database),
        customRecipeCatalog: customRecipes,
        correctMeal: CorrectMealUseCase(
          session: _ownerSession,
          revisions: repository,
          repository: repository,
          ids: _mealIds,
          clock: _mealClock,
        ),
      );
    });
  }

  Future<MealHistoryRepository> createMealHistory() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return DriftMealHistoryRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
    });
  }

  Future<DailyDashboardController> createDailyDashboard({
    DateTime? initialDay,
  }) async => DailyDashboardController(
    history: await createMealHistory(),
    initialDay: initialDay,
  );

  Future<SyncStatusController> createSyncStatus() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final execution = _createSyncExecution(database, ownerId);
      return SyncStatusController(
        ownerId,
        DriftSyncQueueStatusRepository(database, ownerId),
        execution?.run,
      );
    });
  }

  /// Creates sync only for the currently activated encrypted database owner.
  /// Both transports must be supplied together; otherwise sync remains an
  /// explicitly unavailable optional capability.
  Future<SyncExecutionCoordinator> createSyncExecution() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final execution = _createSyncExecution(database, ownerId);
      if (execution == null) {
        throw StateError('Trusted synchronization transport is unavailable');
      }
      return execution;
    });
  }

  Future<SyncTriggerCoordinator> createSyncTriggers(
    Stream<bool> networkLink, {
    SyncResultListener? onResult,
    SyncErrorListener? onError,
  }) async => SyncTriggerCoordinator(
    networkLink,
    await createSyncExecution(),
    onResult: onResult,
    onError: onError,
  );

  SyncExecutionCoordinator? _createSyncExecution(
    db.AppDatabase database,
    String ownerId,
  ) {
    final upload = _syncUpload;
    final pull = _syncPull;
    if (upload == null && pull == null) return null;
    if (upload == null || pull == null) {
      throw StateError('Upload and pull transports must be supplied together');
    }
    return SyncExecutionCoordinator(
      SyncCycleCoordinator(
        SyncUploadCoordinator(
          _ownerSession,
          DriftLocalChangeStore(database, ownerId),
          upload,
        ),
        SyncPullCoordinator(
          _ownerSession,
          DriftPullApplyStore(database, ownerId),
          pull,
        ),
      ),
    );
  }

  Future<VerifiedEntitlementCache> createVerifiedEntitlementCache() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return DriftVerifiedEntitlementCache(
        database: database,
        expectedOwnerId: ownerId,
      );
    });
  }

  Future<FastingPreferencesRepository> createFastingPreferences() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return LocalChangeFastingPreferencesRepository(
        DriftLocalChangeStore(database, ownerId),
        ownerId,
      );
    });
  }

  Future<SaveFastingPreferencesUseCase> createFastingPreferencesSaver() async =>
      SaveFastingPreferencesUseCase(
        session: _ownerSession,
        repository: await createFastingPreferences(),
      );

  Future<FastingSettingsController> createFastingSettings(
    OnboardingState profile,
  ) async {
    final repository = await createFastingPreferences();
    return FastingSettingsController(
      profile,
      repository,
      SaveFastingPreferencesUseCase(
        session: _ownerSession,
        repository: repository,
      ),
    );
  }

  /// Builds Bachat only when the signed-in profile maps to an enabled,
  /// canonical city from the verified city release.
  ///
  /// The price repository is deliberately injected. This composition layer
  /// never substitutes fixture prices or turns a free-form "Other city" value
  /// into a supported market.
  Future<BachatPlannerController> createBachatPlanner({
    required OnboardingState profile,
    required PublishedCityConfiguration cities,
    required BachatRepository repository,
  }) => _ownerSession.withOwner((_) async {
    if (profile.countryCode.trim().toUpperCase() != cities.countryCode) {
      throw StateError('Bachat is unavailable outside the verified market');
    }
    final normalizedCity = profile.city.trim().toLowerCase();
    final matches = cities.enabledCities.where(
      (city) =>
          !city.isOther &&
          city.displayName.trim().toLowerCase() == normalizedCity,
    );
    if (matches.length != 1) {
      throw StateError('No verified Bachat city matches this profile');
    }
    final city = matches.single;
    return BachatPlannerController(
      cityId: city.cityId,
      cityName: city.displayName,
      source: repository,
    );
  });

  Future<HealthPlanRepository> createHealthPlanRepository() {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      return LocalChangeHealthPlanRepository(
        DriftLocalChangeStore(database, ownerId),
        ownerId,
      );
    });
  }

  Future<CreateHealthMealPlan> createHealthMealPlanSaver() async =>
      CreateHealthMealPlan(
        session: _ownerSession,
        repository: await createHealthPlanRepository(),
      );

  Future<SaveApprovedHealthPlanChange> createHealthPlanApprovalSaver() async =>
      SaveApprovedHealthPlanChange(
        session: _ownerSession,
        repository: await createHealthPlanRepository(),
      );

  Future<SaveHealthPlanRevision> createHealthPlanRevisionSaver() async =>
      SaveHealthPlanRevision(
        session: _ownerSession,
        repository: await createHealthPlanRepository(),
      );

  Future<LogHealthPlanAdherence> createHealthPlanAdherenceLogger() async =>
      LogHealthPlanAdherence(
        session: _ownerSession,
        repository: await createHealthPlanRepository(),
        ids: _healthPlanIds,
        clock: _healthPlanClock,
      );

  Future<CorrectHealthPlanAdherence>
  createHealthPlanAdherenceCorrector() async => CorrectHealthPlanAdherence(
    session: _ownerSession,
    repository: await createHealthPlanRepository(),
    ids: _healthPlanIds,
    clock: _healthPlanClock,
  );

  Future<SaveHealthPlanReminderPreferences>
  createHealthPlanReminderSaver() async => SaveHealthPlanReminderPreferences(
    session: _ownerSession,
    repository: await createHealthPlanRepository(),
  );

  Future<HealthPlanController> createHealthPlanController() {
    return _ownerSession.withOwner((ownerId) async {
      final repository = await createHealthPlanRepository();
      return HealthPlanController(
        ownerId: ownerId,
        planCreator: CreateHealthMealPlan(
          session: _ownerSession,
          repository: repository,
        ),
        planLoader: ListHealthMealPlans(
          session: _ownerSession,
          repository: repository,
        ),
        idSource: _healthPlanIds,
        timeSource: _healthPlanClock,
        adherenceLogger: LogHealthPlanAdherence(
          session: _ownerSession,
          repository: repository,
          ids: _healthPlanIds,
          clock: _healthPlanClock,
        ),
        adherenceCorrector: CorrectHealthPlanAdherence(
          session: _ownerSession,
          repository: repository,
          ids: _healthPlanIds,
          clock: _healthPlanClock,
        ),
        adherenceRepository: repository,
        reminderSaver: SaveHealthPlanReminderPreferences(
          session: _ownerSession,
          repository: repository,
        ),
        documentPickerSource: const FileSelectorHealthPlanDocumentPicker(),
      );
    });
  }

  Future<WaterTrackerController> createWaterTracker({DateTime? initialDay}) {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final repository = DriftWaterRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      final preferences = DriftHydrationPreferencesRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      return WaterTrackerController(
        repository: repository,
        logWater: LogWaterUseCase(
          session: _ownerSession,
          repository: repository,
          ids: _waterIds,
          clock: _waterClock,
        ),
        preferences: preferences,
        savePreferences: SaveHydrationPreferencesUseCase(
          session: _ownerSession,
          repository: preferences,
          clock: const SystemHydrationPreferencesClock(),
        ),
        initialDay: initialDay,
      );
    });
  }

  Future<WeightTrackerController> createWeightTracker(OnboardingState profile) {
    return _ownerSession.withOwner((ownerId) async {
      final database = await _databases.open(ownerId);
      if (_databases.activeOwnerId != ownerId) {
        throw StateError('Active database owner changed during composition');
      }
      final repository = DriftWeightRepository(
        database: database,
        expectedOwnerId: ownerId,
      );
      return WeightTrackerController(
        repository: repository,
        logWeight: LogWeightUseCase(
          session: _ownerSession,
          repository: repository,
          ids: _weightIds,
          clock: _weightClock,
        ),
        correctWeight: CorrectWeightUseCase(
          session: _ownerSession,
          activeEvents: repository,
          repository: repository,
          ids: _weightIds,
          clock: _weightClock,
        ),
        startingKilograms: profile.weightKg.toDouble(),
        targetKilograms: profile.targetWeightKg.toDouble(),
        unit: profile.unit,
      );
    });
  }
}
