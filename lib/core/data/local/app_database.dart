import 'package:drift/drift.dart';

part 'app_database.g.dart';

class LocalRecords extends Table {
  TextColumn get ownerId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityKey => text()();
  IntColumn get schemaVersion => integer()();
  IntColumn get revision => integer()();
  TextColumn get payloadJson => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtClient => dateTime()();
  DateTimeColumn get updatedAtClient => dateTime()();
  DateTimeColumn get updatedAtServer => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, entityType, entityKey};
}

class SyncOutboxEntries extends Table {
  TextColumn get ownerId => text()();
  TextColumn get operationId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityKey => text()();
  TextColumn get operationType => text()();
  IntColumn get baseRevision => integer()();
  IntColumn get newRevision => integer()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAtClient => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, operationId};
}

class SyncCursors extends Table {
  TextColumn get ownerId => text()();
  TextColumn get cursor => text()();
  DateTimeColumn get updatedAtClient => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId};
}

class CatalogReleases extends Table {
  TextColumn get releaseId => text()();
  TextColumn get version => text()();
  TextColumn get reviewStatus => text()();
  TextColumn get contentChecksum => text()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {releaseId};
}

class NutritionSources extends Table {
  TextColumn get sourceKey => text()();
  TextColumn get sourceId => text()();
  TextColumn get sourceVersion => text()();
  TextColumn get citation => text()();
  TextColumn get licenseId => text()();

  @override
  Set<Column<Object>> get primaryKey => {sourceKey};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceId, sourceVersion},
  ];
}

class CatalogFoods extends Table {
  TextColumn get releaseId => text().references(
    CatalogReleases,
    #releaseId,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get foodId => text()();
  TextColumn get nameEnglish => text()();
  TextColumn get nameRomanUrdu => text()();
  TextColumn get normalizedNameEnglish => text()();
  TextColumn get normalizedNameRomanUrdu => text()();
  TextColumn get region => text().nullable()();
  TextColumn get preparation => text().nullable()();
  RealColumn get referenceGrams => real()();
  RealColumn get caloriesKcal => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbohydrateGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get sodiumMilligrams => real().nullable()();
  TextColumn get oilInclusion => text()();
  TextColumn get sourceKey => text().references(NutritionSources, #sourceKey)();
  TextColumn get sourceRecordId => text()();
  TextColumn get reviewStatus => text()();
  TextColumn get reviewerId => text().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {releaseId, foodId};

  @override
  List<String> get customConstraints => [
    'CHECK (reference_grams > 0)',
    'CHECK (calories_kcal >= 0)',
    'CHECK (protein_grams >= 0)',
    'CHECK (carbohydrate_grams >= 0)',
    'CHECK (fat_grams >= 0)',
    'CHECK (sodium_milligrams IS NULL OR sodium_milligrams >= 0)',
  ];
}

class CatalogFoodSynonyms extends Table {
  TextColumn get releaseId => text()();
  TextColumn get foodId => text()();
  TextColumn get locale => text()();
  TextColumn get synonym => text()();
  TextColumn get normalizedSynonym => text()();

  @override
  Set<Column<Object>> get primaryKey => {
    releaseId,
    foodId,
    locale,
    normalizedSynonym,
  };

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (release_id, food_id) '
        'REFERENCES catalog_foods(release_id, food_id) ON DELETE CASCADE',
  ];
}

class CatalogServingDefinitions extends Table {
  TextColumn get releaseId => text()();
  TextColumn get foodId => text()();
  TextColumn get servingId => text()();
  TextColumn get label => text()();
  TextColumn get unitCode => text()();
  RealColumn get gramsMinimum => real()();
  RealColumn get gramsMaximum => real()();
  RealColumn get confidence => real()();

  @override
  Set<Column<Object>> get primaryKey => {releaseId, foodId, servingId};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (release_id, food_id) '
        'REFERENCES catalog_foods(release_id, food_id) ON DELETE CASCADE',
    'CHECK (grams_minimum > 0)',
    'CHECK (grams_maximum >= grams_minimum)',
    'CHECK (confidence >= 0 AND confidence <= 1)',
  ];
}

