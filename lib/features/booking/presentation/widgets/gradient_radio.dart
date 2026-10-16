import 'package:flutter/material.dart';

import '../../../../app/colors.dart';

/// Gold-gradient radio indicator used across the Book-a-Shoot v2 flow.
///
/// Matches the shoot-type selector: a bordered circle that fills with the gold
/// gradient and shows a small black dot when selected. Centralised so every
/// single-choice control in the wizard looks identical.
class GradientRadio extends StatelessWidget {
  const GradientRadio({super.key, required this.selected, this.size = 24});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.goldGradientLight,
                  AppColors.goldGradientDark,
                ],
              )
            : null,
        border: Border.all(color: AppColors.white54),
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(radius: 3, backgroundColor: AppColors.black),
            )
          : null,
    );
  }
}
