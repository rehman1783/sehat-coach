import 'email_address.dart';

enum PasswordResetRequestStatus { accepted }

abstract interface class PasswordResetPort {
  /// Must return the same successful shape whether or not the address exists.
  Future<void> requestPasswordReset(String emailAddress);
}

class RequestPasswordResetUseCase {
  const RequestPasswordResetUseCase(this._port);

  final PasswordResetPort _port;

  Future<PasswordResetRequestStatus> execute(String emailAddress) async {
    final email = EmailAddress.parse(emailAddress);
    await _port.requestPasswordReset(email.value);
    return PasswordResetRequestStatus.accepted;
  }
}
