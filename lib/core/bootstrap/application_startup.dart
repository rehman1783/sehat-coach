import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// Selects the executable root without allowing production to fall back to a
/// public preview when trusted identity dependencies are absent.
class ApplicationStartup extends StatelessWidget {
  const ApplicationStartup({
    super.key,
    required this.config,
    required this.preview,
    this.trustedRoot,
  });

  final AppConfig config;
  final Widget preview;
  final Widget? trustedRoot;

  @override
  Widget build(BuildContext context) {
    if (!config.requiresTrustedAccountRuntime) return preview;
    return trustedRoot ?? const TrustedRuntimeUnavailableScreen();
  }
}

class TrustedRuntimeUnavailableScreen extends StatelessWidget {
  const TrustedRuntimeUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            liveRegion: true,
            label: 'Error: Secure account services are not configured',
            excludeSemantics: true,
            child: const Text(
              'Secure account services are not configured for this build. No health data has been opened.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );
}
