import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_commands.dart';
import 'package:sehat_coach/features/custom_foods/domain/user_food_records.dart';
import 'package:sehat_coach/features/custom_foods/presentation/controllers/user_food_entry_controller.dart';

void main() {
  test('creates an owner-scoped unreviewed custom food', () async {
    final repository = _RepositoryFake();
    final controller = _controller(repository);
    final result = await controller.create(
      name: ' Home roll ',
      servingLabel: '1 roll',
      unitCode: 'roll',
      calories: '350',
      protein: '22',
      carbohydrates: '35',
      fat: '14',
      grams: '180',
    );

    expect(result?.ownerId, 'owner-a');
    expect(result?.name, 'Home roll');
    expect(result?.gramsPerServing, 180);
    expect(repository.customFoods.single, same(result));
    expect(controller.errorMessage.value, isNull);
  });

  test('invalid nutrition stays in form state and does not save', () async {
    final repository = _RepositoryFake();
    final controller = _controller(repository);
    final result = await controller.create(
      name: 'Home roll',
      servingLabel: '1 roll',
      unitCode: 'roll',
      calories: '-1',
      protein: 'x',
      carbohydrates: '35',
      fat: '14',
    );

    expect(result, isNull);
    expect(repository.customFoods, isEmpty);
    expect(controller.errorMessage.value, contains('valid non-negative'));
  });

  test('saves unresolved food name and optional context', () async {
    final repository = _RepositoryFake();
    final controller = _controller(repository);
    final result = await controller.saveMissing(
      searchText: ' Anda paratha special ',
      details: ' Local dhaba ',
    );

    expect(result?.status, FoodNotFoundStatus.pending);
    expect(result?.searchText, 'Anda paratha special');
    expect(result?.details, 'Local dhaba');
    expect(repository.notes.single, same(result));
  });
}

UserFoodEntryController _controller(_RepositoryFake repository) =>
    UserFoodEntryController(
      createCustomFood: CreateCustomFoodUseCase(
        session: _SessionFake(),
        repository: repository,
        ids: _IdsFake(),
        clock: _ClockFake(),
      ),
      saveNotFound: SaveFoodNotFoundUseCase(
        session: _SessionFake(),
        repository: repository,
        ids: _IdsFake(),
        clock: _ClockFake(),
      ),
    );

class _RepositoryFake implements UserFoodRecordRepository {
  final customFoods = <CustomFoodRecord>[];
  final notes = <FoodNotFoundRecord>[];

  @override
  Future<void> saveCustomFood(CustomFoodRecord record) async =>
      customFoods.add(record);

  @override
  Future<void> saveNotFound(FoodNotFoundRecord record) async =>
      notes.add(record);

  @override
  Future<List<CustomFoodRecord>> searchCustomFoods(String query) async => [];

  @override
  Future<List<FoodNotFoundRecord>> pendingNotFound() async => notes;
}

class _SessionFake implements AuthenticatedOwnerSession {
  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation('owner-a');
}

class _IdsFake implements UserFoodIdGenerator {
  @override
  String nextCustomFoodId() => 'custom-1';

  @override
  String nextNotFoundId() => 'note-1';
}

class _ClockFake implements UserFoodClock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 10, 22, 12);
}
