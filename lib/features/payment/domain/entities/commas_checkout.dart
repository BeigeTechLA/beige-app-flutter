/// Commas (Fanbasis) embedded checkout data returned by the backend.
///
/// Backend creates the Commas checkout session server-side and returns these
/// values. The app constructs the official embedded checkout URL from them and
/// opens it inside an in-app WebView. The app never calls Commas APIs directly.
class CommasCheckout {
  final String creatorId;
  final String productId;
  final String checkoutSessionSecret;
  final String environment;

  const CommasCheckout({
    required this.creatorId,
    required this.productId,
    required this.checkoutSessionSecret,
    required this.environment,
  });

  /// Builds the [CommasCheckout] from the backend `data` map.
  ///
  /// Tolerates either a flat map or a nested checkout section
  /// (`commas` / `checkout` / `payment_sheet`) so it stays resilient to the
  /// exact response shape.
  factory CommasCheckout.fromJson(Map<String, dynamic> json) {
    final section = (json['commas'] ??
            json['checkout'] ??
            json['payment_sheet'] ??
            json) as Map<String, dynamic>;

    return CommasCheckout(
      creatorId: section['creator_id']?.toString() ?? '',
      productId: section['product_id']?.toString() ?? '',
      checkoutSessionSecret: section['checkout_session_secret']?.toString() ?? '',
      environment: section['environment']?.toString() ?? 'production',
    );
  }

  /// Official Commas embedded checkout URL.
  String get embeddedUrl =>
      'https://embedded.fanbasis.io/session/$creatorId/$productId/$checkoutSessionSecret';

  bool get isValid =>
      creatorId.isNotEmpty &&
      productId.isNotEmpty &&
      checkoutSessionSecret.isNotEmpty;
}
