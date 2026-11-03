import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'foreign-key-invalid legacy data rejects and rolls back upgrade',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-invalid-foreign-key-',
      );
      final file = File('${directory.path}/migration.sqlite');
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final old = sqlite.sqlite3.open(file.path);
      old.execute('''
      CREATE TABLE catalog_releases (
        release_id TEXT NOT NULL PRIMARY KEY,
        version TEXT NOT NULL,
        review_status TEXT NOT NULL,
        content_checksum TEXT NOT NULL,
        published_at INTEGER,
        imported_at INTEGER NOT NULL
      );
      CREATE TABLE nutrition_sources (
        source_key TEXT NOT NULL PRIMARY KEY,
        source_id TEXT NOT NULL,
        source_version TEXT NOT NULL,
        citation TEXT NOT NULL,
        license_id TEXT NOT NULL,
        UNIQUE (source_id, source_version)
      );
      CREATE TABLE catalog_foods (
        release_id TEXT NOT NULL REFERENCES catalog_releases(release_id),
        food_id TEXT NOT NULL,
        name_english TEXT NOT NULL,
        name_roman_urdu TEXT NOT NULL,
        normalized_name_english TEXT NOT NULL,
        normalized_name_roman_urdu TEXT NOT NULL,
        region TEXT,
        preparation TEXT,
        reference_grams REAL NOT NULL,
        calories_kcal REAL NOT NULL,
        protein_grams REAL NOT NULL,
        carbohydrate_grams REAL NOT NULL,
        fat_grams REAL NOT NULL,
        sodium_milligrams REAL,
        oil_inclusion TEXT NOT NULL,
        source_key TEXT NOT NULL REFERENCES nutrition_sources(source_key),
        source_record_id TEXT NOT NULL,
        review_status TEXT NOT NULL,
        reviewer_id TEXT,
        reviewed_at INTEGER,
        PRIMARY KEY (release_id, food_id)
      );
      CREATE TABLE catalog_food_synonyms (
        release_id TEXT NOT NULL,
        food_id TEXT NOT NULL,
        locale TEXT NOT NULL,
        synonym TEXT NOT NULL,
        normalized_synonym TEXT NOT NULL,
        PRIMARY KEY (release_id, food_id, locale, normalized_synonym),
        FOREIGN KEY (release_id, food_id)
          REFERENCES catalog_foods(release_id, food_id)
      );
      CREATE TABLE catalog_serving_definitions (
        release_id TEXT NOT NULL,
        food_id TEXT NOT NULL,
        serving_id TEXT NOT NULL,
        label TEXT NOT NULL,
        unit_code TEXT NOT NULL,
        grams_minimum REAL NOT NULL,
        grams_maximum REAL NOT NULL,
        confidence REAL NOT NULL,
        PRIMARY KEY (release_id, food_id, serving_id),
        FOREIGN KEY (release_id, food_id)
          REFERENCES catalog_foods(release_id, food_id)
      );
      INSERT INTO catalog_food_synonyms VALUES (
        'missing-release', 'missing-food', 'en', 'Ghost', 'ghost'
      );
      PRAGMA user_version = 3;
    ''');
      old.close();

      final failedDatabase = AppDatabase(NativeDatabase(file));
      await expectLater(
        failedDatabase.customSelect('SELECT 1').getSingle(),
        throwsA(isA<StateError>()),
      );
      await failedDatabase.close();

      final afterFailure = sqlite.sqlite3.open(file.path);
      expect(afterFailure.userVersion, 3);
      expect(
        afterFailure.select(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'meal_events'",
        ),
        isEmpty,
      );
      expect(
        afterFailure.select('SELECT * FROM catalog_food_synonyms'),
        hasLength(1),
      );
      afterFailure.execute('DELETE FROM catalog_food_synonyms');
      afterFailure.close();

      final recovered = AppDatabase(NativeDatabase(file));
      addTearDown(recovered.close);
      expect(
        (await recovered.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        14,
      );
      expect(
        await recovered.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    },
  );

  test(
    'failed upgrade rolls back fully and a repaired retry succeeds',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-failed-migration-',
      );
      final file = File('${directory.path}/migration.sqlite');
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final old = sqlite.sqlite3.open(file.path);
      old.execute('''
      CREATE TABLE local_records (
        owner_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_key TEXT NOT NULL,
        schema_version INTEGER NOT NULL,
        revision INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at_client INTEGER NOT NULL,
        updated_at_client INTEGER NOT NULL,
        updated_at_server INTEGER,
        PRIMARY KEY (owner_id, entity_type, entity_key)
      );
      CREATE TABLE sync_outbox_entries (
        owner_id TEXT NOT NULL,
        operation_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_key TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        base_revision INTEGER NOT NULL,
        new_revision INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        created_at_client INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        PRIMARY KEY (owner_id, operation_id)
      );
      CREATE TABLE sync_cursors (
        owner_id TEXT NOT NULL PRIMARY KEY,
        cursor TEXT NOT NULL,
        updated_at_client INTEGER NOT NULL
      );
      INSERT INTO local_records VALUES (
        'owner-a', 'profile', 'profile', 1, 1, '{"safe":true}', 0,
        1761004800, 1761004800, NULL
      );
      CREATE TABLE catalog_releases (legacy_collision TEXT NOT NULL);
      PRAGMA user_version = 1;
    ''');
      old.close();

      final failedDatabase = AppDatabase(NativeDatabase(file));
      await expectLater(
        failedDatabase.customSelect('SELECT 1').getSingle(),
        throwsA(anything),
      );
      await failedDatabase.close();

      final afterFailure = sqlite.sqlite3.open(file.path);
      expect(afterFailure.userVersion, 1);
      expect(
        afterFailure
            .select('SELECT payload_json FROM local_records')
            .single['payload_json'],
        '{"safe":true}',
      );
      expect(
        afterFailure.select(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'idx_outbox_owner_order'",
        ),
        isEmpty,
        reason: 'Migration work before the failure must also roll back.',
      );
      expect(
        afterFailure
            .select('PRAGMA table_info(catalog_releases)')
            .single['name'],
        'legacy_collision',
      );
      afterFailure.execute('DROP TABLE catalog_releases');
      afterFailure.close();

      final recovered = AppDatabase(NativeDatabase(file));
      addTearDown(recovered.close);
      expect(
        (await recovered.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        14,
      );
      expect(
        (await recovered.select(recovered.localRecords).get())
            .single
            .payloadJson,
        '{"safe":true}',
      );
      expect(
        (await recovered
                .customSelect('PRAGMA table_info(catalog_releases)')
                .get())
            .map((row) => row.read<String>('name')),
        containsAll(['release_id', 'version', 'review_status']),
      );
    },
  );

  test('v1 data survives v14 sync, catalog and tracker migrations', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-schema-migration-',
    );
    final file = File('${directory.path}/migration.sqlite');
    addTearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    final old = sqlite.sqlite3.open(file.path);
    old.execute('''
      CREATE TABLE local_records (
        owner_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_key TEXT NOT NULL,
        schema_version INTEGER NOT NULL,
        revision INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at_client INTEGER NOT NULL,
        updated_at_client INTEGER NOT NULL,
        updated_at_server INTEGER,
        PRIMARY KEY (owner_id, entity_type, entity_key)
      );
      CREATE TABLE sync_outbox_entries (
        owner_id TEXT NOT NULL,
        operation_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_key TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        base_revision INTEGER NOT NULL,
        new_revision INTEGER NOT NULL,
        payload_json TEXT NOT NULL,
        created_at_client INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        PRIMARY KEY (owner_id, operation_id)
      );
      CREATE TABLE sync_cursors (
        owner_id TEXT NOT NULL PRIMARY KEY,
        cursor TEXT NOT NULL,
        updated_at_client INTEGER NOT NULL
      );
      INSERT INTO local_records VALUES (
        'owner-a', 'meal', 'meal-1', 1, 4, '{"name":"Daal"}', 0,
        1761004800, 1761004800, NULL
      );
      INSERT INTO sync_outbox_entries VALUES (
        'owner-a', 'op-1', 'meal', 'meal-1', 'upsert', 3, 4,
        '{"name":"Daal"}', 1761004800, 2, 'transport_failure'
      );
      INSERT INTO sync_cursors VALUES ('owner-a', 'cursor-v1', 1761004800);
      PRAGMA user_version = 1;
    ''');
    old.close();

    final database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final record = (await database.select(database.localRecords).get()).single;
    final outbox =
        (await database.select(database.syncOutboxEntries).get()).single;
    final cursor = (await database.select(database.syncCursors).get()).single;
    expect(record.entityKey, 'meal-1');
    expect(record.revision, 4);
    expect(outbox.attemptCount, 2);
    expect(outbox.lastError, 'transport_failure');
    expect(cursor.cursor, 'cursor-v1');

    final indexes = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
        )
        .get();
    expect(
      indexes.map((row) => row.read<String>('name')).toSet(),
      containsAll({
        'idx_outbox_owner_order',
        'idx_outbox_owner_entity',
        'idx_records_owner_type_deleted',
        'idx_catalog_release_status',
        'idx_catalog_food_name_en',
        'idx_catalog_food_name_roman',
        'idx_catalog_synonym_search',
        'idx_catalog_recipe_name_en',
        'idx_catalog_recipe_name_roman',
        'idx_catalog_recipe_synonym_search',
        'idx_catalog_recipe_ingredient_food',
        'idx_meal_owner_time',
        'idx_meal_owner_supersedes',
        'idx_water_owner_time',
        'idx_water_owner_supersedes',
        'idx_weight_owner_time',
        'idx_weight_owner_supersedes',
        'idx_custom_food_owner_name',
        'idx_food_note_owner_status',
        'idx_custom_recipe_owner_name',
      }),
    );
    expect(
      (await database.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      14,
    );
    final mealTables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'meal_%'",
        )
        .get();
    expect(
      mealTables.map((row) => row.read<String>('name')).toSet(),
      containsAll({'meal_events', 'meal_items'}),
    );
    final waterTables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'water_events'",
        )
        .get();
    expect(waterTables, hasLength(1));
    final weightTables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'weight_events'",
        )
        .get();
    expect(weightTables, hasLength(1));
    final hydrationPreferenceTables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'hydration_preferences'",
        )
        .get();
    expect(hydrationPreferenceTables, hasLength(1));
    final mealItemColumns = await database
        .customSelect('PRAGMA table_info(meal_items)')
        .get();
    expect(
      mealItemColumns.map((row) => row.read<String>('name')),
      contains('catalog_item_type'),
    );
    expect(
      mealItemColumns.map((row) => row.read<String>('name')),
      contains('weight_basis'),
    );
    final catalogTables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'catalog_%'",
        )
        .get();
    expect(
      catalogTables.map((row) => row.read<String>('name')).toSet(),
      containsAll({
        'catalog_releases',
        'catalog_foods',
        'catalog_food_synonyms',
        'catalog_serving_definitions',
        'catalog_recipes',
        'catalog_recipe_synonyms',
        'catalog_recipe_ingredients',
      }),
    );
  });

  test(
    'v6 meal items gain recipe and weight identity during v14 upgrade',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-v6-migration-',
      );
      final file = File('${directory.path}/migration.sqlite');
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final old = sqlite.sqlite3.open(file.path);
      old.execute('''
      CREATE TABLE meal_events (
        owner_id TEXT NOT NULL,
        event_id TEXT NOT NULL,
        PRIMARY KEY (owner_id, event_id)
      );
      CREATE TABLE meal_items (
        owner_id TEXT NOT NULL,
        event_id TEXT NOT NULL,
        item_index INTEGER NOT NULL,
        catalog_release_id TEXT NOT NULL,
        food_id TEXT NOT NULL,
        source_id TEXT NOT NULL,
        source_version TEXT NOT NULL,
        source_record_id TEXT NOT NULL,
        serving_id TEXT NOT NULL,
        serving_label TEXT NOT NULL,
        unit_code TEXT NOT NULL,
        quantity REAL NOT NULL,
        grams_minimum REAL NOT NULL,
        grams_maximum REAL NOT NULL,
        serving_confidence REAL NOT NULL,
        calories_minimum REAL NOT NULL,
        calories_maximum REAL NOT NULL,
        protein_minimum REAL NOT NULL,
        protein_maximum REAL NOT NULL,
        carbohydrate_minimum REAL NOT NULL,
        carbohydrate_maximum REAL NOT NULL,
        fat_minimum REAL NOT NULL,
        fat_maximum REAL NOT NULL,
        sodium_minimum REAL,
        sodium_maximum REAL,
        oil_inclusion TEXT NOT NULL,
        calculation_version TEXT NOT NULL,
        PRIMARY KEY (owner_id, event_id, item_index)
      );
      INSERT INTO meal_events VALUES ('owner-a', 'meal-1');
      INSERT INTO meal_items VALUES (
        'owner-a', 'meal-1', 0, 'release-1', 'food-1', 'source-1',
        '1', 'record-1', 'serving-1', '1 serving', 'serving', 1,
        100, 100, 1, 100, 100, 5, 5, 10, 10, 2, 2,
        NULL, NULL, 'unknown', 'deterministic-nutrition-v1'
      );
      PRAGMA user_version = 6;
    ''');
      old.close();

      final database = AppDatabase(NativeDatabase(file));
      addTearDown(database.close);
      final item = (await database.select(database.mealItems).get()).single;
      expect(item.catalogItemType, 'food');
      expect(item.weightBasis, 'catalogConversion');
      expect(
        (await database.customSelect('PRAGMA user_version').getSingle())
            .read<int>('user_version'),
        14,
      );
    },
  );

  test('v12 hydration preferences gain reminder defaults during v14', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-v12-migration-',
    );
    final file = File('${directory.path}/migration.sqlite');
    addTearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });
    final old = sqlite.sqlite3.open(file.path);
    old.execute('''
      CREATE TABLE meal_events (
        owner_id TEXT NOT NULL,
        event_id TEXT NOT NULL,
        PRIMARY KEY (owner_id, event_id)
      );
      CREATE TABLE hydration_preferences (
        owner_id TEXT NOT NULL PRIMARY KEY,
        target_milliliters INTEGER,
        target_source TEXT NOT NULL DEFAULT 'none',
        restriction_note TEXT NOT NULL DEFAULT '',
        revision INTEGER NOT NULL,
        updated_at_utc INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      );
      INSERT INTO hydration_preferences VALUES (
        'owner-a', 1800, 'user', '', 1, 1792700000, 0
      );
      PRAGMA user_version = 12;
    ''');
    old.close();

    final database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final preference =
        (await database.select(database.hydrationPreferences).get()).single;
    expect(preference.targetMilliliters, 1800);
    expect(preference.remindersEnabled, isFalse);
    expect(preference.reminderStartMinute, 480);
    expect(preference.reminderEndMinute, 1200);
    expect(preference.reminderIntervalMinutes, 120);
  });
}
