enum AiLoggingLocale { english, romanUrdu }

enum AiProposalDisposition { reviewRequired, manualFallback }

class AiLoggingRequest {
  AiLoggingRequest({
    required this.requestId,
    required this.ownerId,
    required this.locale,
    required String text,
    required this.createdAtUtc,
  }) : text = text.trim() {
    if (requestId.trim().isEmpty || ownerId.trim().isEmpty) {
      throw ArgumentError('Request and owner identity are required.');
    }
    if (!createdAtUtc.isUtc) {
      throw ArgumentError.value(createdAtUtc, 'createdAtUtc', 'Must be UTC.');
    }
    if (this.text.isEmpty || this.text.length > 500) {
      throw ArgumentError.value(text, 'text', 'Must contain 1–500 characters.');
    }
  }

  final String requestId;
  final String ownerId;
  final AiLoggingLocale locale;
  final String text;
  final DateTime createdAtUtc;
}

class AiFoodCandidate {
  AiFoodCandidate({
    required this.catalogFoodId,
    required this.servingId,
    required this.quantity,
    required this.confidence,
    required String explanation,
    this.assumptions = const [],
  }) : explanation = explanation.trim() {
    if (catalogFoodId.trim().isEmpty || servingId.trim().isEmpty) {
      throw ArgumentError('Catalog food and serving identity are required.');
    }
    if (!quantity.isFinite || quantity <= 0 || quantity > 10000) {
      throw ArgumentError.value(quantity, 'quantity');
    }
    if (!confidence.isFinite || confidence < 0 || confidence > 1) {
      throw ArgumentError.value(confidence, 'confidence');
    }
    if (this.explanation.isEmpty) {
      throw ArgumentError.value(explanation, 'explanation');
    }
  }

  final String catalogFoodId;
  final String servingId;
  final double quantity;
  final double confidence;
  final String explanation;
  final List<String> assumptions;
}

class AiLoggingProposal {
  AiLoggingProposal({
    required this.requestId,
    required this.schemaVersion,
    required this.promptVersion,
    required this.modelId,
    required this.createdAtUtc,
    required this.expiresAtUtc,
    required List<AiFoodCandidate> candidates,
  }) : candidates = List.unmodifiable(candidates) {
    if (requestId.trim().isEmpty ||
        schemaVersion.trim().isEmpty ||
        promptVersion.trim().isEmpty ||
        modelId.trim().isEmpty) {
      throw ArgumentError('Proposal provenance is incomplete.');
    }
    if (!createdAtUtc.isUtc || !expiresAtUtc.isUtc) {
      throw ArgumentError('Proposal timestamps must be UTC.');
    }
    if (!expiresAtUtc.isAfter(createdAtUtc)) {
      throw ArgumentError('Proposal expiry must follow creation.');
    }
    if (this.candidates.isEmpty || this.candidates.length > 20) {
      throw ArgumentError.value(candidates, 'candidates');
    }
  }

  final String requestId;
  final String schemaVersion;
  final String promptVersion;
  final String modelId;
  final DateTime createdAtUtc;
  final DateTime expiresAtUtc;
  final List<AiFoodCandidate> candidates;

  double get minimumConfidence => candidates
      .map((candidate) => candidate.confidence)
      .reduce((value, next) => value < next ? value : next);
}

class AiProposalReviewPolicy {
  const AiProposalReviewPolicy({this.minimumReviewConfidence = 0.55});

  final double minimumReviewConfidence;

  AiProposalDisposition evaluate(
    AiLoggingProposal proposal, {
    required DateTime nowUtc,
  }) {
    if (!nowUtc.isUtc ||
        !proposal.expiresAtUtc.isAfter(nowUtc) ||
        proposal.minimumConfidence < minimumReviewConfidence) {
      return AiProposalDisposition.manualFallback;
    }
    return AiProposalDisposition.reviewRequired;
  }
}

abstract interface class AiLoggingGateway {
  Future<AiLoggingProposal> propose(AiLoggingRequest request);
}

sealed class AiLoggingOutcome {
  const AiLoggingOutcome();
}

class AiProposalReady extends AiLoggingOutcome {
  const AiProposalReady(this.proposal);
  final AiLoggingProposal proposal;
}

class AiManualFallback extends AiLoggingOutcome {
  const AiManualFallback(this.message);
  final String message;
}

class AiLoggingCoordinator {
  const AiLoggingCoordinator({
    required this.gateway,
    this.policy = const AiProposalReviewPolicy(),
  });

  final AiLoggingGateway gateway;
  final AiProposalReviewPolicy policy;

  Future<AiLoggingOutcome> propose({
    required bool consentGranted,
    required AiLoggingRequest request,
    required DateTime nowUtc,
  }) async {
    if (!consentGranted) {
      return const AiManualFallback(
        'AI assistance is off. Continue with private manual meal logging.',
      );
    }
    try {
      final proposal = await gateway.propose(request);
      if (proposal.requestId != request.requestId ||
          policy.evaluate(proposal, nowUtc: nowUtc) ==
              AiProposalDisposition.manualFallback) {
        return const AiManualFallback(
          'The suggestion is uncertain or expired. Continue with manual search.',
        );
      }
      return AiProposalReady(proposal);
    } on Object {
      return const AiManualFallback(
        'AI assistance is unavailable. Your manual meal logger still works.',
      );
    }
  }
}

class AiProposalConfirmation {
  AiProposalConfirmation({
    required this.proposal,
    required Iterable<int> acceptedCandidateIndexes,
  }) : acceptedCandidateIndexes = Set.unmodifiable(acceptedCandidateIndexes) {
    if (this.acceptedCandidateIndexes.isEmpty ||
        this.acceptedCandidateIndexes.any(
          (index) => index < 0 || index >= proposal.candidates.length,
        )) {
      throw ArgumentError.value(
        acceptedCandidateIndexes,
        'acceptedCandidateIndexes',
      );
    }
  }

  final AiLoggingProposal proposal;
  final Set<int> acceptedCandidateIndexes;

  List<AiFoodCandidate> get acceptedCandidates => List.unmodifiable(
    acceptedCandidateIndexes.map((index) => proposal.candidates[index]),
  );
}
