import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../bootstrap/trusted_admin_startup_binding.dart';
import '../config/app_config.dart';
import 'firebase_admin_credentials.dart';

class FlutterFireAuthenticatedUserPort
    implements FirebaseAuthenticatedUserPort {
  const FlutterFireAuthenticatedUserPort(this.user);
  final User user;

  @override
  Future<String?> getIdToken({required bool forceRefresh}) =>
      user.getIdToken(forceRefresh);
}

class FlutterFireAuthSdkPort implements FirebaseAuthSdkPort {
  const FlutterFireAuthSdkPort(this.auth);
  final FirebaseAuth auth;

  @override
  FirebaseAuthenticatedUserPort? get currentUser {
    final user = auth.currentUser;
    return user == null ? null : FlutterFireAuthenticatedUserPort(user);
  }
}

class FlutterFireAppCheckSdkPort implements FirebaseAppCheckSdkPort {
  const FlutterFireAppCheckSdkPort(this.appCheck);
  final FirebaseAppCheck appCheck;

  @override
  Future<String?> getToken({required bool forceRefresh}) =>
      appCheck.getToken(forceRefresh);
}

class FlutterFireAdminInitializer {
  const FlutterFireAdminInitializer({
    required this.options,
    this.providerWeb,
    this.providerAndroid = const AndroidPlayIntegrityProvider(),
    this.providerApple = const AppleAppAttestWithDeviceCheckFallbackProvider(),
    this.isWeb = kIsWeb,
  });

  final FirebaseOptions options;
  final WebProvider? providerWeb;
  final AndroidAppCheckProvider providerAndroid;
  final AppleAppCheckProvider providerApple;
  final bool isWeb;

  Future<void> initialize() async {
    if (isWeb && providerWeb == null) {
      throw StateError(
        'A production Firebase App Check web provider is required.',
      );
    }
    final app = await Firebase.initializeApp(options: options);
    await FirebaseAppCheck.instanceFor(app: app).activate(
      providerWeb: providerWeb,
      providerAndroid: providerAndroid,
      providerApple: providerApple,
    );
  }
}

/// Creates the production startup binding after `flutterfire configure` has
/// generated the platform-specific [FirebaseOptions].
TrustedAdminStartupBinding createFlutterFireAdminStartup({
  required AppConfig config,
  required FirebaseOptions firebaseOptions,
  required http.Client client,
  required DateTime Function() nowUtc,
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
  return TrustedAdminStartupBinding(
    config: config,
    initializeFirebase: initializer.initialize,
    auth: FlutterFireAuthSdkPort(FirebaseAuth.instance),
    appCheck: FlutterFireAppCheckSdkPort(FirebaseAppCheck.instance),
    client: client,
    nowUtc: nowUtc,
  );
}
