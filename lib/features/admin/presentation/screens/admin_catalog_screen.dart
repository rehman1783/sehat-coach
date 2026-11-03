import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/responsive_content.dart';
import '../../domain/catalog_publication_workflow.dart';
import '../controllers/admin_catalog_controller.dart';

class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key, required this.controller});

  final AdminCatalogController controller;

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FOOD CATALOG')),
    body: SafeArea(
      child: Obx(() {
        final controller = widget.controller;
        if (controller.status.value == AdminCatalogStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading authorized catalog releases',
            ),
          );
        }
        if (controller.status.value == AdminCatalogStatus.denied) {
          return const _CatalogMessage(
            message: 'You are not authorized to manage catalog releases.',
            error: true,
          );
        }
        if (controller.status.value == AdminCatalogStatus.failed) {
          return _CatalogMessage(
            message: 'Catalog releases are temporarily unavailable.',
            error: true,
            onRetry: controller.load,
          );
        }
        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Text(
                'Versioned food catalog',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Only source-attributed, independently reviewed releases may be published. Revocation never edits an immutable release.',
              ),
              const SizedBox(height: 20),
              if (controller.releases.isEmpty)
                const Text('No catalog releases are awaiting administration.'),
              for (final release in controller.releases)
                _CatalogReleaseCard(
                  controller: controller,
                  release: release,
                  confirmRevocation: () => _confirmRevocation(context, release),
                ),
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

  Future<void> _confirmRevocation(
    BuildContext context,
    CatalogReleaseRecord release,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke catalog release?'),
        content: Text(
          'Release ${release.version} will stop being eligible for distribution. The immutable release and audit history remain preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM REVOKE'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.controller.advance(release, revokeConfirmed: true);
    }
  }
}

class _CatalogReleaseCard extends StatelessWidget {
  const _CatalogReleaseCard({
    required this.controller,
    required this.release,
    required this.confirmRevocation,
  });

  final AdminCatalogController controller;
  final CatalogReleaseRecord release;
  final VoidCallback confirmRevocation;

  @override
  Widget build(BuildContext context) {
    final busy = controller.busyReleaseId.value == release.releaseId;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${release.version}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('Release: ${release.releaseId}'),
            Text('Checksum: ${release.contentChecksum}'),
            Text('Workflow: ${_stageLabel(release.stage)}'),
            Text('${release.foodCount} foods • ${release.recipeCount} recipes'),
            const SizedBox(height: 10),
            Text(
              'Source evidence',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            for (final source in release.sources)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${source.citation} • ${source.sourceVersion}\nLicense: ${source.licenseId}',
                ),
              ),
            if (controller.actionLabel(release).isNotEmpty) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: controller.canAdvance(release) && !busy
                    ? release.stage == CatalogReleaseStage.published
                          ? confirmRevocation
                          : () => controller.advance(release)
                    : null,
                child: Text(
                  busy ? 'SAVING…' : controller.actionLabel(release),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!controller.canAdvance(release))
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

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
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

String _stageLabel(CatalogReleaseStage stage) => switch (stage) {
  CatalogReleaseStage.draft => 'Draft',
  CatalogReleaseStage.inReview => 'In review',
  CatalogReleaseStage.approved => 'Approved',
  CatalogReleaseStage.published => 'Published',
  CatalogReleaseStage.revoked => 'Revoked',
};
