import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/data/encrypted_account_runtime.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';

class RuntimeVault implements AccountKeyVault {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String ownerId) async => values[ownerId];

  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async =>
      values.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));

  @override
  Future<void> delete(String ownerId) async => values.remove(ownerId);
}

SignInResult runtimeSignIn(String uid) => SignInResult(
  AccountIdentity(
    uid: uid,
    emailVerified: true,
    adultEligible: true,
    linkedProviders: const {AccountProvider.password},
  ),
  AccountAccessStatus.ready,
);

void main() {
  test(
    'activates real encrypted database and reflects service cleanup',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-runtime-test-',
      );
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(RuntimeVault()),
      );
      final runtime = EncryptedAccountRuntime(service);
      addTearDown(() async {
        await service.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      expect(runtime.activeOwnerId, isNull);
      final result = await AccountAccessCoordinator(runtime)
          .activate(runtimeSignIn('owner-a'));
      expect(result.activated, isTrue);
      expect(runtime.activeOwnerId, 'owner-a');
      expect(await service.fileForOwner('owner-a').exists(), isTrue);

      expect(await service.clearIfFullySynced('owner-a'), isTrue);
      expect(runtime.activeOwnerId, isNull);
      expect(await service.fileForOwner('owner-a').exists(), isFalse);
    },
  );

  test('real runtime refuses direct cross-owner activation', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-runtime-isolation-test-',
    );
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(RuntimeVault()),
    );
    final coordinator = AccountAccessCoordinator(
      EncryptedAccountRuntime(service),
    );
    addTearDown(() async {
      await service.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    await coordinator.activate(runtimeSignIn('owner-a'));
    await expectLater(
      coordinator.activate(runtimeSignIn('owner-b')),
      throwsA(isA<AccountSwitchRequiresSignOut>()),
    );
    expect(service.activeOwnerId, 'owner-a');
    expect(await service.fileForOwner('owner-b').exists(), isFalse);
  });

  test('missing protected key preserves file and requires recovery', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-runtime-lost-key-test-',
    );
    final vault = RuntimeVault();
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(vault),
    );
    final runtime = EncryptedAccountRuntime(service);
    final file = service.fileForOwner('owner-a');
    await directory.create(recursive: true);
    final original = Uint8List.fromList([83, 69, 72, 65, 84]);
    await file.writeAsBytes(original, flush: true);
    addTearDown(() async {
      await service.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    await expectLater(
      runtime.activate('owner-a'),
      throwsA(isA<AccountDataRecoveryRequired>()),
    );

    expect(runtime.activeOwnerId, isNull);
    expect(await file.readAsBytes(), original);
    expect(vault.values, isEmpty);
  });

  test(
    'legacy artifact collision preserves both files and requires recovery',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-runtime-artifact-collision-',
      );
      const owner = 'owner-a';
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(RuntimeVault()),
      );
      final runtime = EncryptedAccountRuntime(service);
      await directory.create(recursive: true);
      final legacyName = owner.codeUnits
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      final legacyMain = File('${directory.path}/account-$legacyName.sqlite');
      final legacyWal = File('${legacyMain.path}-wal');
      final hashedWal = File('${service.fileForOwner(owner).path}-wal');
      await legacyMain.writeAsBytes([1, 2, 3], flush: true);
      await legacyWal.writeAsBytes([4, 5, 6], flush: true);
      await hashedWal.writeAsBytes([7, 8, 9], flush: true);
      addTearDown(() async {
        await service.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      await expectLater(
        runtime.activate(owner),
        throwsA(isA<AccountDataRecoveryRequired>()),
      );

      expect(runtime.activeOwnerId, isNull);
      expect(await legacyMain.readAsBytes(), [1, 2, 3]);
      expect(await legacyWal.readAsBytes(), [4, 5, 6]);
      expect(await hashedWal.readAsBytes(), [7, 8, 9]);
    },
  );

  test(
    'suspension closes encrypted storage then clears owner memory',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-runtime-suspend-test-',
      );
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(RuntimeVault()),
      );
      final events = <String>[];
      final runtime = EncryptedAccountRuntime(service, (ownerId) async {
        expect(service.activeOwnerId, isNull);
        events.add('memory:$ownerId');
      });
      addTearDown(() async {
        await service.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      await runtime.activate('owner-a');

      final result = await SuspendAccountSessionUseCase(runtime).execute();

      expect(result, AccountSuspensionStatus.suspended);
      expect(runtime.activeOwnerId, isNull);
      expect(events, ['memory:owner-a']);
      expect(await service.fileForOwner('owner-a').exists(), isTrue);
    },
  );

  test('runtime refuses suspension request for a different owner', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-runtime-close-isolation-test-',
    );
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(RuntimeVault()),
    );
    final runtime = EncryptedAccountRuntime(service);
    addTearDown(() async {
      await service.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });
    await runtime.activate('owner-a');

    await expectLater(
      runtime.closeAccountDatabase('owner-b'),
      throwsStateError,
    );
    expect(runtime.activeOwnerId, 'owner-a');
  });
}
