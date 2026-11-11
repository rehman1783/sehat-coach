import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../../features/account/data/firebase_account_provider.dart';
import '../../features/account/data/firebase_account_lifecycle.dart';
import '../../features/account/data/google_firebase_credential_provider.dart';
import '../../features/account/data/trusted_account_deletion_gateway.dart';
import '../../features/account/data/trusted_adult_eligibility_gateway.dart';
import '../../features/ai_logging/data/trusted_ai_backend_gateway.dart';
import '../../features/ai_logging/domain/ai_assisted_logging.dart';
import '../../features/sync/data/trusted_sync_http_transport.dart';
import '../bootstrap/trusted_account_core_composition.dart';
import '../bootstrap/trusted_consumer_runtime_composition.dart';
import '../bootstrap/trusted_firebase_account_startup.dart';
import '../bootstrap/trusted_firebase_services_startup.dart';
import '../config/app_config.dart';
import 'firebase_admin_credentials.dart';
import 'flutterfire_admin_bindings.dart';

class FlutterFireAccountServices {
  const FlutterFireAccountServices({
    required this.provider,
    required this.lifecycle,
    required this.deletion,
    required this.syncTransport,
    this.aiLogging,
    this.billing,
  });

  final TrustedAccountProviderPorts provider;
  final FirebaseAccountLifecycle lifecycle;
  final TrustedAccountDeletionGateway deletion;
  final TrustedSyncHttpTransport syncTransport;
  final AiLoggingGateway? aiLogging;
  final TrustedBillingConfiguration? billing;

  Future<void> clearOwnerSession(String ownerId) =>
      lifecycle.clearSession(ownerId);

  Future<bool> hasRecentAuthentication(String ownerId) =>
      lifecycle.hasRecentAuthentication(ownerId);

  Future<bool> requestAccountDeletion(String ownerId) =>
      deletion.requestDeletion(ownerId);

  TrustedConsumerRuntimeServices toConsumerRuntimeServices() =>
      TrustedConsumerRuntimeServices(
        provider: provider,
        clearOwnerSession: clearOwnerSession,
        deleteCloudAccount: requestAccountDeletion,
        checkRecentAuthentication: hasRecentAuthentication,
        reauthentication: lifecycle,
        syncUpload: syncTransport,
        syncPull: syncTransport,
        aiLogging: aiLogging,
        billing: billing,
      );
}

