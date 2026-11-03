import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/config/app_config.dart';
import 'core/bootstrap/application_startup.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(
    DevicePreview(
      enabled: config.enableDevicePreview,
      builder: (context) => SehatCoachApp(config: config),
    ),
  );
}

class SehatCoachApp extends StatelessWidget {
  const SehatCoachApp({super.key, required this.config, this.trustedRoot});

  final AppConfig config;
  final Widget? trustedRoot;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      home: ApplicationStartup(
        config: config,
        preview: const SplashScreen(),
        trustedRoot: trustedRoot,
      ),
    );
  }
}
