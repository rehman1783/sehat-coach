import '../../../core/data/local/account_database_service.dart';
import '../domain/account_data_operations.dart';
import '../domain/sign_out_coordinator.dart';

typedef OwnerAction = Future<void> Function(String ownerId);
typedef OwnerDecision = Future<bool> Function(String ownerId);

/// Connects distinct account workflows to one durable local-data boundary.
class SecureAccountLifecyclePort
    implements SignOutPort, AccountDataOperationsPort {
  const SecureAccountLifecyclePort({
    required this.localData,
    required this.synchronizeOwner,
    required this.clearOwnerSession,
    required this.deleteCloudAccount,
    required this.checkRecentAuthentication,
  });

  final AccountLocalDataResetBoundary localData;
  final OwnerAction synchronizeOwner;
  final OwnerAction clearOwnerSession;
  final OwnerDecision deleteCloudAccount;
  final OwnerDecision checkRecentAuthentication;

  @override
  Future<bool> hasRecentAuthentication(String ownerId) =>
      checkRecentAuthentication(ownerId);

  @override
  Future<int> pendingChangeCount(String ownerId) =>
      localData.pendingChangeCount(ownerId);

  @override
  Future<void> synchronize(String ownerId) => synchronizeOwner(ownerId);

  @override
  Future<bool> clearAccountIfFullySynced(String ownerId) =>
      localData.clearIfFullySynced(ownerId);

  @override
  Future<bool> clearLocalIfFullySynced(String ownerId) =>
      localData.resetIfFullySynced(ownerId);

  @override
  Future<bool> requestCloudAccountDeletion(String ownerId) =>
      deleteCloudAccount(ownerId);

  @override
  Future<void> clearSession(String ownerId) => clearOwnerSession(ownerId);
}
