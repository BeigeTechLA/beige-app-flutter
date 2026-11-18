import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum ShootTimeV2Status { initial, saving, success, error }

class ShootTimeV2State {
  final ShootTimeV2Status status;
  final String? errorMessage;

  const ShootTimeV2State({
    this.status = ShootTimeV2Status.initial,
    this.errorMessage,
  });

  ShootTimeV2State copyWith({
    ShootTimeV2Status? status,
    String? errorMessage,
  }) => ShootTimeV2State(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );
}

/// Screen 3 — saves the When & Where selection via `PUT /bookings/:id/time`.
/// The payload is assembled by [ShootTimePayload] in the screen and passed in
/// whole, so this notifier stays transport-only.
class ShootTimeV2Notifier extends Notifier<ShootTimeV2State> {
  @override
  ShootTimeV2State build() => const ShootTimeV2State();

  Future<bool> save({
    required int bookingId,
    required Map<String, dynamic> payload,
  }) async {
    state = state.copyWith(status: ShootTimeV2Status.saving);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateBookingTime(
      bookingId: bookingId,
      data: payload,
    );
    return result.fold(
      (error) {
        state = state.copyWith(
          status: ShootTimeV2Status.error,
          errorMessage: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: ShootTimeV2Status.success);
        return true;
      },
    );
  }
}

final shootTimeV2NotifierProvider =
    NotifierProvider.autoDispose<ShootTimeV2Notifier, ShootTimeV2State>(
      ShootTimeV2Notifier.new,
    );
