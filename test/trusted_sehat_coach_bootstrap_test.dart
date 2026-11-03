import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_sehat_coach_bootstrap.dart';
import 'package:sehat_coach/core/data/local/flutter_secure_account_key_vault.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_session_gate.dart';

void main() {
  test(
    'facade builds complete trusted root without opening private data',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-bootstrap-',
      );
      final provider = _Provider();
      final secureValues = _SecureValues();
      final bootstrap = TrustedSehatCoachBootstrap(
        applicationDataDirectory: directory,
        provider: TrustedAccountProviderPorts(
          authState: provider,
          signIn: provider,
          registration: provider,
          passwordReset: provider,
          emailVerification: provider,
        ),
        secureValues: secureValues,
        clearDecryptedMemory: (_) async {},
        onAuthenticated: () async {},
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
      );
      addTearDown(() async {
        await bootstrap.core.authState.stop();
        provider.close();
        await bootstrap.platform.storage.databases.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final root = bootstrap.build();

      expect(root, isA<AuthenticatedSessionGate>());
      expect(bootstrap.core.runtime.activeOwnerId, isNull);
      expect(secureValues.values, isEmpty);
      expect(await directory.list().toList(), isEmpty);
    },
  );

  test('facade rejects empty platform directory before provider access', () {
    final provider = _Provider();
    addTearDown(provider.close);

    expect(
      () => TrustedSehatCoachBootstrap(
        applicationDataDirectory: Directory(''),
        provider: TrustedAccountProviderPorts(
          authState: provider,
          signIn: provider,
          registration: provider,
          passwordReset: provider,
          emailVerification: provider,
        ),
        secureValues: _SecureValues(),
        clearDecryptedMemory: (_) async {},
        onAuthenticated: () async {},
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
      ),
      throwsArgumentError,
    );
  });
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

  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => events.stream;

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async => _identity(AccountProvider.password);

  @override
  Future<AccountIdentity> signInWithGoogle() async =>
      _identity(AccountProvider.google);

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
  Future<AccountIdentity> refreshIdentity(String ownerId) async =>
      _identity(AccountProvider.password);

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async =>
      VerificationDispatch.sent;
}

AccountIdentity _identity(AccountProvider provider) => AccountIdentity(
  uid: 'owner-a',
  emailVerified: true,
  adultEligible: true,
  linkedProviders: {provider},
);

class _SecureValues implements SecureValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
