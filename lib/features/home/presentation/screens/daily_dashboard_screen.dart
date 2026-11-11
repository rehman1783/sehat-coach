import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../ai_logging/application/ai_meal_draft_handoff.dart';
import '../../../ai_logging/presentation/controllers/ai_meal_assistant_controller.dart';
import '../../../meals/domain/meal_event.dart';
import '../../../meals/domain/meal_history.dart';
import '../../../meals/presentation/controllers/meal_logger_controller.dart';
import '../../../meals/presentation/controllers/meal_correction_controller.dart';
import '../../../meals/presentation/screens/meal_correction_screen.dart';
import '../../../meals/presentation/screens/meal_logger_screen.dart';
import '../../../goals/domain/daily_goal_progress.dart';
import '../../../onboarding/domain/models/onboarding_state.dart';
import '../../../recipes/presentation/controllers/recipe_meal_logger_controller.dart';
import '../../../recipes/presentation/screens/recipe_meal_logger_screen.dart';
import '../../../sync/presentation/controllers/sync_status_controller.dart';
import '../../../sync/presentation/widgets/sync_status_card.dart';
import '../../../water/presentation/controllers/water_tracker_controller.dart';
import '../../../water/presentation/widgets/water_dashboard_card.dart';
import '../../../weight/presentation/controllers/weight_tracker_controller.dart';
import '../../../weight/presentation/widgets/weight_progress_card.dart';
import '../controllers/daily_dashboard_controller.dart';

class DailyDashboardScreen extends StatefulWidget {
  const DailyDashboardScreen({
    super.key,
    required this.controller,
    required this.profile,
    required this.createMealLogger,
    this.createAiAssistant,
    this.createAiDraftHandoff,
    this.createRecipeMealLogger,
    this.waterController,
    this.weightController,
    this.createMealCorrection,
    this.syncStatusController,
  });

  final DailyDashboardController controller;
  final OnboardingState profile;
  final Future<MealLoggerController> Function() createMealLogger;
  final Future<AiMealAssistantController> Function()? createAiAssistant;
  final Future<AiMealDraftHandoff> Function()? createAiDraftHandoff;
  final Future<RecipeMealLoggerController> Function()? createRecipeMealLogger;
  final WaterTrackerController? waterController;
  final WeightTrackerController? weightController;
  final Future<MealCorrectionController> Function(String eventId)?
  createMealCorrection;
  final SyncStatusController? syncStatusController;

  @override
  State<DailyDashboardScreen> createState() => _DailyDashboardScreenState();
}

class _DailyDashboardScreenState extends State<DailyDashboardScreen> {
  Worker? _waterDayWorker;

  @override
  void initState() {
    super.initState();
    widget.controller.start();
    final water = widget.waterController;
    if (water != null) {
      water.selectDay(widget.controller.selectedDay.value);
      water.start();
      _waterDayWorker = ever<DateTime>(
        widget.controller.selectedDay,
        water.selectDay,
      );
    }
    widget.weightController?.start();
    widget.syncStatusController?.start();
  }

  @override
  void dispose() {
    _waterDayWorker?.dispose();
    widget.waterController?.stop();
    widget.weightController?.stop();
    widget.syncStatusController?.stop();
    widget.controller.stop();
    super.dispose();
  }

