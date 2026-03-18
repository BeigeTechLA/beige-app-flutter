import 'dart:async';
import 'package:flutter/material.dart';
import 'package:beige/OnbodingScreen/onboding_screen.dart';
import '../utility/ColorCode.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentIndex = 0;
  Timer? _timer;
  bool _precacheDone = false; // ✅ double call rokne ke liye

  final List<String> centerImages = [
    "assets/Splash/Property_1.png",
    "assets/Splash/Property_2.png",
    "assets/Splash/Property_3.png",
    "assets/Splash/Property_4.png",
    "assets/Splash/Propety_5.png",
    "assets/Splash/Property_6.png",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Context safe hai yahan, aur sirf ek baar chalega
    if (!_precacheDone) {
      _precacheDone = true;
      _precacheAndStart();
    }
  }

  Future<void> _precacheAndStart() async {
    try {
      for (final path in centerImages) {
        await precacheImage(AssetImage(path), context);
      }
    } catch (e) {
      debugPrint("Precache error: $e");
    } finally {
      // ✅ Error aaye ya na aaye, animation ZAROOR chalegi
      if (mounted) _startImageSwap();
    }
  }

  void _startImageSwap() {
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (currentIndex < centerImages.length - 1) {
        setState(() {
          currentIndex++;
        });
      } else {
        timer.cancel();

        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingScreen(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 SOLID BACKGROUND
          Container(
            color: ColorCode.kHeadingColor,
          ),

          /// 🔹 CENTER IMAGE (ONLY THIS CHANGES)
          Center(
            child: Image.asset(
              centerImages[currentIndex],
              width: 240,
              fit: BoxFit.contain,
            ),
          ),

          /// 🔹 TAGLINE
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              "—  Streamline your crew, equipment, & projects  —",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 12,
                fontFamily: "Unbounded",
              ),
            ),
          ),
        ],
      ),
    );
  }
}