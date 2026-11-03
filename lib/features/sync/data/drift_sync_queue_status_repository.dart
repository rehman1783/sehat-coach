import 'package:drift/drift.dart';

import '../../../core/data/local/app_database.dart';
import '../domain/sync_queue_status.dart';

/// Payload-free reactive projection of one account's upload queue.
class DriftSyncQueueStatusRepository implements SyncQueueStatusRepository {
  DriftSyncQueueStatusRepository(this._database, this._ownerId) {
    _requireOwner(_ownerId);
  }

  final AppDatabase _database;
  final String _ownerId;

  void _requireOwner(String ownerId) {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
    if (ownerId != _ownerId) {
      throw StateError('Repository is bound to a different owner');
    }
  }

  Selectable<SyncQueueStatus> _query(String ownerId) {
    _requireOwner(ownerId);
    final table = _database.syncOutboxEntries;
    final pendingCount = countAll();
    final failedCount = table.lastError.count();
    final oldestPendingAt = table.createdAtClient.min();
    final query = _database.selectOnly(table)
      ..addColumns([pendingCount, failedCount, oldestPendingAt])
      ..where(table.ownerId.equals(ownerId));
    return query.map(
      (row) => SyncQueueStatus(
        pendingCount: row.read(pendingCount) ?? 0,
        failedCount: row.read(failedCount) ?? 0,
        oldestPendingAt: row.read(oldestPendingAt),
      ),
    );
  }

  @override
  Future<SyncQueueStatus> read(String ownerId) => _query(ownerId).getSingle();

  @override
  Stream<SyncQueueStatus> watch(String ownerId) =>
      _query(ownerId).watchSingle();
}
