import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/shell/presentation/controllers/authenticated_shell_controller.dart';
import 'package:sehat_coach/features/shell/presentation/screens/authenticated_shell_screen.dart';

void main() {
  test(
    'home always exists and unavailable destinations cannot be selected',
    () {
      final controller = AuthenticatedShellController(
        availableDestinations: const [
          AuthenticatedDestination.feed,
          AuthenticatedDestination.plan,
        ],
      );

      expect(controller.availableDestinations, [
        AuthenticatedDestination.home,
        AuthenticatedDestination.feed,
        AuthenticatedDestination.plan,
      ]);
      controller.select(AuthenticatedDestination.account);
      expect(controller.selected.value, AuthenticatedDestination.home);
      controller.selectIndex(1);
      expect(controller.selected.value, AuthenticatedDestination.feed);
      controller.selectIndex(2);
      expect(controller.selected.value, AuthenticatedDestination.plan);
    },
  );

  testWidgets('shell hides navigation when no authenticated factory exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthenticatedShellScreen(
          home: Scaffold(body: Text('Personalized home')),
        ),
      ),
    );

    expect(find.text('Personalized home'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Feed'), findsNothing);
  });

  testWidgets(
    'five-destination shell stays usable at 200 percent text and retries safely',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var attempts = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
            ),
            child: AuthenticatedShellScreen(
              home: const Scaffold(body: Text('Personalized home')),
              createFeed: () async {
                attempts++;
                throw StateError('private adapter detail');
              },
              createEntitlements: () => Future.error(StateError('not invoked')),
              createAccountSafety: () =>
                  Future.error(StateError('not invoked')),
              createAccountSwitch: () =>
                  Future.error(StateError('not invoked')),
            ),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior,
        NavigationDestinationLabelBehavior.alwaysHide,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.dynamic_feed_outlined));
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(
        find.text('The reviewed feed is unavailable right now.'),
        findsOneWidget,
      );
      expect(find.textContaining('private adapter detail'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
