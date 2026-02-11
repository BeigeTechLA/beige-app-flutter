import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utility/ColorCode.dart';

class PasswordSuccessfull extends StatefulWidget {
  const PasswordSuccessfull({super.key});

  @override
  State<PasswordSuccessfull> createState() => _PasswordSuccessfullState();
}

class _PasswordSuccessfullState extends State<PasswordSuccessfull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C), // dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ✅ SUCCESS IMAGE
            Lottie.asset(
              "assets/lottie/Untitled file.json",
              height: 180,
              repeat: false,
            ),

            const SizedBox(height: 24),

            /// ✅ TITLE TEXT
            const Text(
              "You're All Set",
              style: TextStyle(
                color: ColorCode.kButtonColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: "Unbounded",


              ),
            ),

            const SizedBox(height: 8),

            /// ✅ SUBTITLE TEXT
            const Text(
              "Congratulations! Your password has been\nchanged successfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorCode.kWhiteOpacity70,
                fontSize: 14,
                fontFamily: "Outfit",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
