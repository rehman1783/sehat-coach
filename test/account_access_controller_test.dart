import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/theme/app_theme.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/sign_in_use_cases.dart';
import 'package:sehat_coach/features/account/presentation/controllers/account_access_controller.dart';
import 'package:sehat_coach/features/account/presentation/screens/account_access_screen.dart';

void main() {
  test('ready password sign-in activates runtime and continues', () async {
    final runtime = _Runtime();
    var ready = false;
    final controller = _controller(runtime, onReady: () async => ready = true);
    controller.emailAddress.value = 'person@example.com';
    controller.password.value = 'secret';
    await controller.submitPassword();

    expect(runtime.activeOwnerId, 'owner-a');
    expect(ready, isTrue);
    expect(controller.password.value, isEmpty);
  });

  test(
    'unverified account routes to verification without opening data',
    () async {
      final runtime = _Runtime();
      final controller = _controller(runtime, verified: false);
      controller.emailAddress.value = 'person@example.com';
      controller.password.value = 'secret';
      await controller.submitPassword();

      expect(controller.mode.value, AccountAccessMode.verifyEmail);
      expect(runtime.activeOwnerId, isNull);
    },
  );

  test(
    'under-18 registration remains ineligible and performs no write',
    () async {
      final registration = _AuthPort();
      final controller = _controller(_Runtime(), port: registration);
      controller.showCreateAccount();
      controller.emailAddress.value = 'person@example.com';
      controller.password.value = 'secret';
      controller.declaredAge.value = 17;
      controller.adultConfirmed.value = true;
      await controller.submitPassword();

      expect(controller.mode.value, AccountAccessMode.ineligible);
      expect(registration.registrationCalls, 0);
      expect(controller.password.value, isEmpty);
      expect(controller.obscurePassword.value, isTrue);
    },
  );

  test('recovery response does not disclose account existence', () async {
    final controller = _controller(_Runtime());
    controller.emailAddress.value = 'person@example.com';
    await controller.requestPasswordReset();

    expect(controller.message.value, contains('If an account'));
  });

  test(
    'preserved local-data failure gives non-destructive recovery guidance',
    () async {
      final controller = _controller(
        _Runtime(failure: const AccountDataRecoveryRequired()),
      );
      controller.emailAddress.value = 'person@example.com';
      controller.password.value = 'temporary-secret';

      await controller.submitPassword();

      expect(controller.errorMessage.value, contains('has not been deleted'));
      expect(
        controller.errorMessage.value,
        contains('before clearing local data'),
      );
      expect(controller.password.value, isEmpty);
    },
  );

  testWidgets('account creation remains usable at 200 percent text', (
    tester,
  ) async {
    final controller = _controller(_Runtime())..showCreateAccount();
    await _pumpAccountScreen(tester, controller);

    for (final label in [
      'Email address',
      'Password',
      'Age',
      'I confirm that I am 18 or older',
      'CREATE ACCOUNT',
      'CONTINUE WITH GOOGLE',
      'Already have an account? Sign in',
    ]) {
      final finder = find.text(label);
      await tester.scrollUntilVisible(
        finder,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(finder, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'password entry disables keyboard learning and clears after use',
    (tester) async {
      final controller = _controller(_Runtime());
      await _pumpAccountScreen(tester, controller);
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final editableFinder = find.descendant(
        of: passwordField,
        matching: find.byType(EditableText),
      );

      var field = tester.widget<EditableText>(editableFinder);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.enableIMEPersonalizedLearning, isFalse);
      expect(field.smartDashesType, SmartDashesType.disabled);
      expect(field.smartQuotesType, SmartQuotesType.disabled);

      await tester.enterText(passwordField, 'temporary-secret');
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'SIGN IN'))
          .onPressed!();
      await tester.pumpAndSettle();

      field = tester.widget<EditableText>(editableFinder);
      expect(field.controller.text, isEmpty);
      expect(controller.password.value, isEmpty);
    },
  );

  testWidgets('verification and age-rejection states remain readable', (
    tester,
  ) async {
    final controller = _controller(_Runtime());
    for (final state in [
      (AccountAccessMode.verifyEmail, 'I HAVE VERIFIED MY EMAIL'),
      (AccountAccessMode.ineligible, 'Review age information'),
    ]) {
      controller.mode.value = state.$1;
      await _pumpAccountScreen(tester, controller);
      final action = find.text(state.$2);
      await tester.scrollUntilVisible(
        action,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(action, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

Future<void> _pumpAccountScreen(
  WidgetTester tester,
  AccountAccessController controller,
) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(2),
        ),
        child: AccountAccessScreen(controller: controller),
      ),
    ),
  );
  await tester.pump();
}

AccountAccessController _controller(
  _Runtime runtime, {
  _AuthPort? port,
  bool verified = true,
  Future<void> Function()? onReady,
}) {
  final auth = port ?? _AuthPort(verified: verified);
  return AccountAccessController(
    loginWithPassword: SignInWithPasswordUseCase(auth),
    loginWithGoogle: SignInWithGoogleUseCase(auth),
    registration: CreatePasswordAccountUseCase(auth),
    recovery: RequestPasswordResetUseCase(auth),
    activation: AccountAccessCoordinator(runtime),
    authenticatedCallback: onReady ?? () async {},
  );
}

class _AuthPort
    implements SignInPort, PasswordAccountRegistrationPort, PasswordResetPort {
  _AuthPort({this.verified = true});
  final bool verified;
  int registrationCalls = 0;

  AccountIdentity _identity(AccountProvider provider, {bool? emailVerified}) =>
      AccountIdentity(
        uid: 'owner-a',
        emailVerified: emailVerified ?? verified,
        adultEligible: true,
        linkedProviders: {provider},
      );

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async => _identity(AccountProvider.password);

  @override
  Future<AccountIdentity> signInWithGoogle() async =>
      _identity(AccountProvider.google);

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async {
    registrationCalls++;
    return _identity(AccountProvider.password, emailVerified: false);
  }

  @override
  Future<void> requestPasswordReset(String emailAddress) async {}
}

class _Runtime implements AccountRuntimePort {
  _Runtime({this.failure});

  final Object? failure;

  @override
  String? activeOwnerId;

  @override
  Future<void> activate(String ownerId) async {
    if (failure case final failure?) throw failure;
    activeOwnerId = ownerId;
  }
}
