import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_helper.dart';
import '../helpers/navigation_helper.dart';
import '../helpers/report_builder.dart';

/// All routes that require authentication (protected routes).
/// Derived from router.dart — everything NOT in _publicRoutes.
const _protectedRoutes = [
  ('home', '/', null),
  ('book_shoot', '/book-shoot', null),
  ('my_shoots', '/my-shoots', null),
  ('messages', '/messages', null),
  ('view_profile', '/view-profile/1', null),
  ('recommended_details', '/recommended/1?bookingId=0', null),
  ('change_location', '/change-location', null),
  ('finding_perfect', '/finding-perfect', <String, dynamic>{'bookingId': 0, 'specialtyId': 0, 'ShootTypeId': 0, 'contentTypeId': 0}),
  ('payment_method', '/payment-method/999', null),
  ('content_type', '/content-type', <String, dynamic>{'specialtyId': 0, 'value': 0}),
  ('video_shoot_type', '/video-shoot-type', <String, dynamic>{'contentTypeId': 0, 'bookingId': 0}),
  ('shoot_date_time', '/shoot-date-time', <String, dynamic>{'ShootTypeId': 0, 'bookingId': 0, 'contentTypeId': 0}),
  ('more_details', '/more-details', <String, dynamic>{'contentTypeId': 0, 'specialtyId': 0, 'ShootTypeId': 0, 'bookingId': 0}),
  ('crew_size_matching', '/crew-size-matching', <String, dynamic>{'specialtyId': 0, 'ShootTypeId': 0, 'bookingId': 0, 'contentTypeId': 0}),
  ('select_dream_team', '/select-dream-team', <String, dynamic>{'specialtyId': 0, 'ShootTypeId': 0, 'bookingId': 0, 'contentTypeId': 0}),
  ('review_confirm', '/review-confirm/999', null),
  ('payment_success', '/payment-success/999', <String, dynamic>{'fullName': 'Test User', 'phone': '1234567890', 'paymentMethod': 'card'}),
  ('booking_event_summary', '/booking-summary/999', <String, dynamic>{'contentType': 'Video', 'shootTypeId': 1}),
  ('manage_booking', '/manage-booking/999', <String, dynamic>{'shootTypeId': 1, 'projectName': 'Test', 'eventDate': '2026-05-09', 'startTime': '10:00', 'endTime': '12:00', 'durationHours': 2.0, 'location': 'Test Location', 'imageUrl': 'test.jpg', 'contentType': 'Video', 'multiDays': []}),
  ('booking_review_confirm', '/booking-review-confirm/999', null),
  ('cancel_booking', '/cancel-booking/999', <String, dynamic>{'projectName': 'Test', 'eventDate': '2026-05-09', 'startTime': '10:00', 'endTime': '12:00', 'durationHours': 2, 'location': 'Test Location', 'contentType': 'Video', 'imageUrl': 'test.jpg'}),
  ('select_booking_type', '/select-booking-type/999', null),
  ('shoot_updated', '/shoot-updated', null),
  ('profile', '/profile', null),
  ('edit_profile', '/edit-profile', null),
  ('change_password', '/change-password', 'test@example.com'),
  ('profile_otp', '/profile-otp', 'test@example.com'),
  ('profile_new_password', '/profile-new-password', <String, String>{'email': 'test@example.com', 'otp': '1234'}),
  ('booking_history', '/booking-history', null),
  ('favourites', '/favourites', null),
  ('app_preferences', '/app-preferences', null),
  ('delete_account', '/delete-account', null),
  ('delete_account_otp', '/delete-account-otp', null),
];

/// Public routes — no auth required.
const _publicRoutes = [
  ('splash', '/splash', null),
  ('onboarding', '/onboarding', null),
  ('login', '/login', null),
  ('signup', '/signup', null),
  ('forgot_password', '/forgot-password', null),
  ('forgot_otp', '/forgot-otp', 'test@example.com'),
  ('reset_password', '/reset-password', <String, String>{'email': 'test@example.com', 'otp': '1234'}),
  ('password_success', '/password-success', null),
];

void runRouteLoadTests(ReportBuilder report) {
  group('Route Load Tests — Public Routes', () {
    for (final (name, path, extra) in _publicRoutes) {
      testWidgets('$name loads without crash', (tester) async {
        await pumpAppWithAuth(tester, isLoggedIn: false, extraOverrides: loggedOutOverrides());

        final navResult = await navigateTo(tester, path, extra: extra);
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
    for (final (name, path, extra) in _protectedRoutes) {
      testWidgets('$name loads without crash', (tester) async {
        await pumpAppWithAuth(tester, isLoggedIn: true, extraOverrides: loggedInOverrides());

        final navResult = await navigateTo(tester, path, extra: extra);
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
