import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_helper.dart';
import '../helpers/navigation_helper.dart';
import '../helpers/report_builder.dart';

/// Back nav test pairs: (name, targetPath, previousPath)
/// previousPath is the screen the user is on BEFORE navigating to target.
/// After pop, the test verifies previousPath screen is restored.
const _backNavPairs = [
  // From home → sub-screens → back to home
  ('view_profile_back', '/view-profile/1', '/'),
  ('change_location_back', '/change-location', '/'),
  ('recommended_details_back', '/recommended/1?bookingId=0', '/'),

  // Booking flow back nav
  ('content_type_back', '/content-type', '/'),
  ('video_shoot_type_back', '/video-shoot-type', '/content-type'),
  ('shoot_date_time_back', '/shoot-date-time', '/video-shoot-type'),
  ('more_details_back', '/more-details', '/shoot-date-time'),
  ('crew_size_matching_back', '/crew-size-matching', '/more-details'),
  ('select_dream_team_back', '/select-dream-team', '/crew-size-matching'),
  ('review_confirm_back', '/review-confirm/999', '/select-dream-team'),

  // Booking management back nav
  ('manage_booking_back', '/manage-booking/999', '/my-shoots'),
  ('cancel_booking_back', '/cancel-booking/999', '/manage-booking/999'),
  (
    'booking_review_confirm_back',
    '/booking-review-confirm/999',
    '/manage-booking/999',
  ),
  (
    'select_booking_type_back',
    '/select-booking-type/999',
    '/manage-booking/999',
  ),

  // Profile sub-screens back nav
  ('edit_profile_back', '/edit-profile', '/profile'),
  ('change_password_back', '/change-password', '/profile'),
  ('booking_history_back', '/booking-history', '/profile'),
  ('favourites_back', '/favourites', '/profile'),
  ('app_preferences_back', '/app-preferences', '/profile'),
  ('delete_account_back', '/delete-account', '/profile'),
  ('delete_account_otp_back', '/delete-account-otp', '/delete-account'),

  // Auth flow back nav
  ('forgot_otp_back', '/forgot-otp', '/forgot-password'),
  ('reset_password_back', '/reset-password', '/forgot-otp'),
];

void runBackNavTests(ReportBuilder report) {
  group('Back Navigation Tests', () {
    for (final (name, targetPath, previousPath) in _backNavPairs) {
      testWidgets('$name — pop from $targetPath returns to $previousPath', (
        tester,
      ) async {
        await pumpAppWithAuth(
          tester,
          isLoggedIn: true,
          extraOverrides: loggedInOverrides(),
        );

        final result = await verifyBackNav(tester, targetPath, previousPath);

        report.record(
          route: targetPath,
          routeName: name,
          backNavResult: result,
        );

        expect(
          result.passed,
          isTrue,
          reason:
              'Back nav failed for $targetPath → $previousPath: ${result.error}',
        );
      });
    }
  });
}
