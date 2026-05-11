import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../payment/presentation/providers/payment_providers.dart';
import '../../../shoot/presentation/providers/shoot_providers.dart';

enum BookingReviewStatus { initial, loading, loaded, error }

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
  @override
  BookingReviewState build(int bookingId) {
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

        AnalyticsService.logEvent(AnalyticsEvents.bookingStepReview, params: {
          'booking_id': bookingId,
        });

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
        AnalyticsService.logEvent(AnalyticsEvents.paymentInitiated, params: {
          'booking_id': bookingId,
        });
        final paymentSheet = data['payment_sheet'] as Map<String, dynamic>?;
        return paymentSheet;
      },
    );
  }

  /// Confirm payment with backend. Returns true on success.
  Future<bool> confirmPayment({
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
        AnalyticsService.logEvent(AnalyticsEvents.paymentFailed, params: {
          'booking_id': bookingId,
          'error': error.message,
        });
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
      (_) {
        AnalyticsService.logEvent(AnalyticsEvents.paymentSuccess, params: {
          'booking_id': bookingId,
        });
        AnalyticsService.logEvent(AnalyticsEvents.bookingCompleted, params: {
          'booking_id': bookingId,
        });
        return true;
      },
    );
  }
}

final bookingReviewNotifierProvider = NotifierProvider.autoDispose
    .family<BookingReviewNotifier, BookingReviewState, int>(
  BookingReviewNotifier.new,
);
