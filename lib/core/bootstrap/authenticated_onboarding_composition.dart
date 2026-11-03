import 'package:flutter/widgets.dart';

import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/onboarding/domain/onboarding_profile_handoff.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'activated_account_features.dart';

/// Supplies authenticated onboarding with the verified owner's durable
/// profile handoff. The handoff is created once and retains its duplicate-tap
/// and post-commit recovery guarantees for the lifetime of this composition.
class AuthenticatedOnboardingComposition {
  AuthenticatedOnboardingComposition({
    required this.features,
    required this.onProfileCommitted,
    this.initialLanguage = AppLanguage.english,
    this.detectLocation = false,
  });

  final ActivatedAccountFeatures features;
  final Future<void> Function(OnboardingState profile) onProfileCommitted;
  final AppLanguage initialLanguage;
  final bool detectLocation;
  Future<OnboardingProfileHandoff>? _handoff;

  Widget build() => OnboardingScreen(
    initialLanguage: initialLanguage,
    detectLocation: detectLocation,
    authenticatedCompletion: complete,
  );

  Future<void> complete(OnboardingState profile, bool adultAgeConfirmed) async {
    final handoff = await (_handoff ??= features.createOnboardingProfileHandoff(
      onCommitted: onProfileCommitted,
    ));
    await handoff.complete(
      profile: profile,
      adultAgeConfirmed: adultAgeConfirmed,
    );
  }
}
