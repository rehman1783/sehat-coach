import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/goals/domain/daily_goal_progress.dart';
import 'package:sehat_coach/features/meals/domain/nutrition_calculator.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test('builds transparent progress ranges from profile planning estimate', () {
    final plan = DailyGoalPlan.fromProfile(
      OnboardingState(goal: GoalType.buildMuscle, calculatedCalories: 2000),
    );
    final progress = DailyGoalProgress(
      plan: plan,
      logged: NutritionRangeSnapshot(
        caloriesKcal: ValueRange(900, 1100),
        proteinGrams: ValueRange(60, 75),
        carbohydrateGrams: ValueRange(100, 120),
        fatGrams: ValueRange(30, 40),
        sodiumMilligrams: null,
      ),
    );

    expect(plan.availability, GoalEstimateAvailability.planningEstimate);
    expect(plan.energyKcal, 2000);
    expect(plan.proteinGrams, 150);
    expect(progress.energyFraction?.minimum, 0.45);
    expect(progress.energyFraction?.maximum, 0.55);
    expect(progress.proteinFraction?.minimum, 0.4);
    expect(progress.proteinFraction?.maximum, 0.5);
  });

  test('pauses automatic targets when clinician guidance is required', () {
    final profile = OnboardingState(
      goal: GoalType.dropFat,
      calculatedCalories: 1800,
      conditions: [HealthCondition.clinicianPlan],
    );

    final plan = DailyGoalPlan.fromProfile(profile);
    final progress = DailyGoalProgress(plan: plan, logged: null);

    expect(
      plan.availability,
      GoalEstimateAvailability.clinicianGuidanceRequired,
    );
    expect(plan.energyKcal, isNull);
    expect(progress.energyFraction, isNull);
  });

  test('does not expose a target when onboarding estimate is invalid', () {
    final plan = DailyGoalPlan.fromProfile(
      OnboardingState(calculatedCalories: 0),
    );

    expect(plan.hasPlanningEstimate, isFalse);
    expect(plan.proteinGrams, isNull);
  });
}
