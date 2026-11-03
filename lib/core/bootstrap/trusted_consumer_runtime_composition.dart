import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../features/account/data/encrypted_account_runtime.dart';
import '../../features/account/data/secure_account_lifecycle_port.dart';
import '../../features/account/presentation/controllers/account_safety_controller.dart';
import '../../features/account/presentation/controllers/account_switch_controller.dart';
import '../../features/account/domain/account_reauthentication_coordinator.dart';
import '../../features/account/domain/reauthenticate_account_use_cases.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/sync/domain/sync_pull_coordinator.dart';
import '../../features/sync/domain/sync_upload_coordinator.dart';
import '../data/local/flutter_secure_account_key_vault.dart';
import 'activated_profile_shell_composition.dart';
import 'trusted_account_core_composition.dart';
import 'trusted_sehat_coach_bootstrap.dart';

/// Provider capabilities needed by the platform-independent consumer root.
class TrustedConsumerRuntimeServices {
  const TrustedConsumerRuntimeServices({
    required this.provider,
    required this.clearOwnerSession,
    required this.deleteCloudAccount,
    required this.checkRecentAuthentication,
    required this.reauthentication,
    required this.syncUpload,
    required this.syncPull,
  });

  final TrustedAccountProviderPorts provider;
  final OwnerAction clearOwnerSession;
  final OwnerDecision deleteCloudAccount;
  final OwnerDecision checkRecentAuthentication;
  final AccountReauthenticationPort reauthentication;
  final SyncUploadTransport syncUpload;
  final SyncPullTransport syncPull;
}

/// UI effects that cannot be inferred from authentication or durable storage.
class TrustedConsumerRuntimeEffects {
  const TrustedConsumerRuntimeEffects({
    required this.clearDecryptedMemory,
    required this.onAuthenticated,
    required this.createShell,
    required this.onReadyForAuthentication,
    required this.onSignedOut,
    required this.onAccountDeleted,
    required this.onProfileCommitted,
    this.onLocalDataCleared,
    this.reauthenticate,
    this.reauthenticationPrompts,
  });

  final DecryptedAccountMemoryClearer clearDecryptedMemory;
  final Future<void> Function() onAuthenticated;
  final ActivatedShellFactory createShell;
  final AccountSwitchReadyAction onReadyForAuthentication;
  final AccountAction onSignedOut;
  final AccountAction onAccountDeleted;
  final Future<void> Function(OnboardingState profile) onProfileCommitted;
  final AccountAction? onLocalDataCleared;
  final ReauthenticateAccount? reauthenticate;
  final AccountReauthenticationPrompts? reauthenticationPrompts;
}

/// Builds the complete consumer root and derives owner synchronization from
/// the active verified session instead of accepting an unrelated callback.
TrustedSehatCoachBootstrap composeTrustedConsumerRuntime({
  required Directory applicationDataDirectory,
  required TrustedConsumerRuntimeServices services,
  required TrustedConsumerRuntimeEffects effects,
  required Future<bool> Function() connectivityCheck,
  required Stream<bool> networkLink,
  SecureValueStore? secureValues,
  String? storageScope,
  List<String> legacyStorageScopes = const [],
  AppLanguage initialLanguage = AppLanguage.english,
  bool detectLocation = false,
  Widget? loading,
  Widget? initialError,
}) {
  late final TrustedSehatCoachBootstrap bootstrap;
  final profileRefresh = ValueNotifier<int>(0);

  Future<void> synchronizeOwner(String ownerId) async {
    if (ownerId.trim().isEmpty ||
        bootstrap.core.runtime.activeOwnerId != ownerId) {
      throw StateError('Synchronization owner is not the active account');
    }
    await (await bootstrap.core.features.createSyncExecution()).run();
  }

  Future<void> profileCommitted(OnboardingState profile) async {
    await effects.onProfileCommitted(profile);
    profileRefresh.value++;
  }

  ReauthenticateAccount? reauthenticate;
  if (effects.reauthenticate != null) {
    reauthenticate = effects.reauthenticate;
  } else if (effects.reauthenticationPrompts != null) {
    reauthenticate = () => AccountReauthenticationCoordinator(
      session: bootstrap.core.identitySession,
      port: services.reauthentication,
      prompts: effects.reauthenticationPrompts!,
    ).call();
  }

  Future<void> readyForAuthentication() async {
    await bootstrap.core.identitySession.withIdentity(
      (identity) => services.clearOwnerSession(identity.uid),
    );
    await effects.onReadyForAuthentication();
  }

  bootstrap = TrustedSehatCoachBootstrap(
    applicationDataDirectory: applicationDataDirectory,
    provider: services.provider,
    clearDecryptedMemory: effects.clearDecryptedMemory,
    onAuthenticated: effects.onAuthenticated,
    createShell: effects.createShell,
    synchronizeOwner: synchronizeOwner,
    clearOwnerSession: services.clearOwnerSession,
    deleteCloudAccount: services.deleteCloudAccount,
    checkRecentAuthentication: services.checkRecentAuthentication,
    connectivityCheck: connectivityCheck,
    onReadyForAuthentication: readyForAuthentication,
    onSignedOut: effects.onSignedOut,
    onAccountDeleted: effects.onAccountDeleted,
    onProfileCommitted: profileCommitted,
    secureValues: secureValues,
    storageScope: storageScope,
    legacyStorageScopes: legacyStorageScopes,
    onLocalDataCleared: effects.onLocalDataCleared,
    reauthenticate: reauthenticate,
    initialLanguage: initialLanguage,
    detectLocation: detectLocation,
    syncUpload: services.syncUpload,
    syncPull: services.syncPull,
    networkLink: networkLink,
    profileRefresh: profileRefresh,
    loading: loading,
    initialError: initialError,
  );
  return bootstrap;
}
