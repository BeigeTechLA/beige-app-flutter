import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../shared/util/picker_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/loading.dart';
import '../../domain/models/meeting_type.dart';
import '../providers/create_meeting_state.dart' show TimeOfDayValue;
import '../providers/edit_meeting_notifier.dart';
import '../providers/edit_meeting_state.dart';
import '../providers/meeting_details_providers.dart';
import '../providers/meetings_list_notifier.dart';
import '../widgets/meeting_type_dropdown.dart';

class EditMeetingScreen extends ConsumerStatefulWidget {
  const EditMeetingScreen({super.key, required this.meetingId});

  final String meetingId;

  @override
  ConsumerState<EditMeetingScreen> createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends ConsumerState<EditMeetingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  void _seedControllersFromState(EditMeetingState s) {
    if (_seeded) return;
    if (s.status != EditMeetingStatus.ready) return;
    _titleCtrl.text = s.title;
    _descCtrl.text = s.description;
    _linkCtrl.text = s.link;
    _seeded = true;
  }

  Future<void> _pickDate() async {
    final notifier = ref.read(
      editMeetingNotifierProvider(widget.meetingId).notifier,
    );
    final current = ref.read(editMeetingNotifierProvider(widget.meetingId)).date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
      builder: appDatePickerTheme,
    );
    if (picked == null) return;
    notifier.setDate(picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final notifier = ref.read(
      editMeetingNotifierProvider(widget.meetingId).notifier,
    );
    final state = ref.read(editMeetingNotifierProvider(widget.meetingId));
    final current = start ? state.startTime : state.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current.hour, minute: current.minute),
      builder: appTimePickerTheme,
    );
    if (picked == null) return;
    final value = TimeOfDayValue(picked.hour, picked.minute);
    if (start) {
      notifier.setStartTime(value);
    } else {
      notifier.setEndTime(value);
    }
  }

  Future<void> _save() async {
    await ref
        .read(editMeetingNotifierProvider(widget.meetingId).notifier)
        .submit();
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
    final state = ref.watch(editMeetingNotifierProvider(widget.meetingId));
    final notifier =
        ref.read(editMeetingNotifierProvider(widget.meetingId).notifier);

    _seedControllersFromState(state);

    ref.listen<EditMeetingState>(
      editMeetingNotifierProvider(widget.meetingId),
      (prev, next) {
        if (prev?.status == next.status) return;
        switch (next.status) {
          case EditMeetingStatus.saved:
            ref.invalidate(meetingDetailsProvider(widget.meetingId));
            ref.invalidate(meetingsListNotifierProvider);
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting updated')),
            );
          case EditMeetingStatus.submitError:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error ?? 'Could not save meeting'),
                backgroundColor: AppColors.error,
              ),
            );
          case _:
            break;
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (state.status) {
          EditMeetingStatus.loading => const AppScreenLoader(),
          EditMeetingStatus.loadError => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppEmptyState(
                icon: Icons.error_outline,
                title: 'Could not load meeting',
                description: state.error,
                actionLabel: 'Retry',
                onAction: notifier.retryLoad,
              ),
            ),
          _ => _Form(
              state: state,
              titleCtrl: _titleCtrl,
              descCtrl: _descCtrl,
              linkCtrl: _linkCtrl,
              decorationBuilder: _inputDecoration,
              onPickDate: _pickDate,
              onPickTime: _pickTime,
              onTitleChanged: notifier.setTitle,
              onDescriptionChanged: notifier.setDescription,
              onLinkChanged: notifier.setLink,
              onReminderChanged: notifier.setReminder,
              onMeetingTypeChanged: notifier.setMeetingType,
              onSave: _save,
              onBack: () => context.pop(),
            ),
        },
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.state,
    required this.titleCtrl,
    required this.descCtrl,
    required this.linkCtrl,
    required this.decorationBuilder,
    required this.onPickDate,
    required this.onPickTime,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onLinkChanged,
    required this.onReminderChanged,
    required this.onMeetingTypeChanged,
    required this.onSave,
    required this.onBack,
  });

  final EditMeetingState state;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController linkCtrl;
  final InputDecoration Function({
    required String label,
    String? hint,
    Widget? suffixIcon,
    String? errorText,
  }) decorationBuilder;
  final Future<void> Function() onPickDate;
  final Future<void> Function({required bool start}) onPickTime;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onLinkChanged;
  final ValueChanged<int> onReminderChanged;
  final ValueChanged<MeetingType> onMeetingTypeChanged;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final submitting = state.status == EditMeetingStatus.submitting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 12.0),
          child: IconButton(
            onPressed: onBack,
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
                  'Edit Meeting',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: titleCtrl,
                  onChanged: onTitleChanged,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: decorationBuilder(
                    label: 'Title*',
                    hint: 'e.g. Pre-Production Kickoff',
                  ),
                ),
                const SizedBox(height: 16),
                MeetingTypeDropdown(
                  selected: state.meetingType,
                  decoration: decorationBuilder(label: 'Meeting Type'),
                  onChanged: onMeetingTypeChanged,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onPickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: decorationBuilder(
                        label: 'Date',
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
                        onTap: () => onPickTime(start: true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: decorationBuilder(
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
                        onTap: () => onPickTime(start: false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: decorationBuilder(
                              label: 'End Time',
                              hint: '--:--',
                              errorText: state.hasTimes && !state.endAfterStart
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
                  controller: descCtrl,
                  maxLines: 4,
                  minLines: 3,
                  onChanged: onDescriptionChanged,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: decorationBuilder(
                    label: 'Description',
                    hint: 'What is this meeting about?',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: linkCtrl,
                  keyboardType: TextInputType.url,
                  onChanged: onLinkChanged,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: decorationBuilder(
                    label: 'Meet Link',
                    hint: 'https://...',
                    suffixIcon: const Icon(
                      Icons.link,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    errorText: linkCtrl.text.isNotEmpty && !state.hasLink
                        ? 'Enter a valid URL'
                        : null,
                  ),
                ),
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
                      onTap: () => onReminderChanged(15),
                    ),
                    const SizedBox(width: 8),
                    _ReminderPill(
                      label: '30 min',
                      isActive: state.reminderMinutes == 30,
                      onTap: () => onReminderChanged(30),
                    ),
                    const SizedBox(width: 8),
                    _ReminderPill(
                      label: '1 hour',
                      isActive: state.reminderMinutes == 60,
                      onTap: () => onReminderChanged(60),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Save changes',
                  fullWidth: true,
                  isLoading: submitting,
                  onPressed: state.canSubmit && !submitting ? onSave : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
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
