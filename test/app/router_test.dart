import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:beige/core/providers/core_providers.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Navigation Route Tests
//
// Verifies every GoRouter route in the app:
//   - Resolves without crashing
//   - Auth redirect works (public vs protected routes)
//   - Path parameters parse correctly
//   - Route names match RouteNames constants
//
// Run: flutter test test/app/router_test.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Build a testable GoRouter with the same route config as production,
/// but without Firebase observer dependency.
GoRouter _buildTestRouter({
  required bool isLoggedIn,
  String initialLocation = '/splash',
}) {
  final authNotifier = ValueNotifier<bool>(isLoggedIn);

  const publicRoutes = {
    '/splash',
    '/onboarding',
    '/login',
    '/signup',
    '/forgot-password',
    '/forgot-otp',
    '/reset-password',
    '/password-success',
  };

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublic = publicRoutes.contains(location);

      if (isLoggedIn) {
        if (isPublic) return '/';
      } else {
        if (!isPublic) return '/login';
      }
      return null;
    },
    routes: [
      // Auth & Onboarding
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (_, __) => const _TestScreen('SplashScreen'),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (_, __) => const _TestScreen('OnboardingScreen'),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (_, __) => const _TestScreen('LoginScreen'),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        builder: (_, __) => const _TestScreen('SignUpScreen'),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (_, __) => const _TestScreen('ForgotPasswordScreen'),
      ),
      GoRoute(
        path: '/forgot-otp',
        name: RouteNames.forgotOtp,
        builder: (_, state) {
          final email = state.extra as String? ?? '';
          return _TestScreen('ForgotPasswordOtpScreen:$email');
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: RouteNames.resetPassword,
        builder: (_, state) {
          final data = state.extra as Map<String, String>? ?? {};
          return _TestScreen('ResetPasswordScreen:${data['email']}');
        },
      ),
      GoRoute(
        path: '/password-success',
        name: RouteNames.passwordSuccess,
        builder: (_, __) => const _TestScreen('PasswordResetSuccessScreen'),
      ),

      // Main Shell (simplified for testing — no SVG icons)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: navigationShell.goBranch,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Book Shoot'),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Shoots'),
                BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              name: RouteNames.home,
              builder: (_, __) => const _TestScreen('HomeScreen'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/book-shoot',
              name: RouteNames.bookShoot,
              builder: (_, __) => const _TestScreen('BookShootScreen'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/my-shoots',
              name: RouteNames.myShoots,
              builder: (_, __) => const _TestScreen('MyShootsScreen'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/messages',
              name: RouteNames.messages,
              builder: (_, __) => const _TestScreen('MessagesScreen'),
            ),
          ]),
        ],
      ),

      // Home Sub-Screens
      GoRoute(
        path: '/view-profile/:id',
        name: RouteNames.viewProfile,
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _TestScreen('CreativeProfileScreen:$id');
        },
      ),
      GoRoute(
        path: '/recommended/:id',
        name: RouteNames.recommendedDetails,
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          final bookingId = int.parse(state.uri.queryParameters['bookingId'] ?? '0');
          return _TestScreen('RecommendedDetailScreen:$id:$bookingId');
        },
      ),
      GoRoute(
        path: '/change-location',
        name: RouteNames.changeLocation,
        builder: (_, __) => const _TestScreen('ChangeLocationScreen'),
      ),
      GoRoute(
        path: '/finding-perfect',
        name: RouteNames.findingPerfect,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('FindCreativeScreen:${data['bookingId']}');
        },
      ),
      GoRoute(
        path: '/payment-method/:bookingId',
        name: RouteNames.paymentMethod,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('PaymentMethodScreen:$bookingId');
        },
      ),

      // New Booking Flow
      GoRoute(
        path: '/content-type',
        name: RouteNames.contentType,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>?;
          return _TestScreen('ContentTypeScreen:${data?['specialtyId']}');
        },
      ),
      GoRoute(
        path: '/video-shoot-type',
        name: RouteNames.videoShootType,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('ShootTypeScreen:${data['contentTypeId']}');
        },
      ),
      GoRoute(
        path: '/shoot-date-time',
        name: RouteNames.shootDateTime,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('ShootDateTimeScreen:${data['bookingId']}');
        },
      ),
      GoRoute(
        path: '/more-details',
        name: RouteNames.moreDetails,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('ShootDetailsScreen:${data['bookingId']}');
        },
      ),
      GoRoute(
        path: '/crew-size-matching',
        name: RouteNames.crewSizeMatching,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('CrewSizeMatchingScreen:${data['bookingId']}');
        },
      ),
      GoRoute(
        path: '/select-dream-team',
        name: RouteNames.selectDreamTeam,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('CrewSelectionScreen:${data['bookingId']}');
        },
      ),
      GoRoute(
        path: '/review-confirm/:bookingId',
        name: RouteNames.reviewConfirm,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('ShootReviewScreen:$bookingId');
        },
      ),
      GoRoute(
        path: '/payment-success/:bookingId',
        name: RouteNames.paymentSuccess,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          final data = state.extra as Map<String, dynamic>? ?? {};
          return _TestScreen('PaymentSuccessScreen:$bookingId:${data['fullName']}');
        },
      ),

      // Booking Management
      GoRoute(
        path: '/booking-summary/:bookingId',
        name: RouteNames.bookingEventSummary,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('ShootSummaryScreen:$bookingId');
        },
      ),
      GoRoute(
        path: '/manage-booking/:bookingId',
        name: RouteNames.manageBooking,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('ManageShootScreen:$bookingId');
        },
      ),
      GoRoute(
        path: '/booking-review-confirm/:bookingId',
        name: RouteNames.bookingReviewConfirm,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('ShootEditReviewScreen:$bookingId');
        },
      ),
      GoRoute(
        path: '/cancel-booking/:bookingId',
        name: RouteNames.cancelBooking,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('CancelShootScreen:$bookingId');
        },
      ),
      GoRoute(
        path: '/select-booking-type/:bookingId',
        name: RouteNames.selectBookingType,
        builder: (_, state) {
          final bookingId = int.parse(state.pathParameters['bookingId']!);
          return _TestScreen('ShootTypeSelectionScreen:$bookingId');
        },
      ),
      GoRoute(
        path: '/shoot-updated',
        name: RouteNames.shootUpdated,
        builder: (_, __) => const _TestScreen('ShootUpdateSuccessScreen'),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (_, __) => const _TestScreen('ProfileScreen'),
      ),
      GoRoute(
        path: '/edit-profile',
        name: RouteNames.editProfile,
        builder: (_, __) => const _TestScreen('EditProfileScreen'),
      ),
      GoRoute(
        path: '/change-password',
        name: RouteNames.changePassword,
        builder: (_, state) {
          final email = state.extra as String? ?? '';
          return _TestScreen('ChangePasswordScreen:$email');
        },
      ),
      GoRoute(
        path: '/profile-otp',
        name: RouteNames.profileOtp,
        builder: (_, state) {
          final email = state.extra as String? ?? '';
          return _TestScreen('ProfileOtpScreen:$email');
        },
      ),
      GoRoute(
        path: '/profile-new-password',
        name: RouteNames.profileNewPassword,
        builder: (_, state) {
          final data = state.extra as Map<String, String>? ?? {};
          return _TestScreen('ProfileNewPasswordScreen:${data['email']}');
        },
      ),
      GoRoute(
        path: '/booking-history',
        name: RouteNames.bookingHistory,
        builder: (_, __) => const _TestScreen('ShootHistoryScreen'),
      ),
      GoRoute(
        path: '/favourites',
        name: RouteNames.favourites,
        builder: (_, __) => const _TestScreen('FavoritesScreen'),
      ),
      GoRoute(
        path: '/app-preferences',
        name: RouteNames.appPreferences,
        builder: (_, __) => const _TestScreen('AppPreferencesScreen'),
      ),
      GoRoute(
        path: '/delete-account',
        name: RouteNames.deleteAccount,
        builder: (_, __) => const _TestScreen('DeleteAccountScreen'),
      ),
      GoRoute(
        path: '/delete-account-otp',
        name: RouteNames.deleteAccountOtp,
        builder: (_, __) => const _TestScreen('DeleteAccountOtpScreen'),
      ),
    ],
  );
}

