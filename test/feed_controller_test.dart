import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/feed/domain/feed_repository.dart';
import 'package:sehat_coach/features/feed/domain/scheduled_content.dart';
import 'package:sehat_coach/features/feed/presentation/controllers/feed_controller.dart';

void main() {
  test(
    'loads authenticated private reactions and filters categories',
    () async {
      final repository = _Repository([
        _post('a', 'Nutrition'),
        _post('b', 'Habits'),
      ])..reactions['a'] = PrivatePostReaction.like;
      final controller = FeedController(
        _Session(),
        repository,
        ContentLocale.english,
      );

      await controller.load(nowUtc: DateTime.utc(2026, 10, 23, 12));
      expect(controller.posts, hasLength(2));
      expect(controller.reactions['a'], PrivatePostReaction.like);
      expect(repository.reactionOwner, 'owner-a');
      controller.selectCategory('Habits');
      expect(controller.visiblePosts.single.postId, 'b');
    },
  );

  test('one reaction per owner and post can change or be removed', () async {
    final repository = _Repository([_post('a', 'Nutrition')]);
    final controller = FeedController(
      _Session(),
      repository,
      ContentLocale.english,
    );
    await controller.load(nowUtc: DateTime.utc(2026, 10, 23, 12));

    await controller.react('a', PrivatePostReaction.like);
    expect(repository.reactions, {'a': PrivatePostReaction.like});
    await controller.react('a', PrivatePostReaction.dislike);
    expect(repository.reactions, {'a': PrivatePostReaction.dislike});
    await controller.react('a', PrivatePostReaction.dislike);
    expect(repository.reactions, isEmpty);
    expect(repository.reactionOwner, 'owner-a');
  });

  test('failed reaction keeps prior local selection', () async {
    final repository = _Repository([_post('a', 'Nutrition')])
      ..reactions['a'] = PrivatePostReaction.like
      ..failReaction = true;
    final controller = FeedController(
      _Session(),
      repository,
      ContentLocale.english,
    );
    await controller.load(nowUtc: DateTime.utc(2026, 10, 23, 12));

    await controller.react('a', PrivatePostReaction.dislike);
    expect(controller.reactions['a'], PrivatePostReaction.like);
    expect(controller.errorMessage.value, contains('could not be saved'));
  });
}

class _Repository implements FeedRepository {
  _Repository(this.values);
  final List<ScheduledContentPost> values;
  final reactions = <String, PrivatePostReaction>{};
  String? reactionOwner;
  bool failReaction = false;

  @override
  Future<List<ScheduledContentPost>> fetchVisible({
    required ContentLocale locale,
    required DateTime nowUtc,
  }) async => values;

  @override
  Future<Map<String, PrivatePostReaction>> readPrivateReactions(
    String ownerId,
    Iterable<String> postIds,
  ) async {
    reactionOwner = ownerId;
    return Map.of(reactions);
  }

  @override
  Future<void> setPrivateReaction({
    required String ownerId,
    required String postId,
    required PrivatePostReaction? reaction,
  }) async {
    reactionOwner = ownerId;
    if (failReaction) throw StateError('offline');
    if (reaction == null) {
      reactions.remove(postId);
    } else {
      reactions[postId] = reaction;
    }
  }
}

class _Session implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

ScheduledContentPost _post(String id, String category) => ScheduledContentPost(
  postId: id,
  type: ContentPostType.healthFact,
  locale: ContentLocale.english,
  category: category,
  title: 'Synthetic title',
  body: 'Synthetic body',
  sourceId: 'source',
  sourceCitation: 'Synthetic source',
  publishAtUtc: DateTime.utc(2026, 10, 23, 8),
  expiresAtUtc: DateTime.utc(2026, 10, 24, 8),
  status: ContentPostStatus.published,
  createdBy: 'editor',
  reviewerId: 'reviewer',
  publishedAtUtc: DateTime.utc(2026, 10, 23, 7),
);
