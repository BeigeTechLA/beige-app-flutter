import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../shared/util/picker_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/models/meeting_platform.dart';
import '../providers/client_shoots_provider.dart';
import '../providers/create_meeting_notifier.dart';
import '../providers/create_meeting_state.dart';
import '../providers/meetings_list_notifier.dart';
import '../widgets/default_invited_members_section.dart';
import '../widgets/invite_additional_members_bottom_sheet.dart';
import '../widgets/meeting_type_dropdown.dart';
import '../widgets/selected_participant_chip.dart';
import '../widgets/select_meet_link_picker.dart';

class CreateMeetingScreen extends ConsumerStatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  ConsumerState<CreateMeetingScreen> createState() =>
      _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _openInviteAdditionalBottomSheet() async {
    final state = ref.read(createMeetingNotifierProvider);
    final shootId = state.shootId;
    if (shootId == null) {
      TopMessage.show(context, 'Select a shoot first');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InviteAdditionalMembersBottomSheet(),
    );
  }

  Future<void> _pickDate() async {
    final notifier = ref.read(createMeetingNotifierProvider.notifier);
    final current = ref.read(createMeetingNotifierProvider).date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: _datePickerTheme,
    );
    if (picked == null) return;
    notifier.setDate(picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final notifier = ref.read(createMeetingNotifierProvider.notifier);
    final state = ref.read(createMeetingNotifierProvider);
    final date = state.date;
    if (date == null) {
      TopMessage.show(context, 'Select a date first');
      return;
    }

    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    // Compute lower bound as a DateTime on the picked date.
    DateTime lowerBound;
    if (start) {
      lowerBound = isToday
          ? now.add(const Duration(hours: 2))
          : DateTime(date.year, date.month, date.day, 0, 0);
    } else {
      final s = state.startTime;
      if (s == null) {
        TopMessage.show(context, 'Select start time first');
        return;
      }
      lowerBound = DateTime(
        date.year,
        date.month,
        date.day,
        s.hour,
        s.minute,
      ).add(const Duration(hours: 1));
    }
    final upperBound = DateTime(date.year, date.month, date.day, 23, 59);
    if (!lowerBound.isBefore(upperBound)) {
      TopMessage.show(
        context,
        start
            ? 'No available start time today (needs 2h buffer)'
            : 'No available end time — pick a later date',
      );
      return;
    }

    final current = start ? state.startTime : state.endTime;
    DateTime initial = current == null
        ? lowerBound
        : DateTime(
            date.year,
            date.month,
            date.day,
            current.hour,
            current.minute,
          );
    if (initial.isBefore(lowerBound)) initial = lowerBound;
    if (initial.isAfter(upperBound)) initial = upperBound;

    DateTime tempPicked = initial;
    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(tempPicked),
                    child: Text(
                      'Done',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: false,
                    minuteInterval: 5,
                    initialDateTime: _snapToInterval(initial, 5),
                    minimumDate: lowerBound,
                    maximumDate: upperBound,
                    onDateTimeChanged: (v) => tempPicked = v,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null) return;
    DateTime finalPick = result;
    if (finalPick.isBefore(lowerBound)) finalPick = lowerBound;
    if (finalPick.isAfter(upperBound)) finalPick = upperBound;
    final value = TimeOfDayValue(finalPick.hour, finalPick.minute);
    if (start) {
      notifier.setStartTime(value);
    } else {
      notifier.setEndTime(value);
    }
  }

  DateTime _snapToInterval(DateTime dt, int minuteInterval) {
    final remainder = dt.minute % minuteInterval;
    if (remainder == 0) return dt;
    final add = minuteInterval - remainder;
    return dt.add(Duration(minutes: add));
  }

  Future<void> _submit() async {
    final notifier = ref.read(createMeetingNotifierProvider.notifier);
    await notifier.submit();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
    BoxConstraints? suffixIconConstraints,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      filled: true,
      fillColor: AppColors.surfaceInput,
      suffixIcon: suffixIcon,
      suffixIconConstraints: suffixIconConstraints,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createMeetingNotifierProvider);
    final notifier = ref.read(createMeetingNotifierProvider.notifier);

    ref.listen<CreateMeetingState>(createMeetingNotifierProvider, (prev, next) {
      if (prev?.title != next.title && _titleCtrl.text != next.title) {
        _titleCtrl.text = next.title;
        _titleCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _titleCtrl.text.length),
        );
      }

      if (prev?.status != next.status) {
        if (next.status == CreateMeetingSubmitStatus.success) {
          ref.read(meetingsListNotifierProvider.notifier).refresh();
          context.pushReplacementNamed(RouteNames.meetingScheduled);
        } else if (next.status == CreateMeetingSubmitStatus.error) {
          TopMessage.show(context, next.error ?? 'Could not create meeting');
        }
      }

      if (prev?.linkGenStatus != next.linkGenStatus) {
        if (next.linkGenStatus == MeetLinkGenerationStatus.success) {
          if (_linkCtrl.text != next.link) {
            _linkCtrl.text = next.link;
            _linkCtrl.selection = TextSelection.fromPosition(
              TextPosition(offset: _linkCtrl.text.length),
            );
          }
        } else if (next.linkGenStatus == MeetLinkGenerationStatus.error) {
          TopMessage.show(
            context,
            next.linkGenError ??
                'Something went wrong. Please try again after sometime.',
          );
          notifier.clearLinkGenError();
        }
      }
    });

    final submitting = state.status == CreateMeetingSubmitStatus.submitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 12.0),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: SvgPicture.asset(AppAssets.back, height: 24),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Meeting',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Participants will receive a meeting link and reminder.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _titleCtrl,
                      onChanged: notifier.setTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _inputDecoration(
                        label: 'Title*',
                        hint: 'e.g. Pre-Production Kickoff',
                      ),
                    ),
                    const SizedBox(height: 16),

                    _ShootDropdown(
                      selectedId: state.shootId,
                      decoration: _inputDecoration(
                        label: 'Select Shoot*',
                        hint: 'Select shoot/project',
                      ),
                      onChanged: (opt) => notifier.setShoot(opt),
                    ),
                    const SizedBox(height: 16),

                    MeetingTypeDropdown(
                      selected: state.meetingType,
                      decoration: _inputDecoration(label: 'Meeting Type'),
                      onChanged: notifier.setMeetingType,
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            label: 'Add Date',
                            hint: 'Select date',
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          controller: TextEditingController(
                            text: state.date == null
                                ? ''
                                : DateTimeUtils.formatMeetingDate(state.date!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(start: true),
                            child: AbsorbPointer(
                              child: TextFormField(
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: _inputDecoration(
                                  label: 'Start Time',
                                  hint: '--:--',
                                ),
                                controller: TextEditingController(
                                  text: state.startTime == null
                                      ? ''
                                      : _formatTime(state.startTime!),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(start: false),
                            child: AbsorbPointer(
                              child: TextFormField(
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: _inputDecoration(
                                  label: 'End Time',
                                  hint: '--:--',
                                  errorText:
                                      state.hasTimes && !state.endAfterStart
                                      ? 'End must be after start'
                                      : null,
                                ),
                                controller: TextEditingController(
                                  text: state.endTime == null
                                      ? ''
                                      : _formatTime(state.endTime!),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      minLines: 3,
                      onChanged: notifier.setDescription,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _inputDecoration(
                        label: 'Description',
                        hint: 'What is this meeting about?',
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Select Meet Links',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectMeetLinkPicker(
                      selected: state.platform,
                      onChanged: notifier.setPlatform,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _linkCtrl,
                      keyboardType: TextInputType.url,
                      onChanged: notifier.setLink,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: _inputDecoration(
                        label: 'Attach Meet Link',
                        hint: 'Auto-generated google meet link..',
                        suffixIcon: state.platform == MeetingPlatform.meet
                            ? _GenerateMeetLinkButton(
                                enabled:
                                    state.canGenerateMeetLink &&
                                    state.linkGenStatus !=
                                        MeetLinkGenerationStatus.loading,
                                loading:
                                    state.linkGenStatus ==
                                    MeetLinkGenerationStatus.loading,
                                onPressed: notifier.generateMeetLink,
                              )
                            : const Icon(
                                Icons.link,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        errorText: _linkCtrl.text.isNotEmpty && !state.hasLink
                            ? 'Enter a valid URL'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    DefaultInvitedMembersSection(
                      onInviteAdditionalTap: _openInviteAdditionalBottomSheet,
                    ),

                    if (state.selectedAdditionalStaffMembers.isNotEmpty ||
                        state
                            .selectedAdditionalCreativePartners
                            .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          ...state.selectedAdditionalStaffMembers.map(
                            (p) => SelectedParticipantChip(
                              participant: p,
                              onDeleted: () =>
                                  notifier.removeAdditionalMember(p.id),
                            ),
                          ),
                          ...state.selectedAdditionalCreativePartners.map(
                            (p) => SelectedParticipantChip(
                              participant: p,
                              onDeleted: () =>
                                  notifier.removeAdditionalMember(p.id),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    Text(
                      'Reminder',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ReminderPill(
                          label: '15 min',
                          isActive: state.reminderMinutes == 15,
                          onTap: () => notifier.setReminder(15),
                        ),
                        const SizedBox(width: 8),
                        _ReminderPill(
                          label: '30 min',
                          isActive: state.reminderMinutes == 30,
                          onTap: () => notifier.setReminder(30),
                        ),
                        const SizedBox(width: 8),
                        _ReminderPill(
                          label: '1 hour',
                          isActive: state.reminderMinutes == 60,
                          onTap: () => notifier.setReminder(60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.dividerDark),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'All invited participants will receive an email with the meeting link and calendar invite.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    AppButton(
                      label: 'Create & Send Invite',
                      fullWidth: true,
                      isLoading: submitting,
                      onPressed: state.isValid && !submitting ? _submit : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShootDropdown extends ConsumerWidget {
  const _ShootDropdown({
    required this.selectedId,
    required this.decoration,
    required this.onChanged,
  });

  final int? selectedId;
  final InputDecoration decoration;
  final ValueChanged<ShootOption> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shootsAsync = ref.watch(clientShootsProvider);

    return shootsAsync.when(
      loading: () => AbsorbPointer(
        absorbing: true,
        child: InputDecorator(
          decoration: decoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Loading projects…',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
      error: (e, _) => InputDecorator(
        decoration: decoration.copyWith(
          errorText: 'Could not load shoots — pull to retry',
        ),
        child: TextButton(
          onPressed: () => ref.invalidate(clientShootsProvider),
          child: Text(
            'Retry',
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      data: (shoots) {
        if (shoots.isEmpty) {
          return InputDecorator(
            decoration: decoration.copyWith(
              errorText: 'No upcoming shoots — book one to schedule a meeting',
            ),
            child: const SizedBox(height: 18),
          );
        }
        final selected = shoots.where((s) => s.id == selectedId).firstOrNull;
        return GestureDetector(
          onTap: () async {
            final picked = await showModalBottomSheet<ShootOption>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _ShootPickerBottomSheet(
                shoots: shoots,
                selectedId: selectedId,
              ),
            );
            if (picked != null) onChanged(picked);
          },
          child: AbsorbPointer(
            child: TextFormField(
              key: ValueKey(selected?.id ?? 'none'),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              readOnly: true,
              decoration: decoration.copyWith(
                suffixIcon: const Icon(
                  Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
              ),
              controller: TextEditingController(
                text: selected == null
                    ? ''
                    : (selected.title.trim().isNotEmpty
                          ? selected.title
                          : 'Booking #${selected.id}'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShootPickerBottomSheet extends StatefulWidget {
  const _ShootPickerBottomSheet({
    required this.shoots,
    required this.selectedId,
  });

  final List<ShootOption> shoots;
  final int? selectedId;

  @override
  State<_ShootPickerBottomSheet> createState() =>
      _ShootPickerBottomSheetState();
}

class _ShootPickerBottomSheetState extends State<_ShootPickerBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.shoots
        : widget.shoots
              .where((s) => s.title.toLowerCase().contains(q))
              .toList(growable: false);

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dividerDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select Shoot',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceInput,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: 'Search shoots…',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.dividerDark,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.dividerDark,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matching shoots',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          final isSelected = s.id == widget.selectedId;
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pop(s),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                s.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.onPrimary
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.dividerDark,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                size: 14,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(TimeOfDayValue t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final mm = t.minute.toString().padLeft(2, '0');
  final ampm = t.hour < 12 ? 'AM' : 'PM';
  return '$h:$mm $ampm';
}

Widget _datePickerTheme(BuildContext ctx, Widget? child) =>
    appDatePickerTheme(ctx, child);

class _GenerateMeetLinkButton extends StatelessWidget {
  const _GenerateMeetLinkButton({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: enabled ? AppColors.primary : AppColors.disabled,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: loading
                ? const AppCircularLoader(
                    size: 14,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.onPrimary,
                    ),
                  )
                : Text(
                    'Generate',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
