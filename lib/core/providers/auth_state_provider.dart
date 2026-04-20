import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core_providers.dart';

/// Notifier that manages and provides the authentication state.
class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Updates the authentication state.
  /// This should be called after SharedPreferences is updated.
  void updateState(bool isLoggedIn) {
    state = isLoggedIn;
  }

  /// Helper to refresh state from SharedPreferences.
  void refresh() {
    final prefs = ref.read(sharedPreferencesProvider);
    state = prefs.getBool('isLoggedIn') ?? false;
  }
}

/// Provides the current authentication state.
final authStateProvider = NotifierProvider<AuthStateNotifier, bool>(() {
  return AuthStateNotifier();
});
