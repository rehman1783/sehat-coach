import '../../meals/domain/nutrition_calculator.dart';
import '../../recipes/domain/catalog_recipe.dart' show RecipeOilTreatment;

class CustomRecipeRecord {
  CustomRecipeRecord({
    required this.id,
    required this.ownerId,
    required this.name,
    required Iterable<MealItemCalculationSnapshot> ingredients,
    required this.yieldServingsMinimum,
    required this.yieldServingsMaximum,
    required this.oilTreatment,
    required this.revision,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) : ingredients = List.unmodifiable(ingredients) {
    if (id.trim().isEmpty || ownerId.trim().isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Custom recipe identity and name are required');
    }
    if (name.length > 160) throw ArgumentError('Recipe name is too long');
    if (ingredients.isEmpty) {
      throw ArgumentError('Custom recipe requires at least one ingredient');
    }
    if (!yieldServingsMinimum.isFinite || yieldServingsMinimum <= 0) {
      throw ArgumentError.value(yieldServingsMinimum, 'yieldServingsMinimum');
    }
    if (!yieldServingsMaximum.isFinite ||
        yieldServingsMaximum < yieldServingsMinimum) {
      throw ArgumentError.value(yieldServingsMaximum, 'yieldServingsMaximum');
    }
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (!createdAtUtc.isUtc || !updatedAtUtc.isUtc) {
      throw ArgumentError('Custom recipe timestamps must be UTC');
    }
  }

  final String id;
  final String ownerId;
  final String name;
  final List<MealItemCalculationSnapshot> ingredients;
  final double yieldServingsMinimum;
  final double yieldServingsMaximum;
  final RecipeOilTreatment oilTreatment;
  final int revision;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

abstract interface class CustomRecipeRepository {
  Future<void> save(CustomRecipeRecord recipe);
  Future<List<CustomRecipeRecord>> search(String query);
}
