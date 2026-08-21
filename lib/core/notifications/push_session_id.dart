import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Stable per-install session identifier sent alongside FCM token and
/// preference calls. Third Party keys push preferences by `session_id`, so it
/// must stay constant for the life of an install.
///
/// Persisted in `SharedPreferences`. `SharedService.logout` clears prefs, so a
/// fresh id is minted on the next login — that is treated as a new session.
class PushSessionId {
  const PushSessionId._();

  static const String _key = 'push_session_id';

  /// Returns the persisted session id, generating and storing one on first use.
  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = _generate();
    await prefs.setString(_key, generated);
    return generated;
  }

  static String _generate() {
    final rnd = Random.secure();
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final suffix =
        List.generate(12, (_) => rnd.nextInt(16).toRadixString(16)).join();
    return '$timestamp-$suffix';
  }
}
