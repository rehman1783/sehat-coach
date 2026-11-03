import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';

class TestVault implements AccountKeyVault {
  final keys = <String, Uint8List>{};
  int creations = 0;
  @override
  Future<Uint8List?> read(String ownerId) async => keys[ownerId];
  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async {
    creations++;
    return keys.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));
  }

  @override
  Future<void> delete(String ownerId) async => keys.remove(ownerId);
}

void main() {
  test(
    'missing key for existing database requires recovery without creation',
    () async {
      final vault = TestVault();
      await expectLater(
        AccountKeyResolver(vault).resolve('a', databaseExists: true),
        throwsA(isA<AccountKeyRecoveryRequired>()),
      );
      expect(vault.creations, 0);
    },
  );
  test(
    'keys survive reopen and returned buffers cannot mutate vault',
    () async {
      final vault = TestVault();
      final resolver = AccountKeyResolver(vault);
      final first = await resolver.resolve('a', databaseExists: false);
      final expected = List<int>.of(first);
      first.fillRange(0, 32, 0);
      expect(await resolver.resolve('a', databaseExists: true), expected);
      expect(vault.creations, 1);
      expect((await resolver.resolve('b', databaseExists: false)).length, 32);
      expect(vault.keys.keys, containsAll(['a', 'b']));
    },
  );
  test('malformed stored key is not replaced', () async {
    final vault = TestVault()..keys['a'] = Uint8List(3);
    await expectLater(
      AccountKeyResolver(vault).resolve('a', databaseExists: false),
      throwsA(isA<AccountKeyRecoveryRequired>()),
    );
    expect(vault.creations, 0);
  });
}
