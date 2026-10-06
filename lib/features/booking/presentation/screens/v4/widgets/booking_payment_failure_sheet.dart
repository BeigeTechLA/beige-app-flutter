import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';

enum PaymentFailureAction {
  retry,
  changeMethod,
  cancel,
}

/// Recovery modal bottom sheet (Option A) shown when payment fails or is rejected.
/// Retains all booking state so the user can easily re-attempt without starting over.
class BookingPaymentFailureSheet extends StatelessWidget {
  const BookingPaymentFailureSheet({
    super.key,
    required this.errorMessage,
    required this.onAction,
  });

  final String errorMessage;
  final ValueChanged<PaymentFailureAction> onAction;

  static Future<PaymentFailureAction?> show(
    BuildContext context, {
    required String errorMessage,
  }) {
    return showModalBottomSheet<PaymentFailureAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingPaymentFailureSheet(
        errorMessage: errorMessage,
        onAction: (action) => Navigator.of(ctx).pop(action),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppColors.white15, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Warning Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 38,
                ),
              ),
            ),

            AppSpacing.verticalBase,

            Text(
              'Payment Incomplete',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            AppSpacing.verticalSm,

            Text(
              errorMessage.isNotEmpty
                  ? errorMessage
                  : 'We were unable to process your payment. Your booking information is safely saved so you can try again.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            AppSpacing.verticalXl,

            // Primary: Try Again
            BookingPrimaryButton(
              label: 'Try Again',
              onTap: () => onAction(PaymentFailureAction.retry),
            ),

            AppSpacing.verticalSm,

            // Secondary: Change Method
            OutlinedButton(
              onPressed: () => onAction(PaymentFailureAction.changeMethod),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: AppColors.white.withValues(alpha: 0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.lgAll,
                ),
              ),
              child: Text(
                'Change Payment Method',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            AppSpacing.verticalSm,

            // Dismiss
            TextButton(
              onPressed: () => onAction(PaymentFailureAction.cancel),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
