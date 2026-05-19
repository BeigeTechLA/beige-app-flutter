import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/navigator_key.dart';
import '../../app/route_names.dart';
import '../../config/env.dart';
import '../firebase/crashlytics_service.dart';
import '../network/dio_client.dart';
import '../utils/shared_service.dart';
import 'auth_state_provider.dart';

/// Provider for SharedPreferences instance.
/// Must be initialized in main() via:
/// `final prefs = await SharedPreferences.getInstance();`
/// `container.overrideWithValue(sharedPreferencesProvider.overrideWithValue(prefs))`
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

/// Provider for DioClient singleton.
final dioClientProvider = Provider<DioClient>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  return DioClient(
    getToken: () async => prefs.getString('token'),
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
      final currentLocation = GoRouterState.of(ctx).matchedLocation;
      if (currentLocation != '/login') {
        // ignore: use_build_context_synchronously
        ctx.goNamed(RouteNames.login);
      }
    },
    isDevelopment: Env.current == Environment.dev,
  );
});
