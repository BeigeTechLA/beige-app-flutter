import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../main.dart';

class InternetHelper {
  static StreamSubscription? _subscription;
  static bool _isDialogShowing = false;

  static void startListening() {
    _subscription = Stream.periodic(const Duration(seconds: 3))
        .listen((_) => _checkInternet());
  }

  static Future<void> _checkInternet() async {
    bool hasInternet = await _hasRealInternet();

    if (!hasInternet) {
      if (!_isDialogShowing) {
        _isDialogShowing = true;

        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("No Internet"),
            content: const Text("Please check your internet connection."),
          ),
        );
      }
    } else {
      if (_isDialogShowing) {
        Navigator.of(navigatorKey.currentContext!).pop();
        _isDialogShowing = false;
      }
    }
  }

  static Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}