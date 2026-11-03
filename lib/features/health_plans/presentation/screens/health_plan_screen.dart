import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../domain/health_meal_plan.dart';
import '../../domain/health_plan_adherence.dart';
import '../controllers/health_plan_controller.dart';

class HealthPlanScreen extends StatefulWidget {
  const HealthPlanScreen({super.key, required this.controller});
  final HealthPlanController controller;

  @override
  State<HealthPlanScreen> createState() => _HealthPlanScreenState();
}

class _HealthPlanScreenState extends State<HealthPlanScreen> {
  var _discardConfirmed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: _discardConfirmed || !widget.controller.hasUnsavedDraft,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _discardConfirmed) return;
        final discard =
            await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Discard unsaved draft?'),
                content: const Text(
                  'Your unsaved health-plan draft will be lost. Saved plans will not be changed.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('KEEP EDITING'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('DISCARD DRAFT'),
                  ),
                ],
              ),
            ) ??
            false;
        if (!discard || !mounted || !context.mounted) return;
        setState(() => _discardConfirmed = true);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('MY HEALTH PLAN')),
        body: SafeArea(
          child: ResponsiveContent(
            child: ListView(
              children: [
                Text(
                  'Keep your original guidance safe',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter a plan manually or paste text from a document. Sehat Coach will not silently replace it with automatic targets.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _CaptureForm(
                  key: ValueKey(widget.controller.draftGeneration.value),
                  controller: widget.controller,
                ),
                if (widget.controller.message.value case final message?) ...[
                  const SizedBox(height: 12),
                  _Message(message: message, error: false),
                ],
                if (widget.controller.errorMessage.value case final error?) ...[
                  const SizedBox(height: 12),
                  _Message(message: error, error: true),
                ],
                const SizedBox(height: 24),
                Text(
                  'SAVED ORIGINALS',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                if (widget.controller.isLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (widget.controller.plans.isEmpty)
                  const Text('No health plan has been entered yet.')
                else
                  for (final plan in widget.controller.plans)
                    _PlanCard(plan: plan, controller: widget.controller),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CaptureForm extends StatelessWidget {
  const _CaptureForm({super.key, required this.controller});
  final HealthPlanController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        SegmentedButton<HealthPlanCaptureMethod>(
          segments: const [
            ButtonSegment(
              value: HealthPlanCaptureMethod.manualEntry,
              label: Text('Manual'),
              icon: Icon(Icons.edit_note_rounded),
            ),
            ButtonSegment(
              value: HealthPlanCaptureMethod.importedDocument,
              label: Text('Paste document'),
              icon: Icon(Icons.content_paste_rounded),
            ),
          ],
          selected: {controller.captureMethod.value},
          onSelectionChanged: (value) =>
              controller.captureMethod.value = value.single,
        ),
        const SizedBox(height: 14),
        _Field(
          label: 'Plan title',
          initialValue: controller.title.value,
          onChanged: (v) => controller.title.value = v,
        ),
        const SizedBox(height: 10),
        _Field(
          label:
              controller.captureMethod.value ==
                  HealthPlanCaptureMethod.importedDocument
              ? 'Paste original document text'
              : 'Original plan text',
          maxLines: 4,
          initialValue: controller.originalText.value,
          onChanged: (v) => controller.originalText.value = v,
        ),
        if (controller.captureMethod.value ==
            HealthPlanCaptureMethod.importedDocument) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.isImportingDocument.value
                  ? null
                  : () => _selectDocument(context, controller),
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(
                controller.isImportingDocument.value
                    ? 'READING DOCUMENT'
                    : 'SELECT .TXT OR .MD FILE',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Read locally • 1 MB maximum • Review before saving',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 10),
        _Field(
          label: 'Meal label (for example, Breakfast)',
          initialValue: controller.mealLabel.value,
          onChanged: (v) => controller.mealLabel.value = v,
        ),
        const SizedBox(height: 10),
        _Field(
          label: 'Meal instructions',
          maxLines: 3,
          initialValue: controller.mealInstructions.value,
          onChanged: (v) => controller.mealInstructions.value = v,
        ),
        const SizedBox(height: 10),
        _Field(
          label: 'Schedule label (optional)',
          initialValue: controller.scheduleLabel.value,
          onChanged: (v) => controller.scheduleLabel.value = v,
        ),
        Material(
          color: Colors.transparent,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.userReportsClinicianProvided.value,
            onChanged: (value) =>
                controller.userReportsClinicianProvided.value = value ?? false,
            title: const Text('I received this plan from a clinician'),
            subtitle: const Text(
              'This records what you reported. It does not mark the clinician as verified.',
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: controller.isSaving.value ? null : controller.save,
            child: Text(
              controller.isSaving.value ? 'SAVING' : 'SAVE ORIGINAL PLAN',
            ),
          ),
        ),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.onChanged,
    this.maxLines = 1,
    this.initialValue,
  });
  final String label;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? initialValue;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue,
    decoration: InputDecoration(labelText: label),
    maxLines: maxLines,
    onChanged: onChanged,
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.controller});
  final HealthMealPlan plan;
  final HealthPlanController controller;

  @override
  Widget build(BuildContext context) {
    final reported =
        plan.authorship == HealthPlanAuthorship.userReportedClinicianProvided;
    final checkIns = controller.adherenceByPlan[plan.planId] ?? const [];
    final reportDays = controller.reportWindowDays(plan.planId);
    final recent = controller.adherenceSummary(plan.planId);
    final reminder = controller.remindersByPlan[plan.planId];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 5),
          Text(
            reported
                ? 'User-reported clinician plan • Not independently verified'
                : 'User-entered plan',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(plan.instructions.first.instructions),
          const SizedBox(height: 8),
          const Text(
            'Original preserved • Automatic targets do not override this plan',
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: controller.savingReminderPlanId.value == plan.planId
                ? null
                : () => _showReminder(context),
            icon: Icon(
              reminder?.enabled == true
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              size: 19,
            ),
            label: Text(
              reminder?.enabled == true
                  ? 'Reminder preference on'
                  : 'Set reminder preference',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.checkingInPlanId.value == plan.planId
                      ? null
                      : () => _showCheckIn(context),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('MEAL CHECK-IN'),
                ),
              ),
              if (checkIns.isNotEmpty) ...[
                const SizedBox(width: 10),
                _CheckInCount(count: checkIns.length),
              ],
            ],
          ),
          if (checkIns.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Latest: ${_outcomeLabel(checkIns.first.outcome)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.checkingInPlanId.value == plan.planId
                      ? null
                      : () => _showCheckIn(context, correction: checkIns.first),
                  icon: const Icon(Icons.edit_rounded, size: 17),
                  label: const Text('Correct'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RecentSummary(
              summary: recent,
              days: reportDays,
              onDaysChanged: (days) =>
                  controller.setReportWindow(plan.planId, days),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showExport(context),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Export report'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCheckIn(
    BuildContext context, {
    HealthPlanAdherenceEvent? correction,
  }) async {
    var selected = correction?.outcome ?? HealthPlanAdherenceOutcome.completed;
    final note = TextEditingController(text: correction?.note);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                correction == null
                    ? 'How did this meal go?'
                    : 'Correct this check-in',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                plan.instructions.first.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final outcome in HealthPlanAdherenceOutcome.values)
                    ChoiceChip(
                      label: Text(_outcomeLabel(outcome)),
                      selected: selected == outcome,
                      onSelected: (_) =>
                          setModalState(() => selected = outcome),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: note,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Private note (optional)',
                  hintText: 'Anything you want to remember?',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final saved = correction == null
                        ? await controller.checkIn(
                            plan: plan,
                            instruction: plan.instructions.first,
                            outcome: selected,
                            note: note.text,
                          )
                        : await controller.correctCheckIn(
                            original: correction,
                            outcome: selected,
                            note: note.text,
                          );
                    if (saved && sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: Text(
                    correction == null ? 'SAVE CHECK-IN' : 'SAVE CORRECTION',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                correction == null
                    ? 'This records what happened. It does not change your plan.'
                    : 'The earlier version stays safely in your audit history.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
    note.dispose();
  }

  Future<void> _showExport(BuildContext context) async {
    var includePrivateNotes = false;
    final messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final report = controller.buildExport(
            plan,
            includePrivateNotes: includePrivateNotes,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review report export',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Account identity and original plan text are excluded.',
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: includePrivateNotes,
                  onChanged: (value) =>
                      setModalState(() => includePrivateNotes = value ?? false),
                  title: const Text('Include my private notes'),
                  subtitle: const Text(
                    'Off by default. Turn on only if you intend to share them.',
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      report.content,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: report.content),
                      );
                      if (!sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Report copied to clipboard.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('COPY REVIEWED REPORT'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReminder(BuildContext context) async {
    final existing = controller.remindersByPlan[plan.planId];
    var enabled = existing?.enabled ?? false;
    var minuteOfDay = existing?.localMinuteOfDay ?? 8 * 60;
    final weekdays = <int>{...?existing?.weekdays};
    if (existing == null) weekdays.addAll(const {1, 2, 3, 4, 5, 6, 7});
    final localNow = DateTime.now();
    final timezoneName = _deviceTimezoneLabel(localNow);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminder preference',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'Saving this preference does not enable device notifications yet.',
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: enabled,
                onChanged: (value) => setModalState(() => enabled = value),
                title: const Text('Remind me about this plan'),
              ),
              if (enabled) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var day = 1; day <= 7; day++)
                      Semantics(
                        label: _weekdayName(day),
                        selected: weekdays.contains(day),
                        button: true,
                        excludeSemantics: true,
                        child: FilterChip(
                          label: Text(_weekdayLabel(day)),
                          selected: weekdays.contains(day),
                          onSelected: (selected) => setModalState(() {
                            if (selected) {
                              weekdays.add(day);
                            } else {
                              weekdays.remove(day);
                            }
                          }),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: minuteOfDay ~/ 60,
                        minute: minuteOfDay % 60,
                      ),
                    );
                    if (picked != null) {
                      setModalState(
                        () => minuteOfDay = picked.hour * 60 + picked.minute,
                      );
                    }
                  },
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(
                    TimeOfDay(
                      hour: minuteOfDay ~/ 60,
                      minute: minuteOfDay % 60,
                    ).format(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timezoneName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final saved = await controller.saveReminder(
                      plan: plan,
                      enabled: enabled,
                      localMinuteOfDay: minuteOfDay,
                      weekdays: enabled ? weekdays : const {},
                      timezoneName: timezoneName,
                    );
                    if (saved && sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: const Text('SAVE PREFERENCE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSummary extends StatelessWidget {
  const _RecentSummary({
    required this.summary,
    required this.days,
    required this.onDaysChanged,
  });
  final HealthPlanAdherenceSummary summary;
  final int days;
  final ValueChanged<int> onDaysChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'LAST $days DAYS',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            for (final option in const [7, 30, 90]) ...[
              const SizedBox(width: 5),
              Semantics(
                label: 'Show the last $option days',
                selected: days == option,
                button: true,
                excludeSemantics: true,
                child: ChoiceChip(
                  label: Text('${option}d'),
                  selected: days == option,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => onDaysChanged(option),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            for (final outcome in HealthPlanAdherenceOutcome.values)
              Expanded(
                child: _SummaryValue(
                  value: summary.count(outcome),
                  label: _shortOutcomeLabel(outcome),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'A factual summary of saved check-ins—not a health score.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 2),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _CheckInCount extends StatelessWidget {
  const _CheckInCount({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Text('$count saved'),
  );
}

String _outcomeLabel(HealthPlanAdherenceOutcome outcome) => switch (outcome) {
  HealthPlanAdherenceOutcome.completed => 'Completed',
  HealthPlanAdherenceOutcome.partiallyCompleted => 'Partly completed',
  HealthPlanAdherenceOutcome.skipped => 'Skipped',
};

String _shortOutcomeLabel(HealthPlanAdherenceOutcome outcome) =>
    switch (outcome) {
      HealthPlanAdherenceOutcome.completed => 'Completed',
      HealthPlanAdherenceOutcome.partiallyCompleted => 'Partial',
      HealthPlanAdherenceOutcome.skipped => 'Skipped',
    };

String _weekdayLabel(int day) =>
    const {1: 'M', 2: 'T', 3: 'W', 4: 'T', 5: 'F', 6: 'S', 7: 'S'}[day]!;

String _weekdayName(int day) => const {
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday',
}[day]!;

String _deviceTimezoneLabel(DateTime local) {
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inMinutes.abs() ~/ 60;
  final minutes = offset.inMinutes.abs() % 60;
  final value =
      '$sign${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
  final name = local.timeZoneName.trim();
  return '${name.isEmpty ? 'Device timezone' : name} (UTC$value)';
}

Future<void> _selectDocument(
  BuildContext context,
  HealthPlanController controller,
) async {
  var replaceExisting = false;
  if (controller.originalText.value.trim().isNotEmpty) {
    replaceExisting =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Replace current document text?'),
            content: const Text(
              'The selected file will replace the text currently in this draft. Nothing already saved will be changed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('KEEP CURRENT TEXT'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('SELECT AND REPLACE'),
              ),
            ],
          ),
        ) ??
        false;
    if (!replaceExisting) return;
  }
  await controller.importTextDocument(replaceExisting: replaceExisting);
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.error});
  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: '${error ? 'Error' : 'Status'}: $message',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFF1EE) : const Color(0xFFF0F7F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message),
    ),
  );
}
