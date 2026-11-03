import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';

import 'app_database.dart';

class EncryptedDatabaseOpenFailure implements Exception {
  const EncryptedDatabaseOpenFailure();
}

/// Native connection factory. The caller supplies a resolved account path and
/// key from protected storage. Never retries with plaintext or a replacement key.
Future<AppDatabase> openEncryptedDatabase(File file, Uint8List key) async {
  if (key.length != 32) {
    throw ArgumentError('A 32-byte database key is required');
  }
  final hex = key.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  final database = AppDatabase(
    NativeDatabase(
      file,
      setup: (raw) {
        if (raw.select('PRAGMA cipher').isEmpty) {
          throw StateError('Encrypted SQLite runtime unavailable');
        }
        // Hex encoding makes the interpolated passphrase SQL-safe.
        raw.execute("PRAGMA key = '$hex'");
      },
    ),
  );
  try {
    // Force opening, key verification and schema initialization before return.
    await database
        .customSelect('SELECT count(*) FROM sqlite_master')
        .getSingle();
    final integrityRows = await database
        .customSelect('PRAGMA quick_check(1)')
        .get();
    final integrityResult = integrityRows.length == 1
        ? integrityRows.single.data.values.singleOrNull
        : null;
    if (integrityResult != 'ok') {
      throw StateError('Encrypted database integrity check failed');
    }
    return database;
  } catch (error, stackTrace) {
    await database.close();
    Error.throwWithStackTrace(const EncryptedDatabaseOpenFailure(), stackTrace);
  }
}
