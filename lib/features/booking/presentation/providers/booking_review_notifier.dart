import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../payment/domain/entities/commas_checkout.dart';
import '../../../payment/presentation/providers/payment_providers.dart';
import '../../../shoot/presentation/providers/shoot_providers.dart';

enum BookingReviewStatus { initial, loading, loaded, error }

/// Result of polling booking payment status after Commas checkout.
enum CommasPaymentStatus { paid, pending, failed }

class BookingReviewState {
  final BookingReviewStatus status;
  final Map<String, dynamic>? booking;
  final Map<String, dynamic>? pricing;
  final List<dynamic> heldCreatives;
  final Map<String, dynamic>? crewSummary;
  final bool hasSavedCard;
  final bool isSaving;
  final String? errorMessage;

  const BookingReviewState({
    this.status = BookingReviewStatus.initial,
    this.booking,
    this.pricing,
    this.heldCreatives = const [],
    this.crewSummary,
    this.hasSavedCard = false,
    this.isSaving = false,
    this.errorMessage,
  });

  BookingReviewState copyWith({
    BookingReviewStatus? status,
    Map<String, dynamic>? booking,
    Map<String, dynamic>? pricing,
    List<dynamic>? heldCreatives,
    Map<String, dynamic>? crewSummary,
    bool? hasSavedCard,
    bool? isSaving,
    String? errorMessage,
  }) {
    return BookingReviewState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      pricing: pricing ?? this.pricing,
      heldCreatives: heldCreatives ?? this.heldCreatives,
      crewSummary: crewSummary ?? this.crewSummary,
      hasSavedCard: hasSavedCard ?? this.hasSavedCard,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class BookingReviewNotifier
    extends AutoDisposeFamilyNotifier<BookingReviewState, int> {
  bool _stepCompleted = false;

  @override
  BookingReviewState build(int bookingId) {
    // --- Booking Analytics: Drop-off tracking for Step 7 ---
    ref.onDispose(() {
      if (!_stepCompleted) {
        AnalyticsService.logEvent(
          AnalyticsEvents.bookingAbandoned,
          params: {
            'booking_id': bookingId,
            'last_step': 'review',
            'step_number': 7,
          },
        );
      }
    });
    _fetchSummary(bookingId);
    return const BookingReviewState(status: BookingReviewStatus.loading);
  }

  Future<void> _fetchSummary(int bookingId) async {
    final repo = ref.read(shootRepositoryProvider);
    final result = await repo.getBookingSummary(bookingId: bookingId);

    result.fold(
      (error) => state = state.copyWith(
        status: BookingReviewStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        final bookingData = data['booking'] as Map<String, dynamic>?;
        final pricingData = data['pricing'] as Map<String, dynamic>?;
        final held = data['held_creatives'] as List? ?? [];
        final crew = data['crew_summary'] as Map<String, dynamic>?;

        List savedCards =
            data['payment_methods']?['saved_cards'] as List? ?? [];

        // --- Booking Analytics: Step 7 — Review screen loaded ---
        final totalAmount = pricingData?['total_amount'] ?? 0;
        AnalyticsService.logEvent(
          AnalyticsEvents.bookingStepReview,
          params: {
            'booking_id': bookingId,
            'total_amount': totalAmount,
            'step_number': 7,
          },
        );

        state = state.copyWith(
          status: BookingReviewStatus.loaded,
          booking: bookingData,
          pricing: pricingData,
          heldCreatives: held,
          crewSummary: crew,
          hasSavedCard: savedCards.isNotEmpty,
        );
      },
    );
  }

  /// Save contact info + payment method. Returns true on success.
  Future<bool> savePaymentInfo({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    state = state.copyWith(isSaving: true);

    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.updatePaymentInfo(
      bookingId: bookingId,
      data: data,
    );

    return result.fold(
      (error) {
        state = state.copyWith(isSaving: false, errorMessage: error.message);
        return false;
      },
      (_) {
        state = state.copyWith(isSaving: false);
        return true;
      },
    );
  }

  /// Create Stripe payment sheet. Returns payment sheet data or null on failure.
  Future<Map<String, dynamic>?> createPaymentSheet({
    required int bookingId,
  }) async {
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.createPaymentSheet(bookingId: bookingId);

    return result.fold(
      (error) {
        state = state.copyWith(errorMessage: error.message);
        return null;
      },
      (data) {
        // --- Booking Analytics: Step 8 — Payment initiated ---
        AnalyticsService.logEvent(
          AnalyticsEvents.paymentInitiated,
          params: {'booking_id': bookingId, 'step_number': 8},
        );
        final paymentSheet = data['payment_sheet'] as Map<String, dynamic>?;
        return paymentSheet;
      },
    );
  }

  /// Create a Commas embedded checkout session. Returns the checkout data
  /// (used to build the WebView URL) or null on failure.
  Future<CommasCheckout?> createCommasCheckout({
    required int bookingId,
  }) async {
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.createCommasCheckout(bookingId: bookingId);

    return result.fold(
      (error) {
        state = state.copyWith(errorMessage: error.message);
        return null;
      },
      (checkout) {
        // --- Booking Analytics: Step 8 — Payment initiated ---
        AnalyticsService.logEvent(
          AnalyticsEvents.paymentInitiated,
          params: {'booking_id': bookingId, 'step_number': 8},
        );
        return checkout;
      },
    );
  }

  /// Poll booking payment status after the Commas WebView closes.
  ///
  /// Backend webhook (`payment.succeeded`) is the trusted source; the WebView
  /// callback URL only closes the sheet. Reads `summary-details` and maps the
  /// payment status. Marks the booking flow complete + logs analytics on paid.
  Future<CommasPaymentStatus> checkCommasPaymentStatus({
    required int bookingId,
  }) async {
    final repo = ref.read(shootRepositoryProvider);
    final result = await repo.getBookingSummary(bookingId: bookingId);

    return result.fold(
      (error) {
        state = state.copyWith(errorMessage: error.message);
        return CommasPaymentStatus.pending;
      },
      (data) {
        final status = (data['payment']?['status'] ??
                data['booking']?['payment_status'] ??
                data['payment_status'] ??
                '')
            .toString()
            .toLowerCase();

        switch (status) {
          case 'paid':
          case 'succeeded':
          case 'completed':
            _onPaymentPaid(bookingId);
            return CommasPaymentStatus.paid;
          case 'failed':
          case 'canceled':
          case 'cancelled':
            AnalyticsService.logEvent(
              AnalyticsEvents.paymentFailed,
              params: {'booking_id': bookingId, 'status': status},
            );
            return CommasPaymentStatus.failed;
          default:
            return CommasPaymentStatus.pending;
        }
      },
    );
  }

  void _onPaymentPaid(int bookingId) {
    _stepCompleted = true;
    final totalAmount = (state.pricing?['total_amount'] ?? 0).toDouble();
    AnalyticsService.logEvent(
      AnalyticsEvents.paymentSuccess,
      params: {'booking_id': bookingId, 'amount': totalAmount, 'currency': 'USD'},
    );
    AnalyticsService.logEvent(
      AnalyticsEvents.bookingCompleted,
      params: {
        'booking_id': bookingId,
        'total_amount': totalAmount,
        'step_number': 9,
      },
    );
    AnalyticsService.logPurchase(
      transactionId: bookingId.toString(),
      value: totalAmount,
      currency: 'USD',
      params: {'booking_id': bookingId},
    );
  }
}

/// Confirm payment with backend. Returns true on success.
/*  Future<bool> confirmPayment({
    required int bookingId,
    required String paymentIntentId,
  }) async {
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.confirmStripePayment(
      bookingId: bookingId,
      paymentIntentId: paymentIntentId,
    );

    return result.fold(
      (error) {
        // --- Booking Analytics: Step 9 — Payment failed ---
        AnalyticsService.logEvent(AnalyticsEvents.paymentFailed, params: {
          'booking_id': bookingId,
          'error': error.message,
          'step_number': 9,
        });
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
      (_) {
        _stepCompleted = true;
        // --- Booking Analytics: Step 9 — Payment successful ---
        AnalyticsService.logEvent(AnalyticsEvents.paymentSuccess, params: {
          'booking_id': bookingId,
          'amount': state.pricing?['total_amount'] ?? 0,
          'currency': 'USD',
        });
        // --- Booking Analytics: Step 9 — Booking completed ---
        AnalyticsService.logEvent(AnalyticsEvents.bookingCompleted, params: {
          'booking_id': bookingId,
          'total_amount': state.pricing?['total_amount'] ?? 0,
          'step_number': 9,
        });
        // --- Booking Analytics: Step 9 — Purchase conversion event (Firebase standard) ---
        final totalAmount = (state.pricing?['total_amount'] ?? 0).toDouble();
        AnalyticsService.logPurchase(
          transactionId: bookingId.toString(),
          value: totalAmount,
          currency: 'USD',
          params: {'booking_id': bookingId},
        );
        return true;
      },
    );
  }
}*/

final bookingReviewNotifierProvider = NotifierProvider.autoDispose
    .family<BookingReviewNotifier, BookingReviewState, int>(
      BookingReviewNotifier.new,
    );
