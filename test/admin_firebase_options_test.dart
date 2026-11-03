import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/config/admin_firebase_options.dart';

void main() {
  test('builds trimmed Firebase options from explicit non-secret values', () {
    final options = AdminFirebaseOptions.fromValues(
      apiKey: ' api-key ',
      appId: ' app-id ',
      messagingSenderId: ' sender-id ',
      projectId: ' project-id ',
      authDomain: ' project.firebaseapp.com ',
    );

    expect(options.apiKey, 'api-key');
    expect(options.appId, 'app-id');
    expect(options.messagingSenderId, 'sender-id');
    expect(options.projectId, 'project-id');
    expect(options.authDomain, 'project.firebaseapp.com');
    expect(options.storageBucket, isNull);
  });

  test('missing required Firebase values fail before SDK initialization', () {
    expect(
      () => AdminFirebaseOptions.fromValues(
        apiKey: '',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('unsafe or malformed Firebase values fail before startup', () {
    expect(
      () => AdminFirebaseOptions.fromValues(
        apiKey: 'api key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
      throwsStateError,
    );
    for (final projectId in [
      'UPPERCASE-project',
      '-leading-hyphen',
      'trailing-hyphen-',
      'short',
      'project\u0000id',
      'a123456789012345678901234567890',
    ]) {
      expect(
        () => validateFirebaseProjectId(projectId),
        throwsStateError,
        reason: projectId,
      );
    }
  });
}
