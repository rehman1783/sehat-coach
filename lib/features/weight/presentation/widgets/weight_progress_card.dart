import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/weight_tracking.dart';
import '../controllers/weight_tracker_controller.dart';

class WeightProgressCard extends StatefulWidget {
  const WeightProgressCard({super.key, required this.controller});

  final WeightTrackerController controller;

  @override
  State<WeightProgressCard> createState() => _WeightProgressCardState();
}

class _WeightProgressCardState extends State<WeightProgressCard> {
  Future<void> _showEntry([WeightEvent? original]) async {
    final weight = TextEditingController(
      text: widget.controller
          .displayWeight(
            original?.weightKilograms ??
                widget.controller.progress.currentKilograms,
          )
          .toStringAsFixed(1),
    );
    final note = TextEditingController(text: original?.note ?? '');
    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
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
                original == null ? 'Log weight' : 'Correct check-in',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Daily changes are normal. This record is for your own trend history.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weight,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Weight (${widget.controller.unitLabel})',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: note,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Optional note',
                  hintText: 'e.g. morning check-in',
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    original == null ? 'SAVE CHECK-IN' : 'SAVE CORRECTION',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (shouldSave == true) {
      final value = double.tryParse(weight.text) ?? double.nan;
      if (original == null) {
        await widget.controller.log(displayValue: value, note: note.text);
      } else {
        await widget.controller.correct(
          original: original,
          displayValue: value,
          note: note.text,
        );
      }
    }
    weight.dispose();
    note.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final controller = widget.controller;
    final progress = controller.progress;
    final latest = controller.events.firstOrNull;
    final value = progress.directionalFraction;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9CFF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final identity = Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_outlined,
                      color: Color(0xFF66518C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEIGHT CHECK-INS',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color(0xFF66518C),
                                letterSpacing: 1.1,
                              ),
                        ),
                        Text(
                          '${controller.displayWeight(progress.currentKilograms).toStringAsFixed(1)} ${controller.unitLabel}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final checkIn = OutlinedButton.icon(
                onPressed: controller.isSaving.value ? null : _showEntry,
                icon: const Icon(Icons.add_rounded),
                label: const Text('CHECK IN'),
              );
              final stack =
                  constraints.maxWidth < 380 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.3;
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [identity, const SizedBox(height: 10), checkIn],
                );
              }
              return Row(
                children: [
                  Expanded(child: identity),
                  checkIn,
                ],
              );
            },
          ),
          if (value != null) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: const Color(0xFFE4DDF2),
              color: const Color(0xFF66518C),
            ),
            const SizedBox(height: 7),
            Text(
              'Starting ${controller.displayWeight(progress.startingKilograms).toStringAsFixed(1)} • Personal target ${controller.displayWeight(progress.targetKilograms).toStringAsFixed(1)} ${controller.unitLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (latest != null) ...[
            const SizedBox(height: 10),
            Text(
              '${controller.events.length} check-in${controller.events.length == 1 ? '' : 's'} saved offline. Latest ${_date(latest.occurredAtUtc, latest.timezoneOffsetMinutes)}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (controller.events.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...controller.events
                .take(5)
                .map(
                  (event) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: Color(0xFF66518C),
                    ),
                    title: Text(
                      '${controller.displayWeight(event.weightKilograms).toStringAsFixed(1)} ${controller.unitLabel}',
                    ),
                    subtitle: Text(
                      event.note.isEmpty
                          ? _date(
                              event.occurredAtUtc,
                              event.timezoneOffsetMinutes,
                            )
                          : '${_date(event.occurredAtUtc, event.timezoneOffsetMinutes)} • ${event.note}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: 'Correct check-in',
                      onPressed: controller.isSaving.value
                          ? null
                          : () => _showEntry(event),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                    ),
                  ),
                ),
          ],
          if (controller.errorMessage.value case final error?) ...[
            const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          Text(
            'Focus on the longer trend; a single reading does not measure fat change.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  });

  String _date(DateTime utc, int offset) {
    final local = utc.add(Duration(minutes: offset));
    return '${local.day}/${local.month}/${local.year}';
  }
}
