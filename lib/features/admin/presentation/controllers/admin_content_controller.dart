import 'package:get/get.dart';

import '../../../feed/domain/scheduled_content.dart';
import '../../domain/admin_authorization.dart';

/// Production implementations must reauthorize [principal], persist the
/// transition atomically and append its audit event on every call.
abstract interface class TrustedAdminContentPort {
  Future<List<ScheduledContentPost>> loadPosts({
    required StaffPrincipal principal,
  });

  Future<ScheduledContentPost> submitForReview({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  });

  Future<ScheduledContentPost> approve({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  });

  Future<ScheduledContentPost> publish({
    required StaffPrincipal principal,
    required ScheduledContentPost post,
  });
}

enum AdminContentStatus { loading, ready, denied, failed }

class AdminContentController extends GetxController {
  AdminContentController({
    required this.principal,
    required this.source,
    required this.nowUtc,
    this.authorization = const AdminAuthorizationPolicy(),
  }) {
    if (!nowUtc.isUtc) throw ArgumentError('Current time must be UTC');
  }

  final StaffPrincipal principal;
  final TrustedAdminContentPort source;
  final DateTime nowUtc;
  final AdminAuthorizationPolicy authorization;
  final status = AdminContentStatus.loading.obs;
  final posts = <ScheduledContentPost>[].obs;
  final busyPostId = RxnString();
  final message = RxnString();

  Future<void> load() async {
    status.value = AdminContentStatus.loading;
    message.value = null;
    if (!_hasContentRole) {
      posts.clear();
      status.value = AdminContentStatus.denied;
      return;
    }
    try {
      posts.assignAll(await source.loadPosts(principal: principal));
      status.value = AdminContentStatus.ready;
    } on AdminAuthorizationDenied {
      posts.clear();
      status.value = AdminContentStatus.denied;
    } on Object {
      posts.clear();
      status.value = AdminContentStatus.failed;
    }
  }

  bool canAdvance(ScheduledContentPost post) {
    if (!_isActionable(post.status)) return false;
    try {
      authorization.authorize(_request(post));
      return true;
    } on AdminAuthorizationDenied {
      return false;
    }
  }

  String actionLabel(ScheduledContentPost post) => switch (post.status) {
    ContentPostStatus.draft => 'SUBMIT FOR REVIEW',
    ContentPostStatus.inReview => 'APPROVE POST',
    ContentPostStatus.approved => 'PUBLISH POST',
    ContentPostStatus.published || ContentPostStatus.revoked => '',
  };

  String visibilityLabel(ScheduledContentPost post) {
    if (post.status != ContentPostStatus.published ||
        post.publishedAtUtc == null) {
      return 'Not live';
    }
    if (nowUtc.isBefore(post.publishAtUtc)) return 'Published • scheduled';
    if (!nowUtc.isBefore(post.expiresAtUtc)) return 'Published • expired';
    return 'Live now';
  }

  Future<void> advance(ScheduledContentPost post) async {
    if (busyPostId.value != null || !_isActionable(post.status)) return;
    try {
      authorization.authorize(_request(post));
    } on AdminAuthorizationDenied {
      message.value = 'This transition requires different authorized staff.';
      return;
    }
    busyPostId.value = post.postId;
    message.value = null;
    try {
      final updated = switch (post.status) {
        ContentPostStatus.draft => await source.submitForReview(
          principal: principal,
          post: post,
        ),
        ContentPostStatus.inReview => await source.approve(
          principal: principal,
          post: post,
        ),
        ContentPostStatus.approved => await source.publish(
          principal: principal,
          post: post,
        ),
        ContentPostStatus.published || ContentPostStatus.revoked => post,
      };
      final index = posts.indexWhere(
        (candidate) => candidate.postId == post.postId,
      );
      if (index >= 0) posts[index] = updated;
      message.value = switch (updated.status) {
        ContentPostStatus.inReview => 'Post submitted for independent review.',
        ContentPostStatus.approved =>
          'Post approved. A separate publisher is required.',
        ContentPostStatus.published => 'Post published to its UTC schedule.',
        _ => null,
      };
    } on AdminAuthorizationDenied {
      message.value = 'The server denied this content transition.';
    } on Object {
      message.value = 'The post could not be updated. Existing data is safe.';
    } finally {
      busyPostId.value = null;
    }
  }

  bool get _hasContentRole =>
      principal.active &&
      principal.mfaVerified &&
      (principal.roles.contains(AdminRole.platformOwner) ||
          principal.roles.contains(AdminRole.contentEditor) ||
          principal.roles.contains(AdminRole.contentReviewer));

  bool _isActionable(ContentPostStatus value) => switch (value) {
    ContentPostStatus.draft ||
    ContentPostStatus.inReview ||
    ContentPostStatus.approved => true,
    ContentPostStatus.published || ContentPostStatus.revoked => false,
  };

  AdminAuthorizationRequest _request(ScheduledContentPost post) {
    final action = switch (post.status) {
      ContentPostStatus.draft => AdminAction.editContent,
      ContentPostStatus.inReview => AdminAction.approveContent,
      ContentPostStatus.approved => AdminAction.publishContent,
      ContentPostStatus.published ||
      ContentPostStatus.revoked => throw StateError('Post is not actionable'),
    };
    return AdminAuthorizationRequest(
      actor: principal,
      action: action,
      targetType: 'scheduled_content',
      targetId: post.postId,
      originatingEditorId: post.createdBy,
      reviewerId: post.reviewerId,
    );
  }
}