  Future<void> _openLogger() async {
    try {
      final logger = await widget.createMealLogger();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealLoggerScreen(
            controller: logger,
            createAiAssistant: widget.createAiAssistant,
            createAiDraftHandoff: widget.createAiDraftHandoff,
          ),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal logging is unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openRecipeLogger() async {
    final create = widget.createRecipeMealLogger;
    if (create == null) return;
    try {
      final logger = await create();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeMealLoggerScreen(controller: logger),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe logging is unavailable. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _chooseLogger() async {
    if (widget.createRecipeMealLogger == null) {
      await _openLogger();
      return;
    }
    final choice = await showModalBottomSheet<_LogChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What are you logging?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.restaurant_rounded),
                title: const Text('Foods and portions'),
                subtitle: const Text('Build a meal from individual foods'),
                onTap: () => Navigator.pop(context, _LogChoice.food),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const Icon(Icons.soup_kitchen_outlined),
                title: const Text('Prepared recipe'),
                subtitle: const Text('Choose a verified recipe and servings'),
                onTap: () => Navigator.pop(context, _LogChoice.recipe),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case _LogChoice.food:
        await _openLogger();
      case _LogChoice.recipe:
        await _openRecipeLogger();
      case null:
        return;
    }
  }

  Future<void> _openCorrection(MealHistoryEntry meal) async {
    final create = widget.createMealCorrection;
    if (create == null) return;
    try {
      final controller = await create(meal.eventId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealCorrectionScreen(controller: controller),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This meal can no longer be edited. Refresh history.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(title: const Text('TODAY')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _chooseLogger,
      icon: const Icon(Icons.add_rounded),
      label: const Text('LOG MEAL'),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Obx(() {
            final controller = widget.controller;
            final summary = controller.summary.value;
            final goalProgress = DailyGoalProgress(
              plan: DailyGoalPlan.fromProfile(widget.profile),
              logged: summary?.total,
            );
            return RefreshIndicator(
              onRefresh: () async => controller.reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                children: [
                  _DayPicker(controller: controller),
                  if (widget.syncStatusController case final sync?) ...[
                    const SizedBox(height: 14),
                    SyncStatusCard(controller: sync),
                  ],
                  if (widget.waterController case final water?) ...[
                    const SizedBox(height: 14),
                    WaterDashboardCard(controller: water),
                  ],
                  if (widget.weightController case final weight?) ...[
                    const SizedBox(height: 14),
                    WeightProgressCard(controller: weight),
                  ],
                  const SizedBox(height: 14),
                  _GoalProgressCard(progress: goalProgress),
                  const SizedBox(height: 18),
                  if (controller.isLoading.value && summary == null)
                    Semantics(
                      container: true,
                      liveRegion: true,
                      label: 'Status: Loading daily dashboard',
                      excludeSemantics: true,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  else if (controller.errorMessage.value case final error?)
                    _MessageCard(
                      icon: Icons.cloud_off_rounded,
                      message: error,
                      semanticPrefix: 'Error',
                    )
                  else if (summary == null || summary.meals.isEmpty)
                    const _EmptyDay()
                  else ...[
                    _EnergyCard(summary: summary),
                    const SizedBox(height: 12),
                    _MacroRow(summary: summary),
                    const SizedBox(height: 24),
                    Text(
                      '${summary.mealCount} ${summary.mealCount == 1 ? 'MEAL' : 'MEALS'} LOGGED',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ...summary.meals.map(
                      (meal) => _MealCard(
                        meal: meal,
                        onEdit: widget.createMealCorrection == null
                            ? null
                            : () => _openCorrection(meal),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    ),
  );
}

enum _LogChoice { food, recipe }

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.progress});

  final DailyGoalProgress progress;

  @override
  Widget build(BuildContext context) {
    final plan = progress.plan;
    if (!plan.hasPlanningEstimate) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7DB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8D58E)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.health_and_safety_outlined,
              color: Color(0xFF8A6A00),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your clinician plan comes first',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Automatic calorie progress is paused. You can still log meals and review your daily nutrition history.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final logged = progress.logged;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY PLANNING ESTIMATE',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _goalLabel(plan.goal),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Tooltip(
                message: 'This is an onboarding estimate, not a metabolic measurement or medical prescription.',
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressLine(
            label: 'Energy',
            unit: 'kcal',
            loggedMinimum: logged?.caloriesKcal.minimum ?? 0,
            loggedMaximum: logged?.caloriesKcal.maximum ?? 0,
            target: plan.energyKcal!,
            fraction: progress.energyFraction,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _CompactProgress(
                  label: 'Protein',
                  loggedMinimum: logged?.proteinGrams.minimum ?? 0,
                  loggedMaximum: logged?.proteinGrams.maximum ?? 0,
                  target: plan.proteinGrams!,
                  fraction: progress.proteinFraction,
                ),
                _CompactProgress(
                  label: 'Carbs',
                  loggedMinimum: logged?.carbohydrateGrams.minimum ?? 0,
                  loggedMaximum: logged?.carbohydrateGrams.maximum ?? 0,
                  target: plan.carbohydrateGrams!,
                  fraction: progress.carbohydrateFraction,
                ),
                _CompactProgress(
                  label: 'Fat',
                  loggedMinimum: logged?.fatGrams.minimum ?? 0,
                  loggedMaximum: logged?.fatGrams.maximum ?? 0,
                  target: plan.fatGrams!,
                  fraction: progress.fatFraction,
                ),
              ];
              final stack =
                  constraints.maxWidth < 380 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    cards[0],
                    const SizedBox(height: 8),
                    cards[1],
                    const SizedBox(height: 8),
                    cards[2],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[2]),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Logged food and serving estimates may be ranges. No target date or outcome is promised.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _goalLabel(GoalType? goal) => switch (goal) {
    GoalType.dropFat => 'Supporting your body-fat goal',
    GoalType.buildMuscle => 'Supporting your strength goal',
    GoalType.stayHealthy => 'Supporting steady daily habits',
    null => 'Your personalized daily view',
  };
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.unit,
    required this.loggedMinimum,
    required this.loggedMaximum,
    required this.target,
    required this.fraction,
  });

  final String label;
  final String unit;
  final double loggedMinimum;
  final double loggedMaximum;
  final double target;
  final ProgressRange? fraction;

  @override
  Widget build(BuildContext context) {
    final visual = (fraction?.maximum ?? 0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final labelWidget = Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            );
            final valueWidget = Text(
              '${loggedMinimum.round()}–${loggedMaximum.round()} / ${target.round()} $unit',
              style: Theme.of(context).textTheme.bodySmall,
            );
            final stack =
                constraints.maxWidth < 380 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [labelWidget, const SizedBox(height: 3), valueWidget],
              );
            }
            return Row(
              children: [
                Expanded(child: labelWidget),
                valueWidget,
              ],
            );
          },
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: visual,
            minHeight: 9,
            backgroundColor: const Color(0xFFE4ECE6),
            color: AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}

class _CompactProgress extends StatelessWidget {
  const _CompactProgress({
    required this.label,
    required this.loggedMinimum,
    required this.loggedMaximum,
    required this.target,
    required this.fraction,
  });

  final String label;
  final double loggedMinimum;
  final double loggedMaximum;
  final double target;
  final ProgressRange? fraction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 3),
        Text(
          '${loggedMinimum.round()}–${loggedMaximum.round()}g',
          maxLines: 1,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          'of ${target.round()}g estimate',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: (fraction?.maximum ?? 0).clamp(0.0, 1.0),
          minHeight: 5,
          borderRadius: BorderRadius.circular(20),
          backgroundColor: const Color(0xFFE4ECE6),
        ),
      ],
    ),
  );
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.controller});
  final DailyDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final day = controller.selectedDay.value;
    final today = DateTime.now();
    final isToday =
        day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Previous day',
          onPressed: controller.previousDay,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                isToday ? 'Today' : '${day.day}/${day.month}/${day.year}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                isToday ? 'Your offline daily record' : 'Daily meal history',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Next day',
          onPressed: isToday ? null : controller.nextDay,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.summary});
  final DailyMealSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTIMATED ENERGY LOGGED',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.78),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${summary.total.caloriesKcal.minimum.round()}–${summary.total.caloriesKcal.maximum.round()} kcal',
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 6),
        Text(
          'A transparent estimate based on the portions you logged.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.white.withValues(alpha: 0.76)),
        ),
      ],
    ),
  );
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({required this.summary});
  final DailyMealSummary summary;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cards = [
        _MacroCard(
          label: 'Protein',
          minimum: summary.total.proteinGrams.minimum,
          maximum: summary.total.proteinGrams.maximum,
        ),
        _MacroCard(
          label: 'Carbs',
          minimum: summary.total.carbohydrateGrams.minimum,
          maximum: summary.total.carbohydrateGrams.maximum,
        ),
        _MacroCard(
          label: 'Fat',
          minimum: summary.total.fatGrams.minimum,
          maximum: summary.total.fatGrams.maximum,
        ),
      ];
      final stack =
          constraints.maxWidth < 380 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3;
      if (stack) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cards[0],
            const SizedBox(height: 8),
            cards[1],
            const SizedBox(height: 8),
            cards[2],
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 8),
          Expanded(child: cards[1]),
          const SizedBox(width: 8),
          Expanded(child: cards[2]),
        ],
      );
    },
  );
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.label,
    required this.minimum,
    required this.maximum,
  });
  final String label;
  final double minimum;
  final double maximum;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Text(
          '${minimum.round()}–${maximum.round()} g',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, this.onEdit});
  final MealHistoryEntry meal;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final local = meal.occurredAtUtc.add(
      Duration(minutes: meal.timezoneOffsetMinutes),
    );
    final minute = local.minute.toString().padLeft(2, '0');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconFor(meal.mealType), color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelFor(meal.mealType),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  meal.rawUserInput.isEmpty
                      ? '${local.hour}:$minute'
                      : '${meal.rawUserInput} • ${local.hour}:$minute',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.total.caloriesKcal.minimum.round()}–${meal.total.caloriesKcal.maximum.round()}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit as correction',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelFor(MealType value) => switch (value) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
    MealType.suhoor => 'Suhoor',
    MealType.iftar => 'Iftar',
    MealType.other => 'Meal',
  };

  IconData _iconFor(MealType value) => switch (value) {
    MealType.breakfast => Icons.wb_sunny_outlined,
    MealType.lunch || MealType.dinner => Icons.restaurant_rounded,
    MealType.snack => Icons.local_cafe_outlined,
    MealType.suhoor || MealType.iftar => Icons.nights_stay_outlined,
    MealType.other => Icons.ramen_dining_outlined,
  };
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) => _MessageCard(
    icon: Icons.restaurant_menu_rounded,
    message: 'No meals logged for this day yet. Add one whenever you’re ready.',
    semanticPrefix: 'Status',
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    required this.semanticPrefix,
  });
  final IconData icon;
  final String message;
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: '$semanticPrefix: $message',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: AppColors.primaryGreen),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}
