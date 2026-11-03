import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_admin_startup_binding.dart';

void main() {
  testWidgets('private workspace mounts only after startup succeeds', (
    tester,
  ) async {
    final gate = Completer<Widget>();
    await tester.pumpWidget(
      MaterialApp(home: TrustedAdminStartupGate(start: () => gate.future)),
    );

    expect(find.text('Verifying secure staff access…'), findsOneWidget);
    expect(find.text('PRIVATE ADMIN'), findsNothing);
    gate.complete(const Text('PRIVATE ADMIN'));
    await tester.pumpAndSettle();
    expect(find.text('PRIVATE ADMIN'), findsOneWidget);
  });

  testWidgets(
    'safe failure retries at 200 percent text without leaking error',
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
            child: TrustedAdminStartupGate(
              start: () async {
                attempts++;
                if (attempts == 1) {
                  throw StateError('private firebase configuration detail');
                }
                return const Text('AUTHORIZED WORKSPACE');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('temporarily unavailable'), findsOneWidget);
      expect(find.textContaining('private firebase'), findsNothing);
      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('AUTHORIZED WORKSPACE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
