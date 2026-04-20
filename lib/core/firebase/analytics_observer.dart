import 'package:flutter/material.dart';

/// Route observer that tracks screen views for analytics.
///
/// STUB — Firebase Analytics not yet initialised (no Firebase project).
/// Replace body with real FirebaseAnalytics calls once `flutterfire configure`
/// has been run and `firebase_analytics` is added to pubspec.yaml.
///
/// Wire-up in router.dart:
/// ```dart
/// GoRouter(
///   observers: [AppAnalyticsObserver()],
///   ...
/// )
/// ```
class AppAnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logScreen(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _logScreen(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _logScreen(previousRoute);
  }

  void _logScreen(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null) return;
    // TODO(firebase): replace with AnalyticsService.logScreenView(screenName: name)
    debugPrint('[Analytics] screen: $name');
  }
}