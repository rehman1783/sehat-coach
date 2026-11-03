/// A production adapter must hold a stable authenticated UID for the duration
/// of [operation], including all awaited storage or network calls.
abstract interface class AuthenticatedOwnerSession {
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation);
}
