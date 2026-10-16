import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// An explicit booking entry starts a new form, even in the retained book tab.
void startNewBooking(BuildContext context) {
  context.goNamed(
    RouteNames.bookShoot,
    extra: {'newBooking': DateTime.now().microsecondsSinceEpoch.toString()},
  );
}
