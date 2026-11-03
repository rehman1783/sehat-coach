import 'dart:async';

typedef DecryptedMemoryDisposer = FutureOr<void> Function();

/// Owner-scoped registry for decrypted caches that outlive a single widget.
///
/// Entries are detached before cleanup begins, so a failure cannot leave stale
/// callbacks registered and every disposer still receives one cleanup attempt.
class DecryptedAccountMemoryRegistry {
  final Map<String, Map<Object, DecryptedMemoryDisposer>> _entries = {};

  void Function() register(String ownerId, DecryptedMemoryDisposer dispose) {
    final owner = _owner(ownerId);
    final token = Object();
    (_entries[owner] ??= {})[token] = dispose;
    var registered = true;
    return () {
      if (!registered) return;
      registered = false;
      final ownerEntries = _entries[owner];
      ownerEntries?.remove(token);
      if (ownerEntries?.isEmpty ?? false) _entries.remove(owner);
    };
  }

  int countFor(String ownerId) => _entries[_owner(ownerId)]?.length ?? 0;

  Future<void> clear(String ownerId) async {
    final owner = _owner(ownerId);
    final disposers = _entries.remove(owner)?.values.toList(growable: false);
    if (disposers == null) return;

    Object? firstError;
    StackTrace? firstStack;
    for (final dispose in disposers) {
      try {
        await dispose();
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStack ??= stackTrace;
      }
    }
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStack!);
    }
  }

  static String _owner(String ownerId) {
    final owner = ownerId.trim();
    if (owner.isEmpty || owner.length > 128) {
      throw ArgumentError.value(ownerId, 'ownerId');
    }
    return owner;
  }
}
