import 'package:get/get.dart';

import '../../../onboarding/domain/models/onboarding_state.dart';
import '../../domain/fasting_preferences.dart';
import '../../domain/fasting_safety.dart';
import '../../domain/fasting_schedule.dart';

class FastingSettingsController extends GetxController {
  FastingSettingsController(
    this.profile,
    this._repository,
    this._savePreferences, {
    this.timezoneOffsetMinutes = 300,
  }) : assessment = const FastingSafetyPolicy().assess(profile).obs;

  final OnboardingState profile;
  final FastingPreferencesRepository _repository;
  final SaveFastingPreferencesUseCase _savePreferences;
  final int timezoneOffsetMinutes;
  final Rx<FastingSafetyAssessment> assessment;

  final enabled = false.obs;
  final scheduleType = FastingScheduleType.ramadan.obs;
  final selectedDate = DateTime.now().obs;
  final startMinute = (5 * 60).obs;
  final endMinute = (18 * 60).obs;
  final suhoorReminderEnabled = false.obs;
  final iftarReminderEnabled = false.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final savedRecord = Rxn<FastingPreferencesRecord>();
  _FastingSettingsDraft? _savedDraft;

  bool get hasUnsavedChanges {
    final busy = isLoading.value || isSaving.value;
    final currentDraft = _captureDraft();
    final savedDraft = _savedDraft;
    return !busy && savedDraft != null && currentDraft != savedDraft;
  }

  Future<void> load() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final record = await _repository.read(await _ownerId());
      if (record == null) return;
      savedRecord.value = record;
      enabled.value = record.enabled;
      final schedule = record.schedule;
      if (schedule == null) return;
      scheduleType.value = schedule.type;
      suhoorReminderEnabled.value = schedule.suhoorReminderEnabled;
      iftarReminderEnabled.value = schedule.iftarReminderEnabled;
      final window = schedule.windows.first;
      final localStart = window.startsAtUtc.add(
        Duration(minutes: window.timezoneOffsetMinutes),
      );
      final localEnd = window.endsAtUtc.add(
        Duration(minutes: window.timezoneOffsetMinutes),
      );
      selectedDate.value = DateTime(
        localStart.year,
        localStart.month,
        localStart.day,
      );
      startMinute.value = localStart.hour * 60 + localStart.minute;
      endMinute.value = localEnd.hour * 60 + localEnd.minute;
    } on Object {
      errorMessage.value = 'Fasting settings are unavailable. Existing records were not changed.';
    } finally {
      _savedDraft = _captureDraft();
      isLoading.value = false;
    }
  }

  void setEnabled(bool value) {
    if (value && assessment.value.blockAutomaticPlan) {
      enabled.value = false;
      errorMessage.value = assessment.value.message;
      return;
    }
    enabled.value = value;
    errorMessage.value = null;
  }

  void setStartTime(int hour, int minute) {
    if (!_validTime(hour, minute)) return;
    startMinute.value = hour * 60 + minute;
  }

  void setEndTime(int hour, int minute) {
    if (!_validTime(hour, minute)) return;
    endMinute.value = hour * 60 + minute;
  }

  Future<FastingPreferencesRecord?> save() async {
    if (isSaving.value) return null;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      final record = await _savePreferences.execute(
        profile: profile,
        enabled: enabled.value,
        schedule: enabled.value ? _buildSchedule() : null,
      );
      savedRecord.value = record;
      _savedDraft = _captureDraft();
      return record;
    } on UnsafeFastingActivation catch (error) {
      enabled.value = false;
      errorMessage.value = error.assessment.message;
      return null;
    } on Object {
      errorMessage.value = 'Fasting settings could not be saved. Your previous settings are unchanged.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  FastingSchedule _buildSchedule() {
    final date = selectedDate.value;
    final startLocal = DateTime(
      date.year,
      date.month,
      date.day,
      startMinute.value ~/ 60,
      startMinute.value % 60,
    );
    var endLocal = DateTime(
      date.year,
      date.month,
      date.day,
      endMinute.value ~/ 60,
      endMinute.value % 60,
    );
    if (!endLocal.isAfter(startLocal)) {
      endLocal = endLocal.add(const Duration(days: 1));
    }
    DateTime toUtc(DateTime local) => DateTime.utc(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    ).subtract(Duration(minutes: timezoneOffsetMinutes));
    return FastingSchedule(
      type: scheduleType.value,
      windows: [
        FastingDayWindow(
          startsAtUtc: toUtc(startLocal),
          endsAtUtc: toUtc(endLocal),
          timezoneOffsetMinutes: timezoneOffsetMinutes,
          source: FastingTimeSource.userEntered,
        ),
      ],
      suhoorReminderEnabled: suhoorReminderEnabled.value,
      iftarReminderEnabled: iftarReminderEnabled.value,
    );
  }

  Future<String> _ownerId() =>
      _savePreferences.session.withOwner((ownerId) async => ownerId);

  bool _validTime(int hour, int minute) =>
      hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;

  _FastingSettingsDraft _captureDraft() => _FastingSettingsDraft(
    enabled: enabled.value,
    scheduleType: enabled.value ? scheduleType.value : null,
    selectedDate: enabled.value
        ? DateTime(
            selectedDate.value.year,
            selectedDate.value.month,
            selectedDate.value.day,
          )
        : null,
    startMinute: enabled.value ? startMinute.value : null,
    endMinute: enabled.value ? endMinute.value : null,
    suhoorReminderEnabled: enabled.value ? suhoorReminderEnabled.value : null,
    iftarReminderEnabled: enabled.value ? iftarReminderEnabled.value : null,
  );
}

class _FastingSettingsDraft {
  const _FastingSettingsDraft({
    required this.enabled,
    required this.scheduleType,
    required this.selectedDate,
    required this.startMinute,
    required this.endMinute,
    required this.suhoorReminderEnabled,
    required this.iftarReminderEnabled,
  });

  final bool enabled;
  final FastingScheduleType? scheduleType;
  final DateTime? selectedDate;
  final int? startMinute;
  final int? endMinute;
  final bool? suhoorReminderEnabled;
  final bool? iftarReminderEnabled;

  @override
  bool operator ==(Object other) =>
      other is _FastingSettingsDraft &&
      enabled == other.enabled &&
      scheduleType == other.scheduleType &&
      selectedDate == other.selectedDate &&
      startMinute == other.startMinute &&
      endMinute == other.endMinute &&
      suhoorReminderEnabled == other.suhoorReminderEnabled &&
      iftarReminderEnabled == other.iftarReminderEnabled;

  @override
  int get hashCode => Object.hash(
    enabled,
    scheduleType,
    selectedDate,
    startMinute,
    endMinute,
    suhoorReminderEnabled,
    iftarReminderEnabled,
  );
}
