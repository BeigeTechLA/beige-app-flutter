import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_helper.dart';
import '../helpers/navigation_helper.dart';
import '../helpers/report_builder.dart';

/// All routes that require authentication (protected routes).
/// Derived from router.dart — everything NOT in _publicRoutes.
const _protectedRoutes = [
  ('home', '/'),
  ('book_shoot', '/book-shoot'),
  ('my_shoots', '/my-shoots'),
  ('messages', '/messages'),
  ('view_profile', '/view-profile/1'),
  ('recommended_details', '/recommended/1?bookingId=0'),
  ('change_location', '/change-location'),
  ('finding_perfect', '/finding-perfect'),
  ('payment_method', '/payment-method/999'),
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
  ('profile_new_password', '/profile-new-password'),
  ('booking_history', '/booking-history'),
  ('favourites', '/favourites'),
  ('app_preferences', '/app-preferences'),
  ('delete_account', '/delete-account'),
  ('delete_account_otp', '/delete-account-otp'),
];

/// Public routes — no auth required.
const _publicRoutes = [
  ('splash', '/splash'),
  ('onboarding', '/onboarding'),
  ('login', '/login'),
  ('signup', '/signup'),
  ('forgot_password', '/forgot-password'),
  ('forgot_otp', '/forgot-otp'),
  ('reset_password', '/reset-password'),
  ('password_success', '/password-success'),
];

void runRouteLoadTests(ReportBuilder report) {
  group('Route Load Tests — Public Routes', () {
    for (final (name, path) in _publicRoutes) {
      testWidgets('$name loads without crash', (tester) async {
        await pumpAppWithAuth(tester, isLoggedIn: false, extraOverrides: loggedOutOverrides());

        final navResult = await navigateTo(tester, path);
        final loadResult = await verifyScreenLoaded(tester, path);

        report.record(
          route: path,
          routeName: name,
          loadResult: loadResult,
        );

        expect(loadResult.passed, isTrue,
            reason: 'Route $path failed to load: ${loadResult.error}');
      });
    }
  });

  group('Route Load Tests — Protected Routes (authenticated)', () {
    for (final (name, path) in _protectedRoutes) {
      testWidgets('$name loads without crash', (tester) async {
        await pumpAppWithAuth(tester, isLoggedIn: true, extraOverrides: loggedInOverrides());

        final navResult = await navigateTo(tester, path);
        final loadResult = await verifyScreenLoaded(tester, path);

        report.record(
          route: path,
          routeName: name,
          loadResult: loadResult,
        );

        expect(loadResult.passed, isTrue,
            reason: 'Route $path failed to load: ${loadResult.error}');
      });
    }
  });
}