class CatalogRecipes extends Table {
  TextColumn get releaseId => text().references(
    CatalogReleases,
    #releaseId,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get recipeId => text()();
  TextColumn get nameEnglish => text()();
  TextColumn get nameRomanUrdu => text()();
  TextColumn get normalizedNameEnglish => text()();
  TextColumn get normalizedNameRomanUrdu => text()();
  TextColumn get region => text().nullable()();
  TextColumn get preparationVariant => text().nullable()();
  RealColumn get yieldServingsMinimum => real()();
  RealColumn get yieldServingsMaximum => real()();
  TextColumn get oilTreatment => text()();
  TextColumn get sourceKey => text().references(NutritionSources, #sourceKey)();
  TextColumn get sourceRecordId => text()();
  TextColumn get reviewStatus => text()();
  TextColumn get reviewerId => text().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {releaseId, recipeId};

  @override
  List<String> get customConstraints => [
    'CHECK (yield_servings_minimum > 0)',
    'CHECK (yield_servings_maximum >= yield_servings_minimum)',
    "CHECK (oil_treatment IN ('includedInIngredients', "
        "'excludedFromCalculation', 'unknown'))",
  ];
}

class CatalogRecipeSynonyms extends Table {
  TextColumn get releaseId => text()();
  TextColumn get recipeId => text()();
  TextColumn get locale => text()();
  TextColumn get synonym => text()();
  TextColumn get normalizedSynonym => text()();

  @override
  Set<Column<Object>> get primaryKey => {
    releaseId,
    recipeId,
    locale,
    normalizedSynonym,
  };

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (release_id, recipe_id) '
        'REFERENCES catalog_recipes(release_id, recipe_id) ON DELETE CASCADE',
  ];
}

class CatalogRecipeIngredients extends Table {
  TextColumn get releaseId => text()();
  TextColumn get recipeId => text()();
  IntColumn get ingredientIndex => integer()();
  TextColumn get foodId => text()();
  TextColumn get servingId => text()();
  RealColumn get quantity => real()();
  RealColumn get exactGramsPerServing => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {releaseId, recipeId, ingredientIndex};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (release_id, recipe_id) '
        'REFERENCES catalog_recipes(release_id, recipe_id) ON DELETE CASCADE',
    'FOREIGN KEY (release_id, food_id) '
        'REFERENCES catalog_foods(release_id, food_id)',
    'CHECK (ingredient_index >= 0)',
    'CHECK (quantity > 0)',
    'CHECK (exact_grams_per_serving IS NULL OR exact_grams_per_serving > 0)',
  ];
}

class MealEvents extends Table {
  TextColumn get ownerId => text()();
  TextColumn get eventId => text()();
  TextColumn get mealType => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  IntColumn get timezoneOffsetMinutes => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  TextColumn get rawUserInput => text()();
  TextColumn get aiProvenanceJson => text().nullable()();
  TextColumn get supersedesEventId => text().nullable()();
  IntColumn get revision => integer()();
  TextColumn get calculationVersion => text()();
  RealColumn get caloriesMinimum => real()();
  RealColumn get caloriesMaximum => real()();
  RealColumn get proteinMinimum => real()();
  RealColumn get proteinMaximum => real()();
  RealColumn get carbohydrateMinimum => real()();
  RealColumn get carbohydrateMaximum => real()();
  RealColumn get fatMinimum => real()();
  RealColumn get fatMaximum => real()();
  RealColumn get sodiumMinimum => real().nullable()();
  RealColumn get sodiumMaximum => real().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, eventId};

  @override
  List<String> get customConstraints => [
    'CHECK (timezone_offset_minutes BETWEEN -840 AND 840)',
    'CHECK (revision >= 1)',
    'CHECK (calories_minimum >= 0 AND calories_maximum >= calories_minimum)',
    'CHECK (protein_minimum >= 0 AND protein_maximum >= protein_minimum)',
    'CHECK (carbohydrate_minimum >= 0 AND carbohydrate_maximum >= carbohydrate_minimum)',
    'CHECK (fat_minimum >= 0 AND fat_maximum >= fat_minimum)',
    'CHECK ((sodium_minimum IS NULL AND sodium_maximum IS NULL) OR '
        '(sodium_minimum >= 0 AND sodium_maximum >= sodium_minimum))',
  ];
}

