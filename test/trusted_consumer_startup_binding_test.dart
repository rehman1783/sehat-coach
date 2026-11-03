import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/trusted_consumer_startup_binding.dart';

void main() {
  test(
    'validates services before resolving private storage and caches root',
    () async {
      final events = <String>[];
      final directory = Directory.systemTemp;
      final binding = TrustedConsumerStartupBinding<String>(
        startServices: () async {
          events.add('services');
          return 'trusted';
        },
        resolveApplicationDataDirectory: () async {
          events.add('directory');
          return directory;
        },
        buildRoot: (resolved, services) {
          events.add('root:${resolved.path}:$services');
          return const Text('PRIVATE');
        },
      );

      final roots = await Future.wait([binding.start(), binding.start()]);

      expect(identical(roots.first, roots.last), isTrue);
      expect(events, [
        'services',
        'directory',
        'root:${directory.path}:trusted',
      ]);
      expect(identical(await binding.start(), roots.first), isTrue);
    },
  );

  test(
    'failed startup opens no directory and permits explicit retry',
    () async {
      var attempts = 0;
      var directoryCalls = 0;
      final binding = TrustedConsumerStartupBinding<String>(
        startServices: () async {
          attempts++;
          if (attempts == 1) throw StateError('configuration detail');
          return 'trusted';
        },
        resolveApplicationDataDirectory: () async {
          directoryCalls++;
          return Directory.systemTemp;
        },
        buildRoot: (_, _) => const Text('PRIVATE'),
      );

      await expectLater(binding.start(), throwsStateError);
      expect(directoryCalls, 0);
      expect(await binding.start(), isA<Text>());
      expect(attempts, 2);
      expect(directoryCalls, 1);
    },
  );

  testWidgets('gate withholds private UI then mounts successful root', (
    tester,
  ) async {
    final startup = Completer<Widget>();
    await tester.pumpWidget(
      MaterialApp(
        home: TrustedConsumerStartupGate(start: () => startup.future),
      ),
    );

    expect(find.text('Preparing your secure account…'), findsOneWidget);
    expect(find.text('PRIVATE'), findsNothing);

    startup.complete(const Text('PRIVATE'));
    await tester.pump();
    expect(find.text('PRIVATE'), findsOneWidget);
  });

  testWidgets('failure is private, responsive, and retryable', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var attempts = 0;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: TrustedConsumerStartupGate(
          start: () async {
            attempts++;
            if (attempts == 1) throw StateError('secret configuration detail');
            return const Text('PRIVATE');
          },
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('No health data has been opened'),
      findsOneWidget,
    );
    expect(find.textContaining('secret configuration'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('TRY AGAIN'));
    await tester.pump();
    expect(find.text('PRIVATE'), findsOneWidget);
  });
}
