import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/config/app_config.dart';
import 'package:sehat_coach/core/theme/app_layout.dart';
import 'package:sehat_coach/core/widgets/responsive_content.dart';

void main() {
  test('development configuration is the safe default', () {
    final config = AppConfig.fromEnvironment();

    expect(config.environment, AppEnvironment.development);
    expect(config.enableDevicePreview, isFalse);
    expect(config.aiBackendEndpoint, isNull);
  });

  test('environment parsing rejects misspelled or padded values', () {
    expect(parseAppEnvironment(''), AppEnvironment.development);
    expect(parseAppEnvironment('development'), AppEnvironment.development);
    expect(parseAppEnvironment('staging'), AppEnvironment.staging);
    expect(parseAppEnvironment('production'), AppEnvironment.production);
    expect(() => parseAppEnvironment('prodution'), throwsStateError);
    expect(() => parseAppEnvironment(' production '), throwsStateError);
  });

  test('trusted backend parsing rejects unsafe endpoint structure', () {
    expect(parseOptionalTrustedEndpoint('   '), isNull);
    expect(
      parseOptionalTrustedEndpoint(' https://api.example.test/v1 '),
      Uri.https('api.example.test', '/v1'),
    );
    for (final value in [
      'http://api.example.test/v1',
      'https://user:pass@api.example.test/v1',
      'https://api.example.test:0/v1',
      'https://api.example.test/v1?owner=a',
      'https://api.example.test/v1#fragment',
    ]) {
      expect(
        () => parseOptionalTrustedEndpoint(value),
        throwsStateError,
        reason: value,
      );
    }
    expect(
      () => parseOptionalTrustedEndpoint(
        'https://api.example.test/${'x' * 2048}',
      ),
      throwsStateError,
    );
  });

  testWidgets('responsive content constrains wide layouts', (tester) async {
    const contentKey = Key('responsive-child');
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            child: SizedBox(key: contentKey, width: double.infinity),
          ),
        ),
      ),
    );

    final contentSize = tester.getSize(find.byKey(contentKey));
    expect(
      contentSize.width,
      lessThanOrEqualTo(AppBreakpoints.maxContentWidth),
    );
    expect(contentSize.width, greaterThan(0));
  });
}