class MealItems extends Table {
  TextColumn get ownerId => text()();
  TextColumn get eventId => text()();
  IntColumn get itemIndex => integer()();
  TextColumn get catalogItemType =>
      text().withDefault(const Constant('food'))();
  TextColumn get weightBasis =>
      text().withDefault(const Constant('catalogConversion'))();
  TextColumn get catalogReleaseId => text()();
  TextColumn get foodId => text()();
  TextColumn get sourceId => text()();
  TextColumn get sourceVersion => text()();
  TextColumn get sourceRecordId => text()();
  TextColumn get servingId => text()();
  TextColumn get servingLabel => text()();
  TextColumn get unitCode => text()();
  RealColumn get quantity => real()();
  RealColumn get gramsMinimum => real()();
  RealColumn get gramsMaximum => real()();
  RealColumn get servingConfidence => real()();
  RealColumn get caloriesMinimum => real()();
  RealColumn get caloriesMaximum => real()();
  RealColumn get proteinMinimum => real()();
  RealColumn get proteinMaximum => real()();
  RealColumn get carbohydrateMinimum => real()();
  RealColumn get carbohydrateMaximum => real()();
  RealColumn get fatMinimum => real()();
  RealColumn get fatMaximum => real()();
  RealColumn get sodiumMinimum => real().nullable()();
  RealColumn get sodiumMaximum => real().nullable()();
  TextColumn get oilInclusion => text()();
  TextColumn get calculationVersion => text()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, eventId, itemIndex};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (owner_id, event_id) '
        'REFERENCES meal_events(owner_id, event_id) ON DELETE CASCADE',
    'CHECK (item_index >= 0)',
    'CHECK (quantity > 0)',
    "CHECK ((weight_basis = 'unknown' AND grams_minimum = 0 AND "
        "grams_maximum = 0) OR (weight_basis != 'unknown' AND "
        'grams_minimum > 0 AND grams_maximum >= grams_minimum))',
    "CHECK (weight_basis IN ('catalogConversion', 'exactMeasured', "
        "'userEnteredServingWeight', 'unknown'))",
    'CHECK (serving_confidence BETWEEN 0 AND 1)',
    'CHECK (calories_minimum >= 0 AND calories_maximum >= calories_minimum)',
    'CHECK (protein_minimum >= 0 AND protein_maximum >= protein_minimum)',
    'CHECK (carbohydrate_minimum >= 0 AND carbohydrate_maximum >= carbohydrate_minimum)',
    'CHECK (fat_minimum >= 0 AND fat_maximum >= fat_minimum)',
    'CHECK ((sodium_minimum IS NULL AND sodium_maximum IS NULL) OR '
        '(sodium_minimum >= 0 AND sodium_maximum >= sodium_minimum))',
  ];
}

class WaterEvents extends Table {
  TextColumn get ownerId => text()();
  TextColumn get eventId => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  IntColumn get timezoneOffsetMinutes => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  IntColumn get volumeMilliliters => integer()();
  TextColumn get supersedesEventId => text().nullable()();
  IntColumn get revision => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, eventId};

  @override
  List<String> get customConstraints => [
    'CHECK (timezone_offset_minutes BETWEEN -840 AND 840)',
    'CHECK (volume_milliliters > 0 AND volume_milliliters <= 10000)',
    'CHECK (revision >= 1)',
  ];
}

class WeightEvents extends Table {
  TextColumn get ownerId => text()();
  TextColumn get eventId => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  IntColumn get timezoneOffsetMinutes => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  RealColumn get weightKilograms => real()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get supersedesEventId => text().nullable()();
  IntColumn get revision => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, eventId};

  @override
  List<String> get customConstraints => [
    'CHECK (timezone_offset_minutes BETWEEN -840 AND 840)',
    'CHECK (weight_kilograms >= 20 AND weight_kilograms <= 500)',
    'CHECK (length(note) <= 500)',
    'CHECK (revision >= 1)',
  ];
}

