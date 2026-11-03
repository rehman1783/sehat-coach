import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_change.dart';

void main() {
  test('imported plan preserves original text and document digest', () {
    final plan = _plan(
      captureMethod: HealthPlanCaptureMethod.importedDocument,
      digest: 'sha256:synthetic-fixture',
    );

    expect(plan.originalText, 'Original synthetic instructions');
    expect(plan.originalDocumentDigest, 'sha256:synthetic-fixture');
    expect(plan.instructions, hasLength(1));
  });

  test('user-reported clinician plan is not called verified', () {
    final plan = _plan(
      authorship: HealthPlanAuthorship.userReportedClinicianProvided,
    );
    expect(plan.isClinicianVerified, isFalse);
    expect(
      const HealthPlanPrecedencePolicy().decide(plan).message,
      contains('not been verified'),
    );
  });

  test('active entered plan prevents automatic target override', () {
    final decision = const HealthPlanPrecedencePolicy().decide(_plan());
    expect(decision.automaticNutritionTargetsAllowed, isFalse);
  });

  test('AI proposal requires explicit user approval', () {
    final proposal = _proposal(clinicallySignificant: false);
    expect(
      () => const ApproveHealthPlanChange().execute(
        proposal: proposal,
        userExplicitlyApproved: false,
        nowUtc: DateTime.utc(2026, 10, 24),
      ),
      throwsA(isA<HealthPlanChangeNotApproved>()),
    );
  });

  test('clinically significant proposal also requires review evidence', () {
    final proposal = _proposal(clinicallySignificant: true);
    expect(
      () => const ApproveHealthPlanChange().execute(
        proposal: proposal,
        userExplicitlyApproved: true,
        nowUtc: DateTime.utc(2026, 10, 24),
      ),
      throwsA(isA<HealthPlanChangeNotApproved>()),
    );

    final approval = const ApproveHealthPlanChange().execute(
      proposal: proposal,
      userExplicitlyApproved: true,
      nowUtc: DateTime.utc(2026, 10, 24),
      clinicianReviewState: ClinicianReviewState.approved,
      clinicianReviewerId: 'reviewer-fixture',
      clinicianReviewedAtUtc: DateTime.utc(2026, 10, 24),
    );
    expect(approval.clinicianReviewState, ClinicianReviewState.approved);
  });
}

HealthMealPlan _plan({
  HealthPlanCaptureMethod captureMethod = HealthPlanCaptureMethod.manualEntry,
  HealthPlanAuthorship authorship = HealthPlanAuthorship.userCreated,
  String? digest,
}) => HealthMealPlan(
  planId: 'plan-1',
  ownerId: 'owner-a',
  title: 'Synthetic plan',
  captureMethod: captureMethod,
  authorship: authorship,
  originalText: 'Original synthetic instructions',
  originalDocumentDigest: digest,
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'instruction-1',
      label: 'Breakfast',
      instructions: 'Synthetic fixture meal',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);

HealthPlanChangeProposal _proposal({required bool clinicallySignificant}) =>
    HealthPlanChangeProposal(
      proposalId: 'proposal-1',
      planId: 'plan-1',
      origin: HealthPlanProposalOrigin.ai,
      summary: 'Replace one synthetic meal',
      rationale: 'Synthetic test rationale',
      clinicallySignificant: clinicallySignificant,
      createdAtUtc: DateTime.utc(2026, 10, 24),
    );
