import 'dart:io';

import 'package:drift/drift.dart';

import 'lib/drift_store.dart';

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp('sehat-sync-');
  final file = File('${directory.path}/sync.sqlite');
  var db = BenchmarkDatabase(file);
  Future<void> save(
    int expectedRevision,
    String value, {
    bool fail = false,
  }) async {
    await db.transaction(() async {
      final count = await db.customUpdate(
        'UPDATE profile SET value = ?, revision = revision + 1 WHERE owner = ? AND revision = ?',
        variables: [
          Variable(value),
          const Variable('owner-a'),
          Variable(expectedRevision),
        ],
      );
      if (count != 1) throw StateError('revision-conflict');
      if (fail) throw StateError('injected-outbox-failure');
      await db.customStatement(
        'INSERT INTO outbox (owner, revision, value) VALUES (?, ?, ?)',
        ['owner-a', expectedRevision + 1, value],
      );
    });
  }

  Future<void> check() async {
    final profile = await db
        .customSelect("SELECT * FROM profile WHERE owner = 'owner-a'")
        .getSingle();
    final events = await db.customSelect('SELECT * FROM outbox').get();
    if (profile.read<int>('revision') != 1 ||
        profile.read<String>('value') != 'updated' ||
        events.length != 1 ||
        events.single.read<int>('revision') != 1 ||
        events.single.read<String>('value') != 'updated') {
      throw StateError('Record/outbox atomicity failed');
    }
    final other = await db
        .customSelect("SELECT value FROM profile WHERE owner = 'owner-b'")
        .getSingle();
    if (other.read<String>('value') != 'other')
      throw StateError('Cross-owner change');
  }

  try {
    await db.customStatement(
      'CREATE TABLE profile (owner TEXT PRIMARY KEY, revision INTEGER NOT NULL, value TEXT NOT NULL)',
    );
    await db.customStatement(
      'CREATE TABLE outbox (owner TEXT NOT NULL, revision INTEGER NOT NULL, value TEXT NOT NULL, PRIMARY KEY(owner, revision))',
    );
    await db.customStatement(
      "INSERT INTO profile VALUES ('owner-a', 0, 'initial'), ('owner-b', 0, 'other')",
    );
    await save(0, 'updated');
    for (final attempt in [
      () => save(1, 'partial', fail: true),
      () => save(0, 'stale'),
    ]) {
      var failed = false;
      try {
        await attempt();
      } on StateError {
        failed = true;
      }
      if (!failed) throw StateError('Expected rejected write');
      await check();
    }
  } finally {
    await db.close();
  }
  db = BenchmarkDatabase(file);
  try {
    await check();
  } finally {
    await db.close();
  }
  stdout.writeln(
    'Drift: atomic record/outbox, failure rollback, stale revision rejection, owner isolation and reopen passed.',
  );
}
