import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/water/domain/water_tracking.dart';
import 'package:sehat_coach/features/water/domain/hydration_preferences.dart';
import 'package:sehat_coach/features/water/presentation/controllers/water_tracker_controller.dart';

void main() {
  test('starts reactive day and quick-add saves for stable owner', () async {
    final repository = _WaterRepositoryFake();
    final controller = _controller(repository);
    controller.start();
    repository.emit([]);
    await Future<void>.delayed(Duration.zero);

    final event = await controller.quickAdd(250);
    expect(event?.ownerId, 'owner-a');
    expect(event?.volumeMilliliters, 250);
    expect(repository.saved.single, same(event));
    expect(controller.isSaving.value, isFalse);
    await controller.stop();
  });

  test('past day is read-only and does not create an event', () async {
    final repository = _WaterRepositoryFake();
    final controller = _controller(repository);
    controller.selectDay(DateTime.now().subtract(const Duration(days: 1)));

    expect(controller.isToday, isFalse);
    expect(await controller.quickAdd(500), isNull);
    expect(repository.saved, isEmpty);
  });

  test('save failure clears busy state and exposes retry message', () async {
    final repository = _WaterRepositoryFake()
      ..failure = StateError('disk full');
    final controller = _controller(repository);

    expect(await controller.quickAdd(250), isNull);
    expect(controller.isSaving.value, isFalse);
    expect(controller.errorMessage.value, contains('could not be saved'));
  });

  test('selected dashboard day resubscribes water history', () async {
    final repository = _WaterRepositoryFake();
    final controller = _controller(repository);
    controller.start();
    controller.selectDay(DateTime.now().subtract(const Duration(days: 2)));

    expect(repository.watchedDays, hasLength(2));
    await controller.stop();
  });

  test(
    'saves explicit personal target and reacts to preference stream',
    () async {
      final water = _WaterRepositoryFake();
      final preferences = _PreferencesRepositoryFake();
      final controller = _controller(water, preferences: preferences);
      controller.start();

      expect(
        await controller.saveTarget(
          targetMilliliters: 1750,
          source: HydrationTargetSource.user,
          remindersEnabled: true,
          reminderStartMinute: 480,
          reminderEndMinute: 1200,
          reminderIntervalMinutes: 120,
        ),
        isTrue,
      );
      final saved = preferences.saved.single;
      expect(saved.ownerId, 'owner-a');
      expect(saved.targetMilliliters, 1750);
      expect(saved.remindersEnabled, isTrue);
      expect(saved.reminderStartMinute, 480);
      preferences.emit(saved);
      await Future<void>.delayed(Duration.zero);
      expect(controller.hydrationPreferences.value, same(saved));
      await controller.stop();
    },
  );
}

WaterTrackerController _controller(
  _WaterRepositoryFake repository, {
  _PreferencesRepositoryFake? preferences,
}) => WaterTrackerController(
  repository: repository,
  logWater: LogWaterUseCase(
    session: _SessionFake(),
    repository: repository,
    ids: _IdsFake(),
    clock: _ClockFake(),
  ),
  initialDay: DateTime.now(),
  timezoneOffsetMinutes: 300,
  preferences: preferences,
  savePreferences: preferences == null
      ? null
      : SaveHydrationPreferencesUseCase(
          session: _SessionFake(),
          repository: preferences,
          clock: _PreferencesClockFake(),
        ),
);

class _PreferencesRepositoryFake implements HydrationPreferencesRepository {
  final stream = StreamController<HydrationPreferencesRecord?>.broadcast();
  final saved = <HydrationPreferencesRecord>[];

  void emit(HydrationPreferencesRecord? value) => stream.add(value);

  @override
  Future<int> readRevision() async => saved.length;

  @override
  Future<void> save(HydrationPreferencesRecord preferences) async {
    saved.add(preferences);
  }

  @override
  Stream<HydrationPreferencesRecord?> watch() => stream.stream;
}

class _WaterRepositoryFake implements WaterEventRepository {
  final stream = StreamController<DailyWaterSummary>.broadcast();
  final saved = <WaterEvent>[];
  final watchedDays = <DateTime>[];
  Object? failure;

  void emit(List<WaterEvent> events) {
    stream.add(
      DailyWaterSummary(
        calendarDay: DateTime.now(),
        timezoneOffsetMinutes: 300,
        events: events,
      ),
    );
  }

  @override
  Future<void> save(WaterEvent event) async {
    if (failure case final error?) throw error;
    saved.add(event);
  }

  @override
  Stream<DailyWaterSummary> watchDay({
    required DateTime calendarDay,
    required int timezoneOffsetMinutes,
  }) {
    watchedDays.add(calendarDay);
    return stream.stream;
  }
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements WaterEventIdGenerator {
  @override
  String nextId() => 'water-1';
}

class _ClockFake implements WaterClock {
  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class _PreferencesClockFake implements HydrationPreferencesClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 23);
}
