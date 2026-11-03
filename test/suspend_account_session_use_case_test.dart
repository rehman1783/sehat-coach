import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';

class SuspensionPortFake implements AccountSuspensionPort {
  @override
  String? activeOwnerId;
  bool failClose = false;
  bool remainActive = false;
  final events = <String>[];

  @override
  Future<void> closeAccountDatabase(String ownerId) async {
    events.add('close:$ownerId');
    if (failClose) throw StateError('close failed');
    if (!remainActive) activeOwnerId = null;
  }

  @override
  Future<void> clearDecryptedMemory(String ownerId) async {
    events.add('memory:$ownerId');
  }
}

void main() {
  test('no active account is a safe no-op', () async {
    final port = SuspensionPortFake();
    expect(
      await SuspendAccountSessionUseCase(port).execute(),
      AccountSuspensionStatus.noActiveAccount,
    );
    expect(port.events, isEmpty);
  });

  test('closes database then clears decrypted memory', () async {
    final port = SuspensionPortFake()..activeOwnerId = 'owner-a';
    expect(
      await SuspendAccountSessionUseCase(port).execute(),
      AccountSuspensionStatus.suspended,
    );
    expect(port.events, ['close:owner-a', 'memory:owner-a']);
    expect(port.activeOwnerId, isNull);
  });

  test('decrypted memory is cleared even when database close fails', () async {
    final port = SuspensionPortFake()
      ..activeOwnerId = 'owner-a'
      ..failClose = true;
    await expectLater(
      SuspendAccountSessionUseCase(port).execute(),
      throwsStateError,
    );
    expect(port.events, ['close:owner-a', 'memory:owner-a']);
  });

  test('refuses to report success while runtime remains active', () async {
    final port = SuspensionPortFake()
      ..activeOwnerId = 'owner-a'
      ..remainActive = true;
    await expectLater(
      SuspendAccountSessionUseCase(port).execute(),
      throwsStateError,
    );
    expect(port.events, ['close:owner-a', 'memory:owner-a']);
  });
}
