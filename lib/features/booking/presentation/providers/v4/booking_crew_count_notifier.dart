import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_save_state.dart';

/// Screen 6 — Crew Count. Saves the four total required role counts via
/// `POST /bookings/:id` with `role_counts` before edits/creator selection.
class BookingCrewCountNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  Future<bool> submit(RoleCounts counts) async {
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

    final result = await repo.updateBooking(
      bookingId: bookingId,
      data: counts.toRoleCountsPayload(),
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
          ..setRoleCounts(counts)
          ..markStepComplete(BookingStep.crewCount)
          ..setCurrentStep(BookingStep.edits);
        controller.persist(currentRoute: RouteNames.bookingEdits);
        state = BookingSaveState.success;
        return true;
      },
    );
  }
}

final bookingCrewCountNotifierProvider =
    AutoDisposeNotifierProvider<BookingCrewCountNotifier, BookingSaveState>(
      BookingCrewCountNotifier.new,
    );
