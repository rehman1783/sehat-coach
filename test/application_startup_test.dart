import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/application_startup.dart';
import 'package:sehat_coach/core/config/app_config.dart';

void main() {
  testWidgets('development keeps explicit preview startup', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationStartup(
          config: _config(AppEnvironment.development),
          preview: const Text('PREVIEW'),
        ),
      ),
    );

    expect(find.text('PREVIEW'), findsOneWidget);
    expect(find.byType(TrustedRuntimeUnavailableScreen), findsNothing);
  });

  testWidgets('production never falls back to preview without trusted root', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationStartup(
          config: _config(AppEnvironment.production),
          preview: const Text('PREVIEW'),
        ),
      ),
    );

    expect(find.text('PREVIEW'), findsNothing);
    expect(find.byType(TrustedRuntimeUnavailableScreen), findsOneWidget);
    expect(
      find.textContaining('No health data has been opened'),
      findsOneWidget,
    );
  });

  testWidgets('production mounts injected trusted application root', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationStartup(
          config: _config(AppEnvironment.production),
          preview: const Text('PREVIEW'),
          trustedRoot: const Text('TRUSTED ROOT'),
        ),
      ),
    );

    expect(find.text('TRUSTED ROOT'), findsOneWidget);
    expect(find.text('PREVIEW'), findsNothing);
  });

  testWidgets('development trusted-runtime flag also fails closed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicationStartup(
          config: _config(
            AppEnvironment.development,
            enableTrustedRuntime: true,
          ),
          preview: const Text('PREVIEW'),
        ),
      ),
    );

    expect(find.text('PREVIEW'), findsNothing);
    expect(find.byType(TrustedRuntimeUnavailableScreen), findsOneWidget);
  });
}

AppConfig _config(
  AppEnvironment environment, {
  bool enableTrustedRuntime = false,
}) => AppConfig(
  environment: environment,
  enableDevicePreview: false,
  enableTrustedAccountRuntime: enableTrustedRuntime,
);
