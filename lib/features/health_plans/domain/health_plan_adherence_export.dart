import 'dart:convert';

import 'health_meal_plan.dart';
import 'health_plan_adherence.dart';

class HealthPlanAdherenceExport {
  const HealthPlanAdherenceExport({
    required this.content,
    required this.generatedAtUtc,
    required this.includesPrivateNotes,
    required this.eventCount,
  });

  final String content;
  final DateTime generatedAtUtc;
  final bool includesPrivateNotes;
  final int eventCount;
}

class BuildHealthPlanAdherenceExport {
  const BuildHealthPlanAdherenceExport();

  HealthPlanAdherenceExport execute({
    required HealthMealPlan plan,
    required HealthPlanAdherenceSummary summary,
    required DateTime generatedAtUtc,
    bool includePrivateNotes = false,
  }) {
    if (!generatedAtUtc.isUtc) {
      throw ArgumentError('Export timestamp must be UTC');
    }
    final content = const JsonEncoder.withIndent('  ').convert({
      'format': 'sehat_coach_adherence_v1',
      'generatedAtUtc': generatedAtUtc.toIso8601String(),
      'notice': 'User-recorded history. Not a diagnosis or health score.',
      'plan': {'title': plan.title, 'authorship': plan.authorship.name},
      'period': {
        'fromUtc': summary.fromUtc.toIso8601String(),
        'toUtcExclusive': summary.toUtc.toIso8601String(),
      },
      'counts': {
        for (final outcome in HealthPlanAdherenceOutcome.values)
          outcome.name: summary.count(outcome),
      },
      'privateNotesIncluded': includePrivateNotes,
      'events': [
        for (final event in summary.events)
          {
            'occurredAtUtc': event.occurredAtUtc.toIso8601String(),
            'timezoneOffsetMinutes': event.timezoneOffsetMinutes,
            'instructionId': event.instructionId,
            'planRevisionNumber': event.planRevisionNumber,
            'outcome': event.outcome.name,
            if (includePrivateNotes) 'privateNote': event.note,
          },
      ],
    });
    return HealthPlanAdherenceExport(
      content: content,
      generatedAtUtc: generatedAtUtc,
      includesPrivateNotes: includePrivateNotes,
      eventCount: summary.total,
    );
  }
}
