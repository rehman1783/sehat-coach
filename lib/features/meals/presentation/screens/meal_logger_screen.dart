import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../ai_logging/application/ai_meal_draft_handoff.dart';
import '../../../ai_logging/domain/ai_assisted_logging.dart';
import '../../../ai_logging/presentation/controllers/ai_meal_assistant_controller.dart';
import '../../../ai_logging/presentation/screens/ai_meal_assistant_screen.dart';
import '../../../custom_foods/presentation/screens/user_food_entry_screen.dart';
import '../../../custom_foods/domain/user_food_records.dart';
import '../controllers/meal_logger_controller.dart';

class MealLoggerScreen extends StatefulWidget {
  const MealLoggerScreen({
    super.key,
    required this.controller,
    this.createAiAssistant,
    this.createAiDraftHandoff,
  });

  final MealLoggerController controller;
  final Future<AiMealAssistantController> Function()? createAiAssistant;
  final Future<AiMealDraftHandoff> Function()? createAiDraftHandoff;

  @override
  State<MealLoggerScreen> createState() => _MealLoggerScreenState();
}

class _MealLoggerScreenState extends State<MealLoggerScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  bool _allowExit = false;
  bool _openingAi = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 280),
      () => widget.controller.search(value),
    );
  }

  Future<void> _openUserFood(UserFoodEntryMode mode) async {
    final controller = widget.controller.userFoodEntry;
    if (controller == null) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserFoodEntryScreen(
          controller: controller,
          initialSearch: _search.text.trim(),
          initialMode: mode,
        ),
      ),
    );
    if (result is CustomFoodRecord) {
      widget.controller.addCustomFood(result);
    }
  }

  Future<void> _openAiAssistant() async {
    final createAssistant = widget.createAiAssistant;
    final createHandoff = widget.createAiDraftHandoff;
    if (createAssistant == null || createHandoff == null || _openingAi) return;
    setState(() => _openingAi = true);
    AiMealAssistantController? assistant;
    try {
      assistant = await createAssistant();
      final handoff = await createHandoff();
      if (!mounted) return;
      final confirmation = await Navigator.of(context).push<Object?>(
        MaterialPageRoute<Object?>(
          builder: (_) => AiMealAssistantScreen(
            controller: assistant!,
            onManualSearch: () => Navigator.of(context).pop(),
          ),
        ),
      );
      if (!mounted || confirmation is! AiProposalConfirmation) return;
      final result = await handoff.apply(
        confirmation: confirmation,
        mealDraft: widget.controller,
      );
      if (!mounted) return;
      switch (result) {
        case AiMealDraftApplied(:final itemCount):
          widget.controller.errorMessage.value = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$itemCount suggested item${itemCount == 1 ? '' : 's'} added for review.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        case AiMealDraftNeedsManualReview(:final message):
          widget.controller.errorMessage.value = message;
      }
    } on Object {
      if (!mounted) return;
      widget.controller.errorMessage.value =
          'AI meal assistant is unavailable. Continue with manual search.';
    } finally {
      assistant?.onDelete();
      if (mounted) setState(() => _openingAi = false);
    }
  }

  Future<void> _saveMeal() async {
    final event = await widget.controller.save(
      occurredAt: DateTime.now(),
      rawUserInput: _search.text,
    );
    if (!mounted || event == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal saved offline and ready to sync.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _allowExit = true);
    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: _allowExit || !widget.controller.hasUnsavedMeal,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowExit || !widget.controller.hasUnsavedMeal) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard unsaved meal?'),
            content: const Text(
              'Your selected foods and serving changes have not been saved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('KEEP EDITING'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('DISCARD MEAL'),
              ),
            ],
          ),
        );
        if (discard != true || !mounted || !context.mounted) return;
        setState(() => _allowExit = true);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('LOG A MEAL'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Obx(() {
                final controller = widget.controller;
                final calculation = controller.calculation;
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        children: [
                          Text(
                            'What did you eat?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search the verified offline food catalog. You can adjust the serving before saving.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _search,
                            onChanged: _onSearch,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search daal, roti, biryani…',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: controller.isSearching.value
                                  ? Semantics(
                                      liveRegion: true,
                                      label: 'Status: Searching offline food catalog',
                                      excludeSemantics: true,
                                      child: const Padding(
                                        padding: EdgeInsets.all(14),
                                        child: SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (widget.createAiAssistant != null &&
                              widget.createAiDraftHandoff != null) ...[
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: OutlinedButton.icon(
                                onPressed: _openingAi ? null : _openAiAssistant,
                                icon: const Icon(Icons.auto_awesome_outlined),
                                label: const Text('ASSIST WITH AI'),
                              ),
                            ),
                          ],
                          if (controller.errorMessage.value
                              case final error?) ...[
                            const SizedBox(height: 10),
                            Semantics(
                              container: true,
                              liveRegion: true,
                              label: 'Error: $error',
                              excludeSemantics: true,
                              child: Text(
                                error,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.errorRed),
                              ),
                            ),
                          ],
                          if (controller.results.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Text(
                              'SEARCH RESULTS',
                              style: _sectionStyle(context),
                            ),
                            const SizedBox(height: 8),
                            ...controller.results.map(
                              (food) => _SearchResult(
                                name: food.nameEnglish,
                                subtitle: food.nameRomanUrdu,
                                selected: controller.selected.any(
                                  (item) => item.food.id == food.id,
                                ),
                                onTap: () => controller.addFood(food),
                              ),
                            ),
                          ],
                          if (controller.customResults.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Text(
                              'YOUR CUSTOM FOODS',
                              style: _sectionStyle(context),
                            ),
                            const SizedBox(height: 8),
                            ...controller.customResults.map(
                              (food) => _SearchResult(
                                name: food.name,
                                subtitle: '${food.servingLabel} • User-entered',
                                selected: controller.selectedCustom.any(
                                  (item) => item.food.id == food.id,
                                ),
                                onTap: () => controller.addCustomFood(food),
                              ),
                            ),
                          ],
                          if (_search.text.trim().isNotEmpty &&
                              !controller.isSearching.value &&
                              controller.results.isEmpty &&
                              controller.customResults.isEmpty &&
                              controller.errorMessage.value == null) ...[
                            const SizedBox(height: 22),
                            _EmptySearch(
                              onCreate: controller.userFoodEntry == null
                                  ? null
                                  : () => _openUserFood(
                                      UserFoodEntryMode.customFood,
                                    ),
                              onSaveNote: controller.userFoodEntry == null
                                  ? null
                                  : () => _openUserFood(
                                      UserFoodEntryMode.missingNote,
                                    ),
                            ),
                          ],
                          if (controller.selected.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            Text('YOUR MEAL', style: _sectionStyle(context)),
                            const SizedBox(height: 8),
                            ...controller.selected.map(
                              (item) => _SelectedFoodCard(
                                item: item,
                                onServingChanged: (serving) => controller
                                    .setServing(item.food.id, serving),
                                onQuantityChanged: (quantity) => controller
                                    .setQuantity(item.food.id, quantity),
                                onRemove: () =>
                                    controller.removeFood(item.food.id),
                              ),
                            ),
                          ],
                          if (controller.selectedCustom.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...controller.selectedCustom.map(
                              (item) => _SelectedCustomFoodCard(
                                item: item,
                                onQuantityChanged: (quantity) => controller
                                    .setCustomQuantity(item.food.id, quantity),
                                onRemove: () =>
                                    controller.removeCustomFood(item.food.id),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (calculation != null)
                      _SavePanel(
                        caloriesMinimum: calculation.total.caloriesKcal.minimum,
                        caloriesMaximum: calculation.total.caloriesKcal.maximum,
                        saving: controller.isSaving.value,
                        onSave: _saveMeal,
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    ),
  );

  TextStyle? _sectionStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: AppColors.primaryGreen, letterSpacing: 1.1);
}

class _SelectedCustomFoodCard extends StatelessWidget {
  const _SelectedCustomFoodCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final SelectedCustomFood item;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBEC),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8D58E)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.food.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Remove custom food',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        Text(
          item.food.gramsPerServing == null
              ? '${item.food.servingLabel} • Weight unknown • User-entered nutrition'
              : '${item.food.servingLabel} • ${item.food.gramsPerServing!.round()} g • User-entered nutrition',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<double>(
          initialValue: item.quantity,
          decoration: const InputDecoration(labelText: 'Quantity'),
          items: const [0.5, 1.0, 1.5, 2.0, 3.0]
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text('${value}x')),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) onQuantityChanged(value);
          },
        ),
      ],
    ),
  );
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({
    required this.name,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    elevation: 0,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      title: Text(name, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(subtitle),
      trailing: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.add_circle_outline_rounded,
        color: AppColors.primaryGreen,
      ),
      onTap: selected ? null : onTap,
    ),
  );
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({this.onCreate, this.onSaveNote});

  final VoidCallback? onCreate;
  final VoidCallback? onSaveNote;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.manage_search_rounded,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No verified match found. Try another spelling or a shorter food name.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (onCreate != null && onSaveNote != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('CREATE FOOD'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveNote,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('SAVE NOTE'),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _SelectedFoodCard extends StatelessWidget {
  const _SelectedFoodCard({
    required this.item,
    required this.onServingChanged,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final SelectedMealFood item;
  final ValueChanged<String> onServingChanged;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.food.nameEnglish,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              tooltip: 'Remove food',
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final servingField = DropdownButtonFormField<String>(
              initialValue: item.serving.id,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Serving'),
              items: item.food.servings
                  .map(
                    (serving) => DropdownMenuItem(
                      value: serving.id,
                      child: Text(serving.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) onServingChanged(value);
              },
            );
            final quantityField = DropdownButtonFormField<double>(
              initialValue: item.quantity,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Qty'),
              items: const [0.5, 1.0, 1.5, 2.0, 3.0]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('${value}x'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) onQuantityChanged(value);
              },
            );
            final stack =
                constraints.maxWidth < 380 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  servingField,
                  const SizedBox(height: 10),
                  quantityField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: servingField),
                const SizedBox(width: 10),
                SizedBox(width: 104, child: quantityField),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _SavePanel extends StatelessWidget {
  const _SavePanel({
    required this.caloriesMinimum,
    required this.caloriesMaximum,
    required this.saving,
    required this.onSave,
  });

  final double caloriesMinimum;
  final double caloriesMaximum;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final energy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ESTIMATED ENERGY',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                '${caloriesMinimum.round()}–${caloriesMaximum.round()} kcal',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          );
          final saveButton = FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(saving ? 'SAVING' : 'SAVE MEAL'),
          );
          final stack =
              constraints.maxWidth < 380 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [energy, const SizedBox(height: 10), saveButton],
            );
          }
          return Row(
            children: [
              Expanded(child: energy),
              saveButton,
            ],
          );
        },
      ),
    ),
  );
}
