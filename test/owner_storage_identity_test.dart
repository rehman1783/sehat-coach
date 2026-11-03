import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/data/local/owner_storage_identity.dart';

void main() {
  test('owner storage digest is stable, bounded and one-way presented', () {
    const owner = 'firebase-owner@example.com';
    final digest = ownerStorageDigest(owner);

    expect(digest, hasLength(64));
    expect(digest, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(digest, isNot(contains(owner)));
    expect(ownerStorageDigest(owner), digest);
    expect(ownerStorageDigest('different-owner'), isNot(digest));
  });

  test(
    'owner storage digest rejects blank identities without normalization',
    () {
      expect(() => ownerStorageDigest('   '), throwsArgumentError);
      expect(
        ownerStorageDigest('owner-a'),
        isNot(ownerStorageDigest(' owner-a ')),
        reason: 'Authenticated owner identity must remain exact.',
      );
    },
  );

  test('project scopes isolate the same authenticated owner', () {
    final production = ownerStorageDigest('owner-a', scope: 'firebase:prod');
    final staging = ownerStorageDigest('owner-a', scope: 'firebase:staging');

    expect(production, isNot(staging));
    expect(ownerStorageDigest('owner-a', scope: 'firebase:prod'), production);
    expect(
      () => ownerStorageDigest('owner-a', scope: '   '),
      throwsArgumentError,
    );
  });

  test('rejects identities outside the trusted Firebase UID boundary', () {
    expect(() => ownerStorageDigest('x' * 129), throwsArgumentError);
    expect(() => ownerStorageDigest('owner\u0000a'), throwsArgumentError);
  });

  test('rejects a scope containing the identity delimiter', () {
    expect(
      () => ownerStorageDigest('owner-a', scope: 'firebase\u0000project'),
      throwsArgumentError,
    );
  });
}
