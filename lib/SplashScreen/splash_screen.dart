import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/colors.dart';
import '../app/route_names.dart';
import '../app/text_styles.dart';
import '../core/providers/auth_state_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
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
          
          final isLoggedIn = ref.read(authStateProvider);
          if (isLoggedIn) {
            context.goNamed(RouteNames.home);
          } else {
            context.goNamed(RouteNames.onboarding);
          }
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
            color: AppColors.textHeading,
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
            bottom: MediaQuery.of(context).size.height * 0.05, // 👈 responsive bottom
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05, // 👈 side spacing
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "— Streamline your crew, equipment, & projects  —",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}