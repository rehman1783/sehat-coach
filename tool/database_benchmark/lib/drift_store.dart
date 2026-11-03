import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'benchmark_contract.dart';
import 'fixture.dart';

class BenchmarkDatabase extends GeneratedDatabase {
  final int version;
  final bool failUpgrade;
  BenchmarkDatabase(File file, {this.version = 1, this.failUpgrade = false})
    : super(NativeDatabase(file));
  @override
  int get schemaVersion => version;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      await transaction(() async {
        if (from < 2 && to >= 2) {
          await customStatement(
            "ALTER TABLE food ADD COLUMN source TEXT NOT NULL DEFAULT 'synthetic'",
          );
          if (failUpgrade) throw StateError('injected-migration-failure');
        }
      });
    },
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
}

class DriftStore implements BenchmarkStore {
  final BenchmarkDatabase db;
  DriftStore(String path) : db = BenchmarkDatabase(File(path));
  @override
  String get name => 'Drift/SQLite';
  @override
  Future<void> importFixture(BenchmarkFixture fixture) async {
    await db.customStatement('PRAGMA foreign_keys = ON');
    await db.transaction(() async {
      await db.customStatement(
        'CREATE TABLE food (id INTEGER PRIMARY KEY, name TEXT NOT NULL, energy INTEGER NOT NULL)',
      );
      await db.customStatement('CREATE INDEX food_name ON food(name)');
      await db.customStatement(
        'CREATE TABLE meal (id INTEGER PRIMARY KEY, food_id INTEGER REFERENCES food(id), servings INTEGER NOT NULL)',
      );
      await db.batch((batch) {
        for (final food in fixture.foods) {
          batch.customStatement('INSERT INTO food VALUES (?, ?, ?)', [
            food.id,
            food.name,
            food.energy,
          ]);
        }
        for (final meal in fixture.meals) {
          batch.customStatement('INSERT INTO meal VALUES (?, ?, ?)', [
            meal.id,
            meal.foodId,
            meal.servings,
          ]);
        }
      });
    });
  }

  @override
  Future<List<int>> searchPrefix(String prefix) async =>
      (await db
              .customSelect(
                'SELECT id FROM food WHERE name >= ? AND name < ?',
                variables: [Variable(prefix), Variable('$prefix\uffff')],
              )
              .get())
          .map((row) => row.read<int>('id'))
          .toList();
  @override
  Future<int> mealEnergyTotal() async =>
      (await db
              .customSelect(
                'SELECT SUM(food.energy * meal.servings) AS total FROM meal JOIN food ON food.id = meal.food_id',
              )
              .getSingle())
          .read<int>('total');
  @override
  Future<void> injectFailedWrite() async {
    await db.transaction(() async {
      await db.customStatement('UPDATE food SET energy = 99999');
      await db.customStatement(
        "INSERT INTO food VALUES (999999, 'Rollback sentinel', 1)",
      );
      throw StateError('injected-write-failure');
    });
  }

  @override
  Future<void> close() => db.close();
}
