enum GoalType { dropFat, buildMuscle, stayHealthy }

enum BiologicalSex { male, female }

enum UnitType { metric, imperial }

enum ActivityLevel { sedentary, light, moderate, veryActive }

enum GoalPace { gentle, standard }

enum KitchenRoutine { homeFamily, cookMyself, hostelMess, takeout }

enum HealthCondition {
  ramadan,
  diabetes,
  bp,
  pregnancy,
  breastfeeding,
  clinicianPlan,
  standard,
}

enum CoachPersonality { ammi, direct, gentle }

enum AppLanguage { english, romanUrdu }

class OnboardingState {
  int currentStep;
  AppLanguage language;
  GoalType? goal;
  BiologicalSex sex;
  UnitType unit;
  int age;
  int heightCm;
  int weightKg;
  int targetWeightKg;
  ActivityLevel activityLevel;
  GoalPace goalPace;
  String countryCode;
  String country;
  String countryFlag;
  String city;
  String detectedVia;
  String currency;
  bool isDesiMarket;
  KitchenRoutine? kitchen;
  List<HealthCondition> conditions;
  CoachPersonality? coach;
  int calculatedCalories;

  OnboardingState({
    this.currentStep = 1,
    this.language = AppLanguage.english,
    this.goal,
    this.sex = BiologicalSex.male,
    this.unit = UnitType.metric,
    this.age = 25,
    this.heightCm = 172,
    this.weightKg = 70,
    this.targetWeightKg = 65,
    this.activityLevel = ActivityLevel.moderate,
    this.goalPace = GoalPace.gentle,
    this.countryCode = 'PK',
    this.country = 'Pakistan',
    this.countryFlag = '🇵🇰',
    this.city = 'Lahore',
    this.detectedVia = 'locale_timezone',
    this.currency = 'PKR',
    this.isDesiMarket = true,
    this.kitchen,
    List<HealthCondition>? conditions,
    this.coach,
    this.calculatedCalories = 1820,
  }) : conditions = conditions ?? [];

  bool get allowsGenericCalorieEstimate =>
      !conditions.contains(HealthCondition.pregnancy) &&
      !conditions.contains(HealthCondition.breastfeeding) &&
      !conditions.contains(HealthCondition.clinicianPlan);

  // Calculated getters
  int get proteinGrams => ((calculatedCalories * 0.30) / 4).round();
  int get carbsGrams => ((calculatedCalories * 0.45) / 4).round();
  int get fatGrams => ((calculatedCalories * 0.25) / 9).round();

  String get coachName {
    if (language == AppLanguage.english) {
      switch (coach) {
        case CoachPersonality.ammi:
          return 'Caring Parent';
        case CoachPersonality.direct:
          return 'Direct Coach';
        case CoachPersonality.gentle:
          return 'Gentle Coach';
        case null:
          return 'Caring Parent';
      }
    } else {
      switch (coach) {
        case CoachPersonality.ammi:
          return 'Desi Ammi Mode';
        case CoachPersonality.direct:
          return 'Direct Coach';
        case CoachPersonality.gentle:
          return 'Gentle Coach';
        case null:
          return 'Desi Ammi Mode';
      }
    }
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'location': {
        'countryCode': countryCode,
        'countryName': country,
        'city': city,
        'detectedVia': detectedVia,
        'currency': currency,
        'isDesiMarket': isDesiMarket,
      },
    };
  }

  OnboardingState copyWith({
    int? currentStep,
    GoalType? goal,
    BiologicalSex? sex,
    UnitType? unit,
    int? age,
    int? heightCm,
    int? weightKg,
    int? targetWeightKg,
    ActivityLevel? activityLevel,
    GoalPace? goalPace,
    AppLanguage? language,
    String? countryCode,
    String? country,
    String? countryFlag,
    String? city,
    String? detectedVia,
    String? currency,
    bool? isDesiMarket,
    KitchenRoutine? kitchen,
    List<HealthCondition>? conditions,
    CoachPersonality? coach,
    int? calculatedCalories,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      language: language ?? this.language,
      goal: goal ?? this.goal,
      sex: sex ?? this.sex,
      unit: unit ?? this.unit,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goalPace: goalPace ?? this.goalPace,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      countryFlag: countryFlag ?? this.countryFlag,
      city: city ?? this.city,
      detectedVia: detectedVia ?? this.detectedVia,
      currency: currency ?? this.currency,
      isDesiMarket: isDesiMarket ?? this.isDesiMarket,
      kitchen: kitchen ?? this.kitchen,
      conditions: conditions ?? this.conditions,
      coach: coach ?? this.coach,
      calculatedCalories: calculatedCalories ?? this.calculatedCalories,
    );
  }
}
