import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/util/role_label.dart';
import '../../domain/models/directory_participant.dart';

class InvitedMemberCard extends StatelessWidget {
  const InvitedMemberCard({
    super.key,
    required this.participant,
    required this.onChanged,
    this.isSelected,
  });

  final DirectoryParticipant participant;
  final ValueChanged<bool?>? onChanged;
  final bool? isSelected;

  @override
  Widget build(BuildContext context) {
    final isClient = participant.type == 'client';

    if (isClient) {
      // Client card: Beige background, dark text, no checkbox
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.email ?? participant.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CLIENT',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.onPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Client',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Optional card: Dark background, checkbox, right-side pill (Optional / Selected)
      final selected = isSelected ?? participant.isSelected;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!selected),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white6,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.white30, width: 0.5),
          ),
          child: Row(
            children: [
              Theme(
                data: ThemeData(unselectedWidgetColor: AppColors.textSecondary),
                child: Checkbox(
                  value: selected,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  checkColor: AppColors.onPrimary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleLabel(
                        participant.role ?? participant.type,
                      ).toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(24),
                  border: selected
                      ? null
                      : Border.all(color: AppColors.dividerDark),
                ),
                child: Text(
                  selected ? 'Selected' : 'Optional',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: selected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
