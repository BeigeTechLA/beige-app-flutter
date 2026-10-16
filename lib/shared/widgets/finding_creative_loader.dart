import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Shared full-screen matching animation for both booking flows.
class FindingCreativeLoader extends StatefulWidget {
  const FindingCreativeLoader({super.key});

  @override
  State<FindingCreativeLoader> createState() => _FindingCreativeLoaderState();
}

class _FindingCreativeLoaderState extends State<FindingCreativeLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        AppColors.white.withValues(
                          alpha: 0.35 * _controller.value,
                        ),
                        AppColors.transparent,
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
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            /// 🔤 TEXT
            Text(
              "Finding The Perfect Creator\nFor You...",
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
