import '../../account/domain/authenticated_owner_session.dart';
import 'health_plan_capture.dart';
import 'health_plan_repository.dart';

enum HealthPlanAdherenceOutcome { completed, partiallyCompleted, skipped }

class HealthPlanAdherenceSummary {
  HealthPlanAdherenceSummary({
    required Iterable<HealthPlanAdherenceEvent> events,
    required this.fromUtc,
    required this.toUtc,
  }) : events = List.unmodifiable(
         events.where(
           (event) =>
               !event.occurredAtUtc.isBefore(fromUtc) &&
               event.occurredAtUtc.isBefore(toUtc),
         ),
       ) {
    if (!fromUtc.isUtc || !toUtc.isUtc || !fromUtc.isBefore(toUtc)) {
      throw ArgumentError('A valid UTC adherence interval is required');
    }
  }

  final DateTime fromUtc;
  final DateTime toUtc;
  final List<HealthPlanAdherenceEvent> events;

  int count(HealthPlanAdherenceOutcome outcome) =>
      events.where((event) => event.outcome == outcome).length;

  int get total => events.length;

  double proportion(HealthPlanAdherenceOutcome outcome) =>
      total == 0 ? 0 : count(outcome) / total;
}

/// A factual user check-in. It never edits the source plan or implies blame.
class HealthPlanAdherenceEvent {
  HealthPlanAdherenceEvent({
    required this.eventId,
    required this.ownerId,
    required this.planId,
    required this.instructionId,
    required this.planRevisionNumber,
    required this.outcome,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.recordedAtUtc,
    this.note = '',
    this.supersedesEventId,
    this.revision = 1,
  }) {
    if (eventId.trim().isEmpty ||
        ownerId.trim().isEmpty ||
        planId.trim().isEmpty ||
        instructionId.trim().isEmpty) {
      throw ArgumentError('Complete adherence identity is required');
    }
    if (planRevisionNumber < 0) {
      throw ArgumentError.value(planRevisionNumber, 'planRevisionNumber');
    }
    if (!occurredAtUtc.isUtc || !recordedAtUtc.isUtc) {
      throw ArgumentError('Adherence timestamps must be UTC');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (note.length > 500) throw ArgumentError('Adherence note is too long');
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (supersedesEventId != null &&
        (supersedesEventId!.trim().isEmpty || supersedesEventId == eventId)) {
      throw ArgumentError('Invalid superseded adherence event');
    }
  }

  final String eventId;
  final String ownerId;
  final String planId;
  final String instructionId;
  final int planRevisionNumber;
  final HealthPlanAdherenceOutcome outcome;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime recordedAtUtc;
  final String note;
  final String? supersedesEventId;
  final int revision;
}

class LogHealthPlanAdherence {
  const LogHealthPlanAdherence({
    required this.session,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;
  final HealthPlanIdGenerator ids;
  final HealthPlanClock clock;

  Future<HealthPlanAdherenceEvent> execute({
    required String planId,
    required String instructionId,
    required HealthPlanAdherenceOutcome outcome,
    required DateTime occurredAt,
    String note = '',
  }) => session.withOwner((ownerId) async {
    final original = await repository.readPlan(ownerId, planId);
    if (original == null) throw StateError('Health plan was not found');
    final revisions = await repository.listRevisions(ownerId, planId);
    final latest = revisions.isEmpty ? null : revisions.last;
    final instructions = latest?.effectiveInstructions ?? original.instructions;
    if (!instructions.any((value) => value.instructionId == instructionId)) {
      throw StateError('Meal instruction is not active in this plan');
    }
    final local = occurredAt.toLocal();
    final event = HealthPlanAdherenceEvent(
      eventId: ids.nextId(),
      ownerId: ownerId,
      planId: planId,
      instructionId: instructionId,
      planRevisionNumber: latest?.revisionNumber ?? 0,
      outcome: outcome,
      occurredAtUtc: local.toUtc(),
      timezoneOffsetMinutes: local.timeZoneOffset.inMinutes.clamp(-840, 840),
      recordedAtUtc: clock.nowUtc(),
      note: note.trim(),
    );
    await repository.saveAdherence(event);
    return event;
  });
}

class HealthPlanAdherenceCorrectionUnavailable implements Exception {
  const HealthPlanAdherenceCorrectionUnavailable();
}

class CorrectHealthPlanAdherence {
  const CorrectHealthPlanAdherence({
    required this.session,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;
  final HealthPlanIdGenerator ids;
  final HealthPlanClock clock;

  Future<HealthPlanAdherenceEvent> execute({
    required String originalEventId,
    required HealthPlanAdherenceOutcome outcome,
    String note = '',
  }) => session.withOwner((ownerId) async {
    final original = await repository.readActiveAdherence(
      ownerId,
      originalEventId,
    );
    if (original == null) {
      throw const HealthPlanAdherenceCorrectionUnavailable();
    }
    final correction = HealthPlanAdherenceEvent(
      eventId: ids.nextId(),
      ownerId: ownerId,
      planId: original.planId,
      instructionId: original.instructionId,
      planRevisionNumber: original.planRevisionNumber,
      outcome: outcome,
      occurredAtUtc: original.occurredAtUtc,
      timezoneOffsetMinutes: original.timezoneOffsetMinutes,
      recordedAtUtc: clock.nowUtc(),
      note: note.trim(),
      supersedesEventId: original.eventId,
      revision: original.revision + 1,
    );
    await repository.saveAdherence(correction);
    return correction;
  });
}
