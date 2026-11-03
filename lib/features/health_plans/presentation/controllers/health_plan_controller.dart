import 'package:get/get.dart';

import '../../domain/health_meal_plan.dart';
import '../../domain/health_plan_adherence.dart';
import '../../domain/health_plan_adherence_export.dart';
import '../../domain/health_plan_capture.dart';
import '../../domain/health_plan_repository.dart';
import '../../domain/health_plan_reminder.dart';
import '../../domain/health_plan_text_import.dart';

class HealthPlanController extends GetxController {
  HealthPlanController({
    required this.ownerId,
    required CreateHealthMealPlan planCreator,
    required ListHealthMealPlans planLoader,
    required HealthPlanIdGenerator idSource,
    required HealthPlanClock timeSource,
    required LogHealthPlanAdherence adherenceLogger,
    required CorrectHealthPlanAdherence adherenceCorrector,
    required HealthPlanRepository adherenceRepository,
    required SaveHealthPlanReminderPreferences reminderSaver,
    required HealthPlanDocumentPicker documentPickerSource,
  }) : _createPlan = planCreator,
       _listPlans = planLoader,
       _ids = idSource,
       _clock = timeSource,
       _logAdherence = adherenceLogger,
       _correctAdherence = adherenceCorrector,
       _repository = adherenceRepository,
       _saveReminder = reminderSaver,
       _documentPicker = documentPickerSource;

  final String ownerId;
  final CreateHealthMealPlan _createPlan;
  final ListHealthMealPlans _listPlans;
  final HealthPlanIdGenerator _ids;
  final HealthPlanClock _clock;
  final LogHealthPlanAdherence _logAdherence;
  final CorrectHealthPlanAdherence _correctAdherence;
  final HealthPlanRepository _repository;
  final SaveHealthPlanReminderPreferences _saveReminder;
  final HealthPlanDocumentPicker _documentPicker;

  final plans = <HealthMealPlan>[].obs;
  final captureMethod = HealthPlanCaptureMethod.manualEntry.obs;
  final title = ''.obs;
  final originalText = ''.obs;
  final mealLabel = ''.obs;
  final mealInstructions = ''.obs;
  final scheduleLabel = ''.obs;
  final userReportsClinicianProvided = false.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();
  final message = RxnString();
  final draftGeneration = 0.obs;
  final adherenceByPlan = <String, List<HealthPlanAdherenceEvent>>{}.obs;
  final reportWindowDaysByPlan = <String, int>{}.obs;
  final checkingInPlanId = RxnString();
  final remindersByPlan = <String, HealthPlanReminderPreferences>{}.obs;
  final savingReminderPlanId = RxnString();
  final isImportingDocument = false.obs;

  bool get hasUnsavedDraft =>
      title.value.trim().isNotEmpty ||
      originalText.value.trim().isNotEmpty ||
      mealLabel.value.trim().isNotEmpty ||
      mealInstructions.value.trim().isNotEmpty ||
      scheduleLabel.value.trim().isNotEmpty ||
      userReportsClinicianProvided.value;

  HealthPlanAdherenceSummary adherenceSummary(
    String planId, {
    DateTime? nowUtc,
  }) {
    final end = nowUtc ?? DateTime.now().toUtc();
    final days = reportWindowDaysByPlan[planId] ?? 7;
    return HealthPlanAdherenceSummary(
      events: adherenceByPlan[planId] ?? const [],
      fromUtc: end.subtract(Duration(days: days)),
      toUtc: end.add(const Duration(microseconds: 1)),
    );
  }

  int reportWindowDays(String planId) => reportWindowDaysByPlan[planId] ?? 7;

  void setReportWindow(String planId, int days) {
    if (!const {7, 30, 90}.contains(days)) {
      throw ArgumentError.value(days, 'days');
    }
    reportWindowDaysByPlan[planId] = days;
  }

  HealthPlanAdherenceExport buildExport(
    HealthMealPlan plan, {
    bool includePrivateNotes = false,
  }) => const BuildHealthPlanAdherenceExport().execute(
    plan: plan,
    summary: adherenceSummary(plan.planId),
    generatedAtUtc: _clock.nowUtc(),
    includePrivateNotes: includePrivateNotes,
  );

