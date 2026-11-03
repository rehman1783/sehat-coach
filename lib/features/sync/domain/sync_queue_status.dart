class SyncQueueStatus {
  const SyncQueueStatus({
    required this.pendingCount,
    required this.failedCount,
    required this.oldestPendingAt,
  });

  final int pendingCount;
  final int failedCount;
  final DateTime? oldestPendingAt;

  bool get isSynced => pendingCount == 0;
  bool get needsAttention => failedCount > 0;
}

abstract interface class SyncQueueStatusRepository {
  Future<SyncQueueStatus> read(String ownerId);
  Stream<SyncQueueStatus> watch(String ownerId);
}
