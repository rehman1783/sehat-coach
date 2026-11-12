import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/theme/app_theme.dart';
import 'package:sehat_coach/features/account/domain/account_access_coordinator.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/confirm_adult_eligibility_use_case.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/request_password_reset_use_case.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
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

  test('invalid email formats report actionable validation feedback', () async {
    final controller = _controller(_Runtime());
    controller.emailAddress.value = 'not-an-email';
    controller.password.value = 'secret-pass';
    await controller.submitPassword();
    expect(controller.errorMessage.value, 'Enter a valid email address.');

    controller.emailAddress.value = ' ';
    await controller.requestPasswordReset();
    expect(controller.errorMessage.value, 'Enter a valid email address.');
  });

  testWidgets(
    'clearing age field resets declared age so blank age never passes',
    (tester) async {
      final runtime = _Runtime();
      final port = _AuthPort();
      final controller = _controller(runtime, port: port)..showCreateAccount();
      await _pumpAccountScreen(tester, controller);

      Future<void> enterVisibleField(String label, String value) async {
        final field = find.widgetWithText(TextFormField, label);
        await tester.scrollUntilVisible(
          field,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(field);
        await tester.enterText(field, value);
        await tester.pump();
      }

      await enterVisibleField('Email address', 'person@example.com');
      await enterVisibleField('Password', 'temporary-secret');
      await enterVisibleField('Age', '');
      expect(controller.declaredAge.value, 0);

      await controller.submitPassword();
      expect(port.registrationCalls, 0);
      expect(controller.mode.value, AccountAccessMode.ineligible);
    },
  );

  testWidgets(
    'first-time Google user can confirm 18+ age at 200 percent text and activate runtime',
    (tester) async {
      final runtime = _Runtime();
      final session = SerializedIdentitySession(
        AccountIdentity(
          uid: 'google-uid',
          emailVerified: true,
          adultEligible: false,
          linkedProviders: const {AccountProvider.google},
        ),
      );
      final auth = _AuthPort(adult: false);
      var ready = false;
      final controller = AccountAccessController(
        loginWithPassword: SignInWithPasswordUseCase(auth),
        loginWithGoogle: SignInWithGoogleUseCase(auth),
        registration: CreatePasswordAccountUseCase(auth),
        recovery: RequestPasswordResetUseCase(auth),
        activation: AccountAccessCoordinator(runtime),
        authenticatedCallback: () async => ready = true,
        confirmAdultEligibility: ConfirmAdultEligibilityUseCase(session, auth),
        signOutPending: () async => auth.signedOutCount++,
      );

      await controller.submitGoogle();
      expect(controller.mode.value, AccountAccessMode.ineligible);
      expect(controller.canConfirmAdultEligibility.value, isTrue);
      expect(runtime.activeOwnerId, isNull);

      await _pumpAccountScreen(tester, controller);
      final confirmButton = find.text('CONFIRM AND CONTINUE');
      await tester.scrollUntilVisible(
        confirmButton,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(confirmButton);
      expect(confirmButton, findsOneWidget);
      expect(find.text('Use a different account'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final ageCheckbox = find.widgetWithText(
        CheckboxListTile,
        'I confirm that I am 18 or older',
      );
      await tester.scrollUntilVisible(
        ageCheckbox,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(ageCheckbox);
      await tester.pumpAndSettle();
      await tester.tap(ageCheckbox);
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(ageCheckbox).value, isTrue);
      await tester.scrollUntilVisible(
        confirmButton,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(confirmButton);
      await tester.pumpAndSettle();
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(auth.eligibilityConfirmCalls, 1);
      expect(runtime.activeOwnerId, 'google-uid');
      expect(ready, isTrue);
    },
  );

  testWidgets(
    'password eye icon toggles visibility on screen without losing typed text',
    (tester) async {
      final controller = _controller(_Runtime());
      await _pumpAccountScreen(tester, controller);
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final editableFinder = find.descendant(
        of: passwordField,
        matching: find.byType(EditableText),
      );

      final iconButton = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );
      await tester.scrollUntilVisible(
        passwordField,
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(passwordField);
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, 'MySecret123');
      await tester.pumpAndSettle();
      await tester.ensureVisible(iconButton);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(editableFinder).obscureText, isTrue);
      expect(find.byTooltip('Show password'), findsOneWidget);

      await tester.tap(iconButton);
      await tester.pump();
      expect(tester.widget<EditableText>(editableFinder).obscureText, isFalse);
      expect(
        tester.widget<EditableText>(editableFinder).controller.text,
        'MySecret123',
      );
      expect(find.byTooltip('Hide password'), findsOneWidget);

      await tester.tap(iconButton);
      await tester.pump();
      expect(tester.widget<EditableText>(editableFinder).obscureText, isTrue);
      expect(find.byTooltip('Show password'), findsOneWidget);
    },
  );

  testWidgets(
    'create account toggles 18+ checkbox visually and accepts age 18 and above',
    (tester) async {
      for (final ageText in ['18', '25']) {
        final runtime = _Runtime();
        final auth = _AuthPort();
        final controller = _controller(runtime, port: auth)
          ..showCreateAccount();
        await _pumpAccountScreen(tester, controller);

        Future<void> enterVisible(String label, String value) async {
          final field = find.widgetWithText(TextFormField, label);
          await tester.scrollUntilVisible(
            field,
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(field);
          await tester.enterText(field, value);
          await tester.pump();
        }

        await enterVisible('Email address', 'adult$ageText@example.com');
        await enterVisible('Password', 'StrongPass1!');
        await enterVisible('Age', ageText);

        final checkboxFinder = find.widgetWithText(
          CheckboxListTile,
          'I confirm that I am 18 or older',
        );
        await tester.scrollUntilVisible(
          checkboxFinder,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(checkboxFinder);
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isFalse);

        await tester.tap(checkboxFinder);
        await tester.pump();
        expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isTrue);
        expect(controller.adultConfirmed.value, isTrue);

        final submit = find.widgetWithText(FilledButton, 'CREATE ACCOUNT');
        await tester.scrollUntilVisible(
          submit,
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(submit);
        await tester.pumpAndSettle();
        await tester.tap(submit);
        await tester.pumpAndSettle();

        expect(auth.registrationCalls, 1);
        expect(auth.lastAttestation?.declaredAge, int.parse(ageText));
        expect(auth.lastAttestation?.confirmed, isTrue);
        expect(controller.mode.value, AccountAccessMode.verifyEmail);
      }
    },
  );

  test('create account with 18+ age but unchecked confirmation prompts user without minor lockout', () async {
    final auth = _AuthPort();
    final controller = _controller(_Runtime(), port: auth)..showCreateAccount();
    controller.emailAddress.value = 'adult@example.com';
    controller.password.value = 'StrongPass1!';
    controller.declaredAge.value = 21;
    controller.adultConfirmed.value = false;

    await controller.submitPassword();

    expect(auth.registrationCalls, 0);
    expect(controller.mode.value, AccountAccessMode.createAccount);
    expect(
      controller.errorMessage.value,
      'Please confirm that you are 18 or older to continue.',
    );
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
    implements
        SignInPort,
        PasswordAccountRegistrationPort,
        AdultEligibilityConfirmationPort,
        PasswordResetPort {
  _AuthPort({this.verified = true, this.adult = true});
  final bool verified;
  final bool adult;
  int registrationCalls = 0;
  int eligibilityConfirmCalls = 0;
  int signedOutCount = 0;
  AdultEligibilityAttestation? lastAttestation;

  AccountIdentity _identity(
    AccountProvider provider, {
    bool? emailVerified,
    bool? adultEligible,
    String uid = 'owner-a',
  }) => AccountIdentity(
    uid: uid,
    emailVerified: emailVerified ?? verified,
    adultEligible: adultEligible ?? adult,
    linkedProviders: {provider},
  );

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async => _identity(AccountProvider.password);

  @override
  Future<AccountIdentity> signInWithGoogle() async => _identity(
    AccountProvider.google,
    emailVerified: true,
    uid: adult ? 'owner-a' : 'google-uid',
  );

  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) async {
    registrationCalls++;
    lastAttestation = eligibility;
    return _identity(AccountProvider.password, emailVerified: false);
  }

  @override
  Future<AccountIdentity> confirmAdultEligibility({
    required String ownerId,
    required AdultEligibilityAttestation eligibility,
  }) async {
    eligibilityConfirmCalls++;
    return _identity(
      AccountProvider.google,
      uid: ownerId,
      emailVerified: true,
      adultEligible: true,
    );
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
