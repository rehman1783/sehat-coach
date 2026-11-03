import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';

import 'account_key_resolver.dart';
import 'app_database.dart';
import 'encrypted_database_opener.dart';
import 'owner_storage_identity.dart';

/// One instance must own database access for the application session.
/// Callers must close it before switching accounts or clearing protected keys.
abstract interface class AccountLocalDataBoundary {
  Future<int> pendingChangeCount(String authenticatedOwnerId);
  Future<bool> clearIfFullySynced(String authenticatedOwnerId);
}

abstract interface class AccountLocalDataResetBoundary
    implements AccountLocalDataBoundary {
  /// Clears synchronized local data, then opens a new empty encrypted runtime
  /// for the same still-authenticated owner.
  Future<bool> resetIfFullySynced(String authenticatedOwnerId);
}

class AccountDatabaseArtifactMigrationFailure implements Exception {
  const AccountDatabaseArtifactMigrationFailure();
}

class AccountDatabaseService implements AccountLocalDataResetBoundary {
  AccountDatabaseService(
    this.directory,
    this.keys, {
    this.storageScope,
    this.legacyStorageScopes = const [],
  });
  final Directory directory;
  final AccountKeyResolver keys;
  final String? storageScope;
  final List<String> legacyStorageScopes;
  AppDatabase? _database;
  String? _owner;
  bool _busy = false;

  String? get activeOwnerId => _owner;

  File fileForOwner(String ownerId) {
    final name = ownerStorageDigest(ownerId, scope: storageScope);
    return File('${directory.path}/account-$name.sqlite');
  }

  Future<AppDatabase> open(String authenticatedOwnerId) async {
    if (_busy) throw StateError('Account database operation in progress');
    _busy = true;
    try {
      final file = fileForOwner(authenticatedOwnerId);
      if (_database != null) {
        if (_owner != authenticatedOwnerId) {
          throw StateError('Close the active account before switching');
        }
        return _database!;
      }
      await directory.create(recursive: true);
      await _migrateLegacyArtifacts(authenticatedOwnerId, file);
      final key = await keys.resolve(
        authenticatedOwnerId,
        databaseExists: await file.exists(),
      );
      try {
        final database = await openEncryptedDatabase(file, key);
        _database = database;
        _owner = authenticatedOwnerId;
        return database;
      } finally {
        key.fillRange(0, key.length, 0);
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> close() async {
    if (_busy) throw StateError('Account database operation in progress');
    _busy = true;
    try {
      await _database?.close();
      _database = null;
      _owner = null;
    } finally {
      _busy = false;
    }
  }

  @override
  Future<int> pendingChangeCount(String authenticatedOwnerId) async {
    final database = _requireActiveOwner(authenticatedOwnerId);
    final count = countAll();
    final query = database.selectOnly(database.syncOutboxEntries)
      ..addColumns([count])
      ..where(database.syncOutboxEntries.ownerId.equals(authenticatedOwnerId));
    return (await query.getSingle()).read(count) ?? 0;
  }

  /// Serializes the final pending check, database close, file removal and key
  /// removal through this service. Every account database consumer must honor
  /// this service lifecycle for the boundary to hold.
  @override
  Future<bool> clearIfFullySynced(String authenticatedOwnerId) async {
    if (_busy) throw StateError('Account database operation in progress');
    _busy = true;
    try {
      final database = _requireActiveOwner(authenticatedOwnerId);
      final count = countAll();
      final query = database.selectOnly(database.syncOutboxEntries)
        ..addColumns([count])
        ..where(
          database.syncOutboxEntries.ownerId.equals(authenticatedOwnerId),
        );
      if (((await query.getSingle()).read(count) ?? 0) > 0) return false;

      await database.close();
      _database = null;
      _owner = null;
      final file = fileForOwner(authenticatedOwnerId);
      await _deleteDatabaseArtifacts(file);
      await keys.delete(authenticatedOwnerId);
      return true;
    } finally {
      _busy = false;
    }
  }

  @override
  Future<bool> resetIfFullySynced(String authenticatedOwnerId) async {
    if (!await clearIfFullySynced(authenticatedOwnerId)) return false;
    await open(authenticatedOwnerId);
    return true;
  }

  AppDatabase _requireActiveOwner(String ownerId) {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
    if (_database == null || _owner != ownerId) {
      throw StateError('Active account database does not match owner');
    }
    return _database!;
  }

  Future<void> _deleteDatabaseArtifacts(File databaseFile) async {
    // Delete sidecars first and the main file last. If a sidecar deletion fails,
    // the encrypted database and its key remain available for explicit retry.
    for (final suffix in const ['-wal', '-shm', '-journal', '']) {
      final artifact = File('${databaseFile.path}$suffix');
      if (await artifact.exists()) await artifact.delete();
    }
  }

  Future<void> _migrateLegacyArtifacts(String ownerId, File hashedFile) async {
    try {
      if (await hashedFile.exists()) return;
      final legacyCandidates = [
        for (final legacyScope in legacyStorageScopes)
          File(
            '${directory.path}/account-${ownerStorageDigest(ownerId, scope: legacyScope)}.sqlite',
          ),
        if (storageScope != null)
          File(
            '${directory.path}/account-${ownerStorageDigest(ownerId)}.sqlite',
          ),
        _legacyFileForOwner(ownerId),
      ];
      final existing = <File>[];
      final seenPaths = <String>{};
      for (final candidate in legacyCandidates) {
        if (seenPaths.add(candidate.path) && await candidate.exists()) {
          existing.add(candidate);
        }
      }
      if (existing.isEmpty) return;
      if (existing.length != 1) {
        throw const AccountDatabaseArtifactMigrationFailure();
      }
      final legacyFile = existing.single;

      // Sidecars move first and the main database last. An interruption is
      // resumable while the legacy main file remains authoritative.
      for (final suffix in const ['-wal', '-shm', '-journal', '']) {
        final source = File('${legacyFile.path}$suffix');
        if (!await source.exists()) continue;
        final destination = File('${hashedFile.path}$suffix');
        if (await destination.exists()) {
          throw const AccountDatabaseArtifactMigrationFailure();
        }
        await source.rename(destination.path);
      }
    } on AccountDatabaseArtifactMigrationFailure {
      rethrow;
    } on FileSystemException {
      throw const AccountDatabaseArtifactMigrationFailure();
    }
  }

  File _legacyFileForOwner(String ownerId) {
    final legacyName = utf8
        .encode(ownerId)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return File('${directory.path}/account-$legacyName.sqlite');
  }
}