class HydrationPreferences extends Table {
  TextColumn get ownerId => text()();
  IntColumn get targetMilliliters => integer().nullable()();
  TextColumn get targetSource => text().withDefault(const Constant('none'))();
  TextColumn get restrictionNote => text().withDefault(const Constant(''))();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderStartMinute =>
      integer().withDefault(const Constant(480))();
  IntColumn get reminderEndMinute =>
      integer().withDefault(const Constant(1200))();
  IntColumn get reminderIntervalMinutes =>
      integer().withDefault(const Constant(120))();
  IntColumn get revision => integer()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId};

  @override
  List<String> get customConstraints => [
    'CHECK (target_milliliters IS NULL OR '
        '(target_milliliters >= 250 AND target_milliliters <= 10000))',
    "CHECK (target_source IN ('none', 'user', 'clinician'))",
    "CHECK ((target_source = 'none' AND target_milliliters IS NULL) OR "
        "(target_source != 'none' AND target_milliliters IS NOT NULL))",
    'CHECK (length(restriction_note) <= 500)',
    'CHECK (reminder_start_minute BETWEEN 0 AND 1439)',
    'CHECK (reminder_end_minute BETWEEN 0 AND 1439)',
    'CHECK (reminder_end_minute > reminder_start_minute)',
    'CHECK (reminder_interval_minutes BETWEEN 30 AND 720)',
    'CHECK (revision >= 1)',
  ];
}

class CustomFoods extends Table {
  TextColumn get ownerId => text()();
  TextColumn get customFoodId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get servingLabel => text()();
  TextColumn get unitCode => text()();
  RealColumn get gramsPerServing => real().nullable()();
  RealColumn get caloriesKcal => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbohydrateGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get sodiumMilligrams => real().nullable()();
  IntColumn get revision => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, customFoodId};

  @override
  List<String> get customConstraints => [
    'CHECK (grams_per_serving IS NULL OR grams_per_serving > 0)',
    'CHECK (calories_kcal >= 0)',
    'CHECK (protein_grams >= 0)',
    'CHECK (carbohydrate_grams >= 0)',
    'CHECK (fat_grams >= 0)',
    'CHECK (sodium_milligrams IS NULL OR sodium_milligrams >= 0)',
    'CHECK (revision >= 1)',
  ];
}

class FoodNotFoundNotes extends Table {
  TextColumn get ownerId => text()();
  TextColumn get noteId => text()();
  TextColumn get searchText => text()();
  TextColumn get normalizedSearchText => text()();
  TextColumn get details => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get revision => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, noteId};

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('pending', 'resolved', 'dismissed'))",
    'CHECK (revision >= 1)',
  ];
}

class CustomRecipes extends Table {
  TextColumn get ownerId => text()();
  TextColumn get customRecipeId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  RealColumn get yieldServingsMinimum => real()();
  RealColumn get yieldServingsMaximum => real()();
  TextColumn get oilTreatment => text()();
  IntColumn get revision => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, customRecipeId};

  @override
  List<String> get customConstraints => [
    'CHECK (yield_servings_minimum > 0)',
    'CHECK (yield_servings_maximum >= yield_servings_minimum)',
    "CHECK (oil_treatment IN ('includedInIngredients', "
        "'excludedFromCalculation', 'unknown'))",
    'CHECK (revision >= 1)',
  ];
}

