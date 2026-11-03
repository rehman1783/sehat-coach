import '../../onboarding/domain/models/onboarding_state.dart';

enum FastingEligibility {
  eligibleWithGeneralCaution,
  clinicianGuidanceRequired,
  doNotEncourage,
}

class FastingSafetyAssessment {
  const FastingSafetyAssessment({
    required this.eligibility,
    required this.message,
    required this.blockAutomaticPlan,
  });

  final FastingEligibility eligibility;
  final String message;
  final bool blockAutomaticPlan;
}

class FastingSafetyPolicy {
  const FastingSafetyPolicy();

  FastingSafetyAssessment assess(OnboardingState profile) {
    final conditions = profile.conditions.toSet();
    if (profile.age < 18 ||
        conditions.contains(HealthCondition.pregnancy) ||
        conditions.contains(HealthCondition.breastfeeding)) {
      return const FastingSafetyAssessment(
        eligibility: FastingEligibility.doNotEncourage,
        message: 'Sehat Coach will not recommend a fasting plan for your current profile. Follow qualified clinical guidance.',
        blockAutomaticPlan: true,
      );
    }
    if (conditions.contains(HealthCondition.diabetes) ||
        conditions.contains(HealthCondition.bp) ||
        conditions.contains(HealthCondition.clinicianPlan)) {
      return const FastingSafetyAssessment(
        eligibility: FastingEligibility.clinicianGuidanceRequired,
        message: 'Use fasting features only with guidance from your qualified clinician. Sehat Coach will not create an automatic plan.',
        blockAutomaticPlan: true,
      );
    }
    return const FastingSafetyAssessment(
      eligibility: FastingEligibility.eligibleWithGeneralCaution,
      message: 'Fasting support is optional. Stop and seek appropriate care if you feel unwell.',
      blockAutomaticPlan: false,
    );
  }
}
