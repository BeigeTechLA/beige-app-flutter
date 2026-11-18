import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// An explicit booking entry starts a new form, even in the retained book tab.
///
/// Optional prefill seeds the fresh draft — e.g. "Book Again" from a completed
/// shoot passes its API [contentType] (`'videographer'`, `'photographer'`,
/// `'photographer,videographer'`) and [shootTypeName] (e.g. `'Wedding'`).
void startNewBooking(
  BuildContext context, {
  String? contentType,
  String? shootTypeName,
}) {
  context.goNamed(
    RouteNames.bookShoot,
    extra: {
      'newBooking': DateTime.now().microsecondsSinceEpoch.toString(),
      'contentType': ?contentType,
      'shootTypeName': ?shootTypeName,
    },
  );
}
