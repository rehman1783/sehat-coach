import 'benchmark_contract.dart';
import 'fixture.dart';
import 'entities.dart';
import 'objectbox.g.dart';

class ObjectBoxStore implements BenchmarkStore {
  final Store store;
  ObjectBoxStore(String path)
    : store = Store(getObjectBoxModel(), directory: path);
  @override
  String get name => 'ObjectBox';
  @override
  Future<void> importFixture(BenchmarkFixture fixture) async {
    store.runInTransaction(TxMode.write, () {
      store.box<Food>().putMany(
        fixture.foods
            .map((f) => Food(id: f.id, name: f.name, energy: f.energy))
            .toList(),
      );
      store.box<Meal>().putMany(
        fixture.meals
            .map(
              (m) =>
                  Meal(id: m.id, servings: m.servings)
                    ..food.targetId = m.foodId,
            )
            .toList(),
      );
    });
  }

  @override
  Future<List<int>> searchPrefix(String prefix) async {
    final query = store
        .box<Food>()
        .query(Food_.name.startsWith(prefix, caseSensitive: true))
        .build();
    try {
      return query.findIds();
    } finally {
      query.close();
    }
  }

  @override
  Future<int> mealEnergyTotal() async => store.box<Meal>().getAll().fold<int>(
    0,
    (sum, meal) => sum + meal.food.target!.energy * meal.servings,
  );
  @override
  Future<void> injectFailedWrite() async {
    store.runInTransaction<void>(TxMode.write, () {
      final foods = store.box<Food>().getAll();
      for (final food in foods) {
        food.energy = 99999;
      }
      store.box<Food>().putMany(foods);
      store.box<Food>().put(
        Food(id: 999999, name: 'Rollback sentinel', energy: 1),
      );
      throw StateError('injected-write-failure');
    });
  }

  @override
  Future<void> close() async => store.close();
}
