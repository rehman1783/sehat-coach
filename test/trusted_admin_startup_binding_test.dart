import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sehat_coach/core/bootstrap/trusted_admin_startup_binding.dart';
import 'package:sehat_coach/core/config/app_config.dart';
import 'package:sehat_coach/core/services/firebase_admin_credentials.dart';

void main() {
  test(
    'concurrent startup shares Firebase initialization and bootstrap',
    () async {
      var initializations = 0;
      final gate = Completer<void>();
      final binding = TrustedAdminStartupBinding(
        config: _config(Uri.parse('https://api.example.com/admin')),
        initializeFirebase: () async {
          initializations++;
          await gate.future;
        },
        auth: _Auth(_User()),
        appCheck: _AppCheck(),
        client: MockClient((_) async => http.Response('{}', 500)),
        nowUtc: () => DateTime.utc(2026, 10, 26),
      );

      final first = binding.start();
      final second = binding.start();
      expect(identical(first, second), isTrue);
      gate.complete();
      final values = await Future.wait([first, second]);

      expect(initializations, 1);
      expect(identical(values[0], values[1]), isTrue);
    },
  );

  test('invalid configuration fails before Firebase initialization', () async {
    var initialized = false;
    final binding = TrustedAdminStartupBinding(
      config: _config(null),
      initializeFirebase: () async => initialized = true,
      auth: _Auth(_User()),
      appCheck: _AppCheck(),
      client: MockClient((_) async => http.Response('{}', 200)),
      nowUtc: () => DateTime.utc(2026, 10, 26),
    );

    await expectLater(binding.start(), throwsA(isA<StateError>()));
    expect(initialized, isFalse);
  });
}

AppConfig _config(Uri? endpoint) => AppConfig(
  environment: AppEnvironment.production,
  enableDevicePreview: false,
  enableTrustedAccountRuntime: true,
  adminBackendEndpoint: endpoint,
);

class _Auth implements FirebaseAuthSdkPort {
  _Auth(this.currentUser);
  @override
  final FirebaseAuthenticatedUserPort? currentUser;
}

class _User implements FirebaseAuthenticatedUserPort {
  @override
  Future<String?> getIdToken({required bool forceRefresh}) async => 'id-token';
}

class _AppCheck implements FirebaseAppCheckSdkPort {
  @override
  Future<String?> getToken({required bool forceRefresh}) async => 'app-check';
}
