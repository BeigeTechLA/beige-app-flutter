import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/providers/timezone_provider.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/schedule_input.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_schedule_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_location_field.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/when_where_sheet.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';

/// Screen 3 — "When and where do you want to Beige?" Hosts the When & Where
/// choice sheet, then either a full date/time/location form ("I have a date")
/// or a location-only form ("I'll confirm later").
class BookingScheduleScreen extends ConsumerStatefulWidget {
  const BookingScheduleScreen({super.key});

  @override
  ConsumerState<BookingScheduleScreen> createState() =>
      _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends ConsumerState<BookingScheduleScreen> {
  BookingScheduleMode? _mode;
  String _bookingType = 'single_day';
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  BookingLocation? _location;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(bookingFlowControllerProvider).schedule;
    if (existing != null) {
      _mode = existing.mode;
      _bookingType = existing.bookingType;
      _date = DateTime.tryParse(existing.eventDate ?? '');
      _start = _parseTime(existing.startTime);
      _end = _parseTime(existing.endTime);
      if (existing.eventLocation != null &&
          existing.eventLatitude != null &&
          existing.eventLongitude != null) {
        _location = BookingLocation(
          address: existing.eventLocation!,
          latitude: existing.eventLatitude!,
          longitude: existing.eventLongitude!,
        );
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mode == null) _openModeSheet();
    });
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || !value.contains(':')) return null;
    final parts = value.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _openModeSheet() async {
    final picked = await WhenWhereSheet.show(context, initial: _mode);
    if (!mounted || picked == null) return;
    setState(() => _mode = picked);
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  String _fmtDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

  double? get _durationHours {
    final start = _start;
    final end = _end;
    if (start == null || end == null) return null;
    final minutes = (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    if (minutes <= 0) return null;
    return minutes / 60.0;
  }

  ScheduleInput _buildInput(String timeZone) {
    final loc = _location;
    if (_mode == BookingScheduleMode.deferred) {
      return ScheduleInput(
        mode: BookingScheduleMode.deferred,
        bookingType: 'single_day',
        timeZone: timeZone,
        eventLocation: loc?.address,
        eventLatitude: loc?.latitude,
        eventLongitude: loc?.longitude,
      );
    }
    return ScheduleInput(
      mode: BookingScheduleMode.scheduled,
      bookingType: _bookingType,
      eventDate: _date == null ? null : _fmtDate(_date!),
      startTime: _start == null ? null : _fmtTime(_start!),
      endTime: _end == null ? null : _fmtTime(_end!),
      timeZone: timeZone,
      eventLocation: loc?.address,
      eventLatitude: loc?.latitude,
      eventLongitude: loc?.longitude,
    );
  }

  bool _canContinue(ScheduleInput input) {
    if (!input.isValid) return false;
    // Scheduled bookings also need a positive duration.
    if (input.mode == BookingScheduleMode.scheduled) {
      return _durationHours != null;
    }
    return true;
  }

  Future<void> _continue(ScheduleInput input) async {
    final ok = await ref
        .read(bookingScheduleNotifierProvider.notifier)
        .submit(input);
    if (!mounted) return;
    if (ok) {
      context.pushNamed(RouteNames.bookingDetails);
    } else {
      TopMessage.show(
        context,
        ref.read(bookingScheduleNotifierProvider).error ??
            'Something went wrong',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeZone =
        ref.watch(resolvedTimezoneProvider).valueOrNull ?? 'UTC';
    final isLoading = ref.watch(bookingScheduleNotifierProvider).isLoading;
    final input = _buildInput(timeZone);

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.schedule),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.schedule),
                AppSpacing.verticalXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'When and where do you want to Beige?',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          'Choose a date now, or reserve your spot and confirm '
                          'the details later.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        _modeSummaryRow(),
                        AppSpacing.verticalBase,
                        if (_mode == BookingScheduleMode.deferred)
                          ..._deferredBody()
                        else
                          ..._scheduledBody(),
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalBase,
                BookingPrimaryButton(
                  label: 'Continue',
                  loading: isLoading,
                  enabled: _canContinue(input),
                  onTap: () => _continue(input),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeSummaryRow() {
    final isDeferred = _mode == BookingScheduleMode.deferred;
    return GestureDetector(
      onTap: _openModeSheet,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.white30, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isDeferred ? "I'll confirm later" : 'I have a date',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Change',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
            AppSpacing.gapHSm,
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.white60,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _scheduledBody() {
    return [
      Text(
        'Booking For',
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
      ),
      AppSpacing.verticalSm,
      _bookingTypeToggle(),
      AppSpacing.verticalBase,
      _dateField(),
      AppSpacing.verticalBase,
      Row(
        children: [
          Expanded(
            child: _timeField(
              label: 'Start Time',
              value: _start,
              onPick: (t) => setState(() => _start = t),
            ),
          ),
          AppSpacing.gapHBase,
          Expanded(
            child: _timeField(
              label: 'End Time',
              value: _end,
              onPick: (t) => setState(() => _end = t),
            ),
          ),
        ],
      ),
      if (_durationHours != null) ...[
        AppSpacing.verticalMd,
        _durationChip(_durationHours!),
      ],
      AppSpacing.verticalBase,
      _locationLabel(),
      AppSpacing.verticalSm,
      BookingLocationField(
        initial: _location,
        onChanged: (loc) => setState(() => _location = loc),
      ),
    ];
  }

  List<Widget> _deferredBody() {
    return [
      Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: AppRadii.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Not Ready to Schedule?',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              'Secure your production now and finalize the date and time later '
              'with help from the Beige team.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      AppSpacing.verticalBase,
      _locationLabel(),
      AppSpacing.verticalSm,
      BookingLocationField(
        initial: _location,
        onChanged: (loc) => setState(() => _location = loc),
      ),
    ];
  }

  Widget _bookingTypeToggle() {
    return Row(
      children: [
        _toggleChip(
          label: 'Single Day',
          selected: _bookingType == 'single_day',
          onTap: () => setState(() => _bookingType = 'single_day'),
        ),
        AppSpacing.gapHSm,
        // Multiple-day requests are not yet defined by the API contract; kept
        // visible but disabled behind a verified-payload adapter.
        Opacity(
          opacity: 0.5,
          child: _toggleChip(
            label: 'Multiple Days (Soon)',
            selected: false,
            onTap: null,
          ),
        ),
      ],
    );
  }

  Widget _toggleChip({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.iconBackground,
          borderRadius: AppRadii.enormousAll,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? AppColors.black : AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _dateField() {
    return _pickerBox(
      label: 'Select Date',
      value: _date == null ? null : _fmtDate(_date!),
      icon: Icons.calendar_today_outlined,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _date ?? now,
          firstDate: now,
          lastDate: DateTime(now.year + 2),
        );
        if (picked != null) setState(() => _date = picked);
      },
    );
  }

  Widget _timeField({
    required String label,
    required TimeOfDay? value,
    required ValueChanged<TimeOfDay> onPick,
  }) {
    return _pickerBox(
      label: label,
      value: value?.format(context),
      icon: Icons.schedule,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget _pickerBox({
    required String label,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.inputVertical,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.white30, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white60,
                    ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    value ?? 'Select',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: value == null ? AppColors.white60 : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 18, color: AppColors.white70),
          ],
        ),
      ),
    );
  }

  Widget _durationChip(double hours) {
    final display = hours == hours.roundToDouble()
        ? hours.toInt().toString()
        : hours.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: AppRadii.enormousAll,
      ),
      child: Text(
        'Duration: $display Hours',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget _locationLabel() {
    return Text(
      'Location / Venue *',
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
    );
  }
}
