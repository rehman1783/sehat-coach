import 'bachat_planner.dart';

abstract interface class BachatRepository {
  Future<List<BachatFoodCandidate>> loadCandidatesForCity(String cityId);
}
