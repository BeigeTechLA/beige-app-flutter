import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:beige/app/router.dart';

class InternetHelper {
  static StreamSubscription? _subscription;
  static bool _isDialogShowing = false;

  static void startListening() {
    _subscription = Stream.periodic(const Duration(seconds: 3))
        .listen((_) => _checkInternet());
  }

  static Future<void> _checkInternet() async {
    bool hasInternet = await _hasRealInternet();

    final context = rootNavigatorKey.currentState?.overlay?.context;

    if (!hasInternet) {
      if (!_isDialogShowing && context != null) {
        _isDialogShowing = true;

        // 🔥 USE ROOT NAVIGATOR + PUSH (NOT JUST SHOW DIALOG)
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return WillPopScope(
                onWillPop: () async => false, // 🔥 BACK COMPLETELY DISABLED
                child: Scaffold(
                  backgroundColor: Colors.black54,
                  body: Center(
                    child: AlertDialog(
                      title: const Text("No Internet"),
                      content: const Text(
                        "Please check your internet connection.",
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    } else {
      if (_isDialogShowing && context != null) {
        // 🔥 CLOSE ONLY IF DIALOG IS OPEN
        Navigator.of(context, rootNavigator: true).pop();
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