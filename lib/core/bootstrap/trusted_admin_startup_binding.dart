import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/firebase_admin_credentials.dart';
import 'trusted_admin_bootstrap.dart';

/// Initializes the platform Firebase SDK once, then constructs the fail-closed
/// trusted admin graph. Platform code supplies the real SDK facade instances.
class TrustedAdminStartupBinding {
  TrustedAdminStartupBinding({
    required this.config,
    required this.initializeFirebase,
    required this.auth,
    required this.appCheck,
    required this.client,
    required this.nowUtc,
  });

  final AppConfig config;
  final Future<void> Function() initializeFirebase;
  final FirebaseAuthSdkPort auth;
  final FirebaseAppCheckSdkPort appCheck;
  final http.Client client;
  final DateTime Function() nowUtc;
  Future<TrustedAdminBootstrap>? _starting;

  Future<TrustedAdminBootstrap> start() {
    final active = _starting;
    if (active != null) return active;
    late final Future<TrustedAdminBootstrap> future;
    future = _start().onError((error, stackTrace) {
      if (identical(_starting, future)) _starting = null;
      Error.throwWithStackTrace(
        error ?? StateError('Unknown admin startup failure'),
        stackTrace,
      );
    });
    _starting = future;
    return future;
  }

  Widget build() =>
      TrustedAdminStartupGate(start: () async => (await start()).build());

  Future<TrustedAdminBootstrap> _start() async {
    _validateConfiguration();
    await initializeFirebase();
    return TrustedAdminBootstrap(
      config: config,
      client: client,
      idTokens: FirebaseAuthIdTokenAdapter(auth),
      appCheckTokens: FirebaseAppCheckTokenAdapter(appCheck),
      nowUtc: nowUtc,
    );
  }

  void _validateConfiguration() {
    final endpoint = config.adminBackendEndpoint;
    if (endpoint == null) {
      throw StateError('ADMIN_BACKEND_URL is required for trusted admin.');
    }
    if (endpoint.scheme != 'https' ||
        endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.hasQuery ||
        endpoint.hasFragment) {
      throw StateError('ADMIN_BACKEND_URL must be a trusted HTTPS endpoint.');
    }
  }
}

enum TrustedAdminStartupStatus { loading, ready, failed }

class TrustedAdminStartupGate extends StatefulWidget {
  const TrustedAdminStartupGate({super.key, required this.start});

  final Future<Widget> Function() start;

  @override
  State<TrustedAdminStartupGate> createState() =>
      _TrustedAdminStartupGateState();
}

class _TrustedAdminStartupGateState extends State<TrustedAdminStartupGate> {
  TrustedAdminStartupStatus status = TrustedAdminStartupStatus.loading;
  Widget? destination;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      status = TrustedAdminStartupStatus.loading;
      destination = null;
    });
    try {
      final value = await widget.start();
      if (!mounted) return;
      setState(() {
        destination = value;
        status = TrustedAdminStartupStatus.ready;
      });
    } on Object {
      if (!mounted) return;
      setState(() => status = TrustedAdminStartupStatus.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == TrustedAdminStartupStatus.ready && destination != null) {
      return destination!;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('SEHAT COACH ADMIN')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: status == TrustedAdminStartupStatus.loading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        semanticsLabel: 'Starting secure admin workspace',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verifying secure staff access…',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        liveRegion: true,
                        label: 'Error: Secure admin workspace is temporarily unavailable.',
                        excludeSemantics: true,
                        child: Text(
                          'Secure admin workspace is temporarily unavailable.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _start,
                        child: const Text('TRY AGAIN'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
