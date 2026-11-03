import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/health_plans/data/local_change_health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_capture.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_adherence.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_reminder.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_text_import.dart';
import 'package:sehat_coach/features/health_plans/presentation/controllers/health_plan_controller.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';

void main() {
  test('manual entry saves original and refreshes visible list', () async {
    final controller = _fixture();
    _completeDraft(controller);
    final saved = await controller.save();

    expect(saved?.captureMethod, HealthPlanCaptureMethod.manualEntry);
    expect(controller.plans.single.originalText, 'Original fixture text');
    expect(controller.title.value, isEmpty);
    expect(controller.hasUnsavedDraft, isFalse);
    expect(controller.message.value, contains('preserved'));
  });

  test('pasted document gets deterministic digest', () async {
    final controller = _fixture();
    _completeDraft(controller);
    controller.captureMethod.value = HealthPlanCaptureMethod.importedDocument;
    final saved = await controller.save();

    expect(saved?.originalDocumentDigest, startsWith('sha256:'));
    expect(
      saved?.originalDocumentDigest,
      healthPlanDocumentDigest('Original fixture text'),
    );
  });

  test('clinician checkbox records unverified user report only', () async {
    final controller = _fixture();
    _completeDraft(controller);
    controller.userReportsClinicianProvided.value = true;
    final saved = await controller.save();

    expect(
      saved?.authorship,
      HealthPlanAuthorship.userReportedClinicianProvided,
    );
    expect(saved?.isClinicianVerified, isFalse);
  });

  test('incomplete draft performs no write', () async {
    final controller = _fixture();
    controller.title.value = 'Only a title';
    expect(await controller.save(), isNull);
    expect(controller.plans, isEmpty);
    expect(controller.errorMessage.value, contains('Complete'));
    expect(controller.hasUnsavedDraft, isTrue);
  });

  test('meal check-in appears without changing saved plan', () async {
    final controller = _fixture();
    _completeDraft(controller);
    final plan = (await controller.save())!;

    expect(
      await controller.checkIn(
        plan: plan,
        instruction: plan.instructions.single,
        outcome: HealthPlanAdherenceOutcome.completed,
        note: '  Felt good  ',
      ),
      isTrue,
    );

    final event = controller.adherenceByPlan[plan.planId]!.single;
    expect(event.note, 'Felt good');
    expect(plan.instructions.single.instructions, 'Fixture meal instruction');
    expect(controller.message.value, contains('privately'));
  });

  test(
    'correction replaces visible check-in and retains prior version',
    () async {
      final controller = _fixture();
      _completeDraft(controller);
      final plan = (await controller.save())!;
      await controller.checkIn(
        plan: plan,
        instruction: plan.instructions.single,
        outcome: HealthPlanAdherenceOutcome.skipped,
      );
      final original = controller.adherenceByPlan[plan.planId]!.single;

      expect(
        await controller.correctCheckIn(
          original: original,
          outcome: HealthPlanAdherenceOutcome.completed,
          note: 'Corrected note',
        ),
        isTrue,
      );

      final corrected = controller.adherenceByPlan[plan.planId]!.single;
      expect(corrected.outcome, HealthPlanAdherenceOutcome.completed);
      expect(corrected.supersedesEventId, original.eventId);
      expect(corrected.revision, 2);
      expect(controller.message.value, contains('earlier version'));
    },
  );

  test('report window accepts only supported user-selected ranges', () {
    final controller = _fixture();
    expect(controller.reportWindowDays('plan-1'), 7);
    controller.setReportWindow('plan-1', 30);
    expect(controller.reportWindowDays('plan-1'), 30);
    expect(
      () => controller.setReportWindow('plan-1', 365),
      throwsArgumentError,
    );
  });

  test('reminder preference is explicitly enabled and visible', () async {
    final controller = _fixture();
    _completeDraft(controller);
    final plan = (await controller.save())!;
    expect(
      await controller.saveReminder(
        plan: plan,
        enabled: true,
        localMinuteOfDay: 8 * 60,
        weekdays: const {1, 3, 5},
        timezoneName: 'Asia/Karachi',
      ),
      isTrue,
    );
    expect(controller.remindersByPlan[plan.planId]?.enabled, isTrue);
    expect(controller.message.value, contains('not active yet'));
  });

  test('selected text document fills a reviewable imported draft', () async {
    final controller = _fixture();
    expect(await controller.importTextDocument(), isTrue);
    expect(
      controller.captureMethod.value,
      HealthPlanCaptureMethod.importedDocument,
    );
    expect(controller.title.value, 'fixture-plan');
    expect(controller.originalText.value, 'Imported fixture guidance');
    expect(controller.plans, isEmpty);
    expect(controller.message.value, contains('Review'));
  });

  test('document selection cannot silently replace draft text', () async {
    final picker = _CountingDocumentPicker();
    final controller = _fixture(picker: picker);
    controller.originalText.value = 'Keep this draft';

    expect(await controller.importTextDocument(), isFalse);
    expect(picker.calls, 0);
    expect(controller.originalText.value, 'Keep this draft');
    expect(controller.errorMessage.value, contains('not replaced'));

    expect(await controller.importTextDocument(replaceExisting: true), isTrue);
    expect(picker.calls, 1);
    expect(controller.originalText.value, 'Replacement fixture guidance');
  });

  test('ancillary load failure does not hide the saved plan', () async {
    final store = MemoryLocalChangeStore();
    final repository = _FailingAncillaryRepository(store, 'owner-a');
    const session = _Session();
    await CreateHealthMealPlan(
      session: session,
      repository: repository,
    ).execute(_plan());
    final controller = _fixture(suppliedRepository: repository);

    await controller.load();

    expect(controller.plans.single.title, 'Fixture plan');
    expect(controller.adherenceByPlan['plan-1'], isEmpty);
    expect(controller.errorMessage.value, contains('Plans loaded'));
  });
}

