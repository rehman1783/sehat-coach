import 'dart:io';

import 'package:flutter/material.dart';

typedef TrustedConsumerRootBuilder<T> = Widget Function(
  Directory applicationDataDirectory,
  T services,
);

/// Completes trusted platform startup before any account UI or local health
/// data is mounted.
class TrustedConsumerStartupBinding<T> {
  TrustedConsumerStartupBinding({
    required this.startServices,
    required this.resolveApplicationDataDirectory,
    required this.buildRoot,
  });

  final Future<T> Function() startServices;
  final Future<Directory> Function() resolveApplicationDataDirectory;
  final TrustedConsumerRootBuilder<T> buildRoot;

  Future<Widget>? _inFlight;
  Widget? _ready;

  Future<Widget> start() {
    final ready = _ready;
    if (ready != null) return Future.value(ready);
    return _inFlight ??= _startOnce();
  }

  Future<Widget> _startOnce() async {
    try {
      // Trusted service configuration is validated before local storage is
      // resolved, preventing a misconfigured build from touching health data.
      final services = await startServices();
      final directory = await resolveApplicationDataDirectory();
      final root = buildRoot(directory, services);
      _ready = root;
      return root;
    } catch (_) {
      _inFlight = null;
      rethrow;
    }
  }

  Widget build() => TrustedConsumerStartupGate(start: start);
}

enum TrustedConsumerStartupStatus { loading, ready, failed }

class TrustedConsumerStartupGate extends StatefulWidget {
  const TrustedConsumerStartupGate({super.key, required this.start});

  final Future<Widget> Function() start;

  @override
  State<TrustedConsumerStartupGate> createState() =>
      _TrustedConsumerStartupGateState();
}

class _TrustedConsumerStartupGateState
    extends State<TrustedConsumerStartupGate> {
  TrustedConsumerStartupStatus status = TrustedConsumerStartupStatus.loading;
  Widget? destination;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      status = TrustedConsumerStartupStatus.loading;
      destination = null;
    });
    try {
      final value = await widget.start();
      if (!mounted) return;
      setState(() {
        destination = value;
        status = TrustedConsumerStartupStatus.ready;
      });
    } on Object {
      if (!mounted) return;
      setState(() => status = TrustedConsumerStartupStatus.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == TrustedConsumerStartupStatus.ready && destination != null) {
      return destination!;
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: status == TrustedConsumerStartupStatus.loading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        semanticsLabel: 'Starting secure account services',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Preparing your secure account…',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        liveRegion: true,
                        label: 'Error: Secure account services are temporarily unavailable.',
                        excludeSemantics: true,
                        child: const Text(
                          'Secure account services are temporarily unavailable. No health data has been opened.',
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
