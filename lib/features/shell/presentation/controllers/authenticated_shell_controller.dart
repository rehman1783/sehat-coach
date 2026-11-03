import 'package:get/get.dart';

enum AuthenticatedDestination { home, feed, plan, account, switchAccount }

class AuthenticatedShellController extends GetxController {
  AuthenticatedShellController({
    required Iterable<AuthenticatedDestination> availableDestinations,
  }) : availableDestinations = List.unmodifiable({
         AuthenticatedDestination.home,
         ...availableDestinations,
       }) {
    selected.value = this.availableDestinations.first;
  }

  final List<AuthenticatedDestination> availableDestinations;
  final selected = AuthenticatedDestination.home.obs;

  void select(AuthenticatedDestination destination) {
    if (!availableDestinations.contains(destination)) return;
    selected.value = destination;
  }

  int get selectedIndex => availableDestinations.indexOf(selected.value);

  void selectIndex(int index) {
    if (index < 0 || index >= availableDestinations.length) return;
    select(availableDestinations[index]);
  }
}
