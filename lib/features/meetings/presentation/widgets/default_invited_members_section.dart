import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../providers/create_meeting_notifier.dart';
import 'invited_member_card.dart';

class DefaultInvitedMembersSection extends ConsumerWidget {
  const DefaultInvitedMembersSection({
    super.key,
    required this.onInviteAdditionalTap,
  });

  final VoidCallback onInviteAdditionalTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createMeetingNotifierProvider);
    final notifier = ref.read(createMeetingNotifierProvider.notifier);

    // If no shoot is selected, don't show the default members list
    if (state.shootId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Invited Members',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (state.defaultInvitedMembers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'No default members associated with this shoot.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...state.defaultInvitedMembers.map((member) {
            final selected = !member.isOptional ||
                state.optionalSelectedDefaultMembers.contains(member);
            return InvitedMemberCard(
              participant: member,
              isSelected: selected,
              onChanged: member.isOptional
                  ? (_) => notifier.toggleOptionalDefaultMember(member)
                  : null,
            );
          }),
        const SizedBox(height: 8),
        InkWell(
          onTap: onInviteAdditionalTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  'Invite Additional Members',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
