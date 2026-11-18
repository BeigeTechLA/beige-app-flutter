import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

/// Pill-shaped segmented tab selector. Equal-width segments inside a rounded
/// track; the active segment fills with the gold [AppColors.primary] pill.
///
/// Stateless — caller owns [selectedIndex] and reacts to [onValueChanged].
class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onValueChanged,
    this.height = 44,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;
  final double height;

  static const Duration _kDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.fullAll,
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
                  color: selected ? AppColors.primary : null,
                  borderRadius: AppRadii.fullAll,
                ),
                child: Text(
                  items[index],
                  style: AppTextStyles.labelLarge.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.white60,
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
