import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/prepare_account_switch_use_case.dart';

class SwitchPortFake implements AccountSwitchPreparationPort {
  @override
  String? activeOwnerId = 'owner-a';
  int pending = 0;
  bool syncClearsPending = true;
  final events = <String>[];

  @override
  Future<int> pendingChangeCount(String ownerId) async {
    events.add('count:$ownerId');
    return pending;
  }

  @override
  Future<void> synchronize(String ownerId) async {
    events.add('sync:$ownerId');
    if (syncClearsPending) pending = 0;
  }

  @override
  Future<void> suspend(String ownerId) async {
    events.add('suspend:$ownerId');
    activeOwnerId = null;
  }
}

void main() {
  test('no active account is immediately ready for authentication', () async {
    final port = SwitchPortFake()..activeOwnerId = null;
    expect(
      await PrepareAccountSwitchUseCase(port).execute(isOnline: false),
      AccountSwitchPreparationStatus.noActiveAccount,
    );
    expect(port.events, isEmpty);
  });

  test(
    'pending changes require connectivity and explicit sync choice',
    () async {
      final offline = SwitchPortFake()..pending = 2;
      expect(
        await PrepareAccountSwitchUseCase(offline).execute(isOnline: false),
        AccountSwitchPreparationStatus.pendingOffline,
      );
      expect(offline.activeOwnerId, 'owner-a');

      final online = SwitchPortFake()..pending = 2;
      expect(
        await PrepareAccountSwitchUseCase(online).execute(isOnline: true),
        AccountSwitchPreparationStatus.pendingOnline,
      );
      expect(online.events, ['count:owner-a']);
    },
  );

  test('successful sync recheck suspends previous account', () async {
    final port = SwitchPortFake()..pending = 2;
    expect(
      await PrepareAccountSwitchUseCase(port)
          .execute(isOnline: true, syncFirst: true),
      AccountSwitchPreparationStatus.readyForAuthentication,
    );
    expect(port.events, [
      'count:owner-a',
      'sync:owner-a',
      'count:owner-a',
      'suspend:owner-a',
    ]);
    expect(port.activeOwnerId, isNull);
  });

  test('remaining pending data prevents suspension after sync', () async {
    final port = SwitchPortFake()
      ..pending = 1
      ..syncClearsPending = false;
    expect(
      await PrepareAccountSwitchUseCase(port)
          .execute(isOnline: true, syncFirst: true),
      AccountSwitchPreparationStatus.pendingAfterSync,
    );
    expect(port.activeOwnerId, 'owner-a');
    expect(port.events, ['count:owner-a', 'sync:owner-a', 'count:owner-a']);
  });
}
