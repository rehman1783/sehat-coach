import 'catalog_food.dart';

class FoodSearchQuery {
  FoodSearchQuery(String raw, {this.limit = 20}) : text = raw.trim() {
    if (text.isEmpty) throw ArgumentError('Search text is required');
    if (text.length > 120) throw ArgumentError('Search text is too long');
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit');
    }
  }

  final String text;
  final int limit;
}

abstract interface class OfflineFoodCatalogRepository {
  /// Returns only foods from the active, approved immutable catalog release.
  Future<List<CatalogFood>> search(FoodSearchQuery query);

  Future<CatalogFood?> findApprovedById(String foodId);
}
