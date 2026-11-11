import 'package:get/get.dart';

import '../../domain/account_access_coordinator.dart';
import '../../domain/account_identity.dart';
import '../../domain/authentication_failures.dart';
import '../../domain/confirm_adult_eligibility_use_case.dart';
import '../../domain/create_password_account_use_case.dart';
import '../../domain/email_verification_use_cases.dart';
import '../../domain/request_password_reset_use_case.dart';
import '../../domain/sign_in_use_cases.dart';

enum AccountAccessMode { signIn, createAccount, verifyEmail, ineligible }

class AccountAccessController extends GetxController {
  AccountAccessController({
    required SignInWithPasswordUseCase loginWithPassword,
    required SignInWithGoogleUseCase loginWithGoogle,
    required CreatePasswordAccountUseCase registration,
    required RequestPasswordResetUseCase recovery,
    required AccountActivationPort activation,
    required Future<void> Function() authenticatedCallback,
    this.requestVerification,
    this.refreshVerification,
    this.confirmAdultEligibility,
    this.signOutPending,
  }) : _passwordSignIn = loginWithPassword,
       _googleSignIn = loginWithGoogle,
       _createAccount = registration,
       _passwordReset = recovery,
       _accessCoordinator = activation,
       _onAuthenticated = authenticatedCallback;

  final SignInWithPasswordUseCase _passwordSignIn;
  final SignInWithGoogleUseCase _googleSignIn;
  final CreatePasswordAccountUseCase _createAccount;
  final RequestPasswordResetUseCase _passwordReset;
  final AccountActivationPort _accessCoordinator;
  final Future<void> Function() _onAuthenticated;
  final RequestEmailVerificationUseCase? requestVerification;
  final RefreshEmailVerificationUseCase? refreshVerification;
  final ConfirmAdultEligibilityUseCase? confirmAdultEligibility;
  final Future<void> Function()? signOutPending;

  final mode = AccountAccessMode.signIn.obs;
  final emailAddress = ''.obs;
  final password = ''.obs;
  final declaredAge = 18.obs;
  final adultConfirmed = false.obs;
  final obscurePassword = true.obs;
  final canConfirmAdultEligibility = false.obs;
  final isBusy = false.obs;
  final message = RxnString();
  final errorMessage = RxnString();

  void showSignIn() {
    password.value = '';
    obscurePassword.value = true;
    canConfirmAdultEligibility.value = false;
    mode.value = AccountAccessMode.signIn;
    _clearFeedback();
  }

  void showCreateAccount() {
    password.value = '';
    obscurePassword.value = true;
    canConfirmAdultEligibility.value = false;
    if (declaredAge.value <= 0) declaredAge.value = 18;
    mode.value = AccountAccessMode.createAccount;
    _clearFeedback();
  }

  void showVerificationRequired() {
    canConfirmAdultEligibility.value = false;
    mode.value = AccountAccessMode.verifyEmail;
    _clearFeedback();
  }

  void showAdultEligibilityRequired() {
    if (declaredAge.value <= 0) declaredAge.value = 18;
    canConfirmAdultEligibility.value = confirmAdultEligibility != null;
    mode.value = AccountAccessMode.ineligible;
    _clearFeedback();
  }

  Future<void> submitPassword() async {
    if (isBusy.value) return;
    try {
      await _run(() async {
        if (mode.value == AccountAccessMode.createAccount) {
          final identity = await _createAccount.execute(
            emailAddress: emailAddress.value,
            password: password.value,
            declaredAge: declaredAge.value,
            adultConfirmed: adultConfirmed.value,
          );
          await _accessCoordinator.activate(
            SignInResult(identity, accountAccessStatusFor(identity)),
          );
          mode.value = AccountAccessMode.verifyEmail;
          message.value =
              'Account created. Verify your email before continuing.';
          await _sendVerificationIfAvailable();
          return;
        }
        await _handleSignIn(
          await _passwordSignIn.execute(
            emailAddress: emailAddress.value,
            password: password.value,
          ),
        );
      });
    } finally {
      password.value = '';
      obscurePassword.value = true;
    }
  }

  Future<void> submitGoogle() async {
    if (isBusy.value) return;
    await _run(() async => _handleSignIn(await _googleSignIn.execute()));
  }

  Future<void> submitAdultEligibility() async {
    final confirm = confirmAdultEligibility;
    if (isBusy.value || confirm == null) return;
    await _run(() async {
      final identity = await confirm.execute(
        declaredAge: declaredAge.value,
        adultConfirmed: adultConfirmed.value,
      );
      await _handleSignIn(
        SignInResult(identity, accountAccessStatusFor(identity)),
      );
    });
  }

