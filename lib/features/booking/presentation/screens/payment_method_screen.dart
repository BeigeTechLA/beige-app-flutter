import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/route_names.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Completed")),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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

    return AppScaffold(backgroundColor: AppColors.background,

      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              InkWell(
                onTap: () {
                  context.pop();
                },

                child: SvgPicture.asset(AppAssets.back, height: 24),
              ),

              const SizedBox(height: 14),
              Text(
                "Payment Method",
                style: TextStyle(
                  fontFamily: AppAssets.fontUnbounded,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,

                  color: AppColors.white,
                ),
              ),


              const Text(
                "Manage your saved payment options for\nfaster and secure checkouts.",
                style: TextStyle(
                    fontFamily: AppAssets.fontOutfit,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white70
                ),
              ),

              const SizedBox(height: 24),


              if (savedCards.isNotEmpty) ...[
                const Text(
                  "Saved Card",
                  style: TextStyle(
                    fontFamily: AppAssets.fontUnbounded,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (savedCards.isNotEmpty)
                ...savedCards.map((card) {
                  return InkWell(
                    onTap: () {
                      context.pushNamed(
                        RouteNames.reviewConfirm,
                        pathParameters: {'bookingId': widget.bookingId.toString()},
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            AppAssets.stripeIcon,
                            height: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Stripe",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const Icon(
                            Icons.radio_button_checked,
                            color: Color(0xFFFFE6A5),
                          )
                        ],
                      ),
                    ),
                  );
                }),



              /// ===== CARD SECTION =====
              Text(
                "Card",
                style: TextStyle(
                    fontFamily: AppAssets.fontUnbounded,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: isProcessing ? null : _openStripeSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Add Credit or Debit Card",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6A5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// ===== RECOMMENDED =====
              const Text(
                "Recommended",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              _paymentTile(
                title: "Stripe",
                icon: AppAssets.stripeIcon,
              ),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              height: 26,
              width: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
