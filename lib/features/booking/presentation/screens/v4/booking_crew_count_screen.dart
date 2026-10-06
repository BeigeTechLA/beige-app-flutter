import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_crew_count_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';

/// Screen 6 — "Your Creative Team." Four total required role counters saved
/// before edits. These are total creators, not extras above a package.
class BookingCrewCountScreen extends ConsumerStatefulWidget {
  const BookingCrewCountScreen({super.key});

  @override
  ConsumerState<BookingCrewCountScreen> createState() =>
      _BookingCrewCountScreenState();
}

class _BookingCrewCountScreenState
    extends ConsumerState<BookingCrewCountScreen> {
  late RoleCounts _counts;

  static const Map<BookingCreatorRole, String> _labels = {
    BookingCreatorRole.videographer: 'Videographer',
    BookingCreatorRole.photographer: 'Photographer',
    BookingCreatorRole.cinematographer: 'Cinematographer',
    BookingCreatorRole.photoVideoCreator: 'Hybrid Shooter (Photo + Video)',
  };

  @override
  void initState() {
    super.initState();
    _counts = ref.read(bookingFlowControllerProvider).roleCounts;
  }

  void _setRole(BookingCreatorRole role, int value) {
    if (value < 0) return;
    setState(() => _counts = _counts.withRole(role, value));
  }

  Future<void> _continue() async {
    final ok = await ref
        .read(bookingCrewCountNotifierProvider.notifier)
        .submit(_counts);
    if (!mounted) return;
    if (ok) {
      context.pushNamed(RouteNames.bookingEdits);
    } else {
      TopMessage.show(
        context,
        ref.read(bookingCrewCountNotifierProvider).error ??
            'Something went wrong',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingCrewCountNotifierProvider).isLoading;

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.crewCount),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.crewCount),
                AppSpacing.verticalXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Creative Team',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          'We recommend 1–2 Creative Partners based on your '
                          'project. You can add more if needed.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        for (final role in BookingCreatorRole.values)
                          _RoleRow(
                            label: _labels[role]!,
                            count: _counts.countFor(role),
                            onChanged: (v) => _setRole(role, v),
                          ),
                      ],
                    ),
                  ),
                ),
                BookingPrimaryButton(
                  label: 'Continue',
                  loading: isLoading,
                  enabled: _counts.total > 0,
                  onTap: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.label,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = count > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: selected ? AppColors.primary : AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.remove,
            enabled: count > 0,
            onTap: () => onChanged(count - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              '$count',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            enabled: true,
            onTap: () => onChanged(count + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.white30,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.white30,
        ),
      ),
    );
  }
}
