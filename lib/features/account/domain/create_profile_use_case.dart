import '../../onboarding/domain/models/onboarding_state.dart';
import '../../onboarding/domain/repositories/profile_repository.dart';
import 'authenticated_owner_session.dart';

export 'authenticated_owner_session.dart';

class IneligibleProfileException implements Exception {
  const IneligibleProfileException();
}

class AuthenticationRequiredException implements Exception {
  const AuthenticationRequiredException();
}

/// Application boundary for creating a profile after authentication.
abstract interface class ProfileCreationPort {
  Future<void> create({
    required OnboardingState profile,
    required bool adultAgeConfirmed,
  });
}

class CreateProfileUseCase implements ProfileCreationPort {
  const CreateProfileUseCase(this._repository, this._session);

  final ProfileRepository _repository;
  final AuthenticatedOwnerSession _session;

  @override
  Future<void> create({
    required OnboardingState profile,
    required bool adultAgeConfirmed,
  }) async {
    if (!adultAgeConfirmed || profile.age < 18 || profile.age > 100) {
      throw const IneligibleProfileException();
    }
    await _session.withOwner((ownerId) async {
      if (ownerId.trim().isEmpty) {
        throw const AuthenticationRequiredException();
      }
      await _repository.save(ownerId, profile);
    });
  }
}

/// Reads a profile through the same stable verified-owner boundary used for
/// writes. A repository composed for a previous account fails its owner check.
class LoadProfileUseCase {
  const LoadProfileUseCase(this._repository, this._session);

  final ProfileRepository _repository;
  final AuthenticatedOwnerSession _session;

  Future<OnboardingState?> load() =>
      _session.withOwner((ownerId) => _repository.read(ownerId));
}
