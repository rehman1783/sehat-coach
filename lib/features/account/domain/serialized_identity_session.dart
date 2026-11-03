import 'dart:async';

import 'account_identity.dart';

class IdentityTransition<T> {
  const IdentityTransition({required this.identity, required this.value});

  final AccountIdentity? identity;
  final T value;
}

/// In-memory coordination boundary between a trusted authentication adapter and
/// account-scoped work. It does not persist credentials or validate tokens.
///
/// Identity changes are ordered behind work that already captured an identity,
/// so sign-out and account switching cannot change the owner halfway through an
/// awaited database or network operation.
class SerializedIdentitySession implements StableIdentitySession {
  SerializedIdentitySession([AccountIdentity? initialIdentity])
    : _identity = initialIdentity;

  AccountIdentity? _identity;
  Future<void> _tail = Future<void>.value();

  Future<void> applyTrustedIdentity(AccountIdentity? identity) {
    return transition<void>(
      (_) async => IdentityTransition(identity: identity, value: null),
    );
  }

  /// Runs a trusted auth/runtime transition exclusively, then publishes its
  /// resulting identity before any later account-scoped work may start.
  Future<T> transition<T>(
    Future<IdentityTransition<T>> Function(AccountIdentity? currentIdentity)
    operation,
  ) {
    return _enqueue<T>(() async {
      final result = await operation(_identity);
      _identity = result.identity;
      return result.value;
    });
  }

  @override
  Future<T> withIdentity<T>(
    Future<T> Function(AccountIdentity identity) operation,
  ) {
    return _enqueue<T>(() async {
      final identity = _identity;
      if (identity == null) throw const AuthenticationRequired();
      return operation(identity);
    });
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}
