import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

class ProofDatabase extends GeneratedDatabase {
  ProofDatabase(File file, String? key)
    : super(
        NativeDatabase(
          file,
          setup: (raw) {
            if (raw.select('PRAGMA cipher').isEmpty) {
              throw StateError('Encrypted SQLite runtime unavailable');
            }
            if (key != null) {
              raw.execute("PRAGMA key = '$key'");
            }
          },
        ),
      );
  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
}

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp(
    'sehat-encrypted-proof-',
  );
  final file = File('${directory.path}/health.sqlite');
  final random = Random.secure();
  final key = List.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  Future<bool> readable(String? candidate) async {
    final db = ProofDatabase(file, candidate);
    try {
      final row = await db.customSelect('SELECT value FROM secret').getSingle();
      return row.read<String>('value') == 'synthetic health record';
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  }

  final db = ProofDatabase(file, key);
  try {
    await db.customStatement('CREATE TABLE secret (value TEXT NOT NULL)');
    await db.customStatement(
      "INSERT INTO secret VALUES ('synthetic health record')",
    );
  } finally {
    await db.close();
  }
  if (!await readable(key)) throw StateError('Correct key failed');
  if (await readable(null)) throw StateError('Missing key read encrypted data');
  if (await readable('00' * 32)) {
    throw StateError('Wrong key read encrypted data');
  }
  final migrationDb = ProofDatabase(file, key);
  try {
    await migrationDb.customStatement(
      'ALTER TABLE secret ADD COLUMN synced INTEGER NOT NULL DEFAULT 0',
    );
    try {
      await migrationDb.transaction(() async {
        await migrationDb.customStatement(
          "INSERT INTO secret (value) VALUES ('must roll back')",
        );
        throw StateError('Synthetic transaction failure');
      });
    } on StateError catch (error) {
      if (error.message != 'Synthetic transaction failure') rethrow;
    }
    final rows = await migrationDb
        .customSelect('SELECT value, synced FROM secret')
        .get();
    if (rows.length != 1 || rows.single.read<int>('synced') != 0) {
      throw StateError('Encrypted migration or rollback failed');
    }
  } finally {
    await migrationDb.close();
  }
  if (!await readable(key)) throw StateError('Migrated data failed to reopen');
  final plain = sql.sqlite3.open(file.path);
  try {
    var readableWithoutCipher = false;
    try {
      plain.select('SELECT value FROM secret');
      readableWithoutCipher = true;
    } catch (_) {}
    if (readableWithoutCipher) throw StateError('Unkeyed SQLite read data');
  } finally {
    plain.close();
  }
  stdout.writeln(
    'Encrypted Drift proof passed: key isolation, migration, rollback and reopen.',
  );
  stdout.writeln('Scratch database retained: ${file.path}');
}
