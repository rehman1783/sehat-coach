import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bachat/presentation/controllers/bachat_planner_controller.dart';
import '../../../bachat/presentation/screens/bachat_planner_screen.dart';
import '../../../meals/presentation/controllers/meal_logger_controller.dart';
import '../../../meals/presentation/controllers/meal_correction_controller.dart';
import '../../../meals/presentation/screens/meal_logger_screen.dart';
import '../../../fasting/presentation/controllers/fasting_settings_controller.dart';
import '../../../fasting/presentation/screens/fasting_settings_screen.dart';
import '../../../health_plans/presentation/controllers/health_plan_controller.dart';
import '../../../health_plans/presentation/screens/health_plan_screen.dart';
import '../../../onboarding/domain/models/onboarding_state.dart';
import '../../../recipes/presentation/controllers/recipe_meal_logger_controller.dart';
import '../../../sync/presentation/controllers/sync_status_controller.dart';
import '../../../water/presentation/controllers/water_tracker_controller.dart';
import '../../../weight/presentation/controllers/weight_tracker_controller.dart';
import '../controllers/daily_dashboard_controller.dart';
import 'daily_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  final OnboardingState profile;
  final Future<MealLoggerController> Function()? createMealLogger;
  final Future<DailyDashboardController> Function()? createDashboard;
  final Future<RecipeMealLoggerController> Function()? createRecipeMealLogger;
  final Future<WaterTrackerController> Function()? createWaterTracker;
  final Future<WeightTrackerController> Function(OnboardingState profile)?
  createWeightTracker;
  final Future<MealCorrectionController> Function(String eventId)?
  createMealCorrection;
  final Future<SyncStatusController> Function()? createSyncStatus;
  final Future<FastingSettingsController> Function()? createFastingSettings;
  final Future<BachatPlannerController> Function()? createBachatPlanner;
  final Future<HealthPlanController> Function()? createHealthPlan;

  const HomeScreen({
    super.key,
    required this.profile,
    this.createMealLogger,
    this.createDashboard,
    this.createRecipeMealLogger,
    this.createWaterTracker,
    this.createWeightTracker,
    this.createMealCorrection,
    this.createSyncStatus,
    this.createFastingSettings,
    this.createBachatPlanner,
    this.createHealthPlan,
  });

  Future<void> _openMealLogger(BuildContext context) async {
    final create = createMealLogger;
    if (create == null) return;
    try {
      final controller = await create();
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealLoggerScreen(controller: controller),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal logging is unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDashboard(BuildContext context) async {
    final create = createDashboard;
    final createLogger = createMealLogger;
    if (create == null || createLogger == null) return;
    try {
      final controller = await create();
      final water = await createWaterTracker?.call();
      final weight = await createWeightTracker?.call(profile);
      final syncStatus = await createSyncStatus?.call();
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DailyDashboardScreen(
            controller: controller,
            profile: profile,
            createMealLogger: createLogger,
            createRecipeMealLogger: createRecipeMealLogger,
            waterController: water,
            weightController: weight,
            createMealCorrection: createMealCorrection,
            syncStatusController: syncStatus,
          ),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your dashboard is unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openFastingSettings(BuildContext context) async {
    final create = createFastingSettings;
    if (create == null) return;
    try {
      final controller = await create();
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FastingSettingsScreen(controller: controller),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fasting settings are unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openBachatPlanner(BuildContext context) async {
    final create = createBachatPlanner;
    if (create == null) return;
    try {
      final controller = await create();
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BachatPlannerScreen(controller: controller),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bachat planning is unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openHealthPlan(BuildContext context) async {
    final create = createHealthPlan;
    if (create == null) return;
    try {
      final controller = await create();
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HealthPlanScreen(controller: controller),
        ),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health plans are unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final english = profile.language == AppLanguage.english;
    final goal = switch (profile.goal) {
      GoalType.dropFat => 'Drop Body Fat',
      GoalType.buildMuscle => 'Build Muscle Mass',
      GoalType.stayHealthy => 'Stay Healthy & Energetic',
      null => 'Your health goal',
    };
    final kitchen = switch (profile.kitchen) {
      KitchenRoutine.homeFamily => 'Home and family meals',
      KitchenRoutine.cookMyself => 'Cooking for yourself',
      KitchenRoutine.hostelMess => 'Hostel or mess meals',
      KitchenRoutine.takeout => 'Takeout meals',
      null => 'Your food routine',
    };
    final specialGuidance = !profile.allowsGenericCalorieEstimate;

    return Scaffold(
      appBar: AppBar(title: const Text('SEHAT COACH')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  english
                      ? 'Your journey starts here'
                      : 'Aapka safar yahan se shuru hota hai',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  english
                      ? 'A first look shaped by the answers you gave us.'
                      : 'Aapke diye gaye jawabat ke mutabiq pehli jhalak.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (createMealLogger != null) ...[
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: FilledButton.icon(
                      onPressed: createDashboard == null
                          ? () => _openMealLogger(context)
                          : () => _openDashboard(context),
                      icon: Icon(
                        createDashboard == null
                            ? Icons.add_rounded
                            : Icons.dashboard_rounded,
                      ),
                      label: Text(
                        createDashboard == null
                            ? 'LOG A MEAL'
                            : 'OPEN TODAY’S DASHBOARD',
                      ),
                    ),
                  ),
                ],
                if (createFastingSettings != null) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: OutlinedButton.icon(
                      onPressed: () => _openFastingSettings(context),
                      icon: const Icon(Icons.nightlight_outlined),
                      label: const Text('FASTING SETTINGS'),
                    ),
                  ),
                ],
                if (createBachatPlanner != null) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: OutlinedButton.icon(
                      onPressed: () => _openBachatPlanner(context),
                      icon: const Icon(Icons.savings_outlined),
                      label: const Text('OPEN BACHAT PLANNER'),
                    ),
                  ),
                ],
                if (createHealthPlan != null) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: OutlinedButton.icon(
                      onPressed: () => _openHealthPlan(context),
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text('MY HEALTH PLAN'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _SummaryCard(
                  icon: Icons.flag_outlined,
                  title: 'Your goal',
                  value: goal,
                ),
                _SummaryCard(
                  icon: Icons.restaurant_outlined,
                  title: 'Your food routine',
                  value: kitchen,
                ),
                _SummaryCard(
                  icon: Icons.location_on_outlined,
                  title: 'Your city',
                  value: '${profile.city}, ${profile.country}',
                ),
                _SummaryCard(
                  icon: Icons.support_agent_outlined,
                  title: 'Your coach style',
                  value: profile.coachName,
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EE),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        specialGuidance
                            ? 'Your plan needs personal guidance'
                            : 'Your starting energy estimate',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        specialGuidance
                            ? 'Follow your clinician’s plan. Automatic calorie targets are paused for your selected circumstances.'
                            : 'About ${profile.calculatedCalories} kcal per day. This is an estimate to review, not an exact measurement.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    ),
  );
}
