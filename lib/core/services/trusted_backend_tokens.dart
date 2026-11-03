abstract interface class FirebaseIdTokenProvider {
  Future<String> freshIdToken();
}

abstract interface class FirebaseAppCheckTokenProvider {
  Future<String> appCheckToken();
}
