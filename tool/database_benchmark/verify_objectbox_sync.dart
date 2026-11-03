import 'dart:io';

import 'lib/entities.dart';
import 'lib/objectbox.g.dart';

Future<void> main() async {
  final directory = await Directory.systemTemp.createTemp('sehat-obx-sync-');
  Store open() => Store(getObjectBoxModel(), directory: directory.path);
  var store = open();
  final firstId = store.box<SyncProfile>().put(
    SyncProfile(owner: 'owner-a', value: 'initial'),
  );
  final otherId = store.box<SyncProfile>().put(
    SyncProfile(owner: 'owner-b', value: 'other'),
  );

  void save(int expected, String value, {bool fail = false}) {
    store.runInTransaction<void>(TxMode.write, () {
      final profile = store.box<SyncProfile>().get(firstId)!;
      if (profile.revision != expected) throw StateError('revision-conflict');
      profile.revision++;
      profile.value = value;
      store.box<SyncProfile>().put(profile);
      if (fail) throw StateError('injected-outbox-failure');
      store.box<OutboxEntry>().put(
        OutboxEntry(
          operationKey: '${profile.owner}:${profile.revision}',
          owner: profile.owner,
          revision: profile.revision,
          value: value,
        ),
      );
    });
  }

  void check() {
    final profile = store.box<SyncProfile>().get(firstId)!;
    final entries = store.box<OutboxEntry>().getAll();
    if (profile.revision != 1 ||
        profile.value != 'updated' ||
        entries.length != 1 ||
        entries.single.owner != 'owner-a' ||
        entries.single.revision != 1 ||
        entries.single.value != 'updated') {
      throw StateError('Record/outbox atomicity failed');
    }
    if (store.box<SyncProfile>().get(otherId)!.value != 'other')
      throw StateError('Cross-owner change');
  }

  try {
    save(0, 'updated');
    for (final scenario in [true, false]) {
      var rejected = false;
      try {
        save(scenario ? 1 : 0, scenario ? 'partial' : 'stale', fail: scenario);
      } on StateError catch (error) {
        if (error.message !=
            (scenario ? 'injected-outbox-failure' : 'revision-conflict'))
          rethrow;
        rejected = true;
      }
      if (!rejected) throw StateError('Expected rejected write');
      check();
    }
  } finally {
    store.close();
  }
  store = open();
  try {
    check();
  } finally {
    store.close();
  }
  stdout.writeln(
    'ObjectBox: atomic record/outbox, failure rollback, stale revision rejection, owner isolation and reopen passed.',
  );
}
