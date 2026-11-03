import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/data/profile_codec.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test('all onboarding answers survive JSON round trip', () {
    final input = OnboardingState(
      currentStep: 8,
      language: AppLanguage.romanUrdu,
      goal: GoalType.buildMuscle,
      sex: BiologicalSex.female,
      unit: UnitType.imperial,
      age: 38,
      heightCm: 160,
      weightKg: 63,
      targetWeightKg: 68,
      activityLevel: ActivityLevel.veryActive,
      goalPace: GoalPace.standard,
      countryCode: 'PK',
      country: 'Pakistan',
      countryFlag: '🇵🇰',
      city: 'Multan',
      detectedVia: 'manual',
      currency: 'PKR',
      isDesiMarket: false,
      kitchen: KitchenRoutine.hostelMess,
      conditions: [HealthCondition.diabetes, HealthCondition.clinicianPlan],
      coach: CoachPersonality.gentle,
      calculatedCalories: 2040,
    );
    final restored = ProfileCodec.decode(
      (jsonDecode(jsonEncode(ProfileCodec.encode(input))) as Map)
          .cast<String, Object?>(),
    );
    expect(ProfileCodec.encode(restored), ProfileCodec.encode(input));
    expect(restored.allowsGenericCalorieEstimate, isFalse);
    restored.conditions.clear();
    expect(input.conditions, hasLength(2));
  });

  test('future version and unknown safety-critical enum are rejected', () {
    final payload = ProfileCodec.encode(OnboardingState());
    expect(
      () => ProfileCodec.decode({...payload, 'schemaVersion': 2}),
      throwsFormatException,
    );
    expect(
      () => ProfileCodec.decode({
        ...payload,
        'conditions': ['unknown'],
      }),
      throwsFormatException,
    );
    expect(
      () => ProfileCodec.decode({...payload, 'age': '25'}),
      throwsFormatException,
    );
  });
}
