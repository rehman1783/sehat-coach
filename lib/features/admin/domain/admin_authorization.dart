enum AdminRole {
  platformOwner,
  catalogEditor,
  catalogReviewer,
  contentEditor,
  contentReviewer,
  marketEditor,
  marketReviewer,
  billingSupport,
  auditor,
}

enum AdminAction {
  editCatalog,
  approveCatalog,
  publishCatalog,
  revokeCatalog,
  editContent,
  approveContent,
  publishContent,
  editMarketPrice,
  approveMarketPrice,
  publishMarketPrice,
  editCityConfiguration,
  approveCityConfiguration,
  publishCityConfiguration,
  manageStaff,
  viewAudit,
}

class StaffPrincipal {
  StaffPrincipal({
    required this.staffId,
    required Set<AdminRole> roles,
    required this.mfaVerified,
    this.active = true,
  }) : roles = Set.unmodifiable(roles) {
    if (staffId.trim().isEmpty) throw ArgumentError('Staff ID is required');
    if (this.roles.isEmpty) {
      throw ArgumentError('At least one role is required');
    }
  }

  final String staffId;
  final Set<AdminRole> roles;
  final bool mfaVerified;
  final bool active;
}

class AdminAuthorizationRequest {
  AdminAuthorizationRequest({
    required this.actor,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.originatingEditorId,
    this.reviewerId,
  }) {
    if (targetType.trim().isEmpty || targetId.trim().isEmpty) {
      throw ArgumentError('Admin action target is required');
    }
  }

  final StaffPrincipal actor;
  final AdminAction action;
  final String targetType;
  final String targetId;
  final String? originatingEditorId;
  final String? reviewerId;
}

class AdminAuthorizationDenied implements Exception {
  const AdminAuthorizationDenied(this.reason);

  final String reason;

  @override
  String toString() => 'AdminAuthorizationDenied($reason)';
}

class AdminAuthorizationPolicy {
  const AdminAuthorizationPolicy();

  void authorize(AdminAuthorizationRequest request) {
    final actor = request.actor;
    if (!actor.active) {
      throw const AdminAuthorizationDenied('staff_inactive');
    }
    if (_requiresMfa(request.action) && !actor.mfaVerified) {
      throw const AdminAuthorizationDenied('mfa_required');
    }
    if (!_isAllowed(actor.roles, request.action)) {
      throw const AdminAuthorizationDenied('insufficient_role');
    }
    if (_isApproval(request.action) &&
        request.originatingEditorId == actor.staffId) {
      throw const AdminAuthorizationDenied('four_eyes_required');
    }
    if (_isPublish(request.action)) {
      final reviewer = request.reviewerId?.trim();
      if (reviewer == null || reviewer.isEmpty || reviewer == actor.staffId) {
        throw const AdminAuthorizationDenied('independent_review_required');
      }
    }
  }

  bool _isAllowed(Set<AdminRole> roles, AdminAction action) {
    if (roles.contains(AdminRole.platformOwner)) return true;
    return switch (action) {
      AdminAction.editCatalog => roles.contains(AdminRole.catalogEditor),
      AdminAction.approveCatalog ||
      AdminAction.publishCatalog ||
      AdminAction.revokeCatalog => roles.contains(AdminRole.catalogReviewer),
      AdminAction.editContent => roles.contains(AdminRole.contentEditor),
      AdminAction.approveContent ||
      AdminAction.publishContent => roles.contains(AdminRole.contentReviewer),
      AdminAction.editMarketPrice => roles.contains(AdminRole.marketEditor),
      AdminAction.approveMarketPrice || AdminAction.publishMarketPrice =>
        roles.contains(AdminRole.marketReviewer),
      AdminAction.editCityConfiguration => roles.contains(
        AdminRole.marketEditor,
      ),
      AdminAction.approveCityConfiguration ||
      AdminAction.publishCityConfiguration => roles.contains(
        AdminRole.marketReviewer,
      ),
      AdminAction.manageStaff => false,
      AdminAction.viewAudit => roles.contains(AdminRole.auditor),
    };
  }

  bool _requiresMfa(AdminAction action) => switch (action) {
    AdminAction.viewAudit => false,
    _ => true,
  };

  bool _isApproval(AdminAction action) => switch (action) {
    AdminAction.approveCatalog ||
    AdminAction.approveContent ||
    AdminAction.approveMarketPrice => true,
    AdminAction.approveCityConfiguration => true,
    _ => false,
  };

  bool _isPublish(AdminAction action) => switch (action) {
    AdminAction.publishCatalog ||
    AdminAction.publishContent ||
    AdminAction.publishMarketPrice => true,
    AdminAction.publishCityConfiguration => true,
    _ => false,
  };
}
