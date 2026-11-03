enum AccountSwitchPreparationStatus {
  noActiveAccount,
  pendingOffline,
  pendingOnline,
  pendingAfterSync,
  readyForAuthentication,
}

abstract interface class AccountSwitchPreparationPort {
  String? get activeOwnerId;
  Future<int> pendingChangeCount(String ownerId);
  Future<void> synchronize(String ownerId);

  /// Closes the database and clears decrypted memory while retaining encrypted
  /// recovery material for the previous account.
  Future<void> suspend(String ownerId);
}

class PrepareAccountSwitchUseCase {
  const PrepareAccountSwitchUseCase(this._port);

  final AccountSwitchPreparationPort _port;

  Future<AccountSwitchPreparationStatus> execute({
    required bool isOnline,
    bool syncFirst = false,
  }) async {
    final ownerId = _port.activeOwnerId;
    if (ownerId == null) {
      return AccountSwitchPreparationStatus.noActiveAccount;
    }
    final pending = await _port.pendingChangeCount(ownerId);
    if (pending < 0) throw StateError('Invalid pending change count');
    if (pending > 0 && !isOnline) {
      return AccountSwitchPreparationStatus.pendingOffline;
    }
    if (pending > 0 && !syncFirst) {
      return AccountSwitchPreparationStatus.pendingOnline;
    }
    if (pending > 0) await _port.synchronize(ownerId);
    if (await _port.pendingChangeCount(ownerId) > 0) {
      return AccountSwitchPreparationStatus.pendingAfterSync;
    }
    await _port.suspend(ownerId);
    if (_port.activeOwnerId != null) {
      throw StateError('Previous account remained active');
    }
    return AccountSwitchPreparationStatus.readyForAuthentication;
  }
}
