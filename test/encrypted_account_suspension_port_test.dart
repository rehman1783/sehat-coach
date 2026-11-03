import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/data/encrypted_account_suspension_port.dart';
import 'package:sehat_coach/features/account/domain/suspend_account_session_use_case.dart';

class SuspensionVault implements AccountKeyVault {
  final keys = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String ownerId) async => keys[ownerId];
  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async =>
      keys.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));
  @override
  Future<void> delete(String ownerId) async => keys.remove(ownerId);
}

void main() {
  test(
    'suspension closes runtime but preserves encrypted recovery material',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-suspension-test-',
      );
      final vault = SuspensionVault();
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(vault),
      );
      final memoryClears = <String>[];
      addTearDown(() async {
        await service.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      await service.open('owner-a');
      final file = service.fileForOwner('owner-a');
      final status = await SuspendAccountSessionUseCase(
        EncryptedAccountSuspensionPort(
          databaseService: service,
          clearOwnerMemory: (owner) async => memoryClears.add(owner),
        ),
      ).execute();

      expect(status, AccountSuspensionStatus.suspended);
      expect(service.activeOwnerId, isNull);
      expect(memoryClears, ['owner-a']);
      expect(await file.exists(), isTrue);
      expect(vault.keys, contains('owner-a'));
      await service.open('owner-a');
      expect(service.activeOwnerId, 'owner-a');
    },
  );
}
