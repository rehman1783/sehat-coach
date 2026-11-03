import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/services/privacy_safe_diagnostics.dart';

void main() {
  group('PrivacySafeDiagnostics', () {
    test('emits only the namespaced event identifier when enabled', () {
      final messages = <String>[];
      final diagnostics = PrivacySafeDiagnostics(
        enabled: true,
        sink: messages.add,
      );

      diagnostics.event('geo.tier1.failed');

      expect(messages, <String>['sehat_coach:geo.tier1.failed']);
    });

    test('does not emit in disabled production-style mode', () {
      final messages = <String>[];
      final diagnostics = PrivacySafeDiagnostics(
        enabled: false,
        sink: messages.add,
      );

      diagnostics.event('geo.tier2.failed');

      expect(messages, isEmpty);
    });

    test('rejects arbitrary text that could contain sensitive payloads', () {
      final diagnostics = PrivacySafeDiagnostics(enabled: true, sink: (_) {});

      expect(
        () => diagnostics.event('user email: person@example.com'),
        throwsArgumentError,
      );
      expect(() => diagnostics.event('token=secret'), throwsArgumentError);
    });
  });
}
