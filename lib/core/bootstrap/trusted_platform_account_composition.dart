import 'dart:io';

import '../../features/account/data/encrypted_account_runtime.dart';
import '../../features/ai_logging/domain/ai_assisted_logging.dart';
import '../../features/sync/domain/sync_pull_coordinator.dart';
import '../../features/sync/domain/sync_upload_coordinator.dart';
import '../data/local/flutter_secure_account_key_vault.dart';
import 'trusted_account_core_composition.dart';
import 'trusted_local_storage_composition.dart';

/// Platform bootstrap boundary for the complete trusted account core.
///
/// The platform supplies location and secure-storage capabilities; provider
/// authentication remains behind domain ports. No credentials, paths or fake
/// identities are embedded by this composition.
class TrustedPlatformAccountComposition {
  factory TrustedPlatformAccountComposition({
    required Directory applicationDataDirectory,
    required TrustedAccountProviderPorts provider,
    required DecryptedAccountMemoryClearer clearDecryptedMemory,
    required Future<void> Function() onAuthenticated,
    SecureValueStore? secureValues,
    String? storageScope,
    List<String> legacyStorageScopes = const [],
    SyncUploadTransport? syncUpload,
    SyncPullTransport? syncPull,
    AiLoggingGateway? aiLogging,
  }) {
    final storage = TrustedLocalStorageComposition(
      directory: applicationDataDirectory,
      secureValues: secureValues,
      storageScope: storageScope,
      legacyStorageScopes: legacyStorageScopes,
    );
    return TrustedPlatformAccountComposition._(
      storage: storage,
      core: TrustedAccountCoreComposition(
        provider: provider,
        databases: storage.databases,
        clearDecryptedMemory: clearDecryptedMemory,
        onAuthenticated: onAuthenticated,
        syncUpload: syncUpload,
        syncPull: syncPull,
        aiLogging: aiLogging,
      ),
    );
  }

  const TrustedPlatformAccountComposition._({
    required this.storage,
    required this.core,
  });

  final TrustedLocalStorageComposition storage;
  final TrustedAccountCoreComposition core;
}
