import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../MainScreen.dart';
import '../utility/ColorCode.dart';

class ShootUpdatedScreen extends StatefulWidget {
  const ShootUpdatedScreen({super.key});

  @override
  State<ShootUpdatedScreen> createState() => _ShootUpdatedScreenState();
}

class _ShootUpdatedScreenState extends State<ShootUpdatedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Shoot Updated",
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
                "Your shoot has been rescheduled with\n updated date and time.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorCode.kWhiteOpacity70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              /// 📋 SUMMARY CARD



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
}
