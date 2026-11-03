import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence_export.dart';

void main() {
  test('safe default omits owner, original plan text and private notes', () {
    final result = const BuildHealthPlanAdherenceExport().execute(
      plan: _plan(),
      summary: _summary(),
      generatedAtUtc: DateTime.utc(2026, 10, 24, 12),
    );
    final decoded = jsonDecode(result.content) as Map<String, dynamic>;
    final event = (decoded['events'] as List).single as Map<String, dynamic>;

    expect(result.includesPrivateNotes, isFalse);
    expect(event.containsKey('privateNote'), isFalse);
    expect(result.content, isNot(contains('owner-a')));
    expect(result.content, isNot(contains('Sensitive original plan text')));
    expect(decoded['notice'], contains('Not a diagnosis'));
  });

  test('private notes require an explicit export option', () {
    final result = const BuildHealthPlanAdherenceExport().execute(
      plan: _plan(),
      summary: _summary(),
      generatedAtUtc: DateTime.utc(2026, 10, 24, 12),
      includePrivateNotes: true,
    );
    expect(result.includesPrivateNotes, isTrue);
    expect(result.content, contains('Private fixture note'));
  });
}

HealthMealPlan _plan() => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Synthetic plan',
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Sensitive original plan text',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'meal-1',
      label: 'Breakfast',
      instructions: 'Synthetic instruction',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 20),
);

HealthPlanAdherenceSummary _summary() => HealthPlanAdherenceSummary(
  events: [
    HealthPlanAdherenceEvent(
      eventId: 'event-1',
      ownerId: 'owner-a',
      planId: 'plan-1',
      instructionId: 'meal-1',
      planRevisionNumber: 0,
      outcome: HealthPlanAdherenceOutcome.completed,
      occurredAtUtc: DateTime.utc(2026, 10, 24, 8),
      timezoneOffsetMinutes: 300,
      recordedAtUtc: DateTime.utc(2026, 10, 24, 9),
      note: 'Private fixture note',
    ),
  ],
  fromUtc: DateTime.utc(2026, 10, 18),
  toUtc: DateTime.utc(2026, 10, 25),
);
