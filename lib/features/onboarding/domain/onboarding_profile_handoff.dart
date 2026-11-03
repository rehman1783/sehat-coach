import '../../account/domain/create_profile_use_case.dart';
import 'models/onboarding_state.dart';

/// One-shot boundary between the finalized onboarding draft and private Home.
///
/// A successful completion means the encrypted profile and its synchronization
/// operation were committed before [onCommitted] ran. Concurrent taps share
/// the same work, while a failed attempt may be retried without navigating.
class OnboardingProfileHandoff {
  OnboardingProfileHandoff(this._profiles, this._onCommitted);

  final ProfileCreationPort _profiles;
  final Future<void> Function(OnboardingState profile) _onCommitted;

  Future<void>? _inFlight;
  bool _completed = false;
  OnboardingState? _committedProfile;

  bool get isCompleted => _completed;

  Future<void> complete({
    required OnboardingState profile,
    required bool adultAgeConfirmed,
  }) {
    if (_completed) return Future<void>.value();
    final active = _inFlight;
    if (active != null) return active;

    final operation = _complete(
      profile: profile,
      adultAgeConfirmed: adultAgeConfirmed,
    );
    _inFlight = operation;
    operation.whenComplete(() {
      if (identical(_inFlight, operation)) _inFlight = null;
    }).ignore();
    return operation;
  }

  Future<void> _complete({
    required OnboardingState profile,
    required bool adultAgeConfirmed,
  }) async {
    var snapshot = _committedProfile;
    if (snapshot == null) {
      snapshot = profile.copyWith(conditions: List.of(profile.conditions));
      await _profiles.create(
        profile: snapshot,
        adultAgeConfirmed: adultAgeConfirmed,
      );
      _committedProfile = snapshot;
    }
    await _onCommitted(snapshot);
    _completed = true;
  }
}
