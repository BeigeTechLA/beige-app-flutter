import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/analytics_events.dart';
import '../firebase/analytics_service.dart';
import '../firebase/crashlytics_service.dart';
import '../restoration/restoration_providers.dart';
import '../utils/shared_service.dart';
import 'core_providers.dart';
import 'current_user_provider.dart';

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
    // Revoke access immediately, even if storage or telemetry cleanup fails.
    state = false;
    await _cleanUp('session', () => SharedService.logout());
    ref.invalidate(currentUserProvider);
    ref.invalidate(currentUserIdProvider);
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
