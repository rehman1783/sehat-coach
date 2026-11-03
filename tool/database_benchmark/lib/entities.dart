import 'package:objectbox/objectbox.dart';

@Entity()
class Food {
  @Id(assignable: true)
  int id;
  @Index()
  String name;
  int energy;
  String? source;
  Food({this.id = 0, required this.name, required this.energy});
}

@Entity()
class Meal {
  @Id(assignable: true)
  int id;
  int servings;
  final food = ToOne<Food>();
  Meal({this.id = 0, required this.servings});
}

@Entity()
class SyncProfile {
  int id;
  @Unique()
  String owner;
  int revision;
  String value;
  SyncProfile({
    this.id = 0,
    required this.owner,
    this.revision = 0,
    required this.value,
  });
}

@Entity()
class OutboxEntry {
  int id;
  @Unique()
  String operationKey;
  String owner;
  int revision;
  String value;
  OutboxEntry({
    this.id = 0,
    required this.operationKey,
    required this.owner,
    required this.revision,
    required this.value,
  });
}
