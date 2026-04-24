enum OtpVerifyStatus { initial, loading, success, error }

enum OtpResendStatus { initial, loading, success, error }

class ForgotPasswordOtpState {
  final OtpVerifyStatus verifyStatus;
  final OtpResendStatus resendStatus;
  final String? errorMessage;

  const ForgotPasswordOtpState({
    this.verifyStatus = OtpVerifyStatus.initial,
    this.resendStatus = OtpResendStatus.initial,
    this.errorMessage,
  });

  ForgotPasswordOtpState copyWith({
    OtpVerifyStatus? verifyStatus,
    OtpResendStatus? resendStatus,
    String? errorMessage,
  }) {
    return ForgotPasswordOtpState(
      verifyStatus: verifyStatus ?? this.verifyStatus,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}