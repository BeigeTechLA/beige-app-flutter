import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/route_names.dart';
import '../../../domain/entities/booking_enums.dart';
import '../../../domain/entities/shoot_type_option.dart';
import '../booking_providers.dart';
import '../booking_flow_controller.dart';
import 'booking_save_state.dart';

/// Loads the shared shoot-type catalogue (`GET /bookings/shoot-types`). Same
/// list for every content type; cards use name/description/image/order.
final shootTypeCatalogueProvider =
    FutureProvider.autoDispose<List<ShootTypeOption>>((ref) async {
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.getShootTypeCatalogue();
      return result.fold((failure) => throw failure, (list) => list);
    });

/// Screen 2 — Select Shoot Type. Saves the exact shoot-type NAME (never a
/// numeric id) via `POST /bookings/:id`.
class BookingShootTypeNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  Future<bool> submit(String shootTypeName) async {
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
      data: {'shoot_type': shootTypeName},
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
          ..setShootType(shootTypeName)
          ..markStepComplete(BookingStep.shootType)
          ..setCurrentStep(BookingStep.schedule);
        controller.persist(currentRoute: RouteNames.bookingSchedule);
        state = BookingSaveState.success;
        return true;
      },
    );
  }
}

final bookingShootTypeNotifierProvider =
    AutoDisposeNotifierProvider<BookingShootTypeNotifier, BookingSaveState>(
      BookingShootTypeNotifier.new,
    );
