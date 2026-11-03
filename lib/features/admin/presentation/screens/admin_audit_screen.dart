import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/responsive_content.dart';
import '../../domain/admin_audit.dart';
import '../../domain/admin_authorization.dart';
import '../controllers/admin_audit_controller.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key, required this.controller});

  final AdminAuditController controller;

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load(restart: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ADMIN AUDIT LOG')),
    body: SafeArea(
      child: Obx(() {
        final controller = widget.controller;
        if (controller.status.value == AdminAuditStatus.loading &&
            controller.events.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading authorized audit activity',
            ),
          );
        }
        if (controller.status.value == AdminAuditStatus.denied) {
          return const _AuditMessage(
            error: true,
            message: 'You are not authorized to view the audit log.',
          );
        }
        if (controller.status.value == AdminAuditStatus.failed &&
            controller.events.isEmpty) {
          return _AuditMessage(
            error: true,
            message: 'Audit activity is temporarily unavailable.',
            onRetry: () => controller.load(restart: true),
          );
        }
        if (controller.events.isEmpty) {
          return const _AuditMessage(
            error: false,
            message: 'No authorized audit activity is available.',
          );
        }
        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              const Text(
                'Server-authorized, append-only administrative activity.',
              ),
              const SizedBox(height: 16),
              for (final event in controller.events)
                _AuditEventCard(event: event),
              if (controller.status.value == AdminAuditStatus.failed)
                const _AuditMessage(
                  error: true,
                  message: 'More activity could not be loaded. Existing entries remain visible.',
                ),
              if (controller.hasMore.value) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: controller.status.value == AdminAuditStatus.loading
                      ? null
                      : controller.load,
                  child: Text(
                    controller.status.value == AdminAuditStatus.loading
                        ? 'LOADING…'
                        : 'LOAD MORE',
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    ),
  );
}

class _AuditEventCard extends StatelessWidget {
  const _AuditEventCard({required this.event});
  final AdminAuditEvent event;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _label(event.action),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text('${event.targetType} • ${event.targetId}'),
          Text('Actor: ${event.actorId}'),
          if (event.reviewerId != null) Text('Reviewer: ${event.reviewerId}'),
          Text('UTC: ${event.occurredAtUtc.toIso8601String()}'),
        ],
      ),
    ),
  );
}

class _AuditMessage extends StatelessWidget {
  const _AuditMessage({
    required this.error,
    required this.message,
    this.onRetry,
  });

  final bool error;
  final String message;
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

String _label(AdminAction action) => action.name.replaceAllMapped(
  RegExp(r'([a-z])([A-Z])'),
  (match) => '${match[1]} ${match[2]!.toLowerCase()}',
);
