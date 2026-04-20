import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/colors.dart';
import '../../../app/route_names.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int bookingId;
  final String fullName;
  final String phone;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.fullName,
    required this.phone,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        /// 🔥 BACK PRESS → GO TO HOME
        context.goNamed(RouteNames.home);
        return false; // ❌ prevent default back
      },
      child:Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// 🎉 LOTTIE
              Lottie.asset(
                "assets/lottie/success_animation.json",
                height: 180,
              ),

              const SizedBox(height: 20),

              /// ✅ TITLE
              const Text(
                "Paid Successfully",
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: "Unbounded",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              /// ℹ SUBTITLE
              Text(
                "Your payment was successful & your booking is now confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white70,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        /// 🔥 BUTTON AT BOTTOM
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {
              context.goNamed(RouteNames.home);
            },
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFE6C79C),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                "View Summary",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}