  Future<void> load() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      plans.assignAll(await _listPlans.execute());
    } on Object {
      errorMessage.value =
          'Saved plans are unavailable. Existing records were not changed.';
      isLoading.value = false;
      return;
    }
    var relatedDataUnavailable = false;
    for (final plan in plans) {
      try {
        adherenceByPlan[plan.planId] = await _repository.listAdherence(
          ownerId,
          plan.planId,
        );
      } on Object {
        relatedDataUnavailable = true;
        adherenceByPlan[plan.planId] = const [];
      }
      try {
        final reminder = await _repository.readReminderPreferences(
          ownerId,
          plan.planId,
        );
        if (reminder != null) remindersByPlan[plan.planId] = reminder;
      } on Object {
        relatedDataUnavailable = true;
      }
    }
    if (relatedDataUnavailable) {
      errorMessage.value = 'Plans loaded, but some check-ins or reminder settings are temporarily unavailable.';
    }
    isLoading.value = false;
  }

  Future<bool> saveReminder({
    required HealthMealPlan plan,
    required bool enabled,
    required int localMinuteOfDay,
    required Set<int> weekdays,
    required String timezoneName,
  }) async {
    if (savingReminderPlanId.value != null) return false;
    savingReminderPlanId.value = plan.planId;
    errorMessage.value = null;
    message.value = null;
    try {
      final preferences = HealthPlanReminderPreferences(
        planId: plan.planId,
        enabled: enabled,
        localMinuteOfDay: localMinuteOfDay,
        weekdays: weekdays,
        timezoneName: timezoneName,
        updatedAtUtc: _clock.nowUtc(),
      );
      await _saveReminder.execute(preferences);
      remindersByPlan[plan.planId] = preferences;
      message.value = enabled
          ? 'Reminder preference saved. Device delivery is not active yet.'
          : 'Reminder preference turned off.';
      return true;
    } on ArgumentError {
      errorMessage.value =
          'Choose at least one day and a valid local reminder time.';
      return false;
    } on Object {
      errorMessage.value = 'Reminder settings could not be saved. Existing settings remain unchanged.';
      return false;
    } finally {
      savingReminderPlanId.value = null;
    }
  }

  Future<bool> importTextDocument({bool replaceExisting = false}) async {
    if (isImportingDocument.value) return false;
    if (originalText.value.trim().isNotEmpty && !replaceExisting) {
      errorMessage.value = 'The current draft was not replaced. Confirm replacement before selecting another file.';
      return false;
    }
    isImportingDocument.value = true;
    errorMessage.value = null;
    message.value = null;
    try {
      final imported = await _documentPicker.pickTextDocument();
      if (imported == null) return false;
      captureMethod.value = HealthPlanCaptureMethod.importedDocument;
      originalText.value = imported.text;
      if (title.value.trim().isEmpty) {
        title.value = imported.fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
      }
      draftGeneration.value++;
      message.value =
          'Text imported locally. Review it before saving the original plan.';
      return true;
    } on InvalidHealthPlanDocument catch (error) {
      errorMessage.value = error.message;
      return false;
    } on Object {
      errorMessage.value =
          'The document could not be read. No plan was created.';
      return false;
    } finally {
      isImportingDocument.value = false;
    }
  }

  Future<bool> checkIn({
    required HealthMealPlan plan,
    required HealthPlanMealInstruction instruction,
    required HealthPlanAdherenceOutcome outcome,
    String note = '',
  }) async {
    if (checkingInPlanId.value != null) return false;
    checkingInPlanId.value = plan.planId;
    errorMessage.value = null;
    message.value = null;
    try {
      final event = await _logAdherence.execute(
        planId: plan.planId,
        instructionId: instruction.instructionId,
        outcome: outcome,
        occurredAt: DateTime.now(),
        note: note,
      );
      adherenceByPlan[plan.planId] = [
        event,
        ...adherenceByPlan[plan.planId] ?? const [],
      ];
      message.value = 'Check-in saved privately.';
      return true;
    } on ArgumentError {
      errorMessage.value = 'Keep your optional note under 500 characters.';
      return false;
    } on Object {
      errorMessage.value =
          'The check-in could not be saved. Your plan was not changed.';
      return false;
    } finally {
      checkingInPlanId.value = null;
    }
  }

  Future<bool> correctCheckIn({
    required HealthPlanAdherenceEvent original,
    required HealthPlanAdherenceOutcome outcome,
    String note = '',
  }) async {
    if (checkingInPlanId.value != null) return false;
    checkingInPlanId.value = original.planId;
    errorMessage.value = null;
    message.value = null;
    try {
      final correction = await _correctAdherence.execute(
        originalEventId: original.eventId,
        outcome: outcome,
        note: note,
      );
      final current = adherenceByPlan[original.planId] ?? const [];
      adherenceByPlan[original.planId] = [
        for (final event in current)
          if (event.eventId == original.eventId) correction else event,
      ];
      message.value = 'Check-in corrected. The earlier version is retained.';
      return true;
    } on HealthPlanAdherenceCorrectionUnavailable {
      errorMessage.value =
          'This check-in is no longer current. Reload and try again.';
      return false;
    } on ArgumentError {
      errorMessage.value = 'Keep your optional note under 500 characters.';
      return false;
    } on Object {
      errorMessage.value = 'The correction could not be saved. Existing records were not changed.';
      return false;
    } finally {
      checkingInPlanId.value = null;
    }
  }

  Future<HealthMealPlan?> save() async {
    if (isSaving.value) return null;
    isSaving.value = true;
    errorMessage.value = null;
    message.value = null;
    try {
      final text = originalText.value.trim();
      final planId = _ids.nextId();
      final plan = HealthMealPlan(
        planId: planId,
        ownerId: ownerId,
        title: title.value.trim(),
        captureMethod: captureMethod.value,
        authorship: userReportsClinicianProvided.value
            ? HealthPlanAuthorship.userReportedClinicianProvided
            : HealthPlanAuthorship.userCreated,
        originalText: text,
        originalDocumentDigest:
            captureMethod.value == HealthPlanCaptureMethod.importedDocument
            ? healthPlanDocumentDigest(text)
            : null,
        instructions: [
          HealthPlanMealInstruction(
            instructionId: '$planId-meal-1',
            label: mealLabel.value.trim(),
            instructions: mealInstructions.value.trim(),
            scheduleLabel: scheduleLabel.value.trim().isEmpty
                ? null
                : scheduleLabel.value.trim(),
          ),
        ],
        capturedAtUtc: _clock.nowUtc(),
      );
      await _createPlan.execute(plan);
      plans.insert(0, plan);
      _clearDraft();
      message.value = 'Plan saved. The original instructions are preserved.';
      return plan;
    } on ArgumentError {
      errorMessage.value =
          'Complete the title, original text and meal instruction.';
      return null;
    } on Object {
      errorMessage.value =
          'The plan could not be saved. Existing records remain unchanged.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  void _clearDraft() {
    title.value = '';
    originalText.value = '';
    mealLabel.value = '';
    mealInstructions.value = '';
    scheduleLabel.value = '';
    userReportsClinicianProvided.value = false;
    draftGeneration.value++;
  }
}
