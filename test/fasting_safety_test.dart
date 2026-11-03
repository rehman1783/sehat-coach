import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_safety.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_schedule.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  const safety = FastingSafetyPolicy();

  test('pregnancy and breastfeeding are never encouraged automatically', () {
    for (final condition in [
      HealthCondition.pregnancy,
      HealthCondition.breastfeeding,
    ]) {
      final result = safety.assess(OnboardingState(conditions: [condition]));
      expect(result.eligibility, FastingEligibility.doNotEncourage);
      expect(result.blockAutomaticPlan, isTrue);
      expect(result.message, contains('clinical guidance'));
    }
  });

  test('diabetes, blood pressure and clinician plans require guidance', () {
    for (final condition in [
      HealthCondition.diabetes,
      HealthCondition.bp,
      HealthCondition.clinicianPlan,
    ]) {
      final result = safety.assess(OnboardingState(conditions: [condition]));
      expect(result.eligibility, FastingEligibility.clinicianGuidanceRequired);
      expect(result.blockAutomaticPlan, isTrue);
    }
  });

  test('active eligible fast suppresses food reminders only in its window', () {
    final schedule = _schedule();
    const policy = FastingReminderPolicy();
    final active = policy.decide(
      schedule: schedule,
      nowUtc: DateTime.utc(2026, 10, 23, 12),
      automaticPlanBlocked: false,
    );
    final inactive = policy.decide(
      schedule: schedule,
      nowUtc: DateTime.utc(2026, 10, 23, 19),
      automaticPlanBlocked: false,
    );

    expect(active.suppressDaytimeFoodReminders, isTrue);
    expect(active.allowSuhoorReminder, isTrue);
    expect(active.allowIftarReminder, isTrue);
    expect(inactive.suppressDaytimeFoodReminders, isFalse);
  });

  test(
    'blocked profile disables fasting-specific reminders and suppression',
    () {
      final decision = const FastingReminderPolicy().decide(
        schedule: _schedule(),
        nowUtc: DateTime.utc(2026, 10, 23, 12),
        automaticPlanBlocked: true,
      );
      expect(decision.suppressDaytimeFoodReminders, isFalse);
      expect(decision.allowSuhoorReminder, isFalse);
      expect(decision.allowIftarReminder, isFalse);
    },
  );

  test('invalid or overlapping windows are rejected', () {
    expect(
      () => FastingDayWindow(
        startsAtUtc: DateTime.utc(2026, 10, 23, 18),
        endsAtUtc: DateTime.utc(2026, 10, 23, 5),
        timezoneOffsetMinutes: 300,
        source: FastingTimeSource.userEntered,
      ),
      throwsArgumentError,
    );
    final first = _window();
    final overlap = FastingDayWindow(
      startsAtUtc: DateTime.utc(2026, 10, 23, 12),
      endsAtUtc: DateTime.utc(2026, 10, 23, 20),
      timezoneOffsetMinutes: 300,
      source: FastingTimeSource.userEntered,
    );
    expect(
      () => FastingSchedule(
        type: FastingScheduleType.ramadan,
        windows: [first, overlap],
        suhoorReminderEnabled: true,
        iftarReminderEnabled: true,
      ),
      throwsArgumentError,
    );
  });
}

FastingSchedule _schedule() => FastingSchedule(
  type: FastingScheduleType.ramadan,
  windows: [_window()],
  suhoorReminderEnabled: true,
  iftarReminderEnabled: true,
);

FastingDayWindow _window() => FastingDayWindow(
  startsAtUtc: DateTime.utc(2026, 10, 23, 5),
  endsAtUtc: DateTime.utc(2026, 10, 23, 18),
  timezoneOffsetMinutes: 300,
  source: FastingTimeSource.userEntered,
);
