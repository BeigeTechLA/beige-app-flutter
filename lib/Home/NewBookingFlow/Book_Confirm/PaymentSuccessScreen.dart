import 'package:beige/MainScreen.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../auth/login_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🎉 LOTTIE SUCCESS
              Lottie.asset(
                "assets/lottie/Untitled file.json",
                height: 180,
                repeat: false,
              ),

              const SizedBox(height: 20),

              /// ✅ TITLE
              const Text(
                "Paid Successfully",
                style: TextStyle(
                  color: ColorCode.kButtonColor,
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
                  color: ColorCode.kWhiteOpacity70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              /// 📋 SUMMARY CARD


              const SizedBox(height: 30),

              /// 🔘 BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  Mainscreen(),
                      ),
                          (route) => false,
                    );
                  },

                  child: const Text(
                    "View Summary",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      color: Colors.black,
                      fontWeight: FontWeight.w500
                      ,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
