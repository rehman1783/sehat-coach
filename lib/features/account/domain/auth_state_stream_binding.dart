import 'dart:async';

import 'account_identity.dart';
import 'auth_state_reconciliation_coordinator.dart';
import 'trusted_auth_state_coordinator.dart';

abstract interface class AuthStateStreamPort {
  /// Emits only identities already validated by the production auth adapter.
  /// A null event explicitly means that authentication has been lost.
  Stream<AccountIdentity?> watchTrustedIdentity();
}

typedef AuthStateStatusListener = FutureOr<void> Function(
  AuthStateReconciliationStatus status,
);
typedef AuthStateErrorListener = FutureOr<void> Function(
  Object error,
  StackTrace stackTrace,
);

/// Owns one auth-state subscription and forwards its events in strict order.
/// Stream transport errors are reported but are not interpreted as sign-out;
/// only an explicit null identity may revoke the current local session.
class AuthStateStreamBinding {
  AuthStateStreamBinding(this._source, this._coordinator);

  final AuthStateStreamPort _source;
  final TrustedAuthStateCoordinator _coordinator;
  StreamSubscription<AccountIdentity?>? _subscription;
  Future<void> _tail = Future<void>.value();

  bool get isStarted => _subscription != null;

  void start({
    required AuthStateStatusListener onStatus,
    required AuthStateErrorListener onError,
  }) {
    if (_subscription != null) {
      throw StateError('Auth-state binding is already started');
    }
    _subscription = _source.watchTrustedIdentity().listen(
      (identity) {
        _tail = _tail.then((_) async {
          try {
            await onStatus(await _coordinator.apply(identity));
          } catch (error, stackTrace) {
            await _report(onError, error, stackTrace);
          }
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        _tail = _tail.then((_) => _report(onError, error, stackTrace));
      },
    );
  }

  /// Stops new events and waits for every event already accepted by this
  /// binding to finish before returning.
  Future<void> stop() async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
    await _tail;
  }

  Future<void> _report(
    AuthStateErrorListener listener,
    Object error,
    StackTrace stackTrace,
  ) async {
    try {
      await listener(error, stackTrace);
    } catch (_) {
      // Listener failures must not poison delivery of later auth events.
    }
  }
}
