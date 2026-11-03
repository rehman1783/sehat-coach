import 'package:get/get.dart';

import '../../../bachat/domain/grocery_price.dart';
import '../../domain/admin_authorization.dart';

/// Production implementations must reauthorize [principal] on the server for
/// every read and transition, persist atomically, and append the audit event.
abstract interface class TrustedAdminGroceryPricePort {
  Future<List<GroceryPriceRecord>> loadPending({
    required StaffPrincipal principal,
  });

  Future<GroceryPriceRecord> submitForReview({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  });

  Future<GroceryPriceRecord> approve({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  });

  Future<GroceryPriceRecord> publish({
    required StaffPrincipal principal,
    required GroceryPriceRecord record,
  });
}

enum AdminGroceryPriceStatus { loading, ready, denied, failed }

class AdminGroceryPriceController extends GetxController {
  AdminGroceryPriceController({
    required this.principal,
    required this.source,
    required this.nowUtc,
    this.authorization = const AdminAuthorizationPolicy(),
  }) {
    if (!nowUtc.isUtc) throw ArgumentError('Current time must be UTC');
  }

  final StaffPrincipal principal;
  final TrustedAdminGroceryPricePort source;
  final DateTime nowUtc;
  final AdminAuthorizationPolicy authorization;
  final status = AdminGroceryPriceStatus.loading.obs;
  final records = <GroceryPriceRecord>[].obs;
  final busyPriceId = RxnString();
  final message = RxnString();

  Future<void> load() async {
    status.value = AdminGroceryPriceStatus.loading;
    message.value = null;
    if (!_hasMarketRole) {
      records.clear();
      status.value = AdminGroceryPriceStatus.denied;
      return;
    }
    try {
      records.assignAll(await source.loadPending(principal: principal));
      status.value = AdminGroceryPriceStatus.ready;
    } on AdminAuthorizationDenied {
      records.clear();
      status.value = AdminGroceryPriceStatus.denied;
    } on Object {
      records.clear();
      status.value = AdminGroceryPriceStatus.failed;
    }
  }

  bool canAdvance(GroceryPriceRecord record) {
    if (!_isActionable(record.status)) return false;
    try {
      authorization.authorize(_request(record));
      return true;
    } on AdminAuthorizationDenied {
      return false;
    }
  }

  String actionLabel(GroceryPriceRecord record) => switch (record.status) {
    GroceryPriceStatus.draft => 'SUBMIT FOR REVIEW',
    GroceryPriceStatus.inReview => 'APPROVE PRICE',
    GroceryPriceStatus.approved => 'PUBLISH PRICE',
    GroceryPriceStatus.published || GroceryPriceStatus.retired => '',
  };

  Future<void> advance(GroceryPriceRecord record) async {
    if (busyPriceId.value != null || !_isActionable(record.status)) return;
    try {
      authorization.authorize(_request(record));
    } on AdminAuthorizationDenied {
      message.value = 'This transition requires different authorized staff.';
      return;
    }
    busyPriceId.value = record.priceId;
    message.value = null;
    try {
      final updated = switch (record.status) {
        GroceryPriceStatus.draft => await source.submitForReview(
          principal: principal,
          record: record,
        ),
        GroceryPriceStatus.inReview => await source.approve(
          principal: principal,
          record: record,
        ),
        GroceryPriceStatus.approved => await source.publish(
          principal: principal,
          record: record,
        ),
        GroceryPriceStatus.published || GroceryPriceStatus.retired => record,
      };
      final index = records.indexWhere(
        (candidate) => candidate.priceId == record.priceId,
      );
      if (index >= 0) records[index] = updated;
      message.value = switch (updated.status) {
        GroceryPriceStatus.inReview =>
          'Price submitted for independent review.',
        GroceryPriceStatus.approved =>
          'Price approved. A separate publisher is required.',
        GroceryPriceStatus.published => 'Verified price published.',
        _ => null,
      };
    } on AdminAuthorizationDenied {
      message.value = 'The server denied this price transition.';
    } on Object {
      message.value = 'The price could not be updated. Existing data is safe.';
    } finally {
      busyPriceId.value = null;
    }
  }

  bool get _hasMarketRole =>
      principal.active &&
      principal.mfaVerified &&
      (principal.roles.contains(AdminRole.platformOwner) ||
          principal.roles.contains(AdminRole.marketEditor) ||
          principal.roles.contains(AdminRole.marketReviewer));

  bool _isActionable(GroceryPriceStatus value) => switch (value) {
    GroceryPriceStatus.draft ||
    GroceryPriceStatus.inReview ||
    GroceryPriceStatus.approved => true,
    GroceryPriceStatus.published || GroceryPriceStatus.retired => false,
  };

  AdminAuthorizationRequest _request(GroceryPriceRecord record) {
    final action = switch (record.status) {
      GroceryPriceStatus.draft => AdminAction.editMarketPrice,
      GroceryPriceStatus.inReview => AdminAction.approveMarketPrice,
      GroceryPriceStatus.approved => AdminAction.publishMarketPrice,
      GroceryPriceStatus.published ||
      GroceryPriceStatus.retired => throw StateError('Price is not actionable'),
    };
    return AdminAuthorizationRequest(
      actor: principal,
      action: action,
      targetType: 'grocery_price',
      targetId: record.priceId,
      originatingEditorId: record.createdBy,
      reviewerId: record.reviewerId,
    );
  }
}
