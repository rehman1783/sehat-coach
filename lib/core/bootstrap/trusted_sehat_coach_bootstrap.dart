import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../features/account/data/encrypted_account_runtime.dart';
import '../../features/account/data/secure_account_lifecycle_port.dart';
import '../../features/account/presentation/controllers/account_safety_controller.dart';
import '../../features/account/presentation/controllers/account_switch_controller.dart';
import '../../features/bachat/domain/bachat_repository.dart';
import '../../features/location/domain/city_configuration.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/sync/domain/sync_pull_coordinator.dart';
import '../../features/sync/domain/sync_upload_coordinator.dart';
import '../data/local/flutter_secure_account_key_vault.dart';
import 'activated_profile_shell_composition.dart';
import 'trusted_account_application_composition.dart';
import 'trusted_account_core_composition.dart';
import 'trusted_platform_account_composition.dart';

/// Final local bootstrap facade consumed by the executable after platform and
/// provider adapters are configured.
///
/// This facade embeds no credentials, endpoints, filesystem guesses or fake
/// identities. It only connects explicit trusted capabilities.
class TrustedSehatCoachBootstrap {
  factory TrustedSehatCoachBootstrap({
    required Directory applicationDataDirectory,
    required TrustedAccountProviderPorts provider,
    required DecryptedAccountMemoryClearer clearDecryptedMemory,
    required Future<void> Function() onAuthenticated,
    required ActivatedShellFactory createShell,
    required OwnerAction synchronizeOwner,
    required OwnerAction clearOwnerSession,
    required OwnerDecision deleteCloudAccount,
    required OwnerDecision checkRecentAuthentication,
    required AccountSwitchConnectivityCheck connectivityCheck,
    required AccountSwitchReadyAction onReadyForAuthentication,
    required AccountAction onSignedOut,
    required AccountAction onAccountDeleted,
    required Future<void> Function(OnboardingState profile) onProfileCommitted,
    SecureValueStore? secureValues,
    String? storageScope,
    List<String> legacyStorageScopes = const [],
    AccountAction? onLocalDataCleared,
    ReauthenticateAccount? reauthenticate,
    AppLanguage initialLanguage = AppLanguage.english,
    bool detectLocation = false,
    PublishedCityConfiguration? bachatCities,
    BachatRepository? bachatRepository,
    SyncUploadTransport? syncUpload,
    SyncPullTransport? syncPull,
    Stream<bool>? networkLink,
    Listenable? profileRefresh,
    Widget? loading,
    Widget? initialError,
  }) {
    final platform = TrustedPlatformAccountComposition(
      applicationDataDirectory: applicationDataDirectory,
      provider: provider,
      secureValues: secureValues,
      storageScope: storageScope,
      legacyStorageScopes: legacyStorageScopes,
      clearDecryptedMemory: clearDecryptedMemory,
      onAuthenticated: onAuthenticated,
      syncUpload: syncUpload,
      syncPull: syncPull,
    );
    final application =
        TrustedAccountApplicationComposition.withAccountLifecycle(
          core: platform.core,
          createShell: createShell,
          synchronizeOwner: synchronizeOwner,
          clearOwnerSession: clearOwnerSession,
          deleteCloudAccount: deleteCloudAccount,
          checkRecentAuthentication: checkRecentAuthentication,
          connectivityCheck: connectivityCheck,
          onReadyForAuthentication: onReadyForAuthentication,
          onSignedOut: onSignedOut,
          onAccountDeleted: onAccountDeleted,
          onProfileCommitted: onProfileCommitted,
          onLocalDataCleared: onLocalDataCleared,
          reauthenticate: reauthenticate,
          initialLanguage: initialLanguage,
          detectLocation: detectLocation,
          bachatCities: bachatCities,
          bachatRepository: bachatRepository,
          loading: loading,
          initialError: initialError,
          networkLink: networkLink,
          profileRefresh: profileRefresh,
        );
    return TrustedSehatCoachBootstrap._(
      platform: platform,
      application: application,
    );
  }

  const TrustedSehatCoachBootstrap._({
    required this.platform,
    required this.application,
  });

  final TrustedPlatformAccountComposition platform;
  final TrustedAccountApplicationComposition application;

  TrustedAccountCoreComposition get core => platform.core;

  Widget build() => application.build();
}
