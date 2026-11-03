import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/features/account/data/secure_account_lifecycle_port.dart';
import 'package:sehat_coach/features/account/domain/account_data_operations.dart';
import 'package:sehat_coach/features/account/domain/sign_out_coordinator.dart';

class FakeLocalData implements AccountLocalDataResetBoundary {
  int pending = 0;
  bool clearResult = true;
  final events = <String>[];

  @override
  Future<int> pendingChangeCount(String ownerId) async {
    events.add('count:$ownerId');
    return pending;
  }

  @override
  Future<bool> clearIfFullySynced(String ownerId) async {
    events.add('clear:$ownerId');
    return clearResult;
  }

  @override
  Future<bool> resetIfFullySynced(String ownerId) async {
    events.add('reset:$ownerId');
    return clearResult;
  }
}

void main() {
  test('one durable boundary serves distinct lifecycle operations', () async {
    final local = FakeLocalData();
    final events = local.events;
    final port = SecureAccountLifecyclePort(
      localData: local,
      synchronizeOwner: (owner) async => events.add('sync:$owner'),
      clearOwnerSession: (owner) async => events.add('session:$owner'),
      deleteCloudAccount: (owner) async {
        events.add('cloud-delete:$owner');
        return true;
      },
      checkRecentAuthentication: (owner) async {
        events.add('recent-auth:$owner');
        return true;
      },
    );

    expect(await port.pendingChangeCount('owner-a'), 0);
    expect(await port.clearAccountIfFullySynced('owner-a'), isTrue);
    expect(await port.clearLocalIfFullySynced('owner-a'), isTrue);
    await port.synchronize('owner-a');
    expect(await port.hasRecentAuthentication('owner-a'), isTrue);
    expect(await port.requestCloudAccountDeletion('owner-a'), isTrue);
    await port.clearSession('owner-a');
    expect(events, [
      'count:owner-a',
      'clear:owner-a',
      'reset:owner-a',
      'sync:owner-a',
      'recent-auth:owner-a',
      'cloud-delete:owner-a',
      'session:owner-a',
    ]);
  });

  test('adapter retains both account workflow contracts', () {
    final port = SecureAccountLifecyclePort(
      localData: FakeLocalData(),
      synchronizeOwner: (_) async {},
      clearOwnerSession: (_) async {},
      deleteCloudAccount: (_) async => false,
      checkRecentAuthentication: (_) async => true,
    );
    expect(port, isA<SignOutPort>());
    expect(port, isA<AccountDataOperationsPort>());
  });
}
