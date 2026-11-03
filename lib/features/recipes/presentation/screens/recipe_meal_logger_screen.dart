import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../meals/domain/meal_event.dart';
import '../../../custom_foods/domain/custom_recipe_records.dart';
import '../../../custom_foods/presentation/screens/custom_recipe_entry_screen.dart';
import '../../domain/catalog_recipe.dart';
import '../controllers/recipe_meal_logger_controller.dart';

class RecipeMealLoggerScreen extends StatefulWidget {
  const RecipeMealLoggerScreen({super.key, required this.controller});

  final RecipeMealLoggerController controller;

  @override
  State<RecipeMealLoggerScreen> createState() => _RecipeMealLoggerScreenState();
}

class _RecipeMealLoggerScreenState extends State<RecipeMealLoggerScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  bool _allowExit = false;

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

  Future<void> _save() async {
    final recipe = widget.controller.selectedRecipe.value;
    final customRecipe = widget.controller.selectedCustomRecipe.value;
    final event = await widget.controller.save(
      occurredAt: DateTime.now(),
      rawUserInput: recipe != null
          ? '${widget.controller.selectedServings.value} serving(s) ${recipe.nameEnglish}'
          : customRecipe != null
          ? '${widget.controller.selectedServings.value} serving(s) ${customRecipe.name} (user recipe)'
          : _search.text,
    );
    if (!mounted || event == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe saved offline and ready to sync.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _allowExit = true);
    Navigator.of(context).pop(event);
  }

  Future<void> _createCustomRecipe() async {
    final entry = widget.controller.customRecipeEntry;
    if (entry == null) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomRecipeEntryScreen(controller: entry),
      ),
    );
    if (result is! CustomRecipeRecord) return;
    widget.controller.customResults.removeWhere((item) => item.id == result.id);
    widget.controller.customResults.insert(0, result);
    widget.controller.selectCustomRecipe(result);
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: _allowExit || !widget.controller.hasUnsavedRecipe,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowExit || !widget.controller.hasUnsavedRecipe) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard unsaved recipe?'),
            content: const Text(
              'Your selected recipe and serving changes have not been saved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('KEEP EDITING'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('DISCARD RECIPE'),
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
          title: const Text('LOG A RECIPE'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Obx(() {
                final controller = widget.controller;
                final selected = controller.selectedRecipe.value;
                final selectedCustom = controller.selectedCustomRecipe.value;
                final calculation = controller.calculation;
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                        children: [
                          Text(
                            'Which recipe did you eat?',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search verified Pakistani recipes stored on your device. Estimates reflect the saved recipe yield.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          Semantics(
                            textField: true,
                            label: 'Search verified recipes',
                            child: TextField(
                              controller: _search,
                              onChanged: _onSearch,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'Search daal, karahi, pulao…',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: controller.isSearching.value
                                    ? Semantics(
                                        liveRegion: true,
                                        label: 'Status: Searching recipes',
                                        child: Padding(
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
                          ),
                          if (controller.customRecipeEntry != null) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _createCustomRecipe,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('CREATE YOUR OWN RECIPE'),
                              ),
                            ),
                          ],
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
                          if (controller.results.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _SectionLabel('VERIFIED RECIPES'),
                            const SizedBox(height: 8),
                            ...controller.results.map(
                              (recipe) => _RecipeResultCard(
                                recipe: recipe,
                                selected: selected?.id == recipe.id,
                                onTap: () => controller.selectRecipe(recipe),
                              ),
                            ),
                          ],
                          if (controller.customResults.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _SectionLabel('YOUR RECIPES'),
                            const SizedBox(height: 8),
                            ...controller.customResults.map(
                              (recipe) => _CustomRecipeResultCard(
                                recipe: recipe,
                                selected: selectedCustom?.id == recipe.id,
                                onTap: () =>
                                    controller.selectCustomRecipe(recipe),
                              ),
                            ),
                          ],
                          if (_search.text.trim().isNotEmpty &&
                              !controller.isSearching.value &&
                              controller.results.isEmpty &&
                              controller.customResults.isEmpty &&
                              controller.errorMessage.value == null) ...[
                            const SizedBox(height: 22),
                            const _EmptyRecipeSearch(),
                          ],
                          if (selected != null && calculation != null) ...[
                            const SizedBox(height: 22),
                            _SectionLabel('YOUR SERVING'),
                            const SizedBox(height: 8),
                            _SelectedRecipeCard(
                              recipe: selected,
                              servings: controller.selectedServings.value,
                              onServingsChanged: controller.setServings,
                              onClear: controller.clearSelection,
                            ),
                            const SizedBox(height: 12),
                            _MealTypePicker(controller: controller),
                            if (selected.oilTreatment ==
                                RecipeOilTreatment.unknown) ...[
                              const SizedBox(height: 12),
                              const _OilNotice(),
                            ],
                          ],
                          if (selectedCustom != null &&
                              calculation != null) ...[
                            const SizedBox(height: 22),
                            _SectionLabel('YOUR SERVING'),
                            const SizedBox(height: 8),
                            _SelectedCustomRecipeCard(
                              recipe: selectedCustom,
                              servings: controller.selectedServings.value,
                              onServingsChanged: controller.setServings,
                              onClear: controller.clearSelection,
                            ),
                            const SizedBox(height: 12),
                            _MealTypePicker(controller: controller),
                            if (selectedCustom.oilTreatment ==
                                RecipeOilTreatment.unknown) ...[
                              const SizedBox(height: 12),
                              const _OilNotice(),
                            ],
                          ],
                        ],
                      ),
                    ),
                    if (calculation != null)
                      _RecipeSavePanel(
                        caloriesMinimum: calculation.total.caloriesKcal.minimum,
                        caloriesMaximum: calculation.total.caloriesKcal.maximum,
                        saving: controller.isSaving.value,
                        onSave: _save,
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
}

class _CustomRecipeResultCard extends StatelessWidget {
  const _CustomRecipeResultCard({
    required this.recipe,
    required this.selected,
    required this.onTap,
  });

  final CustomRecipeRecord recipe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFFFF7DB) : AppColors.background,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: selected ? const Color(0xFFC69A18) : AppColors.border,
        width: selected ? 1.4 : 1,
      ),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: const Icon(Icons.edit_note_rounded, color: Color(0xFF8A6A00)),
        title: Text(recipe.name),
        subtitle: Text(
          'User-entered • ${recipe.yieldServingsMinimum.toStringAsFixed(0)}–${recipe.yieldServingsMaximum.toStringAsFixed(0)} servings/batch',
        ),
        trailing: Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.add_circle_outline_rounded,
          color: const Color(0xFF8A6A00),
        ),
        onTap: onTap,
      ),
    ),
  );
}

