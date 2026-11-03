import '../../account/domain/authenticated_owner_session.dart';
import 'user_food_records.dart';

abstract interface class UserFoodIdGenerator {
  String nextCustomFoodId();
  String nextNotFoundId();
}

abstract interface class UserFoodClock {
  DateTime nowUtc();
}

class CreateCustomFoodCommand {
  const CreateCustomFoodCommand({
    required this.name,
    required this.servingLabel,
    required this.unitCode,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.gramsPerServing,
    this.sodiumMilligrams,
  });

  final String name;
  final String servingLabel;
  final String unitCode;
  final double? gramsPerServing;
  final double caloriesKcal;
  final double proteinGrams;
  final double carbohydrateGrams;
  final double fatGrams;
  final double? sodiumMilligrams;
}

class CreateCustomFoodUseCase {
  const CreateCustomFoodUseCase({
    required this.session,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final UserFoodRecordRepository repository;
  final UserFoodIdGenerator ids;
  final UserFoodClock clock;

  Future<CustomFoodRecord> execute(CreateCustomFoodCommand command) =>
      session.withOwner((ownerId) async {
        final now = clock.nowUtc();
        final record = CustomFoodRecord(
          id: ids.nextCustomFoodId(),
          ownerId: ownerId,
          name: command.name.trim(),
          servingLabel: command.servingLabel.trim(),
          unitCode: command.unitCode.trim(),
          gramsPerServing: command.gramsPerServing,
          caloriesKcal: command.caloriesKcal,
          proteinGrams: command.proteinGrams,
          carbohydrateGrams: command.carbohydrateGrams,
          fatGrams: command.fatGrams,
          sodiumMilligrams: command.sodiumMilligrams,
          revision: 1,
          createdAtUtc: now,
          updatedAtUtc: now,
        );
        await repository.saveCustomFood(record);
        return record;
      });
}

class SaveFoodNotFoundUseCase {
  const SaveFoodNotFoundUseCase({
    required this.session,
    required this.repository,
    required this.ids,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final UserFoodRecordRepository repository;
  final UserFoodIdGenerator ids;
  final UserFoodClock clock;

  Future<FoodNotFoundRecord> execute({
    required String searchText,
    String details = '',
  }) => session.withOwner((ownerId) async {
    final now = clock.nowUtc();
    final record = FoodNotFoundRecord(
      id: ids.nextNotFoundId(),
      ownerId: ownerId,
      searchText: searchText.trim(),
      details: details.trim(),
      status: FoodNotFoundStatus.pending,
      revision: 1,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    await repository.saveNotFound(record);
    return record;
  });
}
