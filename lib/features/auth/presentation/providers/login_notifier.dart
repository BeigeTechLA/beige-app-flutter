import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../../core/firebase/crashlytics_service.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/guest_mode_provider.dart';
import '../../../../core/providers/timezone_provider.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/shared_service.dart';
import '../../../app_drawer/providers/drawer_notifier.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

import 'auth_providers.dart';
import 'login_state.dart';

class LoginNotifier extends Notifier<LoginState> {
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
          '', // profile image
          user.designation,
          user.department,
          user.departmentId,
          user.timezone,
        );

        // Re-resolve the active timezone now that the pref is written.
        // SharedPreferences isn't reactive, so invalidate the chain to force
        // a fresh read: a non-empty account tz wins; empty → device fallback.
        // Without this, switching to an empty-tz account would keep the
        // previous account's zone. The app-root listener re-pushes the result
        // into DateTimeUtils.
        ref.invalidate(userTimezonePrefProvider);
        ref.invalidate(resolvedTimezoneProvider);
        if (user.timezone.isNotEmpty) {
          // Immediate sync so post-login screens render without waiting for
          // the async resolve to re-run.
          DateTimeUtils.setActiveTimezone(user.timezone);
        }

        if (savePassword) {
          await prefs.setString("email", email);
          await prefs.setString("password", password);
        }

        // Update auth state & clear guest flag.
        ref.read(authStateProvider.notifier).markLoggedIn();
        ref.read(guestModeProvider.notifier).exit();

        // Analytics & Crashlytics
        AnalyticsService.logEvent(
          AnalyticsEvents.login,
          params: {'method': 'email'},
        );
        AnalyticsService.setUserId(user.environmentId.toString());
        CrashlyticsService.setUserContext(
          userId: user.environmentId,
          email: email,
        );

        // Login response omits `profile_image_url` — fire a profile fetch
        // so the drawer avatar hydrates on first open without waiting for
        // the user to visit Edit Profile.
        unawaited(_hydrateProfileImage());

        state = state.copyWith(status: LoginStatus.success, user: user);
      },
    );
  }

  Future<void> _hydrateProfileImage() async {
    try {
      final repo = ref.read(profileRepositoryProvider);
      final result = await repo.getProfile();
      await result.fold((_) async {}, (profile) async {
        final url = profile['user_profile_image_url']?.toString() ?? '';
        if (url.isEmpty) return;
        await SharedService.updateUserData(profileImageUrl: url);
        ref.invalidate(drawerUserProvider);
        ref.read(profileImageBustProvider.notifier).state++;
      });
    } catch (_) {
      // Non-blocking — drawer will simply show the fallback avatar until the
      // user visits Edit Profile which triggers the same fetch.
    }
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
    String timezone,
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
    await prefs.setString(kUserTimezonePrefKey, timezone);
    await prefs.setBool('isLoggedIn', true);
  }
}

final loginNotifierProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginState>(LoginNotifier.new);
