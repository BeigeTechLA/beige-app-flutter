import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/payment_review.dart';
import '../booking_flow_controller.dart';
import '../booking_providers.dart';

/// Loads the read-only final payment review (`GET /bookings/:id/payment-review`).
/// Returns line items, subtotal, card processing fee, and final amount.
final paymentReviewProvider =
    FutureProvider.autoDispose<PaymentReview>((ref) async {
      final bookingId = ref.watch(
        bookingFlowControllerProvider.select((s) => s.bookingId),
      );
      if (bookingId == null) {
        throw StateError('Missing booking. Please restart the booking.');
      }

      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.getPaymentReview(bookingId: bookingId);

      return result.fold(
        (failure) => throw failure,
        (paymentReview) => paymentReview,
      );
    });
