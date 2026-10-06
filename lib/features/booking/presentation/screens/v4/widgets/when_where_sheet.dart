import 'package:flutter/material.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';

/// "When & Where" choice sheet (Figma when-and-where.png). Returns the chosen
/// [BookingScheduleMode], or null if dismissed without Continue.
class WhenWhereSheet extends StatefulWidget {
  const WhenWhereSheet({super.key, this.initial});

  final BookingScheduleMode? initial;

  static Future<BookingScheduleMode?> show(
    BuildContext context, {
    BookingScheduleMode? initial,
  }) {
    return showModalBottomSheet<BookingScheduleMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => WhenWhereSheet(initial: initial),
    );
  }

  @override
  State<WhenWhereSheet> createState() => _WhenWhereSheetState();
}

class _WhenWhereSheetState extends State<WhenWhereSheet> {
  late BookingScheduleMode _mode =
      widget.initial ?? BookingScheduleMode.scheduled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.base,
        right: AppSpacing.base,
        top: AppSpacing.md,
        bottom: AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white30,
                borderRadius: AppRadii.enormousAll,
              ),
            ),
          ),
          AppSpacing.verticalBase,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'When & Where Are You\nPlanning To Shoot?',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: AppColors.white, size: 24),
              ),
            ],
          ),
          AppSpacing.verticalBase,
          Divider(color: AppColors.white30, height: 1),
          AppSpacing.verticalBase,
          _optionCard(
            mode: BookingScheduleMode.scheduled,
            title: 'I have a date',
            subtitle: 'Specific shoot day and time',
          ),
          AppSpacing.verticalMd,
          _optionCard(
            mode: BookingScheduleMode.deferred,
            title: "I'll confirm later",
            subtitle: 'Hold my spot for 30 days',
          ),
          AppSpacing.verticalXl,
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.gapHBase,
              Expanded(
                child: BookingPrimaryButton(
                  label: 'Continue',
                  onTap: () => Navigator.of(context).pop(_mode),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _optionCard({
    required BookingScheduleMode mode,
    required String title,
    required String subtitle,
  }) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.iconBackground,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.white30,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: selected ? AppColors.black : AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selected ? AppColors.black : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.black : AppColors.transparent,
                border: Border.all(
                  color: selected ? AppColors.black : AppColors.white30,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.circle, size: 8, color: AppColors.primary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
