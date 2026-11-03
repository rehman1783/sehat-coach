import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_platform_account_composition.dart';
import 'package:sehat_coach/core/data/local/flutter_secure_account_key_vault.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';

void main() {
  test(
    'platform composition activates one protected encrypted account core',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-platform-',
      );
      final provider = _Provider();
      final secureValues = _SecureValues();
      var authenticated = 0;
      final platform = TrustedPlatformAccountComposition(
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
        onAuthenticated: () async => authenticated++,
      );
      addTearDown(() async {
        await platform.core.authState.stop();
        provider.close();
        await platform.storage.databases.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final access = platform.core.createAccountAccessController()
        ..emailAddress.value = 'adult@example.com'
        ..password.value = 'transient-password';

      await access.submitPassword();

      expect(platform.core.runtime.activeOwnerId, 'owner-a');
      expect(platform.storage.databases.activeOwnerId, 'owner-a');
      expect(authenticated, 1);
      expect(secureValues.values, hasLength(1));
      expect(
        await platform.storage.databases.fileForOwner('owner-a').exists(),
        isTrue,
      );
    },
  );
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

  AccountIdentity get passwordIdentity => AccountIdentity(
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
  }) async => passwordIdentity;

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
  Future<AccountIdentity> refreshIdentity(String ownerId) async =>
      passwordIdentity;

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async =>
      VerificationDispatch.sent;
}

class _SecureValues implements SecureValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
