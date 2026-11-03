import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/meal_event.dart';
import '../../../catalog/domain/catalog_food.dart';
import '../controllers/meal_correction_controller.dart';

class MealCorrectionScreen extends StatefulWidget {
  const MealCorrectionScreen({super.key, required this.controller});

  final MealCorrectionController controller;

  @override
  State<MealCorrectionScreen> createState() => _MealCorrectionScreenState();
}

class _MealCorrectionScreenState extends State<MealCorrectionScreen> {
  late final TextEditingController _description;
  bool _descriptionDirty = false;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(
      text: widget.controller.draft.rawUserInput,
    );
    _description.addListener(_markDescriptionDirty);
  }

  void _markDescriptionDirty() {
    if (_descriptionDirty || !mounted) return;
    setState(() => _descriptionDirty = true);
  }

  @override
  void dispose() {
    _description.removeListener(_markDescriptionDirty);
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = widget.controller.localOccurrence.value;
    final value = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (value != null) widget.controller.setDate(value);
  }

  Future<void> _pickTime() async {
    final current = widget.controller.localOccurrence.value;
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (value != null) widget.controller.setTime(value.hour, value.minute);
  }

  Future<void> _save() async {
    final correction = await widget.controller.save(_description.text);
    if (!mounted || correction == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Correction saved offline and ready to sync.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _allowExit = true);
    Navigator.of(context).pop(correction);
  }

  Future<void> _showReplacementPicker(int index) async {
    final controller = widget.controller;
    controller.replacementResults.clear();
    controller.replacementError.value = null;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Replace with approved food'),
        content: SizedBox(
          width: 430,
          height: MediaQuery.sizeOf(dialogContext).height * 0.55,
          child: Column(
            children: [
              TextField(
                autofocus: true,
                onChanged: controller.searchReplacements,
                decoration: const InputDecoration(
                  labelText: 'Search food',
                  hintText: 'e.g. daal, roti, chicken',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Obx(() {
                  if (controller.isSearchingReplacements.value) {
                    return Semantics(
                      liveRegion: true,
                      label: 'Status: Searching replacement foods',
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (controller.replacementError.value case final error?) {
                    return Semantics(
                      liveRegion: true,
                      label: 'Error: $error',
                      excludeSemantics: true,
                      child: Center(child: Text(error)),
                    );
                  }
                  if (controller.replacementResults.isEmpty &&
                      controller.customReplacementResults.isEmpty &&
                      controller.recipeReplacementResults.isEmpty &&
                      controller.customRecipeReplacementResults.isEmpty) {
                    return const Center(
                      child: Text(
                        'Type to search approved foods and your custom foods.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      if (controller.replacementResults.isNotEmpty) ...[
                        const ListTile(
                          dense: true,
                          title: Text('APPROVED CATALOG'),
                        ),
                        for (final food in controller.replacementResults)
                          ListTile(
                            title: Text(food.nameEnglish),
                            subtitle: Text(
                              '${food.nameRomanUrdu} • ${food.servings.first.label}',
                            ),
                            trailing: const Icon(Icons.arrow_forward_rounded),
                            onTap: () {
                              controller.replaceWithApprovedFood(index, food);
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                      ],
                      if (controller.customReplacementResults.isNotEmpty) ...[
                        const ListTile(
                          dense: true,
                          title: Text('MY CUSTOM FOODS'),
                        ),
                        for (final food in controller.customReplacementResults)
                          ListTile(
                            leading: const Icon(Icons.person_outline_rounded),
                            title: Text(food.name),
                            subtitle: Text(
                              '${food.servingLabel} • user-entered nutrition',
                            ),
                            trailing: const Icon(Icons.arrow_forward_rounded),
                            onTap: () {
                              controller.replaceWithCustomFood(index, food);
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                      ],
                      if (controller.recipeReplacementResults.isNotEmpty) ...[
                        const ListTile(
                          dense: true,
                          title: Text('APPROVED RECIPES'),
                        ),
                        for (final recipe
                            in controller.recipeReplacementResults)
                          ListTile(
                            leading: const Icon(Icons.restaurant_menu_rounded),
                            title: Text(recipe.nameEnglish),
                            subtitle: Text(
                              '${recipe.nameRomanUrdu} • reviewed recipe',
                            ),
                            trailing: const Icon(Icons.arrow_forward_rounded),
                            onTap: () {
                              controller.replaceWithApprovedRecipe(
                                index,
                                recipe,
                              );
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                      ],
                      if (controller
                          .customRecipeReplacementResults
                          .isNotEmpty) ...[
                        const ListTile(dense: true, title: Text('MY RECIPES')),
                        for (final recipe
                            in controller.customRecipeReplacementResults)
                          ListTile(
                            leading: const Icon(Icons.person_outline_rounded),
                            title: Text(recipe.name),
                            subtitle: const Text(
                              'Saved recipe • user-entered ingredients',
                            ),
                            trailing: const Icon(Icons.arrow_forward_rounded),
                            onTap: () {
                              controller.replaceWithCustomRecipe(index, recipe);
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final hasDraft =
        _descriptionDirty || widget.controller.hasUnsavedChanges.value;
    return PopScope(
      canPop: _allowExit || !hasDraft,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowExit || !hasDraft) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard unsaved correction?'),
            content: const Text(
              'Your original meal is unchanged. These correction edits have not been saved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('KEEP EDITING'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('DISCARD CORRECTION'),
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
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('EDIT MEAL'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Obx(() {
                final controller = widget.controller;
                final local = controller.localOccurrence.value;
                final minute = local.minute.toString().padLeft(2, '0');
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3D590),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.graphiteYellow,
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    'Your original entry stays in history. Saving creates a traceable correction.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<MealType>(
                            initialValue: controller.mealType.value,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Meal type',
                            ),
                            items: MealType.values
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(_mealLabel(type)),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (value) {
                              if (value != null) controller.setMealType(value);
                            },
                          ),
                          const SizedBox(height: 12),
                          _ResponsivePair(
                            first: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                '${local.day}/${local.month}/${local.year}',
                              ),
                            ),
                            second: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.schedule_rounded),
                              label: Text('${local.hour}:$minute'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _description,
                            maxLength: 4000,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Meal description',
                              hintText: 'What did you eat?',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ADJUST PORTIONS',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primaryGreen,
                                  letterSpacing: 1.1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.items.indexed.map((indexed) {
                            final (index, item) = indexed;
                            final servings = controller.availableServings(
                              index,
                            );
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(
                                          0xFFE5F0E8,
                                        ),
                                        foregroundColor: AppColors.primaryGreen,
                                        child: Text('${index + 1}'),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.servingLabel),
                                            Text(
                                              '${item.nutrition.caloriesKcal.minimum.round()}–${item.nutrition.caloriesKcal.maximum.round()} kcal • ${item.unitCode}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Decrease portion',
                                        onPressed: item.quantity <= 0.25
                                            ? null
                                            : () => controller.adjustQuantity(
                                                index,
                                                -0.25,
                                              ),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 2)}×',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                      IconButton(
                                        tooltip: 'Increase portion',
                                        onPressed: () => controller
                                            .adjustQuantity(index, 0.25),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          _showReplacementPicker(index),
                                      icon: const Icon(
                                        Icons.swap_horiz_rounded,
                                      ),
                                      label: const Text('REPLACE ITEM'),
                                    ),
                                  ),
                                  if (servings.length > 1) ...[
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      key: ValueKey(
                                        'serving-$index-${item.servingId}',
                                      ),
                                      initialValue: item.servingId,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Serving unit',
                                        helperText: 'Alternatives come from the same saved catalog release.',
                                      ),
                                      items: servings
                                          .map(
                                            (serving) => DropdownMenuItem(
                                              value: serving.id,
                                              child: Text(serving.label),
                                            ),
                                          )
                                          .toList(growable: false),
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.setServing(index, value);
                                        }
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<OilInclusion>(
                                    initialValue: item.oilInclusion,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Oil in saved nutrition',
                                      helperText: 'Assumption only — changing this does not add calories.',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: OilInclusion.included,
                                        child: Text('Included'),
                                      ),
                                      DropdownMenuItem(
                                        value: OilInclusion.excluded,
                                        child: Text('Not included'),
                                      ),
                                      DropdownMenuItem(
                                        value: OilInclusion.unknown,
                                        child: Text('Not sure'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.setOilInclusion(
                                          index,
                                          value,
                                        );
                                      }
                                    },
                                  ),
                                  if (item.oilInclusion !=
                                      OilInclusion.included) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          size: 17,
                                          color: Color(0xFF8A6A00),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item.oilInclusion ==
                                                    OilInclusion.excluded
                                                ? 'Extra oil is not included in this estimate. Add it as a separate verified food when available.'
                                                : 'Oil inclusion is uncertain, so the estimate does not guess an adjustment.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            'Updated estimate: ${controller.calculation.total.caloriesKcal.minimum.round()}–${controller.calculation.total.caloriesKcal.maximum.round()} kcal',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (controller.errorMessage.value
                              case final error?) ...[
                            const SizedBox(height: 10),
                            Semantics(
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
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: controller.isSaving.value ? null : _save,
                          icon: controller.isSaving.value
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.history_rounded),
                          label: Text(
                            controller.isSaving.value
                                ? 'SAVING CORRECTION'
                                : 'SAVE AS CORRECTION',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  });

  static String _mealLabel(MealType value) => switch (value) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
    MealType.suhoor => 'Suhoor',
    MealType.iftar => 'Iftar',
    MealType.other => 'Other meal',
  };
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
          constraints.maxWidth < 340) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, const SizedBox(height: 10), second],
        );
      }
      return Row(
        children: [
          Expanded(child: first),
          const SizedBox(width: 10),
          Expanded(child: second),
        ],
      );
    },
  );
}
