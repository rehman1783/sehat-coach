import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/bachat_planner.dart';
import '../controllers/bachat_planner_controller.dart';

class BachatPlannerScreen extends StatefulWidget {
  const BachatPlannerScreen({super.key, required this.controller});

  final BachatPlannerController controller;

  @override
  State<BachatPlannerScreen> createState() => _BachatPlannerScreenState();
}

class _BachatPlannerScreenState extends State<BachatPlannerScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadAndPlan();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('BACHAT PLANNER')),
    body: SafeArea(
      child: Obx(() {
        final controller = widget.controller;
        return ResponsiveContent(
          child: ListView(
            children: [
              Text(
                'Plan groceries for ${controller.cityName}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'A free, non-AI plan using verified local prices. Adjust the limits to fit your week.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _ConstraintCard(controller: controller),
              const SizedBox(height: 18),
              if (controller.isLoading.value)
                Semantics(
                  container: true,
                  liveRegion: true,
                  label: 'Status: Loading verified grocery prices',
                  excludeSemantics: true,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.errorMessage.value case final error?)
                _MessageCard(
                  message: error,
                  icon: Icons.cloud_off_outlined,
                  semanticPrefix: 'Error',
                )
              else
                _PlanSection(plan: controller.plan.value),
            ],
          ),
        );
      }),
    ),
  );
}

class _ConstraintCard extends StatelessWidget {
  const _ConstraintCard({required this.controller});

  final BachatPlannerController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR WEEKLY LIMITS',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 14),
        _ResponsiveFieldPair(
          first: _NumberField(
            label: 'Budget (PKR)',
            initialValue: controller.budgetPkr.value,
            onChanged: controller.updateBudget,
          ),
          second: _NumberField(
            label: 'Protein (g)',
            initialValue: controller.minimumProteinGrams.value,
            onChanged: controller.updateMinimumProtein,
          ),
        ),
        const SizedBox(height: 10),
        _ResponsiveFieldPair(
          first: _NumberField(
            label: 'Minimum kcal',
            initialValue: controller.minimumCalories.value,
            onChanged: controller.updateMinimumCalories,
          ),
          second: _NumberField(
            label: 'Maximum kcal',
            initialValue: controller.maximumCalories.value,
            onChanged: controller.updateMaximumCalories,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final tag in const ['egg', 'milk', 'peanut'])
              FilterChip(
                label: Text('No $tag'),
                selected: controller.excludedAllergenTags.contains(tag),
                onSelected: (value) => controller.toggleAllergen(tag, value),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: controller.recalculate,
            icon: const Icon(Icons.auto_graph_rounded),
            label: const Text('BUILD MY PLAN'),
          ),
        ),
      ],
    ),
  );
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({required this.plan});

  final BachatPlan? plan;

  @override
  Widget build(BuildContext context) {
    final value = plan;
    if (value == null) {
      return const _MessageCard(
        message: 'Set your limits to build a grocery plan.',
        icon: Icons.shopping_basket_outlined,
        semanticPrefix: 'Status',
      );
    }
    if (value.status != BachatPlanStatus.ready) {
      return _MessageCard(
        message: value.message ?? 'No verified plan is available.',
        icon: Icons.info_outline_rounded,
        semanticPrefix: 'Status',
      );
    }
    return Semantics(
      container: true,
      liveRegion: true,
      label:
          'Status: Grocery plan ready for ${value.items.length} verified ${value.items.length == 1 ? 'item' : 'items'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            spacing: 12,
            children: [
              Text('YOUR PLAN', style: Theme.of(context).textTheme.titleMedium),
              Text(
                'PKR ${value.totalCostPkr.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in value.items) _PlanItemCard(item: item),
          const SizedBox(height: 8),
          Text(
            '${value.totalCalories.toStringAsFixed(0)} kcal • ${value.totalProteinGrams.toStringAsFixed(0)} g protein',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Prices are snapshots, not guarantees. Check the source, market and date before buying.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PlanItemCard extends StatelessWidget {
  const _PlanItemCard({required this.item});

  final BachatPlanItem item;

  @override
  Widget build(BuildContext context) {
    final price = item.candidate.price;
    final date = price.lastVerifiedAtUtc;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                item.candidate.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text('${item.packCount} × ${price.unitCode}'),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'PKR ${item.costPkr.toStringAsFixed(0)} • ${price.marketName}, ${price.cityName}',
          ),
          const SizedBox(height: 3),
          Text(
            '${price.sourceCitation} • Updated ${date.day}/${date.month}/${date.year}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.icon,
    required this.semanticPrefix,
  });

  final String message;
  final IconData icon;
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: '$semanticPrefix: $message',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D59B)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue.toStringAsFixed(0),
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label),
    onChanged: (value) {
      final parsed = double.tryParse(value);
      if (parsed != null) onChanged(parsed);
    },
  );
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stack =
          constraints.maxWidth < 380 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3;
      if (stack) {
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
