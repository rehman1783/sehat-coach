import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/consumer_main.dart';

void main() {
  testWidgets('consumer executable withholds private root until startup', (
    tester,
  ) async {
    final startup = Completer<Widget>();
    await tester.pumpWidget(
      SehatCoachConsumerApp(startOverride: () => startup.future),
    );

    expect(find.text('Preparing your secure account…'), findsOneWidget);
    expect(find.text('PRIVATE ROOT'), findsNothing);

    startup.complete(const Text('PRIVATE ROOT'));
    await tester.pump();
    expect(find.text('PRIVATE ROOT'), findsOneWidget);
  });

  testWidgets(
    'consumer executable fails closed without leaking error details',
    (tester) async {
      await tester.pumpWidget(
        SehatCoachConsumerApp(
          startOverride: () async => throw StateError('secret project detail'),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('No health data has been opened'),
        findsOneWidget,
      );
      expect(find.textContaining('secret project detail'), findsNothing);
    },
  );
}
