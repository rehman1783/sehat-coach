import 'package:get/get.dart';

import '../../domain/admin_authorization.dart';

enum AdminDashboardStatus {
  loading,
  ready,
  signedOut,
  mfaRequired,
  inactive,
  failed,
}

enum AdminModule { catalog, content, market, billingSupport, audit, staff }

/// Must restore a server-validated staff principal. Implementations may not
/// derive staff roles from local preferences or ordinary consumer auth claims.
abstract interface class TrustedAdminSessionPort {
  Future<StaffPrincipal?> restoreServerVerifiedPrincipal();
}

class AdminDashboardController extends GetxController {
  AdminDashboardController(this._session);

  final TrustedAdminSessionPort _session;
  final status = AdminDashboardStatus.loading.obs;
  final modules = <AdminModule>[].obs;
  final principal = Rxn<StaffPrincipal>();

  Future<void> load() async {
    status.value = AdminDashboardStatus.loading;
    modules.clear();
    principal.value = null;
    try {
      final principal = await _session.restoreServerVerifiedPrincipal();
      if (principal == null) {
        status.value = AdminDashboardStatus.signedOut;
        return;
      }
      if (!principal.active) {
        status.value = AdminDashboardStatus.inactive;
        return;
      }
      if (!principal.mfaVerified) {
        status.value = AdminDashboardStatus.mfaRequired;
        return;
      }
      this.principal.value = principal;
      modules.assignAll(_modulesFor(principal.roles));
      status.value = AdminDashboardStatus.ready;
    } on Object {
      modules.clear();
      principal.value = null;
      status.value = AdminDashboardStatus.failed;
    }
  }

  List<AdminModule> _modulesFor(Set<AdminRole> roles) {
    if (roles.contains(AdminRole.platformOwner)) return AdminModule.values;
    final result = <AdminModule>[];
    if (roles.contains(AdminRole.catalogEditor) ||
        roles.contains(AdminRole.catalogReviewer)) {
      result.add(AdminModule.catalog);
    }
    if (roles.contains(AdminRole.contentEditor) ||
        roles.contains(AdminRole.contentReviewer)) {
      result.add(AdminModule.content);
    }
    if (roles.contains(AdminRole.marketEditor) ||
        roles.contains(AdminRole.marketReviewer)) {
      result.add(AdminModule.market);
    }
    if (roles.contains(AdminRole.billingSupport)) {
      result.add(AdminModule.billingSupport);
    }
    if (roles.contains(AdminRole.auditor)) result.add(AdminModule.audit);
    return result;
  }
}
