import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/responsive_content.dart';
import '../../domain/city_configuration_workflow.dart';
import '../controllers/admin_city_controller.dart';

class AdminCityScreen extends StatefulWidget {
  const AdminCityScreen({super.key, required this.controller});

  final AdminCityController controller;

  @override
  State<AdminCityScreen> createState() => _AdminCityScreenState();
}

class _AdminCityScreenState extends State<AdminCityScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CITY CONFIGURATION')),
    body: SafeArea(
      child: Obx(() {
        final controller = widget.controller;
        if (controller.status.value == AdminCityStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading authorized city configuration',
            ),
          );
        }
        if (controller.status.value == AdminCityStatus.denied) {
          return const _CityMessage(
            message: 'You are not authorized to manage city configuration.',
            error: true,
          );
        }
        if (controller.status.value == AdminCityStatus.failed) {
          return _CityMessage(
            message: 'City configuration is temporarily unavailable.',
            error: true,
            onRetry: controller.load,
          );
        }
        final draft = controller.draft.value;
        if (draft == null) {
          return const _CityMessage(
            message: 'No city release is awaiting administration.',
            error: false,
          );
        }
        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Text(
                'Pakistan city release',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('Version ${draft.version} • ${_stageLabel(draft.stage)}'),
              Text('Release: ${draft.releaseId}'),
              Text('Checksum: ${draft.contentChecksum}'),
              const SizedBox(height: 12),
              const Text(
                'Core features remain city-independent. Publishing requires server authorization, an audit record and independent review.',
              ),
              const SizedBox(height: 20),
              for (final city in draft.cities)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    minVerticalPadding: 14,
                    leading: Icon(
                      city.enabled
                          ? Icons.location_city_outlined
                          : Icons.location_off_outlined,
                    ),
                    title: Text(city.displayName),
                    subtitle: Text(
                      city.isOther
                          ? 'Required configurable fallback'
                          : city.enabled
                          ? 'Enabled • order ${city.sortOrder}'
                          : 'Disabled',
                    ),
                  ),
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
              const SizedBox(height: 16),
              if (!controller.published.value)
                FilledButton(
                  onPressed:
                      controller.canAdvance &&
                          controller.status.value != AdminCityStatus.saving
                      ? controller.advance
                      : null,
                  child: Text(
                    controller.status.value == AdminCityStatus.saving
                        ? 'SAVING…'
                        : controller.actionLabel,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!controller.canAdvance && !controller.published.value)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'This transition requires a different authorized staff role or independent reviewer.',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      }),
    ),
  );
}

class _CityMessage extends StatelessWidget {
  const _CityMessage({
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

String _stageLabel(CityConfigurationStage stage) => switch (stage) {
  CityConfigurationStage.draft => 'Draft',
  CityConfigurationStage.inReview => 'In review',
  CityConfigurationStage.approved => 'Approved',
};
