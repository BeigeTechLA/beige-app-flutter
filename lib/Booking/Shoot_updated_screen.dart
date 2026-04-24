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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🎉 LOTTIE SUCCESS
                Lottie.asset(
                  "assets/lottie/success_animation.json",
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
                /*        SizedBox(
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
                ),*/


              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Mainscreen()
              ),
                  (route) => false,
            );
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
    );

  }
}
