import 'dart:async';

import 'package:get/get.dart';

import '../../domain/water_tracking.dart';
import '../../domain/hydration_preferences.dart';

class WaterTrackerController extends GetxController {
  factory WaterTrackerController({
    required WaterEventRepository repository,
    required LogWaterUseCase logWater,
    DateTime? initialDay,
    int? timezoneOffsetMinutes,
    HydrationPreferencesRepository? preferences,
    SaveHydrationPreferencesUseCase? savePreferences,
  }) => WaterTrackerController._(
    repository: repository,
    logWater: logWater,
    selectedDay: _calendarDay(initialDay ?? DateTime.now()).obs,
    timezoneOffsetMinutes:
        timezoneOffsetMinutes ?? DateTime.now().timeZoneOffset.inMinutes,
    preferences: preferences,
    savePreferences: savePreferences,
  );

  WaterTrackerController._({
    required this._repository,
    required this._logWater,
    required this.selectedDay,
    required this.timezoneOffsetMinutes,
    required this._preferences,
    required this._savePreferences,
  });

  final WaterEventRepository _repository;
  final LogWaterUseCase _logWater;
  final Rx<DateTime> selectedDay;
  final int timezoneOffsetMinutes;
  final HydrationPreferencesRepository? _preferences;
  final SaveHydrationPreferencesUseCase? _savePreferences;
  final summary = Rxn<DailyWaterSummary>();
  final hydrationPreferences = Rxn<HydrationPreferencesRecord>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<DailyWaterSummary>? _subscription;
  StreamSubscription<HydrationPreferencesRecord?>? _preferencesSubscription;
  bool _started = false;

  bool get isToday {
    final now = DateTime.now();
    final day = selectedDay.value;
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  void start() {
    if (_started) return;
    _started = true;
    _watchDay();
    _preferencesSubscription = _preferences?.watch().listen(
      (value) => hydrationPreferences.value = value,
      onError: (_) {
        errorMessage.value = 'Hydration settings are temporarily unavailable.';
      },
    );
  }

  void selectDay(DateTime value) {
    final normalized = _calendarDay(value);
    if (normalized == selectedDay.value) return;
    selectedDay.value = normalized;
    if (_started) _watchDay();
  }

  Future<WaterEvent?> quickAdd(int milliliters) async {
    if (!isToday || isSaving.value) return null;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      return await _logWater.execute(
        volumeMilliliters: milliliters,
        occurredAt: DateTime.now(),
      );
    } on Object {
      errorMessage.value = 'Water could not be saved. Please try again.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> saveTarget({
    required int? targetMilliliters,
    required HydrationTargetSource source,
    String restrictionNote = '',
    bool remindersEnabled = false,
    int reminderStartMinute = 480,
    int reminderEndMinute = 1200,
    int reminderIntervalMinutes = 120,
  }) async {
    final save = _savePreferences;
    if (save == null || isSaving.value) return false;
    isSaving.value = true;
    errorMessage.value = null;
    try {
      await save.execute(
        targetMilliliters: targetMilliliters,
        source: source,
        restrictionNote: restrictionNote,
        remindersEnabled: remindersEnabled,
        reminderStartMinute: reminderStartMinute,
        reminderEndMinute: reminderEndMinute,
        reminderIntervalMinutes: reminderIntervalMinutes,
      );
      return true;
    } on Object {
      errorMessage.value = 'Hydration settings could not be saved.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void _watchDay() {
    _subscription?.cancel();
    isLoading.value = true;
    errorMessage.value = null;
    _subscription = _repository
        .watchDay(
          calendarDay: selectedDay.value,
          timezoneOffsetMinutes: timezoneOffsetMinutes,
        )
        .listen(
          (value) {
            summary.value = value;
            isLoading.value = false;
          },
          onError: (_) {
            isLoading.value = false;
            errorMessage.value = 'Water history is temporarily unavailable.';
          },
        );
  }

  Future<void> stop() async {
    _started = false;
    await _subscription?.cancel();
    await _preferencesSubscription?.cancel();
    _subscription = null;
    _preferencesSubscription = null;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _preferencesSubscription?.cancel();
    super.onClose();
  }

  static DateTime _calendarDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
