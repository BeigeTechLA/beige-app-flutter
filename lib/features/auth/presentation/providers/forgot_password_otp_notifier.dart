import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'forgot_password_otp_state.dart';

class ForgotPasswordOtpNotifier
    extends AutoDisposeNotifier<ForgotPasswordOtpState> {
  @override
  ForgotPasswordOtpState build() => const ForgotPasswordOtpState();

  Future<void> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(verifyStatus: OtpVerifyStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyForgotPasswordOtp(email: email, otp: otp);

    result.fold(
      (error) => state = state.copyWith(
        verifyStatus: OtpVerifyStatus.error,
        errorMessage: error.message,
      ),
      (_) => state = state.copyWith(verifyStatus: OtpVerifyStatus.success),
    );
  }

  Future<void> resendOtp({required String email}) async {
    state = state.copyWith(resendStatus: OtpResendStatus.loading);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resendOtp(email: email);

    result.fold(
      (error) => state = state.copyWith(
        resendStatus: OtpResendStatus.error,
        errorMessage: error.message,
      ),
      (_) => state = state.copyWith(resendStatus: OtpResendStatus.success),
    );
  }
}

final forgotPasswordOtpNotifierProvider =
    NotifierProvider.autoDispose<
      ForgotPasswordOtpNotifier,
      ForgotPasswordOtpState
    >(ForgotPasswordOtpNotifier.new);
