import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meeting_status.dart';
import '../providers/cancel_meeting_notifier.dart';
import '../providers/meeting_details_providers.dart';
import '../providers/meetings_list_notifier.dart';
import '../util/launch_meeting_link.dart';
import 'meeting_participant_tile.dart';
import 'meeting_rsvp_buttons.dart';

Future<void> showMeetingDetailsSheet(
  BuildContext context, {
  required String meetingId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MeetingDetailsSheet(meetingId: meetingId),
  );
}

class MeetingDetailsSheet extends ConsumerWidget {
  const MeetingDetailsSheet({super.key, required this.meetingId});

  final String meetingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(meetingDetailsProvider(meetingId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadii.topSheet,
          ),
          child: SafeArea(
            top: false,
            child: detailsAsync.when(
              data: (m) => _DetailsBody(
                meeting: m,
                scrollController: scrollController,
                isOwner: _isOwner(ref, m),
              ),
              loading: () => _SheetShell(
                scrollController: scrollController,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              error: (e, _) => _SheetShell(
                scrollController: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                      AppSpacing.verticalBase,
                      Text(
                        'Could not load meeting',
                        style: AppTextStyles.titleSmall,
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        '$e',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.verticalBase,
                      AppButton(
                        label: 'Retry',
                        fullWidth: false,
                        onPressed: () =>
                            ref.invalidate(meetingDetailsProvider(meetingId)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isOwner(WidgetRef ref, Meeting m) {
    final me = ref.read(currentUserIdProvider);
    if (me == null || m.createdById == null) return false;
    return me == m.createdById;
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.scrollController, required this.child});
  final ScrollController scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
        const _Handle(),
        const _SheetHeader(),
        child,
      ],
    );
  }
}

class _DetailsBody extends ConsumerWidget {
  const _DetailsBody({
    required this.meeting,
    required this.scrollController,
    required this.isOwner,
  });

  final Meeting meeting;
  final ScrollController scrollController;
  final bool isOwner;

  static final _dateFmt = DateFormat('MMM d');
  static final _timeFmt = DateFormat('hh:mm a');

  String get _dateTimeLabel =>
      '${_dateFmt.format(meeting.startAt)}, ${_timeFmt.format(meeting.startAt)} - ${_timeFmt.format(meeting.endAt)}';

  /// Current user's RSVP state on this meeting, or `null` when they aren't a
  /// listed participant. Used to surface the "(Accepted)" / "(Rejected)"
  /// label under the title.
  MeetingResponse? _myRsvp(WidgetRef ref) {
    final me = ref.read(currentUserIdProvider);
    if (me == null) return null;
    for (final p in meeting.participants) {
      if (p.id == me) return p.rsvpStatus;
    }
    return null;
  }

  void _onEdit(BuildContext context) {
    Navigator.of(context).pop();
    context.pushNamed(
      RouteNames.meetingEdit,
      pathParameters: {'id': meeting.id},
    );
  }

  void _onJoin(BuildContext context) {
    launchMeetingLink(context, meeting.link);
  }

  Future<void> _onCopyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: meeting.link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied')),
    );
  }

  Future<void> _onCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Cancel meeting?', style: AppTextStyles.titleSmall),
        content: Text(
          'Participants will be notified that this meeting was cancelled.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep meeting',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Cancel meeting',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(cancelMeetingNotifierProvider(meeting.id).notifier)
        .cancel();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelState = ref.watch(cancelMeetingNotifierProvider(meeting.id));

    ref.listen<CancelMeetingState>(
      cancelMeetingNotifierProvider(meeting.id),
      (prev, next) {
        if (prev?.status == next.status) return;
        switch (next.status) {
          case CancelMeetingStatus.done:
            ref.invalidate(meetingsListNotifierProvider);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting cancelled')),
            );
          case CancelMeetingStatus.error:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error ?? 'Could not cancel meeting'),
                backgroundColor: AppColors.error,
              ),
            );
          case _:
            break;
        }
      },
    );

    final cancelling = cancelState.status == CancelMeetingStatus.submitting;
    final myRsvp = _myRsvp(ref);
    final agendaText = meeting.description.isNotEmpty
        ? meeting.description
        : meeting.agenda.join('\n');

    return Stack(
      children: [
        ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const _Handle(),
            const _SheetHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusPill(status: meeting.status),
                      const Spacer(),
                      if (isOwner)
                        IconButton(
                          tooltip: 'Edit meeting',
                          onPressed: () => _onEdit(context),
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.verticalBase,
                  Text(
                    meeting.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (myRsvp == MeetingResponse.accepted ||
                      myRsvp == MeetingResponse.declined) ...[
                    const SizedBox(height: 4),
                    Text(
                      myRsvp == MeetingResponse.accepted
                          ? '(Accepted)'
                          : '(Rejected)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: myRsvp == MeetingResponse.accepted
                            ? AppColors.greenBright
                            : const Color(0xFFD33732),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  AppSpacing.verticalBase,
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date & Time',
                        value: _dateTimeLabel,
                      ),
                      AppSpacing.verticalBase,
                      _InfoRow(
                        icon: Icons.videocam_outlined,
                        label: meeting.platform.label.toLowerCase(),
                        value: meeting.link,
                        trailing: _SquareIconButton(
                          icon: Icons.copy_outlined,
                          color: AppColors.textPrimary,
                          onTap: () => _onCopyLink(context),
                        ),
                      ),
                      if (meeting.project.isNotEmpty) ...[
                        AppSpacing.verticalBase,
                        _InfoRow(
                          icon: Icons.work_outline,
                          label: 'Related Shoot',
                          value: meeting.project,
                        ),
                      ],
                    ],
                  ),
                  if (agendaText.isNotEmpty) ...[
                    AppSpacing.verticalXl,
                    Text(
                      'Agenda',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSm,
                    _AgendaCard(text: agendaText),
                  ],
                  AppSpacing.verticalXl,
                  Text(
                    'Participants (${meeting.participants.length})',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  for (final p in meeting.participants) ...[
                    MeetingParticipantTile(participant: p),
                    AppSpacing.verticalSm,
                  ],
                  AppSpacing.verticalBase,
                  MeetingRsvpButtons(meeting: meeting),
                  AppSpacing.verticalXl,
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.dividerDark, width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.base,
            ),
            child: Row(
              children: [
                if (isOwner) ...[
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      fullWidth: true,
                      variant: AppButtonVariant.outline,
                      isLoading: cancelling,
                      onPressed:
                          cancelling ? null : () => _onCancel(context, ref),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: AppButton(
                    label: 'Join Meeting',
                    fullWidth: true,
                    icon: const Icon(
                      Icons.videocam_outlined,
                      color: AppColors.onPrimary,
                      size: 18,
                    ),
                    onPressed: () => _onJoin(context),
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

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Center(
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.dividerDark,
            borderRadius: AppRadii.fullAll,
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.base,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(
                'Meeting Details',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.dividerDark, height: 1),
        AppSpacing.verticalBase,
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final MeetingStatus status;

  Color get _bg {
    switch (status) {
      case MeetingStatus.initiated:
        return AppColors.lightGoldenBg;
      case MeetingStatus.completed:
        return AppColors.softMint;
      case MeetingStatus.revision:
        return const Color(0xFFFFEAE0);
      case MeetingStatus.upcoming:
        return AppColors.blueIce;
    }
  }

  Color get _fg {
    switch (status) {
      case MeetingStatus.initiated:
        return const Color(0xFF8A5C1F);
      case MeetingStatus.completed:
        return AppColors.greenForest;
      case MeetingStatus.revision:
        return AppColors.orangeBright;
      case MeetingStatus.upcoming:
        return AppColors.blueRoyal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadii.fullAll,
      ),
      child: Text(
        status.label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.mdAll,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
