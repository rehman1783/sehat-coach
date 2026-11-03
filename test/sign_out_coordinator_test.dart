import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/sign_out_coordinator.dart';

class FakeSignOutPort implements SignOutPort {
  int pending = 0;
  bool failSync = false;
  bool injectEditBeforeClear = false;
  int syncCalls = 0;
  int localClears = 0;
  int sessionClears = 0;

  @override
  Future<int> pendingChangeCount(String ownerId) async => pending;

  @override
  Future<void> synchronize(String ownerId) async {
    syncCalls++;
    if (failSync) throw StateError('Sync failed');
    pending = 0;
  }

  @override
  Future<bool> clearAccountIfFullySynced(String ownerId) async {
    if (injectEditBeforeClear) pending++;
    if (pending > 0) return false;
    localClears++;
    return true;
  }

  @override
  Future<void> clearSession(String ownerId) async => sessionClears++;
}

void main() {
  test(
    'offline pending records block sign-out without clearing data',
    () async {
      final port = FakeSignOutPort()..pending = 2;
      final result = await SignOutCoordinator(port)
          .signOut('owner-a', isOnline: false);
      expect(result, SignOutStatus.pendingOffline);
      expect(port.localClears, 0);
      expect(port.sessionClears, 0);
    },
  );

  test('online pending records require explicit sync choice', () async {
    final port = FakeSignOutPort()..pending = 1;
    final coordinator = SignOutCoordinator(port);
    expect(
      await coordinator.signOut('owner-a', isOnline: true),
      SignOutStatus.pendingOnline,
    );
    expect(port.syncCalls, 0);
    expect(
      await coordinator.signOut('owner-a', isOnline: true, syncFirst: true),
      SignOutStatus.signedOut,
    );
    expect(port.syncCalls, 1);
    expect(port.localClears, 1);
    expect(port.sessionClears, 1);
  });

  test(
    'sync failure or new pending edit cannot silently clear records',
    () async {
      final failed = FakeSignOutPort()
        ..pending = 1
        ..failSync = true;
      await expectLater(
        SignOutCoordinator(failed)
            .signOut('owner-a', isOnline: true, syncFirst: true),
        throwsStateError,
      );
      expect(failed.localClears, 0);
      expect(failed.sessionClears, 0);

      final raced = FakeSignOutPort()..injectEditBeforeClear = true;
      expect(
        await SignOutCoordinator(raced).signOut('owner-a', isOnline: true),
        SignOutStatus.pendingAfterSync,
      );
      expect(raced.localClears, 0);
      expect(raced.sessionClears, 0);
    },
  );

  test('empty owner is rejected', () async {
    await expectLater(
      SignOutCoordinator(FakeSignOutPort()).signOut(' ', isOnline: true),
      throwsArgumentError,
    );
  });
}
