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
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Initials Avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF322F2A),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
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
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Custom Checkbox
            Theme(
              data: ThemeData(
                unselectedWidgetColor: AppColors.textSecondary,
              ),
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                activeColor: AppColors.primary,
                checkColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
