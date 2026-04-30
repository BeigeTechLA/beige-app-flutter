import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Result of a single navigation verification step.
class NavResult {
  final String route;
  final String checkType;
  final bool passed;
  final String? error;

  const NavResult({
    required this.route,
    required this.checkType,
    required this.passed,
    this.error,
  });
}

/// Pumps the app with an overridden auth state.
///
/// [isLoggedIn] controls the value injected into [authStateProvider].
/// Import your actual app widget and providers here.
Future<void> pumpAppWithAuth(
  WidgetTester tester, {
  required bool isLoggedIn,
  List<Override> extraOverrides = const [],
}) async {
  // Replace `YourApp` with your actual root widget import.
  // Replace `authStateProvider` with your actual provider.
  //
  // Example:
  //   import '../../lib/app/app.dart';
  //   import '../../lib/core/providers/auth_state_provider.dart';
  //
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // authStateProvider.overrideWithValue(isLoggedIn),
        ...extraOverrides,
      ],
      // child: const YourApp(),
      child: const Placeholder(), // ← Replace with your App widget
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

/// Navigates to [path] using GoRouter context push and waits for settle.
Future<NavResult> navigateTo(
  WidgetTester tester,
  String path, {
  Object? extra,
}) async {
  try {
    final context = tester.element(find.byType(Router).first);
    GoRouter.of(context).go(path, extra: extra);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    return NavResult(route: path, checkType: 'navigate', passed: true);
  } catch (e) {
    return NavResult(route: path, checkType: 'navigate', passed: false, error: e.toString());
  }
}

/// Verifies that the current screen rendered without crashing
/// by checking that no [ErrorWidget] is present.
Future<NavResult> verifyScreenLoaded(
  WidgetTester tester,
  String route,
) async {
  try {
    final hasError = find.byType(ErrorWidget).evaluate().isNotEmpty;
    if (hasError) {
      return NavResult(
        route: route,
        checkType: 'screen_load',
        passed: false,
        error: 'ErrorWidget found on screen',
      );
    }
    // Also check app isn't showing a blank scaffold with no content
    final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
    return NavResult(
      route: route,
      checkType: 'screen_load',
      passed: hasContent,
      error: hasContent ? null : 'No Scaffold found — screen may not have loaded',
    );
  } catch (e) {
    return NavResult(route: route, checkType: 'screen_load', passed: false, error: e.toString());
  }
}

/// Verifies that navigating to [protectedPath] while unauthenticated
/// redirects to [expectedRedirect] (default: '/login').
Future<NavResult> verifyAuthGuard(
  WidgetTester tester,
  String protectedPath, {
  String expectedRedirect = '/login',
}) async {
  try {
    final context = tester.element(find.byType(Router).first);
    GoRouter.of(context).go(protectedPath);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final router = GoRouter.of(context);
    final currentLocation = router.routerDelegate.currentConfiguration.uri.toString();
    final redirected = currentLocation.startsWith(expectedRedirect);

    return NavResult(
      route: protectedPath,
      checkType: 'auth_guard',
      passed: redirected,
      error: redirected ? null : 'Expected redirect to $expectedRedirect, got $currentLocation',
    );
  } catch (e) {
    return NavResult(route: protectedPath, checkType: 'auth_guard', passed: false, error: e.toString());
  }
}

/// Verifies that navigating to [deepLinkUri] resolves without crash.
Future<NavResult> verifyDeepLink(
  WidgetTester tester,
  String deepLinkUri,
) async {
  try {
    final context = tester.element(find.byType(Router).first);
    GoRouter.of(context).go(deepLinkUri);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final hasError = find.byType(ErrorWidget).evaluate().isNotEmpty;
    return NavResult(
      route: deepLinkUri,
      checkType: 'deep_link',
      passed: !hasError,
      error: hasError ? 'ErrorWidget after deep link navigation' : null,
    );
  } catch (e) {
    return NavResult(route: deepLinkUri, checkType: 'deep_link', passed: false, error: e.toString());
  }
}

/// Navigates to [path], then pops back and verifies the previous
/// screen is restored (checks for [Scaffold] presence).
Future<NavResult> verifyBackNav(
  WidgetTester tester,
  String path,
  String previousPath,
) async {
  try {
    final context = tester.element(find.byType(Router).first);

    // Go to previous screen first
    GoRouter.of(context).go(previousPath);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Push target screen
    GoRouter.of(context).push(path);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Pop back
    GoRouter.of(context).pop();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
    return NavResult(
      route: path,
      checkType: 'back_nav',
      passed: hasScaffold,
      error: hasScaffold ? null : 'Screen after pop has no Scaffold',
    );
  } catch (e) {
    return NavResult(route: path, checkType: 'back_nav', passed: false, error: e.toString());
  }
}
