import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_local_storage_composition.dart';
import 'package:sehat_coach/core/data/local/flutter_secure_account_key_vault.dart';

void main() {
  test('protected key reopens the same encrypted owner database', () async {
    final directory = await Directory.systemTemp.createTemp('sehat-storage-');
    final secureValues = _SecureValues();
    final first = TrustedLocalStorageComposition(
      directory: directory,
      secureValues: secureValues,
    );
    final database = await first.databases.open('owner-a');
    await database.customStatement(
      "INSERT INTO local_records (owner_id, entity_type, entity_key, schema_version, revision, payload_json, is_deleted, created_at_client, updated_at_client) VALUES ('owner-a', 'test', 'one', 1, 1, '{}', 0, 1, 1)",
    );
    await first.databases.close();

    final second = TrustedLocalStorageComposition(
      directory: directory,
      secureValues: secureValues,
    );
    final reopened = await second.databases.open('owner-a');
    final rows = await reopened
        .customSelect(
          "SELECT owner_id FROM local_records WHERE entity_type = 'test'",
        )
        .get();

    expect(rows.single.read<String>('owner_id'), 'owner-a');
    expect(secureValues.values, hasLength(1));
    await second.databases.close();
    await directory.delete(recursive: true);
  });

  test('empty application data directory is rejected', () {
    expect(
      () => TrustedLocalStorageComposition(
        directory: Directory(''),
        secureValues: _SecureValues(),
      ),
      throwsArgumentError,
    );
  });
}

class _SecureValues implements SecureValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
