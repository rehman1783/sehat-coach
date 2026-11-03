import 'dart:async';

import 'package:get/get.dart';

import '../../../onboarding/domain/models/onboarding_state.dart';
import '../../domain/weight_tracking.dart';

class WeightTrackerController extends GetxController {
  factory WeightTrackerController({
    required WeightRepository repository,
    required LogWeightUseCase logWeight,
    required CorrectWeightUseCase correctWeight,
    required double startingKilograms,
    required double targetKilograms,
    required UnitType unit,
  }) => WeightTrackerController._(
    repository,
    logWeight,
    correctWeight,
    startingKilograms,
    targetKilograms,
    unit,
  );

  WeightTrackerController._(
    this._repository,
    this._logWeight,
    this._correctWeight,
    this.startingKilograms,
    this.targetKilograms,
    this.unit,
  );

  final WeightRepository _repository;
  final LogWeightUseCase _logWeight;
  final CorrectWeightUseCase _correctWeight;
  final double startingKilograms;
  final double targetKilograms;
  final UnitType unit;

  final events = <WeightEvent>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  StreamSubscription<List<WeightEvent>>? _subscription;
  bool _started = false;

  WeightProgress get progress => WeightProgress(
    startingKilograms: startingKilograms,
    targetKilograms: targetKilograms,
    latestKilograms: events.firstOrNull?.weightKilograms,
  );

  bool get usesImperial => unit == UnitType.imperial;

  double displayWeight(double kilograms) =>
      usesImperial ? kilograms * 2.2046226218 : kilograms;

  double kilogramsFromDisplay(double value) =>
      usesImperial ? value / 2.2046226218 : value;

  String get unitLabel => usesImperial ? 'lb' : 'kg';

  void start() {
    if (_started) return;
    _started = true;
    isLoading.value = true;
    _subscription = _repository.watchRecent().listen(
      (value) {
        events.assignAll(value);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        errorMessage.value = 'Weight history is temporarily unavailable.';
      },
    );
  }

  Future<WeightEvent?> log({
    required double displayValue,
    String note = '',
  }) async {
    if (!displayValue.isFinite || displayValue <= 0 || isSaving.value) {
      errorMessage.value = 'Enter a valid weight.';
      return null;
    }
    isSaving.value = true;
    errorMessage.value = null;
    try {
      return await _logWeight.execute(
        weightKilograms: kilogramsFromDisplay(displayValue),
        occurredAt: DateTime.now(),
        note: note,
      );
    } on ArgumentError {
      errorMessage.value = 'Enter a weight between 20 and 500 kg.';
      return null;
    } on Object {
      errorMessage.value = 'Weight could not be saved. Please try again.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<WeightEvent?> correct({
    required WeightEvent original,
    required double displayValue,
    String note = '',
  }) async {
    if (!displayValue.isFinite || displayValue <= 0 || isSaving.value) {
      errorMessage.value = 'Enter a valid weight.';
      return null;
    }
    isSaving.value = true;
    errorMessage.value = null;
    try {
      return await _correctWeight.execute(
        originalEventId: original.id,
        weightKilograms: kilogramsFromDisplay(displayValue),
        note: note,
      );
    } on WeightCorrectionUnavailable {
      errorMessage.value =
          'This check-in was already updated. Refresh history.';
      return null;
    } on ArgumentError {
      errorMessage.value = 'Enter a weight between 20 and 500 kg.';
      return null;
    } on Object {
      errorMessage.value = 'Correction could not be saved. Try again.';
      return null;
    } finally {
      isSaving.value = false;
    }
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
}
