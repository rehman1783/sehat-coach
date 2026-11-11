import '../config/app_config.dart';

typedef TrustedFirebaseServicesBuilder<T> = T Function(
  Uri adultEligibilityEndpoint,
  Uri accountDeletionEndpoint,
  Uri syncUploadEndpoint,
  Uri syncPullEndpoint,
);

/// Fail-closed, single-flight startup for the complete Firebase account bundle.
class TrustedFirebaseServicesStartup<T> {
  TrustedFirebaseServicesStartup({
    required this.config,
    required this.initializeFirebase,
    required this.buildServices,
  });

  final AppConfig config;
  final Future<void> Function() initializeFirebase;
  final TrustedFirebaseServicesBuilder<T> buildServices;
  Future<T>? _inFlight;
  T? _ready;

  Future<T> start() {
    final ready = _ready;
    if (ready != null) return Future.value(ready);
    return _inFlight ??= _startOnce();
  }

  Future<T> _startOnce() async {
    try {
      final eligibility = config.adultEligibilityEndpoint;
      final deletion = config.accountDeletionEndpoint;
      final syncUpload = config.syncUploadEndpoint;
      final syncPull = config.syncPullEndpoint;
      if (eligibility == null ||
          deletion == null ||
          syncUpload == null ||
          syncPull == null) {
        throw StateError('Trusted account backend endpoints are required.');
      }
      if ((config.billingBackendEndpoint == null) !=
          (config.entitlementCatalogEndpoint == null)) {
        throw StateError(
          'Billing backend and entitlement catalog endpoints must be supplied together.',
        );
      }
      if (config.billingStateEndpoint != null &&
          config.billingBackendEndpoint == null) {
        throw StateError(
          'Billing state endpoint requires billing backend and catalog endpoints.',
        );
      }
      await initializeFirebase();
      final services = buildServices(
        eligibility,
        deletion,
        syncUpload,
        syncPull,
      );
      _ready = services;
      return services;
    } catch (_) {
      _inFlight = null;
      rethrow;
    }
  }
}
