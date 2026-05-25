import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for payment-related API operations.
abstract class PaymentRepository {
  /// GET payment — fetch saved payment methods.
  Future<Either<AppException, Map<String, dynamic>>> getSavedPaymentMethods();

  /// POST bookings/{bookingId}/paymentsheet — create Stripe payment sheet.
  Future<Either<AppException, Map<String, dynamic>>> createPaymentSheet({
    required int bookingId,
  });

  /// PUT bookings/{bookingId}/payment — save contact info and payment method.
  Future<Either<AppException, Map<String, dynamic>>> updatePaymentInfo({
    required int bookingId,
    required Map<String, dynamic> data,
  });

  /// POST payment/{bookingId}/stripe/confirm — confirm Stripe payment.
  Future<Either<AppException, Map<String, dynamic>>> confirmStripePayment({
    required int bookingId,
    required String paymentIntentId,
  });
}
