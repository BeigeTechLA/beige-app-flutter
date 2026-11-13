import 'package:beige/app/app.dart';
import 'package:beige/config/env.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

bool _firebaseInitialized = false;

/// Bounded replacement for `pumpAndSettle`. Screens backed by the live API
/// can show a spinner/Lottie forever (e.g. fake test token → request fails or
/// never resolves), so an unbounded settle hangs the whole suite. Pump for at
/// most [max], then let the caller inspect whatever rendered.
Future<void> settle(
  WidgetTester tester, {
  Duration max = const Duration(seconds: 5),
}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      max,
    );
  } on FlutterError {
    // Still animating after [max] — the screen is mounted; carry on.
  }
}

/// Ensures Firebase is initialized once for the test session.
/// Required because [routerProvider] uses [AnalyticsService.observer].
Future<void> ensureFirebaseInitialized() async {
  if (_firebaseInitialized) return;
  // firebase_options.dart and the app read Env.current for per-environment
  // config. The real entry points call this in startApp(); the test harness
  // pumps App() directly, so init it here (dev) before touching Firebase.
  Env.init(Environment.dev);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _firebaseInitialized = true;
}

/// Pumps the app with an overridden auth state.
///
/// [isLoggedIn] controls the auth state via SharedPreferences.
/// The [authStateProvider] reads from [sharedPreferencesProvider],
/// so we override SharedPreferences with the desired login state.
///
/// Pass any additional overrides via [extraOverrides].
Future<void> pumpAppWithAuth(
  WidgetTester tester, {
  required bool isLoggedIn,
  List<Override> extraOverrides = const [],
}) async {
  await ensureFirebaseInitialized();

  SharedPreferences.setMockInitialValues({
    'isLoggedIn': isLoggedIn,
    if (isLoggedIn) 'token': 'fake-test-token',
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...extraOverrides,
      ],
      child: const App(),
    ),
  );
  await settle(tester);
}

/// Navigates to [path] using GoRouter and waits for settle.
Future<NavResult> navigateTo(
  WidgetTester tester,
  String path, {
  Object? extra,
}) async {
  try {
    final context = tester.element(find.byType(Router).first);
    GoRouter.of(context).go(path, extra: extra);
    await settle(tester);
    return NavResult(route: path, checkType: 'navigate', passed: true);
  } catch (e) {
    return NavResult(
      route: path,
      checkType: 'navigate',
      passed: false,
      error: e.toString(),
    );
  }
}

/// Verifies that the current screen rendered without crashing
/// by checking that no [ErrorWidget] is present.
Future<NavResult> verifyScreenLoaded(WidgetTester tester, String route) async {
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
    final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
    return NavResult(
      route: route,
      checkType: 'screen_load',
      passed: hasContent,
      error: hasContent
          ? null
          : 'No Scaffold found — screen may not have loaded',
    );
  } catch (e) {
    return NavResult(
      route: route,
      checkType: 'screen_load',
      passed: false,
      error: e.toString(),
    );
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
    await settle(tester);

    final router = GoRouter.of(context);
    final currentLocation = router.routerDelegate.currentConfiguration.uri
        .toString();
    final redirected = currentLocation.startsWith(expectedRedirect);

    return NavResult(
      route: protectedPath,
      checkType: 'auth_guard',
      passed: redirected,
      error: redirected
          ? null
          : 'Expected redirect to $expectedRedirect, got $currentLocation',
    );
  } catch (e) {
    return NavResult(
      route: protectedPath,
      checkType: 'auth_guard',
      passed: false,
      error: e.toString(),
    );
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
    await settle(tester);

    final hasError = find.byType(ErrorWidget).evaluate().isNotEmpty;
    return NavResult(
      route: deepLinkUri,
      checkType: 'deep_link',
      passed: !hasError,
      error: hasError ? 'ErrorWidget after deep link navigation' : null,
    );
  } catch (e) {
    return NavResult(
      route: deepLinkUri,
      checkType: 'deep_link',
      passed: false,
      error: e.toString(),
    );
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

    GoRouter.of(context).go(previousPath);
    await settle(tester);

    GoRouter.of(context).push(path);
    await settle(tester);

    GoRouter.of(context).pop();
    await settle(tester);

    final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
    return NavResult(
      route: path,
      checkType: 'back_nav',
      passed: hasScaffold,
      error: hasScaffold ? null : 'Screen after pop has no Scaffold',
    );
  } catch (e) {
    return NavResult(
      route: path,
      checkType: 'back_nav',
      passed: false,
      error: e.toString(),
    );
  }
}
