import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/core/data/local/flutter_secure_account_key_vault.dart';
import 'package:sehat_coach/core/data/local/owner_storage_identity.dart';

class MemorySecureValues implements SecureValueStore {
  final values = <String, String>{};
  int writes = 0;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    writes++;
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  test('round trips key without exposing owner id in storage name', () async {
    final values = MemorySecureValues();
    final vault = FlutterSecureAccountKeyVault(values);
    final key = Uint8List.fromList(List.generate(32, (index) => index));

    expect(await vault.createIfAbsent('private-user-id', key), key);
    expect(await vault.read('private-user-id'), key);
    expect(values.values.values.single, isNotEmpty);
    expect(values.values.keys.single, isNot(contains('private-user-id')));
    expect(
      values.values.keys.single,
      contains(RegExp(r'sehat\.account\.db-key\.v1\.[0-9a-f]{64}$')),
    );
  });

  test('concurrent creation keeps one value and one protected write', () async {
    final values = MemorySecureValues();
    final vault = FlutterSecureAccountKeyVault(values);
    final first = Uint8List(32)..[0] = 1;
    final second = Uint8List(32)..[0] = 2;

    final results = await Future.wait([
      vault.createIfAbsent('owner-a', first),
      vault.createIfAbsent('owner-a', second),
    ]);
    expect(results[0], results[1]);
    expect(values.writes, 1);
  });

  test('delete removes only the selected owner key', () async {
    final values = MemorySecureValues();
    final vault = FlutterSecureAccountKeyVault(values);
    await vault.createIfAbsent('owner-a', Uint8List(32)..[0] = 1);
    await vault.createIfAbsent('owner-b', Uint8List(32)..[0] = 2);

    await vault.delete('owner-a');
    expect(await vault.read('owner-a'), isNull);
    expect(await vault.read('owner-b'), isNotNull);
  });

  test('malformed protected value requires resolver recovery', () async {
    final values = MemorySecureValues();
    final vault = FlutterSecureAccountKeyVault(values);
    await vault.createIfAbsent('owner-a', Uint8List(32));
    values.values[values.values.keys.single] = 'not-valid-base64!';

    await expectLater(
      AccountKeyResolver(vault).resolve('owner-a', databaseExists: true),
      throwsA(isA<AccountKeyRecoveryRequired>()),
    );
  });

  test('project-scoped vault migrates the unscoped alias once', () async {
    final values = MemorySecureValues();
    final legacy = FlutterSecureAccountKeyVault(values);
    final key = Uint8List(32)..[0] = 42;
    await legacy.createIfAbsent('owner-a', key);
    final legacyAlias = values.values.keys.single;
    final scoped = FlutterSecureAccountKeyVault(
      values,
      storageScope: 'firebase:production-project',
    );

    expect(await scoped.read('owner-a'), key);

    expect(values.values, hasLength(1));
    expect(values.values, isNot(contains(legacyAlias)));
    expect(await scoped.read('owner-a'), key);
  });

  test('environment scope migrates the previous project alias once', () async {
    final values = MemorySecureValues();
    final key = Uint8List(32)..[0] = 24;
    final projectVault = FlutterSecureAccountKeyVault(
      values,
      storageScope: 'firebase:shared-project',
    );
    await projectVault.createIfAbsent('owner-a', key);
    final projectAlias = values.values.keys.single;
    final environmentVault = FlutterSecureAccountKeyVault(
      values,
      storageScope: 'firebase:shared-project:environment:production',
      legacyStorageScopes: const ['firebase:shared-project'],
    );

    expect(await environmentVault.read('owner-a'), key);
    expect(values.values, hasLength(1));
    expect(values.values, isNot(contains(projectAlias)));
  });

  test('conflicting legacy aliases fail closed without deleting either', () async {
    final values = MemorySecureValues();
    values.values['sehat.account.db-key.v1.${ownerStorageDigest('owner-a')}'] =
        base64Url.encode(Uint8List(32)..[0] = 1);
    values.values['sehat.account.db-key.v1.${ownerStorageDigest('owner-a', scope: 'firebase:shared-project')}'] =
        base64Url.encode(Uint8List(32)..[0] = 2);
    final aliases = Set<String>.from(values.values.keys);
    final environment = FlutterSecureAccountKeyVault(
      values,
      storageScope: 'firebase:shared-project:environment:production',
      legacyStorageScopes: const ['firebase:shared-project'],
    );

    await expectLater(
      AccountKeyResolver(environment).resolve('owner-a', databaseExists: true),
      throwsA(isA<AccountKeyRecoveryRequired>()),
    );
    expect(values.values.keys.toSet(), aliases);
  });
}
