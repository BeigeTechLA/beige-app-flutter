import 'package:beige/Home/HomeSekect/recommended_for_you.dart';
import 'package:flutter/material.dart';
import 'package:beige/utility/ColorCode.dart';

class FindingThePerfectScreen extends StatefulWidget {
  const FindingThePerfectScreen({super.key});

  @override
  State<FindingThePerfectScreen> createState() =>
      _FindingThePerfectScreenState();
}

class _FindingThePerfectScreenState extends State<FindingThePerfectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    /// ⏱ Auto navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>  RecommendedForYou(), // 👈 next screen
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔥 GLOW + SPARKLE LOADER
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 199.5,
                  height: 199.5,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ColorCode.white
                            .withOpacity(0.35 * _controller.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.1416,
                          child: Transform.scale(
                            scale: 0.85 + (_controller.value * 0.3),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 34,
                              color: ColorCode.kButtonColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                );
              },
            ),

            const SizedBox(height: 24),

            /// 🔤 TEXT
            const Text(
              "Finding The Perfect Creator\nFor You...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: ColorCode.kButtonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _star({required double size, required double delay}) {
    return ScaleTransition(
      scale: Tween(begin: 0.6, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          Icons.auto_awesome,
          size: size,
          color: ColorCode.kButtonColor,
        ),
      ),
    );
  }

}
