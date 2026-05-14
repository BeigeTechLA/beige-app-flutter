import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_status.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static const Duration _debounce = Duration(milliseconds: 300);
  static const Duration _lookupTimeout = Duration(seconds: 3);
  static const String _reachabilityHost = 'google.com';

  Stream<ConnectivityStatus> watch() async* {
    yield await current();

    Timer? debounceTimer;
    final controller = StreamController<ConnectivityStatus>();

    final sub = _connectivity.onConnectivityChanged.listen((results) {
      debounceTimer?.cancel();
      debounceTimer = Timer(_debounce, () async {
        final status = await _resolve(results);
        if (!controller.isClosed) controller.add(status);
      });
    });

    controller.onCancel = () async {
      debounceTimer?.cancel();
      await sub.cancel();
    };

    yield* controller.stream;
  }

  Future<ConnectivityStatus> current() async {
    final results = await _connectivity.checkConnectivity();
    return _resolve(results);
  }

  Future<ConnectivityStatus> _resolve(List<ConnectivityResult> results) async {
    final hasTransport = results.any((r) => r != ConnectivityResult.none);
    if (!hasTransport) return ConnectivityStatus.offline;

    final reachable = await _hasRealInternet();
    return reachable ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup(_reachabilityHost)
          .timeout(_lookupTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
