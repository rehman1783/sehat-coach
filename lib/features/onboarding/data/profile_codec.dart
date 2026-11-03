import '../domain/models/onboarding_state.dart';

/// Versioned profile payload for future encrypted local storage and sync.
/// Enum names are persisted rather than ordinal positions.
class ProfileCodec {
  static const int schemaVersion = 1;

  static Map<String, Object?> encode(OnboardingState value) => {
    'schemaVersion': schemaVersion,
    'currentStep': value.currentStep,
    'language': value.language.name,
    'goal': value.goal?.name,
    'sex': value.sex.name,
    'unit': value.unit.name,
    'age': value.age,
    'heightCm': value.heightCm,
    'weightKg': value.weightKg,
    'targetWeightKg': value.targetWeightKg,
    'activityLevel': value.activityLevel.name,
    'goalPace': value.goalPace.name,
    'countryCode': value.countryCode,
    'country': value.country,
    'countryFlag': value.countryFlag,
    'city': value.city,
    'detectedVia': value.detectedVia,
    'currency': value.currency,
    'isDesiMarket': value.isDesiMarket,
    'kitchen': value.kitchen?.name,
    'conditions': value.conditions.map((condition) => condition.name).toList(),
    'coach': value.coach?.name,
    'calculatedCalories': value.calculatedCalories,
  };

  static OnboardingState decode(Map<String, Object?> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw const FormatException('Unsupported profile schema version');
    }
    T requiredEnum<T extends Enum>(Object? raw, List<T> values, String field) {
      if (raw is! String) throw FormatException('Invalid $field');
      for (final value in values) {
        if (value.name == raw) return value;
      }
      throw FormatException('Unknown $field');
    }

    T? optionalEnum<T extends Enum>(
      Object? raw,
      List<T> values,
      String field,
    ) => raw == null ? null : requiredEnum(raw, values, field);
    int integer(String field) {
      final raw = json[field];
      if (raw is! int) throw FormatException('Invalid $field');
      return raw;
    }

    String string(String field) {
      final raw = json[field];
      if (raw is! String) throw FormatException('Invalid $field');
      return raw;
    }

    bool boolean(String field) {
      final raw = json[field];
      if (raw is! bool) throw FormatException('Invalid $field');
      return raw;
    }

    final rawConditions = json['conditions'];
    if (rawConditions is! List) {
      throw const FormatException('Invalid conditions');
    }
    final conditions = rawConditions
        .map((raw) => requiredEnum(raw, HealthCondition.values, 'condition'))
        .toList();
    return OnboardingState(
      currentStep: integer('currentStep'),
      language: requiredEnum(json['language'], AppLanguage.values, 'language'),
      goal: optionalEnum(json['goal'], GoalType.values, 'goal'),
      sex: requiredEnum(json['sex'], BiologicalSex.values, 'sex'),
      unit: requiredEnum(json['unit'], UnitType.values, 'unit'),
      age: integer('age'),
      heightCm: integer('heightCm'),
      weightKg: integer('weightKg'),
      targetWeightKg: integer('targetWeightKg'),
      activityLevel: requiredEnum(
        json['activityLevel'],
        ActivityLevel.values,
        'activityLevel',
      ),
      goalPace: requiredEnum(json['goalPace'], GoalPace.values, 'goalPace'),
      countryCode: string('countryCode'),
      country: string('country'),
      countryFlag: string('countryFlag'),
      city: string('city'),
      detectedVia: string('detectedVia'),
      currency: string('currency'),
      isDesiMarket: boolean('isDesiMarket'),
      kitchen: optionalEnum(json['kitchen'], KitchenRoutine.values, 'kitchen'),
      conditions: conditions,
      coach: optionalEnum(json['coach'], CoachPersonality.values, 'coach'),
      calculatedCalories: integer('calculatedCalories'),
    );
  }
}
