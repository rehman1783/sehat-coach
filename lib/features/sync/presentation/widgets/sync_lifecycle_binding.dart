import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/sync_lifecycle_coordinator.dart';

typedef SyncLifecycleErrorListener = void Function(
  Object error,
  StackTrace stackTrace,
);

/// Attaches an authenticated owner's sync triggers to Flutter lifecycle.
///
/// The coordinator owns connectivity listening and single-flight execution.
/// This widget adds foreground recovery only while its authenticated subtree
/// exists, and stops connectivity delivery when that subtree is removed.
class SyncLifecycleBinding extends StatefulWidget {
  const SyncLifecycleBinding({
    super.key,
    required this.coordinator,
    required this.child,
    this.onError,
  });

  final SyncLifecycleCoordinator coordinator;
  final Widget child;
  final SyncLifecycleErrorListener? onError;

  @override
  State<SyncLifecycleBinding> createState() => _SyncLifecycleBindingState();
}

class _SyncLifecycleBindingState extends State<SyncLifecycleBinding>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.coordinator.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_resumeSafely());
  }

  Future<void> _resumeSafely() async {
    try {
      await widget.coordinator.onAppResumed();
    } on Object catch (error, stackTrace) {
      widget.onError?.call(error, stackTrace);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.coordinator.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
