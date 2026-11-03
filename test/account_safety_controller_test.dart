import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_data_operations.dart';
import 'package:sehat_coach/features/account/domain/account_identity.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/account/domain/serialized_identity_session.dart';
import 'package:sehat_coach/features/account/domain/sign_out_coordinator.dart';
import 'package:sehat_coach/features/account/presentation/controllers/account_safety_controller.dart';
import 'package:sehat_coach/features/account/presentation/screens/account_safety_screen.dart';

void main() {
  test('online pending changes offer explicit sync-first sign-out', () async {
    final fixture = _Fixture(pending: 2);
    await fixture.controller.signOut();
    expect(fixture.controller.canSyncAndSignOut.value, isTrue);
    expect(fixture.port.clearedAccount, isFalse);

    await fixture.controller.signOut(syncFirst: true);
    expect(fixture.signedOut, isTrue);
    expect(fixture.port.clearedAccount, isTrue);
  });

  test('offline sign-out protects pending records', () async {
    final fixture = _Fixture(pending: 1, online: false);
    await fixture.controller.signOut();
    expect(fixture.controller.errorMessage.value, contains('protected'));
    expect(fixture.port.clearedAccount, isFalse);
  });

  test('clear local data remains distinct and keeps account session', () async {
    final fixture = _Fixture();
    await fixture.controller.clearLocalData(confirmed: true);
    expect(fixture.localCleared, isTrue);
    expect(fixture.signedOut, isFalse);
    expect(fixture.deleted, isFalse);
  });

  test('deletion requiring recent auth keeps all data', () async {
    final fixture = _Fixture(recent: false, reauthenticate: () async => false);
    await fixture.controller.deleteAccount(confirmed: true);
    expect(fixture.controller.canReauthenticateForDelete.value, isTrue);
    expect(fixture.port.cloudDeleteAccepted, isFalse);
    expect(fixture.deleted, isFalse);
  });

  test(
    'confirmed deletion calls terminal navigation only on success',
    () async {
      final fixture = _Fixture();
      await fixture.controller.deleteAccount(confirmed: true);
      expect(fixture.deleted, isTrue);
      expect(fixture.port.cloudDeleteAccepted, isTrue);
    },
  );

  testWidgets('account actions remain distinct at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    final fixture = _Fixture(pending: 2);
    await fixture.controller.signOut();

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: AccountSafetyScreen(controller: fixture.controller),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sign out'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('SYNC AND SIGN OUT'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('SYNC AND SIGN OUT'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Clear local data'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Clear local data'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Delete account'), findsOneWidget);
    final status = find.bySemanticsLabel(
      'Status: Unsynchronized records exist. Synchronize them before signing out.',
    );
    await tester.scrollUntilVisible(
      status,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(status, findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}

class _Fixture {
  _Fixture({
    int pending = 0,
    bool online = true,
    bool recent = true,
    Future<bool> Function()? reauthenticate,
  }) : port = _Port(pending: pending, recent: recent),
       session = SerializedIdentitySession(_identity()) {
    controller = AccountSafetyController(
      signOutAction: AuthenticatedSignOutUseCase(
        session,
        SignOutCoordinator(port),
      ),
      clearLocalAction: ClearLocalDataUseCase(_OwnerSession(session), port),
      deleteAction: AuthenticatedDeleteAccountUseCase(
        session,
        DeleteAccountCoordinator(port),
      ),
      connectivityCheck: () async => online,
      onSignedOut: () async => signedOut = true,
      onAccountDeleted: () async => deleted = true,
      onLocalDataCleared: () async => localCleared = true,
      reauthenticate: reauthenticate,
    );
  }

  final _Port port;
  final SerializedIdentitySession session;
  late final AccountSafetyController controller;
  bool signedOut = false;
  bool deleted = false;
  bool localCleared = false;
}

AccountIdentity _identity() => AccountIdentity(
  uid: 'owner-a',
  emailVerified: true,
  adultEligible: true,
  linkedProviders: const {AccountProvider.password},
);

class _OwnerSession implements AuthenticatedOwnerSession {
  const _OwnerSession(this.session);
  final SerializedIdentitySession session;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      session.withIdentity((identity) => operation(identity.uid));
}

class _Port implements SignOutPort, AccountDataOperationsPort {
  _Port({required this.pending, required this.recent});
  int pending;
  bool recent;
  bool clearedAccount = false;
  bool cloudDeleteAccepted = false;

  @override
  Future<int> pendingChangeCount(String ownerId) async => pending;

  @override
  Future<void> synchronize(String ownerId) async => pending = 0;

  @override
  Future<bool> clearAccountIfFullySynced(String ownerId) async {
    if (pending > 0) return false;
    clearedAccount = true;
    return true;
  }

  @override
  Future<void> clearSession(String ownerId) async {}

  @override
  Future<bool> hasRecentAuthentication(String ownerId) async => recent;

  @override
  Future<bool> clearLocalIfFullySynced(String ownerId) async => pending == 0;

  @override
  Future<bool> requestCloudAccountDeletion(String ownerId) async {
    cloudDeleteAccepted = true;
    return true;
  }
}
