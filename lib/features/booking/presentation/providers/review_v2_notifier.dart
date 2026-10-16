import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../payment/domain/entities/commas_checkout.dart';
import 'booking_providers.dart';

enum ReviewV2Status { initial, loading, loaded, paying, error }

class ReviewV2State {
  final ReviewV2Status status;

  /// Server-calculated display payload from `POST /review` (project, schedule,
  /// editing, contact, package_summary, pricing_summary). Rendered as-is.
  final Map<String, dynamic>? review;
  final String? errorMessage;

  const ReviewV2State({
    this.status = ReviewV2Status.initial,
    this.review,
    this.errorMessage,
  });

  ReviewV2State copyWith({
    ReviewV2Status? status,
    Map<String, dynamic>? review,
    String? errorMessage,
  }) => ReviewV2State(
    status: status ?? this.status,
    review: review ?? this.review,
    errorMessage: errorMessage,
  );
}

/// Screen 10 — Review & Pay. Loads the server-calculated review payload and
/// then drives the pay chain:
/// `/quote` → `/submit` → `/paymentsheet` (Commas) → verify `/summary-details`.
///
/// Pricing is never computed in the app — the review payload is rendered
/// verbatim. The screen owns navigation (WebView push + success route); this
/// notifier only performs the transport steps and tracks status.
class ReviewV2Notifier extends Notifier<ReviewV2State> {
  @override
  ReviewV2State build() => const ReviewV2State();

  Future<void> loadReview({
    required int bookingId,
    required List<Map<String, dynamic>> addOnItems,
  }) async {
    state = state.copyWith(status: ReviewV2Status.loading);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getReview(
      bookingId: bookingId,
      data: {'add_on_items': addOnItems},
    );
    result.fold(
      (error) => state = state.copyWith(
        status: ReviewV2Status.error,
        errorMessage: error.message,
      ),
      (data) =>
          state = state.copyWith(status: ReviewV2Status.loaded, review: data),
    );
  }

  /// Runs `/quote` then `/submit`. Returns true on success.
  Future<bool> quoteAndSubmit({
    required int bookingId,
    required String fullName,
    required String email,
    required String phone,
    required String matchingMethod,
    required List<int> selectedCrewIds,
    required List<Map<String, dynamic>> addOnItems,
  }) async {
    state = state.copyWith(status: ReviewV2Status.paying);
    final repo = ref.read(bookingRepositoryProvider);

    final quote = await repo.saveQuote(
      bookingId: bookingId,
      data: {'add_on_items': addOnItems},
    );
    final quoteOk = quote.fold((error) {
      state = state.copyWith(
        status: ReviewV2Status.error,
        errorMessage: error.message,
      );
      return false;
    }, (_) => true);
    if (!quoteOk) return false;

    final submit = await repo.submitBooking(
      bookingId: bookingId,
      data: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'matching_method': matchingMethod,
        'selected_crew_ids': selectedCrewIds,
      },
    );
    return submit.fold((error) {
      state = state.copyWith(
        status: ReviewV2Status.error,
        errorMessage: error.message,
      );
      return false;
    }, (_) => true);
  }

  /// Opens the Commas payment sheet. Returns the parsed checkout, or null on
  /// failure / invalid response.
  Future<CommasCheckout?> openCommasCheckout({required int bookingId}) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.openPaymentSheet(
      bookingId: bookingId,
      data: {'payment_method': 'commas'},
    );
    return result.fold(
      (error) {
        state = state.copyWith(
          status: ReviewV2Status.error,
          errorMessage: error.message,
        );
        return null;
      },
      (data) {
        final checkout = CommasCheckout.fromJson(data);
        return checkout.isValid ? checkout : null;
      },
    );
  }

  /// Polls `/summary-details` once for a paid status (webhook is the trusted
  /// source; the screen retries a few times to let it land).
  Future<bool> isPaid({required int bookingId}) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getSummaryDetails(bookingId: bookingId);
    return result.fold((_) => false, (data) {
      final status = (data['payment']?['status'] ??
              data['booking']?['payment_status'] ??
              data['payment_status'] ??
              '')
          .toString()
          .toLowerCase();
      return const {'paid', 'succeeded', 'completed'}.contains(status);
    });
  }

  void resetPaying() {
    if (state.status == ReviewV2Status.paying) {
      state = state.copyWith(status: ReviewV2Status.loaded);
    }
  }
}

final reviewV2NotifierProvider =
    NotifierProvider.autoDispose<ReviewV2Notifier, ReviewV2State>(
      ReviewV2Notifier.new,
    );
