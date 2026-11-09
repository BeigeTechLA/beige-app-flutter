import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../core/firebase/analytics_events.dart';
// import '../../../../core/firebase/analytics_service.dart';
// import 'profile_providers.dart';

enum DeleteOtpStatus { initial, loading, success, error }

class DeleteAccountOtpState {
  final DeleteOtpStatus confirmStatus;
  final DeleteOtpStatus resendStatus;
  final String? errorMessage;

  const DeleteAccountOtpState({
    this.confirmStatus = DeleteOtpStatus.initial,
    this.resendStatus = DeleteOtpStatus.initial,
    this.errorMessage,
  });

  DeleteAccountOtpState copyWith({
    DeleteOtpStatus? confirmStatus,
    DeleteOtpStatus? resendStatus,
    String? errorMessage,
  }) {
    return DeleteAccountOtpState(
      confirmStatus: confirmStatus ?? this.confirmStatus,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }
}

class DeleteAccountOtpNotifier extends Notifier<DeleteAccountOtpState> {
  @override
  DeleteAccountOtpState build() => const DeleteAccountOtpState();

  Future<void> confirmDelete(String otp) async {
    // TODO(delete-account-api): Legacy API disabled pending the new contract.
    // state = state.copyWith(confirmStatus: DeleteOtpStatus.loading);
    //
    // final repo = ref.read(profileRepositoryProvider);
    // final result = await repo.confirmDeleteAccount(otp: otp);
    //
    // result.fold(
    // (error) => state = state.copyWith(
    // confirmStatus: DeleteOtpStatus.error,
    // errorMessage: error.message,
    // ),
    // (_) {
    // AnalyticsService.logEvent(AnalyticsEvents.accountDeleted);
    // state = state.copyWith(confirmStatus: DeleteOtpStatus.success);
    // },
    // );
    state = state.copyWith(
      confirmStatus: DeleteOtpStatus.error,
      errorMessage:
          'Account deletion is in UI preview mode. API integration is pending.',
    );
  }

  Future<void> resendOtp() async {
    // TODO(delete-account-api): Legacy API disabled pending the new contract.
    // state = state.copyWith(resendStatus: DeleteOtpStatus.loading);
    //
    // // Reuses requestDeleteAccount to trigger new OTP
    // final repo = ref.read(profileRepositoryProvider);
    // final result = await repo.requestDeleteAccount(reason: 'resend');
    //
    // result.fold(
    // (error) => state = state.copyWith(
    // resendStatus: DeleteOtpStatus.error,
    // errorMessage: error.message,
    // ),
    // (_) => state = state.copyWith(resendStatus: DeleteOtpStatus.success),
    // );
    state = state.copyWith(
      resendStatus: DeleteOtpStatus.error,
      errorMessage:
          'Account deletion is in UI preview mode. API integration is pending.',
    );
  }
}

final deleteAccountOtpNotifierProvider =
    NotifierProvider.autoDispose<
      DeleteAccountOtpNotifier,
      DeleteAccountOtpState
    >(DeleteAccountOtpNotifier.new);
