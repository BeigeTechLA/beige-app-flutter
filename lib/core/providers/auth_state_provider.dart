import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// Provides the current authentication state by reading SharedPreferences.
///
/// This is a simple provider that reads the stored login flag.
/// Screens that change login state (login, logout, delete account)
/// must invalidate this provider to trigger GoRouter redirect.
final authStateProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('isLoggedIn') ?? false;
});
