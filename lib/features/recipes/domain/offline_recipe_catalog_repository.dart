import 'catalog_recipe.dart';

class RecipeSearchQuery {
  RecipeSearchQuery(String raw, {this.limit = 20}) : text = raw.trim() {
    if (text.isEmpty) throw ArgumentError('Search text is required');
    if (text.length > 120) throw ArgumentError('Search text is too long');
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit');
    }
  }

  final String text;
  final int limit;
}

abstract interface class OfflineRecipeCatalogRepository {
  /// Returns fully hydrated recipes from the active approved catalog release.
  Future<List<CatalogRecipe>> search(RecipeSearchQuery query);

  Future<CatalogRecipe?> findApprovedById(String recipeId);
}
