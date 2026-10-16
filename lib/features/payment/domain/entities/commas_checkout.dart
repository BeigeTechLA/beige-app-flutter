/// Commas (Fanbasis) embedded checkout data returned by the backend.
///
/// Backend creates the Commas checkout session server-side and returns these
/// values. The app constructs the official embedded checkout URL from them and
/// opens it inside an in-app WebView. The app never calls Commas APIs directly.
class CommasCheckout {
  final String creatorId;
  final String productId;
  final String checkoutSessionSecret;
  final String? checkoutSessionId;
  final String environment;

  const CommasCheckout({
    required this.creatorId,
    required this.productId,
    required this.checkoutSessionSecret,
    this.checkoutSessionId,
    required this.environment,
  });

  /// Builds the [CommasCheckout] from the backend `data` map.
  ///
  /// Tolerates either a flat map or a nested checkout section
  /// (`commas` / `checkout` / `payment_sheet`) so it stays resilient to the
  /// exact response shape.
  factory CommasCheckout.fromJson(Map<String, dynamic> json) {
    // 1. Unwrap common top-level response envelopes (e.g. data, commas, checkout, payment_sheet)
    Map<String, dynamic> map = json;
    if (map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    if (map['commas'] is Map<String, dynamic>) {
      map = map['commas'] as Map<String, dynamic>;
    } else if (map['checkout'] is Map<String, dynamic>) {
      map = map['checkout'] as Map<String, dynamic>;
    } else if (map['payment_sheet'] is Map<String, dynamic>) {
      map = map['payment_sheet'] as Map<String, dynamic>;
    }

    // Helper to find first non-null/non-empty matching value
    String findValue(List<String> keys) {
      for (final key in keys) {
        final val = map[key];
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString().trim();
        }
      }
      return '';
    }

    final creatorId = findValue([
      'creator_id',
      'creatorId',
      'creator_ID',
      'creator',
      'creatorID',
    ]);

    final productId = findValue([
      'product_id',
      'productId',
      'product_ID',
      'product',
      'productID',
    ]);

    final checkoutSessionSecret = findValue([
      'checkout_session_secret',
      'checkoutSessionSecret',
      'checkout_session_id',
      'checkoutSessionId',
      'session_secret',
      'sessionSecret',
      'checkout_secret',
      'checkoutSecret',
      'client_secret',
      'clientSecret',
      'session_id',
      'sessionId',
      'secret',
    ]);

    final checkoutSessionId = findValue([
      'checkout_session_id',
      'checkoutSessionId',
      'session_id',
      'sessionId',
    ]);

    final env = findValue(['environment', 'env']);

    return CommasCheckout(
      creatorId: creatorId,
      productId: productId,
      checkoutSessionSecret: checkoutSessionSecret,
      checkoutSessionId: checkoutSessionId.isNotEmpty ? checkoutSessionId : null,
      environment: env.isNotEmpty ? env : 'production',
    );
  }

  /// Base URL resolved from backend [environment].
  String get baseUrl {
    final env = environment.trim().toLowerCase();
    if (env == 'sandbox' || env == 'qa' || env == 'development' || env == 'dev') {
      return 'https://embedded-checkout.qa.dev-fan-basis.com';
    }
    return 'https://embedded.fanbasis.io';
  }

  /// Official Commas embedded checkout URL.
  String get embeddedUrl =>
      '$baseUrl/session/$creatorId/$productId/$checkoutSessionSecret';

  bool get isValid =>
      creatorId.isNotEmpty &&
      productId.isNotEmpty &&
      checkoutSessionSecret.isNotEmpty;
}