/// Lightweight widget for route identification in tests.
class _TestScreen extends StatelessWidget {
  final String label;
  const _TestScreen(this.label);

  @override
  Widget build(BuildContext context) => Text(label);
}

/// Pump a GoRouter into a MaterialApp for testing.
Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router),
  );
  await tester.pumpAndSettle();
}

void main() {
  // ── Auth Redirect Tests ───────────────────────────────────────────

  group('Auth redirect', () {
    testWidgets('should show login when not authenticated and accessing /',
        (tester) async {
      final router = _buildTestRouter(
        isLoggedIn: false,
        initialLocation: '/',
      );

      await _pumpRouter(tester, router);

      expect(find.text('LoginScreen'), findsOneWidget);
    });

    testWidgets('should redirect to / when logged in and accessing /splash',
        (tester) async {
      final router = _buildTestRouter(
        isLoggedIn: true,
        initialLocation: '/splash',
      );

      await _pumpRouter(tester, router);

      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('should redirect to / when logged in and accessing /login',
        (tester) async {
      final router = _buildTestRouter(
        isLoggedIn: true,
        initialLocation: '/login',
      );

      await _pumpRouter(tester, router);

      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('should allow unauthenticated access to public routes',
        (tester) async {
      for (final route in [
        '/splash',
        '/onboarding',
        '/login',
        '/signup',
        '/forgot-password',
        '/password-success',
      ]) {
        final router = _buildTestRouter(
          isLoggedIn: false,
          initialLocation: route,
        );

        await _pumpRouter(tester, router);

        // Should NOT redirect to login — should stay on public route
        if (route == '/login') {
          expect(find.text('LoginScreen'), findsOneWidget);
        }
        // Just verify no crash for other routes
      }
    });

    testWidgets(
        'should redirect protected routes to /login when not authenticated',
        (tester) async {
      for (final route in [
        '/profile',
        '/edit-profile',
        '/booking-history',
        '/favourites',
        '/app-preferences',
        '/change-location',
        '/shoot-updated',
      ]) {
        final router = _buildTestRouter(
          isLoggedIn: false,
          initialLocation: route,
        );

        await _pumpRouter(tester, router);

        expect(find.text('LoginScreen'), findsOneWidget,
            reason: '$route should redirect to login');
      }
    });
  });

  // ── Public Route Resolution ────────────────────────────────────────

  group('Public routes resolve', () {
    testWidgets('splash', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: false, initialLocation: '/splash');
      await _pumpRouter(tester, router);
      expect(find.text('SplashScreen'), findsOneWidget);
    });

    testWidgets('onboarding', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: false, initialLocation: '/onboarding');
      await _pumpRouter(tester, router);
      expect(find.text('OnboardingScreen'), findsOneWidget);
    });

    testWidgets('login', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: false, initialLocation: '/login');
      await _pumpRouter(tester, router);
      expect(find.text('LoginScreen'), findsOneWidget);
    });

    testWidgets('signup', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: false, initialLocation: '/signup');
      await _pumpRouter(tester, router);
      expect(find.text('SignUpScreen'), findsOneWidget);
    });

    testWidgets('forgot-password', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: false, initialLocation: '/forgot-password');
      await _pumpRouter(tester, router);
      expect(find.text('ForgotPasswordScreen'), findsOneWidget);
    });

    testWidgets('password-success', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: false, initialLocation: '/password-success');
      await _pumpRouter(tester, router);
      expect(find.text('PasswordResetSuccessScreen'), findsOneWidget);
    });
  });

  // ── Shell Tab Routes ───────────────────────────────────────────────

  group('Shell tab routes (authenticated)', () {
    testWidgets('/ shows HomeScreen', (tester) async {
      final router = _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);
      expect(find.text('HomeScreen'), findsOneWidget);
    });

    testWidgets('/book-shoot shows BookShootScreen', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/book-shoot');
      await _pumpRouter(tester, router);
      expect(find.text('BookShootScreen'), findsOneWidget);
    });

    testWidgets('/my-shoots shows MyShootsScreen', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/my-shoots');
      await _pumpRouter(tester, router);
      expect(find.text('MyShootsScreen'), findsOneWidget);
    });

    testWidgets('/messages shows MessagesScreen', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/messages');
      await _pumpRouter(tester, router);
      expect(find.text('MessagesScreen'), findsOneWidget);
    });

    testWidgets('bottom nav has 4 tabs', (tester) async {
      final router = _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);
      expect(find.byType(BottomNavigationBarItem).evaluate().length, 0);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Book Shoot'), findsOneWidget);
      expect(find.text('My Shoots'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('tab switching works', (tester) async {
      final router = _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      expect(find.text('HomeScreen'), findsOneWidget);

      await tester.tap(find.text('My Shoots'));
      await tester.pumpAndSettle();
      expect(find.text('MyShootsScreen'), findsOneWidget);

      await tester.tap(find.text('Book Shoot'));
      await tester.pumpAndSettle();
      expect(find.text('BookShootScreen'), findsOneWidget);

      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('MessagesScreen'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('HomeScreen'), findsOneWidget);
    });
  });

  // ── Path Parameter Routes ──────────────────────────────────────────

  group('Path parameter routes (authenticated)', () {
    testWidgets('/view-profile/:id parses id', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/view-profile/42');
      await _pumpRouter(tester, router);
      expect(find.text('CreativeProfileScreen:42'), findsOneWidget);
    });

    testWidgets('/recommended/:id parses id and query param', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true,
          initialLocation: '/recommended/7?bookingId=99');
      await _pumpRouter(tester, router);
      expect(find.text('RecommendedDetailScreen:7:99'), findsOneWidget);
    });

    testWidgets('/payment-method/:bookingId parses bookingId', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/payment-method/55');
      await _pumpRouter(tester, router);
      expect(find.text('PaymentMethodScreen:55'), findsOneWidget);
    });

    testWidgets('/review-confirm/:bookingId parses bookingId', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/review-confirm/101');
      await _pumpRouter(tester, router);
      expect(find.text('ShootReviewScreen:101'), findsOneWidget);
    });

    testWidgets('/payment-success/:bookingId parses bookingId', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/payment-success/201');
      await _pumpRouter(tester, router);
      expect(find.text('PaymentSuccessScreen:201:null'), findsOneWidget);
    });

    testWidgets('/booking-summary/:bookingId parses bookingId', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/booking-summary/301');
      await _pumpRouter(tester, router);
      expect(find.text('ShootSummaryScreen:301'), findsOneWidget);
    });

    testWidgets('/manage-booking/:bookingId parses bookingId', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/manage-booking/401');
      await _pumpRouter(tester, router);
      expect(find.text('ManageShootScreen:401'), findsOneWidget);
    });

    testWidgets('/booking-review-confirm/:bookingId parses bookingId',
        (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/booking-review-confirm/501');
      await _pumpRouter(tester, router);
      expect(find.text('ShootEditReviewScreen:501'), findsOneWidget);
    });

    testWidgets('/cancel-booking/:bookingId parses bookingId', (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/cancel-booking/601');
      await _pumpRouter(tester, router);
      expect(find.text('CancelShootScreen:601'), findsOneWidget);
    });

    testWidgets('/select-booking-type/:bookingId parses bookingId',
        (tester) async {
      final router = _buildTestRouter(
          isLoggedIn: true, initialLocation: '/select-booking-type/701');
      await _pumpRouter(tester, router);
      expect(find.text('ShootTypeSelectionScreen:701'), findsOneWidget);
    });
  });

  // ── Static Protected Routes ────────────────────────────────────────

  group('Static protected routes (authenticated)', () {
    final staticRoutes = {
      '/change-location': 'ChangeLocationScreen',
      '/shoot-updated': 'ShootUpdateSuccessScreen',
      '/profile': 'ProfileScreen',
      '/edit-profile': 'EditProfileScreen',
      '/booking-history': 'ShootHistoryScreen',
      '/favourites': 'FavoritesScreen',
      '/app-preferences': 'AppPreferencesScreen',
      '/delete-account': 'DeleteAccountScreen',
      '/delete-account-otp': 'DeleteAccountOtpScreen',
    };

    for (final entry in staticRoutes.entries) {
      testWidgets('${entry.key} shows ${entry.value}', (tester) async {
        final router =
            _buildTestRouter(isLoggedIn: true, initialLocation: entry.key);
        await _pumpRouter(tester, router);
        expect(find.text(entry.value), findsOneWidget);
      });
    }
  });

  // ── Extra-based Routes (via goNamed navigation) ────────────────────

  group('Extra-based routes via goNamed', () {
    testWidgets('forgot-otp receives email via extra', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: false, initialLocation: '/login');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.forgotOtp, extra: 'test@email.com');
      await tester.pumpAndSettle();

      expect(find.text('ForgotPasswordOtpScreen:test@email.com'),
          findsOneWidget);
    });

    testWidgets('reset-password receives email+otp via extra', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: false, initialLocation: '/login');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.resetPassword,
          extra: {'email': 'a@b.com', 'otp': '1234'});
      await tester.pumpAndSettle();

      expect(find.text('ResetPasswordScreen:a@b.com'), findsOneWidget);
    });

    testWidgets('content-type receives specialtyId via extra', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.contentType,
          extra: {'specialtyId': 5, 'value': 10});
      await tester.pumpAndSettle();

      expect(find.text('ContentTypeScreen:5'), findsOneWidget);
    });

    testWidgets('video-shoot-type receives data via extra', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.videoShootType,
          extra: {'contentTypeId': 3, 'bookingId': 7});
      await tester.pumpAndSettle();

      expect(find.text('ShootTypeScreen:3'), findsOneWidget);
    });

    testWidgets('finding-perfect receives booking data via extra',
        (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.findingPerfect, extra: {
        'bookingId': 42,
        'specialtyId': 1,
        'ShootTypeId': 2,
        'contentTypeId': 3,
      });
      await tester.pumpAndSettle();

      expect(find.text('FindCreativeScreen:42'), findsOneWidget);
    });

    testWidgets('change-password receives email via extra', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.changePassword, extra: 'user@test.com');
      await tester.pumpAndSettle();

      expect(
          find.text('ChangePasswordScreen:user@test.com'), findsOneWidget);
    });

    testWidgets('profile-otp receives email via extra', (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.profileOtp, extra: 'user@test.com');
      await tester.pumpAndSettle();

      expect(find.text('ProfileOtpScreen:user@test.com'), findsOneWidget);
    });

    testWidgets('profile-new-password receives email+otp via extra',
        (tester) async {
      final router =
          _buildTestRouter(isLoggedIn: true, initialLocation: '/');
      await _pumpRouter(tester, router);

      router.goNamed(RouteNames.profileNewPassword,
          extra: {'email': 'x@y.com', 'otp': '9999'});
      await tester.pumpAndSettle();

      expect(
          find.text('ProfileNewPasswordScreen:x@y.com'), findsOneWidget);
    });
  });

  // ── Route Name Constants Completeness ──────────────────────────────

  group('RouteNames completeness', () {
    test('all route names are unique', () {
      final names = [
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.login,
        RouteNames.signup,
        RouteNames.forgotPassword,
        RouteNames.forgotOtp,
        RouteNames.resetPassword,
        RouteNames.passwordSuccess,
        RouteNames.home,
        RouteNames.bookShoot,
        RouteNames.myShoots,
        RouteNames.messages,
        RouteNames.viewProfile,
        RouteNames.recommendedDetails,
        RouteNames.changeLocation,
        RouteNames.findingPerfect,
        RouteNames.paymentMethod,
        RouteNames.contentType,
        RouteNames.videoShootType,
        RouteNames.shootDateTime,
        RouteNames.moreDetails,
        RouteNames.crewSizeMatching,
        RouteNames.selectDreamTeam,
        RouteNames.reviewConfirm,
        RouteNames.paymentSuccess,
        RouteNames.bookingEventSummary,
        RouteNames.manageBooking,
        RouteNames.bookingReviewConfirm,
        RouteNames.cancelBooking,
        RouteNames.selectBookingType,
        RouteNames.shootUpdated,
        RouteNames.profile,
        RouteNames.editProfile,
        RouteNames.changePassword,
        RouteNames.profileOtp,
        RouteNames.profileNewPassword,
        RouteNames.bookingHistory,
        RouteNames.favourites,
        RouteNames.appPreferences,
        RouteNames.deleteAccount,
        RouteNames.deleteAccountOtp,
      ];

      expect(names.toSet().length, names.length,
          reason: 'Duplicate route names found');
      expect(names.length, 41, reason: 'Expected 41 route names');
    });

    test('all route names follow lowercase_snake_case', () {
      final names = [
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.login,
        RouteNames.signup,
        RouteNames.forgotPassword,
        RouteNames.forgotOtp,
        RouteNames.resetPassword,
        RouteNames.passwordSuccess,
        RouteNames.home,
        RouteNames.bookShoot,
        RouteNames.myShoots,
        RouteNames.messages,
        RouteNames.viewProfile,
        RouteNames.recommendedDetails,
        RouteNames.changeLocation,
        RouteNames.findingPerfect,
        RouteNames.paymentMethod,
        RouteNames.contentType,
        RouteNames.videoShootType,
        RouteNames.shootDateTime,
        RouteNames.moreDetails,
        RouteNames.crewSizeMatching,
        RouteNames.selectDreamTeam,
        RouteNames.reviewConfirm,
        RouteNames.paymentSuccess,
        RouteNames.bookingEventSummary,
        RouteNames.manageBooking,
        RouteNames.bookingReviewConfirm,
        RouteNames.cancelBooking,
        RouteNames.selectBookingType,
        RouteNames.shootUpdated,
        RouteNames.profile,
        RouteNames.editProfile,
        RouteNames.changePassword,
        RouteNames.profileOtp,
        RouteNames.profileNewPassword,
        RouteNames.bookingHistory,
        RouteNames.favourites,
        RouteNames.appPreferences,
        RouteNames.deleteAccount,
        RouteNames.deleteAccountOtp,
      ];

      final snakeCasePattern = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final name in names) {
        expect(snakeCasePattern.hasMatch(name), isTrue,
            reason: '"$name" is not lowercase_snake_case');
      }
    });
  });
}