import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/health_plans/data/local_change_health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_meal_plan.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_change.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_repository.dart';
import 'package:sehat_coach/features/health_plans/domain/health_plan_revision.dart';
import 'package:sehat_coach/features/sync/data/memory_local_change_store.dart';

void main() {
  test('original plan and outbox operation commit together', () async {
    final fixture = _Fixture();
    await fixture.create.execute(_plan());

    final restored = await fixture.repository.readPlan('owner-a', 'plan-1');
    final pending = await fixture.store.pending('owner-a');
    expect(restored?.originalText, 'Immutable synthetic original');
    expect(pending.single.entityType, 'health_meal_plan_original');
    expect(pending.single.newRevision, 1);
    expect(
      (await fixture.repository.listPlans('owner-a')).single.planId,
      'plan-1',
    );
  });

  test('an existing original cannot be replaced', () async {
    final fixture = _Fixture();
    await fixture.create.execute(_plan());
    await expectLater(
      fixture.create.execute(_plan(title: 'Changed title')),
      throwsStateError,
    );
    expect(
      (await fixture.repository.readPlan('owner-a', 'plan-1'))?.title,
      'Synthetic plan',
    );
  });

  test('cross-owner creation and reads are rejected', () async {
    final fixture = _Fixture();
    await expectLater(
      fixture.create.execute(_plan(ownerId: 'owner-b')),
      throwsStateError,
    );
    expect(
      () => fixture.repository.readPlan('owner-b', 'plan-1'),
      throwsStateError,
    );
  });

  test('approved proposal is separate and leaves original unchanged', () async {
    final fixture = _Fixture();
    await fixture.create.execute(_plan());
    final approval = const ApproveHealthPlanChange().execute(
      proposal: _proposal(),
      userExplicitlyApproved: true,
      nowUtc: DateTime.utc(2026, 10, 24),
    );
    await fixture.saveApproval.execute(approval);

    final restored = await fixture.repository.readApproval(
      'owner-a',
      'proposal-1',
    );
    expect(restored?.proposal.summary, 'Synthetic non-clinical change');
    expect(
      (await fixture.repository.readPlan('owner-a', 'plan-1'))?.originalText,
      'Immutable synthetic original',
    );
    expect(await fixture.store.pending('owner-a'), hasLength(2));
  });

  test('approval cannot be stored without its original plan', () async {
    final fixture = _Fixture();
    final approval = const ApproveHealthPlanChange().execute(
      proposal: _proposal(),
      userExplicitlyApproved: true,
      nowUtc: DateTime.utc(2026, 10, 24),
    );
    await expectLater(fixture.saveApproval.execute(approval), throwsStateError);
    expect(await fixture.store.pending('owner-a'), isEmpty);
  });

  test('approved revision persists separately in strict sequence', () async {
    final fixture = _Fixture();
    final original = _plan();
    await fixture.create.execute(original);
    final approval = const ApproveHealthPlanChange().execute(
      proposal: _proposal(),
      userExplicitlyApproved: true,
      nowUtc: DateTime.utc(2026, 10, 24),
    );
    await fixture.saveApproval.execute(approval);
    final revision = const ApplyApprovedHealthPlanChange().execute(
      original: original,
      approval: approval,
      changes: [
        HealthPlanInstructionChange(
          type: HealthPlanInstructionChangeType.replace,
          instructionId: 'meal-1',
          replacement: HealthPlanMealInstruction(
            instructionId: 'meal-1',
            label: 'Breakfast',
            instructions: 'Approved revised fixture meal',
          ),
        ),
      ],
      revisionId: 'revision-1',
      revisionNumber: 1,
      nowUtc: DateTime.utc(2026, 10, 24),
    );
    await SaveHealthPlanRevision(
      session: fixture.session,
      repository: fixture.repository,
    ).execute(revision);

    final revisions = await fixture.repository.listRevisions(
      'owner-a',
      'plan-1',
    );
    expect(
      revisions.single.effectiveInstructions.single.instructions,
      contains('revised'),
    );
    expect(
      (await fixture.repository.readPlan(
        'owner-a',
        'plan-1',
      ))?.instructions.single.instructions,
      'Synthetic fixture meal',
    );
    expect(await fixture.store.pending('owner-a'), hasLength(3));
  });
}

class _Fixture {
  _Fixture() : store = MemoryLocalChangeStore(), session = const _Session() {
    repository = LocalChangeHealthPlanRepository(store, 'owner-a');
    create = CreateHealthMealPlan(session: session, repository: repository);
    saveApproval = SaveApprovedHealthPlanChange(
      session: session,
      repository: repository,
    );
  }

  final MemoryLocalChangeStore store;
  final _Session session;
  late final LocalChangeHealthPlanRepository repository;
  late final CreateHealthMealPlan create;
  late final SaveApprovedHealthPlanChange saveApproval;
}

class _Session implements AuthenticatedOwnerSession {
  const _Session();
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

HealthMealPlan _plan({
  String ownerId = 'owner-a',
  String title = 'Synthetic plan',
}) => HealthMealPlan(
  planId: 'plan-1',
  ownerId: ownerId,
  title: title,
  captureMethod: HealthPlanCaptureMethod.manualEntry,
  authorship: HealthPlanAuthorship.userCreated,
  originalText: 'Immutable synthetic original',
  instructions: [
    HealthPlanMealInstruction(
      instructionId: 'meal-1',
      label: 'Breakfast',
      instructions: 'Synthetic fixture meal',
    ),
  ],
  capturedAtUtc: DateTime.utc(2026, 10, 24),
);

HealthPlanChangeProposal _proposal() => HealthPlanChangeProposal(
  proposalId: 'proposal-1',
  planId: 'plan-1',
  origin: HealthPlanProposalOrigin.ai,
  summary: 'Synthetic non-clinical change',
  rationale: 'Synthetic test rationale',
  clinicallySignificant: false,
  createdAtUtc: DateTime.utc(2026, 10, 24),
);
