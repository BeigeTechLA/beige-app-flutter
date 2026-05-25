import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'payment_providers.dart';

enum PaymentMethodStatus { initial, loading, loaded, error }

class PaymentMethodState {
  final PaymentMethodStatus status;
  final List<dynamic> savedCards;
  final List<dynamic> recommended;
  final bool isProcessing;
  final String? errorMessage;

  const PaymentMethodState({
    this.status = PaymentMethodStatus.initial,
    this.savedCards = const [],
    this.recommended = const [],
    this.isProcessing = false,
    this.errorMessage,
  });

  PaymentMethodState copyWith({
    PaymentMethodStatus? status,
    List<dynamic>? savedCards,
    List<dynamic>? recommended,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return PaymentMethodState(
      status: status ?? this.status,
      savedCards: savedCards ?? this.savedCards,
      recommended: recommended ?? this.recommended,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
    );
  }
}

class PaymentMethodNotifier
    extends AutoDisposeFamilyNotifier<PaymentMethodState, int> {
  @override
  PaymentMethodState build(int bookingId) {
    _fetchPaymentMethods();
    return const PaymentMethodState(status: PaymentMethodStatus.loading);
  }

  Future<void> _fetchPaymentMethods() async {
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.getSavedPaymentMethods();

    result.fold(
      (error) => state = state.copyWith(
        status: PaymentMethodStatus.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: PaymentMethodStatus.loaded,
        savedCards: data['saved_cards'] as List? ?? [],
        recommended: data['recommended'] as List? ?? [],
      ),
    );
  }

  /// Create Stripe payment sheet. Returns payment sheet data or null.
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
      (data) => data['payment_sheet'] as Map<String, dynamic>?,
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
        state = state.copyWith(errorMessage: error.message);
        return false;
      },
      (_) => true,
    );
  }
}

final paymentMethodNotifierProvider = NotifierProvider.autoDispose
    .family<PaymentMethodNotifier, PaymentMethodState, int>(
  PaymentMethodNotifier.new,
);
