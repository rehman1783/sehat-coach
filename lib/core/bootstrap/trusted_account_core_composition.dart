import '../../features/account/data/encrypted_account_runtime.dart';
import '../../features/account/data/secure_account_lifecycle_port.dart';
import '../../features/account/data/secure_account_switch_preparation_port.dart';
import '../../features/account/domain/auth_state_reconciliation_coordinator.dart';
import '../../features/account/domain/account_data_operations.dart';
import '../../features/account/domain/auth_state_stream_binding.dart';
import '../../features/account/domain/create_password_account_use_case.dart';
import '../../features/account/domain/email_verification_use_cases.dart';
import '../../features/account/domain/prepare_account_switch_use_case.dart';
import '../../features/account/domain/request_password_reset_use_case.dart';
import '../../features/account/domain/serialized_identity_session.dart';
import '../../features/account/domain/sign_in_use_cases.dart';
import '../../features/account/domain/sign_out_coordinator.dart';
import '../../features/account/domain/suspend_account_session_use_case.dart';
import '../../features/account/domain/trusted_auth_state_coordinator.dart';
import '../../features/account/domain/verified_adult_owner_session.dart';
import '../../features/account/presentation/controllers/account_access_controller.dart';
import '../../features/account/presentation/controllers/account_safety_controller.dart';
import '../../features/account/presentation/controllers/account_switch_controller.dart';
import '../../features/sync/domain/sync_pull_coordinator.dart';
import '../../features/sync/domain/sync_upload_coordinator.dart';
import '../data/local/account_database_service.dart';
import 'account_access_composition.dart';
import 'activated_account_features.dart';

/// Provider-facing contract for the trusted account core.
///
/// A Firebase implementation may implement several of these ports with one
/// adapter, but it must not bypass their domain validation boundaries.
class TrustedAccountProviderPorts {
  const TrustedAccountProviderPorts({
    required this.authState,
    required this.signIn,
    required this.registration,
    required this.passwordReset,
    required this.emailVerification,
  });

  final AuthStateStreamPort authState;
  final SignInPort signIn;
  final PasswordAccountRegistrationPort registration;
  final PasswordResetPort passwordReset;
  final EmailVerificationPort emailVerification;
}

/// Shares one identity serialization boundary across startup events,
/// interactive account access, encrypted storage and owner-scoped features.
class TrustedAccountCoreComposition {
  factory TrustedAccountCoreComposition({
    required TrustedAccountProviderPorts provider,
    required AccountDatabaseService databases,
    required DecryptedAccountMemoryClearer clearDecryptedMemory,
    required Future<void> Function() onAuthenticated,
    SyncUploadTransport? syncUpload,
    SyncPullTransport? syncPull,
  }) {
    final identitySession = SerializedIdentitySession();
    final runtime = EncryptedAccountRuntime(databases, clearDecryptedMemory);
    final reconciliation = AuthStateReconciliationCoordinator(
      runtime,
      SuspendAccountSessionUseCase(runtime),
    );
    final trustedAuth = TrustedAuthStateCoordinator(
      identitySession,
      reconciliation,
    );
    final access = AccountAccessComposition(
      signIn: provider.signIn,
      registration: provider.registration,
      passwordReset: provider.passwordReset,
      emailVerification: provider.emailVerification,
      identitySession: identitySession,
      runtime: runtime,
      suspension: runtime,
      onAuthenticated: onAuthenticated,
    );
    return TrustedAccountCoreComposition._(
      identitySession: identitySession,
      runtime: runtime,
      authState: AuthStateStreamBinding(provider.authState, trustedAuth),
      accountAccess: access,
      features: ActivatedAccountFeatures(
        databases: databases,
        ownerSession: VerifiedAdultOwnerSession(identitySession),
        syncUpload: syncUpload,
        syncPull: syncPull,
      ),
    );
  }

  const TrustedAccountCoreComposition._({
    required this.identitySession,
    required this.runtime,
    required this.authState,
    required this.accountAccess,
    required this.features,
  });

  final SerializedIdentitySession identitySession;
  final EncryptedAccountRuntime runtime;
  final AuthStateStreamBinding authState;
  final AccountAccessComposition accountAccess;
  final ActivatedAccountFeatures features;

  AccountAccessController createAccountAccessController() =>
      accountAccess.createController();

  AccountSwitchController createAccountSwitchController({
    required OwnerAction synchronizeOwner,
    required AccountSwitchConnectivityCheck connectivityCheck,
    required AccountSwitchReadyAction onReadyForAuthentication,
  }) => AccountSwitchController(
    switchPreparation: PrepareAccountSwitchUseCase(
      SecureAccountSwitchPreparationPort(
        localData: runtime.databaseService,
        suspension: SuspendAccountSessionUseCase(runtime),
        synchronizeOwner: synchronizeOwner,
      ),
    ),
    connectivityCheck: connectivityCheck,
    onReadyForAuthentication: onReadyForAuthentication,
  );

  AccountSafetyController createAccountSafetyController({
    required OwnerAction synchronizeOwner,
    required OwnerAction clearOwnerSession,
    required OwnerDecision deleteCloudAccount,
    required OwnerDecision checkRecentAuthentication,
    required ConnectivityCheck connectivityCheck,
    required AccountAction onSignedOut,
    required AccountAction onAccountDeleted,
    AccountAction? onLocalDataCleared,
    ReauthenticateAccount? reauthenticate,
  }) {
    final lifecycle = SecureAccountLifecyclePort(
      localData: runtime.databaseService,
      synchronizeOwner: synchronizeOwner,
      clearOwnerSession: clearOwnerSession,
      deleteCloudAccount: deleteCloudAccount,
      checkRecentAuthentication: checkRecentAuthentication,
    );
    final ownerSession = VerifiedAdultOwnerSession(identitySession);
    return AccountSafetyController(
      signOutAction: AuthenticatedSignOutUseCase(
        identitySession,
        SignOutCoordinator(lifecycle),
      ),
      clearLocalAction: ClearLocalDataUseCase(ownerSession, lifecycle),
      deleteAction: AuthenticatedDeleteAccountUseCase(
        identitySession,
        DeleteAccountCoordinator(lifecycle),
      ),
      connectivityCheck: connectivityCheck,
      onSignedOut: onSignedOut,
      onAccountDeleted: onAccountDeleted,
      onLocalDataCleared: onLocalDataCleared,
      reauthenticate: reauthenticate,
    );
  }
}
