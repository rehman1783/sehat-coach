import 'package:http/http.dart' as http;

import '../../features/account/domain/authenticated_owner_session.dart';
import '../../features/entitlements/data/trusted_credit_backend_gateway.dart';
import '../../features/entitlements/domain/entitlement_contracts.dart';
import '../services/trusted_backend_tokens.dart';

class ActivatedCreditFeatures {
  const ActivatedCreditFeatures({
    required this.ownerSession,
    required this.endpoint,
    required this.httpClient,
    required this.idTokens,
    required this.appCheckTokens,
  });

  final AuthenticatedOwnerSession ownerSession;
  final Uri endpoint;
  final http.Client httpClient;
  final FirebaseIdTokenProvider idTokens;
  final FirebaseAppCheckTokenProvider appCheckTokens;

  Future<CreditReservationCoordinator> createReservationCoordinator() =>
      ownerSession.withOwner(
        (ownerId) async => CreditReservationCoordinator(
          TrustedCreditBackendGateway(
            ownerId: ownerId,
            endpoint: endpoint,
            client: httpClient,
            idTokens: idTokens,
            appCheckTokens: appCheckTokens,
          ),
        ),
      );
}
