import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/features/booking/domain/entities/payment_sheet_config.dart';
import 'package:beige/features/booking/presentation/screens/commas_checkout_screen.dart';

enum PaymentGatewayResult {
  success,
  canceled,
  failed,
}

/// Abstraction for presenting the payment interface (Stripe native or Commas web).
/// Allows clean testing and mocking without calling native platform channels.
abstract class BookingPaymentGateway {
  Future<PaymentGatewayResult> presentStripe({
    required BuildContext context,
    required PaymentSheetConfig config,
  });

  Future<PaymentGatewayResult> presentCommas({
    required BuildContext context,
    required int bookingId,
    required String checkoutUrl,
  });
}

class DefaultBookingPaymentGateway implements BookingPaymentGateway {
  const DefaultBookingPaymentGateway();

  @override
  Future<PaymentGatewayResult> presentStripe({
    required BuildContext context,
    required PaymentSheetConfig config,
  }) async {
    final clientSecret = config.stripePaymentIntentClientSecret;
    if (clientSecret == null || clientSecret.isEmpty) {
      return PaymentGatewayResult.failed;
    }
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: config.stripeCustomerId,
          customerEphemeralKeySecret: config.stripeEphemeralKeySecret,
          merchantDisplayName: 'BEIGE',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return PaymentGatewayResult.success;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentGatewayResult.canceled;
      }
      return PaymentGatewayResult.failed;
    } catch (_) {
      return PaymentGatewayResult.failed;
    }
  }

  @override
  Future<PaymentGatewayResult> presentCommas({
    required BuildContext context,
    required int bookingId,
    required String checkoutUrl,
  }) async {
    final result = await context.pushNamed<CommasCheckoutResult>(
      RouteNames.commasCheckout,
      pathParameters: {'bookingId': bookingId.toString()},
      extra: checkoutUrl,
    );
    if (result == CommasCheckoutResult.success) {
      return PaymentGatewayResult.success;
    } else if (result == CommasCheckoutResult.dismissed) {
      return PaymentGatewayResult.canceled;
    } else {
      return PaymentGatewayResult.failed;
    }
  }
}

final bookingPaymentGatewayProvider = Provider<BookingPaymentGateway>((ref) {
  return const DefaultBookingPaymentGateway();
});
