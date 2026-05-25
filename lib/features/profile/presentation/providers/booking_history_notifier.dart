import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_providers.dart';

enum BookingHistoryStatus { initial, loading, loaded, error }

class BookingHistoryState {
  final BookingHistoryStatus status;
  final List<dynamic> bookings;
  final String? errorMessage;

  const BookingHistoryState({
    this.status = BookingHistoryStatus.initial,
    this.bookings = const [],
    this.errorMessage,
  });

  BookingHistoryState copyWith({
    BookingHistoryStatus? status,
    List<dynamic>? bookings,
    String? errorMessage,
  }) {
    return BookingHistoryState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookingHistoryNotifier extends AutoDisposeNotifier<BookingHistoryState> {
  @override
  BookingHistoryState build() {
    fetchBookings();
    return const BookingHistoryState(status: BookingHistoryStatus.loading);
  }

  Future<void> fetchBookings() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getBookingHistory();

    result.fold(
      (error) => state = state.copyWith(
        status: BookingHistoryStatus.error,
        errorMessage: error.message,
      ),
      (bookings) => state = state.copyWith(
        status: BookingHistoryStatus.loaded,
        bookings: bookings,
      ),
    );
  }
}

final bookingHistoryNotifierProvider =
    NotifierProvider.autoDispose<BookingHistoryNotifier, BookingHistoryState>(
  BookingHistoryNotifier.new,
);
