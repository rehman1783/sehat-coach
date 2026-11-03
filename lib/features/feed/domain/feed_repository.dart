import 'scheduled_content.dart';

enum PrivatePostReaction { like, dislike }

abstract interface class FeedRepository {
  Future<List<ScheduledContentPost>> fetchVisible({
    required ContentLocale locale,
    required DateTime nowUtc,
  });

  Future<Map<String, PrivatePostReaction>> readPrivateReactions(
    String ownerId,
    Iterable<String> postIds,
  );

  /// A null reaction removes the owner's existing reaction for this post.
  Future<void> setPrivateReaction({
    required String ownerId,
    required String postId,
    required PrivatePostReaction? reaction,
  });
}
