import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

/// In-app WebView hosting the Commas (Fanbasis) embedded checkout.
///
/// Pops with `true` when payment is detected as completed, `false` otherwise.
/// The caller must still verify against the backend (webhook is source of
/// truth) before showing the success screen.
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
            // ─── STEP 4 STUB — payment completion detection ───────────────
            // TODO(commas): confirm with backend the redirect URL Fanbasis
            // hits on success/cancel, then match it here and pop accordingly.
            // Backend webhook (`payment.succeeded`) is the source of truth;
            // this only closes the WebView early. Caller re-verifies status.
            //
            //   if (_isSuccessUrl(request.url)) { _finish(true); ... }
            //   if (_isCancelUrl(request.url))  { _finish(false); ... }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  /// Pops the screen once, returning whether payment appears completed.
  void _finish(bool completed) {
    if (_popped) return;
    _popped = true;
    if (context.canPop()) context.pop(completed);
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
                  onTap: () => _finish(false),
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
