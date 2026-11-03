class LocalRecord {
  const LocalRecord({
    required this.ownerId,
    required this.entityType,
    required this.entityKey,
    required this.revision,
    required this.payload,
  });

  final String ownerId;
  final String entityType;
  final String entityKey;
  final int revision;
  final Map<String, Object?> payload;
}

class OutboxChange {
  const OutboxChange({
    required this.ownerId,
    required this.operationId,
    required this.entityType,
    required this.entityKey,
    required this.baseRevision,
    required this.newRevision,
    required this.payload,
    this.attemptCount = 0,
    this.lastError,
  });

  final String ownerId;
  final String operationId;
  final String entityType;
  final String entityKey;
  final int baseRevision;
  final int newRevision;
  final Map<String, Object?> payload;
  final int attemptCount;
  final String? lastError;
}

class StaleLocalRevision implements Exception {
  const StaleLocalRevision();
}

class ReusedOperationId implements Exception {
  const ReusedOperationId();
}

/// Durable implementations must commit record and outbox in one transaction.
/// Only explicit server acknowledgement may remove a pending operation.
abstract interface class LocalChangeStore {
  Future<OutboxChange> commit({
    required String ownerId,
    required String operationId,
    required String entityType,
    required String entityKey,
    required int expectedRevision,
    required Map<String, Object?> payload,
  });

  Future<LocalRecord?> read(
    String ownerId,
    String entityType,
    String entityKey,
  );
  Future<List<LocalRecord>> listRecords(String ownerId, String entityType);
  Future<List<OutboxChange>> pending(String ownerId);
  Future<void> recordFailure(
    String ownerId,
    String operationId,
    String errorCode,
  );
  Future<bool> acknowledge(String ownerId, String operationId);
}
