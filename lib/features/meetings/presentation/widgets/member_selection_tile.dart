import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/util/role_label.dart';
import '../../domain/models/directory_participant.dart';

class MemberSelectionTile extends StatelessWidget {
  const MemberSelectionTile({
    super.key,
    required this.participant,
    required this.isSelected,
    required this.onTap,
  });

  final DirectoryParticipant participant;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Get initials for Avatar
    final nameParts = participant.name.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (participant.name.isNotEmpty
            ? participant.name[0].toUpperCase()
            : '?');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerDark,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Initials Avatar
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWarm,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name, Role, Email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textOffWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Builder(builder: (_) {
                    final label = roleLabel(participant.role);
                    if (label.isEmpty) return const SizedBox.shrink();
                    return Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                  if (participant.email != null && participant.email!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      participant.email!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Gradient checkbox — mirrors the Staff / Creative Partner tab
            // pill treatment (goldHorizontalGradient).
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.goldHorizontalGradient : null,
                  color: isSelected ? null : AppColors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