class CustomRecipeIngredients extends Table {
  TextColumn get ownerId => text()();
  TextColumn get customRecipeId => text()();
  IntColumn get ingredientIndex => integer()();
  TextColumn get catalogItemType => text()();
  TextColumn get catalogReleaseId => text()();
  TextColumn get itemId => text()();
  TextColumn get sourceId => text()();
  TextColumn get sourceVersion => text()();
  TextColumn get sourceRecordId => text()();
  TextColumn get servingId => text()();
  TextColumn get servingLabel => text()();
  TextColumn get unitCode => text()();
  RealColumn get quantity => real()();
  RealColumn get gramsMinimum => real()();
  RealColumn get gramsMaximum => real()();
  TextColumn get weightBasis => text()();
  RealColumn get servingConfidence => real()();
  RealColumn get caloriesMinimum => real()();
  RealColumn get caloriesMaximum => real()();
  RealColumn get proteinMinimum => real()();
  RealColumn get proteinMaximum => real()();
  RealColumn get carbohydrateMinimum => real()();
  RealColumn get carbohydrateMaximum => real()();
  RealColumn get fatMinimum => real()();
  RealColumn get fatMaximum => real()();
  RealColumn get sodiumMinimum => real().nullable()();
  RealColumn get sodiumMaximum => real().nullable()();
  TextColumn get oilInclusion => text()();
  TextColumn get calculationVersion => text()();

  @override
  Set<Column<Object>> get primaryKey => {
    ownerId,
    customRecipeId,
    ingredientIndex,
  };

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (owner_id, custom_recipe_id) '
        'REFERENCES custom_recipes(owner_id, custom_recipe_id) ON DELETE CASCADE',
    'CHECK (ingredient_index >= 0)',
    'CHECK (quantity > 0)',
    "CHECK ((weight_basis = 'unknown' AND grams_minimum = 0 AND "
        "grams_maximum = 0) OR (weight_basis != 'unknown' AND "
        'grams_minimum > 0 AND grams_maximum >= grams_minimum))',
    'CHECK (serving_confidence BETWEEN 0 AND 1)',
    'CHECK (calories_minimum >= 0 AND calories_maximum >= calories_minimum)',
    'CHECK (protein_minimum >= 0 AND protein_maximum >= protein_minimum)',
    'CHECK (carbohydrate_minimum >= 0 AND carbohydrate_maximum >= carbohydrate_minimum)',
    'CHECK (fat_minimum >= 0 AND fat_maximum >= fat_minimum)',
    'CHECK ((sodium_minimum IS NULL AND sodium_maximum IS NULL) OR '
        '(sodium_minimum >= 0 AND sodium_maximum >= sodium_minimum))',
  ];
}

