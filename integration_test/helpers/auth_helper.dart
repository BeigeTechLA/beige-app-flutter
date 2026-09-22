import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns Riverpod overrides for authenticated state.
///
/// SharedPreferences handles core auth (`isLoggedIn`, `token`).
/// Add overrides here for providers that depend on auth but aren't
/// derived from SharedPreferences (e.g. user profile provider).
List<Override> loggedInOverrides() {
  return [
    // Example when user provider exists:
    // userProvider.overrideWithValue(AsyncData(fakeUser)),
  ];
}

/// Returns Riverpod overrides for unauthenticated state.
List<Override> loggedOutOverrides() {
  return [];
}

/// Fake booking ID used in parameterized routes.
const int fakeBookingId = 999;

/// Fake creative/profile ID used in parameterized routes.
const int fakeCreativeId = 1;
