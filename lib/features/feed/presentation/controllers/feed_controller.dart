import 'package:get/get.dart';

import '../../../account/domain/authenticated_owner_session.dart';
import '../../domain/feed_repository.dart';
import '../../domain/scheduled_content.dart';

class FeedController extends GetxController {
  FeedController(this._session, this._repository, this._locale);

  final AuthenticatedOwnerSession _session;
  final FeedRepository _repository;
  final ContentLocale _locale;

  final posts = <ScheduledContentPost>[].obs;
  final reactions = <String, PrivatePostReaction>{}.obs;
  final selectedCategory = RxnString();
  final isLoading = false.obs;
  final reactingPostIds = <String>{}.obs;
  final errorMessage = RxnString();

  List<String> get categories {
    final values = posts.map((post) => post.category).toSet().toList()..sort();
    return List.unmodifiable(values);
  }

  List<ScheduledContentPost> get visiblePosts {
    final category = selectedCategory.value;
    if (category == null) return List.unmodifiable(posts);
    return List.unmodifiable(posts.where((post) => post.category == category));
  }

  Future<void> load({DateTime? nowUtc}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final current = (nowUtc ?? DateTime.now().toUtc()).toUtc();
      final loaded = await _repository.fetchVisible(
        locale: _locale,
        nowUtc: current,
      );
      await _session.withOwner((ownerId) async {
        final private = await _repository.readPrivateReactions(
          ownerId,
          loaded.map((post) => post.postId),
        );
        posts.assignAll(loaded);
        reactions.assignAll(private);
      });
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = null;
      }
    } on Object {
      errorMessage.value = 'Feed is unavailable. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String? category) {
    if (category != null && !categories.contains(category)) return;
    selectedCategory.value = category;
  }

  Future<void> react(String postId, PrivatePostReaction reaction) async {
    if (!posts.any((post) => post.postId == postId) ||
        reactingPostIds.contains(postId)) {
      return;
    }
    reactingPostIds.add(postId);
    errorMessage.value = null;
    final previous = reactions[postId];
    final next = previous == reaction ? null : reaction;
    try {
      await _session.withOwner(
        (ownerId) => _repository.setPrivateReaction(
          ownerId: ownerId,
          postId: postId,
          reaction: next,
        ),
      );
      if (next == null) {
        reactions.remove(postId);
      } else {
        reactions[postId] = next;
      }
    } on Object {
      errorMessage.value = 'Your private reaction could not be saved.';
    } finally {
      reactingPostIds.remove(postId);
    }
  }
}
