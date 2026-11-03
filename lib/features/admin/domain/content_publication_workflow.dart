import '../../feed/domain/scheduled_content.dart';
import 'admin_audit.dart';
import 'admin_authorization.dart';

class InvalidContentTransition implements Exception {
  const InvalidContentTransition();
}

class ContentPublicationWorkflow {
  const ContentPublicationWorkflow({required this.audit});

  final RecordAuthorizedAdminAction audit;

  Future<ScheduledContentPost> submitForReview({
    required StaffPrincipal actor,
    required ScheduledContentPost post,
  }) => _advance(
    actor: actor,
    post: post,
    expected: ContentPostStatus.draft,
    next: ContentPostStatus.inReview,
    action: AdminAction.editContent,
  );

  Future<ScheduledContentPost> approve({
    required StaffPrincipal actor,
    required ScheduledContentPost post,
  }) => _advance(
    actor: actor,
    post: post,
    expected: ContentPostStatus.inReview,
    next: ContentPostStatus.approved,
    action: AdminAction.approveContent,
    reviewerId: actor.staffId,
  );

  Future<ScheduledContentPost> publish({
    required StaffPrincipal actor,
    required ScheduledContentPost post,
  }) => _advance(
    actor: actor,
    post: post,
    expected: ContentPostStatus.approved,
    next: ContentPostStatus.published,
    action: AdminAction.publishContent,
    published: true,
  );

  Future<ScheduledContentPost> _advance({
    required StaffPrincipal actor,
    required ScheduledContentPost post,
    required ContentPostStatus expected,
    required ContentPostStatus next,
    required AdminAction action,
    String? reviewerId,
    bool published = false,
  }) async {
    if (post.status != expected) throw const InvalidContentTransition();
    final request = AdminAuthorizationRequest(
      actor: actor,
      action: action,
      targetType: 'scheduled_content',
      targetId: post.postId,
      originatingEditorId: post.createdBy,
      reviewerId: post.reviewerId,
    );
    final updated = post.copyWith(
      status: next,
      reviewerId: reviewerId,
      publishedAtUtc: published ? audit.clock.nowUtc() : null,
    );
    await audit.execute(
      request: request,
      beforeMetadata: _metadata(post),
      afterMetadata: _metadata(updated),
    );
    return updated;
  }

  Map<String, Object?> _metadata(ScheduledContentPost post) => {
    'status': post.status.name,
    'type': post.type.name,
    'locale': post.locale.name,
    'category': post.category,
    'sourceId': post.sourceId,
    'publishAtUtc': post.publishAtUtc.toIso8601String(),
    'expiresAtUtc': post.expiresAtUtc.toIso8601String(),
    'reviewerId': post.reviewerId,
    'publishedAtUtc': post.publishedAtUtc?.toIso8601String(),
  };
}
