import 'package:http/http.dart' as http;

import '../../features/account/domain/authenticated_owner_session.dart';
import '../../features/entitlements/data/flutter_play_billing_adapter.dart';
import '../../features/entitlements/data/trusted_billing_backend_gateway.dart';
import '../../features/entitlements/data/trusted_billing_state_gateway.dart';
import '../../features/entitlements/domain/billing_reconciliation.dart';
import '../../features/entitlements/domain/billing_state_refresh.dart';
import '../../features/entitlements/domain/billing_telemetry.dart';
import '../../features/entitlements/domain/paywall_purchase.dart';
import '../../features/entitlements/domain/product_catalog.dart';
import '../../features/entitlements/domain/verified_entitlement_cache.dart';
import '../../features/entitlements/presentation/controllers/entitlement_controller.dart';
import '../../features/entitlements/presentation/controllers/paywall_controller.dart';
import '../services/trusted_backend_tokens.dart';

/// Owner-bound composition for monetization features.
///
/// Construct this only after authentication is verified. The Play adapter is
/// shared so its purchase listener begins once and remains available across
/// Plan and paywall screens.
class ActivatedBillingFeatures {
  factory ActivatedBillingFeatures({
    required AuthenticatedOwnerSession ownerSession,
    required Uri backendEndpoint,
    required http.Client httpClient,
    required FirebaseIdTokenProvider idTokens,
    required FirebaseAppCheckTokenProvider appCheckTokens,
    required EntitlementProductCatalogGateway productCatalog,
    required String Function() idempotencyKeys,
    required bool Function() isOnline,
    InAppPurchaseClient? playClient,
    DateTime Function()? clock,
    VerifiedEntitlementCache? verifiedCache,
    Uri? stateEndpoint,
    Duration purchaseTimeout = const Duration(minutes: 5),
    Duration restoreSettleDelay = const Duration(milliseconds: 500),
    Duration restoreTimeout = const Duration(seconds: 15),
    BillingTelemetrySink telemetry = const NoopBillingTelemetrySink(),
  }) {
    final play = FlutterPlayBillingAdapter(
      client: playClient ?? FlutterInAppPurchaseClient(),
      purchaseTimeout: purchaseTimeout,
      restoreSettleDelay: restoreSettleDelay,
      restoreTimeout: restoreTimeout,
    );
    final backend = TrustedBillingBackendGateway(
      endpoint: backendEndpoint,
      client: httpClient,
      idTokens: idTokens,
      appCheckTokens: appCheckTokens,
    );
    final rawStateGateway = stateEndpoint == null
        ? null
        : TrustedBillingStateGateway(
            endpoint: stateEndpoint,
            client: httpClient,
            idTokens: idTokens,
            appCheckTokens: appCheckTokens,
          );
    return ActivatedBillingFeatures._(
      ownerSession: ownerSession,
      play: play,
      backend: verifiedCache == null
          ? backend
          : CachingBillingReconciliationGateway(
              delegate: backend,
              cache: verifiedCache,
            ),
      verifiedCache: verifiedCache,
      stateGateway: rawStateGateway == null
          ? null
          : verifiedCache == null
          ? rawStateGateway
          : CachingBillingStateGateway(
              delegate: rawStateGateway,
              cache: verifiedCache,
            ),
      productCatalog: productCatalog,
      idempotencyKeys: idempotencyKeys,
      isOnline: isOnline,
      clock: clock ?? DateTime.now,
      telemetry: telemetry,
    );
  }

  ActivatedBillingFeatures._({
    required this._ownerSession,
    required this._play,
    required this._backend,
    required this._verifiedCache,
    required this._stateGateway,
    required this._productCatalog,
    required this._idempotencyKeys,
    required this._isOnline,
    required this._clock,
    required this._telemetry,
  });

  final AuthenticatedOwnerSession _ownerSession;
  final FlutterPlayBillingAdapter _play;
  final BillingReconciliationGateway _backend;
  final VerifiedEntitlementCache? _verifiedCache;
  final BillingStateGateway? _stateGateway;
  final EntitlementProductCatalogGateway _productCatalog;
  final String Function() _idempotencyKeys;
  final bool Function() _isOnline;
  final DateTime Function() _clock;
  final BillingTelemetrySink _telemetry;
  bool _disposed = false;
  Future<void>? _disposeFuture;

  Future<EntitlementController> createEntitlementController() {
    _ensureActive();
    return _ownerSession.withOwner((ownerId) async {
      _ensureActive();
      final cached = await _verifiedCache?.read(ownerId);
      _ensureActive();
      return EntitlementController(
        ownerId: ownerId,
        restoreCoordinator: BillingRestoreCoordinator(
          ownerId: ownerId,
          purchaseSource: _play,
          gateway: _backend,
          finalizer: _play,
          idempotencyKeys: _idempotencyKeys,
        ),
        refreshCoordinator: _stateGateway == null
            ? null
            : BillingRefreshCoordinator(
                ownerId: ownerId,
                gateway: _stateGateway,
              ),
        clock: () => _clock().toUtc(),
        initiallyOnline: _isOnline(),
        initialEntitlement: cached?.entitlement,
        initialCreditBalance: cached?.creditBalance,
        initialHistory: cached?.ledgerEntries ?? const [],
        telemetry: _telemetry,
      );
    });
  }

  Future<PaywallController> createPaywallController(
    EntitlementController entitlement,
  ) {
    _ensureActive();
    return _ownerSession.withOwner((ownerId) async {
      _ensureActive();
      if (entitlement.ownerId != ownerId) {
        throw StateError(
          'Entitlement controller owner changed during composition',
        );
      }
      return PaywallController(
        productsLoader: LoadPaywallProducts(
          configuration: _productCatalog,
          playCatalog: _play,
        ),
        purchaseCoordinator: PaywallPurchaseCoordinator(
          ownerId: ownerId,
          launcher: _play,
          reconciliation: _backend,
          finalizer: _play,
          idempotencyKeys: _idempotencyKeys,
        ),
        onVerifiedPurchase: entitlement.applyVerifiedPurchase,
        initiallyOnline: _isOnline(),
        telemetry: _telemetry,
      );
    });
  }

  void _ensureActive() {
    if (_disposed) throw StateError('billing_features_disposed');
  }

  Future<void> dispose() {
    final existing = _disposeFuture;
    if (existing != null) return existing;
    _disposed = true;
    final future = _play.dispose();
    _disposeFuture = future;
    return future;
  }
}
