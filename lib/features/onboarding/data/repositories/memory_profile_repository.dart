import '../../domain/models/onboarding_state.dart';
import '../../domain/repositories/profile_repository.dart';

/// Development adapter only. Does not persist across app restarts.
class MemoryProfileRepository implements ProfileRepository {
  final Map<String, OnboardingState> _profiles = {};

  void _validateOwner(String ownerId) {
    if (ownerId.trim().isEmpty) {
      throw ArgumentError.value(ownerId, 'ownerId', 'Owner is required');
    }
  }

  OnboardingState _snapshot(OnboardingState profile) =>
      profile.copyWith(conditions: List.of(profile.conditions));

  @override
  Future<void> save(String ownerId, OnboardingState profile) async {
    _validateOwner(ownerId);
    _profiles[ownerId] = _snapshot(profile);
  }

  @override
  Future<OnboardingState?> read(String ownerId) async {
    _validateOwner(ownerId);
    final profile = _profiles[ownerId];
    return profile == null ? null : _snapshot(profile);
  }

  @override
  Future<void> clearLocal(String ownerId) async {
    _validateOwner(ownerId);
    _profiles.remove(ownerId);
  }
}
