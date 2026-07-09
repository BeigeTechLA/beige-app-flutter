import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/navigator_key.dart';
import '../../app/route_names.dart';
import '../../config/env.dart';
import '../firebase/crashlytics_service.dart';
import '../network/dio_client.dart';
import '../session/session_store.dart';
import '../storage/secure_token_storage.dart';
import '../utils/shared_service.dart';
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
    onUnauthorized: () async {
      // Token rejected by server (expired / revoked / stale after app update).
      // Clear local session, flip auth state, force user to login.
      await SharedService.logout();
      CrashlyticsService.clearUserContext();

      if (ref.read(authStateProvider)) {
        ref.read(authStateProvider.notifier).updateState(false);
      }

      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;
      // ignore: use_build_context_synchronously
      final router = GoRouter.of(ctx);
      final currentLocation =
          router.routerDelegate.currentConfiguration.uri.path;
      if (currentLocation != '/login') {
        // ignore: use_build_context_synchronously
        ctx.goNamed(RouteNames.login);
      }
    },
    isDevelopment: Env.current == Environment.dev,
  );
});
