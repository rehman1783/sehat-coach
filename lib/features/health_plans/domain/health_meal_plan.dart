enum HealthPlanCaptureMethod { manualEntry, importedDocument }

enum HealthPlanAuthorship {
  userCreated,
  userReportedClinicianProvided,
  verifiedClinicianProvided,
}

class ClinicianVerificationEvidence {
  ClinicianVerificationEvidence({
    required this.reviewerId,
    required this.reviewedAtUtc,
    required this.evidenceReference,
  }) {
    if (reviewerId.trim().isEmpty || evidenceReference.trim().isEmpty) {
      throw ArgumentError('Clinician verification evidence is required');
    }
    if (!reviewedAtUtc.isUtc) {
      throw ArgumentError('Review timestamp must be UTC');
    }
  }

  final String reviewerId;
  final DateTime reviewedAtUtc;
  final String evidenceReference;
}

class HealthPlanMealInstruction {
  HealthPlanMealInstruction({
    required this.instructionId,
    required this.label,
    required this.instructions,
    this.scheduleLabel,
  }) {
    if (instructionId.trim().isEmpty ||
        label.trim().isEmpty ||
        instructions.trim().isEmpty) {
      throw ArgumentError('Complete meal instruction text is required');
    }
  }

  final String instructionId;
  final String label;
  final String instructions;
  final String? scheduleLabel;
}

class HealthMealPlan {
  HealthMealPlan({
    required this.planId,
    required this.ownerId,
    required this.title,
    required this.captureMethod,
    required this.authorship,
    required this.originalText,
    required Iterable<HealthPlanMealInstruction> instructions,
    required this.capturedAtUtc,
    this.originalDocumentDigest,
    this.clinicianVerification,
  }) : instructions = List.unmodifiable(instructions) {
    if (planId.trim().isEmpty ||
        ownerId.trim().isEmpty ||
        title.trim().isEmpty ||
        originalText.trim().isEmpty ||
        this.instructions.isEmpty) {
      throw ArgumentError(
        'Complete plan identity and original content are required',
      );
    }
    if (!capturedAtUtc.isUtc) {
      throw ArgumentError('Capture timestamp must be UTC');
    }
    if (captureMethod == HealthPlanCaptureMethod.importedDocument &&
        (originalDocumentDigest == null ||
            originalDocumentDigest!.trim().isEmpty)) {
      throw ArgumentError(
        'Imported plans require an immutable document digest',
      );
    }
    if (authorship == HealthPlanAuthorship.verifiedClinicianProvided &&
        clinicianVerification == null) {
      throw ArgumentError(
        'Verified clinician authorship requires review evidence',
      );
    }
    if (authorship != HealthPlanAuthorship.verifiedClinicianProvided &&
        clinicianVerification != null) {
      throw ArgumentError(
        'Unverified authorship cannot carry verification evidence',
      );
    }
    final ids = this.instructions.map((value) => value.instructionId).toSet();
    if (ids.length != this.instructions.length) {
      throw ArgumentError('Meal instruction IDs must be unique');
    }
  }

  final String planId;
  final String ownerId;
  final String title;
  final HealthPlanCaptureMethod captureMethod;
  final HealthPlanAuthorship authorship;
  final String originalText;
  final String? originalDocumentDigest;
  final List<HealthPlanMealInstruction> instructions;
  final DateTime capturedAtUtc;
  final ClinicianVerificationEvidence? clinicianVerification;

  bool get isClinicianVerified =>
      authorship == HealthPlanAuthorship.verifiedClinicianProvided;
}

class HealthPlanGuidanceDecision {
  const HealthPlanGuidanceDecision({
    required this.automaticNutritionTargetsAllowed,
    required this.message,
  });

  final bool automaticNutritionTargetsAllowed;
  final String message;
}

class HealthPlanPrecedencePolicy {
  const HealthPlanPrecedencePolicy();

  HealthPlanGuidanceDecision decide(HealthMealPlan? activePlan) {
    if (activePlan == null) {
      return const HealthPlanGuidanceDecision(
        automaticNutritionTargetsAllowed: true,
        message: 'No active entered health plan is taking precedence.',
      );
    }
    return HealthPlanGuidanceDecision(
      automaticNutritionTargetsAllowed: false,
      message: activePlan.isClinicianVerified
          ? 'The verified clinician-provided plan takes precedence.'
          : 'The entered plan is preserved and takes precedence. Clinician authorship has not been verified.',
    );
  }
}
