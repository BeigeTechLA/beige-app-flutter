import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_save_state.dart';

/// Screen 4 — Additional details + reference links. Saves notes and the
/// reference-link array via `PUT /bookings/:id/details`. Empty links send `[]`.
class BookingDetailsNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  Future<bool> submit({
    required String additionalDetails,
    required List<String> referenceLinks,
  }) async {
    final bookingId = ref.read(bookingFlowControllerProvider).bookingId;
    if (bookingId == null) {
      state = const BookingSaveState(
        status: BookingSaveStatus.error,
        error: 'Missing booking. Please restart the booking.',
      );
      return false;
    }

    state = BookingSaveState.loading;
    final repo = ref.read(bookingRepositoryProvider);
    final controller = ref.read(bookingFlowControllerProvider.notifier);

    final result = await repo.updateBookingDetails(
      bookingId: bookingId,
      data: {
        'additional_details': additionalDetails,
        'reference_links': referenceLinks,
      },
    );

    return result.fold(
      (failure) {
        state = BookingSaveState(
          status: BookingSaveStatus.error,
          error: failure.message,
        );
        return false;
      },
      (_) {
        controller
          ..setDetails(
            additionalDetails: additionalDetails,
            referenceLinks: referenceLinks,
          )
          ..markStepComplete(BookingStep.details)
          ..setCurrentStep(BookingStep.matchingChoice);
        controller.persist(currentRoute: RouteNames.bookingMatchingChoice);
        state = BookingSaveState.success;
        return true;
      },
    );
  }
}

final bookingDetailsNotifierProvider =
    AutoDisposeNotifierProvider<BookingDetailsNotifier, BookingSaveState>(
      BookingDetailsNotifier.new,
    );
