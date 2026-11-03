import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/feed/domain/feed_repository.dart';
import 'package:sehat_coach/features/feed/domain/scheduled_content.dart';
import 'package:sehat_coach/features/feed/presentation/controllers/feed_controller.dart';
import 'package:sehat_coach/features/feed/presentation/screens/feed_screen.dart';

void main() {
  testWidgets('feed remains usable at 200 percent text and exposes reactions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    final repository = _Repository([
      _post('a', 'Nutrition'),
      _post('b', 'Healthy habits'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: FeedScreen(
          controller: FeedController(
            _Session(),
            repository,
            ContentLocale.english,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Healthy habits'), findsOneWidget);
    final likeButton = find.bySemanticsLabel('Like privately').first;
    await tester.ensureVisible(likeButton);
    await tester.pumpAndSettle();
    await tester.tap(likeButton);
    await tester.pumpAndSettle();

    final node = tester.getSemantics(likeButton);
    expect(node.flagsCollection.isSelected, ui.Tristate.isTrue);
    expect(repository.reactions['a'], PrivatePostReaction.like);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('feed load failure is announced and can be refreshed', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repository = _Repository([])..failLoad = true;
    await tester.pumpWidget(
      MaterialApp(
        home: FeedScreen(
          controller: FeedController(
            _Session(),
            repository,
            ContentLocale.english,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Error: Feed is unavailable. Please try again.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Status: No reviewed posts are scheduled right now.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}

class _Repository implements FeedRepository {
  _Repository(this.values);

  final List<ScheduledContentPost> values;
  final reactions = <String, PrivatePostReaction>{};
  bool failLoad = false;

  @override
  Future<List<ScheduledContentPost>> fetchVisible({
    required ContentLocale locale,
    required DateTime nowUtc,
  }) async {
    if (failLoad) throw StateError('offline');
    return values;
  }

  @override
  Future<Map<String, PrivatePostReaction>> readPrivateReactions(
    String ownerId,
    Iterable<String> postIds,
  ) async => Map.of(reactions);

  @override
  Future<void> setPrivateReaction({
    required String ownerId,
    required String postId,
    required PrivatePostReaction? reaction,
  }) async {
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
  title: 'Synthetic reviewed title',
  body: 'Synthetic reviewed body used only for verification.',
  sourceId: 'source',
  sourceCitation: 'Synthetic source',
  publishAtUtc: DateTime.utc(2026, 10, 23, 8),
  expiresAtUtc: DateTime.utc(2026, 10, 24, 8),
  status: ContentPostStatus.published,
  createdBy: 'editor',
  reviewerId: 'reviewer',
  publishedAtUtc: DateTime.utc(2026, 10, 23, 7),
);
