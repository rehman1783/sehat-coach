import 'package:get/get.dart';

import '../../domain/user_food_commands.dart';
import '../../domain/user_food_records.dart';

class UserFoodEntryController extends GetxController {
  factory UserFoodEntryController({
    required CreateCustomFoodUseCase createCustomFood,
    required SaveFoodNotFoundUseCase saveNotFound,
  }) => UserFoodEntryController._(createCustomFood, saveNotFound);

  UserFoodEntryController._(this._createCustomFood, this._saveNotFound);

  final CreateCustomFoodUseCase _createCustomFood;
  final SaveFoodNotFoundUseCase _saveNotFound;

  final isSaving = false.obs;
  final errorMessage = RxnString();
  final savedCustomFood = Rxn<CustomFoodRecord>();
  final savedNotFound = Rxn<FoodNotFoundRecord>();

  Future<CustomFoodRecord?> create({
    required String name,
    required String servingLabel,
    required String unitCode,
    required String calories,
    required String protein,
    required String carbohydrates,
    required String fat,
    String grams = '',
    String sodium = '',
  }) async {
    if (isSaving.value) return null;
    errorMessage.value = null;
    final parsed = _parseNutrition(
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fat: fat,
      grams: grams,
      sodium: sodium,
    );
    if (name.trim().isEmpty ||
        servingLabel.trim().isEmpty ||
        unitCode.trim().isEmpty ||
        parsed == null) {
      errorMessage.value = 'Enter a name, serving, unit and valid non-negative nutrition values.';
      return null;
    }
    isSaving.value = true;
    try {
      final record = await _createCustomFood.execute(
        CreateCustomFoodCommand(
          name: name,
          servingLabel: servingLabel,
          unitCode: unitCode,
          caloriesKcal: parsed.calories,
          proteinGrams: parsed.protein,
          carbohydrateGrams: parsed.carbohydrates,
          fatGrams: parsed.fat,
          gramsPerServing: parsed.grams,
          sodiumMilligrams: parsed.sodium,
        ),
      );
      savedCustomFood.value = record;
      return record;
    } on Object {
      errorMessage.value =
          'Custom food could not be saved. Your entries remain here.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<FoodNotFoundRecord?> saveMissing({
    required String searchText,
    String details = '',
  }) async {
    if (isSaving.value) return null;
    errorMessage.value = null;
    if (searchText.trim().isEmpty) {
      errorMessage.value = 'Enter the food name you could not find.';
      return null;
    }
    isSaving.value = true;
    try {
      final record = await _saveNotFound.execute(
        searchText: searchText,
        details: details,
      );
      savedNotFound.value = record;
      return record;
    } on Object {
      errorMessage.value = 'The note could not be saved. Please try again.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}

_ParsedNutrition? _parseNutrition({
  required String calories,
  required String protein,
  required String carbohydrates,
  required String fat,
  required String grams,
  required String sodium,
}) {
  final required = [
    calories,
    protein,
    carbohydrates,
    fat,
  ].map((value) => double.tryParse(value.trim())).toList();
  if (required.any((value) => value == null || !value.isFinite || value < 0)) {
    return null;
  }
  double? optional(String raw, {bool positive = false}) {
    if (raw.trim().isEmpty) return null;
    final value = double.tryParse(raw.trim());
    if (value == null ||
        !value.isFinite ||
        value < 0 ||
        (positive && value <= 0)) {
      throw const FormatException();
    }
    return value;
  }

  try {
    return _ParsedNutrition(
      calories: required[0]!,
      protein: required[1]!,
      carbohydrates: required[2]!,
      fat: required[3]!,
      grams: optional(grams, positive: true),
      sodium: optional(sodium),
    );
  } on FormatException {
    return null;
  }
}

class _ParsedNutrition {
  const _ParsedNutrition({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.grams,
    required this.sodium,
  });

  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double? grams;
  final double? sodium;
}
