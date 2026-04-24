import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beige/app/theme.dart';
import 'package:beige/core/providers/core_providers.dart';

/// Extension on [WidgetTester] for pumping widgets wrapped in
/// the app's standard provider + theme + router setup.
extension PumpProviderApp on WidgetTester {
  /// Pumps [widget] inside a [ProviderScope] + [MaterialApp] with dark theme.
  ///
  /// Use for widget tests that don't need navigation.
  ///
  /// ```dart
  /// await tester.pumpProviderApp(
  ///   const LoginScreen(),
  ///   overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
  /// );
  /// ```
  Future<void> pumpProviderApp(
    Widget widget, {
    List<Override> overrides = const [],
    SharedPreferences? prefs,
  }) async {
    final sharedPrefs = prefs ?? await _mockPrefs();

    return pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ...overrides,
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: widget,
        ),
      ),
    );
  }

  /// Pumps [widget] inside a [ProviderScope] + [MaterialApp.router] with
  /// a GoRouter that shows [widget] at '/'.
  ///
  /// Use for widget tests that need GoRouter navigation (e.g., context.goNamed).
  ///
  /// ```dart
  /// await tester.pumpRoutedApp(
  ///   const LoginScreen(),
  ///   overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
  ///   routes: [
  ///     GoRoute(path: '/home', name: 'home', builder: (_, __) => const Placeholder()),
  ///   ],
  /// );
  /// ```
  Future<void> pumpRoutedApp(
    Widget widget, {
    List<Override> overrides = const [],
    SharedPreferences? prefs,
    List<RouteBase> routes = const [],
  }) async {
    final sharedPrefs = prefs ?? await _mockPrefs();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => widget,
        ),
        ...routes,
      ],
    );

    return pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ...overrides,
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: router,
        ),
      ),
    );
  }

  /// Creates a mock SharedPreferences with default test values.
  static Future<SharedPreferences> _mockPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues({
      'isLoggedIn': false,
      ...values,
    });
    return SharedPreferences.getInstance();
  }
}

/// Creates mock SharedPreferences for use in [ProviderContainer] tests.
///
/// ```dart
/// final prefs = await createMockPrefs({'isLoggedIn': true, 'token': 'abc'});
/// final container = ProviderContainer(overrides: [
///   sharedPreferencesProvider.overrideWithValue(prefs),
/// ]);
/// ```
Future<SharedPreferences> createMockPrefs([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues({
    'isLoggedIn': false,
    ...values,
  });
  return SharedPreferences.getInstance();
}