import '../../account/domain/authenticated_owner_session.dart';

class WaterEvent {
  WaterEvent({
    required this.id,
    required this.ownerId,
    required this.occurredAtUtc,
    required this.timezoneOffsetMinutes,
    required this.createdAtUtc,
    required this.volumeMilliliters,
    this.supersedesEventId,
    this.revision = 1,
  }) {
    if (id.trim().isEmpty || ownerId.trim().isEmpty) {
      throw ArgumentError('Water event and owner IDs are required');
    }
    if (!occurredAtUtc.isUtc || !createdAtUtc.isUtc) {
      throw ArgumentError('Water timestamps must be UTC');
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (volumeMilliliters < 1 || volumeMilliliters > 10000) {
      throw ArgumentError.value(volumeMilliliters, 'volumeMilliliters');
    }
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (supersedesEventId != null) {
      if (supersedesEventId!.trim().isEmpty || supersedesEventId == id) {
        throw ArgumentError('Invalid superseded water event');
      }
    }
  }

  final String id;
  final String ownerId;
  final DateTime occurredAtUtc;
  final int timezoneOffsetMinutes;
  final DateTime createdAtUtc;
  final int volumeMilliliters;
  final String? supersedesEventId;
  final int revision;
}

class DailyWaterSummary {
  const DailyWaterSummary({
    required this.calendarDay,
    required this.timezoneOffsetMinutes,
    required this.events,
  });

  final DateTime calendarDay;
  final int timezoneOffsetMinutes;
  final List<WaterEvent> events;

  int get totalMilliliters =>
      events.fold(0, (total, event) => total + event.volumeMilliliters);
}

abstract interface class WaterEventRepository {
  Future<void> save(WaterEvent event);
  Stream<DailyWaterSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  });
}

abstract interface class WaterEventIdGenerator {
  String nextId();
}

abstract interface class WaterClock {
  DateTime nowUtc();
}

class LogWaterUseCase {
  factory LogWaterUseCase({
    required AuthenticatedOwnerSession session,
    required WaterEventRepository repository,
    required WaterEventIdGenerator ids,
    required WaterClock clock,
  }) => LogWaterUseCase._(
    session: session,
    repository: repository,
    ids: ids,
    clock: clock,
  );

  const LogWaterUseCase._({
    required this._session,
    required this._repository,
    required this._ids,
    required this._clock,
  });

  final AuthenticatedOwnerSession _session;
  final WaterEventRepository _repository;
  final WaterEventIdGenerator _ids;
  final WaterClock _clock;

  Future<WaterEvent> execute({
    required int volumeMilliliters,
    required DateTime occurredAt,
  }) => _session.withOwner((ownerId) async {
    final local = occurredAt.toLocal();
    final event = WaterEvent(
      id: _ids.nextId(),
      ownerId: ownerId,
      occurredAtUtc: local.toUtc(),
      timezoneOffsetMinutes: local.timeZoneOffset.inMinutes.clamp(-840, 840),
      createdAtUtc: _clock.nowUtc(),
      volumeMilliliters: volumeMilliliters,
    );
    await _repository.save(event);
    return event;
  });
}
