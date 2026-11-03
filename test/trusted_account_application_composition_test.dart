import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_application_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_planner.dart';
import 'package:sehat_coach/features/bachat/domain/bachat_repository.dart';
import 'package:sehat_coach/features/onboarding/presentation/widgets/authenticated_profile_gate.dart';
import 'package:sehat_coach/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:sehat_coach/features/account/presentation/screens/account_access_destination_screen.dart';
import 'package:sehat_coach/features/account/presentation/screens/account_switch_screen.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_session_gate.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_shell_screen.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  test(
    'bridges configured account core into every explicit app state',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);
      final signedOut = const Text('Sign in');
      final verify = const Text('Verify');
      final eligibility = const Text('Eligibility');
      final switchBlocked = const Text('Switch blocked');
      final missing = const Text('Resume onboarding');

      final root =
          TrustedAccountApplicationComposition(
                core: harness.core,
                createShell: (home) => ActivatedShellComposition(home: home),
                signedOut: signedOut,
                emailVerificationRequired: verify,
                adultEligibilityRequired: eligibility,
                accountSwitchBlocked: switchBlocked,
                missingProfile: missing,
              ).build()
              as AuthenticatedSessionGate;

      expect(root.binding, same(harness.core.authState));
      expect(root.signedOut, same(signedOut));
      expect(root.emailVerificationRequired, same(verify));
      expect(root.adultEligibilityRequired, same(eligibility));
      expect(root.accountSwitchBlocked, same(switchBlocked));
      expect(root.authenticated, isA<AuthenticatedProfileGate>());
      expect(harness.databases.activeOwnerId, isNull);
    },
  );

  test('rejects incomplete verified Bachat dependencies at app root', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    expect(
      () => TrustedAccountApplicationComposition(
        core: harness.core,
        createShell: (home) => ActivatedShellComposition(home: home),
        signedOut: const SizedBox(),
        emailVerificationRequired: const SizedBox(),
        adultEligibilityRequired: const SizedBox(),
        accountSwitchBlocked: const SizedBox(),
        missingProfile: const SizedBox(),
        bachatRepository: _BachatRepository(),
      ),
      throwsArgumentError,
    );
  });

  test(
    'account-access factory supplies all three trusted public states',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);

      final root =
          TrustedAccountApplicationComposition.withAccountAccess(
                core: harness.core,
                createShell: (home) => ActivatedShellComposition(home: home),
                accountSwitchBlocked: const Text('Switch blocked'),
                missingProfile: const Text('Resume onboarding'),
              ).build()
              as AuthenticatedSessionGate;

      expect(root.signedOut, isA<AccountAccessDestinationScreen>());
      expect(
        root.emailVerificationRequired,
        isA<AccountAccessDestinationScreen>(),
      );
      expect(
        root.adultEligibilityRequired,
        isA<AccountAccessDestinationScreen>(),
      );
      final destinations = [
        root.signedOut as AccountAccessDestinationScreen,
        root.emailVerificationRequired as AccountAccessDestinationScreen,
        root.adultEligibilityRequired as AccountAccessDestinationScreen,
      ];
      expect(
        destinations.map((item) => item.destination),
        AccountAccessDestination.values,
      );
      expect(destinations.map((item) => item.controller).toSet(), hasLength(1));
    },
  );

  test('full factory supplies secure account-switch destination', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final root =
        TrustedAccountApplicationComposition.withAccountAccessAndSwitch(
              core: harness.core,
              createShell: (home) => ActivatedShellComposition(home: home),
              missingProfile: const Text('Resume onboarding'),
              synchronizeOwner: (_) async {},
              connectivityCheck: () async => true,
              onReadyForAuthentication: () async {},
            ).build()
            as AuthenticatedSessionGate;

    expect(root.accountSwitchBlocked, isA<AccountSwitchScreen>());
    expect(root.signedOut, isA<AccountAccessDestinationScreen>());
  });

  test('complete factory supplies authenticated onboarding resume', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final root =
        TrustedAccountApplicationComposition.withOnboardingResume(
              core: harness.core,
              createShell: (home) => ActivatedShellComposition(home: home),
              synchronizeOwner: (_) async {},
              connectivityCheck: () async => true,
              onReadyForAuthentication: () async {},
              onProfileCommitted: (_) async {},
              detectLocation: false,
            ).build()
            as AuthenticatedSessionGate;
    final profileGate = root.authenticated as AuthenticatedProfileGate;

    expect(profileGate.missingProfile, isA<OnboardingScreen>());
    final onboarding = profileGate.missingProfile as OnboardingScreen;
    expect(onboarding.authenticatedCompletion, isNotNull);
    expect(onboarding.detectLocation, isFalse);
  });

  test(
    'account lifecycle factory injects safety and switching into shell',
    () async {
      final harness = await _Harness.create();
      addTearDown(harness.dispose);

      final root =
          TrustedAccountApplicationComposition.withAccountLifecycle(
                core: harness.core,
                createShell: (home) => ActivatedShellComposition(home: home),
                synchronizeOwner: (_) async {},
                clearOwnerSession: (_) async {},
                deleteCloudAccount: (_) async => true,
                checkRecentAuthentication: (_) async => true,
                connectivityCheck: () async => true,
                onReadyForAuthentication: () async {},
                onSignedOut: () async {},
                onAccountDeleted: () async {},
                onProfileCommitted: (_) async {},
                detectLocation: false,
              ).build()
              as AuthenticatedSessionGate;
      final profileGate = root.authenticated as AuthenticatedProfileGate;
      final shell = profileGate.profileBuilder(
        OnboardingState(age: 30),
      ) as AuthenticatedShellScreen;

      expect(shell.createAccountSafety, isNotNull);
      expect(shell.createAccountSwitch, isNotNull);
    },
  );
}

class _Harness {
  _Harness(this.directory, this.databases, this.provider, this.core);

  final Directory directory;
  final AccountDatabaseService databases;
  final _Provider provider;
  final TrustedAccountCoreComposition core;

  static Future<_Harness> create() async {
    final directory = await Directory.systemTemp.createTemp('sehat-app-core-');
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
    return _Harness(directory, databases, provider, core);
  }

  Future<void> dispose() async {
    await core.authState.stop();
    provider.close();
    await databases.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
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

class _BachatRepository implements BachatRepository {
  @override
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(
    String cityId,
  ) async => const [];
}
