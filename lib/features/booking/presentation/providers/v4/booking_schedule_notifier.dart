import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/route_names.dart';
import '../../../domain/entities/booking_enums.dart';
import '../../../domain/entities/schedule_input.dart';
import '../booking_providers.dart';
import '../booking_flow_controller.dart';
import 'booking_save_state.dart';

/// Screen 3 — Date, Time, Timezone & Location. Saves the schedule for either
/// mode via `PUT /bookings/:id/time`. The deferred payload carries no date or
/// time; never fabricate one.
class BookingScheduleNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  Future<bool> submit(ScheduleInput schedule) async {
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

    final result = await repo.updateBookingTime(
      bookingId: bookingId,
      data: schedule.toTimePayload(),
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
          ..setSchedule(schedule)
          ..markStepComplete(BookingStep.schedule)
          ..setCurrentStep(BookingStep.details);
        controller.persist(currentRoute: RouteNames.bookingDetails);
        state = BookingSaveState.success;
        return true;
      },
    );
  }
}

final bookingScheduleNotifierProvider =
    AutoDisposeNotifierProvider<BookingScheduleNotifier, BookingSaveState>(
      BookingScheduleNotifier.new,
    );
