import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sehat_coach/core/bootstrap/activated_home_composition.dart';
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_account_core_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_consumer_runtime_composition.dart';
import 'package:sehat_coach/core/data/local/flutter_secure_account_key_vault.dart';
import 'package:sehat_coach/core/services/trusted_backend_tokens.dart';
import 'package:sehat_coach/features/account/data/decrypted_account_memory_registry.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/auth_state_reconciliation_coordinator.dart';
import 'package:sehat_coach/features/account/domain/auth_state_stream_binding.dart';
import 'package:sehat_coach/features/account/domain/reauthenticate_account_use_cases.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/entitlements/data/flutter_play_billing_adapter.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_shell_screen.dart';
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

  test(
    'wires owner-bound billing and tears down Play listener on auth loss',
    () async {
      final directory = await Directory.systemTemp.createTemp('consumer-bill-');
      final provider = _Provider();
      final secureValues = _SecureValues();
      final play = _PlayClient();
      final memory = DecryptedAccountMemoryRegistry();
      final link = StreamController<bool>();
      final httpClient = MockClient((_) async => http.Response('{}', 500));
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
          billing: TrustedBillingConfiguration(
            backendEndpoint: Uri.https('api.example.test', '/billing'),
            catalogEndpoint: Uri.https('api.example.test', '/catalog'),
            stateEndpoint: Uri.https('api.example.test', '/state'),
            httpClient: httpClient,
            idTokens: const _IdTokens(),
            appCheckTokens: const _AppCheckTokens(),
            playClient: play,
            idempotencyKeys: () => 'key-1',
          ),
        ),
        effects: TrustedConsumerRuntimeEffects(
          clearDecryptedMemory: memory.clear,
          registerDecryptedMemory: memory.register,
          onAuthenticated: () async {},
          createShell: (home) => ActivatedShellComposition(home: home),
          onReadyForAuthentication: () async {},
          onSignedOut: () async {},
          onAccountDeleted: () async {},
          onProfileCommitted: (_) async {},
        ),
        connectivityCheck: () async => true,
        networkLink: link.stream,
        secureValues: secureValues,
        detectLocation: false,
      );
      addTearDown(() async {
        httpClient.close();
        unawaited(link.close());
        unawaited(provider.close());
        await play.close();
        await bootstrap.core.runtime.databaseService.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      bootstrap.build();
      expect(play.listenCount, 0);

      final activated = Completer<void>();
      final signedOut = Completer<void>();
      bootstrap.core.authState.start(
        onStatus: (status) {
          if (status == AuthStateReconciliationStatus.activated &&
              !activated.isCompleted) {
            activated.complete();
          }
          if (status == AuthStateReconciliationStatus.noIdentity &&
              !signedOut.isCompleted) {
            signedOut.complete();
          }
        },
        onError: (error, stackTrace) =>
            Error.throwWithStackTrace(error, stackTrace),
      );
      addTearDown(bootstrap.core.authState.stop);
      provider.emit(
        AccountIdentity(
          uid: 'owner-a',
          emailVerified: true,
          adultEligible: true,
          linkedProviders: const {AccountProvider.password},
        ),
      );
      await activated.future;

      final home = ActivatedHomeComposition(
        features: bootstrap.core.features,
        profile: OnboardingState(city: 'Islamabad'),
      );
      final shell =
          bootstrap.application.createShell(home).build()
              as AuthenticatedShellScreen;
      final entitlement = await shell.createEntitlements!();
      final paywall = await shell.createPaywall!(entitlement);

      expect(entitlement.ownerId, 'owner-a');
      expect(play.listenCount, 1);
      expect(play.cancelled, isFalse);
      expect(memory.countFor('owner-a'), 1);

      link.add(false);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(entitlement.isOnline.value, isFalse);
      expect(paywall.isOnline.value, isFalse);

      link.add(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(entitlement.isOnline.value, isTrue);
      expect(paywall.isOnline.value, isTrue);

      provider.emit(null);
      await signedOut.future;

      expect(play.cancelled, isTrue);
      expect(memory.countFor('owner-a'), 0);
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

  void emit(AccountIdentity? identity) => _events.add(identity);

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

class _PlayClient implements InAppPurchaseClient {
  int listenCount = 0;
  bool cancelled = false;
  late final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast(
        onListen: () => listenCount++,
        onCancel: () => cancelled = true,
      );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam}) async =>
      false;

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async =>
      false;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      throw UnimplementedError();

  @override
  Future<void> restorePurchases() async {}

  Future<void> close() => _controller.close();
}

class _IdTokens implements FirebaseIdTokenProvider {
  const _IdTokens();
  @override
  Future<String> freshIdToken() async => 'id-token';
}

class _AppCheckTokens implements FirebaseAppCheckTokenProvider {
  const _AppCheckTokens();
  @override
  Future<String> appCheckToken() async => 'appcheck-token';
}
