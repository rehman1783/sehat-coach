import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'core/bootstrap/activated_shell_composition.dart';
import 'core/bootstrap/trusted_consumer_runtime_composition.dart';
import 'core/bootstrap/trusted_consumer_startup_binding.dart';
import 'core/bootstrap/trusted_flutterfire_consumer_startup.dart';
import 'core/config/admin_firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/config/consumer_runtime_configuration.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/account/presentation/services/material_account_reauthentication_prompts.dart';
import 'features/account/data/decrypted_account_memory_registry.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SehatCoachConsumerApp());
}

/// Production consumer entry point. Build it with
/// `flutter build appbundle -t lib/consumer_main.dart`.
class SehatCoachConsumerApp extends StatefulWidget {
  const SehatCoachConsumerApp({super.key, this.startOverride});

  final Future<Widget> Function()? startOverride;

  @override
  State<SehatCoachConsumerApp> createState() => _SehatCoachConsumerAppState();
}

class _SehatCoachConsumerAppState extends State<SehatCoachConsumerApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final decryptedMemory = DecryptedAccountMemoryRegistry();
  http.Client? _client;

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  Future<Widget> _start() async {
    final override = widget.startOverride;
    if (override != null) return override();

    final config = AppConfig.fromEnvironment();
    const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    const googleServerClientId = String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
    );
    ConsumerRuntimeConfiguration.validate(
      config: config,
      releaseMode: kReleaseMode,
      googleServerClientId: googleServerClientId,
      googleClientId: googleClientId,
    );
    final client = _client ??= http.Client();
    final prompts = MaterialAccountReauthenticationPrompts(navigatorKey);
    final webSiteKey = const String.fromEnvironment(
      'CONSUMER_RECAPTCHA_ENTERPRISE_SITE_KEY',
    ).trim();
    final startup = createTrustedFlutterFireConsumerStartup(
      config: config,
      firebaseOptions: AdminFirebaseOptions.fromEnvironment(),
      client: client,
      nowUtc: () => DateTime.now().toUtc(),
      googleClientId: googleClientId,
      googleServerClientId: googleServerClientId,
      providerWeb: kIsWeb && webSiteKey.isNotEmpty
          ? ReCaptchaEnterpriseProvider(webSiteKey)
          : null,
      detectLocation: false,
      effects: TrustedConsumerRuntimeEffects(
        clearDecryptedMemory: decryptedMemory.clear,
        registerDecryptedMemory: decryptedMemory.register,
        onAuthenticated: _returnToRoot,
        createShell: (home) => ActivatedShellComposition(home: home),
        onReadyForAuthentication: _returnToRoot,
        onSignedOut: _returnToRoot,
        onAccountDeleted: _returnToRoot,
        onProfileCommitted: (_) => HapticFeedback.lightImpact(),
        reauthenticationPrompts: prompts.prompts,
      ),
    );
    return startup.start();
  }

  Future<void> _returnToRoot() async {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    navigatorKey: navigatorKey,
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: TrustedConsumerStartupGate(start: _start),
  );
}
