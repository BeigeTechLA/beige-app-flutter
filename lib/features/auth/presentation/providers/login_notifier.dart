import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';

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
        await _saveLoginDetails(prefs, user.token, user.environmentId,
            user.folder, user.name, user.designation, user.department,
            user.departmentId);

        if (savePassword) {
          await prefs.setString("email", email);
          await prefs.setString("password", password);
        }

        // Update auth state
        ref.read(authStateProvider.notifier).updateState(true);

        state = state.copyWith(status: LoginStatus.success, user: user);
      },
    );
  }

  Future<void> _saveLoginDetails(
    SharedPreferences prefs,
    String token,
    int environmentId,
    String folder,
    String name,
    String designation,
    String department,
    String departmentId,
  ) async {
    await prefs.setString('token', token);
    await prefs.setInt('environment_id', environmentId);
    await prefs.setString('folder', folder);
    await prefs.setString('name', name);
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
