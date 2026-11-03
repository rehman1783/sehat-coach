enum GroceryPriceStatus { draft, inReview, approved, published, retired }

class GroceryPriceRecord {
  GroceryPriceRecord({
    required this.priceId,
    required this.commodityId,
    required this.commodityName,
    required this.cityId,
    required this.cityName,
    required this.marketName,
    required this.unitCode,
    required this.pricePkr,
    required this.sourceId,
    required this.sourceCitation,
    required this.observedAtUtc,
    required this.lastVerifiedAtUtc,
    required this.status,
    required this.createdBy,
    this.reviewerId,
    this.publishedAtUtc,
    this.validUntilUtc,
  }) {
    for (final value in [
      priceId,
      commodityId,
      commodityName,
      cityId,
      cityName,
      marketName,
      unitCode,
      sourceId,
      sourceCitation,
      createdBy,
    ]) {
      if (value.trim().isEmpty) {
        throw ArgumentError('Complete grocery price identity is required');
      }
    }
    if (!pricePkr.isFinite || pricePkr <= 0) {
      throw ArgumentError.value(pricePkr, 'pricePkr');
    }
    for (final value in [
      observedAtUtc,
      lastVerifiedAtUtc,
      publishedAtUtc,
      validUntilUtc,
    ]) {
      if (value != null && !value.isUtc) {
        throw ArgumentError('Grocery price timestamps must be UTC');
      }
    }
    if (lastVerifiedAtUtc.isBefore(observedAtUtc)) {
      throw ArgumentError('Verification cannot predate observation');
    }
    if (validUntilUtc != null && !validUntilUtc!.isAfter(observedAtUtc)) {
      throw ArgumentError('Validity must end after observation');
    }
  }

  final String priceId;
  final String commodityId;
  final String commodityName;
  final String cityId;
  final String cityName;
  final String marketName;
  final String unitCode;
  final double pricePkr;
  final String sourceId;
  final String sourceCitation;
  final DateTime observedAtUtc;
  final DateTime lastVerifiedAtUtc;
  final DateTime? validUntilUtc;
  final GroceryPriceStatus status;
  final String createdBy;
  final String? reviewerId;
  final DateTime? publishedAtUtc;

  bool isCurrentAt(
    DateTime nowUtc, {
    Duration maximumAge = const Duration(days: 7),
  }) {
    if (!nowUtc.isUtc) throw ArgumentError('Current time must be UTC');
    if (status != GroceryPriceStatus.published || publishedAtUtc == null) {
      return false;
    }
    if (observedAtUtc.isAfter(nowUtc) || lastVerifiedAtUtc.isAfter(nowUtc)) {
      return false;
    }
    if (validUntilUtc != null && nowUtc.isAfter(validUntilUtc!)) return false;
    return nowUtc.difference(lastVerifiedAtUtc) <= maximumAge;
  }

  GroceryPriceRecord copyWith({
    GroceryPriceStatus? status,
    String? reviewerId,
    DateTime? publishedAtUtc,
  }) => GroceryPriceRecord(
    priceId: priceId,
    commodityId: commodityId,
    commodityName: commodityName,
    cityId: cityId,
    cityName: cityName,
    marketName: marketName,
    unitCode: unitCode,
    pricePkr: pricePkr,
    sourceId: sourceId,
    sourceCitation: sourceCitation,
    observedAtUtc: observedAtUtc,
    lastVerifiedAtUtc: lastVerifiedAtUtc,
    validUntilUtc: validUntilUtc,
    status: status ?? this.status,
    createdBy: createdBy,
    reviewerId: reviewerId ?? this.reviewerId,
    publishedAtUtc: publishedAtUtc ?? this.publishedAtUtc,
  );
}

class GroceryPricePresentation {
  const GroceryPricePresentation({
    required this.available,
    required this.statusLabel,
    this.pricePkr,
    this.unitCode,
    this.cityName,
    this.marketName,
    this.sourceCitation,
    this.lastUpdatedUtc,
  });

  final bool available;
  final String statusLabel;
  final double? pricePkr;
  final String? unitCode;
  final String? cityName;
  final String? marketName;
  final String? sourceCitation;
  final DateTime? lastUpdatedUtc;

  factory GroceryPricePresentation.fromRecord(
    GroceryPriceRecord? record,
    DateTime nowUtc,
  ) {
    if (record == null) {
      return const GroceryPricePresentation(
        available: false,
        statusLabel: 'No verified price available',
      );
    }
    final current = record.isCurrentAt(nowUtc);
    return GroceryPricePresentation(
      available: current,
      statusLabel: current
          ? 'Current verified price'
          : 'Price unavailable or stale',
      pricePkr: current ? record.pricePkr : null,
      unitCode: current ? record.unitCode : null,
      cityName: record.cityName,
      marketName: record.marketName,
      sourceCitation: record.sourceCitation,
      lastUpdatedUtc: record.lastVerifiedAtUtc,
    );
  }
}
