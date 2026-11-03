import 'catalog_food.dart';
import '../../recipes/domain/catalog_recipe.dart';

class CatalogImportBundle {
  CatalogImportBundle({
    required this.release,
    required Iterable<CatalogFood> foods,
    Iterable<CatalogRecipe> recipes = const [],
  }) : foods = List.unmodifiable(foods),
       recipes = List.unmodifiable(recipes) {
    if (!release.isApproved) {
      throw ArgumentError('Only approved catalog releases may be imported');
    }
    if (this.foods.isEmpty) {
      throw ArgumentError('Catalog release must contain foods');
    }
    final foodIds = <String>{};
    for (final food in this.foods) {
      if (!canExposeAsApprovedFood(release, food)) {
        throw ArgumentError('Catalog food is not approved for this release');
      }
      if (!foodIds.add(food.id)) {
        throw ArgumentError('Catalog food IDs must be unique');
      }
    }
    final recipeIds = <String>{};
    for (final recipe in this.recipes) {
      if (recipe.releaseId != release.id ||
          recipe.provenance.reviewStatus != CatalogReviewStatus.approved ||
          recipe.provenance.reviewerId == null ||
          recipe.provenance.reviewedAt == null) {
        throw ArgumentError('Catalog recipe is not approved for this release');
      }
      if (!recipeIds.add(recipe.id)) {
        throw ArgumentError('Catalog recipe IDs must be unique');
      }
      if (recipe.ingredients.any(
        (ingredient) => !foodIds.contains(ingredient.food.id),
      )) {
        throw ArgumentError(
          'Recipe ingredients must be included in the imported release',
        );
      }
    }
  }

  final CatalogRelease release;
  final List<CatalogFood> foods;
  final List<CatalogRecipe> recipes;
}

abstract interface class CatalogImportVerificationPort {
  /// Production implementations verify package integrity and publisher trust
  /// before any nutrition record reaches the local database.
  Future<bool> verify(CatalogImportBundle bundle);
}

enum CatalogImportStatus { imported, alreadyPresent }

abstract interface class CatalogImporter {
  Future<CatalogImportStatus> importBundle(CatalogImportBundle bundle);
}

class CatalogPackageVerificationFailed implements Exception {
  const CatalogPackageVerificationFailed();
}

class ImmutableCatalogReleaseViolation implements Exception {
  const ImmutableCatalogReleaseViolation();
}

class NutritionSourceContinuityViolation implements Exception {
  const NutritionSourceContinuityViolation();
}
