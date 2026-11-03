import '../../bachat/domain/grocery_price.dart';
import 'admin_audit.dart';
import 'admin_authorization.dart';

class InvalidGroceryPriceTransition implements Exception {
  const InvalidGroceryPriceTransition();
}

class GroceryPriceWorkflow {
  const GroceryPriceWorkflow({required this.audit});

  final RecordAuthorizedAdminAction audit;

  Future<GroceryPriceRecord> submitForReview({
    required StaffPrincipal actor,
    required GroceryPriceRecord record,
  }) => _advance(
    actor: actor,
    record: record,
    expected: GroceryPriceStatus.draft,
    next: GroceryPriceStatus.inReview,
    action: AdminAction.editMarketPrice,
  );

  Future<GroceryPriceRecord> approve({
    required StaffPrincipal actor,
    required GroceryPriceRecord record,
  }) => _advance(
    actor: actor,
    record: record,
    expected: GroceryPriceStatus.inReview,
    next: GroceryPriceStatus.approved,
    action: AdminAction.approveMarketPrice,
    reviewerId: actor.staffId,
  );

  Future<GroceryPriceRecord> publish({
    required StaffPrincipal actor,
    required GroceryPriceRecord record,
  }) => _advance(
    actor: actor,
    record: record,
    expected: GroceryPriceStatus.approved,
    next: GroceryPriceStatus.published,
    action: AdminAction.publishMarketPrice,
    published: true,
  );

  Future<GroceryPriceRecord> _advance({
    required StaffPrincipal actor,
    required GroceryPriceRecord record,
    required GroceryPriceStatus expected,
    required GroceryPriceStatus next,
    required AdminAction action,
    String? reviewerId,
    bool published = false,
  }) async {
    if (record.status != expected) {
      throw const InvalidGroceryPriceTransition();
    }
    final request = AdminAuthorizationRequest(
      actor: actor,
      action: action,
      targetType: 'grocery_price',
      targetId: record.priceId,
      originatingEditorId: record.createdBy,
      reviewerId: record.reviewerId,
    );
    final updated = record.copyWith(
      status: next,
      reviewerId: reviewerId,
      publishedAtUtc: published ? audit.clock.nowUtc() : null,
    );
    await audit.execute(
      request: request,
      beforeMetadata: _metadata(record),
      afterMetadata: _metadata(updated),
    );
    return updated;
  }

  Map<String, Object?> _metadata(GroceryPriceRecord record) => {
    'status': record.status.name,
    'commodityId': record.commodityId,
    'cityId': record.cityId,
    'marketName': record.marketName,
    'unitCode': record.unitCode,
    'pricePkr': record.pricePkr,
    'sourceId': record.sourceId,
    'observedAtUtc': record.observedAtUtc.toIso8601String(),
    'lastVerifiedAtUtc': record.lastVerifiedAtUtc.toIso8601String(),
    'reviewerId': record.reviewerId,
    'publishedAtUtc': record.publishedAtUtc?.toIso8601String(),
  };
}
