import 'package:flutter/foundation.dart';
import '../../../../core/services/geo_detector.dart';
import '../../domain/models/location_data.dart';
import '../../domain/models/onboarding_state.dart';

class OnboardingController extends ChangeNotifier {
  final OnboardingState _state = OnboardingState();

  OnboardingController() {
    initializeGeoLocation();
  }

  OnboardingState get state => _state;

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
    _state.age = age;
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

  void setCountry(String country, String flag, {String? defaultCity, String? code}) {
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

  void setCondition(HealthCondition cond) {
    _state.conditions = [cond];
    notifyListeners();
  }

  void toggleCondition(HealthCondition cond) => setCondition(cond);

  void setCoach(CoachPersonality coach) {
    _state.coach = coach;
    notifyListeners();
  }

  /// Calculates final BMR & TDEE using the Mifflin-St Jeor equation
  void computeFinalBlueprint() {
    double bmr = (10 * _state.weightKg) + (6.25 * _state.heightCm) - (5 * _state.age);
    bmr += (_state.sex == BiologicalSex.male) ? 5 : -161;

    double tdee = bmr * 1.35; // Moderate activity multiplier

    if (_state.goal == GoalType.dropFat) {
      tdee -= 450;
    } else if (_state.goal == GoalType.buildMuscle) {
      tdee += 300;
    }

    _state.calculatedCalories = tdee.round();
    notifyListeners();
  }
}
