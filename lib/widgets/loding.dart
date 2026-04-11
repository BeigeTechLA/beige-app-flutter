import 'dart:ui';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill( // 🔥 full screen cover
      child: Container(
        color: ColorCode.bcakgroundcolor,
        child: Center(
          child: Lottie.asset(
            'assets/lottie/loder_.json',
            height: 70,
            width: 70,
          ),
        ),
      ),
    );
  }
}