import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_helper.dart';
import '../helpers/navigation_helper.dart';
import '../helpers/report_builder.dart';

/// Deep link URIs derived from actual GoRouter path patterns.
/// Path parameters use safe fake IDs.
/// Routes with `state.extra` params are tested with default fallbacks
/// since GoRouter ignores extra when navigating via URI directly.
const _deepLinks = [
  // Public
  ('splash_deep', '/splash'),
  ('onboarding_deep', '/onboarding'),
  ('login_deep', '/login'),
  ('signup_deep', '/signup'),
  ('forgot_password_deep', '/forgot-password'),
  ('forgot_otp_deep', '/forgot-otp'),
  ('reset_password_deep', '/reset-password'),
  ('password_success_deep', '/password-success'),

  // Shell tabs
  ('home_deep', '/'),
  ('book_shoot_deep', '/book-shoot'),
  ('my_shoots_deep', '/my-shoots'),
  ('messages_deep', '/messages'),

  // Parameterized routes — using fake IDs
  ('view_profile_deep', '/view-profile/1'),
  ('recommended_details_deep', '/recommended/1?bookingId=0'),
  ('payment_method_deep', '/payment-method/999'),
  ('review_confirm_deep', '/review-confirm/999'),
  ('payment_success_deep', '/payment-success/999'),
  ('booking_summary_deep', '/booking-summary/999'),
  ('manage_booking_deep', '/manage-booking/999'),
  ('booking_review_confirm_deep', '/booking-review-confirm/999'),
  ('cancel_booking_deep', '/cancel-booking/999'),
  ('select_booking_type_deep', '/select-booking-type/999'),

  // Simple protected routes
  ('change_location_deep', '/change-location'),
  ('finding_perfect_deep', '/finding-perfect'),
  ('content_type_deep', '/content-type'),
  ('video_shoot_type_deep', '/video-shoot-type'),
  ('shoot_date_time_deep', '/shoot-date-time'),
  ('more_details_deep', '/more-details'),
  ('crew_size_matching_deep', '/crew-size-matching'),
  ('select_dream_team_deep', '/select-dream-team'),
  ('shoot_updated_deep', '/shoot-updated'),
  ('profile_deep', '/profile'),
  ('edit_profile_deep', '/edit-profile'),
  ('change_password_deep', '/change-password'),
  ('profile_otp_deep', '/profile-otp'),
  ('profile_new_password_deep', '/profile-new-password'),
  ('booking_history_deep', '/booking-history'),
  ('favourites_deep', '/favourites'),
  ('app_preferences_deep', '/app-preferences'),
  ('delete_account_deep', '/delete-account'),
  ('delete_account_otp_deep', '/delete-account-otp'),
];

void runDeepLinkTests(ReportBuilder report) {
  group('Deep Link Tests — authenticated', () {
    for (final (name, uri) in _deepLinks) {
      testWidgets('$name resolves via deep link', (tester) async {
        // Public routes tested logged-out; protected routes logged-in
        final isPublic = _publicPaths.contains(uri.split('?').first);

        await pumpAppWithAuth(
          tester,
          isLoggedIn: !isPublic,
          extraOverrides: isPublic ? loggedOutOverrides() : loggedInOverrides(),
        );

        final result = await verifyDeepLink(tester, uri);

        report.record(
          route: uri,
          routeName: name,
          deepLinkResult: result,
        );

        expect(
          result.passed,
          isTrue,
          reason: 'Deep link $uri failed: ${result.error}',
        );
      });
    }
  });
}

/// Paths that are publicly accessible without auth.
const _publicPaths = {
  '/splash',
  '/onboarding',
  '/login',
  '/signup',
  '/forgot-password',
  '/forgot-otp',
  '/reset-password',
  '/password-success',
};
