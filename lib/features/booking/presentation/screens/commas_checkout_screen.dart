import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import '../../../payment/presentation/providers/checkout_status_poller.dart';
import '../../../shoot/presentation/providers/shoot_providers.dart';

/// Outcome of the Commas WebView from a callback or backend confirmation.
enum CommasCheckoutResult { success, failed, dismissed }

/// In-app WebView hosting the Commas (Fanbasis) embedded checkout.
///
/// Commas is configured with `always_redirect: true` and redirects to a
/// backend callback on completion:
///   success → https://mobile.beige.app/payment/success?booking_id={id}
///   failure → https://mobile.beige.app/payment/failed?booking_id={id}
/// The screen detects these, blocks the load, and pops a [CommasCheckoutResult].
/// It also checks backend status while open in case checkout never redirects.
/// On success the caller still verifies against the backend (webhook is the
/// trusted source) before showing the confirmation screen.
class CommasCheckoutScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final String checkoutUrl;

  const CommasCheckoutScreen({
    super.key,
    required this.bookingId,
    required this.checkoutUrl,
  });

  /// Returns the checkout outcome if [url] is a payment callback, else null.
  ///
  /// Host-agnostic (works across dev/prod); only fires when `booking_id` is
  /// absent or matches [bookingId]. Pure/static so it can be unit-tested.
  static CommasCheckoutResult? resultForCallback(String url, int bookingId) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final path = uri.path;
    final isSuccess = path.contains('/payment/success');
    final isFailure = path.contains('/payment/failed');
    if (!isSuccess && !isFailure) return null;

    final bookingParam = uri.queryParameters['booking_id'];
    if (bookingParam != null && bookingParam != bookingId.toString()) {
      return null;
    }

    return isSuccess
        ? CommasCheckoutResult.success
        : CommasCheckoutResult.failed;
  }

  @override
  ConsumerState<CommasCheckoutScreen> createState() =>
      _CommasCheckoutScreenState();
}

class _CommasCheckoutScreenState extends ConsumerState<CommasCheckoutScreen> {
  late final WebViewController _controller;
  late final CheckoutStatusPoller _statusPoller;
  bool _isLoading = true;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(shootRepositoryProvider);
    _statusPoller = CheckoutStatusPoller(
      isPaid: () async {
        final result = await repository.getBookingSummary(
          bookingId: widget.bookingId,
        );
        return result.fold((_) => false, (data) {
          final status =
              (data['payment']?['status'] ??
                      data['booking']?['payment_status'] ??
                      data['payment_status'] ??
                      '')
                  .toString()
                  .toLowerCase();
          return const {'paid', 'succeeded', 'completed'}.contains(status);
        });
      },
      onPaid: () => _finish(CommasCheckoutResult.success),
    )..start();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            final result = _callbackResult(url);
            if (result != null) _finish(result);
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            final result = _callbackResult(url);
            if (result != null) _finish(result);
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
          // Backup for redirects that don't fire onNavigationRequest
          // (JS `window.location`, server 302 within a load, history replace).
          onUrlChange: (change) {
            final url = change.url;
            if (url == null) return;
            final result = _callbackResult(url);
            if (result != null) _finish(result);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  void dispose() {
    _statusPoller.stop();
    super.dispose();
  }

  CommasCheckoutResult? _callbackResult(String url) =>
      CommasCheckoutScreen.resultForCallback(url, widget.bookingId);

  /// Pops the screen once with the checkout [result].
  void _finish(CommasCheckoutResult result) {
    if (!mounted || _popped || !context.canPop()) return;
    _popped = true;
    _statusPoller.stop();
    context.pop(result);
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
