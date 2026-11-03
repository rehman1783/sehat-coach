import 'dart:math';
import 'dart:typed_data';

/// Production implementation must protect keys with platform secure storage.
/// createIfAbsent must be atomic and return the existing key on a race.
abstract interface class AccountKeyVault {
  Future<Uint8List?> read(String ownerId);
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate);
  Future<void> delete(String ownerId);
}

class AccountKeyRecoveryRequired implements Exception {
  const AccountKeyRecoveryRequired();
}

class AccountKeyResolver {
  const AccountKeyResolver(this._vault);
  final AccountKeyVault _vault;

  Future<void> delete(String ownerId) {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
    return _vault.delete(ownerId);
  }

  /// Caller must serialize database creation/opening for this owner and supply
  /// existence from the resolved account database path, not UI state.
  Future<Uint8List> resolve(
    String ownerId, {
    required bool databaseExists,
  }) async {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
    final existing = await _vault.read(ownerId);
    if (existing != null) return _validatedCopy(existing);
    if (databaseExists) throw const AccountKeyRecoveryRequired();
    final random = Random.secure();
    final candidate = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    try {
      return _validatedCopy(await _vault.createIfAbsent(ownerId, candidate));
    } finally {
      candidate.fillRange(0, candidate.length, 0);
    }
  }

  Uint8List _validatedCopy(Uint8List key) {
    if (key.length != 32) throw const AccountKeyRecoveryRequired();
    return Uint8List.fromList(key);
  }
}
