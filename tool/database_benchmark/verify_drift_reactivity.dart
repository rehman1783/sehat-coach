import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import 'lib/drift_store.dart';
import 'lib/fixture.dart';

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp(
    'sehat-drift-reactive-',
  );
  final adapter = DriftStore('${directory.path}/reactive.sqlite');
  final fixture = BenchmarkFixture();
  StreamSubscription<int>? subscription;
  try {
    await adapter.importFixture(fixture);
    final initial = await adapter.mealEnergyTotal();
    final changed = Completer<int>();
    subscription = adapter.db
        .tableUpdates(const TableUpdateQuery.onTableName('food'))
        .asyncMap((_) => adapter.mealEnergyTotal())
        .listen(
          (total) {
            if (!changed.isCompleted) changed.complete(total);
          },
          onError: (Object error, StackTrace stack) {
            if (!changed.isCompleted) changed.completeError(error, stack);
          },
        );
    await adapter.db.transaction(() async {
      await adapter.db.customStatement(
        'UPDATE food SET energy = energy + 10 WHERE id = 1',
      );
      // Explicit SQL requires explicit Drift invalidation; generated writes do this automatically.
      adapter.db.notifyUpdates({
        const TableUpdate('food', kind: UpdateKind.update),
      });
    });
    final observed = await changed.future.timeout(const Duration(seconds: 5));
    if (observed != initial + 10)
      throw StateError('Wrong reactive total: $observed');
    stdout.writeln(
      'Drift SQL invalidation stream: committed meal total +10 passed.',
    );
  } finally {
    await subscription?.cancel();
    await adapter.close();
  }
}
