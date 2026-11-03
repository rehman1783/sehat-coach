/// Fixed, payload-free billing events suitable for privacy-safe diagnostics.
///
/// Events deliberately contain no owner IDs, purchase tokens, product IDs,
/// prices, health data, exception text or backend response content.
enum BillingTelemetryEvent {
  catalogLoadFailed,
  purchaseUnavailable,
  purchaseResultApplicationFailed,
  entitlementRefreshUnavailable,
  purchaseRestoreUnavailable,
  crossOwnerPurchaseRejected,
}

abstract interface class BillingTelemetrySink {
  void record(BillingTelemetryEvent event);
}

class NoopBillingTelemetrySink implements BillingTelemetrySink {
  const NoopBillingTelemetrySink();

  @override
  void record(BillingTelemetryEvent event) {}
}

/// Records diagnostics without allowing observability failures to affect the
/// user-facing billing flow.
void recordBillingTelemetrySafely(
  BillingTelemetrySink sink,
  BillingTelemetryEvent event,
) {
  try {
    sink.record(event);
  } on Object {
    // Telemetry is best-effort and must never become a billing dependency.
  }
}
