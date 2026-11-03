import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/feed_repository.dart';
import '../../domain/scheduled_content.dart';
import '../controllers/feed_controller.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.controller});

  final FeedController controller;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SEHAT FEED')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Obx(() {
            final controller = widget.controller;
            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: controller.selectedCategory.value == null,
                        onSelected: (_) => controller.selectCategory(null),
                      ),
                      for (final category in controller.categories)
                        ChoiceChip(
                          label: Text(category),
                          selected:
                              controller.selectedCategory.value == category,
                          onSelected: (_) =>
                              controller.selectCategory(category),
                        ),
                    ],
                  ),
                  if (controller.errorMessage.value case final error?) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      label: 'Error: $error',
                      excludeSemantics: true,
                      child: Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.errorRed),
                      ),
                    ),
                  ],
                  if (controller.isLoading.value && controller.posts.isEmpty)
                    Semantics(
                      liveRegion: true,
                      label: 'Status: Loading reviewed posts',
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (controller.visiblePosts.isEmpty)
                    Semantics(
                      liveRegion: true,
                      label:
                          'Status: No reviewed posts are scheduled right now.',
                      excludeSemantics: true,
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            'No reviewed posts are scheduled right now.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    ...controller.visiblePosts.map(
                      (post) => _PostCard(
                        post: post,
                        reaction: controller.reactions[post.postId],
                        busy: controller.reactingPostIds.contains(post.postId),
                        onReaction: (reaction) =>
                            controller.react(post.postId, reaction),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    ),
  );
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.reaction,
    required this.busy,
    required this.onReaction,
  });

  final ScheduledContentPost post;
  final PrivatePostReaction? reaction;
  final bool busy;
  final ValueChanged<PrivatePostReaction> onReaction;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${post.category.toUpperCase()} • ${post.type == ContentPostType.healthFact ? 'REVIEWED FACT' : 'QUOTE'}',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.primaryGreen, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        Text(post.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(post.body),
        if (post.sourceCitation case final source?) ...[
          const SizedBox(height: 10),
          Text('Source: $source', style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final reactionButtons = <Widget>[
              Semantics(
                button: true,
                selected: reaction == PrivatePostReaction.like,
                label: busy ? 'Like privately, saving' : 'Like privately',
                excludeSemantics: true,
                child: IconButton(
                  tooltip: 'Like privately',
                  onPressed: busy
                      ? null
                      : () => onReaction(PrivatePostReaction.like),
                  icon: Icon(
                    reaction == PrivatePostReaction.like
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                  ),
                ),
              ),
              Semantics(
                button: true,
                selected: reaction == PrivatePostReaction.dislike,
                label: busy ? 'Dislike privately, saving' : 'Dislike privately',
                excludeSemantics: true,
                child: IconButton(
                  tooltip: 'Dislike privately',
                  onPressed: busy
                      ? null
                      : () => onReaction(PrivatePostReaction.dislike),
                  icon: Icon(
                    reaction == PrivatePostReaction.dislike
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                  ),
                ),
              ),
            ];
            final privacyLabel = Text(
              'Private',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: AppColors.textSecondary),
            );
            if (MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
                constraints.maxWidth < 260) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: reactionButtons,
                  ),
                  privacyLabel,
                ],
              );
            }
            return Row(
              children: [...reactionButtons, const Spacer(), privacyLabel],
            );
          },
        ),
      ],
    ),
  );
}
