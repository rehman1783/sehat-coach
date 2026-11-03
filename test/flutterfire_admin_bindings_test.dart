import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/services/flutterfire_admin_bindings.dart';

void main() {
  test('web initialization requires an explicit App Check provider', () async {
    final initializer = FlutterFireAdminInitializer(
      options: _options,
      isWeb: true,
    );

    await expectLater(initializer.initialize(), throwsA(isA<StateError>()));
  });

  test('native initializer defaults to Play Integrity and Apple fallback', () {
    final initializer = FlutterFireAdminInitializer(
      options: _options,
      isWeb: false,
    );

    expect(initializer.providerAndroid, isA<AndroidPlayIntegrityProvider>());
    expect(
      initializer.providerApple,
      isA<AppleAppAttestWithDeviceCheckFallbackProvider>(),
    );
  });
}

const _options = FirebaseOptions(
  apiKey: 'test-api-key',
  appId: 'test-app-id',
  messagingSenderId: 'test-sender',
  projectId: 'test-project',
);
