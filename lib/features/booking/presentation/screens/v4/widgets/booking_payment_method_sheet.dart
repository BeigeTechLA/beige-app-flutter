import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';

/// Modal bottom sheet (Option A) allowing the user to explicitly select
/// between Stripe and Commas payment methods before starting checkout.
class BookingPaymentMethodSheet extends ConsumerStatefulWidget {
  const BookingPaymentMethodSheet({
    super.key,
    required this.amountLabel,
    required this.onProceed,
  });

  final String amountLabel;
  final ValueChanged<BookingPaymentMethod> onProceed;

  static Future<BookingPaymentMethod?> show(
    BuildContext context, {
    required String amountLabel,
  }) {
    return showModalBottomSheet<BookingPaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingPaymentMethodSheet(
        amountLabel: amountLabel,
        onProceed: (method) => Navigator.of(ctx).pop(method),
      ),
    );
  }

  @override
  ConsumerState<BookingPaymentMethodSheet> createState() =>
      _BookingPaymentMethodSheetState();
}

class _BookingPaymentMethodSheetState
    extends ConsumerState<BookingPaymentMethodSheet> {
  late BookingPaymentMethod _selectedMethod;

  @override
  void initState() {
    super.initState();
    _selectedMethod = ref.read(bookingPaymentNotifierProvider).selectedMethod;
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
            // Drag handle
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

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select how you would like to pay',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (widget.amountLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: AppRadii.mdAll,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      widget.amountLabel,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            AppSpacing.verticalBase,

            // Stripe Option Card
            _buildProviderCard(
              method: BookingPaymentMethod.stripe,
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, Amex, Apple Pay',
              icon: Icons.credit_card_rounded,
              badge: 'Secured by Stripe',
            ),

            AppSpacing.verticalMd,

            // Commas Option Card
            _buildProviderCard(
              method: BookingPaymentMethod.commas,
              title: 'Commas Checkout',
              subtitle: 'Pay via bank transfer, crypto or installments',
              icon: Icons.account_balance_wallet_rounded,
              badge: 'Commas Pay',
            ),

            AppSpacing.verticalXl,

            // CTA
            BookingPrimaryButton(
              label: widget.amountLabel.isNotEmpty
                  ? 'Pay ${widget.amountLabel} with ${_selectedMethod == BookingPaymentMethod.stripe ? "Stripe" : "Commas"}'
                  : 'Proceed to Payment',
              onTap: () {
                ref
                    .read(bookingPaymentNotifierProvider.notifier)
                    .selectMethod(_selectedMethod);
                widget.onProceed(_selectedMethod);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required BookingPaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceVariant,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.white15,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.white.withValues(alpha: 0.06),
                borderRadius: AppRadii.mdAll,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.white70,
                size: 22,
              ),
            ),
            AppSpacing.gapHMd,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.white30,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
