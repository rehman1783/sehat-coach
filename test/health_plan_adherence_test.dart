import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/health_plans/data/local_change_health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_capture.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_repository.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';

void main() {
  test('records a factual check-in without changing the plan', () async {
    final fixture = _Fixture();
    await fixture.create.execute(_plan());

    final event = await fixture.log.execute(
      planId: 'plan-1',
      instructionId: 'meal-1',
      outcome: HealthPlanAdherenceOutcome.partiallyCompleted,
      occurredAt: DateTime(2026, 10, 24, 8),
      note: '  Synthetic note  ',
    );

    expect(event.planRevisionNumber, 0);
    expect(event.note, 'Synthetic note');
    final restored = await fixture.repository.listAdherence(
      'owner-a',
      'plan-1',
    );
    expect(restored.single.eventId, event.eventId);
    expect(
      restored.single.outcome,
      HealthPlanAdherenceOutcome.partiallyCompleted,
    );
    expect(restored.single.note, 'Synthetic note');
    expect(
      (await fixture.repository.readPlan(
        'owner-a',
        'plan-1',
      ))?.instructions.single.instructions,
      'Synthetic fixture meal',
    );
    expect(await fixture.store.pending('owner-a'), hasLength(2));
  });

  test('rejects check-ins for missing or inactive instructions', () async {
    final fixture = _Fixture();
    await fixture.create.execute(_plan());
    await expectLater(
      fixture.log.execute(
        planId: 'plan-1',
        instructionId: 'missing',
        outcome: HealthPlanAdherenceOutcome.skipped,
        occurredAt: DateTime(2026, 10, 24, 8),
      ),
      throwsStateError,
    );
    expect(
      await fixture.repository.listAdherence('owner-a', 'plan-1'),
      isEmpty,
    );
  });

  test('rejects cross-owner persistence and overlong private notes', () async {
    final fixture = _Fixture();
    expect(
      () => HealthPlanAdherenceEvent(
        eventId: 'event-1',
        ownerId: 'owner-a',
        planId: 'plan-1',
        instructionId: 'meal-1',
        planRevisionNumber: 0,
        outcome: HealthPlanAdherenceOutcome.completed,
        occurredAtUtc: DateTime.utc(2026, 10, 24),
        timezoneOffsetMinutes: 300,
        recordedAtUtc: DateTime.utc(2026, 10, 24),
        note: 'x' * 501,
      ),
      throwsArgumentError,
    );
    final foreign = HealthPlanAdherenceEvent(
      eventId: 'event-2',
      ownerId: 'owner-b',
      planId: 'plan-1',
      instructionId: 'meal-1',
      planRevisionNumber: 0,
      outcome: HealthPlanAdherenceOutcome.completed,
      occurredAtUtc: DateTime.utc(2026, 10, 24),
      timezoneOffsetMinutes: 300,
      recordedAtUtc: DateTime.utc(2026, 10, 24),
    );
    await expectLater(
      fixture.repository.saveAdherence(foreign),
      throwsStateError,
    );
  });
}

class _Fixture {
  _Fixture() {
    store = MemoryLocalChangeStore();
    repository = LocalChangeHealthPlanRepository(store, 'owner-a');
    create = CreateHealthMealPlan(
      session: const _Session(),
      repository: repository,
    );
    log = LogHealthPlanAdherence(
      session: const _Session(),
      repository: repository,
      ids: const _Ids(),
      clock: const _Clock(),
    );
  }

  late final MemoryLocalChangeStore store;
  late final LocalChangeHealthPlanRepository repository;
  late final CreateHealthMealPlan create;
  late final LogHealthPlanAdherence log;
}

class _Session implements AuthenticatedOwnerSession {
  const _Session();
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Ids implements HealthPlanIdGenerator {
  const _Ids();
  @override
  String nextId() => 'event-1';
}

class _Clock implements HealthPlanClock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24, 12);
}

HealthMealPlan _plan() => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Synthetic plan',
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Immutable synthetic original',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'meal-1',
      label: 'Breakfast',
      instructions: 'Synthetic fixture meal',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);
