import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../../core/firebase/crashlytics_service.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/guest_mode_provider.dart';
import '../../../../core/storage/secure_token_storage.dart';

import 'auth_providers.dart';
import 'login_state.dart';

class LoginNotifier extends AutoDisposeNotifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> login({
    required String email,
    required String password,
    bool savePassword = false,
  }) async {
    state = state.copyWith(status: LoginStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password);

    await result.fold(
      (error) async {
        state = state.copyWith(
          status: LoginStatus.error,
          errorMessage: error.message,
        );
      },
      (user) async {
        // Save login details to SharedPreferences
        final prefs = ref.read(sharedPreferencesProvider);
        await _saveLoginDetails(
          prefs,
          user.id,
          user.token,
          user.environmentId,
          user.folder,
          user.name,
          email, // login email
          '',    // profile image
          user.designation,
          user.department,
          user.departmentId,
         );



        if (savePassword) {
          await prefs.setString("email", email);
          await prefs.setString("password", password);
        }

        // Update auth state & clear guest flag.
        ref.read(authStateProvider.notifier).updateState(true);
        ref.read(guestModeProvider.notifier).exit();

        // Analytics & Crashlytics
        AnalyticsService.logEvent(AnalyticsEvents.login, params: {'method': 'email'});
        AnalyticsService.setUserId(user.environmentId.toString());
        CrashlyticsService.setUserContext(userId: user.environmentId, email: email);

        state = state.copyWith(status: LoginStatus.success, user: user);
      },
    );
  }

  Future<void> _saveLoginDetails(
    SharedPreferences prefs,
    String userId,
    String token,
    int environmentId,
    String folder,
    String name,
      String email,
      String profileImageUrl,
    String designation,
    String department,
    String departmentId,
  ) async {
    await SecureTokenStorage.write(token);
    await prefs.setString('user_id', userId);
    await prefs.setInt('environment_id', environmentId);
    await prefs.setString('folder', folder);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('profile_image_url', profileImageUrl);
    await prefs.setString('designation', designation);
    await prefs.setString('department', department);
    await prefs.setString('department_id', departmentId);
    await prefs.setBool('isLoggedIn', true);
  }
}

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
