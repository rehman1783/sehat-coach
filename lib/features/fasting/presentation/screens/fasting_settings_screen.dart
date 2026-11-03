import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/fasting_schedule.dart';
import '../controllers/fasting_settings_controller.dart';

class FastingSettingsScreen extends StatefulWidget {
  const FastingSettingsScreen({super.key, required this.controller});

  final FastingSettingsController controller;

  @override
  State<FastingSettingsScreen> createState() => _FastingSettingsScreenState();
}

class _FastingSettingsScreenState extends State<FastingSettingsScreen> {
  bool _discardConfirmed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Future<void> _pickTime(bool start) async {
    final value = start
        ? widget.controller.startMinute.value
        : widget.controller.endMinute.value;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: value ~/ 60, minute: value % 60),
    );
    if (selected == null) return;
    if (start) {
      widget.controller.setStartTime(selected.hour, selected.minute);
    } else {
      widget.controller.setEndTime(selected.hour, selected.minute);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final controller = widget.controller;
    return PopScope(
      canPop: _discardConfirmed || !controller.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _discardConfirmed || !controller.hasUnsavedChanges) {
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard unsaved changes?'),
            content: const Text(
              'Your fasting settings changes have not been saved. Your previously saved settings will stay unchanged.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('KEEP EDITING'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('DISCARD CHANGES'),
              ),
            ],
          ),
        );
        if (discard != true || !mounted || !context.mounted) return;
        setState(() => _discardConfirmed = true);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('FASTING SETTINGS')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Obx(() {
                final controller = widget.controller;
                final blocked = controller.assessment.value.blockAutomaticPlan;
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: blocked
                            ? const Color(0xFFFFF1EE)
                            : const Color(0xFFF0F7F2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: blocked
                              ? AppColors.errorRed.withValues(alpha: 0.35)
                              : AppColors.border,
                        ),
                      ),
                      child: Text(controller.assessment.value.message),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: controller.enabled.value,
                      onChanged: controller.setEnabled,
                      title: const Text('Enable fasting schedule'),
                      subtitle: const Text(
                        'You stay in control of this setting.',
                      ),
                    ),
                    if (controller.enabled.value) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<FastingScheduleType>(
                        initialValue: controller.scheduleType.value,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Schedule type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: FastingScheduleType.ramadan,
                            child: Text('Ramadan'),
                          ),
                          DropdownMenuItem(
                            value: FastingScheduleType.sunnah,
                            child: Text('Sunnah fast'),
                          ),
                          DropdownMenuItem(
                            value: FastingScheduleType.intermittent,
                            child: Text('Intermittent fast'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.scheduleType.value = value;
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stackControls =
                              constraints.maxWidth < 380 ||
                              MediaQuery.textScalerOf(context).scale(1) > 1.3;
                          final startButton = OutlinedButton.icon(
                            onPressed: () => _pickTime(true),
                            icon: const Icon(Icons.nightlight_outlined),
                            label: Text(
                              'Start ${_time(controller.startMinute.value)}',
                            ),
                          );
                          final endButton = OutlinedButton.icon(
                            onPressed: () => _pickTime(false),
                            icon: const Icon(Icons.wb_sunny_outlined),
                            label: Text(
                              'End ${_time(controller.endMinute.value)}',
                            ),
                          );
                          if (stackControls) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                startButton,
                                const SizedBox(height: 10),
                                endButton,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: startButton),
                              const SizedBox(width: 10),
                              Expanded(child: endButton),
                            ],
                          );
                        },
                      ),
                      SwitchListTile(
                        value: controller.suhoorReminderEnabled.value,
                        onChanged: (value) =>
                            controller.suhoorReminderEnabled.value = value,
                        title: const Text('Suhoor reminder preference'),
                      ),
                      SwitchListTile(
                        value: controller.iftarReminderEnabled.value,
                        onChanged: (value) =>
                            controller.iftarReminderEnabled.value = value,
                        title: const Text('Iftar reminder preference'),
                      ),
                      const Text(
                        'Times are currently user-entered. Device notification delivery is not active yet.',
                      ),
                    ],
                    if (controller.errorMessage.value case final error?) ...[
                      const SizedBox(height: 12),
                      Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.errorRed),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.save,
                      child: Text(
                        controller.isSaving.value ? 'SAVING' : 'SAVE SETTINGS',
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
}

String _time(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = (minuteOfDay % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}
