import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/analytics_events.dart';
import '../firebase/analytics_service.dart';
import '../firebase/crashlytics_service.dart';
import '../notifications/push_notification_service.dart';
import '../notifications/push_session_id.dart';
import '../notifications/push_token_sync_provider.dart';
import '../restoration/restoration_providers.dart';
import '../utils/date_time_utils.dart';
import '../utils/shared_service.dart';
import 'core_providers.dart';
import 'current_user_provider.dart';
import 'timezone_provider.dart';

/// Boolean derived from session presence — single source of truth for
/// "is the user logged in?". Router redirect reads it; login/logout flows
/// mutate via [AuthStateNotifier.markLoggedIn] / [AuthStateNotifier.logout].
///
/// `build()` seeds from the persisted `isLoggedIn` flag so the value is correct
/// from the first router redirect.
class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void>? _endingSession;

  /// Call after a successful login flow has already written the session.
  void markLoggedIn() {
    _endingSession = null;
    state = true;
  }

  /// Shared backend session-expiry path. The router observes auth state and
  /// returns to Login. Repeated failures for the same session share one
  /// cleanup operation.
  Future<void> expireSession() =>
      _endingSession ??= _endSession(emitLogoutEvent: false);

  /// Explicit user logout uses the same cleanup and records the logout event.
  Future<void> logout() =>
      _endingSession ??= _endSession(emitLogoutEvent: true);

  Future<void> _endSession({required bool emitLogoutEvent}) async {
    // Deregister the FCM token BEFORE `SharedService.logout()` wipes the JWT
    // from `SecureTokenStorage` and `push_session_id` from `SharedPreferences`.
    // Only attempt network DELETE on explicit logout (when the JWT is still
    // valid), not on 401 session expiry (which would fail with 401 again).
    final pushService = PushNotificationService.instance;
    pushService.onTokenRefreshed = null;
    final sessionId = pushService.lastSessionId ?? await PushSessionId.peek();
    pushService.clearSession();
    if (emitLogoutEvent && sessionId != null && sessionId.isNotEmpty) {
      await _cleanUp('push token', () async {
        final result = await ref
            .read(pushTokenRepositoryProvider)
            .removeToken(sessionId: sessionId);
        if (kDebugMode) {
          result.fold(
            (err) => debugPrint(
              '[AuthStateNotifier] Push token removal failed: ${err.message}',
            ),
            (_) => debugPrint(
              '[AuthStateNotifier] Push token removed for ended session.',
            ),
          );
        }
      });
    }

    // Revoke access immediately, even if storage or telemetry cleanup fails.
    state = false;
    await _cleanUp('session', () => SharedService.logout());
    ref.invalidate(currentUserProvider);
    ref.invalidate(currentUserIdProvider);
    // Reset timezone so the next user doesn't inherit this session's zone.
    // `prefs.clear()` wipes the `user_timezone` key, but the in-memory active
    // zone and the cached resolve providers must be reset explicitly.
    DateTimeUtils.setActiveTimezone('');
    ref.invalidate(userTimezonePrefProvider);
    ref.invalidate(resolvedTimezoneProvider);
    await _cleanUp(
      'route restoration',
      () => ref.read(routeRestorationServiceProvider).clearAll(),
    );
    await _cleanUp('drafts', () => ref.read(draftStoreProvider).clearAll());
    await _cleanUp('telemetry', () async {
      await CrashlyticsService.clearUserContext();
      if (emitLogoutEvent) {
        await AnalyticsService.logEvent(AnalyticsEvents.logout);
      }
    });
  }

  Future<void> _cleanUp(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      // A cleanup failure must not strand the original API request or prevent
      // the remaining cleanup operations and the router's auth redirect.
      debugPrint('Failed to clear $label on session end: $error');
    }
  }
}

/// Provides the current authentication state.
final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(() {
  return AuthStateNotifier();
});
