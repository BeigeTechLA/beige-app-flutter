import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────
// Replace this import with your actual authStateProvider path:
// import '../../lib/core/providers/auth_state_provider.dart';
// ─────────────────────────────────────────────────────────────

/// Returns Riverpod overrides that simulate a logged-in user.
///
/// Usage:
///   await pumpAppWithAuth(tester, isLoggedIn: true, extraOverrides: loggedInOverrides());
List<Override> loggedInOverrides() {
  return [
    // authStateProvider.overrideWithValue(true),
    // Add any other providers that depend on auth state here.
    // Example for a userProvider:
    // userProvider.overrideWithValue(AsyncData(fakeUser)),
  ];
}

/// Returns Riverpod overrides that simulate a logged-out user.
List<Override> loggedOutOverrides() {
  return [
    // authStateProvider.overrideWithValue(false),
  ];
}

/// Fake minimal user data for providers that require it.
/// Expand this as needed for your domain models.
const Map<String, dynamic> fakeUserData = {
  'id': 1,
  'email': 'test@beige.com',
  'fullName': 'Test User',
  'phone': '+1234567890',
};

/// Fake booking ID used in parameterized routes.
const int fakeBookingId = 999;

/// Fake creative/profile ID used in parameterized routes.
const int fakeCreativeId = 1;
