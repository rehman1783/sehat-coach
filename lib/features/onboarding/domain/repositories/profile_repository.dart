import '../models/onboarding_state.dart';

/// Implementations must isolate owners and return detached snapshots.
/// Successful writes must be atomic; failures must preserve the prior profile.
abstract interface class ProfileRepository {
  Future<void> save(String ownerId, OnboardingState profile);
  Future<OnboardingState?> read(String ownerId);
  Future<void> clearLocal(String ownerId);
}
