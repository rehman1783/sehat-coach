import '../../account/domain/authenticated_owner_session.dart';

class WeightEvent {
  WeightEvent({
    required this.id,
    required this.ownerId,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.createdAtUtc,
    required this.weightKilograms,
    this.note = '',
    this.supersedesEventId,
    this.revision = 1,
  }) {
    if (id.trim().isEmpty || ownerId.trim().isEmpty) {
      throw ArgumentError('Weight event and owner IDs are required');
    }
    if (!occurredAtUtc.isUtc || !createdAtUtc.isUtc) {
      throw ArgumentError('Weight timestamps must be UTC');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (!weightKilograms.isFinite ||
        weightKilograms < 20 ||
        weightKilograms > 500) {
      throw ArgumentError.value(weightKilograms, 'weightKilograms');
    }
    if (note.length > 500) throw ArgumentError('Weight note is too long');
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (supersedesEventId != null &&
        (supersedesEventId!.trim().isEmpty || supersedesEventId == id)) {
      throw ArgumentError('Invalid superseded weight event');
    }
  }

  final String id;
  final String ownerId;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime createdAtUtc;
  final double weightKilograms;
  final String note;
  final String? supersedesEventId;
  final int revision;
}

abstract interface class WeightRepository {
  Future<void> save(WeightEvent event);
  Stream<List<WeightEvent>> watchRecent({int limit = 30});
}

abstract interface class ActiveWeightEventReader {
  Future<WeightEvent?> readActive({
    required String ownerId,
    required String eventId,
  });
}

abstract interface class WeightEventIdGenerator {
  String nextId();
}

abstract interface class WeightClock {
  DateTime nowUtc();
}

class LogWeightUseCase {
  const LogWeightUseCase({
    required this.session,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final WeightRepository repository;
  final WeightEventIdGenerator ids;
  final WeightClock clock;

  Future<WeightEvent> execute({
    required double weightKilograms,
    required DateTime occurredAt,
    String note = '',
  }) => session.withOwner((ownerId) async {
    final local = occurredAt.toLocal();
    final event = WeightEvent(
      id: ids.nextId(),
      ownerId: ownerId,
      occurredAtUtc: local.toUtc(),
      timezoneOffsetMinutes: local.timeZoneOffset.inMinutes.clamp(-840, 840),
      createdAtUtc: clock.nowUtc(),
      weightKilograms: weightKilograms,
      note: note.trim(),
    );
    await repository.save(event);
    return event;
  });
}

class WeightCorrectionUnavailable implements Exception {
  const WeightCorrectionUnavailable();
}

class CorrectWeightUseCase {
  const CorrectWeightUseCase({
    required this.session,
    required this.activeEvents,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final ActiveWeightEventReader activeEvents;
  final WeightRepository repository;
  final WeightEventIdGenerator ids;
  final WeightClock clock;

  Future<WeightEvent> execute({
    required String originalEventId,
    required double weightKilograms,
    required String note,
  }) => session.withOwner((ownerId) async {
    final original = await activeEvents.readActive(
      ownerId: ownerId,
      eventId: originalEventId,
    );
    if (original == null) throw const WeightCorrectionUnavailable();
    final correction = WeightEvent(
      id: ids.nextId(),
      ownerId: ownerId,
      occurredAtUtc: original.occurredAtUtc,
      timezoneOffsetMinutes: original.timezoneOffsetMinutes,
      createdAtUtc: clock.nowUtc(),
      weightKilograms: weightKilograms,
      note: note.trim(),
      supersedesEventId: original.id,
      revision: original.revision + 1,
    );
    await repository.save(correction);
    return correction;
  });
}

class WeightProgress {
  const WeightProgress({
    required this.startingKilograms,
    required this.targetKilograms,
    required this.latestKilograms,
  });

  final double startingKilograms;
  final double targetKilograms;
  final double? latestKilograms;

  double get currentKilograms => latestKilograms ?? startingKilograms;
  double get changeFromStart => currentKilograms - startingKilograms;

  double? get directionalFraction {
    final journey = targetKilograms - startingKilograms;
    if (journey == 0) return null;
    return ((currentKilograms - startingKilograms) / journey).clamp(0.0, 1.0);
  }
}
