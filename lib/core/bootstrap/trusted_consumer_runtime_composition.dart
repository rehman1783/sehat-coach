import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../features/account/data/decrypted_account_memory_registry.dart';
import '../../features/account/data/encrypted_account_runtime.dart';
import '../../features/account/data/secure_account_lifecycle_port.dart';
import '../../features/account/domain/account_reauthentication_coordinator.dart';
import '../../features/account/domain/reauthenticate_account_use_cases.dart';
import '../../features/account/presentation/controllers/account_safety_controller.dart';
import '../../features/account/presentation/controllers/account_switch_controller.dart';
import '../../features/ai_logging/domain/ai_assisted_logging.dart';
import '../../features/entitlements/data/flutter_play_billing_adapter.dart';
import '../../features/entitlements/data/trusted_entitlement_product_catalog_gateway.dart';
import '../../features/entitlements/domain/billing_telemetry.dart';
import '../../features/entitlements/domain/verified_entitlement_cache.dart';
import '../../features/entitlements/presentation/controllers/entitlement_controller.dart';
import '../../features/entitlements/presentation/controllers/paywall_controller.dart';
import '../../features/onboarding/domain/models/onboarding_state.dart';
import '../../features/sync/domain/sync_pull_coordinator.dart';
import '../../features/sync/domain/sync_upload_coordinator.dart';
import '../data/local/flutter_secure_account_key_vault.dart';
import '../services/secure_operation_id.dart';
import '../services/trusted_backend_tokens.dart';
import 'activated_billing_features.dart';
import 'activated_home_composition.dart';
import 'activated_profile_shell_composition.dart';
import 'activated_shell_composition.dart';
import 'trusted_account_core_composition.dart';
import 'trusted_sehat_coach_bootstrap.dart';

typedef DecryptedMemoryRegistrar = void Function() Function(
  String ownerId,
  DecryptedMemoryDisposer dispose,
);

/// Non-secret backend and Play configuration for owner-bound monetization.
class TrustedBillingConfiguration {
  const TrustedBillingConfiguration({
    required this.backendEndpoint,
    required this.catalogEndpoint,
    required this.httpClient,
    required this.idTokens,
    required this.appCheckTokens,
    this.stateEndpoint,
    this.playClient,
    this.idempotencyKeys,
    this.clock,
    this.telemetry = const NoopBillingTelemetrySink(),
  });

  final Uri backendEndpoint;
  final Uri catalogEndpoint;
  final Uri? stateEndpoint;
  final http.Client httpClient;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;
  final InAppPurchaseClient? playClient;
  final String Function()? idempotencyKeys;
  final DateTime Function()? clock;
  final BillingTelemetrySink telemetry;
}

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
    this.aiLogging,
    this.billing,
  });

  final TrustedAccountProviderPorts provider;
  final OwnerAction clearOwnerSession;
  final OwnerDecision deleteCloudAccount;
  final OwnerDecision checkRecentAuthentication;
  final AccountReauthenticationPort reauthentication;
  final SyncUploadTransport syncUpload;
  final SyncPullTransport syncPull;
  final AiLoggingGateway? aiLogging;
  final TrustedBillingConfiguration? billing;
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
    this.registerDecryptedMemory,
    this.onLocalDataCleared,
    this.reauthenticate,
    this.reauthenticationPrompts,
  });

  final DecryptedAccountMemoryClearer clearDecryptedMemory;
  final DecryptedMemoryRegistrar? registerDecryptedMemory;
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
  final billingConfig = services.billing;
  final sharedNetworkLink = billingConfig == null
      ? networkLink
      : (networkLink.isBroadcast
            ? networkLink
            : networkLink.asBroadcastStream());

  _ActivatedBillingBinder? billingBinder;
  if (billingConfig != null) {
    billingBinder = _ActivatedBillingBinder(
      getBootstrap: () => bootstrap,
      config: billingConfig,
      connectivityCheck: connectivityCheck,
      networkLink: sharedNetworkLink,
      registerMemory: effects.registerDecryptedMemory,
    );
  }

  Future<void> clearDecryptedMemory(String ownerId) async {
    await billingBinder?.disposeForOwner(ownerId);
    await effects.clearDecryptedMemory(ownerId);
  }

  ActivatedShellComposition createShell(ActivatedHomeComposition home) {
    final shell = effects.createShell(home);
    if (billingBinder == null || shell.createEntitlements != null) {
      return shell;
    }
    return shell.withEntitlements(
      createEntitlements: billingBinder.createEntitlements,
      createPaywall: billingBinder.createPaywall,
    );
  }

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
    clearDecryptedMemory: clearDecryptedMemory,
    onAuthenticated: effects.onAuthenticated,
    createShell: createShell,
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
    aiLogging: services.aiLogging,
    networkLink: sharedNetworkLink,
    profileRefresh: profileRefresh,
    loading: loading,
    initialError: initialError,
  );
  return bootstrap;
}

class _ActivatedBillingBinder {
  _ActivatedBillingBinder({
    required this.getBootstrap,
    required this.config,
    required this.connectivityCheck,
    required this.networkLink,
    this.registerMemory,
  });