HealthPlanController _fixture({
  HealthPlanRepository? suppliedRepository,
  HealthPlanDocumentPicker? picker,
}) {
  final repository =
      suppliedRepository ??
      LocalChangeHealthPlanRepository(MemoryLocalChangeStore(), 'owner-a');
  const session = _Session();
  final ids = _Ids();
  return HealthPlanController(
    ownerId: 'owner-a',
    planCreator: CreateHealthMealPlan(session: session, repository: repository),
    planLoader: ListHealthMealPlans(session: session, repository: repository),
    idSource: ids,
    timeSource: const _Clock(),
    adherenceLogger: LogHealthPlanAdherence(
      session: session,
      repository: repository,
      ids: ids,
      clock: const _Clock(),
    ),
    adherenceCorrector: CorrectHealthPlanAdherence(
      session: session,
      repository: repository,
      ids: ids,
      clock: const _Clock(),
    ),
    adherenceRepository: repository,
    reminderSaver: SaveHealthPlanReminderPreferences(
      session: session,
      repository: repository,
    ),
    documentPickerSource: picker ?? const _DocumentPicker(),
  );
}

class _FailingAncillaryRepository extends LocalChangeHealthPlanRepository {
  _FailingAncillaryRepository(super.store, super.ownerId);

  @override
  Future<List<HealthPlanAdherenceEvent>> listAdherence(
    String ownerId,
    String planId,
  ) => throw StateError('Synthetic ancillary failure');
}

HealthMealPlan _plan() => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Fixture plan',
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Original fixture text',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'meal-1',
      label: 'Breakfast',
      instructions: 'Fixture instruction',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);

void _completeDraft(HealthPlanController controller) {
  controller.title.value = 'Fixture plan';
  controller.originalText.value = 'Original fixture text';
  controller.mealLabel.value = 'Breakfast';
  controller.mealInstructions.value = 'Fixture meal instruction';
}

class _Session implements AuthenticatedOwnerSession {
  const _Session();
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _Ids implements HealthPlanIdGenerator {
  var _value = 0;
  @override
  String nextId() => 'plan-${++_value}';
}

class _Clock implements HealthPlanClock {
  const _Clock();
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 24);
}

class _DocumentPicker implements HealthPlanDocumentPicker {
  const _DocumentPicker();
  @override
  Future<ImportedHealthPlanText?> pickTextDocument() async =>
      const ImportedHealthPlanText(
        fileName: 'fixture-plan.txt',
        text: 'Imported fixture guidance',
      );
}

class _CountingDocumentPicker implements HealthPlanDocumentPicker {
  int calls = 0;

  @override
  Future<ImportedHealthPlanText?> pickTextDocument() async {
    calls++;
    return const ImportedHealthPlanText(
      fileName: 'replacement.txt',
      text: 'Replacement fixture guidance',
    );
  }
}
