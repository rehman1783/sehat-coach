import '../../location/domain/city_configuration.dart';
import 'admin_audit.dart';
import 'admin_authorization.dart';

enum CityConfigurationStage { draft, inReview, approved }

class CityConfigurationDraft {
  CityConfigurationDraft({
    required this.releaseId,
    required this.version,
    required this.contentChecksum,
    required List<CityConfigurationEntry> cities,
    required this.createdBy,
    this.stage = CityConfigurationStage.draft,
    this.reviewerId,
  }) : cities = List.unmodifiable(cities) {
    if (releaseId.trim().isEmpty ||
        version.trim().isEmpty ||
        contentChecksum.trim().isEmpty ||
        createdBy.trim().isEmpty) {
      throw ArgumentError('City release identity is required');
    }
    // Reuse the mobile contract validation before a draft can enter workflow.
    PublishedCityConfiguration(
      releaseId: releaseId,
      version: version,
      countryCode: 'PK',
      contentChecksum: contentChecksum,
      publishedAtUtc: DateTime.utc(2000),
      cities: this.cities,
    );
  }

  final String releaseId;
  final String version;
  final String contentChecksum;
  final List<CityConfigurationEntry> cities;
  final String createdBy;
  final CityConfigurationStage stage;
  final String? reviewerId;

  CityConfigurationDraft copyWith({
    CityConfigurationStage? stage,
    String? reviewerId,
  }) => CityConfigurationDraft(
    releaseId: releaseId,
    version: version,
    contentChecksum: contentChecksum,
    cities: cities,
    createdBy: createdBy,
    stage: stage ?? this.stage,
    reviewerId: reviewerId ?? this.reviewerId,
  );
}

class InvalidCityConfigurationTransition implements Exception {
  const InvalidCityConfigurationTransition();
}

class CityConfigurationWorkflow {
  const CityConfigurationWorkflow({required this.audit});

  final RecordAuthorizedAdminAction audit;

  Future<CityConfigurationDraft> submitForReview({
    required StaffPrincipal actor,
    required CityConfigurationDraft draft,
  }) => _advance(
    actor: actor,
    draft: draft,
    expected: CityConfigurationStage.draft,
    next: CityConfigurationStage.inReview,
    action: AdminAction.editCityConfiguration,
  );

  Future<CityConfigurationDraft> approve({
    required StaffPrincipal actor,
    required CityConfigurationDraft draft,
  }) => _advance(
    actor: actor,
    draft: draft,
    expected: CityConfigurationStage.inReview,
    next: CityConfigurationStage.approved,
    action: AdminAction.approveCityConfiguration,
    reviewerId: actor.staffId,
  );

  Future<PublishedCityConfiguration> publish({
    required StaffPrincipal actor,
    required CityConfigurationDraft draft,
  }) async {
    if (draft.stage != CityConfigurationStage.approved) {
      throw const InvalidCityConfigurationTransition();
    }
    final request = _request(
      actor: actor,
      draft: draft,
      action: AdminAction.publishCityConfiguration,
    );
    final now = audit.clock.nowUtc();
    final published = PublishedCityConfiguration(
      releaseId: draft.releaseId,
      version: draft.version,
      countryCode: 'PK',
      contentChecksum: draft.contentChecksum,
      publishedAtUtc: now,
      cities: draft.cities,
    );
    await audit.execute(
      request: request,
      beforeMetadata: _metadata(draft),
      afterMetadata: {
        ..._metadata(draft),
        'stage': 'published',
        'publishedAtUtc': now.toIso8601String(),
      },
    );
    return published;
  }

  Future<CityConfigurationDraft> _advance({
    required StaffPrincipal actor,
    required CityConfigurationDraft draft,
    required CityConfigurationStage expected,
    required CityConfigurationStage next,
    required AdminAction action,
    String? reviewerId,
  }) async {
    if (draft.stage != expected) {
      throw const InvalidCityConfigurationTransition();
    }
    final request = _request(actor: actor, draft: draft, action: action);
    final updated = draft.copyWith(stage: next, reviewerId: reviewerId);
    await audit.execute(
      request: request,
      beforeMetadata: _metadata(draft),
      afterMetadata: _metadata(updated),
    );
    return updated;
  }

  AdminAuthorizationRequest _request({
    required StaffPrincipal actor,
    required CityConfigurationDraft draft,
    required AdminAction action,
  }) => AdminAuthorizationRequest(
    actor: actor,
    action: action,
    targetType: 'city_configuration_release',
    targetId: draft.releaseId,
    originatingEditorId: draft.createdBy,
    reviewerId: draft.reviewerId,
  );

  Map<String, Object?> _metadata(CityConfigurationDraft draft) => {
    'version': draft.version,
    'checksum': draft.contentChecksum,
    'stage': draft.stage.name,
    'enabledCityCount': draft.cities.where((city) => city.enabled).length,
    'reviewerId': draft.reviewerId,
  };
}
