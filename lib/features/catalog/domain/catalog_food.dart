enum CatalogReviewStatus { draft, inReview, approved, rejected, retired }

enum OilInclusion { included, excluded, unknown }

class NutritionProvenance {
  NutritionProvenance({
    required this.sourceId,
    required this.sourceVersion,
    required this.sourceRecordId,
    required this.citation,
    required this.licenseId,
    required this.reviewStatus,
    this.reviewerId,
    this.reviewedAt,
  }) {
    _requireText(sourceId, 'sourceId');
    _requireText(sourceVersion, 'sourceVersion');
    _requireText(sourceRecordId, 'sourceRecordId');
    _requireText(citation, 'citation');
    _requireText(licenseId, 'licenseId');
    if (reviewStatus == CatalogReviewStatus.approved &&
        (reviewerId == null || reviewedAt == null)) {
      throw ArgumentError('Approved nutrition requires review evidence');
    }
    if (reviewerId != null) _requireText(reviewerId!, 'reviewerId');
  }

  final String sourceId;
  final String sourceVersion;
  final String sourceRecordId;
  final String citation;
  final String licenseId;
  final CatalogReviewStatus reviewStatus;
  final String? reviewerId;
  final DateTime? reviewedAt;

  bool get isApproved => reviewStatus == CatalogReviewStatus.approved;
}

class NutritionPerReference {
  NutritionPerReference({
    required this.referenceGrams,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.sodiumMilligrams,
  }) {
    _requirePositive(referenceGrams, 'referenceGrams');
    _requireNonNegative(caloriesKcal, 'caloriesKcal');
    _requireNonNegative(proteinGrams, 'proteinGrams');
    _requireNonNegative(carbohydrateGrams, 'carbohydrateGrams');
    _requireNonNegative(fatGrams, 'fatGrams');
    if (sodiumMilligrams case final sodium?) {
      _requireNonNegative(sodium, 'sodiumMilligrams');
    }
  }

  final double referenceGrams;
  final double caloriesKcal;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double? sodiumMilligrams;
}

class ServingDefinition {
  ServingDefinition({
    required this.id,
    required this.label,
    required this.unitCode,
    required this.gramsMinimum,
    required this.gramsMaximum,
    required this.confidence,
  }) {
    _requireText(id, 'id');
    _requireText(label, 'label');
    _requireText(unitCode, 'unitCode');
    _requirePositive(gramsMinimum, 'gramsMinimum');
    _requirePositive(gramsMaximum, 'gramsMaximum');
    if (gramsMaximum < gramsMinimum) {
      throw ArgumentError('Serving maximum cannot be below minimum');
    }
    if (!confidence.isFinite || confidence < 0 || confidence > 1) {
      throw ArgumentError.value(confidence, 'confidence');
    }
  }

  final String id;
  final String label;
  final String unitCode;
  final double gramsMinimum;
  final double gramsMaximum;
  final double confidence;
}

class CatalogFood {
  CatalogFood({
    required this.id,
    required this.releaseId,
    required this.nameEnglish,
    required this.nameRomanUrdu,
    required Iterable<String> synonyms,
    required this.nutrition,
    required this.provenance,
    required this.oilInclusion,
    required Iterable<ServingDefinition> servings,
    this.region,
    this.preparation,
  }) : synonyms = List.unmodifiable(synonyms),
       servings = List.unmodifiable(servings) {
    _requireText(id, 'id');
    _requireText(releaseId, 'releaseId');
    _requireText(nameEnglish, 'nameEnglish');
    _requireText(nameRomanUrdu, 'nameRomanUrdu');
    if (this.servings.isEmpty) {
      throw ArgumentError('At least one serving definition is required');
    }
    final servingIds = this.servings.map((serving) => serving.id).toSet();
    if (servingIds.length != this.servings.length) {
      throw ArgumentError('Serving IDs must be unique within a food');
    }
    for (final synonym in this.synonyms) {
      _requireText(synonym, 'synonym');
    }
  }

  final String id;
  final String releaseId;
  final String nameEnglish;
  final String nameRomanUrdu;
  final List<String> synonyms;
  final String? region;
  final String? preparation;
  final NutritionPerReference nutrition;
  final NutritionProvenance provenance;
  final OilInclusion oilInclusion;
  final List<ServingDefinition> servings;
}

class CatalogRelease {
  CatalogRelease({
    required this.id,
    required this.version,
    required this.reviewStatus,
    required this.contentChecksum,
    this.publishedAt,
  }) {
    _requireText(id, 'id');
    _requireText(version, 'version');
    _requireText(contentChecksum, 'contentChecksum');
    if (reviewStatus == CatalogReviewStatus.approved && publishedAt == null) {
      throw ArgumentError('Approved catalog release requires publication time');
    }
  }

  final String id;
  final String version;
  final CatalogReviewStatus reviewStatus;
  final String contentChecksum;
  final DateTime? publishedAt;

  bool get isApproved => reviewStatus == CatalogReviewStatus.approved;
}

bool canExposeAsApprovedFood(CatalogRelease release, CatalogFood food) {
  return release.id == food.releaseId &&
      release.isApproved &&
      food.provenance.isApproved;
}

void _requireText(String value, String name) {
  if (value.trim().isEmpty) throw ArgumentError.value(value, name);
}

void _requirePositive(double value, String name) {
  if (!value.isFinite || value <= 0) throw ArgumentError.value(value, name);
}

void _requireNonNegative(double value, String name) {
  if (!value.isFinite || value < 0) throw ArgumentError.value(value, name);
}
