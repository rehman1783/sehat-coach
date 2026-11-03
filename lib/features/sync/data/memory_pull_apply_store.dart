import 'dart:convert';

import '../domain/sync_pull_coordinator.dart';

class PulledRecord {
  const PulledRecord({
    required this.revision,
    required this.deleted,
    required this.payload,
  });

  final int revision;
  final bool deleted;
  final Map<String, Object?> payload;
}

/// Single-isolate test/development adapter. Not durable storage.
class MemoryPullApplyStore implements PullApplyStore {
  final Map<String, String?> _cursors = {};
  final Map<String, Map<String, PulledRecord>> _records = {};
  final Map<String, Set<String>> _pendingEntities = {};

  Map<String, Object?> _snapshot(Map<String, Object?> value) =>
      (jsonDecode(jsonEncode(value)) as Map).cast<String, Object?>();

  String _recordKey(String entityType, String entityKey) =>
      '$entityType\u0000$entityKey';

  @override
  Future<String?> cursor(String ownerId) async => _cursors[ownerId];

  @override
  Future<void> applyPage(String ownerId, PullPage page) async {
    if (_cursors[ownerId] != page.requestCursor) {
      throw StateError('Cursor changed before apply');
    }
    final prepared = <String, PulledRecord>{};
    final existing = _records[ownerId] ?? const <String, PulledRecord>{};
    for (final change in page.changes) {
      if (change.ownerId != ownerId) throw StateError('Owner mismatch');
      final recordKey = _recordKey(change.entityType, change.entityKey);
      if (_pendingEntities[ownerId]?.contains(recordKey) ?? false) {
        throw PullApplyConflict(change.entityKey);
      }
      final priorRevision =
          prepared[recordKey]?.revision ?? existing[recordKey]?.revision ?? 0;
      if (change.serverRevision <= priorRevision) {
        throw StateError('Non-increasing server revision');
      }
      prepared[recordKey] = PulledRecord(
        revision: change.serverRevision,
        deleted: change.deleted,
        payload: _snapshot(change.payload),
      );
    }
    // No await between record replacement and cursor advancement.
    _records.putIfAbsent(ownerId, () => {}).addAll(prepared);
    _cursors[ownerId] = page.nextCursor;
  }

  void markPending(String ownerId, String entityType, String entityKey) {
    _pendingEntities
        .putIfAbsent(ownerId, () => {})
        .add(_recordKey(entityType, entityKey));
  }

  void clearPending(String ownerId, String entityType, String entityKey) {
    _pendingEntities[ownerId]?.remove(_recordKey(entityType, entityKey));
  }

  PulledRecord? read(String ownerId, String entityType, String entityKey) {
    final value = _records[ownerId]?[_recordKey(entityType, entityKey)];
    if (value == null) return null;
    return PulledRecord(
      revision: value.revision,
      deleted: value.deleted,
      payload: _snapshot(value.payload),
    );
  }
}
