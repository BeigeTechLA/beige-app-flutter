import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectionStream async* {
    await for (final results in _connectivity.onConnectivityChanged) {
      yield !results.contains(ConnectivityResult.none);
    }
  }

  Future<bool> hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
