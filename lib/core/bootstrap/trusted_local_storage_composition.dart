import 'dart:io';

import '../data/local/account_database_service.dart';
import '../data/local/account_key_resolver.dart';
import '../data/local/flutter_secure_account_key_vault.dart';

/// Composes encrypted account databases with platform-protected key storage.
/// The caller supplies the platform-approved application data directory; no
/// broad or user-visible filesystem path is inferred here.
class TrustedLocalStorageComposition {
  factory TrustedLocalStorageComposition({
    required Directory directory,
    SecureValueStore? secureValues,
    String? storageScope,
    List<String> legacyStorageScopes = const [],
  }) {
    if (directory.path.trim().isEmpty) {
      throw ArgumentError('Application data directory is required');
    }
    final vault = FlutterSecureAccountKeyVault(
      secureValues ?? const FlutterSecureValueStore(),
      storageScope: storageScope,
      legacyStorageScopes: legacyStorageScopes,
    );
    return TrustedLocalStorageComposition._(
      AccountDatabaseService(
        directory,
        AccountKeyResolver(vault),
        storageScope: storageScope,
        legacyStorageScopes: legacyStorageScopes,
      ),
    );
  }

  const TrustedLocalStorageComposition._(this.databases);

  final AccountDatabaseService databases;
}
