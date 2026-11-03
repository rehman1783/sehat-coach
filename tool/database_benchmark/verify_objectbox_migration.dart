import 'dart:io';

import 'lib/entities.dart';
import 'lib/objectbox.g.dart' as v2;
import 'lib/objectbox_v1.g.dart' as v1;

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp(
    'sehat-obx-migration-',
  );
  final oldStore = v1.Store(v1.getObjectBoxModel(), directory: directory.path);
  try {
    oldStore.box<Food>().put(Food(id: 1, name: 'Synthetic food', energy: 120));
    oldStore.box<Meal>().put(Meal(id: 1, servings: 2)..food.targetId = 1);
  } finally {
    oldStore.close();
  }
  for (var reopen = 0; reopen < 2; reopen++) {
    final store = v2.Store(v2.getObjectBoxModel(), directory: directory.path);
    try {
      final food = store.box<Food>().get(1)!;
      final meal = store.box<Meal>().get(1)!;
      if (food.name != 'Synthetic food' ||
          food.energy != 120 ||
          meal.food.targetId != 1 ||
          meal.servings * meal.food.target!.energy != 240) {
        throw StateError('Schema upgrade changed existing records or relation');
      }
      if (reopen == 0) {
        if (food.source != null && food.source != '')
          throw StateError('Unexpected added-field default');
        food.source = 'synthetic';
        store.box<Food>().put(food);
      } else if (food.source != 'synthetic') {
        throw StateError('New field did not persist');
      }
    } finally {
      store.close();
    }
  }
  stdout.writeln(
    'ObjectBox additive schema evolution: old data/relation preserved and new field persisted after reopen.',
  );
  stdout.writeln('Scratch store retained: ${directory.path}');
}
