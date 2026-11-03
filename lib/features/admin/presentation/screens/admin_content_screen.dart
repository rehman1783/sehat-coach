import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/responsive_content.dart';
import '../../../feed/domain/scheduled_content.dart';
import '../controllers/admin_content_controller.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key, required this.controller});
  final AdminContentController controller;

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('REVIEWED CONTENT')),
    body: SafeArea(
      child: Obx(() {
        final controller = widget.controller;
        if (controller.status.value == AdminContentStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading authorized reviewed content',
            ),
          );
        }
        if (controller.status.value == AdminContentStatus.denied) {
          return const _ContentMessage(
            message: 'You are not authorized to manage reviewed content.',
            error: true,
          );
        }
        if (controller.status.value == AdminContentStatus.failed) {
          return _ContentMessage(
            message: 'Reviewed content is temporarily unavailable.',
            error: true,
            onRetry: controller.load,
          );
        }
        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Text(
                'Content schedule',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Health facts require source attribution. Publication never bypasses independent review, scheduling or expiry.',
              ),
              const SizedBox(height: 20),
              if (controller.posts.isEmpty)
                const Text('No posts are awaiting administration.'),
              for (final post in controller.posts)
                _ContentCard(controller: controller, post: post),
              if (controller.message.value != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  label: 'Status: ${controller.message.value}',
                  excludeSemantics: true,
                  child: Text(controller.message.value!),
                ),
              ],
            ],
          ),
        );
      }),
    ),
  );
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.controller, required this.post});
  final AdminContentController controller;
  final ScheduledContentPost post;

  @override
  Widget build(BuildContext context) {
    final busy = controller.busyPostId.value == post.postId;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(post.body),
            const SizedBox(height: 8),
            Text('${_typeLabel(post.type)} • ${_localeLabel(post.locale)}'),
            Text('Category: ${post.category}'),
            if (post.sourceCitation != null)
              Text('Source: ${post.sourceCitation}'),
            Text('Starts UTC: ${post.publishAtUtc.toIso8601String()}'),
            Text('Expires UTC: ${post.expiresAtUtc.toIso8601String()}'),
            Text('Workflow: ${_statusLabel(post.status)}'),
            Text('Visibility: ${controller.visibilityLabel(post)}'),
            if (controller.actionLabel(post).isNotEmpty) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: controller.canAdvance(post) && !busy
                    ? () => controller.advance(post)
                    : null,
                child: Text(
                  busy ? 'SAVING…' : controller.actionLabel(post),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!controller.canAdvance(post))
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'A different authorized role or independent reviewer is required.',
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContentMessage extends StatelessWidget {
  const _ContentMessage({
    required this.message,
    required this.error,
    this.onRetry,
  });
  final String message;
  final bool error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            label: '${error ? 'Error' : 'Status'}: $message',
            excludeSemantics: true,
            child: Text(message, textAlign: TextAlign.center),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('TRY AGAIN')),
          ],
        ],
      ),
    ),
  );
}

String _typeLabel(ContentPostType type) => switch (type) {
  ContentPostType.quote => 'Quote',
  ContentPostType.healthFact => 'Health fact',
};

String _localeLabel(ContentLocale locale) => switch (locale) {
  ContentLocale.english => 'English',
  ContentLocale.romanUrdu => 'Roman Urdu',
};

String _statusLabel(ContentPostStatus status) => switch (status) {
  ContentPostStatus.draft => 'Draft',
  ContentPostStatus.inReview => 'In review',
  ContentPostStatus.approved => 'Approved',
  ContentPostStatus.published => 'Published',
  ContentPostStatus.revoked => 'Revoked',
};
