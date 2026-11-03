import 'dart:io';

import 'lib/drift_store.dart';
import 'lib/fixture.dart';

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp('sehat-migration-');
  final fixture = BenchmarkFixture();
  final file = File('${directory.path}/migration.sqlite');
  final initial = DriftStore(file.path);
  try {
    await initial.importFixture(fixture);
  } finally {
    await initial.close();
  }

  final failing = BenchmarkDatabase(file, version: 2, failUpgrade: true);
  var sawFailure = false;
  try {
    await failing
        .customSelect('SELECT COUNT(*) AS count FROM food')
        .getSingle();
  } on StateError catch (error) {
    if (error.message != 'injected-migration-failure') rethrow;
    sawFailure = true;
  } finally {
    await failing.close();
  }
  if (!sawFailure) throw StateError('Expected migration failure');

  final original = BenchmarkDatabase(file);
  try {
    final columns = await original
        .customSelect('PRAGMA table_info(food)')
        .get();
    if (columns.any((row) => row.read<String>('name') == 'source')) {
      throw StateError('Failed migration left a partial column');
    }
    final version = await original
        .customSelect('PRAGMA user_version')
        .getSingle();
    if (version.read<int>('user_version') != 1)
      throw StateError('Failed migration changed version');
  } finally {
    await original.close();
  }

  for (var reopen = 0; reopen < 2; reopen++) {
    final upgraded = BenchmarkDatabase(file, version: 2);
    try {
      final row = await upgraded
          .customSelect(
            "SELECT COUNT(*) AS count FROM food WHERE source = 'synthetic'",
          )
          .getSingle();
      if (row.read<int>('count') != fixture.foods.length)
        throw StateError('Lost food records');
      final total = await upgraded
          .customSelect(
            'SELECT SUM(food.energy * meal.servings) AS total FROM meal JOIN food ON food.id = meal.food_id',
          )
          .getSingle();
      if (total.read<int>('total') != fixture.expectedTotal)
        throw StateError('Changed meal records');
      final version = await upgraded
          .customSelect('PRAGMA user_version')
          .getSingle();
      if (version.read<int>('user_version') != 2)
        throw StateError('Upgrade version not committed');
    } finally {
      await upgraded.close();
    }
  }
  stdout.writeln(
    'Drift: failed-upgrade rollback, retry, preserved rows/relations and v2 reopen passed.',
  );
  stdout.writeln('Scratch database retained: ${file.path}');
}
