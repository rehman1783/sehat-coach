import '../../meals/domain/nutrition_calculator.dart';
import '../../onboarding/domain/models/onboarding_state.dart';

enum GoalEstimateAvailability { planningEstimate, clinicianGuidanceRequired }

class DailyGoalPlan {
  const DailyGoalPlan._({
    required this.availability,
    required this.goal,
    required this.energyKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
  });

  factory DailyGoalPlan.fromProfile(OnboardingState profile) {
    if (!profile.allowsGenericCalorieEstimate ||
        profile.calculatedCalories <= 0) {
      return DailyGoalPlan._(
        availability: GoalEstimateAvailability.clinicianGuidanceRequired,
        goal: profile.goal,
        energyKcal: null,
        proteinGrams: null,
        carbohydrateGrams: null,
        fatGrams: null,
      );
    }
    return DailyGoalPlan._(
      availability: GoalEstimateAvailability.planningEstimate,
      goal: profile.goal,
      energyKcal: profile.calculatedCalories.toDouble(),
      proteinGrams: profile.proteinGrams.toDouble(),
      carbohydrateGrams: profile.carbsGrams.toDouble(),
      fatGrams: profile.fatGrams.toDouble(),
    );
  }

  final GoalEstimateAvailability availability;
  final GoalType? goal;
  final double? energyKcal;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;

  bool get hasPlanningEstimate =>
      availability == GoalEstimateAvailability.planningEstimate;
}

class ProgressRange {
  const ProgressRange({required this.minimum, required this.maximum});

  final double minimum;
  final double maximum;
}

class DailyGoalProgress {
  const DailyGoalProgress({required this.plan, required this.logged});

  final DailyGoalPlan plan;
  final NutritionRangeSnapshot? logged;

  ProgressRange? get energyFraction => _fraction(
    logged?.caloriesKcal.minimum,
    logged?.caloriesKcal.maximum,
    plan.energyKcal,
  );

  ProgressRange? get proteinFraction => _fraction(
    logged?.proteinGrams.minimum,
    logged?.proteinGrams.maximum,
    plan.proteinGrams,
  );

  ProgressRange? get carbohydrateFraction => _fraction(
    logged?.carbohydrateGrams.minimum,
    logged?.carbohydrateGrams.maximum,
    plan.carbohydrateGrams,
  );

  ProgressRange? get fatFraction => _fraction(
    logged?.fatGrams.minimum,
    logged?.fatGrams.maximum,
    plan.fatGrams,
  );

  ProgressRange? _fraction(double? minimum, double? maximum, double? target) {
    if (minimum == null || maximum == null || target == null || target <= 0) {
      return null;
    }
    return ProgressRange(minimum: minimum / target, maximum: maximum / target);
  }
}
