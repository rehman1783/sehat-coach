import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_reauthentication_coordinator.dart';
import 'package:sehat_coach/features/account/presentation/services/material_account_reauthentication_prompts.dart';

void main() {
  testWidgets('provider chooser returns only an explicitly selected method', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: key, home: const SizedBox()),
    );
    final prompts = MaterialAccountReauthenticationPrompts(key);

    final result = prompts.chooseMethod({
      ReauthenticationMethod.password,
      ReauthenticationMethod.google,
    });
    await tester.pumpAndSettle();
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('GOOGLE'), findsOneWidget);

    await tester.tap(find.text('GOOGLE'));
    await tester.pumpAndSettle();
    expect(await result, ReauthenticationMethod.google);
  });

  testWidgets('password is masked, validated and returned only on confirm', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: key, home: const SizedBox()),
    );
    final prompts = MaterialAccountReauthenticationPrompts(key);

    final result = prompts.requestPassword();
    await tester.pumpAndSettle();
    final passwordField = tester.widget<TextField>(find.byType(TextField));
    expect(passwordField.obscureText, isTrue);
    expect(passwordField.autocorrect, isFalse);
    expect(passwordField.enableSuggestions, isFalse);
    expect(passwordField.enableIMEPersonalizedLearning, isFalse);
    expect(passwordField.smartDashesType, SmartDashesType.disabled);
    expect(passwordField.smartQuotesType, SmartQuotesType.disabled);

    await tester.tap(find.text('CONFIRM'));
    await tester.pump();
    expect(find.text('Enter your password to continue.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'temporary-secret');
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();
    expect(await result, 'temporary-secret');
  });

  testWidgets('dialogs remain usable at 320x568 and 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const SizedBox(),
      ),
    );
    final prompts = MaterialAccountReauthenticationPrompts(key);

    final result = prompts.requestPassword();
    await tester.pumpAndSettle();
    expect(find.text('CONFIRM'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
