import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/payment_review.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_notifier.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_review_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_payment_failure_sheet.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_payment_method_sheet.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_payment_processing_overlay.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

/// Screen 11 / Screen 10 (Phase 5 & 6) — Confirm & Pay.
///
/// Read-only final pricing screen from `GET /bookings/:id/payment-review`.
/// Renders server amounts, fees, and line items directly without client-side
/// recalculation.
///
/// Tapping Confirm & Pay opens explicit provider selection (Stripe / Commas),
/// performs final submit (`PUT /bookings/:id/submit`), presents payment, and
/// verifies confirmation against backend summary webhook.
class BookingConfirmPayScreen extends ConsumerWidget {
  const BookingConfirmPayScreen({super.key});

  Future<void> _openPaymentMethodSheet(
    BuildContext context,
    WidgetRef ref,
    PaymentReview review,
  ) async {
    final amountText = review.finalAmountLabel ??
        (review.finalAmount != null ? '\$${review.finalAmount}' : '');
    final selectedMethod = await BookingPaymentMethodSheet.show(
      context,
      amountLabel: amountText,
    );
    if (selectedMethod != null && context.mounted) {
      await ref.read(bookingPaymentNotifierProvider.notifier).submitAndPay(
            context,
            method: selectedMethod,
          );
    }
  }

  void _handlePaymentFailure(
    BuildContext context,
    WidgetRef ref,
    String errorMessage,
    PaymentReview review,
  ) async {
    final action = await BookingPaymentFailureSheet.show(
      context,
      errorMessage: errorMessage,
    );
    if (!context.mounted) return;

    if (action == PaymentFailureAction.retry) {
      ref.read(bookingPaymentNotifierProvider.notifier).submitAndPay(context);
    } else if (action == PaymentFailureAction.changeMethod) {
      _openPaymentMethodSheet(context, ref, review);
    } else {
      ref.read(bookingPaymentNotifierProvider.notifier).resetError();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentReviewAsync = ref.watch(paymentReviewProvider);
    final paymentState = ref.watch(bookingPaymentNotifierProvider);
    final bookingId = ref.watch(
      bookingFlowControllerProvider.select((s) => s.bookingId),
    );

    // Listen to payment outcome transitions
    ref.listen<BookingPaymentState>(bookingPaymentNotifierProvider, (prev, next) {
      if (next.isSuccess && next.status != prev?.status) {
        if (context.mounted && bookingId != null) {
          context.goNamed(
            RouteNames.bookingConfirmation,
            pathParameters: {'bookingId': bookingId.toString()},
          );
        }
      } else if (next.isFailed && next.status != prev?.status) {
        paymentReviewAsync.whenData((review) {
          if (context.mounted) {
            _handlePaymentFailure(
              context,
              ref,
              next.errorMessage ?? 'Payment was not completed.',
              review,
            );
          }
        });
      }
    });

    return Stack(
      children: [
        AppScaffold(
          hasAppBar: true,
          appBar: BookingStepHeader.appBar(context, step: BookingStep.confirmPay),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.confirmPay),
                AppSpacing.verticalBase,
                Expanded(
                  child: paymentReviewAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Couldn't load payment details.",
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                          ),
                          AppSpacing.verticalMd,
                          TextButton(
                            onPressed: () => ref.invalidate(paymentReviewProvider),
                            child: Text(
                              'Retry',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (review) => ListView(
                      children: [
                        Text(
                          'Confirm & Pay',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          'Review your final order summary and pricing before proceeding.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        // Premium Receipt Card (Option A)
                        _buildReceiptCard(review),
                        AppSpacing.verticalBase,
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalBase,
                paymentReviewAsync.maybeWhen(
                  data: (review) {
                    final amountText = review.finalAmountLabel ??
                        (review.finalAmount != null ? '\$${review.finalAmount}' : '');
                    return BookingPrimaryButton(
                      label: amountText.isNotEmpty
                          ? 'Confirm & Pay $amountText'
                          : 'Confirm & Pay',
                      loading: paymentState.isLoading,
                      onTap: () => _openPaymentMethodSheet(context, ref, review),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                AppSpacing.verticalBase,
              ],
            ),
          ),
        ),
        if (paymentState.isLoading || paymentState.isPendingVerification)
          BookingPaymentProcessingOverlay(
            state: paymentState,
            onRecheck: () {
              if (bookingId != null) {
                ref
                    .read(bookingPaymentNotifierProvider.notifier)
                    .verifyPayment(bookingId);
              }
            },
            onGoToShoots: () => context.goNamed(RouteNames.myShoots),
          ),
      ],
    );
  }

  /// Premium receipt-style card with line items, fee breakdown, and highlighted total.
  Widget _buildReceiptCard(PaymentReview review) {
    final edits = review.editingServices;
    final receiveText = edits.receiveText;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white15, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                AppSpacing.gapHSm,
                Expanded(
                  child: Text(
                    review.packageService ?? 'Shoot Package',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crew Breakdown
                if (review.crew.isNotEmpty) ...[
                  Text(
                    'Assigned Crew',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: review.crew.map((c) => _tagPill(c)).toList(),
                  ),
                  const Divider(color: AppColors.white10, height: 24),
                ],
                // Delivery Summary
                if (receiveText != null && receiveText.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          receiveText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.white10, height: 24),
                ],
                // Line Items
                if (review.lineItems.isNotEmpty) ...[
                  Text(
                    'Price Breakdown',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...review.lineItems.map(
                    (item) => _pricingRow(
                      label: item.label,
                      amount: item.amountLabel ?? (item.amount != null ? '\$${item.amount}' : ''),
                    ),
                  ),
                  const Divider(color: AppColors.white10, height: 20),
                ],
                // Subtotal
                if (review.subtotal != null || review.subtotalLabel != null)
                  _pricingRow(
                    label: 'Subtotal',
                    amount: review.subtotalLabel ?? '\$${review.subtotal}',
                  ),
                // Card Processing Fee
                if (review.cardProcessingFee != null || review.cardProcessingFeeLabel != null) ...[
                  const SizedBox(height: 4),
                  _pricingRow(
                    label: 'Card Processing Fee',
                    amount: review.cardProcessingFeeLabel ?? '\$${review.cardProcessingFee}',
                    isSubtle: true,
                  ),
                ],
                const Divider(color: AppColors.white15, height: 24),
                // Total Highlight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review.finalAmountLabel ??
                          (review.finalAmount != null ? '\$${review.finalAmount}' : ''),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pricingRow({
    required String label,
    required String amount,
    bool isSubtle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSubtle ? AppColors.textSecondary : AppColors.white,
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSubtle ? AppColors.textSecondary : AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: AppRadii.smAll,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
