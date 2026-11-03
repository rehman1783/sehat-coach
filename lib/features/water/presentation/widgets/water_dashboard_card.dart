import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/water_tracker_controller.dart';
import '../../domain/hydration_preferences.dart';

class WaterDashboardCard extends StatelessWidget {
  const WaterDashboardCard({super.key, required this.controller});

  final WaterTrackerController controller;

  Future<void> _configure(BuildContext context) async {
    final current = controller.hydrationPreferences.value;
    final target = TextEditingController(
      text: current?.targetMilliliters?.toString() ?? '',
    );
    final note = TextEditingController(text: current?.restrictionNote ?? '');
    var source = current?.targetSource == HydrationTargetSource.clinician
        ? HydrationTargetSource.clinician
        : HydrationTargetSource.user;
    var remindersEnabled = current?.remindersEnabled ?? false;
    var startMinute = current?.reminderStartMinute ?? 480;
    var endMinute = current?.reminderEndMinute ?? 1200;
    var intervalMinutes = current?.reminderIntervalMinutes ?? 120;
    final result = await showModalBottomSheet<_HydrationTargetDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hydration target',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Optional wellness tracking only. Sehat Coach does not prescribe a universal water target.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: target,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily target (ml)',
                    hintText: '250–10000',
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save reminder preference'),
                  subtitle: const Text(
                    'Device notifications are not active yet.',
                  ),
                  value: remindersEnabled,
                  onChanged: (value) =>
                      setModalState(() => remindersEnabled = value),
                ),
                if (remindersEnabled) ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final from = DropdownButtonFormField<int>(
                        initialValue: startMinute,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'From'),
                        items: const [360, 480, 600, 720]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(_timeLabel(value)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => startMinute = value);
                          }
                        },
                      );
                      final until = DropdownButtonFormField<int>(
                        initialValue: endMinute,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Until'),
                        items: const [1080, 1200, 1320, 1380]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(_timeLabel(value)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => endMinute = value);
                          }
                        },
                      );
                      final stack =
                          constraints.maxWidth < 380 ||
                          MediaQuery.textScalerOf(context).scale(1) > 1.3;
                      if (stack) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [from, const SizedBox(height: 10), until],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: from),
                          const SizedBox(width: 10),
                          Expanded(child: until),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: intervalMinutes,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    items: const [60, 120, 180, 240]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              'Every ${value ~/ 60} hour${value == 60 ? '' : 's'}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => intervalMinutes = value);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 10),
                DropdownButtonFormField<HydrationTargetSource>(
                  initialValue: source,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Target source'),
                  items: const [
                    DropdownMenuItem(
                      value: HydrationTargetSource.user,
                      child: Text('My personal preference'),
                    ),
                    DropdownMenuItem(
                      value: HydrationTargetSource.clinician,
                      child: Text('Clinician-provided guidance'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setModalState(() => source = value);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: note,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Optional restriction or context',
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final remove = current?.targetMilliliters == null
                        ? null
                        : TextButton(
                            onPressed: () => Navigator.pop(
                              context,
                              const _HydrationTargetDraft.clear(),
                            ),
                            child: const Text('REMOVE TARGET'),
                          );
                    final save = FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _HydrationTargetDraft(
                          milliliters: int.tryParse(target.text),
                          source: source,
                          note: note.text,
                          remindersEnabled: remindersEnabled,
                          startMinute: startMinute,
                          endMinute: endMinute,
                          intervalMinutes: intervalMinutes,
                        ),
                      ),
                      child: const Text('SAVE TARGET'),
                    );
                    final stack =
                        constraints.maxWidth < 380 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.3;
                    if (stack) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (remove != null) ...[
                            remove,
                            const SizedBox(height: 8),
                          ],
                          save,
                        ],
                      );
                    }
                    return Row(children: [?remove, const Spacer(), save]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    target.dispose();
    note.dispose();
    if (result == null) return;
    await controller.saveTarget(
      targetMilliliters: result.milliliters,
      source: result.source,
      restrictionNote: result.note,
      remindersEnabled: result.remindersEnabled,
      reminderStartMinute: result.startMinute,
      reminderEndMinute: result.endMinute,
      reminderIntervalMinutes: result.intervalMinutes,
    );
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final total = controller.summary.value?.totalMilliliters ?? 0;
    final enabled = controller.isToday && !controller.isSaving.value;
    final preferences = controller.hydrationPreferences.value;
    final target = preferences?.targetMilliliters;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7F7F4), Color(0xFFF3FAF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFE4DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedScale(
                scale: controller.isSaving.value ? 1.16 : 1,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: Color(0xFF168C80),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WATER LOGGED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF14756C),
                        letterSpacing: 1.1,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: total.toDouble()),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        '${value.round()} ml',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoading.value)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              IconButton(
                tooltip: 'Configure hydration target',
                onPressed: controller.isSaving.value
                    ? null
                    : () => _configure(context),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          if (target != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (total / target).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: const Color(0xFFCFEAE5),
              color: const Color(0xFF168C80),
            ),
            const SizedBox(height: 6),
            Text(
              '$total / $target ml • ${preferences!.targetSource == HydrationTargetSource.clinician ? 'Clinician-provided' : 'Personal'} target',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (preferences.restrictionNote.isNotEmpty)
              Text(
                preferences.restrictionNote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No universal target applied. Add one only if it suits you or follows clinician guidance.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (preferences?.remindersEnabled ?? false) ...[
            const SizedBox(height: 8),
            Text(
              'Reminder preference: ${_timeLabel(preferences!.reminderStartMinute)}–${_timeLabel(preferences.reminderEndMinute)}, every ${preferences.reminderIntervalMinutes ~/ 60} hour${preferences.reminderIntervalMinutes == 60 ? '' : 's'}. Device delivery is not active yet.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF14756C)),
            ),
          ],
          const SizedBox(height: 14),
          if (controller.isToday)
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    label: '+250 ml',
                    enabled: enabled,
                    onPressed: () => controller.quickAdd(250),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAddButton(
                    label: '+500 ml',
                    enabled: enabled,
                    onPressed: () => controller.quickAdd(500),
                  ),
                ),
              ],
            )
          else
            Text(
              'Past-day intake is shown for review. New water is logged on today only.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (controller.errorMessage.value case final error?) ...[
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
        ],
      ),
    );
  });
}

class _HydrationTargetDraft {
  const _HydrationTargetDraft({
    required this.milliliters,
    required this.source,
    required this.note,
    required this.remindersEnabled,
    required this.startMinute,
    required this.endMinute,
    required this.intervalMinutes,
  });

  const _HydrationTargetDraft.clear()
    : milliliters = null,
      source = HydrationTargetSource.none,
      note = '',
      remindersEnabled = false,
      startMinute = 480,
      endMinute = 1200,
      intervalMinutes = 120;

  final int? milliliters;
  final HydrationTargetSource source;
  final String note;
  final bool remindersEnabled;
  final int startMinute;
  final int endMinute;
  final int intervalMinutes;
}

String _timeLabel(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = (minuteOfDay % 60).toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final twelveHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$twelveHour:$minute $suffix';
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: enabled ? onPressed : null,
    style: OutlinedButton.styleFrom(
      backgroundColor: AppColors.surface,
      foregroundColor: const Color(0xFF14756C),
      side: const BorderSide(color: Color(0xFF9BD2C7)),
    ),
    child: Text(label),
  );
}
