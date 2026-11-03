import 'package:get/get.dart';

import '../../domain/admin_audit.dart';
import '../../domain/admin_authorization.dart';

class AdminAuditPage {
  AdminAuditPage({required List<AdminAuditEvent> events, this.nextCursor})
    : events = List.unmodifiable(events) {
    if (nextCursor != null && nextCursor!.trim().isEmpty) {
      throw ArgumentError('Next cursor cannot be empty');
    }
  }

  final List<AdminAuditEvent> events;
  final String? nextCursor;
}

/// Production implementations must reauthorize [principal] on the server and
/// return only audit fields approved for this staff member.
abstract interface class TrustedAdminAuditPort {
  Future<AdminAuditPage> loadPage({
    required StaffPrincipal principal,
    String? cursor,
  });
}

enum AdminAuditStatus { idle, loading, ready, denied, failed }

class AdminAuditController extends GetxController {
  AdminAuditController({
    required this.principal,
    required this.source,
    this.authorization = const AdminAuthorizationPolicy(),
  });

  final StaffPrincipal principal;
  final TrustedAdminAuditPort source;
  final AdminAuthorizationPolicy authorization;
  final status = AdminAuditStatus.idle.obs;
  final events = <AdminAuditEvent>[].obs;
  final hasMore = false.obs;
  String? _cursor;

  Future<void> load({bool restart = false}) async {
    if (status.value == AdminAuditStatus.loading) return;
    if (!restart && events.isNotEmpty && !hasMore.value) return;
    try {
      authorization.authorize(
        AdminAuthorizationRequest(
          actor: principal,
          action: AdminAction.viewAudit,
          targetType: 'audit_log',
          targetId: 'admin_activity',
        ),
      );
    } on AdminAuthorizationDenied {
      events.clear();
      hasMore.value = false;
      status.value = AdminAuditStatus.denied;
      return;
    }

    status.value = AdminAuditStatus.loading;
    if (restart) {
      events.clear();
      _cursor = null;
      hasMore.value = false;
    }
    try {
      final page = await source.loadPage(principal: principal, cursor: _cursor);
      final existingIds = events.map((event) => event.eventId).toSet();
      events.addAll(
        page.events.where((event) => existingIds.add(event.eventId)),
      );
      _cursor = page.nextCursor;
      hasMore.value = _cursor != null;
      status.value = AdminAuditStatus.ready;
    } on Object {
      status.value = AdminAuditStatus.failed;
    }
  }
}
