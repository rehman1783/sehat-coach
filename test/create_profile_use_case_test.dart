import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/create_profile_use_case.dart';
import 'package:sehat_coach/features/onboarding/data/repositories/memory_profile_repository.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

class FakeAuthenticatedSession implements AuthenticatedOwnerSession {
  FakeAuthenticatedSession(this.ownerId);
  String? ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) async {
    final owner = ownerId;
    if (owner == null) throw const AuthenticationRequiredException();
    return operation(owner);
  }
}

void main() {
  test('rejects unconfirmed and under-18 profiles without writing', () async {
    final repository = MemoryProfileRepository();
    final create = CreateProfileUseCase(
      repository,
      FakeAuthenticatedSession('owner-a'),
    );
    await expectLater(
      create.create(
        profile: OnboardingState(age: 25),
        adultAgeConfirmed: false,
      ),
      throwsA(isA<IneligibleProfileException>()),
    );
    await expectLater(
      create.create(profile: OnboardingState(age: 17), adultAgeConfirmed: true),
      throwsA(isA<IneligibleProfileException>()),
    );
    expect(await repository.read('owner-a'), isNull);
  });

  test('18+ confirmed profile is saved only for session owner', () async {
    final repository = MemoryProfileRepository();
    final session = FakeAuthenticatedSession('owner-a');
    final create = CreateProfileUseCase(repository, session);
    await create.create(
      profile: OnboardingState(age: 18, city: 'Multan'),
      adultAgeConfirmed: true,
    );
    expect((await repository.read('owner-a'))?.city, 'Multan');
    expect(await repository.read('owner-b'), isNull);
    session.ownerId = 'owner-b';
    await create.create(
      profile: OnboardingState(age: 30, city: 'Quetta'),
      adultAgeConfirmed: true,
    );
    expect((await repository.read('owner-a'))?.city, 'Multan');
    expect((await repository.read('owner-b'))?.city, 'Quetta');
    session.ownerId = null;
    await expectLater(
      create.create(profile: OnboardingState(age: 25), adultAgeConfirmed: true),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    expect((await repository.read('owner-b'))?.city, 'Quetta');
  });
}
