enum GoalType { dropFat, buildMuscle, stayHealthy }

enum BiologicalSex { male, female }

enum UnitType { metric, imperial }

enum KitchenRoutine { homeFamily, cookMyself, hostelMess, takeout }

enum HealthCondition { ramadan, diabetes, bp, standard }

enum CoachPersonality { ammi, direct, gentle }

class OnboardingState {
  int currentStep;
  GoalType? goal;
  BiologicalSex sex;
  UnitType unit;
  int age;
  int heightCm;
  int weightKg;
  String country;
  String countryFlag;
  String city;
  KitchenRoutine? kitchen;
  List<HealthCondition> conditions;
  CoachPersonality? coach;
  int calculatedCalories;

  OnboardingState({
    this.currentStep = 1,
    this.goal,
    this.sex = BiologicalSex.male,
    this.unit = UnitType.metric,
    this.age = 25,
    this.heightCm = 172,
    this.weightKg = 70,
    this.country = 'Pakistan',
    this.countryFlag = '🇵🇰',
    this.city = 'Lahore',
    this.kitchen,
    List<HealthCondition>? conditions,
    this.coach,
    this.calculatedCalories = 1820,
  }) : conditions = conditions ?? [];

  // Calculated getters
  int get proteinGrams => ((calculatedCalories * 0.30) / 4).round();
  int get carbsGrams => ((calculatedCalories * 0.45) / 4).round();
  int get fatGrams => ((calculatedCalories * 0.25) / 9).round();

  String get coachName {
    switch (coach) {
      case CoachPersonality.ammi:
        return 'Ammi Routine';
      case CoachPersonality.direct:
        return 'Direct Coach';
      case CoachPersonality.gentle:
        return 'Gentle Coach';
      case null:
        return 'Ammi Routine';
    }
  }

  OnboardingState copyWith({
    int? currentStep,
    GoalType? goal,
    BiologicalSex? sex,
    UnitType? unit,
    int? age,
    int? heightCm,
    int? weightKg,
    String? country,
    String? countryFlag,
    String? city,
    KitchenRoutine? kitchen,
    List<HealthCondition>? conditions,
    CoachPersonality? coach,
    int? calculatedCalories,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      goal: goal ?? this.goal,
      sex: sex ?? this.sex,
      unit: unit ?? this.unit,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      country: country ?? this.country,
      countryFlag: countryFlag ?? this.countryFlag,
      city: city ?? this.city,
      kitchen: kitchen ?? this.kitchen,
      conditions: conditions ?? this.conditions,
      coach: coach ?? this.coach,
      calculatedCalories: calculatedCalories ?? this.calculatedCalories,
    );
  }
}
