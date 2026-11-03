import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Stable, one-way local identifier for an exact authenticated owner ID.
///
/// The original value must never be used in filenames or secure-storage keys.
String ownerStorageDigest(String ownerId, {String? scope}) {
  if (ownerId.trim().isEmpty ||
      ownerId.length > 128 ||
      ownerId.contains('\u0000')) {
    throw ArgumentError('Owner is invalid');
  }
  if (scope != null &&
      (scope.trim().isEmpty ||
          scope.length > 128 ||
          scope.contains('\u0000'))) {
    throw ArgumentError('Storage scope is invalid');
  }
  final scopedIdentity = scope == null ? ownerId : '$scope\u0000$ownerId';
  return sha256.convert(utf8.encode(scopedIdentity)).toString();
}