class _SelectedCustomRecipeCard extends StatelessWidget {
  const _SelectedCustomRecipeCard({
    required this.recipe,
    required this.servings,
    required this.onServingsChanged,
    required this.onClear,
  });

  final CustomRecipeRecord recipe;
  final double servings;
  final ValueChanged<double> onServingsChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBEC),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE8D58E)),
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
                    recipe.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Your recipe • Nutrition is based on your saved ingredients',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove recipe',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<double>(
          initialValue: servings,
          decoration: const InputDecoration(labelText: 'Servings eaten'),
          items: const [0.5, 1.0, 1.5, 2.0, 3.0, 4.0]
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} servings',
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) onServingsChanged(value);
          },
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: AppColors.primaryGreen, letterSpacing: 1.1),
  );
}

class _RecipeResultCard extends StatelessWidget {
  const _RecipeResultCard({
    required this.recipe,
    required this.selected,
    required this.onTap,
  });

  final CatalogRecipe recipe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFE8F4EC) : AppColors.background,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: selected ? AppColors.primaryGreen : AppColors.border,
        width: selected ? 1.4 : 1,
      ),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGreen : const Color(0xFFE5F0E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.soup_kitchen_outlined,
            color: selected ? AppColors.white : AppColors.primaryGreen,
          ),
        ),
        title: Text(recipe.nameEnglish),
        subtitle: Text(
          '${recipe.nameRomanUrdu} • ${_yieldLabel(recipe)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          selected
              ? Icons.check_circle_rounded
              : Icons.add_circle_outline_rounded,
          color: AppColors.primaryGreen,
        ),
        onTap: onTap,
      ),
    ),
  );

  String _yieldLabel(CatalogRecipe recipe) =>
      '${recipe.yieldServingsMinimum.toStringAsFixed(0)}–${recipe.yieldServingsMaximum.toStringAsFixed(0)} servings/batch';
}

class _SelectedRecipeCard extends StatelessWidget {
  const _SelectedRecipeCard({
    required this.recipe,
    required this.servings,
    required this.onServingsChanged,
    required this.onClear,
  });

  final CatalogRecipe recipe;
  final double servings;
  final ValueChanged<double> onServingsChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.nameEnglish,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    recipe.nameRomanUrdu,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Remove recipe',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<double>(
          initialValue: servings,
          decoration: const InputDecoration(labelText: 'Servings eaten'),
          items: const [0.5, 1.0, 1.5, 2.0, 3.0, 4.0]
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} servings',
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) onServingsChanged(value);
          },
        ),
      ],
    ),
  );
}

class _MealTypePicker extends StatelessWidget {
  const _MealTypePicker({required this.controller});
  final RecipeMealLoggerController controller;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<MealType>(
    initialValue: controller.mealType.value,
    decoration: const InputDecoration(labelText: 'Meal'),
    items: MealType.values
        .map((type) => DropdownMenuItem(value: type, child: Text(_label(type))))
        .toList(growable: false),
    onChanged: (value) {
      if (value != null) controller.mealType.value = value;
    },
  );

  String _label(MealType type) => switch (type) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
    MealType.suhoor => 'Suhoor',
    MealType.iftar => 'Iftar',
    MealType.other => 'Other',
  };
}

class _OilNotice extends StatelessWidget {
  const _OilNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7DB),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8D58E)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFF8A6A00)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'The recipe source does not confirm whether cooking oil is included. The estimate has not guessed an adjustment.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _EmptyRecipeSearch extends StatelessWidget {
  const _EmptyRecipeSearch();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.manage_search_rounded, color: AppColors.primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'No verified recipe found. Try another spelling or a shorter name.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

class _RecipeSavePanel extends StatelessWidget {
  const _RecipeSavePanel({
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
          final action = FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(saving ? 'SAVING' : 'SAVE RECIPE'),
          );
          if (MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
              constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [energy, const SizedBox(height: 10), action],
            );
          }
          return Row(
            children: [
              Expanded(child: energy),
              action,
            ],
          );
        },
      ),
    ),
  );
}
