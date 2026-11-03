import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_preferences.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_schedule.dart';
import 'package:sehat_coach/features/fasting/presentation/controllers/fasting_settings_controller.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test('eligible user saves explicit Pakistan-local window', () async {
    final repository = _Repository();
    final controller = _controller(OnboardingState(), repository);
    await controller.load();
    controller.setEnabled(true);
    controller.selectedDate.value = DateTime(2026, 10, 23);
    controller.setStartTime(5, 15);
    controller.setEndTime(18, 5);
    controller.suhoorReminderEnabled.value = true;
    controller.iftarReminderEnabled.value = true;

    final saved = await controller.save();
    final window = saved!.schedule!.windows.single;
    expect(window.startsAtUtc, DateTime.utc(2026, 10, 23, 0, 15));
    expect(window.endsAtUtc, DateTime.utc(2026, 10, 23, 13, 5));
    expect(window.source, FastingTimeSource.userEntered);
    expect(saved.schedule?.suhoorReminderEnabled, isTrue);
    expect(controller.hasUnsavedChanges, isFalse);
  });

  test('restricted profile cannot enable or persist a schedule', () async {
    final repository = _Repository();
    final controller = _controller(
      OnboardingState(conditions: [HealthCondition.diabetes]),
      repository,
    );

    controller.setEnabled(true);
    expect(controller.enabled.value, isFalse);
    expect(controller.errorMessage.value, contains('clinician'));
    expect(repository.saved, isEmpty);
  });

  test('load restores stored window and reminder choices', () async {
    final repository = _Repository()..current = _record();
    final controller = _controller(OnboardingState(), repository);
    await controller.load();

    expect(controller.enabled.value, isTrue);
    expect(controller.startMinute.value, 5 * 60);
    expect(controller.endMinute.value, 18 * 60);
    expect(controller.iftarReminderEnabled.value, isTrue);
    expect(controller.hasUnsavedChanges, isFalse);
    controller.setEndTime(18, 30);
    expect(controller.hasUnsavedChanges, isTrue);
  });

  test(
    'disabled hidden schedule values do not create a false dirty state',
    () async {
      final repository = _Repository();
      final controller = _controller(OnboardingState(), repository);
      await controller.load();

      controller.setStartTime(6, 30);
      controller.suhoorReminderEnabled.value = true;

      expect(controller.enabled.value, isFalse);
      expect(controller.hasUnsavedChanges, isFalse);
    },
  );
}

FastingSettingsController _controller(
  OnboardingState profile,
  _Repository repository,
) => FastingSettingsController(
  profile,
  repository,
  SaveFastingPreferencesUseCase(
    session: _Session(),
    repository: repository,
    clock: _Clock(),
  ),
);

class _Repository implements FastingPreferencesRepository {
  FastingPreferencesRecord? current;
  final saved = <FastingPreferencesRecord>[];

  @override
  Future<FastingPreferencesRecord?> read(String ownerId) async => current;

  @override
  Future<void> save(FastingPreferencesRecord preferences) async {
    saved.add(preferences);
    current = preferences;
  }
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

FastingPreferencesRecord _record() => FastingPreferencesRecord(
  ownerId: 'owner-a',
  enabled: true,
  schedule: FastingSchedule(
    type: FastingScheduleType.ramadan,
    windows: [
      FastingDayWindow(
        startsAtUtc: DateTime.utc(2026, 10, 23, 0),
        endsAtUtc: DateTime.utc(2026, 10, 23, 13),
        timezoneOffsetMinutes: 300,
        source: FastingTimeSource.userEntered,
      ),
    ],
    suhoorReminderEnabled: true,
    iftarReminderEnabled: true,
  ),
  revision: 1,
  updatedAtUtc: DateTime.utc(2026, 10, 23),
);
