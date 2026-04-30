import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_helper.dart';
import '../helpers/navigation_helper.dart';
import '../helpers/report_builder.dart';

/// Protected routes that must redirect to /login when unauthenticated.
/// Path parameters use fake IDs that won't hit real APIs.
const _guardedRoutes = [
  ('home', '/'),
  ('book_shoot', '/book-shoot'),
  ('my_shoots', '/my-shoots'),
  ('messages', '/messages'),
  ('view_profile', '/view-profile/1'),
  ('change_location', '/change-location'),
  ('content_type', '/content-type'),
  ('video_shoot_type', '/video-shoot-type'),
  ('shoot_date_time', '/shoot-date-time'),
  ('more_details', '/more-details'),
  ('crew_size_matching', '/crew-size-matching'),
  ('select_dream_team', '/select-dream-team'),
  ('review_confirm', '/review-confirm/999'),
  ('payment_success', '/payment-success/999'),
  ('booking_event_summary', '/booking-summary/999'),
  ('manage_booking', '/manage-booking/999'),
  ('booking_review_confirm', '/booking-review-confirm/999'),
  ('cancel_booking', '/cancel-booking/999'),
  ('select_booking_type', '/select-booking-type/999'),
  ('shoot_updated', '/shoot-updated'),
  ('profile', '/profile'),
  ('edit_profile', '/edit-profile'),
  ('change_password', '/change-password'),
  ('profile_otp', '/profile-otp'),
  ('booking_history', '/booking-history'),
  ('favourites', '/favourites'),
  ('app_preferences', '/app-preferences'),
  ('delete_account', '/delete-account'),
  ('delete_account_otp', '/delete-account-otp'),
  ('payment_method', '/payment-method/999'),
  ('finding_perfect', '/finding-perfect'),
  ('recommended_details', '/recommended/1'),
];

void runGuardTests(ReportBuilder report) {
  group('Auth Guard Tests — unauthenticated should redirect to /login', () {
    for (final (name, path) in _guardedRoutes) {
      testWidgets('$name redirects unauthenticated user to /login', (tester) async {
        // Pump app with logged-out state
        await pumpAppWithAuth(
          tester,
          isLoggedIn: false,
          extraOverrides: loggedOutOverrides(),
        );

        final guardResult = await verifyAuthGuard(
          tester,
          path,
          expectedRedirect: '/login',
        );

        // Record into report — guard only, no load result here
        report.record(
          route: path,
          routeName: name,
          guardResult: guardResult,
        );

        expect(
          guardResult.passed,
          isTrue,
          reason: 'Guard failed for $path: ${guardResult.error}',
        );
      });
    }
  });

  group('Auth Guard Tests — authenticated user should NOT be redirected from protected routes', () {
    const _authProtectedRoutes = [
      ('home', '/'),
      ('profile', '/profile'),
      ('my_shoots', '/my-shoots'),
      ('booking_history', '/booking-history'),
    ];

    for (final (name, path) in _authProtectedRoutes) {
      testWidgets('$name is accessible when authenticated', (tester) async {
        await pumpAppWithAuth(
          tester,
          isLoggedIn: true,
          extraOverrides: loggedInOverrides(),
        );

        await navigateTo(tester, path);
        final loadResult = await verifyScreenLoaded(tester, path);

        report.record(
          route: path,
          routeName: '${name}_auth_accessible',
          loadResult: loadResult,
        );

        expect(
          loadResult.passed,
          isTrue,
          reason: 'Authenticated user could not access $path: ${loadResult.error}',
        );
      });
    }
  });

  group('Auth Guard Tests — logged in user redirected away from public routes', () {
    const _publicAuthRoutes = [
      ('login', '/login'),
      ('signup', '/signup'),
      ('onboarding', '/onboarding'),
    ];

    for (final (name, path) in _publicAuthRoutes) {
      testWidgets('$name redirects authenticated user to /', (tester) async {
        await pumpAppWithAuth(
          tester,
          isLoggedIn: true,
          extraOverrides: loggedInOverrides(),
        );

        final guardResult = await verifyAuthGuard(
          tester,
          path,
          expectedRedirect: '/',
        );

        report.record(
          route: path,
          routeName: '${name}_reverse_guard',
          guardResult: guardResult,
        );

        expect(
          guardResult.passed,
          isTrue,
          reason: 'Authenticated user was not redirected away from $path',
        );
      });
    }
  });
}
