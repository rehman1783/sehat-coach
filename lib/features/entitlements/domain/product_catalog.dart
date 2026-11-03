enum EntitlementProductKind { subscription, consumableCredits }

class EntitlementProductDefinition {
  EntitlementProductDefinition({
    required this.id,
    required this.playProductId,
    required this.kind,
    required this.title,
    required this.description,
    required List<String> benefitLabels,
    required Set<String> featureIds,
    required this.displayOrder,
    this.creditAmount,
  }) : benefitLabels = List.unmodifiable(benefitLabels),
       featureIds = Set.unmodifiable(featureIds) {
    if (id.trim().isEmpty ||
        playProductId.trim().isEmpty ||
        title.trim().isEmpty ||
        description.trim().isEmpty ||
        displayOrder < 0 ||
        benefitLabels.any((item) => item.trim().isEmpty) ||
        featureIds.any((item) => item.trim().isEmpty) ||
        (kind == EntitlementProductKind.consumableCredits &&
            (creditAmount == null || creditAmount! < 1)) ||
        (kind == EntitlementProductKind.subscription && creditAmount != null)) {
      throw ArgumentError('Remote product definition is invalid.');
    }
  }

  final String id;
  final String playProductId;
  final EntitlementProductKind kind;
  final String title;
  final String description;
  final List<String> benefitLabels;
  final Set<String> featureIds;
  final int displayOrder;
  final int? creditAmount;
}

class EntitlementProductCatalog {
  EntitlementProductCatalog({
    required this.revision,
    required this.publishedAtUtc,
    required List<EntitlementProductDefinition> products,
  }) : products = List.unmodifiable(products) {
    if (revision < 1 ||
        !publishedAtUtc.isUtc ||
        this.products.map((item) => item.id).toSet().length !=
            this.products.length ||
        this.products.map((item) => item.playProductId).toSet().length !=
            this.products.length) {
      throw ArgumentError('Remote product catalog is invalid.');
    }
  }

  final int revision;
  final DateTime publishedAtUtc;
  final List<EntitlementProductDefinition> products;
}

class PlayProductPresentation {
  PlayProductPresentation({
    required this.playProductId,
    required this.localizedPrice,
    required this.currencyCode,
  }) {
    if (playProductId.trim().isEmpty ||
        localizedPrice.trim().isEmpty ||
        currencyCode.trim().isEmpty) {
      throw ArgumentError('Play product presentation is incomplete.');
    }
  }

  final String playProductId;
  final String localizedPrice;
  final String currencyCode;
}

class PaywallProduct {
  const PaywallProduct({
    required this.definition,
    required this.playPresentation,
  });

  final EntitlementProductDefinition definition;
  final PlayProductPresentation? playPresentation;

  bool get isPurchasable => playPresentation != null;
}

abstract interface class EntitlementProductCatalogGateway {
  Future<EntitlementProductCatalog> loadActiveCatalog();
}

abstract interface class PlayProductCatalogGateway {
  Future<List<PlayProductPresentation>> loadProducts(Set<String> productIds);
}

class LoadPaywallProducts {
  const LoadPaywallProducts({
    required this.configuration,
    required this.playCatalog,
  });

  final EntitlementProductCatalogGateway configuration;
  final PlayProductCatalogGateway playCatalog;

  Future<List<PaywallProduct>> execute() async {
    final catalog = await configuration.loadActiveCatalog();
    final playProducts = await playCatalog.loadProducts(
      catalog.products.map((item) => item.playProductId).toSet(),
    );
    final byId = <String, PlayProductPresentation>{};
    for (final product in playProducts) {
      if (!catalog.products.any(
        (item) => item.playProductId == product.playProductId,
      )) {
        continue;
      }
      if (byId.containsKey(product.playProductId)) {
        throw StateError('Google Play returned a duplicate product.');
      }
      byId[product.playProductId] = product;
    }
    final products =
        catalog.products
            .map(
              (definition) => PaywallProduct(
                definition: definition,
                playPresentation: byId[definition.playProductId],
              ),
            )
            .toList(growable: false)
          ..sort(
            (left, right) => left.definition.displayOrder.compareTo(
              right.definition.displayOrder,
            ),
          );
    return List.unmodifiable(products);
  }
}
