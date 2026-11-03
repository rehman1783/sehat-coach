import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../features/admin/data/trusted_admin_http_gateway.dart';
import '../../features/admin/data/trusted_admin_mutation_transport.dart';
import '../../features/admin/presentation/admin_workspace_composition.dart';
import '../config/app_config.dart';
import '../services/trusted_backend_tokens.dart';

/// Production admin bootstrap. It has no preview implementation and refuses to
/// compose unless an explicit trusted HTTPS endpoint is configured.
class TrustedAdminBootstrap {
  factory TrustedAdminBootstrap({
    required AppConfig config,
    required http.Client client,
    required FirebaseIdTokenProvider idTokens,
    required FirebaseAppCheckTokenProvider appCheckTokens,
    required DateTime Function() nowUtc,
  }) {
    final endpoint = config.adminBackendEndpoint;
    if (endpoint == null) {
      throw StateError('ADMIN_BACKEND_URL is required for trusted admin.');
    }
    final reads = TrustedAdminHttpGateway(
      endpoint: endpoint,
      client: client,
      idTokens: idTokens,
      appCheckTokens: appCheckTokens,
    );
    final mutations = TrustedAdminMutationClient(
      endpoint: endpoint,
      client: client,
      idTokens: idTokens,
      appCheckTokens: appCheckTokens,
    );
    final workspace = TrustedAdminWorkspaceComposition(
      session: reads,
      audit: reads,
      catalog: TrustedAdminCatalogHttpPort(mutations),
      city: TrustedAdminCityHttpPort(mutations),
      content: TrustedAdminContentHttpPort(mutations),
      prices: TrustedAdminGroceryPriceHttpPort(mutations),
      nowUtc: nowUtc,
    );
    return TrustedAdminBootstrap._(
      reads: reads,
      mutations: mutations,
      workspace: workspace,
    );
  }

  const TrustedAdminBootstrap._({
    required this.reads,
    required this.mutations,
    required this.workspace,
  });

  final TrustedAdminHttpGateway reads;
  final TrustedAdminMutationClient mutations;
  final TrustedAdminWorkspaceComposition workspace;

  Widget build() => workspace.build();
}
