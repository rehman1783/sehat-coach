import '../../account/domain/authenticated_owner_session.dart';
import 'health_plan_repository.dart';

class HealthPlanReminderPreferences {
  HealthPlanReminderPreferences({
    required this.planId,
    required this.enabled,
    required this.localMinuteOfDay,
    required Iterable<int> weekdays,
    required this.timezoneName,
    required this.updatedAtUtc,
  }) : weekdays = Set.unmodifiable(weekdays) {
    if (planId.trim().isEmpty || timezoneName.trim().isEmpty) {
      throw ArgumentError('Plan and timezone are required');
    }
    if (!updatedAtUtc.isUtc) {
      throw ArgumentError('Reminder update time must be UTC');
    }
    if (localMinuteOfDay < 0 || localMinuteOfDay > 1439) {
      throw ArgumentError.value(localMinuteOfDay, 'localMinuteOfDay');
    }
    if (this.weekdays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError('Reminder weekdays must use ISO values 1 to 7');
    }
    if (enabled && this.weekdays.isEmpty) {
      throw ArgumentError('Enabled reminders require at least one day');
    }
  }

  final String planId;
  final bool enabled;
  final int localMinuteOfDay;
  final Set<int> weekdays;
  final String timezoneName;
  final DateTime updatedAtUtc;
}

class SaveHealthPlanReminderPreferences {
  const SaveHealthPlanReminderPreferences({
    required this.session,
    required this.repository,
  });

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;

  Future<HealthPlanReminderPreferences> execute(
    HealthPlanReminderPreferences preferences,
  ) => session.withOwner((ownerId) async {
    if (await repository.readPlan(ownerId, preferences.planId) == null) {
      throw StateError('Health plan was not found');
    }
    await repository.saveReminderPreferences(ownerId, preferences);
    return preferences;
  });
}
