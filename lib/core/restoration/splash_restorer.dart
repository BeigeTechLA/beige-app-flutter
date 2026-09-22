import 'package:flutter/foundation.dart';

/// Pure decision function for whether the splash screen should redirect
/// the user to a persisted route on cold start.
///
/// Kept pure so it is trivial to unit test every branch.
@immutable
class SplashRestorer {
  const SplashRestorer();

  /// Returns `true` when a stored route should be applied.
  ///
  /// Logic:
  /// - feature flag must be on
  /// - user must be logged in (guests always land on home)
  /// - guest mode must be off
  /// - no incoming deep link
  /// - a non-empty persisted route exists
  /// - persisted route is not one we explicitly forbid (defence in depth)
  bool shouldRestore({
    required bool isEnabled,
    required bool isLoggedIn,
    required bool isGuest,
    required bool hasDeepLink,
    required String? persistedRoute,
  }) {
    if (!isEnabled) return false;
    if (!isLoggedIn) return false;
    if (isGuest) return false;
    if (hasDeepLink) return false;
    if (persistedRoute == null || persistedRoute.isEmpty) return false;
    if (_forbidden.contains(persistedRoute)) return false;
    return true;
  }

  /// Routes we never restore to even if they somehow ended up persisted.
  /// Should mirror [RouteRestorationService] skip list — duplicated for
  /// defence in depth.
  static const Set<String> _forbidden = {
    '/splash',
    '/login',
    '/signup',
    '/forgot-password',
    '/forgot-otp',
    '/reset-password',
    '/password-success',
    '/profile-otp',
    '/profile-new-password',
    '/change-password',
    '/delete-account-otp',
  };
}
