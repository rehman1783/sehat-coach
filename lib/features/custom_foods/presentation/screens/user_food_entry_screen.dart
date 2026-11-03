import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/user_food_entry_controller.dart';

enum UserFoodEntryMode { customFood, missingNote }

class UserFoodEntryScreen extends StatefulWidget {
  const UserFoodEntryScreen({
    super.key,
    required this.controller,
    required this.initialSearch,
    this.initialMode = UserFoodEntryMode.customFood,
  });

  final UserFoodEntryController controller;
  final String initialSearch;
  final UserFoodEntryMode initialMode;

  @override
  State<UserFoodEntryScreen> createState() => _UserFoodEntryScreenState();
}

class _UserFoodEntryScreenState extends State<UserFoodEntryScreen> {
  late UserFoodEntryMode _mode = widget.initialMode;
  late final _name = TextEditingController(text: widget.initialSearch);
  final _serving = TextEditingController(text: '1 serving');
  final _unit = TextEditingController(text: 'serving');
  final _grams = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _sodium = TextEditingController();
  final _details = TextEditingController();
  bool _hasUnsavedDraft = false;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_markDirty);
    }
  }

  List<TextEditingController> get _controllers => [
    _name,
    _serving,
    _unit,
    _grams,
    _calories,
    _protein,
    _carbs,
    _fat,
    _sodium,
    _details,
  ];

  void _markDirty() {
    if (_hasUnsavedDraft || !mounted) return;
    setState(() => _hasUnsavedDraft = true);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_markDirty);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final result = switch (_mode) {
      UserFoodEntryMode.customFood => await widget.controller.create(
        name: _name.text,
        servingLabel: _serving.text,
        unitCode: _unit.text,
        calories: _calories.text,
        protein: _protein.text,
        carbohydrates: _carbs.text,
        fat: _fat.text,
        grams: _grams.text,
        sodium: _sodium.text,
      ),
      UserFoodEntryMode.missingNote => await widget.controller.saveMissing(
        searchText: _name.text,
        details: _details.text,
      ),
    };
    if (!mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _mode == UserFoodEntryMode.customFood
              ? 'Custom food saved offline.'
              : 'Food note saved for later review.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _allowExit = true);
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _allowExit || !_hasUnsavedDraft,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || _allowExit || !_hasUnsavedDraft) return;
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Discard unsaved food?'),
          content: const Text(
            'Your food details have not been saved on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('KEEP EDITING'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('DISCARD FOOD'),
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
      appBar: AppBar(title: const Text('ADD A FOOD')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Obx(
              () => Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      children: [
                        Text(
                          'Not in the verified catalog?',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create a private food from a label you trust, or save the name for later resolution.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        _ModeSelector(
                          mode: _mode,
                          onChanged: (mode) => setState(() {
                            _mode = mode;
                            _hasUnsavedDraft = true;
                            widget.controller.errorMessage.value = null;
                          }),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _name,
                          maxLength: 160,
                          decoration: const InputDecoration(
                            labelText: 'Food name',
                            hintText: 'e.g. Home chicken roll',
                          ),
                        ),
                        if (_mode == UserFoodEntryMode.customFood) ...[
                          const _UnreviewedNotice(),
                          const SizedBox(height: 14),
                          _ResponsiveFieldPair(
                            first: TextField(
                              controller: _serving,
                              decoration: const InputDecoration(
                                labelText: 'Serving label',
                              ),
                            ),
                            second: TextField(
                              controller: _unit,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _grams,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Grams per serving (optional)',
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'NUTRITION PER SERVING',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.primaryGreen,
                                  letterSpacing: 1.1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _NutritionGrid(
                            calories: _calories,
                            protein: _protein,
                            carbohydrates: _carbs,
                            fat: _fat,
                            sodium: _sodium,
                          ),
                        ] else ...[
                          TextField(
                            controller: _details,
                            maxLength: 1000,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Details (optional)',
                              hintText:
                                  'Where you ate it or how it was prepared',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                        if (widget.controller.errorMessage.value
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: widget.controller.isSaving.value
                            ? null
                            : _save,
                        icon: widget.controller.isSaving.value
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _mode == UserFoodEntryMode.customFood
                                    ? Icons.save_outlined
                                    : Icons.bookmark_add_outlined,
                              ),
                        label: Text(
                          widget.controller.isSaving.value
                              ? 'SAVING'
                              : _mode == UserFoodEntryMode.customFood
                              ? 'SAVE CUSTOM FOOD'
                              : 'SAVE FOR LATER',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onChanged});

  final UserFoodEntryMode mode;
  final ValueChanged<UserFoodEntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Custom food'),
            selected: mode == UserFoodEntryMode.customFood,
            onSelected: (_) => onChanged(UserFoodEntryMode.customFood),
          ),
          ChoiceChip(
            label: const Text('Save note'),
            selected: mode == UserFoodEntryMode.missingNote,
            onSelected: (_) => onChanged(UserFoodEntryMode.missingNote),
          ),
        ],
      );
    }
    return SegmentedButton<UserFoodEntryMode>(
      segments: const [
        ButtonSegment(
          value: UserFoodEntryMode.customFood,
          icon: Icon(Icons.add_box_outlined),
          label: Text('Custom food'),
        ),
        ButtonSegment(
          value: UserFoodEntryMode.missingNote,
          icon: Icon(Icons.bookmark_add_outlined),
          label: Text('Save note'),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.single),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

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

class _UnreviewedNotice extends StatelessWidget {
  const _UnreviewedNotice();

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
            'This stays private to your account and is not a verified Sehat Coach catalog item. Copy values from a reliable product label.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}

class _NutritionGrid extends StatelessWidget {
  const _NutritionGrid({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.sodium,
  });

  final TextEditingController calories;
  final TextEditingController protein;
  final TextEditingController carbohydrates;
  final TextEditingController fat;
  final TextEditingController sodium;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ResponsiveFieldPair(
        first: _numberField(calories, 'Calories', 'kcal'),
        second: _numberField(protein, 'Protein', 'g'),
      ),
      const SizedBox(height: 10),
      _ResponsiveFieldPair(
        first: _numberField(carbohydrates, 'Carbohydrates', 'g'),
        second: _numberField(fat, 'Fat', 'g'),
      ),
      const SizedBox(height: 10),
      _numberField(sodium, 'Sodium (optional)', 'mg'),
    ],
  );

  Widget _numberField(
    TextEditingController controller,
    String label,
    String suffix,
  ) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, suffixText: suffix),
  );
}
