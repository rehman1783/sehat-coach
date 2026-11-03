import '../../account/domain/authenticated_owner_session.dart';
import 'health_meal_plan.dart';
import 'health_plan_adherence.dart';
import 'health_plan_change.dart';
import 'health_plan_revision.dart';
import 'health_plan_reminder.dart';

abstract interface class HealthPlanRepository {
  Future<List<HealthMealPlan>> listPlans(String ownerId);
  Future<HealthMealPlan?> readPlan(String ownerId, String planId);
  Future<void> createPlan(HealthMealPlan plan);
  Future<HealthPlanChangeApproval?> readApproval(
    String ownerId,
    String proposalId,
  );
  Future<void> saveApproval(String ownerId, HealthPlanChangeApproval approval);
  Future<List<HealthPlanRevision>> listRevisions(String ownerId, String planId);
  Future<void> saveRevision(String ownerId, HealthPlanRevision revision);
  Future<List<HealthPlanAdherenceEvent>> listAdherence(
    String ownerId,
    String planId,
  );
  Future<void> saveAdherence(HealthPlanAdherenceEvent event);
  Future<HealthPlanAdherenceEvent?> readActiveAdherence(
    String ownerId,
    String eventId,
  );
  Future<List<HealthPlanAdherenceEvent>> listAdherenceAudit(
    String ownerId,
    String planId,
  );
  Future<HealthPlanReminderPreferences?> readReminderPreferences(
    String ownerId,
    String planId,
  );
  Future<void> saveReminderPreferences(
    String ownerId,
    HealthPlanReminderPreferences preferences,
  );
}

class SaveHealthPlanRevision {
  const SaveHealthPlanRevision({
    required this.session,
    required this.repository,
  });

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;

  Future<HealthPlanRevision> execute(
    HealthPlanRevision revision,
  ) => session.withOwner((ownerId) async {
    final original = await repository.readPlan(ownerId, revision.planId);
    if (original == null) {
      throw StateError('Original health plan was not found');
    }
    final approval = await repository.readApproval(
      ownerId,
      revision.approvedProposalId,
    );
    if (approval == null || approval.proposal.planId != revision.planId) {
      throw StateError('Approved proposal was not found for this plan');
    }
    final existing = await repository.listRevisions(ownerId, revision.planId);
    final expected = existing.isEmpty ? 1 : existing.last.revisionNumber + 1;
    if (revision.revisionNumber != expected) {
      throw StateError('Health plan revision sequence is stale');
    }
    await repository.saveRevision(ownerId, revision);
    return revision;
  });
}

class ListHealthMealPlans {
  const ListHealthMealPlans({required this.session, required this.repository});

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;

  Future<List<HealthMealPlan>> execute() =>
      session.withOwner(repository.listPlans);
}

class CreateHealthMealPlan {
  const CreateHealthMealPlan({required this.session, required this.repository});

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;

  Future<HealthMealPlan> execute(HealthMealPlan plan) =>
      session.withOwner((ownerId) async {
        if (plan.ownerId != ownerId) {
          throw StateError('Health plan belongs to another account');
        }
        await repository.createPlan(plan);
        return plan;
      });
}

class SaveApprovedHealthPlanChange {
  const SaveApprovedHealthPlanChange({
    required this.session,
    required this.repository,
  });

  final AuthenticatedOwnerSession session;
  final HealthPlanRepository repository;

  Future<HealthPlanChangeApproval> execute(
    HealthPlanChangeApproval approval,
  ) => session.withOwner((ownerId) async {
    final plan = await repository.readPlan(ownerId, approval.proposal.planId);
    if (plan == null) throw StateError('Original health plan was not found');
    await repository.saveApproval(ownerId, approval);
    return approval;
  });
}
