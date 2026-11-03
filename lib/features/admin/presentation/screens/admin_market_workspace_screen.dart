import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_content.dart';

class AdminMarketWorkspaceScreen extends StatelessWidget {
  const AdminMarketWorkspaceScreen({
    super.key,
    required this.cityDestination,
    required this.priceDestination,
  });

  final WidgetBuilder cityDestination;
  final WidgetBuilder priceDestination;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('CITIES AND PRICES')),
    body: SafeArea(
      child: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Text(
              'Market administration',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'City releases and grocery prices use separate reviewed publication workflows.',
            ),
            const SizedBox(height: 20),
            _MarketCard(
              title: 'City configuration',
              description: 'Review the configurable Pakistan city list and Other-city fallback.',
              icon: Icons.location_city_outlined,
              onTap: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: cityDestination)),
            ),
            _MarketCard(
              title: 'Grocery prices',
              description: 'Review source, city, unit and verification evidence before publishing.',
              icon: Icons.price_check_outlined,
              onTap: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: priceDestination)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      minVerticalPadding: 16,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
