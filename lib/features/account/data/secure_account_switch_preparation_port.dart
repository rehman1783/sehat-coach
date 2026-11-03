import '../../../core/data/local/account_database_service.dart';
import '../domain/prepare_account_switch_use_case.dart';
import '../domain/suspend_account_session_use_case.dart';
import 'secure_account_lifecycle_port.dart';

class SecureAccountSwitchPreparationPort
    implements AccountSwitchPreparationPort {
  const SecureAccountSwitchPreparationPort({
    required this.localData,
    required this.suspension,
    required this.synchronizeOwner,
  });

  final AccountLocalDataBoundary localData;
  final SuspendAccountSessionUseCase suspension;
  final OwnerAction synchronizeOwner;

  @override
  String? get activeOwnerId => suspension.activeOwnerId;

  @override
  Future<int> pendingChangeCount(String ownerId) =>
      localData.pendingChangeCount(ownerId);

  @override
  Future<void> synchronize(String ownerId) => synchronizeOwner(ownerId);

  @override
  Future<void> suspend(String ownerId) async {
    if (activeOwnerId != ownerId) throw StateError('Active owner mismatch');
    final result = await suspension.execute();
    if (result != AccountSuspensionStatus.suspended) {
      throw StateError('Account was not suspended');
    }
  }
}
