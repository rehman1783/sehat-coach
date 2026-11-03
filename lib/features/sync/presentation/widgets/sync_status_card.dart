import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/sync_status_controller.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key, required this.controller});

  final SyncStatusController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final status = controller.status.value;
    if (controller.isLoading.value && status.isSynced) {
      return Semantics(
        container: true,
        liveRegion: true,
        label: 'Status: Checking synchronization queue',
        excludeSemantics: true,
        child: const LinearProgressIndicator(minHeight: 2),
      );
    }
    final failed = status.needsAttention;
    final synced = status.isSynced;
    final color = failed
        ? AppColors.errorRed
        : synced
        ? AppColors.primaryGreen
        : const Color(0xFF8A6A00);
    final title = failed
        ? '${status.failedCount} change${status.failedCount == 1 ? ' needs' : 's need'} attention'
        : synced
        ? 'Saved and synchronized'
        : '${status.pendingCount} change${status.pendingCount == 1 ? '' : 's'} waiting to sync';
    final detail =
        controller.errorMessage.value ??
        (synced
            ? 'Your upload queue is clear.'
            : _pendingMessage(status.oldestPendingAt));
    return Semantics(
      container: true,
      liveRegion: true,
      label:
          '${controller.errorMessage.value == null ? 'Status' : 'Error'}: $title. $detail',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Row(
              children: [
                Icon(
                  failed
                      ? Icons.sync_problem_rounded
                      : synced
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_upload_outlined,
                  color: color,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            );
            final retry = controller.canRetry && !synced
                ? IconButton(
                    tooltip: 'Retry sync',
                    onPressed: controller.isSyncing.value
                        ? null
                        : controller.retry,
                    icon: controller.isSyncing.value
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                  )
                : null;
            final stack =
                constraints.maxWidth < 380 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            if (stack && retry != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  details,
                  Align(alignment: Alignment.centerRight, child: retry),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: details),
                ?retry,
              ],
            );
          },
        ),
      ),
    );
  });
}

String _pendingMessage(DateTime? oldest) {
  if (oldest == null) return 'Your changes are saved safely on this device.';
  final local = oldest.toLocal();
  final minute = local.minute.toString().padLeft(2, '0');
  return 'Saved safely on this device • waiting since '
      '${local.day}/${local.month} at ${local.hour}:$minute';
}
