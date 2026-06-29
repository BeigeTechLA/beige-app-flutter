import 'package:flutter/material.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

/// Standard Home-screen section title row: padded left/right with the title on
/// the leading edge. Style defaults match the "Featured / Explore Services"
/// header treatment; callers can override per-section.
class HomeSectionTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;

  const HomeSectionTitle({
    super.key,
    required this.title,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.insetsHXl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style ??
                AppTextStyles.labelLarge.copyWith(
                  fontFamily: AppAssets.fontUnbounded,
                  color: AppColors.white,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
