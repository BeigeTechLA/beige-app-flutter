import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

/// Outcome of the Commas WebView, based on the redirect callback detected.
enum CommasCheckoutResult { success, failed, dismissed }

/// In-app WebView hosting the Commas (Fanbasis) embedded checkout.
///
/// Commas is configured with `always_redirect: true` and redirects to a
/// backend callback on completion:
///   success → https://mobile.beige.app/payment/success?booking_id={id}
///   failure → https://mobile.beige.app/payment/failed?booking_id={id}
/// The screen detects these, blocks the load, and pops a [CommasCheckoutResult].
/// On success the caller still verifies against the backend (webhook is the
/// trusted source) before showing the confirmation screen.
class CommasCheckoutScreen extends StatefulWidget {
  final int bookingId;
  final String checkoutUrl;

  const CommasCheckoutScreen({
    super.key,
    required this.bookingId,
    required this.checkoutUrl,
  });

  @override
  State<CommasCheckoutScreen> createState() => _CommasCheckoutScreenState();
}

class _CommasCheckoutScreenState extends State<CommasCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            // Redirect callbacks only close the WebView — the backend webhook
            // stays the trusted source. Block the load and pop the outcome.
            final result = _callbackResult(request.url);
            if (result != null) {
              _finish(result);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
    debugPrint("🔗 [Commas WebView Loading]: ${widget.checkoutUrl}");
  }

  /// Returns the checkout outcome if [url] is a payment callback, else null.
  ///
  /// Host-agnostic (works across dev/prod); only fires when `booking_id` is
  /// absent or matches this booking.
  CommasCheckoutResult? _callbackResult(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final path = uri.path;
    final isSuccess = path.contains('/payment/success');
    final isFailure = path.contains('/payment/failed');
    if (!isSuccess && !isFailure) return null;

    final bookingParam = uri.queryParameters['booking_id'];
    if (bookingParam != null && bookingParam != widget.bookingId.toString()) {
      return null;
    }

    return isSuccess
        ? CommasCheckoutResult.success
        : CommasCheckoutResult.failed;
  }

  /// Pops the screen once with the checkout [result].
  void _finish(CommasCheckoutResult result) {
    if (_popped) return;
    _popped = true;
    if (context.canPop()) context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _finish(CommasCheckoutResult.dismissed),
                  child: SvgPicture.asset(AppAssets.back, height: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  "Checkout",
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
