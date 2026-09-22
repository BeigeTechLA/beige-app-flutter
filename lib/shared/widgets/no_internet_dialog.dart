import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String noInternetDialogRouteName = '__no_internet_dialog__';

Future<void> showNoInternetDialog(BuildContext context) {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: false,
    routeSettings: const RouteSettings(name: noInternetDialogRouteName),
    builder: (ctx) {
      return PopScope(
        canPop: false,
        child: AlertDialog.adaptive(
          title: const Text('No Internet'),
          content: const Text(
            'You are offline. Please check your connection and try again.',
          ),
          actions: [
            if (Platform.isIOS)
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Retry'),
              )
            else
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    },
  );
}
