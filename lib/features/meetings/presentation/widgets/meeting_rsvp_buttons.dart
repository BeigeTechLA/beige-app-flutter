import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_response.dart';
import '../providers/meeting_details_providers.dart';
import '../providers/meeting_response_notifier.dart';
import '../providers/meetings_list_notifier.dart';

/// Accept / Decline pair shown to invited participants whose RSVP is pending.
///
/// Rendered on both the meeting list card and the details sheet. The same
/// notifier (family-keyed by meetingId) is used in both surfaces — a response
/// from one auto-collapses the buttons in the other after invalidate.
class MeetingRsvpButtons extends ConsumerWidget {
  const MeetingRsvpButtons({
    super.key,
    required this.meeting,
    this.compact = false,
  });

  final Meeting meeting;

  /// Compact mode trims paddings + uses small button size for inline use on
  /// list cards. Full mode used inside the details sheet bottom region.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    if (me == null) return const SizedBox.shrink();

    final rsvp = _viewerRsvp(me);
    // Only show when the viewer is an invited participant with no response
    // yet. `null` is treated as `pending` so legacy payloads still surface
    // the CTAs.
    if (rsvp != null && rsvp != MeetingResponse.pending) {
      return const SizedBox.shrink();
    }
    if (!_isViewerInvited(me)) return const SizedBox.shrink();

    final responseState =
        ref.watch(meetingResponseNotifierProvider(meeting.id));
    final notifier =
        ref.read(meetingResponseNotifierProvider(meeting.id).notifier);
    final submitting = responseState.isSubmitting;

    ref.listen<MeetingResponseState>(
      meetingResponseNotifierProvider(meeting.id),
      (prev, next) {
        if (prev?.status == next.status) return;
        switch (next.status) {
          case MeetingResponseStatus.accepted:
            ref.invalidate(meetingDetailsProvider(meeting.id));
            ref.invalidate(meetingsListNotifierProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting accepted')),
            );
          case MeetingResponseStatus.declined:
            ref.invalidate(meetingDetailsProvider(meeting.id));
            ref.invalidate(meetingsListNotifierProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting declined')),
            );
          case MeetingResponseStatus.error:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error ?? 'Could not submit response'),
                backgroundColor: AppColors.error,
              ),
            );
          case _:
            break;
        }
      },
    );

    final size = compact ? AppButtonSize.sm : AppButtonSize.md;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            Text(
              'You are invited',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Decline',
                  size: size,
                  fullWidth: true,
                  variant: AppButtonVariant.outline,
                  isLoading: submitting,
                  onPressed: submitting ? null : notifier.decline,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  size: size,
                  fullWidth: true,
                  isLoading: submitting,
                  onPressed: submitting ? null : notifier.accept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isViewerInvited(String me) =>
      meeting.participants.any((p) => p.id == me);

  MeetingResponse? _viewerRsvp(String me) {
    for (final p in meeting.participants) {
      if (p.id == me) return p.rsvpStatus;
    }
    return null;
  }
}
