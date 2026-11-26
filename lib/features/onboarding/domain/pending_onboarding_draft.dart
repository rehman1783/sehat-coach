import 'models/onboarding_state.dart';

/// Holds unauthenticated onboarding answers in volatile memory until the user
/// creates or signs into a verified adult account and activates encrypted
/// owner storage.
class PendingOnboardingDraft {
  OnboardingState? _profile;
  bool _adultAgeConfirmed = false;

  bool get hasDraft => _profile != null;

  void save(OnboardingState profile, {required bool adultAgeConfirmed}) {
    _profile = profile.copyWith(conditions: List.of(profile.conditions));
    _adultAgeConfirmed = adultAgeConfirmed;
  }

  ({OnboardingState profile, bool adultAgeConfirmed})? peek() {
    final profile = _profile;
    if (profile == null) return null;
    return (
      profile: profile.copyWith(conditions: List.of(profile.conditions)),
      adultAgeConfirmed: _adultAgeConfirmed,
    );
  }

  ({OnboardingState profile, bool adultAgeConfirmed})? take() {
    final snapshot = peek();
    clear();
    return snapshot;
  }

  void clear() {
    _profile = null;
    _adultAgeConfirmed = false;
  }
}
