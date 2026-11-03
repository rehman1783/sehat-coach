import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/product_catalog.dart';
import '../controllers/paywall_controller.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, required this.controller});
  final PaywallController controller;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surface,
    appBar: AppBar(title: const Text('CHOOSE A PLAN')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Obx(() {
            final controller = widget.controller;
            if (controller.isLoading.value && controller.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                Text(
                  'Choose what fits your needs',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Prices below come directly from Google Play. Purchases unlock access only after server verification.',
                ),
                if (controller.statusMessage.value case final status?) ...[
                  const SizedBox(height: 14),
                  Semantics(
                    liveRegion: true,
                    label: 'Status: $status',
                    excludeSemantics: true,
                    child: Text(status),
                  ),
                ],
                if (controller.errorMessage.value case final error?) ...[
                  const SizedBox(height: 14),
                  Semantics(
                    liveRegion: true,
                    label: 'Error: $error',
                    excludeSemantics: true,
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.errorRed),
                    ),
                  ),
                ],
                if (!controller.hasCurrentCatalog &&
                    !controller.isLoading.value) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: controller.isOnline.value
                        ? controller.load
                        : null,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('TRY AGAIN'),
                  ),
                ],
                const SizedBox(height: 18),
                for (final product in controller.products)
                  _ProductCard(
                    product: product,
                    purchasing:
                        controller.purchasingProductId.value ==
                        product.definition.id,
                    purchaseBlocked:
                        controller.purchasingProductId.value != null ||
                        !controller.hasCurrentCatalog,
                    onPurchase: () => controller.purchase(product),
                  ),
              ],
            );
          }),
        ),
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.purchasing,
    required this.purchaseBlocked,
    required this.onPurchase,
  });

  final PaywallProduct product;
  final bool purchasing;
  final bool purchaseBlocked;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final definition = product.definition;
    final play = product.playPresentation;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(definition.description),
            const SizedBox(height: 12),
            for (final benefit in definition.benefitLabels)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Text(
              play?.localizedPrice ?? 'Unavailable from Google Play',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !product.isPurchasable || purchaseBlocked
                    ? null
                    : onPurchase,
                child: Text(purchasing ? 'VERIFYING…' : 'CONTINUE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
