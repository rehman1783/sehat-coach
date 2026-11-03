import 'package:get/get.dart';

import '../../domain/prepare_account_switch_use_case.dart';

typedef AccountSwitchConnectivityCheck = Future<bool> Function();
typedef AccountSwitchReadyAction = Future<void> Function();

class AccountSwitchController extends GetxController {
  AccountSwitchController({
    required PrepareAccountSwitchUseCase switchPreparation,
    required AccountSwitchConnectivityCheck connectivityCheck,
    required this.onReadyForAuthentication,
  }) : _preparation = switchPreparation,
       _isOnline = connectivityCheck;

  final PrepareAccountSwitchUseCase _preparation;
  final AccountSwitchConnectivityCheck _isOnline;
  final AccountSwitchReadyAction onReadyForAuthentication;

  final isBusy = false.obs;
  final canSyncAndContinue = false.obs;
  final message = RxnString();
  final errorMessage = RxnString();

  Future<void> prepare({bool syncFirst = false}) async {
    if (isBusy.value) return;
    isBusy.value = true;
    message.value = null;
    errorMessage.value = null;
    try {
      final status = await _preparation.execute(
        isOnline: await _isOnline(),
        syncFirst: syncFirst,
      );
      canSyncAndContinue.value = false;
      switch (status) {
        case AccountSwitchPreparationStatus.readyForAuthentication:
        case AccountSwitchPreparationStatus.noActiveAccount:
          message.value =
              'This device is ready to authenticate another account.';
          await onReadyForAuthentication();
        case AccountSwitchPreparationStatus.pendingOffline:
          errorMessage.value = 'Unsynchronized records are protected. Connect to the internet before switching accounts.';
        case AccountSwitchPreparationStatus.pendingOnline:
          canSyncAndContinue.value = true;
          message.value = 'Unsynchronized records exist. Synchronize them before switching accounts.';
        case AccountSwitchPreparationStatus.pendingAfterSync:
          errorMessage.value = 'Some records are still unsynchronized. The current account remains active.';
      }
    } on Object {
      errorMessage.value = 'Account switching could not start. The current account remains protected.';
    } finally {
      isBusy.value = false;
    }
  }
}
