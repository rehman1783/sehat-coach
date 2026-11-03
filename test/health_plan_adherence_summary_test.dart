import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence.dart';

void main() {
  test('summarizes only events inside the requested interval', () {
    final summary = HealthPlanAdherenceSummary(
      events: [
        _event('inside-1', HealthPlanAdherenceOutcome.completed, 24),
        _event('inside-2', HealthPlanAdherenceOutcome.partiallyCompleted, 23),
        _event('inside-3', HealthPlanAdherenceOutcome.skipped, 22),
        _event('outside', HealthPlanAdherenceOutcome.completed, 10),
      ],
      fromUtc: DateTime.utc(2026, 10, 20),
      toUtc: DateTime.utc(2026, 10, 25),
    );

    expect(summary.total, 3);
    expect(summary.count(HealthPlanAdherenceOutcome.completed), 1);
    expect(summary.count(HealthPlanAdherenceOutcome.partiallyCompleted), 1);
    expect(summary.count(HealthPlanAdherenceOutcome.skipped), 1);
    expect(
      summary.proportion(HealthPlanAdherenceOutcome.completed),
      closeTo(1 / 3, 0.001),
    );
  });

  test('empty summary has zero proportions and invalid windows fail', () {
    final summary = HealthPlanAdherenceSummary(
      events: const [],
      fromUtc: DateTime.utc(2026, 10, 20),
      toUtc: DateTime.utc(2026, 10, 25),
    );
    expect(summary.total, 0);
    expect(summary.proportion(HealthPlanAdherenceOutcome.completed), 0);
    expect(
      () => HealthPlanAdherenceSummary(
        events: const [],
        fromUtc: DateTime.utc(2026, 10, 25),
        toUtc: DateTime.utc(2026, 10, 20),
      ),
      throwsArgumentError,
    );
  });
}

HealthPlanAdherenceEvent _event(
  String id,
  HealthPlanAdherenceOutcome outcome,
  int day,
) => HealthPlanAdherenceEvent(
  eventId: id,
  ownerId: 'owner-a',
  planId: 'plan-1',
  instructionId: 'meal-1',
  planRevisionNumber: 0,
  outcome: outcome,
  occurredAtUtc: DateTime.utc(2026, 10, day, 8),
  timezoneOffsetMinutes: 300,
  recordedAtUtc: DateTime.utc(2026, 10, day, 9),
);
