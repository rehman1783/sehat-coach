import '../../account/domain/authenticated_owner_session.dart';

class RemoteChange {
  const RemoteChange({
    required this.ownerId,
    required this.entityType,
    required this.entityKey,
    required this.serverRevision,
    required this.deleted,
    required this.payload,
  });

  final String ownerId;
  final String entityType;
  final String entityKey;
  final int serverRevision;
  final bool deleted;
  final Map<String, Object?> payload;
}

class PullPage {
  const PullPage({
    required this.ownerId,
    required this.requestCursor,
    required this.nextCursor,
    required this.changes,
    required this.hasMore,
  });

  final String ownerId;
  final String? requestCursor;
  final String nextCursor;
  final List<RemoteChange> changes;
  final bool hasMore;
}

abstract interface class SyncPullTransport {
  Future<PullPage> fetch({required String ownerId, required String? cursor});
}

class PullTransportFailure implements Exception {
  const PullTransportFailure();
}

class PullAuthenticationFailure implements Exception {
  const PullAuthenticationFailure();
}

/// Implementations must apply every change and advance the cursor in one
/// transaction. A failure must preserve both records and the previous cursor.
abstract interface class PullApplyStore {
  Future<String?> cursor(String ownerId);
  Future<void> applyPage(String ownerId, PullPage page);
}

class PullApplyConflict implements Exception {
  const PullApplyConflict(this.entityKey);
  final String entityKey;
}

enum PullStopReason {
  complete,
  moreAvailable,
  conflict,
  invalidPage,
  applyFailure,
  transportFailure,
  authenticationRequired,
}

class PullRunResult {
  const PullRunResult(this.applied, this.reason, [this.blockedEntityKey]);
  final int applied;
  final PullStopReason reason;
  final String? blockedEntityKey;
}

class SyncPullCoordinator {
  const SyncPullCoordinator(this._session, this._store, this._transport);

  final AuthenticatedOwnerSession _session;
  final PullApplyStore _store;
  final SyncPullTransport _transport;

  Future<PullRunResult> pullOnePage() => _session.withOwner((ownerId) async {
    if (ownerId.trim().isEmpty) {
      throw StateError('Authenticated owner required');
    }
    final cursor = await _store.cursor(ownerId);
    late final PullPage page;
    try {
      page = await _transport.fetch(ownerId: ownerId, cursor: cursor);
    } on PullAuthenticationFailure {
      return const PullRunResult(0, PullStopReason.authenticationRequired);
    } on PullTransportFailure {
      return const PullRunResult(0, PullStopReason.transportFailure);
    }
    if (page.ownerId != ownerId ||
        page.requestCursor != cursor ||
        page.nextCursor.trim().isEmpty ||
        page.changes.any(
          (change) =>
              change.ownerId != ownerId ||
              change.entityType.trim().isEmpty ||
              change.entityKey.trim().isEmpty ||
              change.serverRevision <= 0,
        )) {
      return const PullRunResult(0, PullStopReason.invalidPage);
    }
    try {
      await _store.applyPage(ownerId, page);
    } on PullApplyConflict catch (conflict) {
      return PullRunResult(0, PullStopReason.conflict, conflict.entityKey);
    } catch (_) {
      return const PullRunResult(0, PullStopReason.applyFailure);
    }
    return PullRunResult(
      page.changes.length,
      page.hasMore ? PullStopReason.moreAvailable : PullStopReason.complete,
    );
  });
}
