import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum ShootTypeSelectionStatus { initial, loading, loaded, saving, saved, error }

class ShootTypeSelectionState {
  final ShootTypeSelectionStatus status;
  final Map<String, dynamic> bookingTimeData;
  final String? errorMessage;

  const ShootTypeSelectionState({
    this.status = ShootTypeSelectionStatus.initial,
    this.bookingTimeData = const {},
    this.errorMessage,
  });

  ShootTypeSelectionState copyWith({
    ShootTypeSelectionStatus? status,
    Map<String, dynamic>? bookingTimeData,
    String? errorMessage,
  }) {
    return ShootTypeSelectionState(
      status: status ?? this.status,
      bookingTimeData: bookingTimeData ?? this.bookingTimeData,
      errorMessage: errorMessage,
    );
  }
}

class ShootTypeSelectionNotifier
    extends AutoDisposeFamilyNotifier<ShootTypeSelectionState, int> {
  @override
  ShootTypeSelectionState build(int bookingId) {
    _fetchBookingTime(bookingId);
    return const ShootTypeSelectionState(
      status: ShootTypeSelectionStatus.loading,
    );
  }

  Future<void> _fetchBookingTime(int bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getBookingTime(bookingId: bookingId);

    result.fold(
      (error) => state = state.copyWith(
        status: ShootTypeSelectionStatus.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: ShootTypeSelectionStatus.loaded,
        bookingTimeData: data,
      ),
    );
  }

  /// Save updated booking time. Returns true on success.
  Future<bool> saveBookingTime({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    state = state.copyWith(status: ShootTypeSelectionStatus.saving);

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateBookingTime(
      bookingId: bookingId,
      data: data,
    );

    return result.fold(
      (error) {
        state = state.copyWith(
          status: ShootTypeSelectionStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: ShootTypeSelectionStatus.saved);
        return true;
      },
    );
  }
}

final shootTypeSelectionNotifierProvider = NotifierProvider.autoDispose
    .family<ShootTypeSelectionNotifier, ShootTypeSelectionState, int>(
      ShootTypeSelectionNotifier.new,
    );
