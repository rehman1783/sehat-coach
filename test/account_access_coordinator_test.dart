import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';

AccountIdentity accessIdentity(String uid) => AccountIdentity(
  uid: uid,
  emailVerified: true,
  adultEligible: true,
  linkedProviders: const {AccountProvider.password},
);

SignInResult accessResult(
  AccountAccessStatus status, {
  String uid = 'owner-a',
}) => SignInResult(accessIdentity(uid), status);

class AccountRuntimeFake implements AccountRuntimePort {
  @override
  String? activeOwnerId;
  var activations = 0;
  bool publishWrongOwner = false;

  @override
  Future<void> activate(String ownerId) async {
    activations++;
    activeOwnerId = publishWrongOwner ? 'wrong-owner' : ownerId;
  }
}

void main() {
  test('only a ready identity activates encrypted account runtime', () async {
    final runtime = AccountRuntimeFake();
    final coordinator = AccountAccessCoordinator(runtime);
    for (final blocked in [
      AccountAccessStatus.emailVerificationRequired,
      AccountAccessStatus.adultEligibilityRequired,
    ]) {
      final result = await coordinator.activate(accessResult(blocked));
      expect(result.activated, isFalse);
      expect(result.accessStatus, blocked);
    }
    expect(runtime.activations, 0);

    final ready = await coordinator.activate(
      accessResult(AccountAccessStatus.ready),
    );
    expect(ready.activated, isTrue);
    expect(runtime.activeOwnerId, 'owner-a');
    expect(runtime.activations, 1);
  });

  test('same-owner activation is idempotent', () async {
    final runtime = AccountRuntimeFake()..activeOwnerId = 'owner-a';
    final result = await AccountAccessCoordinator(runtime)
        .activate(accessResult(AccountAccessStatus.ready));
    expect(result.activated, isTrue);
    expect(runtime.activations, 0);
  });

  test('different active owner requires safe sign-out first', () async {
    final runtime = AccountRuntimeFake()..activeOwnerId = 'owner-a';
    await expectLater(
      AccountAccessCoordinator(runtime)
          .activate(accessResult(AccountAccessStatus.ready, uid: 'owner-b')),
      throwsA(isA<AccountSwitchRequiresSignOut>()),
    );
    expect(runtime.activeOwnerId, 'owner-a');
    expect(runtime.activations, 0);
  });

  test('runtime must prove it activated the requested UID', () async {
    final runtime = AccountRuntimeFake()..publishWrongOwner = true;
    await expectLater(
      AccountAccessCoordinator(runtime)
          .activate(accessResult(AccountAccessStatus.ready)),
      throwsStateError,
    );
    expect(runtime.activations, 1);
  });
}
