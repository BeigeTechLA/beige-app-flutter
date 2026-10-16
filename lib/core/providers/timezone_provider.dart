import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'core_providers.dart';

/// Pref key holding the user's IANA timezone captured at login.
const String kUserTimezonePrefKey = 'user_timezone';

/// User's IANA timezone string from prefs (`user_timezone`), empty when unset.
/// Populated on successful login (see login_notifier / SharedService).
final userTimezonePrefProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(kUserTimezonePrefKey) ?? '';
});

/// Resolves the active IANA timezone for display + booking schedule payload.
///
/// Fallback chain: `user_timezone` pref (login) -> device IANA via
/// flutter_timezone -> `UTC`. The device lookup is cached for the provider's
/// lifetime. No picker — matches the read-only stance in user_timezone_plan.md.
final resolvedTimezoneProvider = FutureProvider<String>((ref) async {
  final fromPref = ref.watch(userTimezonePrefProvider);
  if (fromPref.isNotEmpty) return fromPref;
  try {
    // flutter_timezone 5: getLocalTimezone returns TimezoneInfo; the IANA
    // name is on `.identifier`.
    final device = (await FlutterTimezone.getLocalTimezone()).identifier;
    if (device.isNotEmpty) return device;
  } catch (e) {
    debugPrint('resolvedTimezoneProvider device lookup failed: $e');
  }
  return 'UTC';
});
