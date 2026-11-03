class CustomFoodRecord {
  CustomFoodRecord({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.servingLabel,
    required this.unitCode,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    required this.revision,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.gramsPerServing,
    this.sodiumMilligrams,
  }) {
    _requireText(id, 'id');
    _requireText(ownerId, 'ownerId');
    _requireBoundedText(name, 'name', 160);
    _requireBoundedText(servingLabel, 'servingLabel', 80);
    _requireBoundedText(unitCode, 'unitCode', 40);
    _nonNegative(caloriesKcal, 'caloriesKcal');
    _nonNegative(proteinGrams, 'proteinGrams');
    _nonNegative(carbohydrateGrams, 'carbohydrateGrams');
    _nonNegative(fatGrams, 'fatGrams');
    if (gramsPerServing case final value?) _positive(value, 'gramsPerServing');
    if (sodiumMilligrams case final value?) {
      _nonNegative(value, 'sodiumMilligrams');
    }
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (!createdAtUtc.isUtc || !updatedAtUtc.isUtc) {
      throw ArgumentError('Custom food timestamps must be UTC');
    }
  }

  final String id;
  final String ownerId;
  final String name;
  final String servingLabel;
  final String unitCode;
  final double? gramsPerServing;
  final double caloriesKcal;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double? sodiumMilligrams;
  final int revision;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

enum FoodNotFoundStatus { pending, resolved, dismissed }

class FoodNotFoundRecord {
  FoodNotFoundRecord({
    required this.id,
    required this.ownerId,
    required this.searchText,
    required this.details,
    required this.status,
    required this.revision,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) {
    _requireText(id, 'id');
    _requireText(ownerId, 'ownerId');
    _requireBoundedText(searchText, 'searchText', 160);
    if (details.length > 1000) throw ArgumentError('Details are too long');
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (!createdAtUtc.isUtc || !updatedAtUtc.isUtc) {
      throw ArgumentError('Food note timestamps must be UTC');
    }
  }

  final String id;
  final String ownerId;
  final String searchText;
  final String details;
  final FoodNotFoundStatus status;
  final int revision;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

abstract interface class UserFoodRecordRepository {
  Future<void> saveCustomFood(CustomFoodRecord record);
  Future<void> saveNotFound(FoodNotFoundRecord record);
  Future<List<CustomFoodRecord>> searchCustomFoods(String query);
  Future<List<FoodNotFoundRecord>> pendingNotFound();
}

void _requireText(String value, String name) {
  if (value.trim().isEmpty) throw ArgumentError.value(value, name);
}

void _requireBoundedText(String value, String name, int maximum) {
  _requireText(value, name);
  if (value.length > maximum) throw ArgumentError('$name is too long');
}

void _positive(double value, String name) {
  if (!value.isFinite || value <= 0) throw ArgumentError.value(value, name);
}

void _nonNegative(double value, String name) {
  if (!value.isFinite || value < 0) throw ArgumentError.value(value, name);
}
