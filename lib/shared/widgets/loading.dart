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