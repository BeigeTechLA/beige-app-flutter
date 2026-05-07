import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/payment/presentation/providers/payment_method_notifier.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final int bookingId;
  const PaymentMethodScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  bool isProcessing = false;
  Future<void> _openStripeSheet() async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    final notifier = ref.read(
      paymentMethodNotifierProvider(widget.bookingId).notifier,
    );

    try {
      // 1. Create payment sheet
      final paymentSheet = await notifier.createPaymentSheet(
        bookingId: widget.bookingId,
      );

      if (paymentSheet == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create payment sheet")),
          );
        }
        return;
      }

      final clientSecret = paymentSheet['payment_intent_client_secret'];

      if (clientSecret == null || (clientSecret as String).isEmpty) {
        throw "Client secret missing";
      }

      // 2. Init Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerId: paymentSheet['customer_id'],
          customerEphemeralKeySecret: paymentSheet['ephemeral_key_secret'],
          merchantDisplayName: "BEIGE",
        ),
      );

      // 3. Present Stripe
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirm with backend
      final paymentIntentId = clientSecret.split('_secret').first;

      final confirmed = await notifier.confirmPayment(
        bookingId: widget.bookingId,
        paymentIntentId: paymentIntentId,
      );

      if (!confirmed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment confirmation failed")),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Payment Completed")));
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.error.localizedMessage ?? "Payment failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(
      paymentMethodNotifierProvider(widget.bookingId),
    );
    final savedCards = paymentState.savedCards;

    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                context.pop();
              },

              child: SvgPicture.asset(AppAssets.back, height: 24),
            ),

            const SizedBox(height: AppSpacing.mld),
            Text(
              "Payment Method",
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),

            Text(
              "Manage your saved payment options for\nfaster and secure checkouts.",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.white70,
              ),
            ),

            AppSpacing.verticalXxl,

            if (savedCards.isNotEmpty) ...[
              Text(
                "Saved Card",
                style: AppTextStyles.labelLarge.copyWith(
                  fontFamily: AppAssets.fontUnbounded,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                ),
              ),
              AppSpacing.verticalMd,
            ],
            if (savedCards.isNotEmpty)
              ...savedCards.map((card) {
                return InkWell(
                  onTap: () {
                    context.pushNamed(
                      RouteNames.reviewConfirm,
                      pathParameters: {
                        'bookingId': widget.bookingId.toString(),
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadii.xxlAll,
                    ),
                    child: Row(
                      children: [
                        Image.asset(AppAssets.stripeIcon, height: 28),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: Text(
                            "Stripe",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.radio_button_checked,
                          color: AppColors.paymentAccent,
                        ),
                      ],
                    ),
                  ),
                );
              }),

            /// ===== CARD SECTION =====
            Text(
              "Card",
              style: AppTextStyles.labelLarge.copyWith(
                fontFamily: AppAssets.fontUnbounded,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
            AppSpacing.verticalMd,

            InkWell(
              onTap: isProcessing ? null : _openStripeSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.mld,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.xxlAll,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                    AppSpacing.gapHMd,
                    Expanded(
                      child: Text(
                        "Add Credit or Debit Card",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: AppColors.paymentAccent,
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            /// ===== RECOMMENDED =====
            Text(
              "Recommended",
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
            ),
            AppSpacing.verticalMd,

            _paymentTile(title: "Stripe", icon: AppAssets.stripeIcon),
          ],
        ),
      ),
    );
  }

  /// ===== PAYMENT TILE =====
  Widget _paymentTile({required String title, required String icon}) {
    return InkWell(
      onTap: isProcessing ? null : _openStripeSheet,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.mld,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppRadii.xxlAll,
        ),
        child: Row(
          children: [
            Image.asset(icon, height: 26, width: 26),
            AppSpacing.gapHMd,
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.neutralGrey,
            ),
          ],
        ),
      ),
    );
  }
}
