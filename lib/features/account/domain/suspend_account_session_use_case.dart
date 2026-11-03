enum AccountSuspensionStatus { noActiveAccount, suspended }

abstract interface class AccountSuspensionPort {
  String? get activeOwnerId;

  Future<void> closeAccountDatabase(String ownerId);

  /// Clears controllers, decoded models and account-scoped caches.
  Future<void> clearDecryptedMemory(String ownerId);
}

/// Used for token expiry, revocation or auth-state loss. Unlike successful
/// sign-out, suspension preserves the encrypted file and protected key.
class SuspendAccountSessionUseCase {
  const SuspendAccountSessionUseCase(this._port);

  final AccountSuspensionPort _port;

  String? get activeOwnerId => _port.activeOwnerId;

  Future<AccountSuspensionStatus> execute() async {
    final ownerId = _port.activeOwnerId;
    if (ownerId == null) return AccountSuspensionStatus.noActiveAccount;
    Object? closeError;
    StackTrace? closeStack;
    try {
      await _port.closeAccountDatabase(ownerId);
    } catch (error, stack) {
      closeError = error;
      closeStack = stack;
    } finally {
      await _port.clearDecryptedMemory(ownerId);
    }
    if (closeError != null) Error.throwWithStackTrace(closeError, closeStack!);
    if (_port.activeOwnerId != null) {
      throw StateError('Account database remained active after suspension');
    }
    return AccountSuspensionStatus.suspended;
  }
}
