import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';

/// Full-screen modal overlay (Option A) shown during payment submission,
/// gateway presentation, and post-payment webhook verification.
class BookingPaymentProcessingOverlay extends StatelessWidget {
  const BookingPaymentProcessingOverlay({
    super.key,
    required this.state,
    required this.onRecheck,
    required this.onGoToShoots,
  });

  final BookingPaymentState state;
  final VoidCallback onRecheck;
  final VoidCallback onGoToShoots;

  @override
  Widget build(BuildContext context) {
    final isPending = state.isPendingVerification;

    return PopScope(
      canPop: isPending,
      child: Material(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.xlAll,
              border: Border.all(color: AppColors.white15, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isPending) ...[
                  // Pulse loader
                  const SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  AppSpacing.verticalBase,
                  Text(
                    _titleForStatus(state.status),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    _subtitleForStatus(state.status, state.attempts),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  // Pending Verification State
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primary,
                      size: 38,
                    ),
                  ),
                  AppSpacing.verticalBase,
                  Text(
                    'Confirmation Pending',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    'Your payment was authorized and is currently being confirmed by the server. This may take up to a minute.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  AppSpacing.verticalXl,
                  BookingPrimaryButton(
                    label: 'Check Status Again',
                    onTap: onRecheck,
                  ),
                  AppSpacing.verticalSm,
                  TextButton(
                    onPressed: onGoToShoots,
                    child: Text(
                      'View in My Shoots',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _titleForStatus(BookingPaymentStatus status) {
    switch (status) {
      case BookingPaymentStatus.submitting:
        return 'Submitting Booking';
      case BookingPaymentStatus.presentingPayment:
        return 'Connecting Payment Gateway';
      case BookingPaymentStatus.verifying:
        return 'Verifying Payment';
      default:
        return 'Processing';
    }
  }

  static String _subtitleForStatus(BookingPaymentStatus status, int attempts) {
    switch (status) {
      case BookingPaymentStatus.submitting:
        return 'Sending your shoot preferences and contact information...';
      case BookingPaymentStatus.presentingPayment:
        return 'Opening secure checkout session...';
      case BookingPaymentStatus.verifying:
        return attempts > 1
            ? 'Confirming with Beige server (check $attempts of 4)...'
            : 'Confirming payment with Beige server...';
      default:
        return 'Please wait...';
    }
  }
}
