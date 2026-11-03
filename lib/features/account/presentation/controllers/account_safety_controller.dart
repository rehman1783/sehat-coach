import 'package:get/get.dart';

import '../../domain/account_data_operations.dart';
import '../../domain/sign_out_coordinator.dart';

typedef ConnectivityCheck = Future<bool> Function();
typedef AccountAction = Future<void> Function();
typedef ReauthenticateAccount = Future<bool> Function();

class AccountSafetyController extends GetxController {
  AccountSafetyController({
    required AuthenticatedSignOutUseCase signOutAction,
    required ClearLocalDataUseCase clearLocalAction,
    required AuthenticatedDeleteAccountUseCase deleteAction,
    required ConnectivityCheck connectivityCheck,
    required this.onSignedOut,
    required this.onAccountDeleted,
    this.onLocalDataCleared,
    this.reauthenticate,
  }) : _signOut = signOutAction,
       _clearLocalData = clearLocalAction,
       _deleteAccount = deleteAction,
       _isOnline = connectivityCheck;

  final AuthenticatedSignOutUseCase _signOut;
  final ClearLocalDataUseCase _clearLocalData;
  final AuthenticatedDeleteAccountUseCase _deleteAccount;
  final ConnectivityCheck _isOnline;
  final AccountAction onSignedOut;
  final AccountAction onAccountDeleted;
  final AccountAction? onLocalDataCleared;
  final ReauthenticateAccount? reauthenticate;

  final isBusy = false.obs;
  final message = RxnString();
  final errorMessage = RxnString();
  final canSyncAndSignOut = false.obs;
  final canReauthenticateForDelete = false.obs;

  Future<void> signOut({bool syncFirst = false}) async {
    await _run(() async {
      final status = await _signOut.execute(
        isOnline: await _isOnline(),
        syncFirst: syncFirst,
      );
      canSyncAndSignOut.value = false;
      switch (status) {
        case SignOutStatus.signedOut:
          message.value =
              'Signed out. Account data was removed from this device.';
          await onSignedOut();
        case SignOutStatus.noActiveAccount:
          message.value = 'No account is currently signed in.';
        case SignOutStatus.pendingOffline:
          errorMessage.value = 'Unsynchronized records are protected. Connect to the internet before signing out.';
        case SignOutStatus.pendingOnline:
          canSyncAndSignOut.value = true;
          message.value = 'Unsynchronized records exist. Synchronize them before signing out.';
        case SignOutStatus.pendingAfterSync:
          errorMessage.value = 'Some records are still unsynchronized. Nothing was removed; try again later.';
      }
    });
  }

  Future<void> clearLocalData({required bool confirmed}) async {
    if (!confirmed) return;
    await _run(() async {
      final status = await _clearLocalData.execute();
      switch (status) {
        case ClearLocalDataStatus.cleared:
          message.value = 'Local data was cleared. You remain signed in and synchronized history can restore safely.';
          await onLocalDataCleared?.call();
        case ClearLocalDataStatus.pendingChanges:
          errorMessage.value = 'Local data was not cleared because unsynchronized records are protected.';
      }
    });
  }

  Future<void> deleteAccount({required bool confirmed}) async {
    if (!confirmed) return;
    await _run(() async {
      final status = await _deleteAccount.execute(confirmed: true);
      canReauthenticateForDelete.value = false;
      switch (status) {
        case DeleteAccountStatus.deleted:
          message.value = 'Your account deletion request was accepted and local data was removed.';
          await onAccountDeleted();
        case DeleteAccountStatus.recentAuthenticationRequired:
          canReauthenticateForDelete.value = reauthenticate != null;
          errorMessage.value =
              'For security, sign in again before deleting your account.';
        case DeleteAccountStatus.pendingChanges:
          errorMessage.value = 'Account deletion is blocked until unsynchronized records are safely synchronized.';
        case DeleteAccountStatus.cloudRequestRejected:
          errorMessage.value = 'The server did not accept the deletion request. Your account and local data remain available.';
        case DeleteAccountStatus.localCleanupPending:
          errorMessage.value = 'Deletion was accepted, but secure local cleanup still needs to finish. Do not switch accounts yet.';
      }
    });
  }

  Future<void> reauthenticateAndDelete() async {
    final action = reauthenticate;
    if (action == null || isBusy.value) return;
    await _run(() async {
      if (!await action()) {
        message.value = 'Reauthentication was cancelled. Nothing was deleted.';
        return;
      }
      final status = await _deleteAccount.execute(confirmed: true);
      if (status == DeleteAccountStatus.deleted) {
        canReauthenticateForDelete.value = false;
        message.value = 'Your account deletion request was accepted and local data was removed.';
        await onAccountDeleted();
      } else {
        errorMessage.value = 'Account deletion could not finish. Your remaining local data was not silently removed.';
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isBusy.value) return;
    isBusy.value = true;
    message.value = null;
    errorMessage.value = null;
    try {
      await action();
    } on Object {
      errorMessage.value = 'This account action could not finish. Existing local data remains protected.';
    } finally {
      isBusy.value = false;
    }
  }
}
