import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';

class AppQtyCounter extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String Function(int)? formatValue;

  const AppQtyCounter({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = formatValue?.call(value) ?? value.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        gradient: AppColors.counterGradient,
        borderRadius: AppRadii.mdAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: Icon(Icons.remove, size: 14, color: AppColors.black),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              displayValue,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textHeading,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: Icon(Icons.add, size: 14, color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}