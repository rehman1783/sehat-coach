import '../../features/account/domain/account_access_coordinator.dart';
import '../../features/account/domain/create_password_account_use_case.dart';
import '../../features/account/domain/email_verification_use_cases.dart';
import '../../features/account/domain/request_password_reset_use_case.dart';
import '../../features/account/domain/serialized_identity_session.dart';
import '../../features/account/domain/sign_in_use_cases.dart';
import '../../features/account/domain/suspend_account_session_use_case.dart';
import '../../features/account/domain/trusted_account_access_activation.dart';
import '../../features/account/domain/trusted_auth_state_coordinator.dart';
import '../../features/account/domain/auth_state_reconciliation_coordinator.dart';
import '../../features/account/presentation/controllers/account_access_controller.dart';

/// Composes account access around one serialized trusted-identity session.
///
/// Provider implementations are injected and may be Firebase-backed later;
/// this layer contains no credentials, project identifiers or fallback users.
class AccountAccessComposition {
  factory AccountAccessComposition({
    required SignInPort signIn,
    required PasswordAccountRegistrationPort registration,
    required PasswordResetPort passwordReset,
    required EmailVerificationPort emailVerification,
    required SerializedIdentitySession identitySession,
    required AccountRuntimePort runtime,
    required AccountSuspensionPort suspension,
    required Future<void> Function() onAuthenticated,
  }) {
    final trustedAuth = TrustedAuthStateCoordinator(
      identitySession,
      AuthStateReconciliationCoordinator(
        runtime,
        SuspendAccountSessionUseCase(suspension),
      ),
    );
    return AccountAccessComposition._(
      signIn: signIn,
      registration: registration,
      passwordReset: passwordReset,
      emailVerification: emailVerification,
      identitySession: identitySession,
      trustedAuth: trustedAuth,
      onAuthenticated: onAuthenticated,
    );
  }

  const AccountAccessComposition._({
    required this.signIn,
    required this.registration,
    required this.passwordReset,
    required this.emailVerification,
    required this.identitySession,
    required this.trustedAuth,
    required this.onAuthenticated,
  });

  final SignInPort signIn;
  final PasswordAccountRegistrationPort registration;
  final PasswordResetPort passwordReset;
  final EmailVerificationPort emailVerification;
  final SerializedIdentitySession identitySession;
  final TrustedAuthStateCoordinator trustedAuth;
  final Future<void> Function() onAuthenticated;

  AccountAccessController createController() => AccountAccessController(
    loginWithPassword: SignInWithPasswordUseCase(signIn),
    loginWithGoogle: SignInWithGoogleUseCase(signIn),
    registration: CreatePasswordAccountUseCase(registration),
    recovery: RequestPasswordResetUseCase(passwordReset),
    activation: TrustedAccountAccessActivation(trustedAuth),
    authenticatedCallback: onAuthenticated,
    requestVerification: RequestEmailVerificationUseCase(
      identitySession,
      emailVerification,
    ),
    refreshVerification: RefreshEmailVerificationUseCase(
      identitySession,
      emailVerification,
    ),
  );
}
