import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/email_verification_use_cases.dart';

AccountIdentity verificationIdentity({
  String uid = 'owner-a',
  bool verified = false,
  bool adult = true,
  Set<AccountProvider> providers = const {AccountProvider.password},
}) => AccountIdentity(
  uid: uid,
  emailVerified: verified,
  adultEligible: adult,
  linkedProviders: providers,
);

class VerificationSession implements StableIdentitySession {
  VerificationSession(this.identity);
  final AccountIdentity identity;

  @override
  Future<T> withIdentity<T>(
    Future<T> Function(AccountIdentity identity) operation,
  ) => operation(identity);
}

class VerificationPortFake implements EmailVerificationPort {
  VerificationDispatch dispatch = VerificationDispatch.sent;
  late AccountIdentity refreshed;
  var sends = 0;
  var refreshes = 0;

  @override
  Future<VerificationDispatch> sendVerification(String ownerId) async {
    sends++;
    return dispatch;
  }

  @override
  Future<AccountIdentity> refreshIdentity(String ownerId) async {
    refreshes++;
    return refreshed;
  }
}

void main() {
  test('requests verification by UID and exposes throttling', () async {
    final port = VerificationPortFake()
      ..refreshed = verificationIdentity()
      ..dispatch = VerificationDispatch.throttled;
    final status = await RequestEmailVerificationUseCase(
      VerificationSession(verificationIdentity()),
      port,
    ).execute();
    expect(status, RequestEmailVerificationStatus.throttled);
    expect(port.sends, 1);
  });

  test(
    'verified identity does not send and non-password flow is rejected',
    () async {
      final port = VerificationPortFake()..refreshed = verificationIdentity();
      expect(
        await RequestEmailVerificationUseCase(
          VerificationSession(verificationIdentity(verified: true)),
          port,
        ).execute(),
        RequestEmailVerificationStatus.alreadyVerified,
      );
      await expectLater(
        RequestEmailVerificationUseCase(
          VerificationSession(
            verificationIdentity(providers: const {AccountProvider.google}),
          ),
          port,
        ).execute(),
        throwsStateError,
      );
      expect(port.sends, 0);
    },
  );

  test('refresh reports verified or pending state', () async {
    final port = VerificationPortFake()
      ..refreshed = verificationIdentity(verified: false);
    final useCase = RefreshEmailVerificationUseCase(
      VerificationSession(verificationIdentity()),
      port,
    );
    expect(
      await useCase.execute(),
      RefreshEmailVerificationStatus.stillPending,
    );
    port.refreshed = verificationIdentity(verified: true);
    expect(await useCase.execute(), RefreshEmailVerificationStatus.verified);
  });

  test('refresh rejects UID, provider or eligibility changes', () async {
    final invalid = [
      verificationIdentity(uid: 'owner-b'),
      verificationIdentity(adult: false),
      verificationIdentity(
        providers: const {AccountProvider.password, AccountProvider.google},
      ),
    ];
    for (final result in invalid) {
      final port = VerificationPortFake()..refreshed = result;
      await expectLater(
        RefreshEmailVerificationUseCase(
          VerificationSession(verificationIdentity()),
          port,
        ).execute(),
        throwsA(isA<IdentityContinuityViolation>()),
      );
    }
  });
}
