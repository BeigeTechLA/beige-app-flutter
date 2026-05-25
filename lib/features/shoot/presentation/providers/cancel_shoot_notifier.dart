import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import 'shoot_providers.dart';

enum CancelShootStatus { initial, cancelling, cancelled, error }

class CancelShootState {
  final CancelShootStatus status;
  final String? errorMessage;
  final String? successMessage;

  const CancelShootState({
    this.status = CancelShootStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  CancelShootState copyWith({
    CancelShootStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return CancelShootState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class CancelShootNotifier extends AutoDisposeNotifier<CancelShootState> {
  @override
  CancelShootState build() {
    return const CancelShootState();
  }

  Future<void> cancelShoot({required int bookingId}) async {
    state = state.copyWith(status: CancelShootStatus.cancelling);

    final repo = ref.read(shootRepositoryProvider);
    final result = await repo.cancelShoot(bookingId: bookingId);

    result.fold(
      (error) => state = state.copyWith(
        status: CancelShootStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        AnalyticsService.logEvent(AnalyticsEvents.bookingCancelled, params: {
          'booking_id': bookingId,
        });
        final message =
            (data['message'] as String?) ?? 'Shoot cancelled successfully';
        state = state.copyWith(
          status: CancelShootStatus.cancelled,
          successMessage: message,
        );
      },
    );
  }
}

final cancelShootNotifierProvider =
    NotifierProvider.autoDispose<CancelShootNotifier, CancelShootState>(
  CancelShootNotifier.new,
);