  final TrustedSehatCoachBootstrap Function() getBootstrap;
  final TrustedBillingConfiguration config;
  final Future<bool> Function() connectivityCheck;
  final Stream<bool> networkLink;
  final DecryptedMemoryRegistrar? registerMemory;

  int _generation = 0;
  String? _activeOwnerId;
  ActivatedBillingFeatures? _activeBilling;
  Future<ActivatedBillingFeatures>? _pendingBilling;
  String? _pendingOwnerId;
  StreamSubscription<bool>? _linkSubscription;
  void Function()? _unregisterMemory;
  bool _isOnline = true;
  final _entitlements = <WeakReference<EntitlementController>>[];
  final _paywalls = <WeakReference<PaywallController>>[];

  Future<ActivatedBillingFeatures> _ensureForOwner(
    String ownerId,
    VerifiedEntitlementCache cache,
  ) async {
    final existing = _activeBilling;
    if (existing != null && _activeOwnerId == ownerId) {
      return existing;
    }
    final pending = _pendingBilling;
    if (pending != null && _pendingOwnerId == ownerId) {
      return pending;
    }
    if (existing != null && _activeOwnerId != null) {
      await disposeForOwner(_activeOwnerId!);
    }

    final creation = _createForOwner(ownerId, cache, _generation);
    _pendingOwnerId = ownerId;
    _pendingBilling = creation;
    try {
      return await creation;
    } finally {
      if (identical(_pendingBilling, creation)) {
        _pendingBilling = null;
        _pendingOwnerId = null;
      }
    }
  }

  Future<ActivatedBillingFeatures> _createForOwner(
    String ownerId,
    VerifiedEntitlementCache cache,
    int startGeneration,
  ) async {
    final online = await connectivityCheck();
    if (_generation != startGeneration) {
      throw StateError('billing_features_disposed');
    }
    _isOnline = online;
    final subscription = networkLink.listen(_handleConnectivity);
    final features = getBootstrap().core.features;
    final idKeys =
        config.idempotencyKeys ?? SecureOperationIdGenerator('billing').nextId;
    final billing = ActivatedBillingFeatures(
      ownerSession: features.ownerSession,
      backendEndpoint: config.backendEndpoint,
      httpClient: config.httpClient,
      idTokens: config.idTokens,
      appCheckTokens: config.appCheckTokens,
      productCatalog: TrustedEntitlementProductCatalogGateway(
        endpoint: config.catalogEndpoint,
        client: config.httpClient,
        idTokens: config.idTokens,
        appCheckTokens: config.appCheckTokens,
      ),
      idempotencyKeys: idKeys,
      isOnline: () => _isOnline,
      playClient: config.playClient,
      clock: config.clock,
      verifiedCache: cache,
      stateEndpoint: config.stateEndpoint,
      telemetry: config.telemetry,
    );
    if (_generation != startGeneration) {
      await subscription.cancel();
      await billing.dispose();
      throw StateError('billing_features_disposed');
    }
    _linkSubscription = subscription;
    _activeOwnerId = ownerId;
    _activeBilling = billing;
    _unregisterMemory = registerMemory?.call(
      ownerId,
      () => disposeForOwner(ownerId),
    );
    return billing;
  }

  void _handleConnectivity(bool online) {
    _isOnline = online;
    _entitlements.removeWhere((ref) {
      final controller = ref.target;
      if (controller == null || controller.isClosed) return true;
      controller.setConnectivity(online);
      return false;
    });
    _paywalls.removeWhere((ref) {
      final controller = ref.target;
      if (controller == null || controller.isClosed) return true;
      controller.setConnectivity(online);
      return false;
    });
  }

  Future<EntitlementController> createEntitlements() async {
    final features = getBootstrap().core.features;
    final context = await features.createVerifiedEntitlementContext();
    final billing = await _ensureForOwner(context.ownerId, context.cache);
    final controller = await billing.createEntitlementController();
    if (controller.ownerId != context.ownerId) {
      throw StateError('Entitlement owner changed during composition');
    }
    _entitlements.add(WeakReference(controller));
    return controller;
  }

  Future<PaywallController> createPaywall(
    EntitlementController entitlement,
  ) async {
    final features = getBootstrap().core.features;
    final context = await features.createVerifiedEntitlementContext();
    if (context.ownerId != entitlement.ownerId) {
      throw StateError('Paywall owner does not match verified session');
    }
    final billing = await _ensureForOwner(context.ownerId, context.cache);
    final controller = await billing.createPaywallController(entitlement);
    _paywalls.add(WeakReference(controller));
    return controller;
  }

  Future<void> disposeForOwner(String ownerId) async {
    if (_activeOwnerId != ownerId && _pendingOwnerId != ownerId) return;
    _generation++;
    final billing = _activeBilling;
    final subscription = _linkSubscription;
    final unregister = _unregisterMemory;
    _activeOwnerId = null;
    _activeBilling = null;
    _linkSubscription = null;
    _unregisterMemory = null;
    _entitlements.clear();
    _paywalls.clear();
    unregister?.call();
    await subscription?.cancel();
    if (billing != null) {
      await billing.dispose();
    }
  }
}
