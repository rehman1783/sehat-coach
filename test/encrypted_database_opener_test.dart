import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/app_database.dart';
import 'package:sehat_coach/core/data/local/encrypted_database_opener.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('encrypted app schema survives reopen and rejects wrong keys', () async {
    final directory = await Directory.systemTemp.createTemp(
      'sehat-schema-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/account.sqlite');
    final key = Uint8List.fromList(List.generate(32, (i) => i + 1));
    final database = await openEncryptedDatabase(file, key);
    await database
        .into(database.syncCursors)
        .insert(
          SyncCursorsCompanion.insert(
            ownerId: 'synthetic-owner',
            cursor: 'saved-cursor',
            updatedAtClient: DateTime.utc(2026, 10, 21),
          ),
        );
    await database.close();
    await expectLater(
      openEncryptedDatabase(file, Uint8List(32)),
      throwsA(anything),
    );
    final reopened = await openEncryptedDatabase(file, key);
    try {
      expect(
        (await reopened.select(reopened.syncCursors).getSingle()).cursor,
        'saved-cursor',
      );
    } finally {
      await reopened.close();
    }
  });

  test(
    'damaged encrypted database fails closed before repository use',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'sehat-integrity-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/account.sqlite');
      final key = Uint8List.fromList(List.generate(32, (i) => 32 - i));
      final database = await openEncryptedDatabase(file, key);
      await database
          .into(database.syncCursors)
          .insert(
            SyncCursorsCompanion.insert(
              ownerId: 'synthetic-owner',
              cursor: 'saved-cursor',
              updatedAtClient: DateTime.utc(2026, 10, 27),
            ),
          );
      await database.close();

      final raw = sqlite.sqlite3.open(file.path);
      final hex = key
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      raw.execute("PRAGMA key = '$hex'");
      raw.execute('PRAGMA writable_schema = ON');
      raw.execute(
        "UPDATE sqlite_schema SET rootpage = 2147483647 "
        "WHERE type = 'table' AND name = 'sync_cursors'",
      );
      raw.execute('PRAGMA writable_schema = OFF');
      raw.close();

      await expectLater(
        openEncryptedDatabase(file, key),
        throwsA(isA<EncryptedDatabaseOpenFailure>()),
      );

      final renamed = File('${file.path}.damaged');
      await file.rename(renamed.path);
      expect(renamed.existsSync(), isTrue);
    },
  );
}
