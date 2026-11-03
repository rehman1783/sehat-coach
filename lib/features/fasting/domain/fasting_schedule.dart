enum FastingScheduleType { ramadan, sunnah, intermittent }

enum FastingTimeSource {
  verifiedPrayerCalculation,
  userEntered,
  clinicianProvided,
}

class FastingDayWindow {
  FastingDayWindow({
    required this.startsAtUtc,
    required this.endsAtUtc,
    required this.timezoneOffsetMinutes,
    required this.source,
  }) {
    if (!startsAtUtc.isUtc || !endsAtUtc.isUtc) {
      throw ArgumentError('Fasting window times must be UTC');
    }
    if (!endsAtUtc.isAfter(startsAtUtc) ||
        endsAtUtc.difference(startsAtUtc) > const Duration(hours: 24)) {
      throw ArgumentError(
        'Fasting window must be positive and at most 24 hours',
      );
    }
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
  }

  final DateTime startsAtUtc;
  final DateTime endsAtUtc;
  final int timezoneOffsetMinutes;
  final FastingTimeSource source;

  bool contains(DateTime utc) =>
      !utc.isBefore(startsAtUtc) && utc.isBefore(endsAtUtc);
}

class FastingSchedule {
  FastingSchedule({
    required this.type,
    required Iterable<FastingDayWindow> windows,
    required this.suhoorReminderEnabled,
    required this.iftarReminderEnabled,
  }) : windows = List.unmodifiable(windows) {
    if (this.windows.isEmpty) throw ArgumentError('A schedule needs a window');
    final sorted = [...this.windows]
      ..sort((a, b) => a.startsAtUtc.compareTo(b.startsAtUtc));
    for (var index = 1; index < sorted.length; index++) {
      if (sorted[index].startsAtUtc.isBefore(sorted[index - 1].endsAtUtc)) {
        throw ArgumentError('Fasting windows cannot overlap');
      }
    }
  }

  final FastingScheduleType type;
  final List<FastingDayWindow> windows;
  final bool suhoorReminderEnabled;
  final bool iftarReminderEnabled;

  FastingDayWindow? activeWindow(DateTime nowUtc) {
    if (!nowUtc.isUtc) throw ArgumentError('Current time must be UTC');
    for (final window in windows) {
      if (window.contains(nowUtc)) return window;
    }
    return null;
  }
}

class FastingReminderDecision {
  const FastingReminderDecision({
    required this.suppressDaytimeFoodReminders,
    required this.allowSuhoorReminder,
    required this.allowIftarReminder,
  });

  final bool suppressDaytimeFoodReminders;
  final bool allowSuhoorReminder;
  final bool allowIftarReminder;
}

class FastingReminderPolicy {
  const FastingReminderPolicy();

  FastingReminderDecision decide({
    required FastingSchedule schedule,
    required DateTime nowUtc,
    required bool automaticPlanBlocked,
  }) {
    if (automaticPlanBlocked) {
      return const FastingReminderDecision(
        suppressDaytimeFoodReminders: false,
        allowSuhoorReminder: false,
        allowIftarReminder: false,
      );
    }
    final active = schedule.activeWindow(nowUtc) != null;
    return FastingReminderDecision(
      suppressDaytimeFoodReminders: active,
      allowSuhoorReminder: schedule.suhoorReminderEnabled,
      allowIftarReminder: schedule.iftarReminderEnabled,
    );
  }
}
