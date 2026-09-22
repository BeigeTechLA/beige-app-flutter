import 'package:flutter/material.dart';

/// Global navigator key shared by the router and non-widget callers
/// (e.g. network interceptors) that need to navigate without a BuildContext.
final rootNavigatorKey = GlobalKey<NavigatorState>();
