import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test(
    'interactive access and startup stream share owner security state',
    () async {
      final directory = await Directory.systemTemp.createTemp('sehat-core-');
      final databases = AccountDatabaseService(
        directory,
        AccountKeyResolver(_Vault()),
      );
      final provider = _Provider();
      final cleared = <String>[];
      var authenticated = 0;
      final core = TrustedAccountCoreComposition(
        provider: TrustedAccountProviderPorts(
          authState: provider,
          signIn: provider,
          registration: provider,
          passwordReset: provider,
          emailVerification: provider,
        ),
        databases: databases,
        clearDecryptedMemory: (ownerId) async => cleared.add(ownerId),
        onAuthenticated: () async => authenticated++,
      );
      addTearDown(() async {
        await core.authState.stop();
        provider.close();
        await databases.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final controller = core.createAccountAccessController()
        ..emailAddress.value = 'adult@example.com'
        ..password.value = 'transient-password';
      await controller.submitPassword();

      expect(core.runtime.activeOwnerId, 'owner-a');
      expect(authenticated, 1);
      expect(controller.password.value, isEmpty);
      expect(
        await core.identitySession.withIdentity(
          (identity) async => identity.uid,
        ),
        'owner-a',
      );

      final statuses = <AuthStateReconciliationStatus>[];
      core.authState.start(
        onStatus: statuses.add,
        onError: (error, stack) => fail('Unexpected auth error: $error'),
      );
      provider.events.add(null);
      await _waitFor(() => statuses.isNotEmpty);

      expect(statuses, [AuthStateReconciliationStatus.noIdentity]);
      expect(core.runtime.activeOwnerId, isNull);
      expect(cleared, ['owner-a']);
      await expectLater(
        core.identitySession.withIdentity((identity) async => identity.uid),
        throwsA(isA<AuthenticationRequired>()),
      );
    },
  );

  test(
    'verified feature session is the same identity used by account access',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-core-profile-',
      );
      final databases = AccountDatabaseService(
        directory,
        AccountKeyResolver(_Vault()),
      );
      final provider = _Provider();
      final core = TrustedAccountCoreComposition(
        provider: TrustedAccountProviderPorts(
          authState: provider,
          signIn: provider,
          registration: provider,
          passwordReset: provider,
          emailVerification: provider,
        ),
        databases: databases,
        clearDecryptedMemory: (_) async {},
        onAuthenticated: () async {},
      );
      addTearDown(() async {
        await core.authState.stop();
        provider.close();
        await databases.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final controller = core.createAccountAccessController()
        ..emailAddress.value = 'adult@example.com'
        ..password.value = 'transient-password';
      await controller.submitPassword();

      final handoff = await core.features.createOnboardingProfileHandoff(
        onCommitted: (_) async {},
      );
      await handoff.complete(
        profile: OnboardingState(age: 32, city: 'Faisalabad'),
        adultAgeConfirmed: true,
      );
      final loader = await core.features.createProfileLoader();

      expect((await loader.load())?.city, 'Faisalabad');
    },
  );

  test(
    'composed account switch suspends the shared encrypted runtime',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-core-switch-',
      );
      final databases = AccountDatabaseService(
        directory,
        AccountKeyResolver(_Vault()),
      );
      final provider = _Provider();
      final cleared = <String>[];
      final core = TrustedAccountCoreComposition(
        provider: TrustedAccountProviderPorts(
          authState: provider,
          signIn: provider,
          registration: provider,
          passwordReset: provider,
          emailVerification: provider,
        ),
        databases: databases,
        clearDecryptedMemory: (owner) async => cleared.add(owner),
        onAuthenticated: () async {},
      );
      addTearDown(() async {
        await core.authState.stop();
        provider.close();
        await databases.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final access = core.createAccountAccessController()
        ..emailAddress.value = 'adult@example.com'
        ..password.value = 'transient-password';
      await access.submitPassword();
      var ready = false;
      final switching = core.createAccountSwitchController(
        synchronizeOwner: (_) async {},
        connectivityCheck: () async => true,
        onReadyForAuthentication: () async => ready = true,
      );

      await switching.prepare();

      expect(core.runtime.activeOwnerId, isNull);
      expect(cleared, ['owner-a']);
      expect(ready, isTrue);
    },
  );

  test('composed sign-out clears local account and shared identity', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-core-signout-',
    );
    final databases = AccountDatabaseService(
      directory,
      AccountKeyResolver(_Vault()),
    );
    final provider = _Provider();
    final core = TrustedAccountCoreComposition(
      provider: TrustedAccountProviderPorts(
        authState: provider,
        signIn: provider,
        registration: provider,
        passwordReset: provider,
        emailVerification: provider,
      ),
      databases: databases,
      clearDecryptedMemory: (_) async {},
      onAuthenticated: () async {},
    );
    addTearDown(() async {
      await core.authState.stop();
      provider.close();
      await databases.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });
    final access = core.createAccountAccessController()
      ..emailAddress.value = 'adult@example.com'
      ..password.value = 'transient-password';
    await access.submitPassword();
    var providerSignOut = 0;
    var navigated = 0;
    final safety = core.createAccountSafetyController(
      synchronizeOwner: (_) async {},
      clearOwnerSession: (_) async => providerSignOut++,
      deleteCloudAccount: (_) async => true,
      checkRecentAuthentication: (_) async => true,
      connectivityCheck: () async => true,
      onSignedOut: () async => navigated++,
      onAccountDeleted: () async {},
    );

    await safety.signOut();

    expect(providerSignOut, 1);
    expect(navigated, 1);
    expect(core.runtime.activeOwnerId, isNull);
    expect(await databases.fileForOwner('owner-a').exists(), isFalse);
    await expectLater(
      core.identitySession.withIdentity((identity) async => identity.uid),
      throwsA(isA<AuthenticationRequired>()),
    );
  });
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100 && !condition(); attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue);
}

class _Provider
    implements
        AuthStateStreamPort,
        SignInPort,
        PasswordAccountRegistrationPort,
        PasswordResetPort,
        EmailVerificationPort {
  final events = StreamController<AccountIdentity?>();

  void close() => unawaited(events.close());

  AccountIdentity get identity => AccountIdentity(
    uid: 'owner-a',
    emailVerified: true,
    adultEligible: true,
    linkedProviders: const {AccountProvider.password},
  );

  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => events.stream;

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async => identity;

  @override
  Future<AccountIdentity> signInWithGoogle() async => AccountIdentity(
    uid: 'owner-a',
    emailVerified: true,
    adultEligible: true,
    linkedProviders: const {AccountProvider.google},
  );

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async => AccountIdentity(
    uid: 'owner-a',
    emailVerified: false,
    adultEligible: true,
    linkedProviders: const {AccountProvider.password},
  );

  @override
  Future<void> requestPasswordReset(String emailAddress) async {}

  @override
  Future<AccountIdentity> refreshIdentity(String ownerId) async => identity;

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async =>
      VerificationDispatch.sent;
}

class _Vault implements AccountKeyVault {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String ownerId) async => values[ownerId];

  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async =>
      values.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));

  @override
  Future<void> delete(String ownerId) async => values.remove(ownerId);
}
