import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/fasting/data/local_change_fasting_preferences_repository.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_preferences.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_schedule.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';

void main() {
  test('schedule is stored with one atomic sync operation', () async {
    final store = MemoryLocalChangeStore();
    final repository = LocalChangeFastingPreferencesRepository(
      store,
      'owner-a',
    );
    final useCase = SaveFastingPreferencesUseCase(
      session: _Session(),
      repository: repository,
      clock: _Clock(),
    );

    final saved = await useCase.execute(
      profile: OnboardingState(),
      enabled: true,
      schedule: _schedule(),
    );
    final restored = await repository.read('owner-a');
    final pending = await store.pending('owner-a');

    expect(saved.revision, 1);
    expect(restored?.enabled, isTrue);
    expect(restored?.schedule?.type, FastingScheduleType.ramadan);
    expect(
      restored?.schedule?.windows.single.startsAtUtc,
      DateTime.utc(2026, 10, 23, 5),
    );
    expect(pending.single.entityType, 'fasting_preferences');
    expect(pending.single.newRevision, 1);
  });

  test('successive saves advance revision and remain owner scoped', () async {
    final store = MemoryLocalChangeStore();
    final repository = LocalChangeFastingPreferencesRepository(
      store,
      'owner-a',
    );
    final useCase = SaveFastingPreferencesUseCase(
      session: _Session(),
      repository: repository,
      clock: _Clock(),
    );
    await useCase.execute(
      profile: OnboardingState(),
      enabled: true,
      schedule: _schedule(),
    );
    final disabled = await useCase.execute(
      profile: OnboardingState(),
      enabled: false,
    );

    expect(disabled.revision, 2);
    expect((await repository.read('owner-a'))?.enabled, isFalse);
    expect(() => repository.read('owner-b'), throwsStateError);
  });

  test('unsafe profile is rejected before persistence', () async {
    final store = MemoryLocalChangeStore();
    final repository = LocalChangeFastingPreferencesRepository(
      store,
      'owner-a',
    );
    final useCase = SaveFastingPreferencesUseCase(
      session: _Session(),
      repository: repository,
      clock: _Clock(),
    );

    await expectLater(
      useCase.execute(
        profile: OnboardingState(conditions: [HealthCondition.pregnancy]),
        enabled: true,
        schedule: _schedule(),
      ),
      throwsA(isA<UnsafeFastingActivation>()),
    );
    expect(await store.pending('owner-a'), isEmpty);
    expect(await repository.read('owner-a'), isNull);
  });
}

class _Session implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Clock implements FastingPreferencesClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 23);
}

FastingSchedule _schedule() => FastingSchedule(
  type: FastingScheduleType.ramadan,
  windows: [
    FastingDayWindow(
      startsAtUtc: DateTime.utc(2026, 10, 23, 5),
      endsAtUtc: DateTime.utc(2026, 10, 23, 18),
      timezoneOffsetMinutes: 300,
      source: FastingTimeSource.userEntered,
    ),
  ],
  suhoorReminderEnabled: true,
  iftarReminderEnabled: true,
);
