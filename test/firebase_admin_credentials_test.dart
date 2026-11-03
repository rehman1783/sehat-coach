import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/services/firebase_admin_credentials.dart';

void main() {
  test(
    'Firebase adapters force refresh and return trimmed credentials',
    () async {
      final user = _User('  id-token  ');
      final appCheck = _AppCheck('  app-check-token  ');

      expect(
        await FirebaseAuthIdTokenAdapter(_Auth(user)).freshIdToken(),
        'id-token',
      );
      expect(
        await FirebaseAppCheckTokenAdapter(appCheck).appCheckToken(),
        'app-check-token',
      );
      expect(user.forced, isTrue);
      expect(appCheck.forced, isTrue);
    },
  );

  test('signed-out and empty Firebase credentials fail closed', () async {
    await expectLater(
      FirebaseAuthIdTokenAdapter(_Auth(null)).freshIdToken(),
      throwsA(isA<FirebaseCredentialUnavailable>()),
    );
    await expectLater(
      FirebaseAppCheckTokenAdapter(_AppCheck(' ')).appCheckToken(),
      throwsA(isA<FirebaseCredentialUnavailable>()),
    );
  });
}

class _Auth implements FirebaseAuthSdkPort {
  _Auth(this.currentUser);
  @override
  final FirebaseAuthenticatedUserPort? currentUser;
}

class _User implements FirebaseAuthenticatedUserPort {
  _User(this.token);
  final String? token;
  bool forced = false;

  @override
  Future<String?> getIdToken({required bool forceRefresh}) async {
    forced = forceRefresh;
    return token;
  }
}

class _AppCheck implements FirebaseAppCheckSdkPort {
  _AppCheck(this.token);
  final String? token;
  bool forced = false;

  @override
  Future<String?> getToken({required bool forceRefresh}) async {
    forced = forceRefresh;
    return token;
  }
}
