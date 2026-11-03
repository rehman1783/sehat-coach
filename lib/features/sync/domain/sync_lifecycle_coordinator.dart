import 'sync_cycle_coordinator.dart';

abstract interface class SyncLifecycleCoordinator {
  void start();

  Future<SyncCycleResult?> onAppResumed();

  Future<void> stop();
}
