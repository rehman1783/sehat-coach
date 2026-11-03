import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/account/presentation/controllers/account_access_controller.dart';
import 'package:sehat_coach/features/account/presentation/screens/account_access_destination_screen.dart';

void main() {
  testWidgets('shared controller renders each trusted access destination', (
    tester,
  ) async {
    final controller = _controller();

    await tester.pumpWidget(
      MaterialApp(
        home: AccountAccessDestinationScreen(
          controller: controller,
          destination: AccountAccessDestination.signedOut,
        ),
      ),
    );
    expect(find.text('WELCOME BACK'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: AccountAccessDestinationScreen(
          controller: controller,
          destination: AccountAccessDestination.verification,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('VERIFY YOUR EMAIL'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: AccountAccessDestinationScreen(
          controller: controller,
          destination: AccountAccessDestination.adultEligibility,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('AGE REQUIREMENT'), findsOneWidget);
  });

  testWidgets('destination transition clears stale private feedback', (
    tester,
  ) async {
    final controller = _controller();
    controller.errorMessage.value = 'Old provider detail';

    await tester.pumpWidget(
      MaterialApp(
        home: AccountAccessDestinationScreen(
          controller: controller,
          destination: AccountAccessDestination.verification,
        ),
      ),
    );

    expect(controller.errorMessage.value, isNull);
    expect(find.text('Old provider detail'), findsNothing);
  });
}

AccountAccessController _controller() => AccountAccessController(
  loginWithPassword: SignInWithPasswordUseCase(_Port()),
  loginWithGoogle: SignInWithGoogleUseCase(_Port()),
  registration: CreatePasswordAccountUseCase(_Port()),
  recovery: RequestPasswordResetUseCase(_Port()),
  activation: _Activation(),
  authenticatedCallback: () async {},
);

class _Port
    implements SignInPort, PasswordAccountRegistrationPort, PasswordResetPort {
  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<AccountIdentity> signInWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async => throw UnimplementedError();

  @override
  Future<void> requestPasswordReset(String emailAddress) async {}
}

class _Activation implements AccountActivationPort {
  @override
  Future<AccountActivationResult> activate(SignInResult result) async =>
      throw UnimplementedError();
}
