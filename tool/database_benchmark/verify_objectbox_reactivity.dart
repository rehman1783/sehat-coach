import 'dart:async';
import 'dart:io';

import 'lib/entities.dart';
import 'lib/objectbox.g.dart';

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp('sehat-reactive-');
  final store = Store(getObjectBoxModel(), directory: directory.path);
  final foods = store.box<Food>();
  final first = Completer<void>();
  final changed = Completer<void>();
  final values = <int>[];
  StreamSubscription<Query<Food>>? subscription;
  try {
    final id = foods.put(Food(name: 'Synthetic food', energy: 100));
    subscription = foods
        .query()
        .watch(triggerImmediately: true)
        .listen(
          (query) {
            final total = query.find().fold<int>(
              0,
              (sum, food) => sum + food.energy,
            );
            values.add(total);
            if (total == 100 && !first.isCompleted) first.complete();
            if (total == 250 && !changed.isCompleted) changed.complete();
          },
          onError: (Object error, StackTrace stack) {
            if (!first.isCompleted) first.completeError(error, stack);
            if (!changed.isCompleted) changed.completeError(error, stack);
          },
        );
    await first.future.timeout(const Duration(seconds: 5));
    foods.put(Food(id: id, name: 'Synthetic food', energy: 250));
    await changed.future.timeout(const Duration(seconds: 5));
    if (values.first != 100 || values.last != 250)
      throw StateError('Wrong reactive values: $values');
    stdout.writeln(
      'ObjectBox native query stream: initial 100 -> updated 250 passed.',
    );
  } finally {
    await subscription?.cancel();
    store.close();
  }
}
