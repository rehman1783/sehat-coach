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
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/domain/pending_onboarding_draft.dart';

void main() {
  test('PendingOnboardingDraft stores defensive copy and clears cleanly', () {
    final draft = PendingOnboardingDraft();
    expect(draft.hasDraft, isFalse);
    expect(draft.peek(), isNull);

    final conditions = [HealthCondition.standard];
    final state = OnboardingState(
      goal: GoalType.stayHealthy,
      age: 24,
      conditions: conditions,
    );

    draft.save(state, adultAgeConfirmed: true);
    conditions.add(HealthCondition.diabetes);

    expect(draft.hasDraft, isTrue);
    final peeked = draft.peek();
    expect(peeked, isNotNull);
    expect(peeked!.adultAgeConfirmed, isTrue);
    expect(peeked.profile.age, 24);
    expect(peeked.profile.conditions, [HealthCondition.standard]);

    final taken = draft.take();
    expect(taken?.profile.age, 24);
    expect(draft.hasDraft, isFalse);
    expect(draft.peek(), isNull);
  });

  testWidgets(
    'New to Sehat Coach button invokes pre-auth onboarding callback when provided',
    (tester) async {
      final auth = _StubAuthPort();
      final controller = AccountAccessController(
        loginWithPassword: SignInWithPasswordUseCase(auth),
        loginWithGoogle: SignInWithGoogleUseCase(auth),
        registration: CreatePasswordAccountUseCase(auth),
        recovery: RequestPasswordResetUseCase(auth),
        activation: AccountAccessCoordinator(_StubRuntime()),
        authenticatedCallback: () async {},
      );
      var startedOnboarding = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AccountAccessScreen(
            controller: controller,
            onStartCreateAccount: (_) async {
              startedOnboarding = true;
            },
          ),
        ),
      );
      await tester.pump();

      final createButton = find.text('New to Sehat Coach? Create account');
      await tester.scrollUntilVisible(
        createButton,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(startedOnboarding, isTrue);
      expect(controller.mode.value, AccountAccessMode.signIn);
    },
  );
}

class _StubAuthPort
    implements SignInPort, PasswordAccountRegistrationPort, PasswordResetPort {
  @override
  Future<AccountIdentity> createPasswordAccount({
    required String emailAddress,
    required String password,
    required AdultEligibilityAttestation eligibility,
  }) => throw UnimplementedError();

  @override
  Future<void> requestPasswordReset(String emailAddress) async {}

  @override
  Future<AccountIdentity> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<AccountIdentity> signInWithPassword({
    required String emailAddress,
    required String password,
  }) => throw UnimplementedError();
}

class _StubRuntime implements AccountRuntimePort {
  @override
  String? activeOwnerId;

  @override
  Future<void> activate(String ownerId) async => activeOwnerId = ownerId;
}
