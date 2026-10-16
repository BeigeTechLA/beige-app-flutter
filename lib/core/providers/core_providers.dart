import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/env.dart';
import '../network/dio_client.dart';
import '../session/session_store.dart';
import '../storage/secure_token_storage.dart';
import 'auth_state_provider.dart';

/// Provider for SharedPreferences instance.
/// Must be initialized in main() via:
/// `final prefs = await SharedPreferences.getInstance();`
/// `container.overrideWithValue(sharedPreferencesProvider.overrideWithValue(prefs))`
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in ProviderScope',
  );
});

/// Session accessor used by features that need the persisted user id
/// (meetings list URL, messaging socket auth, etc.). Read-only adapter
/// over `SharedPreferences` + `SecureTokenStorage`.
final sessionStoreProvider = Provider<SessionStore>(
  (_) => const SessionStore(),
);

/// Provider for DioClient singleton.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    getToken: () => SecureTokenStorage.read(),
    // Token rejected by server (expired / revoked / stale after app update).
    // Shared session-expiry path: clears local session and flips auth state.
    // The router observes auth state and redirects to Login.
    onUnauthorized: () =>
        ref.read(authStateProvider.notifier).expireSession(),
    isDevelopment: Env.current == Environment.dev,
  );
});
