import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/route_names.dart';
import '../../../domain/entities/booking_enums.dart';
import '../booking_providers.dart';
import '../booking_flow_controller.dart';
import 'booking_save_state.dart';

/// Screen 1 — Select Content Type. Creates the draft booking (or updates its
/// content type) and stores the returned `booking_id` in the flow controller.
class BookingContentNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  /// Saves the chosen content type. Returns true on success so the screen can
  /// navigate. On failure, state carries the error and input is preserved.
  Future<bool> submit(BookingContentType contentType) async {
    state = BookingSaveState.loading;
    final repo = ref.read(bookingRepositoryProvider);
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    final existingId = ref.read(bookingFlowControllerProvider).bookingId;

    final payload = {'content_type': contentType.wireValue};

    // Create on first entry; update the content type when re-editing.
    final result = existingId == null
        ? await repo.createBooking(data: payload)
        : await repo.updateBooking(bookingId: existingId, data: payload);

    return result.fold(
      (failure) {
        state = BookingSaveState(
          status: BookingSaveStatus.error,
          error: failure.message,
        );
        return false;
      },
      (data) {
        final bookingId = existingId ?? _extractBookingId(data);
        if (bookingId == null) {
          state = const BookingSaveState(
            status: BookingSaveStatus.error,
            error: 'Could not start your booking. Please try again.',
          );
          return false;
        }
        controller
          ..setBookingId(bookingId)
          ..setContentType(contentType)
          ..markStepComplete(BookingStep.contentType)
          ..setCurrentStep(BookingStep.shootType);
        controller.persist(currentRoute: RouteNames.bookingShootType);
        state = BookingSaveState.success;
        return true;
      },
    );
  }

  int? _extractBookingId(Map<String, dynamic> response) {
    final data = response['data'];
    final raw = data is Map<String, dynamic>
        ? (data['booking_id'] ?? data['id'])
        : (response['booking_id'] ?? response['id']);
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}

final bookingContentNotifierProvider =
    AutoDisposeNotifierProvider<BookingContentNotifier, BookingSaveState>(
      BookingContentNotifier.new,
    );
