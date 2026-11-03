import 'dart:convert';
import 'dart:io';

import 'lib/benchmark_contract.dart';
import 'lib/fixture.dart';
import 'lib/drift_store.dart';
import 'lib/objectbox_store.dart';

Future<void> main() async {
  final fixture = BenchmarkFixture();
  final directory = await Directory.systemTemp.createTemp(
    'sehat-db-benchmark-',
  );
  // Retain scratch data for diagnosis; never touch app/user databases.
  stderr.writeln('Scratch directory: ${directory.path}');
  for (var repetition = 0; repetition < 5; repetition++) {
    for (final candidate in ['drift', 'objectbox']) {
      try {
        final BenchmarkStore store = candidate == 'drift'
            ? DriftStore('${directory.path}/drift-$repetition.sqlite')
            : ObjectBoxStore('${directory.path}/objectbox-$repetition');
        final result = await runBenchmark(store, fixture);
        stdout.writeln(
          jsonEncode({'repetition': repetition, ...result.toJson()}),
        );
      } catch (error) {
        stderr.writeln('$candidate repetition $repetition failed: $error');
        exitCode = 1;
      }
    }
  }
}
