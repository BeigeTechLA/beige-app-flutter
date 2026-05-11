import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import 'booking_providers.dart';

enum ShootDetailsStatus { initial, saving, success, error }

class ShootDetailsState {
  final ShootDetailsStatus status;
  final String? errorMessage;

  const ShootDetailsState({
    this.status = ShootDetailsStatus.initial,
    this.errorMessage,
  });

  ShootDetailsState copyWith({
    ShootDetailsStatus? status,
    String? errorMessage,
  }) {
    return ShootDetailsState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class ShootDetailsNotifier
    extends AutoDisposeFamilyNotifier<ShootDetailsState, int> {
  bool _stepCompleted = false;

  @override
  ShootDetailsState build(int bookingId) {
    // --- Booking Analytics: Drop-off tracking for Step 4 ---
    ref.onDispose(() {
      if (!_stepCompleted) {
        AnalyticsService.logEvent(AnalyticsEvents.bookingAbandoned, params: {
          'booking_id': bookingId,
          'last_step': 'details',
          'step_number': 4,
        });
      }
    });
    return const ShootDetailsState();
  }

  Future<void> saveDetails({
    required int bookingId,
    required Map<String, dynamic> payload,
  }) async {
    state = state.copyWith(status: ShootDetailsStatus.saving);

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateBookingDetails(
      bookingId: bookingId,
      data: payload,
    );

    result.fold(
      (error) => state = state.copyWith(
        status: ShootDetailsStatus.error,
        errorMessage: error.message,
      ),
      (_) {
        _stepCompleted = true;
        // --- Booking Analytics: Step 4 — Shoot details saved ---
        AnalyticsService.logEvent(AnalyticsEvents.bookingStepDetails, params: {
          'booking_id': bookingId,
          'location': payload['location']?.toString() ?? '',
          'step_number': 4,
        });
        state = state.copyWith(status: ShootDetailsStatus.success);
      },
    );
  }
}

final shootDetailsNotifierProvider = NotifierProvider.autoDispose
    .family<ShootDetailsNotifier, ShootDetailsState, int>(
  ShootDetailsNotifier.new,
);
