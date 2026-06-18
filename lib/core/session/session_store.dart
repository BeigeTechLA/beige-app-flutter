import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/secure_token_storage.dart';

/// Snapshot of the persisted session user used by the messaging layer (DTO
/// `fromMe` derivation, socket auth handshake).
///
/// `id` and `role` may be empty for sessions persisted before the messaging
/// feature landed — DTOs degrade safely (delivery status falls back to
/// `delivered`, socket handshake omits `userRole`).
@immutable
class UserSnapshot {
  final String id;
  final String? name;
  final String? email;
  final String? role;

  const UserSnapshot({
    required this.id,
    this.name,
    this.email,
    this.role,
  });
}

/// Thin adapter over `SharedPreferences` + `SecureTokenStorage`. Keeps the
/// messaging layer decoupled from the rest of `SharedService`. Read-only.
class SessionStore {
  const SessionStore();

  /// SharedPreferences keys. Existing keys (`name`, `email`) populated by
  /// `SharedService.setLoginDetails`. `user_id` + `user_role` need to be
  /// added to the login persistence path before messaging fully works.
  static const String _kUserId = 'user_id';
  static const String _kUserName = 'name';
  static const String _kUserEmail = 'email';
  static const String _kUserRole = 'user_role';

  Future<UserSnapshot?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kUserId) ?? '';
    final name = prefs.getString(_kUserName);
    final email = prefs.getString(_kUserEmail);
    final role = prefs.getString(_kUserRole);
    // `name` populated by SharedService — treat its presence as proof the
    // user has logged in even when id/role haven't been persisted yet.
    if (id.isEmpty && (name == null || name.isEmpty)) {
      return null;
    }
    return UserSnapshot(
      id: id,
      name: name,
      email: email,
      role: role,
    );
  }

  Future<String?> readToken() => SecureTokenStorage.read();
}
