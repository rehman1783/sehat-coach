import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/account_access_composition.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';

void main() {
  test(
    'registration publishes pending identity before verification dispatch',
    () async {
      final adapter = _Adapter();
      final session = SerializedIdentitySession();
      final runtime = _Runtime();
      final controller = AccountAccessComposition(
        signIn: adapter,
        registration: adapter,
        passwordReset: adapter,
        emailVerification: adapter,
        identitySession: session,
        runtime: runtime,
        suspension: runtime,
        onAuthenticated: () async {},
      ).createController();
      controller
        ..showCreateAccount()
        ..emailAddress.value = 'adult@example.com'
        ..password.value = 'not-a-real-password'
        ..declaredAge.value = 25
        ..adultConfirmed.value = true;

      await controller.submitPassword();

      expect(adapter.verificationOwner, 'owner-a');
      expect(runtime.activeOwnerId, isNull);
      expect(controller.mode.value.name, 'verifyEmail');
      expect(
        await session.withIdentity((identity) async => identity.uid),
        'owner-a',
      );
    },
  );

  test(
    'ready sign-in publishes identity and activates matching runtime',
    () async {
      final adapter = _Adapter()..signInVerified = true;
      final session = SerializedIdentitySession();
      final runtime = _Runtime();
      var authenticated = 0;
      final controller = AccountAccessComposition(
        signIn: adapter,
        registration: adapter,
        passwordReset: adapter,
        emailVerification: adapter,
        identitySession: session,
        runtime: runtime,
        suspension: runtime,
        onAuthenticated: () async => authenticated++,
      ).createController();
      controller
        ..emailAddress.value = 'adult@example.com'
        ..password.value = 'not-a-real-password';

      await controller.submitPassword();

      expect(runtime.activeOwnerId, 'owner-a');
      expect(authenticated, 1);
      expect(controller.password.value, isEmpty);
      expect(
        await session.withIdentity((identity) async => identity.uid),
        'owner-a',
      );
    },
  );
}

class _Adapter
    implements
        SignInPort,
        PasswordAccountRegistrationPort,
        PasswordResetPort,
        EmailVerificationPort {
  bool signInVerified = false;
  String? verificationOwner;

  AccountIdentity _identity({required bool verified}) => AccountIdentity(
    uid: 'owner-a',
    emailVerified: verified,
    adultEligible: true,
    linkedProviders: const {AccountProvider.password},
  );

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async => _identity(verified: false);

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async => _identity(verified: signInVerified);

  @override
  Future<AccountIdentity> signInWithGoogle() async => AccountIdentity(
    uid: 'owner-a',
    emailVerified: true,
    adultEligible: true,
    linkedProviders: const {AccountProvider.google},
  );

  @override
  Future<void> requestPasswordReset(String emailAddress) async {}

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async {
    verificationOwner = ownerId;
    return VerificationDispatch.sent;
  }

  @override
  Future<AccountIdentity> refreshIdentity(String ownerId) async =>
      _identity(verified: true);
}

class _Runtime implements AccountRuntimePort, AccountSuspensionPort {
  @override
  String? activeOwnerId;

  @override
  Future<void> activate(String ownerId) async => activeOwnerId = ownerId;

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    activeOwnerId = null;
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {}
}
