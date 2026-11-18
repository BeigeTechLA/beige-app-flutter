import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/timezone_provider.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../../domain/entities/shoot_time_payload.dart';
import '../../domain/entities/time_slot_rules.dart';
import '../providers/shoot_time_v2_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import '../widgets/booking_time_sheet.dart';
import '../widgets/gradient_radio.dart';
import '../widgets/location_picker_field.dart';
import '../widgets/schedule_choice_sheet.dart';
import '../widgets/wizard_bottom_bar.dart';

/// Booking-window granularity for Screen 3 (When & Where, "I have a date").
enum _BookingType { singleDay, multiDay }

/// Screen 3 of the Book-a-Shoot v2 flow — the dated "I have a date" journey:
/// pick single/multiple days + times, choose a location, then `PUT /time`.
///
/// Date/time rules (15-min slots, 4-hour lead) come from [TimeSlotRules];
/// location UX is reused via [LocationPickerField]; the request body is built
/// by [ShootTimePayload] and saved through [shootTimeV2NotifierProvider].
class WhenWhereScreen extends ConsumerStatefulWidget {
  const WhenWhereScreen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;

  @override
  ConsumerState<WhenWhereScreen> createState() => _WhenWhereScreenState();
}

class _WhenWhereScreenState extends ConsumerState<WhenWhereScreen> {
  static const int _windowDays = 180;
  static const String _fallbackTimeZone = 'America/Los_Angeles';

  /// Dated vs deferred ("I'll confirm later"). Chosen via the entry sheet;
  /// `null` until the user picks (sheet still open).
  ScheduleMode? _scheduleMode;

  _BookingType _bookingType = _BookingType.singleDay;

  // Single day.
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Multiple days.
  final List<DateTime> _selectedDates = [];
  bool _sameTimeForAll = true;
  TimeOfDay? _sharedStart;
  TimeOfDay? _sharedEnd;
  final Map<DateTime, TimeOfDay?> _perDayStart = {};
  final Map<DateTime, TimeOfDay?> _perDayEnd = {};

