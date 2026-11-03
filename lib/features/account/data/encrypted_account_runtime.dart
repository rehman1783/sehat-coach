import '../../../core/data/local/account_database_service.dart';
import '../../../core/data/local/account_key_resolver.dart';
import '../../../core/data/local/encrypted_database_opener.dart';
import '../domain/account_access_coordinator.dart';
import '../domain/suspend_account_session_use_case.dart';

typedef DecryptedAccountMemoryClearer = Future<void> Function(String ownerId);

Future<void> _noDecryptedMemory(String ownerId) async {}

/// Activates the real encrypted account database without duplicating owner
/// state outside AccountDatabaseService.
class EncryptedAccountRuntime
    implements AccountRuntimePort, AccountSuspensionPort {
  const EncryptedAccountRuntime(
    this.databaseService, [
    this._clearDecryptedMemory = _noDecryptedMemory,
  ]);

  final AccountDatabaseService databaseService;
  final DecryptedAccountMemoryClearer _clearDecryptedMemory;

  @override
  String? get activeOwnerId => databaseService.activeOwnerId;

  @override
  Future<void> activate(String ownerId) async {
    try {
      await databaseService.open(ownerId);
    } on EncryptedDatabaseOpenFailure catch (_) {
      throw const AccountDataRecoveryRequired();
    } on AccountKeyRecoveryRequired catch (_) {
      throw const AccountDataRecoveryRequired();
    } on AccountDatabaseArtifactMigrationFailure catch (_) {
      throw const AccountDataRecoveryRequired();
    }
    if (databaseService.activeOwnerId != ownerId) {
      throw StateError('Encrypted database owner mismatch');
    }
  }

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    final activeOwner = databaseService.activeOwnerId;
    if (activeOwner == null) return;
    if (activeOwner != ownerId) {
      throw StateError('Refusing to close a different account database');
    }
    await databaseService.close();
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) =>
      _clearDecryptedMemory(ownerId);
}
