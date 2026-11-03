import 'package:get/get.dart';

import '../../domain/admin_authorization.dart';
import '../../domain/city_configuration_workflow.dart';

/// Production implementations must reauthorize [principal] on the server for
/// every read and transition. The server remains responsible for persisting
/// the draft, recording its audit event and enforcing independent review.
abstract interface class TrustedAdminCityPort {
  Future<CityConfigurationDraft?> loadCurrent({
    required StaffPrincipal principal,
  });

  Future<CityConfigurationDraft> submitForReview({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  });

  Future<CityConfigurationDraft> approve({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  });

  Future<void> publish({
    required StaffPrincipal principal,
    required CityConfigurationDraft draft,
  });
}

enum AdminCityStatus { loading, ready, empty, denied, failed, saving }

class AdminCityController extends GetxController {
  AdminCityController({
    required this.principal,
    required this.source,
    this.authorization = const AdminAuthorizationPolicy(),
  });

  final StaffPrincipal principal;
  final TrustedAdminCityPort source;
  final AdminAuthorizationPolicy authorization;
  final status = AdminCityStatus.loading.obs;
  final draft = Rxn<CityConfigurationDraft>();
  final message = RxnString();
  final published = false.obs;

  Future<void> load() async {
    status.value = AdminCityStatus.loading;
    message.value = null;
    published.value = false;
    try {
      if (!_hasMarketRole) {
        status.value = AdminCityStatus.denied;
        return;
      }
      final loaded = await source.loadCurrent(principal: principal);
      draft.value = loaded;
      status.value = loaded == null
          ? AdminCityStatus.empty
          : AdminCityStatus.ready;
    } on AdminAuthorizationDenied {
      status.value = AdminCityStatus.denied;
    } on Object {
      status.value = AdminCityStatus.failed;
    }
  }

  bool get canAdvance {
    final current = draft.value;
    if (current == null || published.value) return false;
    try {
      authorization.authorize(_request(current));
      return true;
    } on AdminAuthorizationDenied {
      return false;
    }
  }

  String get actionLabel => switch (draft.value?.stage) {
    CityConfigurationStage.draft => 'SUBMIT FOR REVIEW',
    CityConfigurationStage.inReview => 'APPROVE RELEASE',
    CityConfigurationStage.approved => 'PUBLISH RELEASE',
    null => '',
  };

  Future<void> advance() async {
    final current = draft.value;
    if (current == null || status.value == AdminCityStatus.saving) return;
    try {
      authorization.authorize(_request(current));
    } on AdminAuthorizationDenied {
      status.value = AdminCityStatus.denied;
      return;
    }

    status.value = AdminCityStatus.saving;
    message.value = null;
    try {
      switch (current.stage) {
        case CityConfigurationStage.draft:
          draft.value = await source.submitForReview(
            principal: principal,
            draft: current,
          );
          message.value = 'Release submitted for independent review.';
        case CityConfigurationStage.inReview:
          draft.value = await source.approve(
            principal: principal,
            draft: current,
          );
          message.value = 'Release approved. A separate publisher is required.';
        case CityConfigurationStage.approved:
          await source.publish(principal: principal, draft: current);
          published.value = true;
          message.value = 'City release published successfully.';
      }
      status.value = AdminCityStatus.ready;
    } on AdminAuthorizationDenied {
      status.value = AdminCityStatus.denied;
    } on Object {
      message.value = 'The city release could not be updated. Try again.';
      status.value = AdminCityStatus.ready;
    }
  }

  bool get _hasMarketRole =>
      principal.active &&
      principal.mfaVerified &&
      (principal.roles.contains(AdminRole.platformOwner) ||
          principal.roles.contains(AdminRole.marketEditor) ||
          principal.roles.contains(AdminRole.marketReviewer));

  AdminAuthorizationRequest _request(CityConfigurationDraft value) {
    final action = switch (value.stage) {
      CityConfigurationStage.draft => AdminAction.editCityConfiguration,
      CityConfigurationStage.inReview => AdminAction.approveCityConfiguration,
      CityConfigurationStage.approved => AdminAction.publishCityConfiguration,
    };
    return AdminAuthorizationRequest(
      actor: principal,
      action: action,
      targetType: 'city_configuration_release',
      targetId: value.releaseId,
      originatingEditorId: value.createdBy,
      reviewerId: value.reviewerId,
    );
  }
}
