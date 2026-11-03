import 'dart:io';

import 'lib/benchmark_contract.dart';
import 'lib/fixture.dart';
import 'lib/drift_store.dart';
import 'lib/objectbox_store.dart';

Future<void> assertPreserved(
  BenchmarkStore store,
  BenchmarkFixture fixture,
) async {
  if (await store.mealEnergyTotal() != fixture.expectedTotal ||
      (await store.searchPrefix('Rollback sentinel')).isNotEmpty ||
      (await store.searchPrefix('Daal')).length != 2000) {
    throw StateError('${store.name}: records changed after failure/reopen');
  }
}

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp(
    'sehat-db-integrity-',
  );
  final fixture = BenchmarkFixture();
  for (final candidate in ['drift', 'objectbox']) {
    BenchmarkStore open() => candidate == 'drift'
        ? DriftStore('${directory.path}/drift.sqlite')
        : ObjectBoxStore('${directory.path}/objectbox');
    var store = open();
    try {
      await store.importFixture(fixture);
      var sawInjectedFailure = false;
      try {
        await store.injectFailedWrite();
      } on StateError catch (error) {
        if (error.message != 'injected-write-failure') rethrow;
        sawInjectedFailure = true;
      }
      if (!sawInjectedFailure) throw StateError('Fault was not injected');
      await assertPreserved(store, fixture);
    } finally {
      await store.close();
    }
    store = open();
    try {
      await assertPreserved(store, fixture);
      stdout.writeln('${store.name}: rollback and persisted reopen passed');
    } finally {
      await store.close();
    }
  }
  stdout.writeln('Scratch stores retained: ${directory.path}');
}
