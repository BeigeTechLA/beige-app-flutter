import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_providers.dart';

/// Persisted user id read from SharedPreferences (`user_id`).
///
/// Written by `SharedService.setLoginDetails` on login, cleared on logout
/// (`SharedService.logout` wipes prefs). Returns `null` when empty/missing so
/// callers can branch on logged-out state without a separate auth check.
final currentUserIdProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final id = prefs.getString('user_id');
  if (id == null || id.isEmpty) return null;
  return id;
});

/// Minimal current-user snapshot for role-aware UI gating.
///
/// `role` is sourced from the `user_role` SharedPreferences key. Login flow
/// does not yet persist this key (see `SessionStore` doc) — provider returns
/// `null` role until that wiring lands. Callers must treat `null` role as
/// "unknown / not yet wired", not as a specific role.
class CurrentUser {
  const CurrentUser({required this.id, this.name, this.email, this.role});

  final String id;
  final String? name;
  final String? email;
  final String? role;
}

final currentUserProvider = Provider<CurrentUser?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final id = prefs.getString('user_id');
  if (id == null || id.isEmpty) return null;
  return CurrentUser(
    id: id,
    name: prefs.getString('name'),
    email: prefs.getString('email'),
    role: prefs.getString('user_role'),
  );
});
