import 'dart:convert';

import '../domain/local_change_store.dart';

/// Single-isolate development adapter. Never use it for durable health records.
class MemoryLocalChangeStore implements LocalChangeStore {
  final Map<String, Map<String, LocalRecord>> _records = {};
  final Map<String, Map<String, OutboxChange>> _pending = {};
  final Map<String, Map<String, OutboxChange>> _operations = {};

  void _requireId(String value, String name) {
    if (value.trim().isEmpty) throw ArgumentError.value(value, name);
  }

  Map<String, Object?> _snapshot(Map<String, Object?> value) =>
      (jsonDecode(jsonEncode(value)) as Map).cast<String, Object?>();

  OutboxChange _copyChange(OutboxChange value) => OutboxChange(
    ownerId: value.ownerId,
    operationId: value.operationId,
    entityType: value.entityType,
    entityKey: value.entityKey,
    baseRevision: value.baseRevision,
    newRevision: value.newRevision,
    payload: _snapshot(value.payload),
    attemptCount: value.attemptCount,
    lastError: value.lastError,
  );

  @override
  Future<OutboxChange> commit({
    required String ownerId,
    required String operationId,
    required String entityType,
    required String entityKey,
    required int expectedRevision,
    required Map<String, Object?> payload,
  }) async {
    _requireId(ownerId, 'ownerId');
    _requireId(operationId, 'operationId');
    _requireId(entityType, 'entityType');
    _requireId(entityKey, 'entityKey');
    if (expectedRevision < 0) throw ArgumentError.value(expectedRevision);
    final safePayload = _snapshot(payload); // Validate before either write.
    final priorOperation = _operations[ownerId]?[operationId];
    if (priorOperation != null) {
      if (priorOperation.entityType == entityType &&
          priorOperation.entityKey == entityKey &&
          priorOperation.baseRevision == expectedRevision &&
          jsonEncode(priorOperation.payload) == jsonEncode(safePayload)) {
        return _copyChange(priorOperation);
      }
      throw const ReusedOperationId();
    }
    final recordKey = '$entityType\u0000$entityKey';
    final prior = _records[ownerId]?[recordKey];
    if ((prior?.revision ?? 0) != expectedRevision) {
      throw const StaleLocalRevision();
    }
    final change = OutboxChange(
      ownerId: ownerId,
      operationId: operationId,
      entityType: entityType,
      entityKey: entityKey,
      baseRevision: expectedRevision,
      newRevision: expectedRevision + 1,
      payload: safePayload,
    );
    // No awaits between the two mutations: atomic in this single isolate.
    _records.putIfAbsent(ownerId, () => {})[recordKey] = LocalRecord(
      ownerId: ownerId,
      entityType: entityType,
      entityKey: entityKey,
      revision: change.newRevision,
      payload: safePayload,
    );
    _pending.putIfAbsent(ownerId, () => {})[operationId] = change;
    _operations.putIfAbsent(ownerId, () => {})[operationId] = change;
    return _copyChange(change);
  }

  @override
  Future<LocalRecord?> read(
    String ownerId,
    String entityType,
    String entityKey,
  ) async {
    _requireId(ownerId, 'ownerId');
    _requireId(entityType, 'entityType');
    _requireId(entityKey, 'entityKey');
    final record = _records[ownerId]?['$entityType\u0000$entityKey'];
    if (record == null) return null;
    return LocalRecord(
      ownerId: ownerId,
      entityType: entityType,
      entityKey: entityKey,
      revision: record.revision,
      payload: _snapshot(record.payload),
    );
  }

  @override
  Future<List<LocalRecord>> listRecords(
    String ownerId,
    String entityType,
  ) async {
    _requireId(ownerId, 'ownerId');
    _requireId(entityType, 'entityType');
    final values =
        (_records[ownerId]?.values ?? <LocalRecord>[])
            .where((record) => record.entityType == entityType)
            .map(
              (record) => LocalRecord(
                ownerId: record.ownerId,
                entityType: record.entityType,
                entityKey: record.entityKey,
                revision: record.revision,
                payload: _snapshot(record.payload),
              ),
            )
            .toList()
          ..sort((a, b) => a.entityKey.compareTo(b.entityKey));
    return List.unmodifiable(values);
  }

  @override
  Future<List<OutboxChange>> pending(String ownerId) async {
    _requireId(ownerId, 'ownerId');
    return [
      for (final change in _pending[ownerId]?.values ?? <OutboxChange>[])
        _copyChange(change),
    ];
  }

  @override
  Future<void> recordFailure(
    String ownerId,
    String operationId,
    String errorCode,
  ) async {
    _requireId(ownerId, 'ownerId');
    _requireId(operationId, 'operationId');
    _requireId(errorCode, 'errorCode');
    final existing = _pending[ownerId]?[operationId];
    if (existing == null) throw StateError('Pending operation not found');
    final updated = OutboxChange(
      ownerId: existing.ownerId,
      operationId: existing.operationId,
      entityType: existing.entityType,
      entityKey: existing.entityKey,
      baseRevision: existing.baseRevision,
      newRevision: existing.newRevision,
      payload: _snapshot(existing.payload),
      attemptCount: existing.attemptCount + 1,
      lastError: errorCode,
    );
    _pending[ownerId]![operationId] = updated;
    _operations[ownerId]![operationId] = updated;
  }

  @override
  Future<bool> acknowledge(String ownerId, String operationId) async {
    _requireId(ownerId, 'ownerId');
    _requireId(operationId, 'operationId');
    return _pending[ownerId]?.remove(operationId) != null;
  }
}
