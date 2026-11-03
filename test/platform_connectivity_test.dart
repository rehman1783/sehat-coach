import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/sync/data/platform_connectivity.dart';

void main() {
  test('seeds current link state then emits distinct changes', () async {
    final source = _Source([ConnectivityResult.wifi]);
    addTearDown(source.close);
    final connectivity = PlatformConnectivity(source: source);
    final values = <bool>[];
    final subscription = connectivity.watchNetworkLink().listen(values.add);
    await _pump();
    source.controller.add([ConnectivityResult.mobile]);
    source.controller.add([ConnectivityResult.none]);
    source.controller.add([]);
    source.controller.add([ConnectivityResult.ethernet]);
    await _pump();
    await subscription.cancel();

    expect(values, [true, false, true]);
  });

  test('network link does not claim backend reachability', () async {
    final source = _Source([ConnectivityResult.none]);
    addTearDown(source.close);
    final connectivity = PlatformConnectivity(source: source);
    expect(await connectivity.hasNetworkLink(), isFalse);
    source.current = [ConnectivityResult.vpn, ConnectivityResult.wifi];
    expect(await connectivity.hasNetworkLink(), isTrue);
  });
}

class _Source implements ConnectivitySnapshotSource {
  _Source(this.current);
  List<ConnectivityResult> current;
  final controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;
  @override
  Stream<List<ConnectivityResult>> get changes => controller.stream;
  Future<void> close() => controller.close();
}

Future<void> _pump() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
