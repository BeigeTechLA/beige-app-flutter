import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/util/role_label.dart';
import '../../domain/models/directory_participant.dart';

class SelectedParticipantChip extends StatelessWidget {
  const SelectedParticipantChip({
    super.key,
    required this.participant,
    required this.onDeleted,
  });

  final DirectoryParticipant participant;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final label = roleLabel(participant.role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.dividerDark),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: participant.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (label.isNotEmpty)
                  TextSpan(
                    text: ' ($label)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
