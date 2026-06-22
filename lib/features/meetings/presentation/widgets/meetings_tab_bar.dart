import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/meetings_tab.dart';

/// Pill segmented tab bar — Upcoming / Invited / Completed. Active pill uses
/// the gold horizontal gradient; inactive pills sit flat on the surface.
///
/// The Invited pill optionally shows a numeric badge with the count of
/// pending invites — surfaces the Accept/Decline workflow without forcing
/// users to tap into the tab to discover it.
class MeetingsTabBar extends StatelessWidget {
  const MeetingsTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.invitedBadgeCount = 0,
  });

  final MeetingsTab selected;
  final ValueChanged<MeetingsTab> onChanged;
  final int invitedBadgeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid,
        borderRadius: AppRadii.xlAll,
      ),
      child: Row(
        children: [
          for (final tab in MeetingsTab.values)
            Expanded(
              child: _Pill(
                label: tab.label,
                isActive: tab == selected,
                badgeCount:
                    tab == MeetingsTab.invited ? invitedBadgeCount : 0,
                onTap: () => onChanged(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isActive,
    required this.badgeCount,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: badgeCount > 0
          ? '$label meetings, $badgeCount pending'
          : '$label meetings',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.goldHorizontalGradient : null,
            borderRadius: AppRadii.mldAll,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isActive ? AppColors.textHeading : AppColors.white30,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                _Badge(count: badgeCount, isActive: isActive),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.isActive});

  final int count;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.textHeading : AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTextStyles.labelSmall.copyWith(
          color: isActive ? AppColors.primary : AppColors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
