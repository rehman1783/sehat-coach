import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/bootstrap/trusted_admin_startup_binding.dart';
import 'core/config/admin_firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/services/flutterfire_admin_bindings.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SehatCoachAdminApp());
}

class SehatCoachAdminApp extends StatefulWidget {
  const SehatCoachAdminApp({super.key});

  @override
  State<SehatCoachAdminApp> createState() => _SehatCoachAdminAppState();
}

class _SehatCoachAdminAppState extends State<SehatCoachAdminApp> {
  late final http.Client _client = http.Client();

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<Widget> _start() async {
    final config = AppConfig.fromEnvironment();
    final firebaseOptions = AdminFirebaseOptions.fromEnvironment();
    final webSiteKey = const String.fromEnvironment(
      'ADMIN_RECAPTCHA_ENTERPRISE_SITE_KEY',
    ).trim();
    final binding = createFlutterFireAdminStartup(
      config: config,
      firebaseOptions: firebaseOptions,
      client: _client,
      nowUtc: () => DateTime.now().toUtc(),
      providerWeb: kIsWeb && webSiteKey.isNotEmpty
          ? ReCaptchaEnterpriseProvider(webSiteKey)
          : null,
    );
    return (await binding.start()).build();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sehat Coach Admin',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home: TrustedAdminStartupGate(start: _start),
  );
}
