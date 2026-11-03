import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'account_key_resolver.dart';
import 'owner_storage_identity.dart';

abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureValueStore implements SecureValueStore {
  const FlutterSecureValueStore([
    this.storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(storageNamespace: 'sehat_coach_account_keys'),
    ),
  ]);

  final FlutterSecureStorage storage;

  @override
  Future<String?> read(String key) => storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => storage.delete(key: key);
}

/// Platform-protected key vault. Creation is coalesced within this process.
class FlutterSecureAccountKeyVault implements AccountKeyVault {
  FlutterSecureAccountKeyVault(
    this._store, {
    this.storageScope,
    this.legacyStorageScopes = const [],
  });

  final SecureValueStore _store;
  final String? storageScope;
  final List<String> legacyStorageScopes;
  final Map<String, Future<Uint8List>> _creates = {};

  String _storageKey(String ownerId) {
    final ownerHash = ownerStorageDigest(ownerId, scope: storageScope);
    return 'sehat.account.db-key.v1.$ownerHash';
  }

  List<String> _legacyStorageKeys(String ownerId) => {
    for (final scope in legacyStorageScopes)
      'sehat.account.db-key.v1.${ownerStorageDigest(ownerId, scope: scope)}',
    if (storageScope != null)
      'sehat.account.db-key.v1.${ownerStorageDigest(ownerId)}',
  }.toList(growable: false);

  @override
  Future<Uint8List?> read(String ownerId) async {
    final storageKey = _storageKey(ownerId);
    var encoded = await _store.read(storageKey);
    final legacyKeys = _legacyStorageKeys(ownerId);
    if (encoded == null) {
      final legacyValues = <String, String>{};
      for (final legacyKey in legacyKeys) {
        final value = await _store.read(legacyKey);
        if (value != null) legacyValues[legacyKey] = value;
      }
      if (legacyValues.values.toSet().length > 1) {
        return Uint8List(0);
      }
      if (legacyValues.isNotEmpty) {
        encoded = legacyValues.values.first;
        await _store.write(storageKey, encoded);
        for (final legacyKey in legacyValues.keys) {
          await _store.delete(legacyKey);
        }
      }
    }
    if (encoded == null) return null;
    try {
      return Uint8List.fromList(base64Url.decode(encoded));
    } on FormatException {
      return Uint8List(0);
    }
  }

  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async {
    final storageKey = _storageKey(ownerId);
    final active = _creates[storageKey];
    if (active != null) return Uint8List.fromList(await active);
    final creation = _create(ownerId, storageKey, candidate);
    _creates[storageKey] = creation;
    try {
      return Uint8List.fromList(await creation);
    } finally {
      if (identical(_creates[storageKey], creation)) {
        _creates.remove(storageKey);
      }
    }
  }

  Future<Uint8List> _create(
    String ownerId,
    String storageKey,
    Uint8List candidate,
  ) async {
    final existing = await read(ownerId);
    if (existing != null) {
      return existing;
    }
    final snapshot = Uint8List.fromList(candidate);
    await _store.write(storageKey, base64Url.encode(snapshot));
    return snapshot;
  }

  @override
  Future<void> delete(String ownerId) async {
    final storageKey = _storageKey(ownerId);
    final active = _creates[storageKey];
    if (active != null) await active;
    await _store.delete(storageKey);
    for (final legacyKey in _legacyStorageKeys(ownerId)) {
      await _store.delete(legacyKey);
    }
  }
}
