import 'health_meal_plan.dart';
import 'health_plan_change.dart';

enum HealthPlanInstructionChangeType { add, replace, remove }

class HealthPlanInstructionChange {
  HealthPlanInstructionChange({
    required this.type,
    required this.instructionId,
    this.replacement,
  }) {
    if (instructionId.trim().isEmpty) {
      throw ArgumentError('Instruction ID is required');
    }
    if (type == HealthPlanInstructionChangeType.remove && replacement != null) {
      throw ArgumentError('Remove changes cannot include replacement content');
    }
    if (type != HealthPlanInstructionChangeType.remove && replacement == null) {
      throw ArgumentError('Add and replace changes require exact content');
    }
    if (replacement != null && replacement!.instructionId != instructionId) {
      throw ArgumentError('Replacement must preserve the instruction ID');
    }
  }

  final HealthPlanInstructionChangeType type;
  final String instructionId;
  final HealthPlanMealInstruction? replacement;
}

class HealthPlanRevision {
  HealthPlanRevision({
    required this.revisionId,
    required this.planId,
    required this.revisionNumber,
    required this.approvedProposalId,
    required Iterable<HealthPlanInstructionChange> changes,
    required Iterable<HealthPlanMealInstruction> effectiveInstructions,
    required this.createdAtUtc,
  }) : changes = List.unmodifiable(changes),
       effectiveInstructions = List.unmodifiable(effectiveInstructions) {
    if (revisionId.trim().isEmpty ||
        planId.trim().isEmpty ||
        approvedProposalId.trim().isEmpty ||
        revisionNumber < 1 ||
        this.changes.isEmpty ||
        this.effectiveInstructions.isEmpty ||
        !createdAtUtc.isUtc) {
      throw ArgumentError('Complete health-plan revision evidence is required');
    }
  }

  final String revisionId;
  final String planId;
  final int revisionNumber;
  final String approvedProposalId;
  final List<HealthPlanInstructionChange> changes;
  final List<HealthPlanMealInstruction> effectiveInstructions;
  final DateTime createdAtUtc;
}

class InvalidHealthPlanRevision implements Exception {
  const InvalidHealthPlanRevision(this.message);
  final String message;
}

class ApplyApprovedHealthPlanChange {
  const ApplyApprovedHealthPlanChange();

  HealthPlanRevision execute({
    required HealthMealPlan original,
    required HealthPlanChangeApproval approval,
    required Iterable<HealthPlanInstructionChange> changes,
    required String revisionId,
    required int revisionNumber,
    required DateTime nowUtc,
    HealthPlanRevision? currentRevision,
  }) {
    if (approval.proposal.planId != original.planId) {
      throw const InvalidHealthPlanRevision('Proposal targets another plan');
    }
    if (!nowUtc.isUtc) throw ArgumentError('Revision time must be UTC');
    if (currentRevision != null &&
        (currentRevision.planId != original.planId ||
            revisionNumber != currentRevision.revisionNumber + 1)) {
      throw const InvalidHealthPlanRevision('Revision sequence is invalid');
    }
    if (currentRevision == null && revisionNumber != 1) {
      throw const InvalidHealthPlanRevision(
        'First revision must be number one',
      );
    }
    final exactChanges = List<HealthPlanInstructionChange>.unmodifiable(
      changes,
    );
    if (exactChanges.isEmpty) {
      throw const InvalidHealthPlanRevision(
        'At least one exact change is required',
      );
    }
    final working = <String, HealthPlanMealInstruction>{
      for (final instruction
          in currentRevision?.effectiveInstructions ?? original.instructions)
        instruction.instructionId: instruction,
    };
    final touched = <String>{};
    for (final change in exactChanges) {
      if (!touched.add(change.instructionId)) {
        throw const InvalidHealthPlanRevision(
          'One proposal cannot change an instruction more than once',
        );
      }
      switch (change.type) {
        case HealthPlanInstructionChangeType.add:
          if (working.containsKey(change.instructionId)) {
            throw const InvalidHealthPlanRevision(
              'Added instruction already exists',
            );
          }
          working[change.instructionId] = change.replacement!;
        case HealthPlanInstructionChangeType.replace:
          if (!working.containsKey(change.instructionId)) {
            throw const InvalidHealthPlanRevision(
              'Replaced instruction is missing',
            );
          }
          working[change.instructionId] = change.replacement!;
        case HealthPlanInstructionChangeType.remove:
          if (working.remove(change.instructionId) == null) {
            throw const InvalidHealthPlanRevision(
              'Removed instruction is missing',
            );
          }
      }
    }
    if (working.isEmpty) {
      throw const InvalidHealthPlanRevision(
        'A plan must retain an instruction',
      );
    }
    return HealthPlanRevision(
      revisionId: revisionId,
      planId: original.planId,
      revisionNumber: revisionNumber,
      approvedProposalId: approval.proposal.proposalId,
      changes: exactChanges,
      effectiveInstructions: working.values,
      createdAtUtc: nowUtc,
    );
  }
}
