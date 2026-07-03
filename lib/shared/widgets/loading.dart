import 'package:flutter/material.dart';
import '../../app/assets.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Lottie.asset(
          AppAssets.lottieLoader,
          height: 70,
          width: 70,
        ),
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, this.size = 70});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: AppColors.black.withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Center(
              child: Lottie.asset(
                AppAssets.lottieCircleLoader,
                height: size,
                width: size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}