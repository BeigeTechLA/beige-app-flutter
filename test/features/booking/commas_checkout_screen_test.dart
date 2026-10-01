import 'package:beige/features/booking/presentation/screens/commas_checkout_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit coverage for callback URL classification, not live card processing.
void main() {
  const bookingId = 42;
  CommasCheckoutResult? classify(String url) =>
      CommasCheckoutScreen.resultForCallback(url, bookingId);

  group('resultForCallback — success', () {
    test('success callback with matching booking_id → success', () {
      final r = classify(
        'https://mobile.beige.app/payment/success?booking_id=$bookingId',
      );
      expect(r, CommasCheckoutResult.success);
    });

    test('success callback without booking_id → success', () {
      final r = classify('https://mobile.beige.app/payment/success');
      expect(r, CommasCheckoutResult.success);
    });

    test('dev host also detected (host-agnostic)', () {
      final r = classify(
        'https://dev.beige.app/payment/success?booking_id=$bookingId',
      );
      expect(r, CommasCheckoutResult.success);
    });

    test('extra query params do not break detection', () {
      final r = classify(
        'https://mobile.beige.app/payment/success?booking_id=$bookingId&session=abc123',
      );
      expect(r, CommasCheckoutResult.success);
    });
  });

  group('resultForCallback — failed', () {
    test('failed callback with matching booking_id → failed', () {
      final r = classify(
        'https://mobile.beige.app/payment/failed?booking_id=$bookingId',
      );
      expect(r, CommasCheckoutResult.failed);
    });

    test('failed callback without booking_id → failed', () {
      final r = classify('https://mobile.beige.app/payment/failed');
      expect(r, CommasCheckoutResult.failed);
    });
  });

  group('resultForCallback — non-callback / edge cases (null)', () {
    test('checkout page itself is not a callback', () {
      final r = classify('https://checkout.fanbasis.com/embed/abc');
      expect(r, isNull);
    });

    test('stripe iframe url is not a callback', () {
      final r = classify('https://js.stripe.com/v3/elements-inner-card.html');
      expect(r, isNull);
    });

    test('success path but booking_id for a different booking → null', () {
      final r = classify(
        'https://mobile.beige.app/payment/success?booking_id=999',
      );
      expect(r, isNull);
    });

    test('malformed url → null (no crash)', () {
      final r = classify('not a url');
      expect(r, isNull);
    });
  });
}
