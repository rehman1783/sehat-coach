import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/weight/domain/weight_tracking.dart';
import 'package:sehat_coach/features/weight/presentation/controllers/weight_tracker_controller.dart';

void main() {
  test('exposes neutral progress and converts imperial input', () async {
    final repository = _RepositoryFake();
    final controller = WeightTrackerController(
      repository: repository,
      logWeight: _useCase(repository),
      correctWeight: _correctUseCase(repository),
      startingKilograms: 80,
      targetKilograms: 70,
      unit: UnitType.imperial,
    );
    controller.start();
    repository.emit([]);
    expect(controller.progress.directionalFraction, 0);

    final saved = await controller.log(displayValue: 165.3467);
    expect(saved?.weightKilograms, closeTo(75, 0.01));
    repository.emit([saved!]);
    await Future<void>.delayed(Duration.zero);
    expect(controller.progress.directionalFraction, closeTo(0.5, 0.01));
    expect(controller.unitLabel, 'lb');
    await controller.stop();
  });

  test('keeps history and reports repository failure', () async {
    final repository = _RepositoryFake()..failure = StateError('disk');
    final controller = WeightTrackerController(
      repository: repository,
      logWeight: _useCase(repository),
      correctWeight: _correctUseCase(repository),
      startingKilograms: 70,
      targetKilograms: 70,
      unit: UnitType.metric,
    );
    controller.start();
    repository.emit([_event()]);
    await Future<void>.delayed(Duration.zero);

    expect(await controller.log(displayValue: 71), isNull);
    expect(controller.events, hasLength(1));
    expect(controller.errorMessage.value, contains('could not be saved'));
    expect(controller.progress.directionalFraction, isNull);
    await controller.stop();
  });

  test('correction preserves occurrence and increments revision', () async {
    final repository = _RepositoryFake()..active = _event();
    final controller = WeightTrackerController(
      repository: repository,
      logWeight: _useCase(repository),
      correctWeight: _correctUseCase(repository),
      startingKilograms: 70,
      targetKilograms: 65,
      unit: UnitType.metric,
    );

    final corrected = await controller.correct(
      original: repository.active!,
      displayValue: 69.5,
      note: 'corrected',
    );

    expect(corrected?.supersedesEventId, 'weight-old');
    expect(corrected?.revision, 2);
    expect(corrected?.occurredAtUtc, repository.active!.occurredAtUtc);
    expect(corrected?.weightKilograms, 69.5);
  });
}

LogWeightUseCase _useCase(_RepositoryFake repository) => LogWeightUseCase(
  session: _SessionFake(),
  repository: repository,
  ids: _IdsFake(),
  clock: _ClockFake(),
);

CorrectWeightUseCase _correctUseCase(_RepositoryFake repository) =>
    CorrectWeightUseCase(
      session: _SessionFake(),
      activeEvents: repository,
      repository: repository,
      ids: _IdsFake(),
      clock: _ClockFake(),
    );

class _RepositoryFake implements WeightRepository, ActiveWeightEventReader {
  final stream = StreamController<List<WeightEvent>>.broadcast();
  Object? failure;
  WeightEvent? active;

  void emit(List<WeightEvent> events) => stream.add(events);

  @override
  Future<void> save(WeightEvent event) async {
    if (failure case final error?) throw error;
  }

  @override
  Stream<List<WeightEvent>> watchRecent({int limit = 30}) => stream.stream;

  @override
  Future<WeightEvent?> readActive({
    required String ownerId,
    required String eventId,
  }) async => active ?? _event();
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements WeightEventIdGenerator {
  @override
  String nextId() => 'weight-1';
}

class _ClockFake implements WeightClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 23);
}

WeightEvent _event() => WeightEvent(
  id: 'weight-old',
  ownerId: 'owner-a',
  occurredAtUtc: DateTime.utc(2026, 10, 22),
  timezoneOffsetMinutes: 300,
  createdAtUtc: DateTime.utc(2026, 10, 22),
  weightKilograms: 70,
);
