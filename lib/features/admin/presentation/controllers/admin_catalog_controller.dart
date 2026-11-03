import 'package:get/get.dart';

import '../../domain/admin_authorization.dart';
import '../../domain/catalog_publication_workflow.dart';

/// Production implementations must reauthorize [principal], persist the
/// transition atomically and append an audit event for every method call.
abstract interface class TrustedAdminCatalogPort {
  Future<List<CatalogReleaseRecord>> loadReleases({
    required StaffPrincipal principal,
  });

  Future<CatalogReleaseRecord> submitForReview({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  });

  Future<CatalogReleaseRecord> approve({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  });

  Future<CatalogReleaseRecord> publish({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  });

  Future<CatalogReleaseRecord> revoke({
    required StaffPrincipal principal,
    required CatalogReleaseRecord release,
  });
}

enum AdminCatalogStatus { loading, ready, denied, failed }

class AdminCatalogController extends GetxController {
  AdminCatalogController({
    required this.principal,
    required this.source,
    this.authorization = const AdminAuthorizationPolicy(),
  });

  final StaffPrincipal principal;
  final TrustedAdminCatalogPort source;
  final AdminAuthorizationPolicy authorization;
  final status = AdminCatalogStatus.loading.obs;
  final releases = <CatalogReleaseRecord>[].obs;
  final busyReleaseId = RxnString();
  final message = RxnString();

  Future<void> load() async {
    status.value = AdminCatalogStatus.loading;
    message.value = null;
    if (!_hasCatalogRole) {
      releases.clear();
      status.value = AdminCatalogStatus.denied;
      return;
    }
    try {
      releases.assignAll(await source.loadReleases(principal: principal));
      status.value = AdminCatalogStatus.ready;
    } on AdminAuthorizationDenied {
      releases.clear();
      status.value = AdminCatalogStatus.denied;
    } on Object {
      releases.clear();
      status.value = AdminCatalogStatus.failed;
    }
  }

  bool canAdvance(CatalogReleaseRecord release) {
    if (release.stage == CatalogReleaseStage.revoked) return false;
    try {
      authorization.authorize(_request(release));
      return true;
    } on AdminAuthorizationDenied {
      return false;
    }
  }

  String actionLabel(CatalogReleaseRecord release) => switch (release.stage) {
    CatalogReleaseStage.draft => 'SUBMIT FOR REVIEW',
    CatalogReleaseStage.inReview => 'APPROVE RELEASE',
    CatalogReleaseStage.approved => 'PUBLISH RELEASE',
    CatalogReleaseStage.published => 'REVOKE RELEASE',
    CatalogReleaseStage.revoked => '',
  };

  Future<void> advance(
    CatalogReleaseRecord release, {
    bool revokeConfirmed = false,
  }) async {
    if (busyReleaseId.value != null ||
        release.stage == CatalogReleaseStage.revoked) {
      return;
    }
    if (release.stage == CatalogReleaseStage.published && !revokeConfirmed) {
      message.value = 'Revocation requires explicit confirmation.';
      return;
    }
    try {
      authorization.authorize(_request(release));
    } on AdminAuthorizationDenied {
      message.value = 'This transition requires different authorized staff.';
      return;
    }

    busyReleaseId.value = release.releaseId;
    message.value = null;
    try {
      final updated = switch (release.stage) {
        CatalogReleaseStage.draft => await source.submitForReview(
          principal: principal,
          release: release,
        ),
        CatalogReleaseStage.inReview => await source.approve(
          principal: principal,
          release: release,
        ),
        CatalogReleaseStage.approved => await source.publish(
          principal: principal,
          release: release,
        ),
        CatalogReleaseStage.published => await source.revoke(
          principal: principal,
          release: release,
        ),
        CatalogReleaseStage.revoked => release,
      };
      final index = releases.indexWhere(
        (candidate) => candidate.releaseId == release.releaseId,
      );
      if (index >= 0) releases[index] = updated;
      message.value = switch (updated.stage) {
        CatalogReleaseStage.inReview =>
          'Catalog submitted for independent review.',
        CatalogReleaseStage.approved =>
          'Catalog approved. A separate publisher is required.',
        CatalogReleaseStage.published => 'Catalog release published.',
        CatalogReleaseStage.revoked => 'Catalog release revoked.',
        CatalogReleaseStage.draft => null,
      };
    } on AdminAuthorizationDenied {
      message.value = 'The server denied this catalog transition.';
    } on Object {
      message.value =
          'The catalog could not be updated. Existing data is safe.';
    } finally {
      busyReleaseId.value = null;
    }
  }

  bool get _hasCatalogRole =>
      principal.active &&
      principal.mfaVerified &&
      (principal.roles.contains(AdminRole.platformOwner) ||
          principal.roles.contains(AdminRole.catalogEditor) ||
          principal.roles.contains(AdminRole.catalogReviewer));

  AdminAuthorizationRequest _request(CatalogReleaseRecord release) {
    final action = switch (release.stage) {
      CatalogReleaseStage.draft => AdminAction.editCatalog,
      CatalogReleaseStage.inReview => AdminAction.approveCatalog,
      CatalogReleaseStage.approved => AdminAction.publishCatalog,
      CatalogReleaseStage.published => AdminAction.revokeCatalog,
      CatalogReleaseStage.revoked => throw StateError('Release is revoked'),
    };
    return AdminAuthorizationRequest(
      actor: principal,
      action: action,
      targetType: 'catalog_release',
      targetId: release.releaseId,
      originatingEditorId: release.createdBy,
      reviewerId: release.reviewerId,
    );
  }
}
