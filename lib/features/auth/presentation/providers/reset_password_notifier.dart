import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'reset_password_state.dart';

class ResetPasswordNotifier extends AutoDisposeNotifier<ResetPasswordState> {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: ResetPasswordStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (error) => state = state.copyWith(
        status: ResetPasswordStatus.error,
        errorMessage: error.message,
      ),
      (_) => state = state.copyWith(status: ResetPasswordStatus.success),
    );
  }
}

final resetPasswordNotifierProvider =
    NotifierProvider.autoDispose<ResetPasswordNotifier, ResetPasswordState>(
  ResetPasswordNotifier.new,
);
