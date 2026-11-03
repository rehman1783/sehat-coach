import 'admin_audit.dart';
import 'admin_authorization.dart';

enum CatalogReleaseStage { draft, inReview, approved, published, revoked }

class CatalogSourceEvidence {
  CatalogSourceEvidence({
    required this.sourceId,
    required this.sourceVersion,
    required this.citation,
    required this.licenseId,
  }) {
    for (final value in [sourceId, sourceVersion, citation, licenseId]) {
      if (value.trim().isEmpty) {
        throw ArgumentError('Complete catalog source evidence is required');
      }
    }
  }

  final String sourceId;
  final String sourceVersion;
  final String citation;
  final String licenseId;
}

class CatalogReleaseRecord {
  CatalogReleaseRecord({
    required this.releaseId,
    required this.version,
    required this.contentChecksum,
    required this.stage,
    required this.foodCount,
    required this.recipeCount,
    required List<CatalogSourceEvidence> sources,
    required this.createdBy,
    this.reviewerId,
    this.publishedAtUtc,
    this.revokedAtUtc,
  }) : sources = List.unmodifiable(sources) {
    if (releaseId.trim().isEmpty ||
        version.trim().isEmpty ||
        contentChecksum.trim().isEmpty ||
        createdBy.trim().isEmpty) {
      throw ArgumentError('Catalog release identity is required');
    }
    if (foodCount < 0 || recipeCount < 0 || foodCount + recipeCount == 0) {
      throw ArgumentError('Catalog release must contain reviewed content');
    }
    if (this.sources.isEmpty) {
      throw ArgumentError('Catalog release requires source evidence');
    }
    if (publishedAtUtc != null && !publishedAtUtc!.isUtc) {
      throw ArgumentError('Publication time must be UTC');
    }
    if (revokedAtUtc != null && !revokedAtUtc!.isUtc) {
      throw ArgumentError('Revocation time must be UTC');
    }
  }

  final String releaseId;
  final String version;
  final String contentChecksum;
  final CatalogReleaseStage stage;
  final int foodCount;
  final int recipeCount;
  final List<CatalogSourceEvidence> sources;
  final String createdBy;
  final String? reviewerId;
  final DateTime? publishedAtUtc;
  final DateTime? revokedAtUtc;

  CatalogReleaseRecord copyWith({
    CatalogReleaseStage? stage,
    String? reviewerId,
    DateTime? publishedAtUtc,
    DateTime? revokedAtUtc,
  }) => CatalogReleaseRecord(
    releaseId: releaseId,
    version: version,
    contentChecksum: contentChecksum,
    stage: stage ?? this.stage,
    foodCount: foodCount,
    recipeCount: recipeCount,
    sources: sources,
    createdBy: createdBy,
    reviewerId: reviewerId ?? this.reviewerId,
    publishedAtUtc: publishedAtUtc ?? this.publishedAtUtc,
    revokedAtUtc: revokedAtUtc ?? this.revokedAtUtc,
  );
}

class InvalidCatalogTransition implements Exception {
  const InvalidCatalogTransition();
}

class CatalogPublicationWorkflow {
  const CatalogPublicationWorkflow({
    required this.authorization,
    required this.audit,
  });

  final AdminAuthorizationPolicy authorization;
  final RecordAuthorizedAdminAction audit;

  Future<CatalogReleaseRecord> submitForReview({
    required StaffPrincipal actor,
    required CatalogReleaseRecord release,
  }) => _transition(
    actor: actor,
    release: release,
    expected: CatalogReleaseStage.draft,
    next: CatalogReleaseStage.inReview,
    action: AdminAction.editCatalog,
  );

  Future<CatalogReleaseRecord> approve({
    required StaffPrincipal actor,
    required CatalogReleaseRecord release,
  }) => _transition(
    actor: actor,
    release: release,
    expected: CatalogReleaseStage.inReview,
    next: CatalogReleaseStage.approved,
    action: AdminAction.approveCatalog,
    reviewerId: actor.staffId,
  );

  Future<CatalogReleaseRecord> publish({
    required StaffPrincipal actor,
    required CatalogReleaseRecord release,
  }) => _transition(
    actor: actor,
    release: release,
    expected: CatalogReleaseStage.approved,
    next: CatalogReleaseStage.published,
    action: AdminAction.publishCatalog,
    publishedAtUtc: true,
  );

  Future<CatalogReleaseRecord> revoke({
    required StaffPrincipal actor,
    required CatalogReleaseRecord release,
  }) => _transition(
    actor: actor,
    release: release,
    expected: CatalogReleaseStage.published,
    next: CatalogReleaseStage.revoked,
    action: AdminAction.revokeCatalog,
    revokedAtUtc: true,
  );

  Future<CatalogReleaseRecord> _transition({
    required StaffPrincipal actor,
    required CatalogReleaseRecord release,
    required CatalogReleaseStage expected,
    required CatalogReleaseStage next,
    required AdminAction action,
    String? reviewerId,
    bool publishedAtUtc = false,
    bool revokedAtUtc = false,
  }) async {
    if (release.stage != expected) throw const InvalidCatalogTransition();
    final request = AdminAuthorizationRequest(
      actor: actor,
      action: action,
      targetType: 'catalog_release',
      targetId: release.releaseId,
      originatingEditorId: release.createdBy,
      reviewerId: release.reviewerId,
    );
    authorization.authorize(request);
    final now = audit.clock.nowUtc();
    final updated = release.copyWith(
      stage: next,
      reviewerId: reviewerId,
      publishedAtUtc: publishedAtUtc ? now : null,
      revokedAtUtc: revokedAtUtc ? now : null,
    );
    await audit.execute(
      request: request,
      beforeMetadata: _metadata(release),
      afterMetadata: _metadata(updated),
    );
    return updated;
  }

  Map<String, Object?> _metadata(CatalogReleaseRecord release) => {
    'version': release.version,
    'checksum': release.contentChecksum,
    'stage': release.stage.name,
    'foodCount': release.foodCount,
    'recipeCount': release.recipeCount,
    'reviewerId': release.reviewerId,
    'publishedAtUtc': release.publishedAtUtc?.toIso8601String(),
    'revokedAtUtc': release.revokedAtUtc?.toIso8601String(),
  };
}
