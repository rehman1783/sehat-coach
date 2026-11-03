import '../../../core/data/local/account_database_service.dart';
import '../domain/suspend_account_session_use_case.dart';

typedef ClearOwnerMemory = Future<void> Function(String ownerId);

class EncryptedAccountSuspensionPort implements AccountSuspensionPort {
  const EncryptedAccountSuspensionPort({
    required this.databaseService,
    required this.clearOwnerMemory,
  });

  final AccountDatabaseService databaseService;
  final ClearOwnerMemory clearOwnerMemory;

  @override
  String? get activeOwnerId => databaseService.activeOwnerId;

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    if (databaseService.activeOwnerId != ownerId) {
      throw StateError('Active database owner mismatch');
    }
    await databaseService.close();
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) =>
      clearOwnerMemory(ownerId);
}
