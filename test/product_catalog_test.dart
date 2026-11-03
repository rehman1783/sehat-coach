import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/entitlements/domain/product_catalog.dart';

void main() {
  test('joins remote benefits with Google Play localized price', () async {
    final result = await LoadPaywallProducts(
      configuration: _Configuration([
        _subscription(order: 2),
        _credits(order: 1),
      ]),
      playCatalog: _PlayCatalog([
        PlayProductPresentation(
          playProductId: 'play.premium.monthly',
          localizedPrice: 'PKR 999.00',
          currencyCode: 'PKR',
        ),
      ]),
    ).execute();

    expect(result.map((item) => item.definition.id), ['credits-10', 'premium']);
    expect(result.first.isPurchasable, isFalse);
    expect(result.last.playPresentation?.localizedPrice, 'PKR 999.00');
  });

  test('never fabricates price when Play does not return a product', () async {
    final result = await LoadPaywallProducts(
      configuration: _Configuration([_subscription(order: 0)]),
      playCatalog: _PlayCatalog(const []),
    ).execute();

    expect(result.single.playPresentation, isNull);
    expect(result.single.isPurchasable, isFalse);
  });

  test('rejects duplicate remote or Play product identities', () async {
    expect(
      () => EntitlementProductCatalog(
        revision: 1,
        publishedAtUtc: DateTime.utc(2026, 10, 25),
        products: [_subscription(order: 0), _subscription(order: 1)],
      ),
      throwsArgumentError,
    );

    final duplicate = PlayProductPresentation(
      playProductId: 'play.premium.monthly',
      localizedPrice: 'PKR 999.00',
      currencyCode: 'PKR',
    );
    await expectLater(
      LoadPaywallProducts(
        configuration: _Configuration([_subscription(order: 0)]),
        playCatalog: _PlayCatalog([duplicate, duplicate]),
      ).execute(),
      throwsStateError,
    );
  });
}

EntitlementProductDefinition _subscription({required int order}) =>
    EntitlementProductDefinition(
      id: 'premium',
      playProductId: 'play.premium.monthly',
      kind: EntitlementProductKind.subscription,
      title: 'Premium plan',
      description: 'Server-configured test description',
      benefitLabels: const ['AI meal assistance'],
      featureIds: const {'ai-meal-log'},
      displayOrder: order,
    );

EntitlementProductDefinition _credits({required int order}) =>
    EntitlementProductDefinition(
      id: 'credits-10',
      playProductId: 'play.credits.10',
      kind: EntitlementProductKind.consumableCredits,
      title: '10 credits',
      description: 'Server-configured test description',
      benefitLabels: const ['10 assisted actions'],
      featureIds: const {},
      displayOrder: order,
      creditAmount: 10,
    );

class _Configuration implements EntitlementProductCatalogGateway {
  _Configuration(this.products);
  final List<EntitlementProductDefinition> products;

  @override
  Future<EntitlementProductCatalog> loadActiveCatalog() async =>
      EntitlementProductCatalog(
        revision: 1,
        publishedAtUtc: DateTime.utc(2026, 10, 25),
        products: products,
      );
}

class _PlayCatalog implements PlayProductCatalogGateway {
  _PlayCatalog(this.products);
  final List<PlayProductPresentation> products;

  @override
  Future<List<PlayProductPresentation>> loadProducts(
    Set<String> productIds,
  ) async => products;
}
