import 'dart:async';

import 'package:get/get.dart';

import '../../../meals/domain/meal_history.dart';

class DailyDashboardController extends GetxController {
  factory DailyDashboardController({
    required MealHistoryRepository history,
    DateTime? initialDay,
    int? timezoneOffsetMinutes,
  }) => DailyDashboardController._(
    history: history,
    selectedDay: _calendarDay(initialDay ?? DateTime.now()).obs,
    timezoneOffsetMinutes:
        timezoneOffsetMinutes ?? DateTime.now().timeZoneOffset.inMinutes,
  );

  DailyDashboardController._({
    required this._history,
    required this.selectedDay,
    required this.timezoneOffsetMinutes,
  });

  final MealHistoryRepository _history;
  final Rx<DateTime> selectedDay;
  final int timezoneOffsetMinutes;
  final summary = Rxn<DailyMealSummary>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  StreamSubscription<DailyMealSummary>? _subscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _watchSelectedDay();
  }

  void previousDay() =>
      selectDay(selectedDay.value.subtract(const Duration(days: 1)));

  void nextDay() {
    final next = selectedDay.value.add(const Duration(days: 1));
    if (next.isAfter(_calendarDay(DateTime.now()))) return;
    selectDay(next);
  }

  void selectDay(DateTime value) {
    final day = _calendarDay(value);
    if (day == selectedDay.value) return;
    selectedDay.value = day;
    if (_started) _watchSelectedDay();
  }

  void reload() {
    if (_started) _watchSelectedDay();
  }

  void _watchSelectedDay() {
    _subscription?.cancel();
    isLoading.value = true;
    errorMessage.value = null;
    _subscription = _history
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
            errorMessage.value =
                'Today’s meal summary is unavailable. Please try again.';
          },
        );
  }

  Future<void> stop() async {
    _started = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  static DateTime _calendarDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
