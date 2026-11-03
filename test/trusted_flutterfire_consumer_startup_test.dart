import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sehat_coach/core/bootstrap/activated_shell_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_consumer_runtime_composition.dart';
import 'package:sehat_coach/core/bootstrap/trusted_consumer_startup_binding.dart';
import 'package:sehat_coach/core/bootstrap/trusted_flutterfire_consumer_startup.dart';
import 'package:sehat_coach/core/config/app_config.dart';

void main() {
  test('storage scope isolates environments sharing one Firebase project', () {
    const options = FirebaseOptions(
      apiKey: 'public-api-key',
      appId: 'app-id',
      messagingSenderId: 'sender-id',
      projectId: 'shared-project',
    );
    const staging = AppConfig(
      environment: AppEnvironment.staging,
      enableDevicePreview: false,
    );
    const production = AppConfig(
      environment: AppEnvironment.production,
      enableDevicePreview: false,
    );

    expect(
      trustedFirebaseStorageScope(staging, options),
      isNot(trustedFirebaseStorageScope(production, options)),
    );
  });

  test('storage scope rejects a malformed Firebase project identity', () {
    const config = AppConfig(
      environment: AppEnvironment.production,
      enableDevicePreview: false,
    );
    const options = FirebaseOptions(
      apiKey: 'public-api-key',
      appId: 'app-id',
      messagingSenderId: 'sender-id',
      projectId: 'invalid project',
    );

    expect(
      () => trustedFirebaseStorageScope(config, options),
      throwsStateError,
    );
  });

  test('factory is lazy and exposes the fail-closed consumer gate', () {
    final client = http.Client();
    addTearDown(client.close);
    final startup = createTrustedFlutterFireConsumerStartup(
      config: AppConfig(
        environment: AppEnvironment.staging,
        enableDevicePreview: false,
        enableTrustedAccountRuntime: true,
        adultEligibilityEndpoint: Uri.https('api.example.test', '/eligibility'),
        accountDeletionEndpoint: Uri.https('api.example.test', '/deletion'),
        syncUploadEndpoint: Uri.https('api.example.test', '/sync/upload'),
        syncPullEndpoint: Uri.https('api.example.test', '/sync/pull'),
      ),
      firebaseOptions: const FirebaseOptions(
        apiKey: 'public-api-key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
      client: client,
      nowUtc: () => DateTime.utc(2026, 10, 27),
      effects: TrustedConsumerRuntimeEffects(
        clearDecryptedMemory: (_) async {},
        onAuthenticated: () async {},
        createShell: (home) => ActivatedShellComposition(home: home),
        onReadyForAuthentication: () async {},
        onSignedOut: () async {},
        onAccountDeleted: () async {},
        onProfileCommitted: (_) async {},
      ),
      detectLocation: false,
    );

    // Building the gate must not initialize Firebase, query connectivity or
    // resolve/create the private application-data directory.
    expect(startup.build(), isA<TrustedConsumerStartupGate>());
  });
}
