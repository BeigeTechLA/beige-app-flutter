import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../core/connectivity/connectivity_providers.dart';
import '../../core/connectivity/connectivity_status.dart';
import 'no_internet_dialog.dart';

class ConnectivityListener extends ConsumerStatefulWidget {
  const ConnectivityListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ConnectivityListener> createState() =>
      _ConnectivityListenerState();
}

class _ConnectivityListenerState extends ConsumerState<ConnectivityListener> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectivityStatus>(connectivityStatusProvider, (prev, next) {
      if (next == ConnectivityStatus.offline) {
        _showDialog();
      } else if (next == ConnectivityStatus.online) {
        _dismissDialog();
      }
    });

    return widget.child;
  }

  void _showDialog() {
    if (_isDialogShowing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null || _isDialogShowing) return;
      _isDialogShowing = true;
      showNoInternetDialog(ctx).whenComplete(() {
        _isDialogShowing = false;
        // If user dismissed dialog (via Retry) but device still offline,
        // re-show so user is not stranded without the prompt.
        if (!mounted) return;
        final status = ref.read(connectivityStatusProvider);
        if (status == ConnectivityStatus.offline) {
          _showDialog();
        }
      });
    });
  }

  void _dismissDialog() {
    if (!_isDialogShowing) return;
    final navState = rootNavigatorKey.currentState;
    if (navState == null) {
      _isDialogShowing = false;
      return;
    }
    // Only pop if current top route really is our dialog. Avoids accidentally
    // popping an unrelated screen if dialog was already dismissed.
    navState.popUntil((route) {
      return route.settings.name != noInternetDialogRouteName;
    });
    _isDialogShowing = false;
  }
}
