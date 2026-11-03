enum HealthPlanProposalOrigin { user, clinician, ai }

enum ClinicianReviewState { notRequired, pending, approved, rejected }

class HealthPlanChangeProposal {
  HealthPlanChangeProposal({
    required this.proposalId,
    required this.planId,
    required this.origin,
    required this.summary,
    required this.rationale,
    required this.clinicallySignificant,
    required this.createdAtUtc,
  }) {
    if (proposalId.trim().isEmpty ||
        planId.trim().isEmpty ||
        summary.trim().isEmpty ||
        rationale.trim().isEmpty) {
      throw ArgumentError('Complete plan-change explanation is required');
    }
    if (!createdAtUtc.isUtc) {
      throw ArgumentError('Proposal timestamp must be UTC');
    }
  }

  final String proposalId;
  final String planId;
  final HealthPlanProposalOrigin origin;
  final String summary;
  final String rationale;
  final bool clinicallySignificant;
  final DateTime createdAtUtc;
}

class HealthPlanChangeApproval {
  HealthPlanChangeApproval({
    required this.proposal,
    required this.userApprovedAtUtc,
    required this.clinicianReviewState,
    this.clinicianReviewerId,
    this.clinicianReviewedAtUtc,
  }) {
    if (!userApprovedAtUtc.isUtc ||
        (clinicianReviewedAtUtc != null && !clinicianReviewedAtUtc!.isUtc)) {
      throw ArgumentError('Approval timestamps must be UTC');
    }
    if (clinicianReviewState == ClinicianReviewState.approved &&
        (clinicianReviewerId == null ||
            clinicianReviewerId!.trim().isEmpty ||
            clinicianReviewedAtUtc == null)) {
      throw ArgumentError(
        'Approved clinical review requires reviewer evidence',
      );
    }
    if (proposal.clinicallySignificant &&
        clinicianReviewState != ClinicianReviewState.approved) {
      throw ArgumentError(
        'Clinically significant approval requires professional review',
      );
    }
  }

  final HealthPlanChangeProposal proposal;
  final DateTime userApprovedAtUtc;
  final ClinicianReviewState clinicianReviewState;
  final String? clinicianReviewerId;
  final DateTime? clinicianReviewedAtUtc;
}

class HealthPlanChangeNotApproved implements Exception {
  const HealthPlanChangeNotApproved(this.message);
  final String message;
}

class ApproveHealthPlanChange {
  const ApproveHealthPlanChange();

  HealthPlanChangeApproval execute({
    required HealthPlanChangeProposal proposal,
    required bool userExplicitlyApproved,
    required DateTime nowUtc,
    ClinicianReviewState clinicianReviewState = ClinicianReviewState.pending,
    String? clinicianReviewerId,
    DateTime? clinicianReviewedAtUtc,
  }) {
    if (!nowUtc.isUtc) throw ArgumentError('Approval time must be UTC');
    if (!userExplicitlyApproved) {
      throw const HealthPlanChangeNotApproved(
        'Explicit user approval is required.',
      );
    }
    if (proposal.clinicallySignificant &&
        clinicianReviewState != ClinicianReviewState.approved) {
      throw const HealthPlanChangeNotApproved(
        'Clinically significant changes require approved professional review.',
      );
    }
    return HealthPlanChangeApproval(
      proposal: proposal,
      userApprovedAtUtc: nowUtc,
      clinicianReviewState: proposal.clinicallySignificant
          ? clinicianReviewState
          : ClinicianReviewState.notRequired,
      clinicianReviewerId: proposal.clinicallySignificant
          ? clinicianReviewerId
          : null,
      clinicianReviewedAtUtc: proposal.clinicallySignificant
          ? clinicianReviewedAtUtc
          : null,
    );
  }
}
