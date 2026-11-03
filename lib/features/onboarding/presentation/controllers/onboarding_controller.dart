import 'package:get/get.dart';

import '../../../../core/services/geo_detector.dart';
import '../../domain/models/location_data.dart';
import '../../domain/models/onboarding_state.dart';

class OnboardingController extends GetxController {
  final OnboardingState _state = OnboardingState();
  bool _adultAgeConfirmed = false;

  OnboardingController({bool detectLocation = true}) {
    if (detectLocation) {
      initializeGeoLocation();
    }
  }

  OnboardingState get state => _state;
  bool get adultAgeConfirmed => _adultAgeConfirmed && _state.age >= 18;

  // Compatibility bridge for the existing form setters during GetX migration.
  void notifyListeners() {
    if (!isClosed) update();
  }

  /// Runs the 3-Tier Zero-Permission Geolocation Detection Cascade
  Future<void> initializeGeoLocation() async {
    // Synchronous Tier 1 Check
    final tier1 = GeoDetector.detectTier1();
    if (tier1 != null) {
      _applyDetectedLocation(tier1);
    }

    // Background Async Tier 2 Check (IP Fallback)
    final location = await GeoDetector.detectLocation();
    _applyDetectedLocation(location);
  }

  void _applyDetectedLocation(DetectedLocation loc) {
    if (isClosed || _state.detectedVia == 'user_selected') return;
    _state.countryCode = loc.countryCode;
    _state.country = loc.countryName;
    _state.city = loc.city;
    _state.detectedVia = loc.detectedVia;
    _state.currency = loc.currency;
    _state.isDesiMarket = loc.isDesiMarket;

    final countryData = LocationRepository.findByCode(loc.countryCode);
    _state.countryFlag = countryData.flag;

    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _state.language = lang;
    notifyListeners();
  }

  void setGoal(GoalType goal) {
    _state.goal = goal;
    notifyListeners();
  }

  void setSex(BiologicalSex sex) {
    _state.sex = sex;
    notifyListeners();
  }

  void setUnit(UnitType unit) {
    _state.unit = unit;
    notifyListeners();
  }

  void setAge(int age) {
    if (_state.age != age) _adultAgeConfirmed = false;
    _state.age = age;
    notifyListeners();
  }

  void confirmAdultAge(bool confirmed) {
    _adultAgeConfirmed = confirmed && _state.age >= 18;
    notifyListeners();
  }

  void setHeight(int heightCm) {
    _state.heightCm = heightCm;
    notifyListeners();
  }

  void setWeight(int weightKg) {
    _state.weightKg = weightKg;
    notifyListeners();
  }

  void setTargetWeight(int weightKg) {
    _state.targetWeightKg = weightKg;
    notifyListeners();
  }

  void setActivityLevel(ActivityLevel level) {
    _state.activityLevel = level;
    notifyListeners();
  }

  void setGoalPace(GoalPace pace) {
    _state.goalPace = pace;
    notifyListeners();
  }

  void setCountry(
    String country,
    String flag, {
    String? defaultCity,
    String? code,
  }) {
    _state.country = country;
    _state.countryFlag = flag;
    _state.detectedVia = 'user_selected';
    if (code != null && code.isNotEmpty) {
      _state.countryCode = code;
    }
    if (defaultCity != null && defaultCity.isNotEmpty) {
      _state.city = defaultCity;
    }
    notifyListeners();
  }

  void setCity(String city) {
    _state.city = city;
    _state.detectedVia = 'user_selected';
    notifyListeners();
  }

  void setKitchen(KitchenRoutine kitchen) {
    _state.kitchen = kitchen;
    notifyListeners();
  }

  void toggleCondition(HealthCondition condition) {
    if (condition == HealthCondition.standard) {
      _state.conditions = _state.conditions.contains(condition)
          ? []
          : [HealthCondition.standard];
    } else {
      _state.conditions.remove(HealthCondition.standard);
      if (condition == HealthCondition.pregnancy) {
        _state.conditions.remove(HealthCondition.breastfeeding);
      } else if (condition == HealthCondition.breastfeeding) {
        _state.conditions.remove(HealthCondition.pregnancy);
      }
      if (_state.conditions.contains(condition)) {
        _state.conditions.remove(condition);
      } else {
        _state.conditions.add(condition);
      }
    }
    notifyListeners();
  }

  void setCoach(CoachPersonality coach) {
    _state.coach = coach;
    notifyListeners();
  }

  /// Calculates final BMR & TDEE using the Mifflin-St Jeor equation
  void computeFinalBlueprint() {
    if (!adultAgeConfirmed || !_state.allowsGenericCalorieEstimate) {
      _state.calculatedCalories = 0;
      notifyListeners();
      return;
    }

    double bmr =
        (10 * _state.weightKg) + (6.25 * _state.heightCm) - (5 * _state.age);
    bmr += (_state.sex == BiologicalSex.male) ? 5 : -161;

    final activityMultiplier = switch (_state.activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.light => 1.375,
      ActivityLevel.moderate => 1.55,
      ActivityLevel.veryActive => 1.725,
    };
    final tdee = bmr * activityMultiplier;

    _state.calculatedCalories = tdee.round();
    notifyListeners();
  }
}
