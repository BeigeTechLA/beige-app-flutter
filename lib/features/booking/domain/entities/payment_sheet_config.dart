import 'package:flutter/foundation.dart';

import 'booking_enums.dart';

/// Config returned by `POST /bookings/:id/paymentsheet` for the chosen
/// provider. Stripe returns mobile PaymentSheet params; Commas returns an
/// embedded checkout URL. Exact field names are unverified (D8) — validate
/// required data before opening the payment UI.
@immutable
class PaymentSheetConfig {
  const PaymentSheetConfig({
    required this.method,
    this.stripePaymentIntentClientSecret,
    this.stripeCustomerId,
    this.stripeEphemeralKeySecret,
    this.stripePublishableKey,
    this.commasCheckoutUrl,
  });

  final BookingPaymentMethod method;

  // Stripe PaymentSheet.
  final String? stripePaymentIntentClientSecret;
  final String? stripeCustomerId;
  final String? stripeEphemeralKeySecret;
  final String? stripePublishableKey;

  // Commas embedded checkout.
  final String? commasCheckoutUrl;

  /// True when the required fields for [method] are present.
  bool get isUsable => switch (method) {
    BookingPaymentMethod.stripe =>
      (stripePaymentIntentClientSecret ?? '').isNotEmpty,
    BookingPaymentMethod.commas => (commasCheckoutUrl ?? '').isNotEmpty,
  };

  factory PaymentSheetConfig.fromData(
    Map<String, dynamic> data, {
    required BookingPaymentMethod method,
  }) {
    return PaymentSheetConfig(
      method: method,
      stripePaymentIntentClientSecret:
          (data['payment_intent_client_secret'] ??
                  data['client_secret'] ??
                  data['paymentIntent'])
              ?.toString(),
      stripeCustomerId: (data['customer'] ?? data['customer_id'])?.toString(),
      stripeEphemeralKeySecret:
          (data['ephemeral_key'] ?? data['ephemeralKey'])?.toString(),
      stripePublishableKey:
          (data['publishable_key'] ?? data['publishableKey'])?.toString(),
      commasCheckoutUrl:
          (data['checkout_url'] ?? data['url'] ?? data['embed_url'])
              ?.toString(),
    );
  }
}
