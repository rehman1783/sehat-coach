import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/confirm_adult_eligibility_use_case.dart';
import 'package:sehat_coach/features/account/domain/create_password_account_use_case.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';

class _ConfirmationPort implements AdultEligibilityConfirmationPort {
  _ConfirmationPort(this.onConfirm);

  final AccountIdentity Function(
    String ownerId,
    AdultEligibilityAttestation eligibility,
  )
  onConfirm;
  int calls = 0;

  @override
  Future<AccountIdentity> confirmAdultEligibility({
    required String ownerId,
    required AdultEligibilityAttestation eligibility,
  }) async {
    calls++;
    return onConfirm(ownerId, eligibility);
  }
}

void main() {
  test('rejects minor or unconfirmed input without calling port', () async {
    final session = SerializedIdentitySession(
      AccountIdentity(
        uid: 'google-1',
        emailVerified: true,
        adultEligible: false,
        linkedProviders: const {AccountProvider.google},
      ),
    );
    final port = _ConfirmationPort(
      (uid, _) => AccountIdentity(
        uid: uid,
        emailVerified: true,
        adultEligible: true,
        linkedProviders: const {AccountProvider.google},
      ),
    );
    final useCase = ConfirmAdultEligibilityUseCase(session, port);

    await expectLater(
      useCase.execute(declaredAge: 17, adultConfirmed: true),
      throwsA(isA<AdultEligibilityRequired>()),
    );
    await expectLater(
      useCase.execute(declaredAge: 21, adultConfirmed: false),
      throwsA(isA<AdultEligibilityRequired>()),
    );
    expect(port.calls, 0);
  });

  test('confirms eligibility and enforces identity continuity', () async {
    final session = SerializedIdentitySession(
      AccountIdentity(
        uid: 'google-1',
        emailVerified: true,
        adultEligible: false,
        linkedProviders: const {AccountProvider.google},
      ),
    );
    final validPort = _ConfirmationPort(
      (uid, eligibility) => AccountIdentity(
        uid: uid,
        emailVerified: true,
        adultEligible: eligibility.confirmed && eligibility.declaredAge >= 18,
        linkedProviders: const {AccountProvider.google},
      ),
    );
    final updated = await ConfirmAdultEligibilityUseCase(
      session,
      validPort,
    ).execute(declaredAge: 24, adultConfirmed: true);
    expect(updated.adultEligible, isTrue);
    expect(validPort.calls, 1);

    final hijackedPort = _ConfirmationPort(
      (_, _) => AccountIdentity(
        uid: 'other-user',
        emailVerified: true,
        adultEligible: true,
        linkedProviders: const {AccountProvider.google},
      ),
    );
    await expectLater(
      ConfirmAdultEligibilityUseCase(
        session,
        hijackedPort,
      ).execute(declaredAge: 24, adultConfirmed: true),
      throwsA(isA<IdentityContinuityViolation>()),
    );
  });
}
