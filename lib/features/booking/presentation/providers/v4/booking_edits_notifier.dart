import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/booking_enums.dart';
import '../../../domain/entities/edit_selection.dart';
import '../../../domain/entities/edit_type_option.dart';
import '../booking_flow_controller.dart';
import '../booking_providers.dart';
import 'booking_save_state.dart';

/// Loads the edit-types catalogue for the current content type
/// (`GET /bookings/edit-types?content_type=...`). Throws when no content type
/// has been chosen yet so the screen can show an error/retry.
final editTypesCatalogueProvider =
    FutureProvider.autoDispose<EditTypesCatalogue>((ref) async {
      final contentType = ref.read(bookingFlowControllerProvider).contentType;
      if (contentType == null) {
        throw StateError('content type not set');
      }
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.getEditTypesCatalogue(contentType: contentType);
      return result.fold((failure) => throw failure, (catalogue) => catalogue);
    });

/// Screen 7 — Select Edits. Saves the edit selection via
/// `PUT /bookings/:id/edits`. Quantities above one are not encoded (D3); only
/// the exact edit keys are sent.
class BookingEditsNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  Future<bool> submit(EditSelection selection) async {
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

    final result = await repo.saveEdits(
      bookingId: bookingId,
      selection: selection,
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
          ..setEditSelection(selection)
          ..markStepComplete(BookingStep.edits)
          ..setCurrentStep(
            ref.read(bookingFlowControllerProvider).isManualBranch
                ? BookingStep.creatorSelection
                : BookingStep.addons,
          );
        controller.persist();
        state = BookingSaveState.success;
        return true;
      },
    );
  }
}

final bookingEditsNotifierProvider =
    AutoDisposeNotifierProvider<BookingEditsNotifier, BookingSaveState>(
      BookingEditsNotifier.new,
    );
