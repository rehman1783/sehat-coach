import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/health_plans/data/local_change_health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_reminder.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_repository.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';

void main() {
  test('reminders are opt-in and require a selected day', () {
    expect(
      () => HealthPlanReminderPreferences(
        planId: 'plan-1',
        enabled: true,
        localMinuteOfDay: 480,
        weekdays: const [],
        timezoneName: 'Asia/Karachi',
        updatedAtUtc: DateTime.utc(2026, 10, 24),
      ),
      throwsArgumentError,
    );
    expect(
      HealthPlanReminderPreferences(
        planId: 'plan-1',
        enabled: false,
        localMinuteOfDay: 480,
        weekdays: const [],
        timezoneName: 'Asia/Karachi',
        updatedAtUtc: DateTime.utc(2026, 10, 24),
      ).enabled,
      isFalse,
    );
  });

  test('preferences update atomically and remain owner scoped', () async {
    final store = MemoryLocalChangeStore();
    final repository = LocalChangeHealthPlanRepository(store, 'owner-a');
    const session = _Session();
    await CreateHealthMealPlan(
      session: session,
      repository: repository,
    ).execute(_plan());
    final save = SaveHealthPlanReminderPreferences(
      session: session,
      repository: repository,
    );
    await save.execute(_preferences(DateTime.utc(2026, 10, 24, 10)));
    await save.execute(
      _preferences(DateTime.utc(2026, 10, 24, 11), enabled: false),
    );

    final restored = await repository.readReminderPreferences(
      'owner-a',
      'plan-1',
    );
    expect(restored?.enabled, isFalse);
    expect(restored?.weekdays, {1, 3, 5});
    expect(await store.pending('owner-a'), hasLength(3));
    expect(
      () => repository.readReminderPreferences('owner-b', 'plan-1'),
      throwsStateError,
    );
  });

  test('cannot save preferences for a missing plan', () async {
    final repository = LocalChangeHealthPlanRepository(
      MemoryLocalChangeStore(),
      'owner-a',
    );
    await expectLater(
      SaveHealthPlanReminderPreferences(
        session: const _Session(),
        repository: repository,
      ).execute(_preferences(DateTime.utc(2026, 10, 24, 10))),
      throwsStateError,
    );
  });
}

HealthPlanReminderPreferences _preferences(
  DateTime updatedAtUtc, {
  bool enabled = true,
}) => HealthPlanReminderPreferences(
  planId: 'plan-1',
  enabled: enabled,
  localMinuteOfDay: 480,
  weekdays: const {1, 3, 5},
  timezoneName: 'Asia/Karachi',
  updatedAtUtc: updatedAtUtc,
);

HealthMealPlan _plan() => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Synthetic plan',
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Synthetic original',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'meal-1',
      label: 'Breakfast',
      instructions: 'Synthetic instructions',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);

class _Session implements AuthenticatedOwnerSession {
  const _Session();
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}
