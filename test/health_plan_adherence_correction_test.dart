import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/health_plans/data/local_change_health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_capture.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';

void main() {
  test(
    'correction supersedes the visible event and preserves audit history',
    () async {
      final store = MemoryLocalChangeStore();
      final repository = LocalChangeHealthPlanRepository(store, 'owner-a');
      final original = _event('event-1');
      await repository.saveAdherence(original);

      final correction =
          await CorrectHealthPlanAdherence(
            session: const _Session(),
            repository: repository,
            ids: const _Ids(),
            clock: const _Clock(),
          ).execute(
            originalEventId: original.eventId,
            outcome: HealthPlanAdherenceOutcome.partiallyCompleted,
            note: 'Corrected fixture',
          );

      expect(correction.supersedesEventId, original.eventId);
      expect(correction.revision, 2);
      expect(
        await repository.readActiveAdherence('owner-a', original.eventId),
        isNull,
      );
      expect(
        (await repository.listAdherence('owner-a', 'plan-1')).single.eventId,
        'event-2',
      );
      expect(
        await repository.listAdherenceAudit('owner-a', 'plan-1'),
        hasLength(2),
      );
      expect(await store.pending('owner-a'), hasLength(2));
    },
  );

  test('cannot correct the same event twice', () async {
    final repository = LocalChangeHealthPlanRepository(
      MemoryLocalChangeStore(),
      'owner-a',
    );
    final original = _event('event-1');
    await repository.saveAdherence(original);
    final correct = CorrectHealthPlanAdherence(
      session: const _Session(),
      repository: repository,
      ids: const _Ids(),
      clock: const _Clock(),
    );
    await correct.execute(
      originalEventId: original.eventId,
      outcome: HealthPlanAdherenceOutcome.completed,
    );
    await expectLater(
      correct.execute(
        originalEventId: original.eventId,
        outcome: HealthPlanAdherenceOutcome.skipped,
      ),
      throwsA(isA<HealthPlanAdherenceCorrectionUnavailable>()),
    );
  });
}

HealthPlanAdherenceEvent _event(String id) => HealthPlanAdherenceEvent(
  eventId: id,
  ownerId: 'owner-a',
  planId: 'plan-1',
  instructionId: 'meal-1',
  planRevisionNumber: 0,
  outcome: HealthPlanAdherenceOutcome.skipped,
  occurredAtUtc: DateTime.utc(2026, 10, 24, 8),
  timezoneOffsetMinutes: 300,
  recordedAtUtc: DateTime.utc(2026, 10, 24, 9),
);

class _Session implements AuthenticatedOwnerSession {
  const _Session();
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Ids implements HealthPlanIdGenerator {
  const _Ids();
  @override
  String nextId() => 'event-2';
}

class _Clock implements HealthPlanClock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24, 10);
}
