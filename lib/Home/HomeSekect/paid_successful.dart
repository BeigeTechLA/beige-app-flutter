import 'dart:async';
import 'package:flutter/material.dart';
import '../../Booking/booking_summary_view_summary.dart';
import '../../utility/ColorCode.dart';
import 'home_booking_summary_details.dart';

class PaidSuccessful extends StatefulWidget {
  const PaidSuccessful({super.key});

  @override
  State<PaidSuccessful> createState() => _PaidSuccessfulState();
}

class _PaidSuccessfulState extends State<PaidSuccessful> {

  @override
  void initState() {
    super.initState();

    // ⏱ Auto redirect after 2 second
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// ✅ CHECK ICON
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: ColorCode.kButtonColor,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/Icons/paid_successful.png", // apni image ka path

                  fit: BoxFit.contain,
                ),

              ),

              const SizedBox(height: 20),

              /// 📝 TITLE
              const Text(
                "Paid Successful",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w600,
                  color: ColorCode.kButtonColor,
                ),
              ),

              const SizedBox(height: 8),

              /// 📝 SUB TITLE
              const Text(
                "Your payment was successful & your\nbooking is now confirmed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

              const SizedBox(height: 40),

              /// 🔘 BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeBookingSummaryDetails()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.kButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "View Summary",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
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
}
