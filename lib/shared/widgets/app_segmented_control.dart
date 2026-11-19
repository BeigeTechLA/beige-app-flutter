import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Segmented tab selector matching the Figma spec:
/// Outer track: height 53, color #282828, border radius 12, padding 4.
/// Selected indicator: rounded rectangle radius 10 with gold gradient/color.
/// Stateless — caller owns [selectedIndex] and reacts to [onValueChanged].
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onValueChanged,
    this.height = 53,
    this.trackColor = AppColors.surfaceMid,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.indicatorRadius = const BorderRadius.all(Radius.circular(10)),
    this.padding = const EdgeInsets.all(4),
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;
  final double height;
  final Color trackColor;
  final BorderRadius borderRadius;
  final BorderRadius indicatorRadius;
  final EdgeInsetsGeometry padding;

  static const Duration _kDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: selected ? null : () => onValueChanged(index),
              child: AnimatedContainer(
                duration: _kDuration,
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.goldHorizontalGradient : null,
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: indicatorRadius,
                ),
                child: Text(
                  items[index],
                  style: AppTextStyles.labelLarge.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.white70,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
