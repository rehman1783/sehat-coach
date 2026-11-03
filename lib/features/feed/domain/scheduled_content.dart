enum ContentPostType { quote, healthFact }

enum ContentLocale { english, romanUrdu }

enum ContentPostStatus { draft, inReview, approved, published, revoked }

class ScheduledContentPost {
  ScheduledContentPost({
    required this.postId,
    required this.type,
    required this.locale,
    required this.category,
    required this.title,
    required this.body,
    required this.publishAtUtc,
    required this.expiresAtUtc,
    required this.status,
    required this.createdBy,
    this.sourceId,
    this.sourceCitation,
    this.reviewerId,
    this.publishedAtUtc,
  }) {
    for (final value in [postId, category, title, body, createdBy]) {
      if (value.trim().isEmpty) {
        throw ArgumentError('Content identity and copy are required');
      }
    }
    if (!publishAtUtc.isUtc ||
        !expiresAtUtc.isUtc ||
        (publishedAtUtc != null && !publishedAtUtc!.isUtc)) {
      throw ArgumentError('Content timestamps must be UTC');
    }
    if (!expiresAtUtc.isAfter(publishAtUtc)) {
      throw ArgumentError('Content expiry must follow its schedule');
    }
    if (type == ContentPostType.healthFact &&
        ((sourceId?.trim().isEmpty ?? true) ||
            (sourceCitation?.trim().isEmpty ?? true))) {
      throw ArgumentError('Health facts require source attribution');
    }
  }

  final String postId;
  final ContentPostType type;
  final ContentLocale locale;
  final String category;
  final String title;
  final String body;
  final String? sourceId;
  final String? sourceCitation;
  final DateTime publishAtUtc;
  final DateTime expiresAtUtc;
  final ContentPostStatus status;
  final String createdBy;
  final String? reviewerId;
  final DateTime? publishedAtUtc;

  bool isVisibleAt(DateTime nowUtc) {
    if (!nowUtc.isUtc) throw ArgumentError('Current time must be UTC');
    return status == ContentPostStatus.published &&
        publishedAtUtc != null &&
        !nowUtc.isBefore(publishAtUtc) &&
        nowUtc.isBefore(expiresAtUtc);
  }

  ScheduledContentPost copyWith({
    ContentPostStatus? status,
    String? reviewerId,
    DateTime? publishedAtUtc,
  }) => ScheduledContentPost(
    postId: postId,
    type: type,
    locale: locale,
    category: category,
    title: title,
    body: body,
    sourceId: sourceId,
    sourceCitation: sourceCitation,
    publishAtUtc: publishAtUtc,
    expiresAtUtc: expiresAtUtc,
    status: status ?? this.status,
    createdBy: createdBy,
    reviewerId: reviewerId ?? this.reviewerId,
    publishedAtUtc: publishedAtUtc ?? this.publishedAtUtc,
  );
}

class ScheduledFeedDay {
  ScheduledFeedDay(Iterable<ScheduledContentPost> posts)
    : posts = List.unmodifiable(posts) {
    if (this.posts.length == 1 || this.posts.length > 4) {
      throw ArgumentError('A feed day must contain zero or two to four posts');
    }
  }

  final List<ScheduledContentPost> posts;

  List<ScheduledContentPost> visibleAt(DateTime nowUtc, ContentLocale locale) =>
      List.unmodifiable(
        posts.where(
          (post) => post.locale == locale && post.isVisibleAt(nowUtc),
        ),
      );
}