  Future<void> leavePendingAccount() async {
    if (isBusy.value) return;
    final signOut = signOutPending;
    if (signOut == null) {
      showSignIn();
      return;
    }
    await _run(() async {
      await signOut();
      showSignIn();
    });
  }

  Future<void> requestPasswordReset() async {
    if (isBusy.value) return;
    await _run(() async {
      await _passwordReset.execute(emailAddress.value);
      message.value = 'If an account can receive recovery email, instructions have been sent.';
    });
  }

  Future<void> resendVerification() async {
    if (isBusy.value || requestVerification == null) return;
    await _run(() async {
      final status = await requestVerification!.execute();
      message.value = switch (status) {
        RequestEmailVerificationStatus.sent => 'Verification email sent.',
        RequestEmailVerificationStatus.throttled =>
          'Please wait before requesting another email.',
        RequestEmailVerificationStatus.alreadyVerified =>
          'Your email is already verified.',
      };
    });
  }

  Future<void> checkVerification() async {
    if (isBusy.value || refreshVerification == null) return;
    await _run(() async {
      final status = await refreshVerification!.execute();
      if (status == RefreshEmailVerificationStatus.stillPending) {
        message.value = 'Email verification is still pending.';
        return;
      }
      message.value = 'Email verified. Sign in to continue securely.';
      mode.value = AccountAccessMode.signIn;
    });
  }

  Future<void> _handleSignIn(SignInResult result) async {
    final activation = await _accessCoordinator.activate(result);
    switch (activation.accessStatus) {
      case AccountAccessStatus.ready:
        if (!activation.activated) {
          throw StateError('Account storage could not be activated');
        }
        await _onAuthenticated();
      case AccountAccessStatus.emailVerificationRequired:
        mode.value = AccountAccessMode.verifyEmail;
        message.value = 'Verify your email before continuing.';
      case AccountAccessStatus.adultEligibilityRequired:
        canConfirmAdultEligibility.value = confirmAdultEligibility != null;
        mode.value = AccountAccessMode.ineligible;
        message.value = canConfirmAdultEligibility.value
            ? 'Confirm that you are 18 or older to complete account setup.'
            : 'Sehat Coach V1 is available only to adults aged 18 or older.';
    }
  }

  Future<void> _sendVerificationIfAvailable() async {
    if (requestVerification == null) return;
    final status = await requestVerification!.execute();
    if (status == RequestEmailVerificationStatus.throttled) {
      message.value = 'Account created. Please wait before requesting another verification email.';
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    isBusy.value = true;
    _clearFeedback();
    try {
      await operation();
    } on AuthenticationFailure catch (error) {
      errorMessage.value = _safeFailureMessage(error.code);
    } on AdultEligibilityRequired {
      canConfirmAdultEligibility.value = false;
      mode.value = AccountAccessMode.ineligible;
      errorMessage.value = 'You must be 18 or older to create an account.';
    } on AccountDataRecoveryRequired {
      errorMessage.value =
          'Local health data could not be opened safely. It has not been deleted. '
          'Please retry or contact support before clearing local data.';
    } on FormatException {
      errorMessage.value = 'Enter a valid email address.';
    } on ArgumentError {
      errorMessage.value = 'Check the email, password and age information.';
    } on Object {
      errorMessage.value = 'Account access is unavailable. Please try again.';
    } finally {
      isBusy.value = false;
    }
  }

  void _clearFeedback() {
    message.value = null;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    password.value = '';
    super.onClose();
  }
}

String _safeFailureMessage(AuthenticationFailureCode code) => switch (code) {
  AuthenticationFailureCode.invalidCredentials =>
    'The email or password could not be verified.',
  AuthenticationFailureCode.rateLimited =>
    'Too many attempts. Please wait and try again.',
  AuthenticationFailureCode.networkUnavailable =>
    'Check your connection and try again.',
  AuthenticationFailureCode.emailVerificationRequired =>
    'Verify your email before continuing.',
  AuthenticationFailureCode.recentAuthenticationRequired =>
    'Please sign in again before this action.',
  AuthenticationFailureCode.providerUnavailable =>
    'This sign-in method is temporarily unavailable.',
  AuthenticationFailureCode.cancelled => 'Sign-in was cancelled.',
  AuthenticationFailureCode.unknown =>
    'Account access is unavailable. Please try again.',
};