@DriftDatabase(
  tables: [
    LocalRecords,
    SyncOutboxEntries,
    SyncCursors,
    CatalogReleases,
    NutritionSources,
    CatalogFoods,
    CatalogFoodSynonyms,
    CatalogServingDefinitions,
    CatalogRecipes,
    CatalogRecipeSynonyms,
    CatalogRecipeIngredients,
    MealEvents,
    MealItems,
    WaterEvents,
    WeightEvents,
    HydrationPreferences,
    CustomFoods,
    FoodNotFoundNotes,
    CustomRecipes,
    CustomRecipeIngredients,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createSyncIndexes();
      await _createCatalogIndexes();
      await _createRecipeIndexes();
      await _createMealIndexes();
      await _createWaterIndexes();
      await _createWeightIndexes();
      await _createUserFoodIndexes();
      await _createCustomRecipeIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      await transaction(() async {
        if (from < 2) await _createSyncIndexes();
        if (from < 3) {
          await migrator.createTable(catalogReleases);
          await migrator.createTable(nutritionSources);
          await migrator.createTable(catalogFoods);
          await migrator.createTable(catalogFoodSynonyms);
          await migrator.createTable(catalogServingDefinitions);
          await _createCatalogIndexes();
        }
        if (from < 4) {
          await migrator.createTable(mealEvents);
          await migrator.createTable(mealItems);
          await _createMealIndexes();
        }
        if (from < 5) {
          await migrator.createTable(waterEvents);
          await _createWaterIndexes();
        }
        if (from < 6) {
          await migrator.createTable(catalogRecipes);
          await migrator.createTable(catalogRecipeSynonyms);
          await migrator.createTable(catalogRecipeIngredients);
          await _createRecipeIndexes();
        }
        if (from >= 4 && from < 7) {
          await migrator.addColumn(mealItems, mealItems.catalogItemType);
        }
        if (from < 8) {
          await migrator.createTable(customFoods);
          await migrator.createTable(foodNotFoundNotes);
          await _createUserFoodIndexes();
        }
        if (from >= 4 && from < 9) {
          await migrator.alterTable(
            TableMigration(mealItems, newColumns: [mealItems.weightBasis]),
          );
        }
        if (from < 10) {
          await migrator.createTable(customRecipes);
          await migrator.createTable(customRecipeIngredients);
          await _createCustomRecipeIndexes();
        }
        if (from < 11) {
          await migrator.createTable(weightEvents);
          await _createWeightIndexes();
        }
        if (from < 12) {
          await migrator.createTable(hydrationPreferences);
        }
        if (from >= 12 && from < 13) {
          await migrator.addColumn(
            hydrationPreferences,
            hydrationPreferences.remindersEnabled,
          );
          await migrator.addColumn(
            hydrationPreferences,
            hydrationPreferences.reminderStartMinute,
          );
          await migrator.addColumn(
            hydrationPreferences,
            hydrationPreferences.reminderEndMinute,
          );
          await migrator.addColumn(
            hydrationPreferences,
            hydrationPreferences.reminderIntervalMinutes,
          );
        }
        if (from >= 4 && from < 14) {
          await migrator.addColumn(mealEvents, mealEvents.aiProvenanceJson);
        }
        final foreignKeyViolations = await customSelect(
          'PRAGMA foreign_key_check',
        ).get();
        if (foreignKeyViolations.isNotEmpty) {
          throw StateError('Database migration integrity check failed');
        }
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createSyncIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_owner_order '
      'ON sync_outbox_entries(owner_id, created_at_client, operation_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_outbox_owner_entity '
      'ON sync_outbox_entries(owner_id, entity_type, entity_key)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_records_owner_type_deleted '
      'ON local_records(owner_id, entity_type, is_deleted)',
    );
  }

  Future<void> _createCatalogIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_release_status '
      'ON catalog_releases(review_status, published_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_food_name_en '
      'ON catalog_foods(release_id, normalized_name_english)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_food_name_roman '
      'ON catalog_foods(release_id, normalized_name_roman_urdu)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_synonym_search '
      'ON catalog_food_synonyms(release_id, normalized_synonym, food_id)',
    );
  }

  Future<void> _createMealIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_meal_owner_time '
      'ON meal_events(owner_id, occurred_at_utc DESC, event_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_meal_owner_supersedes '
      'ON meal_events(owner_id, supersedes_event_id)',
    );
  }

  Future<void> _createRecipeIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_recipe_name_en '
      'ON catalog_recipes(release_id, normalized_name_english)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_recipe_name_roman '
      'ON catalog_recipes(release_id, normalized_name_roman_urdu)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_recipe_synonym_search '
      'ON catalog_recipe_synonyms(release_id, normalized_synonym, recipe_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_catalog_recipe_ingredient_food '
      'ON catalog_recipe_ingredients(release_id, food_id, recipe_id)',
    );
  }

  Future<void> _createWaterIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_water_owner_time '
      'ON water_events(owner_id, occurred_at_utc DESC, event_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_water_owner_supersedes '
      'ON water_events(owner_id, supersedes_event_id)',
    );
  }

  Future<void> _createWeightIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_weight_owner_time '
      'ON weight_events(owner_id, occurred_at_utc DESC, event_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_weight_owner_supersedes '
      'ON weight_events(owner_id, supersedes_event_id)',
    );
  }

  Future<void> _createUserFoodIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_custom_food_owner_name '
      'ON custom_foods(owner_id, normalized_name, is_deleted)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_food_note_owner_status '
      'ON food_not_found_notes(owner_id, status, created_at_utc DESC)',
    );
  }

  Future<void> _createCustomRecipeIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_custom_recipe_owner_name '
      'ON custom_recipes(owner_id, normalized_name, is_deleted)',
    );
  }
}
