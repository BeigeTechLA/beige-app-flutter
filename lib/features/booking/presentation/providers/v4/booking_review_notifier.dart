import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige/app/route_names.dart';
import '../../../domain/entities/booking_enums.dart';
import '../../../domain/entities/booking_review.dart';
import '../../../domain/entities/submit_request.dart';
import '../booking_flow_controller.dart';
import '../booking_providers.dart';
import 'booking_save_state.dart';

/// Loads the review snapshot (`POST /bookings/:id/review`) with the current
/// add-on items. Marks the review cache fresh on success.
final bookingReviewProvider =
    FutureProvider.autoDispose<BookingReview>((ref) async {
      final bookingId = ref.watch(
        bookingFlowControllerProvider.select((s) => s.bookingId),
      );
      if (bookingId == null) {
        throw StateError('Missing booking. Please restart the booking.');
      }

      final addOnItems = ref.read(bookingFlowControllerProvider).addonSelection.toAddOnItems();
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.reviewBooking(
        bookingId: bookingId,
        addOnItems: addOnItems,
      );

      return result.fold(
        (failure) => throw failure,
        (review) {
          Future.microtask(() {
            ref.read(bookingFlowControllerProvider.notifier).markReviewed();
          });
          return review;
        },
      );
    });

/// Validates contact information and saves the quote via
/// `POST /bookings/:id/quote` with the exact add-on snapshot.
class BookingQuoteNotifier extends AutoDisposeNotifier<BookingSaveState> {
  @override
  BookingSaveState build() => BookingSaveState.idle;

  Future<bool> submitQuote(ContactInfo contact) async {
    final name = contact.fullName.trim();
    final email = contact.email.trim();
    final phone = contact.phone.trim();

    if (name.isEmpty) {
      state = const BookingSaveState(
        status: BookingSaveStatus.error,
        error: 'Please enter your full name.',
      );
      return false;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      state = const BookingSaveState(
        status: BookingSaveStatus.error,
        error: 'Please enter a valid email address.',
      );
      return false;
    }

    if (phone.isEmpty || phone.replaceAll(RegExp(r'[^0-9]'), '').length < 7) {
      state = const BookingSaveState(
        status: BookingSaveStatus.error,
        error: 'Please enter a valid phone number.',
      );
      return false;
    }

    final bookingId = ref.read(bookingFlowControllerProvider).bookingId;
    if (bookingId == null) {
      state = const BookingSaveState(
        status: BookingSaveStatus.error,
        error: 'Missing booking. Please restart the booking.',
      );
      return false;
    }

    state = BookingSaveState.loading;
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    controller.setContact(contact);

    final addOnItems = ref.read(bookingFlowControllerProvider).addonSelection.toAddOnItems();
    final repo = ref.read(bookingRepositoryProvider);

    final result = await repo.quoteBooking(
      bookingId: bookingId,
      addOnItems: addOnItems,
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
          ..markQuoted()
          ..markStepComplete(BookingStep.review)
          ..setCurrentStep(BookingStep.confirmPay);
        controller.persist(currentRoute: RouteNames.bookingConfirmPay);
        state = BookingSaveState.success;
        return true;
      },
    );
  }
}

final bookingQuoteNotifierProvider =
    AutoDisposeNotifierProvider<BookingQuoteNotifier, BookingSaveState>(
      BookingQuoteNotifier.new,
    );
