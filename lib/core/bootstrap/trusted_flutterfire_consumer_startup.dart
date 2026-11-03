import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/sync/data/platform_connectivity.dart';
import '../config/app_config.dart';
import '../config/admin_firebase_options.dart';
import '../data/local/flutter_secure_account_key_vault.dart';
import '../data/local/platform_application_data_directory.dart';
import '../services/flutterfire_account_bindings.dart';
import 'trusted_consumer_runtime_composition.dart';
import 'trusted_consumer_startup_binding.dart';

/// Creates the production consumer startup graph from concrete platform
/// adapters. Construction is lazy: Firebase and private storage are untouched
/// until the returned binding is started by its fail-closed gate.
TrustedConsumerStartupBinding<FlutterFireAccountServices>
createTrustedFlutterFireConsumerStartup({
  required AppConfig config,
  required FirebaseOptions firebaseOptions,
  required http.Client client,
  required DateTime Function() nowUtc,
  required TrustedConsumerRuntimeEffects effects,
  String? googleClientId,
  String? googleServerClientId,
  WebProvider? providerWeb,
  AndroidAppCheckProvider providerAndroid =
      const AndroidPlayIntegrityProvider(),
  AppleAppCheckProvider providerApple =
      const AppleAppAttestWithDeviceCheckFallbackProvider(),
  PlatformApplicationDataDirectory? applicationData,
  PlatformConnectivity? connectivity,
  SecureValueStore? secureValues,
  AppLanguage initialLanguage = AppLanguage.english,
  bool detectLocation = false,
  Widget? loading,
  Widget? initialError,
}) {
  final accountServices = createFlutterFireAccountServicesStartup(
    config: config,
    firebaseOptions: firebaseOptions,
    client: client,
    nowUtc: nowUtc,
    googleClientId: googleClientId,
    googleServerClientId: googleServerClientId,
    providerWeb: providerWeb,
    providerAndroid: providerAndroid,
    providerApple: providerApple,
  );
  final directory = applicationData ?? PlatformApplicationDataDirectory();
  final network = connectivity ?? const PlatformConnectivity();

  return TrustedConsumerStartupBinding<FlutterFireAccountServices>(
    startServices: accountServices.start,
    resolveApplicationDataDirectory: directory.resolve,
    buildRoot: (applicationDataDirectory, services) =>
        composeTrustedConsumerRuntime(
          applicationDataDirectory: applicationDataDirectory,
          services: services.toConsumerRuntimeServices(),
          effects: effects,
          connectivityCheck: network.hasNetworkLink,
          networkLink: network.watchNetworkLink(),
          secureValues: secureValues,
          storageScope: trustedFirebaseStorageScope(config, firebaseOptions),
          legacyStorageScopes: ['firebase:${firebaseOptions.projectId}'],
          initialLanguage: initialLanguage,
          detectLocation: detectLocation,
          loading: loading,
          initialError: initialError,
        ).build(),
  );
}

String trustedFirebaseStorageScope(
  AppConfig config,
  FirebaseOptions firebaseOptions,
) =>
    'firebase:${validateFirebaseProjectId(firebaseOptions.projectId)}:environment:${config.environment.name}';