TrustedFirebaseServicesStartup<FlutterFireAccountServices>
createFlutterFireAccountServicesStartup({
  required AppConfig config,
  required FirebaseOptions firebaseOptions,
  required http.Client client,
  required DateTime Function() nowUtc,
  String? googleClientId,
  String? googleServerClientId,
  WebProvider? providerWeb,
  AndroidAppCheckProvider providerAndroid =
      const AndroidPlayIntegrityProvider(),
  AppleAppCheckProvider providerApple =
      const AppleAppAttestWithDeviceCheckFallbackProvider(),
}) {
  final initializer = FlutterFireAdminInitializer(
    options: firebaseOptions,
    providerWeb: providerWeb,
    providerAndroid: providerAndroid,
    providerApple: providerApple,
  );
  return TrustedFirebaseServicesStartup(
    config: config,
    initializeFirebase: initializer.initialize,
    buildServices:
        (
          eligibilityEndpoint,
          deletionEndpoint,
          syncUploadEndpoint,
          syncPullEndpoint,
        ) {
          final auth = FirebaseAuth.instance;
          final authPort = FlutterFireAuthSdkPort(auth);
          final appCheckPort = FlutterFireAppCheckSdkPort(
            FirebaseAppCheck.instance,
          );
          final idTokens = FirebaseAuthIdTokenAdapter(authPort);
          final appCheckTokens = FirebaseAppCheckTokenAdapter(appCheckPort);
          final google = GoogleFirebaseCredentialProvider(
            clientId: googleClientId,
            serverClientId: googleServerClientId,
          );
          final eligibility = TrustedAdultEligibilityGateway(
            endpoint: eligibilityEndpoint,
            client: client,
            idTokens: idTokens,
            appCheckTokens: appCheckTokens,
          );
          final accountProvider = FirebaseAccountProvider(
            auth: auth,
            registerAdultEligibility: eligibility.register,
            googleCredential: google.call,
          );
          final provider = TrustedAccountProviderPorts(
            authState: accountProvider,
            signIn: accountProvider,
            registration: accountProvider,
            passwordReset: accountProvider,
            emailVerification: accountProvider,
            adultEligibilityConfirmation: accountProvider,
            signOutPending: accountProvider.signOutPendingSession,
          );
          final lifecycle = FirebaseAccountLifecycle(
            auth: FlutterFireLifecycleAuthPort(auth),
            googleCredential: google.call,
            nowUtc: nowUtc,
          );
          final deletion = TrustedAccountDeletionGateway(
            endpoint: deletionEndpoint,
            client: client,
            idTokens: idTokens,
            appCheckTokens: appCheckTokens,
          );
          final syncTransport = TrustedSyncHttpTransport(
            uploadEndpoint: syncUploadEndpoint,
            pullEndpoint: syncPullEndpoint,
            client: client,
            idTokens: idTokens,
            appCheckTokens: appCheckTokens,
          );
          final aiEndpoint = config.aiBackendEndpoint;
          final aiLogging = aiEndpoint == null
              ? null
              : TrustedAiBackendGateway(
                  endpoint: aiEndpoint,
                  client: client,
                  idTokens: idTokens,
                  appCheckTokens: appCheckTokens,
                );
          final billingEndpoint = config.billingBackendEndpoint;
          final catalogEndpoint = config.entitlementCatalogEndpoint;
          final billing = billingEndpoint != null && catalogEndpoint != null
              ? TrustedBillingConfiguration(
                  backendEndpoint: billingEndpoint,
                  catalogEndpoint: catalogEndpoint,
                  stateEndpoint: config.billingStateEndpoint,
                  httpClient: client,
                  idTokens: idTokens,
                  appCheckTokens: appCheckTokens,
                )
              : null;
          return FlutterFireAccountServices(
            provider: provider,
            lifecycle: lifecycle,
            deletion: deletion,
            syncTransport: syncTransport,
            aiLogging: aiLogging,
            billing: billing,
          );
        },
  );
}

TrustedFirebaseAccountStartup createFlutterFireAccountStartup({
  required AppConfig config,
  required FirebaseOptions firebaseOptions,
  required http.Client client,
  String? googleClientId,
  String? googleServerClientId,
  WebProvider? providerWeb,
  AndroidAppCheckProvider providerAndroid =
      const AndroidPlayIntegrityProvider(),
  AppleAppCheckProvider providerApple =
      const AppleAppAttestWithDeviceCheckFallbackProvider(),
}) {
  final initializer = FlutterFireAdminInitializer(
    options: firebaseOptions,
    providerWeb: providerWeb,
    providerAndroid: providerAndroid,
    providerApple: providerApple,
  );
  return TrustedFirebaseAccountStartup(
    config: config,
    initializeFirebase: initializer.initialize,
    buildProvider: (endpoint) {
      final auth = FirebaseAuth.instance;
      final idTokens = FirebaseAuthIdTokenAdapter(FlutterFireAuthSdkPort(auth));
      final appCheckTokens = FirebaseAppCheckTokenAdapter(
        FlutterFireAppCheckSdkPort(FirebaseAppCheck.instance),
      );
      final eligibility = TrustedAdultEligibilityGateway(
        endpoint: endpoint,
        client: client,
        idTokens: idTokens,
        appCheckTokens: appCheckTokens,
      );
      final google = GoogleFirebaseCredentialProvider(
        clientId: googleClientId,
        serverClientId: googleServerClientId,
      );
      final provider = FirebaseAccountProvider(
        auth: auth,
        registerAdultEligibility: eligibility.register,
        googleCredential: google.call,
      );
      return TrustedAccountProviderPorts(
        authState: provider,
        signIn: provider,
        registration: provider,
        passwordReset: provider,
        emailVerification: provider,
        adultEligibilityConfirmation: provider,
        signOutPending: provider.signOutPendingSession,
      );
    },
  );
}
