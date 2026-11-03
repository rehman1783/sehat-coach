import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_consumer_runtime_composition.dart';
import 'package:sehat_coach/core/data/local/flutter_secure_account_key_vault.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/reauthenticate_account_use_cases.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/sync/domain/local_change_store.dart';
import 'package:sehat_coach/features/sync/domain/sync_pull_coordinator.dart';
import 'package:sehat_coach/features/sync/domain/sync_upload_coordinator.dart';

void main() {
  test(
    'composition does not open private data before verified activation',
    () async {
      final directory = await Directory.systemTemp.createTemp('consumer-root-');
      final provider = _Provider();
      final secureValues = _SecureValues();
      final bootstrap = composeTrustedConsumerRuntime(
        applicationDataDirectory: directory,
        services: TrustedConsumerRuntimeServices(
          provider: provider.ports,
          clearOwnerSession: (_) async {},
          deleteCloudAccount: (_) async => true,
          checkRecentAuthentication: (_) async => true,
          reauthentication: _Reauthentication(),
          syncUpload: _Upload(),
          syncPull: _Pull(),
        ),
        effects: TrustedConsumerRuntimeEffects(
          clearDecryptedMemory: (_) async {},
          onAuthenticated: () async {},
          createShell: (home) => ActivatedShellComposition(home: home),
          onReadyForAuthentication: () async {},
          onSignedOut: () async {},
          onAccountDeleted: () async {},
          onProfileCommitted: (_) async {},
        ),
        connectivityCheck: () async => true,
        networkLink: const Stream.empty(),
        secureValues: secureValues,
        detectLocation: false,
      );
      addTearDown(() async {
        unawaited(provider.close());
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      bootstrap.build();

      expect(bootstrap.core.runtime.activeOwnerId, isNull);
      expect(secureValues.values, isEmpty);
      expect(await directory.list().toList(), isEmpty);
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
  final _events = StreamController<AccountIdentity?>();

  TrustedAccountProviderPorts get ports => TrustedAccountProviderPorts(
    authState: this,
    signIn: this,
    registration: this,
    passwordReset: this,
    emailVerification: this,
  );

  Future<void> close() => _events.close();
  @override
  Stream<AccountIdentity?> watchTrustedIdentity() => _events.stream;
  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<AccountIdentity> signInWithGoogle() => throw UnimplementedError();
  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) => throw UnimplementedError();
  @override
  Future<void> requestPasswordReset(String emailAddress) async {}
  @override
  Future<AccountIdentity> refreshIdentity(String ownerId) =>
      throw UnimplementedError();
  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async =>
      VerificationDispatch.sent;
}

class _Upload implements SyncUploadTransport {
  @override
  Future<UploadReceipt> upload(OutboxChange change) =>
      throw UnimplementedError();
}

class _Pull implements SyncPullTransport {
  @override
  Future<PullPage> fetch({required String ownerId, required String? cursor}) =>
      throw UnimplementedError();
}

class _Reauthentication implements AccountReauthenticationPort {
  @override
  Future<AccountIdentity?> reauthenticateWithGoogle({
    required String ownerId,
  }) => throw UnimplementedError();

  @override
  Future<AccountIdentity> reauthenticateWithPassword({
    required String ownerId,
    required String password,
  }) => throw UnimplementedError();
}

class _SecureValues implements SecureValueStore {
  final values = <String, String>{};
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
