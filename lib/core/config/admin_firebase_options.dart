import 'package:firebase_core/firebase_core.dart';

class AdminFirebaseOptions {
  const AdminFirebaseOptions._();

  static FirebaseOptions fromEnvironment() => fromValues(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    ),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
    iosBundleId: const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  );

  static FirebaseOptions fromValues({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    String authDomain = '',
    String storageBucket = '',
    String measurementId = '',
    String iosBundleId = '',
  }) {
    final normalizedApiKey = _requiredValue(apiKey, 'FIREBASE_API_KEY');
    final normalizedAppId = _requiredValue(appId, 'FIREBASE_APP_ID');
    final normalizedSenderId = _requiredValue(
      messagingSenderId,
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    final normalizedProjectId = validateFirebaseProjectId(projectId);
    return FirebaseOptions(
      apiKey: normalizedApiKey,
      appId: normalizedAppId,
      messagingSenderId: normalizedSenderId,
      projectId: normalizedProjectId,
      authDomain: _optional(authDomain, 'FIREBASE_AUTH_DOMAIN'),
      storageBucket: _optional(storageBucket, 'FIREBASE_STORAGE_BUCKET'),
      measurementId: _optional(measurementId, 'FIREBASE_MEASUREMENT_ID'),
      iosBundleId: _optional(iosBundleId, 'FIREBASE_IOS_BUNDLE_ID'),
    );
  }

  static String? _optional(String value, String name) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return _validatedValue(normalized, name);
  }
}

final _firebaseProjectIdPattern = RegExp(r'^[a-z][a-z0-9-]{4,28}[a-z0-9]$');

String validateFirebaseProjectId(String raw) {
  final value = _requiredValue(raw, 'FIREBASE_PROJECT_ID');
  if (!_firebaseProjectIdPattern.hasMatch(value)) {
    throw StateError('FIREBASE_PROJECT_ID is invalid.');
  }
  return value;
}

String _requiredValue(String raw, String name) {
  final value = raw.trim();
  if (value.isEmpty) throw StateError('$name is required.');
  return _validatedValue(value, name);
}

String _validatedValue(String value, String name) {
  if (value.length > 512 || value.contains(RegExp(r'\s|[\x00-\x1F\x7F]'))) {
    throw StateError('$name is invalid.');
  }
  return value;
}
