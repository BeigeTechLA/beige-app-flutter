import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../../config/env.dart';

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
    isDevelopment: Env.current == Environment.dev,
  );
});
