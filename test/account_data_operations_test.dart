import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/account/domain/account_data_operations.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';

class DataTestSession implements AuthenticatedOwnerSession {
  DataTestSession(this.ownerId);
  final String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class DataTestPort implements AccountDataOperationsPort {
  bool recentAuthentication = true;
  int pending = 0;
  bool cloudAccepted = true;
  bool localClearSafe = true;
  int cloudRequests = 0;
  int localClears = 0;
  int sessionClears = 0;

  @override
  Future<bool> hasRecentAuthentication(String ownerId) async =>
      recentAuthentication;

  @override
  Future<int> pendingChangeCount(String ownerId) async => pending;

  @override
  Future<bool> clearLocalIfFullySynced(String ownerId) async {
    if (!localClearSafe || pending > 0) return false;
    localClears++;
    return true;
  }

  @override
  Future<bool> requestCloudAccountDeletion(String ownerId) async {
    cloudRequests++;
    return cloudAccepted;
  }

  @override
  Future<void> clearSession(String ownerId) async => sessionClears++;
}

void main() {
  test(
    'clear local data preserves session and blocks pending records',
    () async {
      final port = DataTestPort()..pending = 1;
      final clear = ClearLocalDataUseCase(DataTestSession('owner-a'), port);
      expect(await clear.execute(), ClearLocalDataStatus.pendingChanges);
      expect(port.localClears, 0);
      expect(port.sessionClears, 0);
      port.pending = 0;
      expect(await clear.execute(), ClearLocalDataStatus.cleared);
      expect(port.localClears, 1);
      expect(port.sessionClears, 0);
    },
  );

  test(
    'delete requires explicit confirmation before any side effect',
    () async {
      final port = DataTestPort();
      final delete = DeleteAccountUseCase(DataTestSession('owner-a'), port);
      expect(() => delete.execute(confirmed: false), throwsArgumentError);
      expect(port.cloudRequests, 0);
      expect(port.localClears, 0);
      expect(port.sessionClears, 0);
    },
  );

  test(
    'delete requires recent authentication before inspecting data',
    () async {
      final port = DataTestPort()
        ..recentAuthentication = false
        ..pending = 3;
      final delete = DeleteAccountUseCase(DataTestSession('owner-a'), port);
      expect(
        await delete.execute(confirmed: true),
        DeleteAccountStatus.recentAuthenticationRequired,
      );
      expect(port.cloudRequests, 0);
      expect(port.localClears, 0);
      expect(port.sessionClears, 0);
    },
  );

  test('delete blocks pending data and rejected cloud request', () async {
    final port = DataTestPort()..pending = 2;
    final delete = DeleteAccountUseCase(DataTestSession('owner-a'), port);
    expect(
      await delete.execute(confirmed: true),
      DeleteAccountStatus.pendingChanges,
    );
    expect(port.cloudRequests, 0);
    port
      ..pending = 0
      ..cloudAccepted = false;
    expect(
      await delete.execute(confirmed: true),
      DeleteAccountStatus.cloudRequestRejected,
    );
    expect(port.localClears, 0);
    expect(port.sessionClears, 0);
  });

  test('accepted deletion clears local data then session', () async {
    final port = DataTestPort();
    final delete = DeleteAccountUseCase(DataTestSession('owner-a'), port);
    expect(await delete.execute(confirmed: true), DeleteAccountStatus.deleted);
    expect(port.cloudRequests, 1);
    expect(port.localClears, 1);
    expect(port.sessionClears, 1);
  });

  test(
    'new pending edit after cloud request prevents local destruction',
    () async {
      final port = DataTestPort()..localClearSafe = false;
      final delete = DeleteAccountUseCase(DataTestSession('owner-a'), port);
      expect(
        await delete.execute(confirmed: true),
        DeleteAccountStatus.localCleanupPending,
      );
      expect(port.cloudRequests, 1);
      expect(port.localClears, 0);
      expect(port.sessionClears, 0);
    },
  );
}
