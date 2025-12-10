import 'package:beige/OnbodingScreen/onboding_screen.dart';
import 'package:flutter/material.dart';
// import your next screen here
// import 'package:your_app/NextScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    /// 2 SECOND DELAY THEN NAVIGATE
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),  // <-- Replace your screen here
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// FULL SCREEN BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/Splash/Splash1.png",
              fit: BoxFit.cover,
            ),
          ),

          /// CENTER IMAGE
          Center(
            child: Image.asset(
              "assets/Splash/Splash2.png",
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),

          /// TEXT AT BOTTOM
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              "- Streamline your crew, equipment, & projects -",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

