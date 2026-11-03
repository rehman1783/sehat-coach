import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/data/decrypted_account_memory_registry.dart';

void main() {
  test(
    'clears only the selected owner and removes registrations first',
    () async {
      final registry = DecryptedAccountMemoryRegistry();
      final events = <String>[];
      registry.register('owner-a', () {
        expect(registry.countFor('owner-a'), 0);
        events.add('a');
      });
      registry.register('owner-b', () => events.add('b'));

      await registry.clear('owner-a');

      expect(events, ['a']);
      expect(registry.countFor('owner-a'), 0);
      expect(registry.countFor('owner-b'), 1);
    },
  );

  test('attempts every disposer and remains cleared when one fails', () async {
    final registry = DecryptedAccountMemoryRegistry();
    final events = <String>[];
    registry.register('owner-a', () {
      events.add('first');
      throw StateError('cleanup failed');
    });
    registry.register('owner-a', () async => events.add('second'));

    await expectLater(registry.clear('owner-a'), throwsStateError);

    expect(events, ['first', 'second']);
    expect(registry.countFor('owner-a'), 0);
    await registry.clear('owner-a');
  });

  test('unregister is idempotent and prevents later disposal', () async {
    final registry = DecryptedAccountMemoryRegistry();
    var calls = 0;
    final unregister = registry.register('owner-a', () => calls++);

    unregister();
    unregister();
    await registry.clear('owner-a');

    expect(calls, 0);
  });

  test('rejects empty owner identifiers', () async {
    final registry = DecryptedAccountMemoryRegistry();
    expect(() => registry.register('  ', () {}), throwsArgumentError);
    expect(() => registry.countFor(''), throwsArgumentError);
    await expectLater(registry.clear(' '), throwsArgumentError);
  });
}
