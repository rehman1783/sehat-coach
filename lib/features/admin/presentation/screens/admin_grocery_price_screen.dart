import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/responsive_content.dart';
import '../../../bachat/domain/grocery_price.dart';
import '../controllers/admin_grocery_price_controller.dart';

class AdminGroceryPriceScreen extends StatefulWidget {
  const AdminGroceryPriceScreen({super.key, required this.controller});

  final AdminGroceryPriceController controller;

  @override
  State<AdminGroceryPriceScreen> createState() =>
      _AdminGroceryPriceScreenState();
}

class _AdminGroceryPriceScreenState extends State<AdminGroceryPriceScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('GROCERY PRICES')),
    body: SafeArea(
      child: Obx(() {
        final controller = widget.controller;
        if (controller.status.value == AdminGroceryPriceStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading authorized grocery prices',
            ),
          );
        }
        if (controller.status.value == AdminGroceryPriceStatus.denied) {
          return const _PriceMessage(
            message: 'You are not authorized to manage grocery prices.',
            error: true,
          );
        }
        if (controller.status.value == AdminGroceryPriceStatus.failed) {
          return _PriceMessage(
            message: 'Grocery prices are temporarily unavailable.',
            error: true,
            onRetry: controller.load,
          );
        }
        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Text(
                'Verified market prices',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'A price becomes current only after source-backed verification, independent approval and publication.',
              ),
              const SizedBox(height: 20),
              if (controller.records.isEmpty)
                const Text('No grocery prices are awaiting administration.'),
              for (final record in controller.records)
                _PriceCard(controller: controller, record: record),
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

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.controller, required this.record});

  final AdminGroceryPriceController controller;
  final GroceryPriceRecord record;

  @override
  Widget build(BuildContext context) {
    final presentation = GroceryPricePresentation.fromRecord(
      record,
      controller.nowUtc,
    );
    final busy = controller.busyPriceId.value == record.priceId;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.commodityName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('${record.cityName} • ${record.marketName}'),
            Text(
              'Candidate amount: PKR ${record.pricePkr} / ${record.unitCode}',
            ),
            Text('Source: ${record.sourceCitation}'),
            Text('Observed UTC: ${record.observedAtUtc.toIso8601String()}'),
            Text(
              'Last verified UTC: ${record.lastVerifiedAtUtc.toIso8601String()}',
            ),
            Text('Workflow: ${_statusLabel(record.status)}'),
            Text(
              presentation.available
                  ? 'Current verified price'
                  : 'Not available to users as a current price',
            ),
            if (controller.actionLabel(record).isNotEmpty) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: controller.canAdvance(record) && !busy
                    ? () => controller.advance(record)
                    : null,
                child: Text(
                  busy ? 'SAVING…' : controller.actionLabel(record),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!controller.canAdvance(record))
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

class _PriceMessage extends StatelessWidget {
  const _PriceMessage({
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

String _statusLabel(GroceryPriceStatus status) => switch (status) {
  GroceryPriceStatus.draft => 'Draft',
  GroceryPriceStatus.inReview => 'In review',
  GroceryPriceStatus.approved => 'Approved',
  GroceryPriceStatus.published => 'Published',
  GroceryPriceStatus.retired => 'Retired',
};
