import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';

import 'auth_providers.dart';
import 'forgot_password_state.dart';

class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<void> sendOtp(String email) async {
    state = state.copyWith(status: ForgotPasswordStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.forgotPassword(email: email);

    result.fold(
      (error) {
        state = state.copyWith(
          status: ForgotPasswordStatus.error,
          errorMessage: error.message,
        );
      },
      (message) {
        AnalyticsService.logEvent(AnalyticsEvents.forgotPassword);
        state = state.copyWith(
          status: ForgotPasswordStatus.success,
          successMessage: message,
        );
      },
    );
  }
}

final forgotPasswordNotifierProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);
