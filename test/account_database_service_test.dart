import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/core/data/local/encrypted_database_opener.dart';
import 'package:sehat_coach/features/sync/data/drift_local_change_store.dart';

class Vault implements AccountKeyVault {
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
    'account filename is deterministic without reversible owner identity',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-account-name-test-',
      );
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(Vault()),
      );
      const owner = 'firebase-owner@example.com';
      final reversibleHex = owner.codeUnits
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();

      final first = service.fileForOwner(owner);

      expect(first.path, isNot(contains(owner)));
      expect(first.path, isNot(contains(reversibleHex)));
      expect(service.fileForOwner(owner).path, first.path);
      expect(service.fileForOwner('different-owner').path, isNot(first.path));
    },
  );

  test(
    'legacy reversible filename migrates without losing encrypted data',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-account-name-migration-',
      );
      const owner = 'owner-a';
      final key = Uint8List.fromList(List.generate(32, (index) => index + 1));
      final vault = Vault()..keys[owner] = Uint8List.fromList(key);
      final legacyName = owner.codeUnits
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      final legacyFile = File('${directory.path}/account-$legacyName.sqlite');
      final oldDatabase = await openEncryptedDatabase(legacyFile, key);
      await oldDatabase
          .into(oldDatabase.syncCursors)
          .insert(
            SyncCursorsCompanion.insert(
              ownerId: owner,
              cursor: 'legacy-cursor',
              updatedAtClient: DateTime.utc(2026, 10, 28),
            ),
          );
      await oldDatabase.close();
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(vault),
      );
      addTearDown(() async {
        await service.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final migrated = await service.open(owner);

      expect(await legacyFile.exists(), isFalse);
      expect(await service.fileForOwner(owner).exists(), isTrue);
      expect(
        (await migrated.select(migrated.syncCursors).getSingle()).cursor,
        'legacy-cursor',
      );
    },
  );

  test('project scopes isolate filenames for the same owner', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-account-scope-test-',
    );
    addTearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });
    final production = AccountDatabaseService(
      directory,
      AccountKeyResolver(Vault()),
      storageScope: 'firebase:production-project',
    );
    final staging = AccountDatabaseService(
      directory,
      AccountKeyResolver(Vault()),
      storageScope: 'firebase:staging-project',
    );

    expect(
      production.fileForOwner('owner-a').path,
      isNot(staging.fileForOwner('owner-a').path),
    );
  });

  test(
    'project scope migrates the previous unscoped hashed database',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-account-scope-migration-',
      );
      const owner = 'owner-a';
      final key = Uint8List.fromList(List.generate(32, (index) => 32 - index));
      final vault = Vault()..keys[owner] = Uint8List.fromList(key);
      final unscopedService = AccountDatabaseService(
        directory,
        AccountKeyResolver(vault),
      );
      final unscopedFile = unscopedService.fileForOwner(owner);
      final oldDatabase = await openEncryptedDatabase(unscopedFile, key);
      await oldDatabase
          .into(oldDatabase.syncCursors)
          .insert(
            SyncCursorsCompanion.insert(
              ownerId: owner,
              cursor: 'unscoped-cursor',
              updatedAtClient: DateTime.utc(2026, 10, 28),
            ),
          );
      await oldDatabase.close();
      final scopedService = AccountDatabaseService(
        directory,
        AccountKeyResolver(vault),
        storageScope: 'firebase:production-project',
      );
      addTearDown(() async {
        await scopedService.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final migrated = await scopedService.open(owner);

      expect(await unscopedFile.exists(), isFalse);
      expect(await scopedService.fileForOwner(owner).exists(), isTrue);
      expect(
        (await migrated.select(migrated.syncCursors).getSingle()).cursor,
        'unscoped-cursor',
      );
    },
  );

  test('environment scope migrates the previous project database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-account-environment-migration-',
    );
    const owner = 'owner-a';
    final key = Uint8List.fromList(List.generate(32, (index) => index + 2));
    final vault = Vault()..keys[owner] = Uint8List.fromList(key);
    final projectService = AccountDatabaseService(
      directory,
      AccountKeyResolver(vault),
      storageScope: 'firebase:shared-project',
    );
    final projectFile = projectService.fileForOwner(owner);
    final oldDatabase = await openEncryptedDatabase(projectFile, key);
    await oldDatabase
        .into(oldDatabase.syncCursors)
        .insert(
          SyncCursorsCompanion.insert(
            ownerId: owner,
            cursor: 'project-scoped-cursor',
            updatedAtClient: DateTime.utc(2026, 10, 28),
          ),
        );
    await oldDatabase.close();
    final environmentService = AccountDatabaseService(
      directory,
      AccountKeyResolver(vault),
      storageScope: 'firebase:shared-project:environment:production',
      legacyStorageScopes: const ['firebase:shared-project'],
    );
    addTearDown(() async {
      await environmentService.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    final migrated = await environmentService.open(owner);

    expect(await projectFile.exists(), isFalse);
    expect(await environmentService.fileForOwner(owner).exists(), isTrue);
    expect(
      (await migrated.select(migrated.syncCursors).getSingle()).cursor,
      'project-scoped-cursor',
    );
  });

  test('isolates account files, requires close before switching, preserves lost-key file', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-account-test-',
    );
    final vault = Vault();
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(vault),
    );
    addTearDown(() async {
      await service.close();
      await directory.delete(recursive: true);
    });
    final first = await service.open('owner-a');
    expect(identical(first, await service.open('owner-a')), isTrue);
    await expectLater(service.open('owner-b'), throwsStateError);
    await service.close();
    await service.open('owner-b');
    expect(
      service.fileForOwner('owner-a').path,
      isNot(service.fileForOwner('owner-b').path),
    );
    await service.close();
    final file = service.fileForOwner('owner-a');
    final before = await file.readAsBytes();
    vault.keys.remove('owner-a');
    await expectLater(
      service.open('owner-a'),
      throwsA(isA<AccountKeyRecoveryRequired>()),
    );
    expect(await file.readAsBytes(), before);
    expect(vault.keys.containsKey('owner-a'), isFalse);
  });

  test(
    'local clearing is blocked by durable outbox then removes file and key',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-account-clear-test-',
      );
      final vault = Vault();
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(vault),
      );
      addTearDown(() async {
        await service.close();
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final database = await service.open('owner-a');
      await database.customStatement('PRAGMA journal_mode = WAL');
      final changes = DriftLocalChangeStore(database, 'owner-a');
      await changes.commit(
        ownerId: 'owner-a',
        operationId: 'op-1',
        entityType: 'profile',
        entityKey: 'main',
        expectedRevision: 0,
        payload: const {'ready': true},
      );
      final file = service.fileForOwner('owner-a');
      expect(await service.pendingChangeCount('owner-a'), 1);
      expect(await service.clearIfFullySynced('owner-a'), isFalse);
      expect(await file.exists(), isTrue);
      expect(vault.keys, contains('owner-a'));

      expect(await changes.acknowledge('owner-a', 'op-1'), isTrue);
      final sidecars = [
        '-wal',
        '-shm',
        '-journal',
      ].map((suffix) => File('${file.path}$suffix')).toList();
      await sidecars.last.writeAsString('stale rollback journal marker');
      expect(sidecars.any((artifact) => artifact.existsSync()), isTrue);
      expect(await service.clearIfFullySynced('owner-a'), isTrue);
      expect(await file.exists(), isFalse);
      expect(sidecars.where((artifact) => artifact.existsSync()), isEmpty);
      expect(vault.keys, isNot(contains('owner-a')));
      await expectLater(
        service.pendingChangeCount('owner-a'),
        throwsStateError,
      );
    },
  );

  test('local reset opens a fresh encrypted database for same owner', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-account-reset-test-',
    );
    final vault = Vault();
    final service = AccountDatabaseService(
      directory,
      AccountKeyResolver(vault),
    );
    addTearDown(() async {
      await service.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    final before = await service.open('owner-a');
    final changes = DriftLocalChangeStore(before, 'owner-a');
    await changes.commit(
      ownerId: 'owner-a',
      operationId: 'op-1',
      entityType: 'profile',
      entityKey: 'main',
      expectedRevision: 0,
      payload: const {'ready': true},
    );
    await changes.acknowledge('owner-a', 'op-1');
    expect(await before.select(before.localRecords).get(), hasLength(1));

    expect(await service.resetIfFullySynced('owner-a'), isTrue);
    expect(service.activeOwnerId, 'owner-a');
    expect(await service.fileForOwner('owner-a').exists(), isTrue);
    expect(vault.keys, contains('owner-a'));
    final after = await service.open('owner-a');
    expect(identical(after, before), isFalse);
    expect(await after.select(after.localRecords).get(), isEmpty);
  });
}
