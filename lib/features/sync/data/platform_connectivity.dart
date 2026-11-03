import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivitySnapshotSource {
  Future<List<ConnectivityResult>> checkConnectivity();
  Stream<List<ConnectivityResult>> get changes;
}

class ConnectivityPlusSnapshotSource implements ConnectivitySnapshotSource {
  const ConnectivityPlusSnapshotSource();

  Connectivity get _connectivity => Connectivity();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      _connectivity.checkConnectivity();

  @override
  Stream<List<ConnectivityResult>> get changes =>
      _connectivity.onConnectivityChanged;
}

/// Supplies network-link hints for sync scheduling.
///
/// A positive value means only that a network interface is available. The
/// authenticated sync transport remains the authority on backend reachability.
class PlatformConnectivity {
  const PlatformConnectivity({
    this.source = const ConnectivityPlusSnapshotSource(),
  });

  final ConnectivitySnapshotSource source;

  Future<bool> hasNetworkLink() async =>
      _hasNetworkLink(await source.checkConnectivity());

  Stream<bool> watchNetworkLink() => _watchNetworkLink().distinct();

  Stream<bool> _watchNetworkLink() async* {
    yield await hasNetworkLink();
    yield* source.changes.map(_hasNetworkLink);
  }

  static bool _hasNetworkLink(List<ConnectivityResult> results) =>
      results.isNotEmpty &&
      results.any((result) => result != ConnectivityResult.none);
}
