import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/entities/booking_flow_enums.dart';
import 'gradient_radio.dart';
import 'wizard_bottom_bar.dart';

/// "When & Where Are You Planning To Shoot?" bottom sheet (Screen 3).
///
/// Lets the user pick [ScheduleMode.dated] ("I have a date") or
/// [ScheduleMode.deferred] ("I'll confirm later"). The deferred option is
/// rendered inert until [enableDeferred] is true (Phase 3 — Choose Date Later).
///
/// Returns the chosen [ScheduleMode] on Continue, or `null` if dismissed.
class ScheduleChoiceSheet extends StatefulWidget {
  const ScheduleChoiceSheet({
    super.key,
    this.initial,
    this.enableDeferred = false,
  });

  final ScheduleMode? initial;
  final bool enableDeferred;

  static Future<ScheduleMode?> show(
    BuildContext context, {
    ScheduleMode? initial,
    bool enableDeferred = false,
  }) {
    return showModalBottomSheet<ScheduleMode>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
      ),
      builder: (_) =>
          ScheduleChoiceSheet(initial: initial, enableDeferred: enableDeferred),
    );
  }

  @override
  State<ScheduleChoiceSheet> createState() => _ScheduleChoiceSheetState();
}

class _ScheduleChoiceSheetState extends State<ScheduleChoiceSheet> {
  ScheduleMode? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white24,
                  borderRadius: AppRadii.smAll,
                ),
              ),
            ),
            AppSpacing.verticalBase,
            Row(
              children: [
                Expanded(
                  child: Text(
                    'When & Where Are You Planning To Shoot?',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalBase,
            _choice(
              mode: ScheduleMode.dated,
              title: 'I have a date',
              subtitle: 'Specific shoot day and time',
            ),
            const SizedBox(height: AppSpacing.md),
            _choice(
              mode: ScheduleMode.deferred,
              title: "I'll confirm later",
              subtitle: 'Hold my spot for 30 days',
              disabled: !widget.enableDeferred,
            ),
            AppSpacing.verticalXl,
            WizardBottomBar(
              onBack: () => Navigator.of(context).pop(),
              onContinue: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choice({
    required ScheduleMode mode,
    required String title,
    required String subtitle,
    bool disabled = false,
  }) {
    final selected = _selected == mode;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => setState(() => _selected = mode),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: selected ? null : AppColors.background,
            gradient: selected ? AppColors.goldHorizontalGradient : null,
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: selected ? AppColors.transparent : AppColors.white15,
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
                      style: AppTextStyles.bodyLargeMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? AppColors.black
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: selected
                            ? AppColors.textHeading
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GradientRadio(selected: selected, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
