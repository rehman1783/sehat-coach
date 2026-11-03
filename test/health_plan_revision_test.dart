import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_change.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_revision.dart';

void main() {
  test(
    'approved exact replacement creates revision without changing original',
    () {
      final original = _plan();
      final revision = const ApplyApprovedHealthPlanChange().execute(
        original: original,
        approval: _approval(),
        changes: [
          HealthPlanInstructionChange(
            type: HealthPlanInstructionChangeType.replace,
            instructionId: 'meal-1',
            replacement: HealthPlanMealInstruction(
              instructionId: 'meal-1',
              label: 'Breakfast',
              instructions: 'Approved replacement',
            ),
          ),
        ],
        revisionId: 'revision-1',
        revisionNumber: 1,
        nowUtc: DateTime.utc(2026, 10, 24),
      );

      expect(
        revision.effectiveInstructions.single.instructions,
        'Approved replacement',
      );
      expect(original.instructions.single.instructions, 'Original instruction');
    },
  );

  test('missing targets, duplicate touches and empty resulting plan fail', () {
    final original = _plan();
    final apply = const ApplyApprovedHealthPlanChange();
    HealthPlanInstructionChange remove(String id) =>
        HealthPlanInstructionChange(
          type: HealthPlanInstructionChangeType.remove,
          instructionId: id,
        );

    expect(
      () => apply.execute(
        original: original,
        approval: _approval(),
        changes: [remove('missing')],
        revisionId: 'r1',
        revisionNumber: 1,
        nowUtc: DateTime.utc(2026, 10, 24),
      ),
      throwsA(isA<InvalidHealthPlanRevision>()),
    );
    expect(
      () => apply.execute(
        original: original,
        approval: _approval(),
        changes: [remove('meal-1'), remove('meal-1')],
        revisionId: 'r1',
        revisionNumber: 1,
        nowUtc: DateTime.utc(2026, 10, 24),
      ),
      throwsA(isA<InvalidHealthPlanRevision>()),
    );
    expect(
      () => apply.execute(
        original: original,
        approval: _approval(),
        changes: [remove('meal-1')],
        revisionId: 'r1',
        revisionNumber: 1,
        nowUtc: DateTime.utc(2026, 10, 24),
      ),
      throwsA(isA<InvalidHealthPlanRevision>()),
    );
  });

  test('revision sequence must advance exactly once', () {
    final original = _plan(twoInstructions: true);
    final first = const ApplyApprovedHealthPlanChange().execute(
      original: original,
      approval: _approval(),
      changes: [
        HealthPlanInstructionChange(
          type: HealthPlanInstructionChangeType.remove,
          instructionId: 'meal-2',
        ),
      ],
      revisionId: 'r1',
      revisionNumber: 1,
      nowUtc: DateTime.utc(2026, 10, 24),
    );
    expect(
      () => const ApplyApprovedHealthPlanChange().execute(
        original: original,
        approval: _approval('proposal-2'),
        changes: [
          HealthPlanInstructionChange(
            type: HealthPlanInstructionChangeType.replace,
            instructionId: 'meal-1',
            replacement: HealthPlanMealInstruction(
              instructionId: 'meal-1',
              label: 'Breakfast',
              instructions: 'Second revision',
            ),
          ),
        ],
        revisionId: 'r3',
        revisionNumber: 3,
        nowUtc: DateTime.utc(2026, 10, 24),
        currentRevision: first,
      ),
      throwsA(isA<InvalidHealthPlanRevision>()),
    );
  });
}

HealthMealPlan _plan({bool twoInstructions = false}) => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Plan',
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Original text',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'meal-1',
      label: 'Breakfast',
      instructions: 'Original instruction',
    ),
    if (twoInstructions)
      HealthPlanMealInstruction(
        instructionId: 'meal-2',
        label: 'Lunch',
        instructions: 'Original lunch',
      ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);

HealthPlanChangeApproval _approval([String proposalId = 'proposal-1']) =>
    const ApproveHealthPlanChange().execute(
      proposal: HealthPlanChangeProposal(
        proposalId: proposalId,
        planId: 'plan-1',
        origin: HealthPlanProposalOrigin.user,
        summary: 'Exact change',
        rationale: 'User requested change',
        clinicallySignificant: false,
        createdAtUtc: DateTime.utc(2026, 10, 24),
      ),
      userExplicitlyApproved: true,
      nowUtc: DateTime.utc(2026, 10, 24),
    );
