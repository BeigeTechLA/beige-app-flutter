import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';

/// Decorative side dot used by the "How It Works" timeline card to punch
/// holes into the left and right edges of the beige container.
class HomeSideDot extends StatelessWidget {
  const HomeSideDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.pillAll,
      ),
    );
  }
}
