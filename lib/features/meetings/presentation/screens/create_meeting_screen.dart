import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/colors.dart';
import '../../../../app/route_names.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/util/picker_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/client_shoots_provider.dart';
import '../providers/create_meeting_notifier.dart';
import '../providers/create_meeting_state.dart';
import '../providers/meetings_list_notifier.dart';
import '../widgets/meeting_participant_picker_sheet.dart';
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
  static final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _openParticipantPicker() async {
    final state = ref.read(createMeetingNotifierProvider);
    final shootId = state.shootId;
    if (shootId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a shoot first')),
      );
      return;
    }
    final picked = await showMeetingParticipantPickerSheet(
      context,
      bookingId: shootId,
      initialSelected: state.invitedParticipants,
    );
    if (picked == null) return;
    ref.read(createMeetingNotifierProvider.notifier).setParticipants(picked);
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
    final current = start ? state.startTime : state.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current.hour, minute: current.minute),
      builder: _timePickerTheme,
    );
    if (picked == null) return;
    final value = TimeOfDayValue(picked.hour, picked.minute);
    if (start) {
      notifier.setStartTime(value);
    } else {
      notifier.setEndTime(value);
    }
  }

  Future<void> _submit() async {
    final notifier = ref.read(createMeetingNotifierProvider.notifier);
    await notifier.submit();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      labelStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      hintStyle:
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surfaceInput,
      suffixIcon: suffixIcon,
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
      if (prev?.status != next.status) {
        if (next.status == CreateMeetingSubmitStatus.success) {
          ref.invalidate(meetingsListNotifierProvider);
          context.pushReplacementNamed(RouteNames.meetingScheduled);
        } else if (next.status == CreateMeetingSubmitStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error ?? 'Could not create meeting'),
              backgroundColor: AppColors.error,
            ),
          );
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
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
                      onChanged: (opt) => notifier.setShoot(
                        shootId: opt.id,
                        name: opt.title,
                      ),
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
                                : _dateFmt.format(state.date!),
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
                                  errorText: state.hasTimes &&
                                          !state.endAfterStart
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
                        hint: 'Auto-generated or paste custom link',
                        suffixIcon: const Icon(
                          Icons.link,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        errorText: _linkCtrl.text.isNotEmpty && !state.hasLink
                            ? 'Enter a valid URL'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _openParticipantPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            label: 'Invite Participants*',
                            hint: state.shootId == null
                                ? 'Select a shoot first'
                                : 'Tap to pick from the booking roster',
                            suffixIcon: const Icon(
                              Icons.person_add_alt_1_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          controller: TextEditingController(
                            text: state.invitedParticipants.isEmpty
                                ? ''
                                : '${state.invitedParticipants.length} selected',
                          ),
                        ),
                      ),
                    ),

                    if (state.invitedParticipants.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          for (final p in state.invitedParticipants)
                            Chip(
                              label: Text(
                                p.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              backgroundColor:
                                  AppColors.white.withValues(alpha: 0.08),
                              side: const BorderSide(
                                color: AppColors.dividerDark,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              onDeleted: () =>
                                  notifier.removeParticipant(p.id),
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
      loading: () => InputDecorator(
        decoration: decoration,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
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
        final initial = shoots.any((s) => s.id == selectedId)
            ? selectedId
            : null;
        return DropdownButtonFormField<int>(
          initialValue: initial,
          dropdownColor: AppColors.surfaceStats,
          decoration: decoration,
          icon: const Icon(
            Icons.expand_more,
            color: AppColors.textSecondary,
          ),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          items: [
            for (final s in shoots)
              DropdownMenuItem(value: s.id, child: Text(s.title)),
          ],
          onChanged: (v) {
            if (v == null) return;
            final picked = shoots.firstWhere((s) => s.id == v);
            onChanged(picked);
          },
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

Widget _timePickerTheme(BuildContext ctx, Widget? child) =>
    appTimePickerTheme(ctx, child);
