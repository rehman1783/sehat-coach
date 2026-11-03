import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/features/account/data/secure_account_switch_preparation_port.dart';
import 'package:sehat_coach/features/account/domain/prepare_account_switch_use_case.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';

class SwitchLocalDataFake implements AccountLocalDataBoundary {
  int pending = 0;

  @override
  Future<bool> clearIfFullySynced(String authenticatedOwnerId) async => false;

  @override
  Future<int> pendingChangeCount(String authenticatedOwnerId) async => pending;
}

class SwitchSuspensionFake implements AccountSuspensionPort {
  @override
  String? activeOwnerId = 'owner-a';
  final events = <String>[];

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {
    events.add('memory:$ownerId');
  }

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    events.add('close:$ownerId');
    activeOwnerId = null;
  }
}

void main() {
  test(
    'composition uses durable count, sync and preserving suspension',
    () async {
      final local = SwitchLocalDataFake()..pending = 1;
      final suspensionPort = SwitchSuspensionFake();
      final syncOwners = <String>[];
      final port = SecureAccountSwitchPreparationPort(
        localData: local,
        suspension: SuspendAccountSessionUseCase(suspensionPort),
        synchronizeOwner: (owner) async {
          syncOwners.add(owner);
          local.pending = 0;
        },
      );

      expect(
        await PrepareAccountSwitchUseCase(port)
            .execute(isOnline: true, syncFirst: true),
        AccountSwitchPreparationStatus.readyForAuthentication,
      );
      expect(syncOwners, ['owner-a']);
      expect(suspensionPort.events, ['close:owner-a', 'memory:owner-a']);
      expect(port.activeOwnerId, isNull);
    },
  );
}