  // Location.
  PickedLocation? _location;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _chooseSchedule());
  }

  /// Opens the "When & Where" sheet to pick dated vs deferred. Dismissing
  /// without a choice backs out of the screen.
  Future<void> _chooseSchedule() async {
    final mode = await ScheduleChoiceSheet.show(
      context,
      initial: _scheduleMode,
      enableDeferred: true,
    );
    if (!mounted) return;
    if (mode == null) {
      if (_scheduleMode == null && context.canPop()) context.pop();
      return;
    }
    setState(() => _scheduleMode = mode);
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Active IANA zone for the booking schedule payload.
  /// Resolved chain (app-root already resolved it): login `user_timezone`
  /// pref → device IANA → UTC, with a last-resort constant fallback.
  String _timeZone() =>
      ref.read(resolvedTimezoneProvider).value ??
      ref.read(sharedPreferencesProvider).getString(kUserTimezonePrefKey) ??
      _fallbackTimeZone;

  // ── Single-day handlers ──────────────────────────────────────────────

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? _today,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: _windowDays)),
    );
    if (picked == null) return;
    final date = _norm(picked);
    setState(() {
      _date = date;
      _startTime = TimeSlotRules.defaultStartForDate(
        date: date,
        now: DateTime.now(),
      );
      _endTime = _startTime == null
          ? null
          : TimeSlotRules.defaultEndForStart(
              date: date,
              start: _startTime!,
              now: DateTime.now(),
            );
    });
  }

  Future<void> _pickSingleStart() async {
    final date = _date;
    if (date == null) {
      TopMessage.show(context, 'Please select a date first');
      return;
    }
    final slot = await _pickTime(
      date: date,
      isStart: true,
      currentValue: _startTime,
    );
    if (slot == null) return;
    setState(() {
      _startTime = slot;
      _endTime = TimeSlotRules.defaultEndForStart(
        date: date,
        start: slot,
        now: DateTime.now(),
      );
    });
  }

  Future<void> _pickSingleEnd() async {
    final date = _date;
    final start = _startTime;
    if (date == null || start == null) {
      TopMessage.show(context, 'Please select a start time first');
      return;
    }
    final slot = await _pickTime(
      date: date,
      isStart: false,
      startBound: start,
      currentValue: _endTime,
    );
    if (slot == null) return;
    setState(() => _endTime = slot);
  }

  // ── Multi-day handlers ───────────────────────────────────────────────

  void _toggleDate(DateTime date) {
    final d = _norm(date);
    setState(() {
      final existing = _selectedDates.indexWhere((e) => _sameDay(e, d));
      if (existing >= 0) {
        _selectedDates.removeAt(existing);
        _perDayStart.remove(d);
        _perDayEnd.remove(d);
      } else {
        _selectedDates.add(d);
      }
      _selectedDates.sort();
    });
  }

  bool _sameDay(DateTime a, DateTime b) => TimeSlotRules.isSameDate(a, b);

  Future<void> _pickMultiStart({DateTime? perDay}) async {
    final date = perDay ?? _earliestSelected();
    if (date == null) return;
    final slot = await _pickTime(
      date: date,
      isStart: true,
      currentValue: perDay == null ? _sharedStart : _perDayStart[_norm(perDay)],
    );
    if (slot == null) return;
    setState(() {
      if (perDay == null) {
        _sharedStart = slot;
        if (_sharedEnd != null &&
            !TimeSlotRules.isTimeAfter(slot, _sharedEnd!)) {
          _sharedEnd = null;
        }
      } else {
        _perDayStart[_norm(perDay)] = slot;
        final end = _perDayEnd[_norm(perDay)];
        if (end != null && !TimeSlotRules.isTimeAfter(slot, end)) {
          _perDayEnd[_norm(perDay)] = null;
        }
      }
    });
  }

  Future<void> _pickMultiEnd({DateTime? perDay}) async {
    final date = perDay ?? _earliestSelected();
    final start = perDay == null ? _sharedStart : _perDayStart[_norm(perDay)];
    if (date == null || start == null) {
      TopMessage.show(context, 'Please select a start time first');
      return;
    }
    final slot = await _pickTime(
      date: date,
      isStart: false,
      startBound: start,
      currentValue: perDay == null ? _sharedEnd : _perDayEnd[_norm(perDay)],
    );
    if (slot == null) return;
    setState(() {
      if (perDay == null) {
        _sharedEnd = slot;
      } else {
        _perDayEnd[_norm(perDay)] = slot;
      }
    });
  }

  DateTime? _earliestSelected() =>
      _selectedDates.isEmpty ? null : (List.of(_selectedDates)..sort()).first;

  // ── Shared time picker sheet ─────────────────────────────────────────

  Future<TimeOfDay?> _pickTime({
    required DateTime date,
    required bool isStart,
    TimeOfDay? startBound,
    TimeOfDay? currentValue,
  }) async {
    final slots = TimeSlotRules.buildSlots(
      date: date,
      isStart: isStart,
      now: DateTime.now(),
      startBound: startBound,
    );
    if (slots.isEmpty) {
      TopMessage.show(context, 'No available times for this day');
      return null;
    }
    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (sheetContext) => BookingTimeSheet(
        isStart: isStart,
        slots: slots,
        currentValue: currentValue,
        formatSlot: DateTimeUtils.formatTimeOfDayShort,
        isSameTime: (a, b) => a.hour == b.hour && a.minute == b.minute,
      ),
    );
  }

  // ── Validation + save ────────────────────────────────────────────────

  bool get _canContinue {
    if (_location == null) return false;
    // Deferred ("I'll confirm later") needs only a location — no date/time.
    if (_scheduleMode == ScheduleMode.deferred) return true;
    if (_bookingType == _BookingType.singleDay) {
      return _date != null && _startTime != null && _endTime != null;
    }
    if (_selectedDates.isEmpty) return false;
    if (_sameTimeForAll) {
      return _sharedStart != null && _sharedEnd != null;
    }
    return _selectedDates.every(
      (d) => _perDayStart[_norm(d)] != null && _perDayEnd[_norm(d)] != null,
    );
  }

  Future<void> _continue() async {
    if (_location == null) {
      setState(() => _locationError = 'Please select a location');
      return;
    }
    final loc = _location!;
    final Map<String, dynamic> payload;
    if (_scheduleMode == ScheduleMode.deferred) {
      payload = ShootTimePayload.deferred(
        timeZone: _timeZone(),
        location: loc.address,
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
    } else if (_bookingType == _BookingType.singleDay) {
      payload = ShootTimePayload.datedSingle(
        eventDate: DateTimeUtils.formatApiDate(_date!),
        startTime: DateTimeUtils.formatApiTime(_startTime!),
        endTime: DateTimeUtils.formatApiTime(_endTime!),
        timeZone: _timeZone(),
        location: loc.address,
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
    } else {
      payload = ShootTimePayload.datedMulti(
        bookingDays: _buildBookingDays(),
        timeZone: _timeZone(),
        location: loc.address,
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
    }

    final ok = await ref
        .read(shootTimeV2NotifierProvider.notifier)
        .save(bookingId: widget.bookingId, payload: payload);
    if (!mounted) return;
    if (ok) {
      context.pushNamed(
        RouteNames.creativeBrief,
        extra: {
          'bookingId': widget.bookingId,
          'contentType': widget.contentType,
          'shootTypeName': widget.shootTypeName,
        },
      );
    } else {
      final msg = ref.read(shootTimeV2NotifierProvider).errorMessage;
      TopMessage.show(context, msg ?? 'Something went wrong');
    }
  }

  List<Map<String, String>> _buildBookingDays() {
    final days = List.of(_selectedDates)..sort();
    return days.map((d) {
      final start = _sameTimeForAll ? _sharedStart : _perDayStart[_norm(d)];
      final end = _sameTimeForAll ? _sharedEnd : _perDayEnd[_norm(d)];
      return ShootTimePayload.day(
        date: DateTimeUtils.formatApiDate(d),
        startTime: DateTimeUtils.formatApiTime(start),
        endTime: DateTimeUtils.formatApiTime(end),
      );
    }).toList();
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final saving =
        ref.watch(shootTimeV2NotifierProvider).status ==
        ShootTimeV2Status.saving;

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: CreateProjectAppBar(
        step: BookingWizardStep.whenWhere,
        title: _scheduleMode == ScheduleMode.deferred
            ? 'More Details'
            : 'Create Project',
      ),
      body: _scheduleMode == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHWide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_scheduleMode == ScheduleMode.deferred) ...[
                    _sectionTitle('More Details'),
                    AppSpacing.verticalMd,
                    _notReadyCard(),
                    AppSpacing.verticalXl,
                  ] else ...[
                    _sectionTitle('Select Booking Type'),
                    AppSpacing.verticalMd,
                    _bookingTypeToggle(),
                    AppSpacing.verticalBase,
                    if (_bookingType == _BookingType.singleDay)
                      _singleDaySection()
                    else
                      _multiDaySection(),
                    AppSpacing.verticalBase,
                  ],
                  _sectionTitle('Location'),
                  AppSpacing.verticalMd,
                  LocationPickerField(
                    initial: _location,
                    errorText: _locationError,
                    onChanged: (value) => setState(() {
                      _location = value;
                      if (value != null) _locationError = null;
                    }),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _scheduleMode == null
          ? null
          : WizardBottomBar(
              onBack: () => context.pop(),
              onContinue: (_canContinue && !saving) ? _continue : null,
            ),
    );
  }

  /// "Not Ready to Schedule?" card shown on the deferred path (Figma 03b).
  Widget _notReadyCard() => Container(
    padding: const EdgeInsets.all(AppSpacing.base),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: AppRadii.xlAll,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.schedule, color: AppColors.primary, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
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
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Secure your production now and finalize the date and time '
                'later with help from the Beige team.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
  );

  Widget _bookingTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _toggleCard(
            label: 'Single Day',
            selected: _bookingType == _BookingType.singleDay,
            onTap: () => setState(() => _bookingType = _BookingType.singleDay),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _toggleCard(
            label: 'Multiple Days',
            selected: _bookingType == _BookingType.multiDay,
            onTap: () => setState(() => _bookingType = _BookingType.multiDay),
          ),
        ),
      ],
    );
  }

  Widget _toggleCard({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.goldHorizontalGradient : null,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: selected ? AppColors.transparent : AppColors.white30,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.black : AppColors.textSecondary,
                ),
              ),
            ),
            GradientRadio(selected: selected, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Single day UI ────────────────────────────────────────────────────

  Widget _singleDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Shoot Date & Time'),
        AppSpacing.verticalMd,
        _fieldTile(
          label: 'Select Date',
          value: _date == null
              ? 'Select a date'
              : DateTimeUtils.formatFullMonthDate(_date!),
          icon: Icons.calendar_today_outlined,
          onTap: _pickSingleDate,
          filled: _date != null,
        ),
        AppSpacing.verticalMd,
        _fieldTile(
          label: 'Start Time*',
          value: _startTime == null
              ? 'Select start time'
              : DateTimeUtils.formatTimeOfDay(context, _startTime!),
          icon: Icons.access_time,
          onTap: _pickSingleStart,
          filled: _startTime != null,
        ),
        AppSpacing.verticalMd,
        _fieldTile(
          label: 'End Time*',
          value: _endTime == null
              ? 'Select end time'
              : DateTimeUtils.formatTimeOfDay(context, _endTime!),
          icon: Icons.access_time,
          onTap: _pickSingleEnd,
          filled: _endTime != null,
        ),
      ],
    );
  }

  // ── Multi day UI ─────────────────────────────────────────────────────

  Widget _multiDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Select Date'),
        AppSpacing.verticalMd,
        _dateStrip(),
        AppSpacing.verticalMd,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _infoChip('Total Days: ${_selectedDates.length}'),
            if (_selectedDates.isNotEmpty)
              _infoChip(
                DateTimeUtils.formatGroupedSelectedDaysLabel(_selectedDates),
              ),
          ],
        ),
        if (_selectedDates.isNotEmpty) ...[
          AppSpacing.verticalBase,
          _sectionTitle('Are Timings Same For All Selected Dates?'),
          AppSpacing.verticalMd,
          Row(
            children: [
              _radio(
                label: 'Yes',
                selected: _sameTimeForAll,
                onTap: () => setState(() => _sameTimeForAll = true),
              ),
              const SizedBox(width: AppSpacing.xl),
              _radio(
                label: 'No',
                selected: !_sameTimeForAll,
                onTap: () => setState(() => _sameTimeForAll = false),
              ),
            ],
          ),
          AppSpacing.verticalMd,
          if (_sameTimeForAll) _sharedTimeFields() else _perDayTimeFields(),
        ],
      ],
    );
  }

  Widget _sharedTimeFields() {
    return Column(
      children: [
        _fieldTile(
          label: 'Start Time*',
          value: _sharedStart == null
              ? 'Select start time'
              : DateTimeUtils.formatTimeOfDay(context, _sharedStart!),
          icon: Icons.access_time,
          onTap: () => _pickMultiStart(),
          filled: _sharedStart != null,
        ),
        AppSpacing.verticalMd,
        _fieldTile(
          label: 'End Time*',
          value: _sharedEnd == null
              ? 'Select end time'
              : DateTimeUtils.formatTimeOfDay(context, _sharedEnd!),
          icon: Icons.access_time,
          onTap: () => _pickMultiEnd(),
          filled: _sharedEnd != null,
        ),
      ],
    );
  }

  Widget _perDayTimeFields() {
    final days = List.of(_selectedDates)..sort();
    return Column(
      children: [
        for (final d in days) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateTimeUtils.formatFullMonthDate(d),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
            ),
          ),
          AppSpacing.verticalXs,
          Row(
            children: [
              Expanded(
                child: _fieldTile(
                  label: 'Start*',
                  value: _perDayStart[_norm(d)] == null
                      ? 'Start'
                      : DateTimeUtils.formatTimeOfDay(
                          context,
                          _perDayStart[_norm(d)]!,
                        ),
                  icon: Icons.access_time,
                  onTap: () => _pickMultiStart(perDay: d),
                  filled: _perDayStart[_norm(d)] != null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _fieldTile(
                  label: 'End*',
                  value: _perDayEnd[_norm(d)] == null
                      ? 'End'
                      : DateTimeUtils.formatTimeOfDay(
                          context,
                          _perDayEnd[_norm(d)]!,
                        ),
                  icon: Icons.access_time,
                  onTap: () => _pickMultiEnd(perDay: d),
                  filled: _perDayEnd[_norm(d)] != null,
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,
        ],
      ],
    );
  }

  Widget _dateStrip() {
    final dates = List.generate(
      _windowDays,
      (i) => _today.add(Duration(days: i)),
    );
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = _selectedDates.any((d) => _sameDay(d, date));
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleDate(date),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: AppTextStyles.bodyLargeMedium.copyWith(
                      fontSize: 18,
                      color: selected ? AppColors.black : AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    DateTimeUtils.formatWeekdayShort(date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: selected ? AppColors.black : AppColors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(String text) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: AppRadii.smAll,
    ),
    child: Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
    ),
  );

  Widget _radio({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          GradientRadio(selected: selected, size: 32),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _fieldTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: false,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: filled ? AppColors.primary : AppColors.white60,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadii.lgAll,
            borderSide: BorderSide(
              color: filled ? AppColors.borderGold : AppColors.white30,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: filled ? AppColors.white : AppColors.white54,
                ),
              ),
            ),
            Icon(icon, color: AppColors.white70, size: 20),
          ],
        ),
      ),
    );
  }
}
