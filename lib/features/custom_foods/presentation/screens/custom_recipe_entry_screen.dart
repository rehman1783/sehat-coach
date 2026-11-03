import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../recipes/domain/catalog_recipe.dart';
import '../controllers/custom_recipe_entry_controller.dart';

class CustomRecipeEntryScreen extends StatefulWidget {
  const CustomRecipeEntryScreen({super.key, required this.controller});

  final CustomRecipeEntryController controller;

  @override
  State<CustomRecipeEntryScreen> createState() =>
      _CustomRecipeEntryScreenState();
}

class _CustomRecipeEntryScreenState extends State<CustomRecipeEntryScreen> {
  final _name = TextEditingController();
  final _search = TextEditingController();
  final _minimumYield = TextEditingController(text: '4');
  final _maximumYield = TextEditingController(text: '4');
  Timer? _debounce;
  bool _detailsDirty = false;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [_name, _minimumYield, _maximumYield]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (_detailsDirty || !mounted) return;
    setState(() => _detailsDirty = true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final controller in [_name, _minimumYield, _maximumYield]) {
      controller.removeListener(_markDirty);
    }
    _name.dispose();
    _search.dispose();
    _minimumYield.dispose();
    _maximumYield.dispose();
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

  Future<void> _create() async {
    final recipe = await widget.controller.create(
      name: _name.text,
      minimumYield: double.tryParse(_minimumYield.text) ?? double.nan,
      maximumYield: double.tryParse(_maximumYield.text) ?? double.nan,
    );
    if (!mounted || recipe == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your recipe is saved offline and ready to use.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _allowExit = true);
    Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final hasDraft = _detailsDirty || widget.controller.hasSelectedIngredients;
    return PopScope(
      canPop: _allowExit || !hasDraft,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _allowExit || !hasDraft) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard unsaved recipe?'),
            content: const Text(
              'Your recipe details and selected ingredients have not been saved.',
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
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('CREATE YOUR RECIPE'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Obx(() {
                final controller = widget.controller;
                final nutrition = controller.batchNutrition;
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                        children: [
                          Text(
                            'Build your home recipe',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add the ingredients used in one batch. We keep this separate from verified recipes.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _name,
                            maxLength: 160,
                            decoration: const InputDecoration(
                              labelText: 'Recipe name',
                              hintText: 'e.g. Ammi’s chicken karahi',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('INGREDIENTS', style: _sectionStyle(context)),
                          const SizedBox(height: 8),
                          Semantics(
                            textField: true,
                            label: 'Search recipe ingredients',
                            child: TextField(
                              controller: _search,
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                hintText: 'Search ingredients…',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: controller.isSearching.value
                                    ? Semantics(
                                        liveRegion: true,
                                        label: 'Status: Searching ingredients',
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
                          ),
                          if (controller.results.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...controller.results.map(
                              (food) => _IngredientResult(
                                name: food.nameEnglish,
                                subtitle: food.nameRomanUrdu,
                                added: controller.selected.any(
                                  (item) => item.food.id == food.id,
                                ),
                                onTap: () => controller.addFood(food),
                              ),
                            ),
                          ],
                          if (controller.customResults.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('YOUR FOODS', style: _sectionStyle(context)),
                            const SizedBox(height: 6),
                            ...controller.customResults.map(
                              (food) => _IngredientResult(
                                name: food.name,
                                subtitle: '${food.servingLabel} • User-entered',
                                added: controller.selectedCustom.any(
                                  (item) => item.food.id == food.id,
                                ),
                                onTap: () => controller.addCustomFood(food),
                              ),
                            ),
                          ],
                          if (controller.selected.isNotEmpty ||
                              controller.selectedCustom.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'BATCH INGREDIENTS',
                              style: _sectionStyle(context),
                            ),
                            const SizedBox(height: 8),
                            ...controller.selected.map(
                              (item) => _SelectedIngredient(
                                name: item.food.nameEnglish,
                                servingLabel: item.serving.label,
                                servingId: item.serving.id,
                                servingOptions: {
                                  for (final serving in item.food.servings)
                                    serving.id: serving.label,
                                },
                                quantity: item.quantity,
                                onServing: (value) =>
                                    controller.setServing(item.food.id, value),
                                onQuantity: (value) =>
                                    controller.setQuantity(item.food.id, value),
                                onRemove: () =>
                                    controller.removeFood(item.food.id),
                              ),
                            ),
                            ...controller.selectedCustom.map(
                              (item) => _SelectedIngredient(
                                name: item.food.name,
                                servingLabel: item.food.servingLabel,
                                quantity: item.quantity,
                                userEntered: true,
                                onQuantity: (value) => controller.setQuantity(
                                  item.food.id,
                                  value,
                                  custom: true,
                                ),
                                onRemove: () =>
                                    controller.removeCustomFood(item.food.id),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text('BATCH YIELD', style: _sectionStyle(context)),
                          const SizedBox(height: 8),
                          _ResponsivePair(
                            first: TextField(
                              controller: _minimumYield,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Minimum servings',
                              ),
                            ),
                            second: TextField(
                              controller: _maximumYield,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Maximum servings',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<RecipeOilTreatment>(
                            initialValue: controller.oilTreatment.value,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Cooking oil in ingredient totals',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: RecipeOilTreatment.includedInIngredients,
                                child: Text('Included'),
                              ),
                              DropdownMenuItem(
                                value:
                                    RecipeOilTreatment.excludedFromCalculation,
                                child: Text('Not included'),
                              ),
                              DropdownMenuItem(
                                value: RecipeOilTreatment.unknown,
                                child: Text('Not sure'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _detailsDirty = true);
                                controller.oilTreatment.value = value;
                              }
                            },
                          ),
                          if (controller.errorMessage.value
                              case final error?) ...[
                            const SizedBox(height: 12),
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
                          if (nutrition != null) ...[
                            const SizedBox(height: 16),
                            _BatchEstimate(
                              minimum: nutrition.caloriesKcal.minimum,
                              maximum: nutrition.caloriesKcal.maximum,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: controller.isSaving.value ? null : _create,
                          icon: controller.isSaving.value
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            controller.isSaving.value
                                ? 'SAVING'
                                : 'SAVE RECIPE',
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

  TextStyle? _sectionStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: AppColors.primaryGreen, letterSpacing: 1.1);
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
        return Column(children: [first, const SizedBox(height: 10), second]);
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

class _IngredientResult extends StatelessWidget {
  const _IngredientResult({
    required this.name,
    required this.subtitle,
    required this.added,
    required this.onTap,
  });
  final String name;
  final String subtitle;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 7),
    child: ListTile(
      title: Text(name),
      subtitle: Text(subtitle),
      trailing: Icon(
        added ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
        color: AppColors.primaryGreen,
      ),
      onTap: added ? null : onTap,
    ),
  );
}

class _SelectedIngredient extends StatelessWidget {
  const _SelectedIngredient({
    required this.name,
    required this.servingLabel,
    required this.quantity,
    required this.onQuantity,
    required this.onRemove,
    this.userEntered = false,
    this.servingId,
    this.servingOptions = const {},
    this.onServing,
  });
  final String name;
  final String servingLabel;
  final double quantity;
  final ValueChanged<double> onQuantity;
  final VoidCallback onRemove;
  final bool userEntered;
  final String? servingId;
  final Map<String, String> servingOptions;
  final ValueChanged<String>? onServing;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
    decoration: BoxDecoration(
      color: userEntered ? const Color(0xFFFFFBEC) : AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: userEntered ? const Color(0xFFE8D58E) : AppColors.border,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              if (servingOptions.isEmpty)
                Text(servingLabel, style: Theme.of(context).textTheme.bodySmall)
              else
                DropdownButton<String>(
                  value: servingId,
                  isDense: true,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: servingOptions.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) onServing?.call(value);
                  },
                ),
            ],
          ),
        ),
        DropdownButton<double>(
          value: quantity,
          underline: const SizedBox.shrink(),
          items: const [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0]
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text('$value×')),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value != null) onQuantity(value);
          },
        ),
        IconButton(
          tooltip: 'Remove ingredient',
          onPressed: onRemove,
          icon: const Icon(Icons.close_rounded, size: 20),
        ),
      ],
    ),
  );
}

class _BatchEstimate extends StatelessWidget {
  const _BatchEstimate({required this.minimum, required this.maximum});
  final double minimum;
  final double maximum;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F4EC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(Icons.calculate_outlined, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Estimated batch energy: ${minimum.round()}–${maximum.round()} kcal',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}
