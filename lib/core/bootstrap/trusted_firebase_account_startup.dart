import '../config/app_config.dart';
import 'trusted_account_core_composition.dart';

typedef TrustedAccountProviderBuilder = TrustedAccountProviderPorts Function(
  Uri adultEligibilityEndpoint,
);

/// Single-flight, retryable startup boundary for production account providers.
class TrustedFirebaseAccountStartup {
  TrustedFirebaseAccountStartup({
    required this.config,
    required this.initializeFirebase,
    required this.buildProvider,
  });

  final AppConfig config;
  final Future<void> Function() initializeFirebase;
  final TrustedAccountProviderBuilder buildProvider;
  Future<TrustedAccountProviderPorts>? _inFlight;
  TrustedAccountProviderPorts? _ready;

  Future<TrustedAccountProviderPorts> start() {
    final ready = _ready;
    if (ready != null) return Future.value(ready);
    return _inFlight ??= _startOnce();
  }

  Future<TrustedAccountProviderPorts> _startOnce() async {
    try {
      final endpoint = config.adultEligibilityEndpoint;
      if (endpoint == null) {
        throw StateError('Trusted adult eligibility endpoint is required.');
      }
      await initializeFirebase();
      final provider = buildProvider(endpoint);
      _ready = provider;
      return provider;
    } catch (_) {
      _inFlight = null;
      rethrow;
    }
  }
}
