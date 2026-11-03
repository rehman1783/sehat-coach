import 'fixture.dart';

/// Each adapter must use a fresh store and release native resources in close.
abstract interface class BenchmarkStore {
  String get name;
  Future<void> importFixture(BenchmarkFixture fixture);
  Future<List<int>> searchPrefix(String prefix);
  Future<int> mealEnergyTotal();
  Future<void> injectFailedWrite();
  Future<void> close();
}

class BenchmarkResult {
  final String candidate;
  final int importMicroseconds;
  final List<int> searchMicroseconds;
  final int aggregationMicroseconds;
  const BenchmarkResult(
    this.candidate,
    this.importMicroseconds,
    this.searchMicroseconds,
    this.aggregationMicroseconds,
  );

  Map<String, Object> toJson() => {
    'candidate': candidate,
    'import_us': importMicroseconds,
    'search_samples_us': searchMicroseconds,
    'aggregation_us': aggregationMicroseconds,
    'correctness': 'passed',
  };
}

/// Results are returned only after queries pass deterministic correctness checks.
Future<BenchmarkResult> runBenchmark(
  BenchmarkStore store,
  BenchmarkFixture fixture,
) async {
  final timer = Stopwatch();
  try {
    timer.start();
    await store.importFixture(fixture);
    timer.stop();
    final importTime = timer.elapsedMicroseconds;
    const prefixes = ['Daal', 'Roti', 'Chawal', 'Biryani', 'Sabzi', 'Missing'];
    for (final prefix in prefixes) {
      await store.searchPrefix(prefix); // Warm up both engines equally.
    }
    final samples = <int>[];
    for (var repeat = 0; repeat < 10; repeat++) {
      for (final prefix in prefixes) {
        timer
          ..reset()
          ..start();
        final actual = await store.searchPrefix(prefix);
        timer.stop();
        samples.add(timer.elapsedMicroseconds);
        final expected =
            fixture.foods
                .where((food) => food.name.startsWith(prefix))
                .map((food) => food.id)
                .toList()
              ..sort();
        final sorted = List<int>.of(actual)..sort();
        if (sorted.length != expected.length ||
            List.generate(
              expected.length,
              (i) => sorted[i] == expected[i],
            ).contains(false)) {
          throw StateError(
            '${store.name}: incorrect prefix results for $prefix',
          );
        }
      }
    }
    timer
      ..reset()
      ..start();
    final total = await store.mealEnergyTotal();
    timer.stop();
    if (total != fixture.expectedTotal) {
      throw StateError('${store.name}: incorrect relational total');
    }
    return BenchmarkResult(
      store.name,
      importTime,
      samples,
      timer.elapsedMicroseconds,
    );
  } finally {
    await store.close();
  }
}
