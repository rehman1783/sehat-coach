import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/ai_assisted_logging.dart';
import '../controllers/ai_meal_assistant_controller.dart';

class AiMealAssistantScreen extends StatefulWidget {
  const AiMealAssistantScreen({
    super.key,
    required this.controller,
    required this.onManualSearch,
  });

  final AiMealAssistantController controller;
  final VoidCallback onManualSearch;

  @override
  State<AiMealAssistantScreen> createState() => _AiMealAssistantScreenState();
}

class _AiMealAssistantScreenState extends State<AiMealAssistantScreen> {
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _confirm() {
    final confirmation = widget.controller.confirmSelection();
    Navigator.of(context).pop(confirmation);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(title: const Text('ASSISTED MEAL LOG')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Obx(() {
            final controller = widget.controller;
            final proposal = controller.proposal.value;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Text(
                  'Tell us what you ate',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'AI suggests matches only. You review the food and serving before anything is logged.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                SegmentedButton<AiLoggingLocale>(
                  segments: const [
                    ButtonSegment(
                      value: AiLoggingLocale.romanUrdu,
                      label: Text('Roman Urdu'),
                    ),
                    ButtonSegment(
                      value: AiLoggingLocale.english,
                      label: Text('English'),
                    ),
                  ],
                  selected: {controller.locale.value},
                  onSelectionChanged: (value) =>
                      controller.setLocale(value.single),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 500,
                  enabled: !controller.isLoading.value,
                  decoration: const InputDecoration(
                    labelText: 'Meal description',
                    hintText: 'Example: aik katori daal aur do chapati',
                    alignLabelWithHint: true,
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use AI assistance for this description'),
                  subtitle: const Text(
                    'You can keep this off and use private manual search.',
                  ),
                  value: controller.consentGranted.value,
                  onChanged: controller.isLoading.value
                      ? null
                      : controller.setConsent,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.submit(_description.text),
                  icon: controller.isLoading.value
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    controller.isLoading.value
                        ? 'CHECKING MATCHES…'
                        : 'SUGGEST MATCHES',
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onManualSearch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('USE MANUAL FOOD SEARCH'),
                ),
                if (controller.message.value case final message?) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    label: 'Status: $message',
                    excludeSemantics: true,
                    child: Text(message),
                  ),
                ],
                if (proposal != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    'REVIEW SUGGESTIONS',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  for (
                    var index = 0;
                    index < proposal.candidates.length;
                    index++
                  )
                    _CandidateCard(
                      candidate: proposal.candidates[index],
                      selected: controller.selectedIndexes.contains(index),
                      onChanged: (_) => controller.toggleCandidate(index),
                    ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: controller.canConfirm ? _confirm : null,
                    child: const Text('CONFIRM SELECTED ITEMS'),
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    ),
  );
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.selected,
    required this.onChanged,
  });

  final AiFoodCandidate candidate;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: CheckboxListTile(
      value: selected,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.trailing,
      title: Text(candidate.explanation),
      subtitle: Text(
        '${candidate.quantity} × ${candidate.servingId}\n'
        '${candidate.assumptions.join(' ')}',
      ),
      isThreeLine: candidate.assumptions.isNotEmpty,
    ),
  );
}
