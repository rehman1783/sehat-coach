/// Synthetic fixtures only: these values are not nutritional advice or a catalog.
class BenchmarkFood {
  final int id;
  final String name;
  final int energy;
  const BenchmarkFood(this.id, this.name, this.energy);
}

class BenchmarkMeal {
  final int id;
  final int foodId;
  final int servings;
  const BenchmarkMeal(this.id, this.foodId, this.servings);
}

class BenchmarkFixture {
  final List<BenchmarkFood> foods;
  final List<BenchmarkMeal> meals;

  BenchmarkFixture({int foodCount = 10000, int mealCount = 2000})
    : foods = List.generate(foodCount, (i) {
        const names = ['Daal', 'Roti', 'Chawal', 'Biryani', 'Sabzi'];
        return BenchmarkFood(
          i + 1,
          '${names[i % names.length]} variant $i',
          100 + i % 400,
        );
      }),
      meals = List.generate(
        mealCount,
        (i) => BenchmarkMeal(i + 1, i % foodCount + 1, i % 3 + 1),
      );

  int get expectedTotal => meals.fold(
    0,
    (sum, meal) => sum + foods[meal.foodId - 1].energy * meal.servings,
  );
}
