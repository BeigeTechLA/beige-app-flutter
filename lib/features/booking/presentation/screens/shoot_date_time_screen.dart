import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/utils/date_time_utils.dart';
import 'package:beige/shared/widgets/scale_clamped_text.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/presentation/providers/shoot_date_time_notifier.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/util/picker_theme.dart';

import '../../../../app/assets.dart';
import 'package:beige/shared/widgets/app_qty_counter.dart';

class ShootDateTimeScreen extends ConsumerStatefulWidget {
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  final String? shootTypeName;

  const ShootDateTimeScreen({
    super.key,
    required this.ShootTypeId,
    required this.bookingId,
    required this.contentTypeId,
    this.shootTypeName,
  });

  @override
  ConsumerState<ShootDateTimeScreen> createState() =>
      _ShootDateTimeScreenState();
}

class _ShootDateTimeScreenState extends ConsumerState<ShootDateTimeScreen> {
  static const bool kResetTimesOnDateChange = false;

  bool isToday = false;
  bool isStartOpen = false;
  bool isEndOpen = false;
  static const Set<int> _weddingShootTypeIds = {9, 16};

  Map<DateTime, bool> expandedMap = {};
  Map<DateTime, TimeOfDay?> startTimes = {};
  Map<DateTime, TimeOfDay?> endTimes = {};

  Map<int, int> videoCounts = {};
  Map<int, int> photoCounts = {};

  TimeOfDay? shootStartTime;
  TimeOfDay? shootEndTime;
  bool isShootDateSelected() {
    return selectedDates.isNotEmpty;
  }

  String? startTimeStr;
  String? endTimeStr;

  /// MULTIPLE NO (PER DATE)
  Map<DateTime, String?> startTimeMap = {};
  Map<DateTime, String?> endTimeMap = {};

  bool get isWeddingShoot => _weddingShootTypeIds.contains(widget.ShootTypeId);

  int get includedPhotosPerHour => isWeddingShoot ? 50 : 25;

  int get extraPhotosPerAddOn => 25;

  int _calculateDurationInMinutes(TimeOfDay start, TimeOfDay end) {
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;

    if (endMin >= startMin) {
      return endMin - startMin;
    }

    return (24 * 60 - startMin) + endMin;
  }

  TimeOfDay? convertStringToTime(String? timeStr) {
    if (timeStr == null) return null;

    final now = DateTime.now();
    final dt = parseTime(timeStr, now);

    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  int getTotalSelectedDurationInMinutes() {
    if (selectedIndex == 1) {
      if (startTime == null || endTime == null) return 0;
      return _calculateDurationInMinutes(startTime!, endTime!);
    }

    if (selectedDates.isEmpty) return 0;

    if (istimingsame) {
      if (startTime == null || endTime == null) return 0;
      return _calculateDurationInMinutes(startTime!, endTime!) *
          selectedDates.length;
    }

    int totalMinutes = 0;

    for (final date in selectedDates) {
      final key = normalizeDate(date);
      final start = startTimes[key];
      final end = endTimes[key];

      if (start == null || end == null) continue;

      totalMinutes += _calculateDurationInMinutes(start, end);
    }

    return totalMinutes;
  }

  List<String> generateTimeList({required bool isStart, DateTime? date}) {
    List<String> times = [];

    DateTime now = DateTime.now();
    DateTime baseDate = date ?? selectedDate ?? now;

    /// 🔥 4 HOUR RULE
    DateTime minTime = now.add(Duration(hours: 4));

    /// 🔥 LOOP SAME AS SINGLE DAY (IMPORTANT)
    DateTime startOfDay = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      0,
      0,
    );
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    DateTime current = startOfDay;

    while (current.isBefore(endOfDay)) {
      /// 🔥 CHECK TODAY
      bool isToday =
          baseDate.year == now.year &&
          baseDate.month == now.month &&
          baseDate.day == now.day;

      /// ✅ APPLY SAME RULE AS SINGLE DAY
      if (isToday && current.isBefore(minTime)) {
        current = current.add(Duration(minutes: 15));
        continue;
      }

      /// 🔥 END TIME FILTER
      if (!isStart) {
        String? startStr;

        if (date != null) {
          startStr = startTimeMap[date];
        } else {
          startStr = startTimeStr;
        }

        if (startStr != null) {
          DateTime startDT = parseTime(startStr, baseDate);

          if (!current.isAfter(startDT)) {
            current = current.add(Duration(minutes: 15));
            continue;
          }
        }
      }

      /// ✅ FINAL FORMAT (12 HOUR SAME AS SINGLE)
      final time = TimeOfDay.fromDateTime(current);
      times.add(DateTimeUtils.formatTimeOfDay(context, time));

      current = current.add(Duration(minutes: 15));
    }

    return times;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _minutesOfDay(TimeOfDay time) => time.hour * 60 + time.minute;

  DateTime _dateTimeForTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _roundDateTimeUp15(DateTime dateTime) {
    final hasSubMinute =
        dateTime.second > 0 ||
        dateTime.millisecond > 0 ||
        dateTime.microsecond > 0;
    var minutes = dateTime.hour * 60 + dateTime.minute;
    if (hasSubMinute) minutes += 1;

    final remainder = minutes % 15;
    if (remainder != 0) {
      minutes += 15 - remainder;
    }

    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    ).add(Duration(minutes: minutes));
  }

  TimeOfDay _roundUp15(DateTime dateTime) {
    return TimeOfDay.fromDateTime(_roundDateTimeUp15(dateTime));
  }

  String _formatSlot(TimeOfDay time) {
    return DateTimeUtils.formatTimeOfDayShort(time);
  }

  bool _isSameTime(TimeOfDay a, TimeOfDay b) {
    return a.hour == b.hour && a.minute == b.minute;
  }

  bool _isTimeAfter(TimeOfDay start, TimeOfDay end) {
    return _minutesOfDay(end) > _minutesOfDay(start);
  }

  List<TimeOfDay> _buildSlots({
    required DateTime date,
    required bool isStart,
    TimeOfDay? startBound,
  }) {
    final now = DateTime.now();
    final dayStart = DateTime(date.year, date.month, date.day);
    final latestSlot = DateTime(date.year, date.month, date.day, 23, 45);
    var current = dayStart;

    if (_isSameDate(date, now)) {
      current = _roundDateTimeUp15(now.add(const Duration(hours: 4)));
      if (!_isSameDate(current, date) || current.isAfter(latestSlot)) {
        return <TimeOfDay>[];
      }
    }

    final startBoundMinutes = !isStart && startBound != null
        ? _minutesOfDay(startBound)
        : null;
    final slots = <TimeOfDay>[];

    while (!current.isAfter(latestSlot)) {
      final slot = TimeOfDay.fromDateTime(current);
      if (startBoundMinutes == null ||
          _minutesOfDay(slot) > startBoundMinutes) {
        slots.add(slot);
      }
      current = current.add(const Duration(minutes: 15));
    }

    return slots;
  }

  DateTime? _slotDateForTimeSelection(DateTime? date) {
    if (date != null) return normalizeDate(date);

    if (selectedIndex == 1) return selectedDate;

    if (selectedIndex == 2 && selectedDates.isNotEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final normalizedDates = selectedDates.map(normalizeDate).toList();

      for (final selected in normalizedDates) {
        if (_isSameDate(selected, today)) return selected;
      }

      normalizedDates.sort((a, b) => a.compareTo(b));
      return normalizedDates.first;
    }

    return null;
  }

  TimeOfDay? _defaultEndForStart(DateTime date, TimeOfDay start) {
    var endDateTime = _dateTimeForTime(
      date,
      start,
    ).add(const Duration(hours: 4));
    final latestSlot = DateTime(date.year, date.month, date.day, 23, 45);

    if (endDateTime.isAfter(latestSlot)) {
      endDateTime = latestSlot;
    }

    final end = TimeOfDay.fromDateTime(endDateTime);
    return _isTimeAfter(start, end) ? end : null;
  }

  void _clearSingleDayTimes() {
    startTime = null;
    endTime = null;
    startTimeController.clear();
    endTimeController.clear();
  }

  void _syncSingleDayTimeControllers() {
    if (startTime == null) {
      startTimeController.clear();
    } else {
      _updateTimeText(startTimeController, startTime!);
    }

    if (endTime == null) {
      endTimeController.clear();
    } else {
      _updateTimeText(endTimeController, endTime!);
    }
  }

  void _applyDefaultSingleDayTimes(DateTime date) {
    final startSlots = _buildSlots(date: date, isStart: true);
    if (startSlots.isEmpty) {
      _clearSingleDayTimes();
      return;
    }

    final desiredStart = _isSameDate(date, DateTime.now())
        ? _roundUp15(DateTime.now().add(const Duration(hours: 4)))
        : const TimeOfDay(hour: 9, minute: 0);
    final start = startSlots.firstWhere(
      (slot) => _isSameTime(slot, desiredStart),
      orElse: () => startSlots.first,
    );

    startTime = start;
    endTime = _defaultEndForStart(date, start);
    _syncSingleDayTimeControllers();
  }

  void _applySingleDayDateChange({
    required DateTime picked,
    required DateTime? previousDate,
    required TimeOfDay? previousStart,
    required TimeOfDay? previousEnd,
  }) {
    if (previousDate != null && kResetTimesOnDateChange) {
      _clearSingleDayTimes();
      return;
    }

    if (previousDate != null && previousStart != null) {
      final validStartSlots = _buildSlots(date: picked, isStart: true);
      final canKeepStart = validStartSlots.any(
        (slot) => _isSameTime(slot, previousStart),
      );

      if (!canKeepStart) {
        _applyDefaultSingleDayTimes(picked);
        return;
      }

      startTime = previousStart;
      if (previousEnd != null && _isTimeAfter(previousStart, previousEnd)) {
        final validEndSlots = _buildSlots(
          date: picked,
          isStart: false,
          startBound: previousStart,
        );
        endTime = validEndSlots.any((slot) => _isSameTime(slot, previousEnd))
            ? previousEnd
            : null;
      } else {
        endTime = null;
      }

      _syncSingleDayTimeControllers();
      return;
    }

    _applyDefaultSingleDayTimes(picked);
  }

  int getRoundedBookedHours() {
    final totalMinutes = getTotalSelectedDurationInMinutes();
    if (totalMinutes <= 0) return 0;
    return (totalMinutes / 60).ceil();
  }

  /*int getIncludedPhotoCount() {
      final bookedHours = getRoundedBookedHours();
      if (bookedHours == 0) return 0;
      return bookedHours * includedPhotosPerHour;
    }*/

  /* int getIncludedPhotoCount() {
    final hours = getRoundedBookedHours();

    if (hours == 0) return 0;

    // 🔥 Wedding check (NAME se bhi kar sakte ho)
    if ((widget.shootTypeName ?? "").toLowerCase() == "wedding") {
      return hours * 50;
    } else {
      return hours * 25;
    }
  }*/

  int getIncludedPhotoCount() {
    final hours = getRoundedBookedHours();

    if (hours == 0) return 0;

    // ✅ Wedding = 50 per hour
    // ✅ Other = 25 per hour
    return isWeddingShoot ? hours * 50 : hours * 25;
  }

  int getTotalPhotos() {
    /// 🔥 VIDEO ONLY → NO PHOTOS
    if (widget.contentTypeId == 1) {
      return 0;
    }

    int total = getIncludedPhotoCount();

    photoCounts.forEach((key, value) {
      total += value;
    });

    return total;
  }

  int getTotalVideos() {
    int total = 0;

    videoCounts.forEach((key, value) {
      total += value;
    });

    return total;
  }

  String getDurationSummaryLabel() {
    final bookedHours = getRoundedBookedHours();

    if (bookedHours > 0) {
      return "$bookedHours ${bookedHours == 1 ? "Hour" : "Hours"} Duration";
    }

    return "Select Duration";
  }

  String getDurationText(DateTime date) {
    final key = normalizeDate(date);

    final start = startTimes[key];
    final end = endTimes[key];

    if (start == null || end == null) return "Duration:00";

    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;

    int diff;

    if (endMin >= startMin) {
      diff = endMin - startMin;
    } else {
      diff = (24 * 60 - startMin) + endMin;
    }

    final hours = diff ~/ 60;
    final minutes = diff % 60;

    if (hours > 0 && minutes > 0) {
      return "Duration: ${hours}h ${minutes}m";
    } else if (hours > 0) {
      return "Duration: ${hours}h";
    } else {
      return "Duration: ${minutes}m";
    }
  }

  DateTime parseTime(String time, DateTime date) {
    try {
      final parts = time.split(' ');
      final timePart = parts[0]; // 12:45
      final period = parts[1]; // AM / PM

      final t = timePart.split(':');
      int hour = int.parse(t[0]);
      int minute = int.parse(t[1]);

      if (period == "PM" && hour != 12) {
        hour += 12;
      } else if (period == "AM" && hour == 12) {
        hour = 0;
      }

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      debugPrint("PARSE ERROR: $e");
      return date; // fallback
    }
  }

  List<DateTime> allDates = [];
  List<DateTime> selectedDates = [];
  List<dynamic> photoEditTypes = [];
  List<dynamic> editTypes = [];

  int selectedIndex = 1;
  bool istimingsame = true;
  bool isPhotoOpen = true; //      // API data
  bool isVideoOpen = true; //      // API data

  List<int> selectedEditTypeIds = []; // selected ids
  List<String> selectedEditTypeNames = [];

  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  DateTime? selectedDate;

  bool isEditNeeded = false; // ✅ Default = No selected

  bool isSubmitting = false;
  bool _isPopping = false;

  void _handleBack() {
    if (_isPopping) return;
    if (!context.canPop()) return;
    _isPopping = true;
    context.pop();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _isPopping = false;
    });
  }

  bool isDateSelected() {
    return selectedDate != null;
  }

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  String getFinalSummaryText() {
    final photos = getTotalPhotos();
    final videos = getTotalVideos();

    /// ONLY PHOTO
    if (photos > 0 && videos == 0) {
      return "You’ll Receive $photos Photos";
    }

    /// ONLY VIDEO
    if (videos > 0 && photos == 0) {
      return "You’ll Receive $videos Videos";
    }

    /// BOTH
    if (photos > 0 && videos > 0) {
      return "You’ll Receive $photos Photos + $videos Videos";
    }

    return "Select Edits";
  }

  String getTotalDuration() {
    final totalMinutes = getTotalSelectedDurationInMinutes();

    if (totalMinutes <= 0) return "0 Hour";

    final hours = (totalMinutes / 60).ceil();

    return "$hours ${hours == 1 ? "Hour" : "Hours"}";
  }

  String formatDatesAlt(List<DateTime> dates) {
    return DateTimeUtils.formatGroupedMonthDays(dates);
  }

  String getDaysAndHours() {
    final totalMinutes = getTotalSelectedDurationInMinutes();

    if (totalMinutes <= 0) return "0 Day • 0 Hour";

    final hours = (totalMinutes / 60).ceil();
    final days = selectedDates.length;

    return "$days ${days == 1 ? "Day" : "Days"} • "
        "$hours ${hours == 1 ? "Hour" : "Hours"}";
  }

  String formatSelectedDates(List<DateTime> dates) {
    return DateTimeUtils.formatGroupedSelectedDaysLabel(dates);
  }

  DateTime normalizeDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  bool isEndTimeAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    /// SAME DAY
    if (endMinutes > startMinutes) return true;

    /// NEXT DAY ALLOW
    return true;
  }

  bool get isFormValid {
    /// 🔥 SINGLE DAY
    if (selectedIndex == 1) {
      if (selectedDate == null) return false;
      if (startTime == null || endTime == null) return false;
    }

    /// 🔥 MULTIPLE DAY
    if (selectedIndex == 2) {
      if (selectedDates.isEmpty) return false;

      /// 👉 SAME TIME FOR ALL
      if (istimingsame == true) {
        if (startTime == null || endTime == null) return false;
      }

      /// 👉 DIFFERENT TIME FOR EACH DATE
      if (istimingsame == false) {
        for (var date in selectedDates) {
          final key = normalizeDate(date);
          if (startTimes[key] == null || endTimes[key] == null) {
            return false;
          }
        }
      }
    }

    /// 🔥 EDIT VALIDATION (FIXED)
    if (isEditNeeded) {
      bool hasEdits = false;

      // check video edits
      videoCounts.forEach((key, value) {
        if (value > 0) hasEdits = true;
      });

      // check photo edits
      photoCounts.forEach((key, value) {
        if (value > 0) hasEdits = true;
      });

      if (!hasEdits) return false;
    }

    return true;
  }

  String getPhotoInclusionMessage() {
    final includedPhotos = getIncludedPhotoCount();
    final bookedHours = getRoundedBookedHours();

    if (includedPhotos == 0 || bookedHours == 0) {
      return isWeddingShoot
          ? "Wedding shoots include 50 edited photos per hour. You can add 25 extra photos anytime."
          : "This shoot includes 25 edited photos per hour. You can add 25 extra photos anytime.";
    }

    final photoLabel = includedPhotos == 1 ? "photo" : "photos";
    final hourLabel = bookedHours == 1 ? "hour" : "hours";

    return "You’ll receive $includedPhotos edited $photoLabel for $bookedHours $hourLabel. Need more? Add 25 extra photos.";
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void resetEditTypes() {
    selectedEditTypeIds.clear();
    selectedEditTypeNames.clear();
  }

  String getEditTypeDisplayText() {
    /// 🔥 When nothing selected
    if (selectedEditTypeNames.isEmpty) {
      switch (widget.contentTypeId) {
        case 1:
          return "Select Video Edit Type";

        case 2:
          return "Select Photo Edit Type";

        case 3:
          return "Select Photo & Video Edit Type";

        default:
          return "Select Edit Type";
      }
    }

    /// 🔥 Single selection
    if (selectedEditTypeNames.length == 1) {
      return selectedEditTypeNames.first;
    }

    /// 🔥 Multiple selection
    return "${selectedEditTypeNames.first} +${selectedEditTypeNames.length - 1}";
  }

  void _syncEditTypesFromNotifier(ShootDateTimeState dtState) {
    if (dtState.status == ShootDateTimeStatus.loaded ||
        dtState.status == ShootDateTimeStatus.success) {
      editTypes = dtState.videoEditTypes;
      photoEditTypes = dtState.photoEditTypes;
      isLoading = false;
    } else if (dtState.status == ShootDateTimeStatus.loading) {
      isLoading = true;
    } else if (dtState.status == ShootDateTimeStatus.error) {
      isLoading = false;
    }
  }

  Future<void> _ShootDate_Time() async {
    if (!isFormValid) return;
    if (isSubmitting) return;

    setState(() => isSubmitting = true);

    /// 🔥 RESET
    if (!isEditNeeded) {
      selectedEditTypeIds.clear();
      selectedEditTypeNames.clear();
      videoCounts.clear();
      photoCounts.clear();
    }

    /// 🔥 BUILD EDIT ARRAYS
    List<String> videoEditKeys = [];
    List<String> photoEditKeys = [];

    videoCounts.forEach((key, count) {
      if (count > 0) {
        String apiKey = editTypes[key]['key'];
        for (int i = 0; i < count; i++) {
          videoEditKeys.add(apiKey);
        }
      }
    });

    /*      photoCounts.forEach((key, count) {
        if (count > 0) {
          String apiKey = photoEditTypes[key]['key'];
          for (int i = 0; i < count; i++) {
            photoEditKeys.add(apiKey);
          }
        }
      });*/

    photoCounts.forEach((key, count) {
      if (count > 0) {
        String apiKey = photoEditTypes[key]['key'];

        int unitCount = count ~/ 25; // 🔥 MAIN FIX

        for (int i = 0; i < unitCount; i++) {
          photoEditKeys.add(apiKey);
        }
      }
    });
    Map<String, dynamic> payload = {};

    /// ================= SINGLE DAY =================
    if (selectedIndex == 1) {
      /// ✅ SAFETY CHECK
      if (selectedDate == null || startTime == null || endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select date and time")),
        );
        setState(() => isSubmitting = false);
        return;
      }

      /// ✅ END > START CHECK
      if (!_isTimeAfter(startTime!, endTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End time must be after Start time")),
        );
        setState(() => isSubmitting = false);
        return;
      }

      payload = {
        "booking_type": "single_day",
        "time_zone": "Asia/Calcutta",
        "event_date": DateTimeUtils.formatApiDate(selectedDate!),
        "start_time": DateTimeUtils.formatApiTime(startTime!),
        "end_time": DateTimeUtils.formatApiTime(endTime!),
        "edits_needed": isEditNeeded ? 1 : 0,
        "video_edit_types": videoEditKeys,
        "photo_edit_types": photoEditKeys,
      };
    }

    /// ================= MULTIPLE DAY =================
    if (selectedIndex == 2) {
      List<Map<String, dynamic>> bookingDays = [];

      if (selectedDates.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select dates")));
        setState(() => isSubmitting = false);
        return;
      }

      /// 🔹 SAME TIME FOR ALL
      if (istimingsame) {
        if (startTime == null || endTime == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Please select time")));
          setState(() => isSubmitting = false);
          return;
        }

        if (!isEndTimeAfterStart(startTime!, endTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("End time must be after Start time")),
          );
          setState(() => isSubmitting = false);
          return;
        }

        for (var date in selectedDates) {
          bookingDays.add({
            "date": DateTimeUtils.formatApiDate(date),
            "start_time": DateTimeUtils.formatApiTime(startTime!),
            "end_time": DateTimeUtils.formatApiTime(endTime!),
          });
        }
      }
      /// 🔹 DIFFERENT TIME FOR EACH DATE
      else {
        for (var date in selectedDates) {
          final key = normalizeDate(date);
          final start = startTimes[key];
          final end = endTimes[key];

          /// ❌ NULL CHECK
          if (start == null || end == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Select time for all dates")),
            );
            setState(() => isSubmitting = false);
            return;
          }

          /// ❌ VALIDATION
          if (!isEndTimeAfterStart(start, end)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("End time must be after Start time"),
              ),
            );
            setState(() => isSubmitting = false);
            return;
          }

          bookingDays.add({
            "date": DateTimeUtils.formatApiDate(date),
            "start_time": DateTimeUtils.formatApiTime(start), // ✅ FIXED
            "end_time": DateTimeUtils.formatApiTime(end), // ✅ FIXED
          });
        }
      }

      payload = {
        "booking_type": "multi_day",
        "time_zone": "Asia/Calcutta",
        "booking_days": bookingDays,
        "edits_needed": isEditNeeded ? 1 : 0,
        "video_edit_types": videoEditKeys,
        "photo_edit_types": photoEditKeys,
      };
    }

    await ref
        .read(shootDateTimeNotifierProvider(widget.ShootTypeId).notifier)
        .saveBookingTime(bookingId: widget.bookingId, payload: payload);

    if (!mounted) return;

    final dtState = ref.read(shootDateTimeNotifierProvider(widget.ShootTypeId));

    if (dtState.status == ShootDateTimeStatus.success) {
      context.pushNamed(
        RouteNames.moreDetails,
        extra: {
          'bookingId': widget.bookingId,
          'contentTypeId': widget.contentTypeId,
          'ShootTypeId': widget.ShootTypeId,
        },
      );
    } else if (dtState.status == ShootDateTimeStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dtState.errorMessage ?? "Something went wrong")),
      );
    }

    setState(() => isSubmitting = false);
  }

  TimeOfDay getMinAllowedTime() {
    final now = DateTime.now().add(const Duration(hours: 4));
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  bool isTodaySelected() {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    return selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;
  }

  DateTime minDateTimeForToday() {
    return DateTime.now().add(const Duration(hours: 4));
  }

  bool isMinTimeNextDay() {
    final min = minDateTimeForToday();
    final now = DateTime.now();
    return min.day != now.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: '',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.white,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.surfaceDark,
              dividerColor: AppColors.dividerDark,
              headerHeadlineStyle: AppTextStyles.titleMedium.copyWith(
                fontSize: 20,
                color: AppColors.white,
              ),
              headerHelpStyle: const TextStyle(fontSize: 0, height: 0),
              headerBackgroundColor: AppColors.surfaceDeep,
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              weekdayStyle: const TextStyle(
                fontFamily: AppAssets.fontOutfit,
                fontSize: 13,
                color: AppColors.white70,
              ),
              dayStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontFamily: AppAssets.fontUnbounded,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final previousDate = selectedDate;
      final previousStart = startTime;
      final previousEnd = endTime;

      setState(() {
        /// 🔥 SINGLE DAY MODE
        if (selectedIndex == 1) {
          selectedDate = picked;
          dateController.text = DateTimeUtils.formatDateValue(
            picked,
            fallback: "",
          );
        }
        /// 🔥 MULTIPLE DAY MODE
        else {
          bool exists = selectedDates.any(
            (d) =>
                d.year == picked.year &&
                d.month == picked.month &&
                d.day == picked.day,
          );

          if (exists) {
            selectedDates.removeWhere(
              (d) =>
                  d.year == picked.year &&
                  d.month == picked.month &&
                  d.day == picked.day,
            );
          } else {
            selectedDates.add(picked);
          }
        }

        /// 🔥 AUTO TIME LOGIC (ONLY SINGLE)
        if (selectedIndex == 1) {
          _applySingleDayDateChange(
            picked: picked,
            previousDate: previousDate,
            previousStart: previousStart,
            previousEnd: previousEnd,
          );
        }
      });
    }
  }

  Future<void> _selectDateMultiple(BuildContext context) async {
    List<DateTime> tempSelected = List.from(selectedDates);

    final result = await showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceDark,
            ),
          ),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxl,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      color: AppColors.surfaceDeep,
                      child: Text(
                        "Select Date",
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    /// CALENDAR
                    SizedBox(
                      height: 350,
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.multi,

                          /// ❌ REMOVE DEFAULT CIRCLE
                          selectedDayHighlightColor: AppColors.transparent,

                          /// ❌ PAST DATES DISABLE
                          firstDate: DateTime.now(),

                          /// TEXT STYLE
                          selectedDayTextStyle: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),

                          /// 🔥 CUSTOM UI (MAIN PART)
                          dayBuilder:
                              ({
                                required DateTime date,
                                TextStyle? textStyle,
                                BoxDecoration? decoration,
                                bool? isSelected,
                                bool? isDisabled,
                                bool? isToday,
                              }) {
                                final today = DateTime.now();

                                bool isPast = date.isBefore(
                                  DateTime(today.year, today.month, today.day),
                                );

                                /// ❌ PAST DATE (VISIBLE BUT DISABLED)
                                if (isPast) {
                                  return Container(
                                    margin: const EdgeInsets.all(
                                      AppSpacing.xxs,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${date.day}",
                                        style: const TextStyle(
                                          color: AppColors
                                              .disabled, // 👈 grey = disabled look
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                /// ✅ SELECTED (BOX STYLE)
                                if (isSelected == true) {
                                  return Container(
                                    margin: const EdgeInsets.all(
                                      AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: AppRadii.smAll,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${date.day}",
                                        style: const TextStyle(
                                          color: AppColors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                /// ✅ NORMAL DATE
                                return Container(
                                  margin: const EdgeInsets.all(AppSpacing.xxs),
                                  child: Center(
                                    child: Text(
                                      "${date.day}",
                                      style: const TextStyle(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                        ),

                        value: tempSelected,

                        onValueChanged: (dates) {
                          setStateDialog(() {
                            /// 🔥 SAFETY FILTER
                            tempSelected = dates.where((date) {
                              return !date.isBefore(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                ),
                              );
                            }).toList();
                          });
                        },
                      ),
                    ),

                    /// ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        TextButton(
                          onPressed: () {
                            context.pop(tempSelected);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null && result is List<DateTime>) {
      setState(() {
        selectedDates = result;
        startTimes.clear();
        endTimes.clear();
      });
    }
  }

  // Helper method to format time (Make sure this is inside your _ShootDateTimeScreenState class)
  void _updateTimeText(TextEditingController controller, TimeOfDay picked) {
    final hour = picked.hourOfPeriod == 0
        ? 12
        : picked.hourOfPeriod.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? "AM" : "PM";
    controller.text = "$hour:$minute $period";
  }

  Future<TimeOfDay?> _showCupertinoTimeSheet({
    required BuildContext context,
    required bool isStart,
    required DateTime selectedDate,
    TimeOfDay? startBound,
    TimeOfDay? currentValue,
  }) async {
    final slots = _buildSlots(
      date: selectedDate,
      isStart: isStart,
      startBound: startBound,
    );

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (popupContext) {
        return _CupertinoTimeSheetContent(
          isStart: isStart,
          slots: slots,
          currentValue: currentValue,
          formatSlot: _formatSlot,
          isSameTime: _isSameTime,
        );
      },
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController? controller,
    bool isStartTime,
    DateTime? date,
  ) async {
    final dateKey = date == null ? null : normalizeDate(date);
    final useCupertinoSheet =
        (selectedIndex == 1 && dateKey == null) || selectedIndex == 2;
    final sheetDate = _slotDateForTimeSelection(dateKey);

    if (useCupertinoSheet && sheetDate == null) return;
    if (useCupertinoSheet && !isStartTime) {
      final selectedStart = dateKey == null ? startTime : startTimes[dateKey];
      if (selectedStart == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select start time first")),
        );
        return;
      }
    }

    final now = DateTime.now();

    bool isToday = false;
    if (dateKey != null) {
      isToday =
          dateKey.year == now.year &&
          dateKey.month == now.month &&
          dateKey.day == now.day;
    } else {
      isToday = isTodaySelected();
    }

    TimeOfDay initial;
    if (isToday && isStartTime) {
      final roundedNow = DateTime(now.year, now.month, now.day, now.hour);
      final minAllowed = roundedNow.add(const Duration(hours: 4));
      initial = TimeOfDay.fromDateTime(minAllowed);
    } else {
      if (dateKey != null) {
        initial = isStartTime
            ? (startTimes[dateKey] ?? TimeOfDay.now())
            : (endTimes[dateKey] ?? TimeOfDay.now());
      } else {
        initial = isStartTime
            ? (startTime ?? TimeOfDay.now())
            : (endTime ?? TimeOfDay.now());
      }
    }

    final TimeOfDay? picked;
    if (useCupertinoSheet) {
      final selectedStart = dateKey == null ? startTime : startTimes[dateKey];
      final selectedEnd = dateKey == null ? endTime : endTimes[dateKey];
      picked = await _showCupertinoTimeSheet(
        context: context,
        isStart: isStartTime,
        selectedDate: sheetDate!,
        startBound: isStartTime ? null : selectedStart,
        currentValue: isStartTime ? selectedStart : selectedEnd,
      );
    } else {
      picked = await showTimePicker(
        context: context,
        initialTime: initial,
        builder: appTimePickerTheme,
      );
    }

    if (picked == null || !context.mounted) return;
    final selectedTime = picked;

    if (!useCupertinoSheet && isToday) {
      final roundedNow = DateTime(now.year, now.month, now.day, now.hour);
      final minAllowed = roundedNow.add(const Duration(hours: 4));
      final baseDate = dateKey ?? selectedDate!;
      final pickedDT = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        picked.hour,
        picked.minute,
      );
      if (pickedDT.isBefore(minAllowed)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select time after 4 hours")),
        );
        return;
      }
    }

    setState(() {
      if (dateKey != null) {
        if (isStartTime) {
          startTimes[dateKey] = selectedTime;
          if (endTimes[dateKey] != null &&
              !_isTimeAfter(selectedTime, endTimes[dateKey]!)) {
            endTimes[dateKey] = null;
          }
        } else {
          endTimes[dateKey] = selectedTime;
        }
      } else {
        if (isStartTime) {
          startTime = selectedTime;
          if (endTime != null && !_isTimeAfter(selectedTime, endTime!)) {
            endTime = null;
            endTimeController.clear();
          }
          if (controller != null) _updateTimeText(controller, selectedTime);
        } else {
          if (startTime != null && !_isTimeAfter(startTime!, selectedTime)) {
            return;
          }
          endTime = selectedTime;
          if (controller != null) _updateTimeText(controller, selectedTime);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dtState = ref.watch(
      shootDateTimeNotifierProvider(widget.ShootTypeId),
    );
    _syncEditTypesFromNotifier(dtState);

    return AppScaffold(
      hasAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _handleBack,
                child: SvgPicture.asset(AppAssets.back, height: 24),
              ),
            ),
            Text(
              "Create Project",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "1/3",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Row(
                  children: List.generate(3, (index) {
                    bool isActive = index == 0; // current step (1/3)

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textSubtle, // grey background
                          borderRadius: BorderRadius.circular(
                            AppRadii.enormous,
                          ),
                        ),
                        child: isActive
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 5,
                                  width: 120, // 🔥 colored portion only
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.enormous,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      textAlign: TextAlign.start,
                      "Select Booking Types",
                      style: AppTextStyles.titleSmall,
                    ),
                  ],
                ),
                SizedBox(height: 12),

                //////////////////////////////////////////////////////////////////////////
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = 1;

                                    /// 🔥 RESET ADD HERE
                                    startTimeStr = null;
                                    endTimeStr = null;
                                    startTimeMap.clear();
                                    endTimeMap.clear();
                                    isStartOpen = false;
                                    isEndOpen = false;
                                    startTime = null;
                                    endTime = null;
                                    startTimeController.clear();
                                    endTimeController.clear();
                                    startTimes.clear();
                                    endTimes.clear();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.base,
                                    vertical: AppSpacing.lg,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: selectedIndex == 1
                                        ? AppColors.goldHorizontalGradient
                                        : null,
                                    borderRadius: AppRadii.lgAll,
                                    border: selectedIndex == 1
                                        ? null
                                        : Border.all(color: AppColors.white30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ScaleClampedText(
                                        child: Text(
                                          "Single Day",
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: selectedIndex == 1
                                                    ? AppColors.black
                                                    : AppColors.disabled,
                                              ),
                                        ),
                                      ),
                                      selectedIndex == 1
                                          ? Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: selectedIndex == 1
                                                    ? LinearGradient(
                                                        colors: [
                                                          AppColors.black,
                                                          AppColors
                                                              .surfaceVariant,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      )
                                                    : null,
                                                border: selectedIndex == 1
                                                    ? Border.all(
                                                        color:
                                                            AppColors.disabled,
                                                      )
                                                    : null,
                                              ),
                                              child: selectedIndex == 1
                                                  ? Center(
                                                      child: Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            )
                                          : Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.white30,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = 2;

                                    /// 🔥 RESET ADD HERE
                                    startTimeStr = null;
                                    endTimeStr = null;
                                    startTimeMap.clear();
                                    endTimeMap.clear();
                                    isStartOpen = false;
                                    isEndOpen = false;
                                    startTime = null;
                                    endTime = null;
                                    startTimeController.clear();
                                    endTimeController.clear();
                                    startTimes.clear();
                                    endTimes.clear();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.base,
                                    vertical: AppSpacing.lg,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: selectedIndex == 2
                                        ? AppColors.goldHorizontalGradient
                                        : null,
                                    borderRadius: AppRadii.lgAll,
                                    border: selectedIndex == 2
                                        ? null
                                        : Border.all(color: AppColors.white30),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ScaleClampedText(
                                        child: Text(
                                          "Multiple Days",
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: selectedIndex == 2
                                                    ? AppColors.black
                                                    : AppColors.disabled,
                                              ),
                                        ),
                                      ),

                                      selectedIndex == 2
                                          ? Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                // color: selectedIndex == 1
                                                //     ? AppColors.black
                                                //     : AppColors.transparent,
                                                gradient: selectedIndex == 2
                                                    ? LinearGradient(
                                                        colors: [
                                                          AppColors.black,
                                                          AppColors
                                                              .surfaceVariant,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      )
                                                    : null,

                                                border: selectedIndex == 2
                                                    ? Border.all(
                                                        color:
                                                            AppColors.disabled,
                                                      )
                                                    : null,
                                              ),
                                              child: selectedIndex == 2
                                                  ? Center(
                                                      child: Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                      ),
                                                    )
                                                  : null,
                                            )
                                          : Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.white30,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 50),

                        if (selectedIndex == 2) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Select Date",
                                    style: AppTextStyles.titleSmall,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              buildDateSelector(
                                context: context,
                                selectedDates: selectedDates,
                                onChanged: (dates) {
                                  setState(() {
                                    selectedDates = dates;
                                  });
                                },
                              ),

                              SizedBox(height: 12),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: AppRadii.lgAll,
                                    ),
                                    child: Text(
                                      "Total Days: ${selectedDates.length}",
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontFamily: AppAssets.fontHelveticaNeue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: AppRadii.lgAll,
                                      ),
                                      child: selectedDates.isEmpty
                                          ? const Text(
                                              "No dates selected",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12,
                                              ),
                                            )
                                          : SingleChildScrollView(
                                              scrollDirection: Axis
                                                  .horizontal, // 👈 scroll enable
                                              child: Text(
                                                formatSelectedDates(
                                                  selectedDates,
                                                ),
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 13,
                                                  fontFamily: AppAssets
                                                      .fontHelveticaNeue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 18),
                              Text(
                                'Are Timings Same For All\nSelected Dates?',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.white,
                                  fontFamily: AppAssets.fontUnbounded,
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// 🔹 YES / NO
                              Row(
                                children: [
                                  _buildOption(
                                    title: "Yes",
                                    isSelected: istimingsame == true,
                                    onTap: () {
                                      setState(() {
                                        istimingsame = true;

                                        /// 🔥 RESET ADD HERE
                                        startTimeStr = null;
                                        endTimeStr = null;
                                        startTimeMap.clear();
                                        endTimeMap.clear();
                                        isStartOpen = false;
                                        isEndOpen = false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 24),
                                  _buildOption(
                                    title: "No",
                                    isSelected: istimingsame == false,
                                    onTap: () {
                                      setState(() {
                                        istimingsame = false;

                                        /// 🔥 RESET ADD HERE
                                        startTimeStr = null;
                                        endTimeStr = null;
                                        startTimeMap.clear();
                                        endTimeMap.clear();
                                        isStartOpen = false;
                                        isEndOpen = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (istimingsame == false) ...[
                                const SizedBox(height: 20),

                                Column(
                                  children: selectedDates.map((date) {
                                    final isOpen = expandedMap[date] ?? false;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        border: isOpen
                                            ? Border.all(
                                                color: AppColors.dividerDark,
                                              )
                                            : Border.all(
                                                color: AppColors.transparent,
                                              ),
                                        borderRadius: AppRadii.lgAll,
                                      ),
                                      child: Column(
                                        children: [
                                          /// 🔥 HEADER (Dropdown)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                /// 🔥 sab close karo
                                                expandedMap.updateAll(
                                                  (key, value) => false,
                                                );

                                                /// 🔥 sirf current open karo
                                                expandedMap[date] = !isOpen;
                                              });
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.base,
                                                    vertical: AppSpacing.base,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius: AppRadii.lgAll,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    DateTimeUtils.formatFullMonthDate(
                                                      date,
                                                    ),
                                                    style: const TextStyle(
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                  Icon(
                                                    isOpen
                                                        ? Icons
                                                              .keyboard_arrow_up
                                                        : Icons
                                                              .keyboard_arrow_down,
                                                    color: AppColors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          /// 🔥 BODY
                                          if (isOpen) ...[
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                AppSpacing.base,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  /// Start Time
                                                  AppTextField(
                                                    label: "Start Time",
                                                    controller:
                                                        TextEditingController(
                                                          text:
                                                              startTimes[normalizeDate(
                                                                    date,
                                                                  )]
                                                                  ?.format(
                                                                    context,
                                                                  ) ??
                                                              "",
                                                        ),
                                                    readOnly: true,
                                                    onTap: () {
                                                      _selectTime(
                                                        context,
                                                        null,
                                                        true,
                                                        date,
                                                      );
                                                    },
                                                    suffix: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            AppSpacing.md,
                                                          ),
                                                      child: SvgPicture.asset(
                                                        AppAssets.clock,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 30),
                                                  AppTextField(
                                                    label: "End Time",
                                                    controller:
                                                        TextEditingController(
                                                          text:
                                                              endTimes[normalizeDate(
                                                                    date,
                                                                  )]
                                                                  ?.format(
                                                                    context,
                                                                  ) ??
                                                              "",
                                                        ),
                                                    readOnly: true,
                                                    onTap: () {
                                                      _selectTime(
                                                        context,
                                                        null,
                                                        false,
                                                        date,
                                                      );
                                                    },
                                                    suffix: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            AppSpacing.md,
                                                          ),
                                                      child: SvgPicture.asset(
                                                        AppAssets.clock,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),

                                                  /// Duration
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius:
                                                          AppRadii.mdAll,
                                                    ),
                                                    child: Text(
                                                      getDurationText(date),
                                                      style: const TextStyle(
                                                        color: AppColors.black,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],

                              if (istimingsame == true) ...[
                                SizedBox(height: 22),

                                AppTextField(
                                  label: "Start Time",
                                  controller: startTimeController,
                                  readOnly: true,
                                  onTap: () {
                                    if (selectedDates.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please select date first",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    _selectTime(
                                      context,
                                      startTimeController,
                                      true,
                                      null,
                                    );
                                  },
                                  suffix: Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    child: SvgPicture.asset(
                                      AppAssets.clock,
                                      color: AppColors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 30),

                                AppTextField(
                                  label: "End Time",
                                  controller: endTimeController,
                                  readOnly: true,
                                  onTap: () {
                                    if (selectedDates.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please select date first",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    _selectTime(
                                      context,
                                      endTimeController,
                                      false,
                                      null,
                                    );
                                  },
                                  suffix: Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    child: SvgPicture.asset(
                                      AppAssets.clock,
                                      color: AppColors.white,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(height: 12),

                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppAssets.checkmark,
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Applied to ${selectedDates.length} selected dates',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w400,
                                        height: 1.36,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.mld),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: AppRadii.xlAll,
                                    border: Border.all(
                                      color: AppColors.dividerDark,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      /// 📅 ICON
                                      SvgPicture.asset(AppAssets.calndermark),

                                      const SizedBox(width: 13),

                                      /// 📅 DATE + TIME (DYNAMIC)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// 🔥 DYNAMIC DATE
                                            Text(
                                              formatDatesAlt(
                                                selectedDates,
                                              ), // ✅ already in your code
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    AppAssets.fontHelveticaNeue,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            /// 🔥 DYNAMIC TIME
                                            Text(
                                              startTime != null &&
                                                      endTime != null
                                                  ? "${DateTimeUtils.formatTimeOfDay(context, startTime)} – ${DateTimeUtils.formatTimeOfDay(context, endTime)}"
                                                  : "Select Time",
                                              style: TextStyle(
                                                fontFamily:
                                                    AppAssets.fontHelveticaNeue,

                                                color: AppColors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// ⏱ DYNAMIC HOURS
                                      Text(
                                        getDaysAndHours(), // 👇 function below
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontFamily:
                                              AppAssets.fontHelveticaNeue,

                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: 12),
                            ],
                          ),
                        ],

                        if (selectedIndex == 1) ...[
                          Row(
                            children: [
                              Text(
                                "Shoot Date & Time",
                                style: AppTextStyles.titleSmall,
                              ),
                            ],
                          ),

                          SizedBox(height: 30),

                          AppTextField(
                            label: "Select Date",
                            controller: dateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            suffix: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: SvgPicture.asset(
                                AppAssets.calendar,
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white70,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          AppTextField(
                            label: "Start Time",
                            controller: startTimeController,
                            readOnly: true,
                            onTap: () {
                              if (selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select date first"),
                                  ),
                                );
                                return;
                              }
                              _selectTime(
                                context,
                                startTimeController,
                                true,
                                null,
                              );
                            },
                            suffix: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: SvgPicture.asset(
                                AppAssets.clock,
                                color: AppColors.white,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          AppTextField(
                            label: "End Time",
                            controller: endTimeController,
                            readOnly: true,
                            onTap: () {
                              if (selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select date first"),
                                  ),
                                );
                                return;
                              }
                              if (startTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please select start time first",
                                    ),
                                  ),
                                );
                                return;
                              }
                              _selectTime(
                                context,
                                endTimeController,
                                false,
                                null,
                              );
                            },
                            suffix: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: SvgPicture.asset(
                                AppAssets.clock,
                                color: AppColors.white,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 TITLE
                            Text(
                              "Edits Needed?",
                              style: AppTextStyles.titleSmall,
                            ),

                            const SizedBox(height: 12),

                            /// 🔹 YES / NO
                            Row(
                              children: [
                                _buildOption(
                                  title: "Yes",
                                  isSelected: isEditNeeded == true,
                                  onTap: () {
                                    setState(() {
                                      isEditNeeded = true;
                                    });
                                  },
                                ),
                                const SizedBox(width: 24),
                                _buildOption(
                                  title: "No",
                                  isSelected: isEditNeeded == false,
                                  onTap: () {
                                    setState(() {
                                      isEditNeeded = false;

                                      // 🔥 CLEAR OLD DATA
                                      resetEditTypes();
                                    });
                                  },
                                ),
                              ],
                            ),

                            /// 🔥 ONLY SHOW WHEN YES SELECTED
                            if (isEditNeeded == true) ...[
                              const SizedBox(height: 30),

                              /// 🔹 INFO CONTAINER
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base,
                                  vertical: AppSpacing.mld,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: AppRadii.lgAll,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: AppColors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Editing includes",
                                          style: AppTextStyles.labelLarge
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Professional editing includes color grading, sound mixing, and basic revisions",
                                            style: const TextStyle(
                                              color: AppColors.white70,
                                              fontSize: 13,
                                              fontFamily: AppAssets.fontOutfit,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 30),

                              /*    GestureDetector(
                                onTap: _showEditTypeBottomSheet,
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: getEditTypeDisplayText(),
                                    ),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.white,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: getContentTypeTitle(widget.contentTypeId),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      suffixIcon: const Icon(
                                        Icons.keyboard_arrow_down,

                                        color: AppColors.white70,
                                      ),
                                      contentPadding:
                                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppRadii.lgAll,
                                        borderSide:
                                        const BorderSide(color: AppColors.white70, width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: AppRadii.lgAll,
                                        borderSide:
                                        const BorderSide(color: AppColors.white70, width: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                              Column(
                                children: [
                                  /// ✅ VIDEO ONLY IF DATA AVAILABLE
                                  if (editTypes.isNotEmpty)
                                    VideoEdits('Video Edits', editTypes),

                                  /// ✅ PHOTO ONLY IF DATA AVAILABLE
                                  /*  if (photoEditTypes.isNotEmpty)
                                    PhotoEdits('Photo Edits', photoEditTypes),*/
                                  if (widget.contentTypeId != 1 &&
                                      photoEditTypes.isNotEmpty)
                                    PhotoEdits('Photo Edits', photoEditTypes),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors
                                          .primary, // Beige/Cream color
                                      borderRadius: AppRadii
                                          .lgAll, // Fully rounded like the image
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black10,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Sparkle Icon Container
                                        Container(
                                          width: 34,
                                          height: 34,
                                          padding: EdgeInsets.all(
                                            AppSpacing.sm,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: AppColors.black,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              AppAssets.starIcon,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 5),

                                        // Text
                                        Expanded(
                                          child: Text(
                                            getFinalSummaryText(),
                                            style: AppTextStyles.buttonSmall
                                                .copyWith(
                                                  color: AppColors.surfaceDeep,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*  if (isSubmitting)
              Positioned.fill(
                child: Container(
                  color: AppColors.black.withOpacity(0.15), // optional dim
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),*/
        ],
      ),

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.disabled),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.mld,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    "Back",
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isFormValid && !isSubmitting
                      ? () {
                          debugPrint("✅ Continue clicked");
                          _ShootDate_Time(); // 🔥 API CALL
                        }
                      : null, // ❌ disabled when false

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFormValid
                        ? AppColors
                              .primary // ✅ active
                        : AppColors.surface, // ❌ disabled
                    foregroundColor: isFormValid
                        ? AppColors.black
                        : AppColors.disabled,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.mld,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                    elevation: isFormValid ? 2 : 0,
                  ),

                  child: Text(
                    "Continue",
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////
  Widget buildDateSelector({
    required BuildContext context,
    required List<DateTime> selectedDates,
    required Function(List<DateTime>) onChanged,
  }) {
    DateTime today = DateTime.now();

    /// ✅ Current month calculation (IMPORTANT FIX)
    DateTime lastDay = DateTime(today.year, today.month + 1, 0);
    int totalDays = lastDay.day;

    /// ✅ Only current month dates
    List<DateTime> allDates = List.generate(
      totalDays - today.day + 1,
      (index) => DateTime(today.year, today.month, today.day + index),
    );

    bool isSameDate(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    String getHeaderMonth() {
      return DateTimeUtils.formatMonthYear(today);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔥 Header
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getHeaderMonth(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppAssets.fontOutfit,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDateMultiple(context),
                  child: SvgPicture.asset(
                    AppAssets.calndermark,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔥 Horizontal Month Dates
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allDates.length,
              itemBuilder: (context, index) {
                final date = allDates[index];

                final isSelected = selectedDates.any(
                  (d) => isSameDate(d, date),
                );

                /// ✅ Disable past dates (optional but good)
                final isPast = date.isBefore(
                  DateTime(today.year, today.month, today.day),
                );

                return GestureDetector(
                  onTap: isPast
                      ? null
                      : () {
                          List<DateTime> updated = List.from(selectedDates);

                          if (isSelected) {
                            updated.removeWhere((d) => isSameDate(d, date));
                          } else {
                            updated.add(date);
                          }

                          onChanged(updated);

                          /// 🔥 UI refresh
                          (context as Element).markNeedsBuild();
                        },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.smd,
                    ),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.overlay,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontFamily: AppAssets.fontOutfit,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          DateTimeUtils.formatWeekdayShort(date),
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: AppAssets.fontOutfit,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget VideoEdits(String title, List<dynamic> data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white30, width: 0.5),
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          /// HEADER
          GestureDetector(
            onTap: () {
              setState(() {
                isVideoOpen = !isVideoOpen;

                /// ✅ CLOSE → CLEAR DATA
                /* if (!isVideoOpen) {
                    videoCounts.clear();
                    selectedEditTypeIds.clear();
                  }*/
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.xlAll,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  AnimatedRotation(
                    turns: isVideoOpen ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// BODY
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: isVideoOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,

            firstChild: Column(
              children: data.asMap().entries.map((entry) {
                int id = entry.key;
                var item = entry.value;

                String name = item['value'] ?? "";

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),

                      /// COUNTER
                      AppQtyCounter(
                        value: videoCounts[id] ?? 0,
                        onDecrement: () {
                          setState(() {
                            int current = videoCounts[id] ?? 0;
                            if (current > 0) {
                              current--;
                              if (current == 0) {
                                videoCounts.remove(id);
                                selectedEditTypeIds.remove(id);
                              } else {
                                videoCounts[id] = current;
                              }
                            }
                          });
                        },
                        onIncrement: () {
                          setState(() {
                            int current = videoCounts[id] ?? 0;
                            current++;
                            videoCounts[id] = current;
                            if (!selectedEditTypeIds.contains(id)) {
                              selectedEditTypeIds.add(id);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            secondChild: SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget PhotoEdits(String title, List<dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white30, width: 0.5),
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          /// HEADER
          GestureDetector(
            onTap: () {
              setState(() {
                isPhotoOpen = !isPhotoOpen;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.base,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    isPhotoOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),

          /// BODY
          if (isPhotoOpen)
            ...data.asMap().entries.map((entry) {
              int id = entry.key;
              var item = entry.value;

              String name = item['value'] ?? "";
              String note = item['note'] ?? "";
              int count = photoCounts[id] ?? 0;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.mld,
                    ),
                    child: Row(
                      children: [
                        /// TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                note,
                                style: const TextStyle(
                                  color: AppColors.disabled,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// COUNTER
                        AppQtyCounter(
                          value: count ~/ 25,
                          formatValue: (v) => v.toString(),
                          onDecrement: () {
                            setState(() {
                              int current = photoCounts[id] ?? 0;
                              if (current > 0) {
                                current -= 25;
                                if (current <= 0) {
                                  photoCounts.remove(id);
                                } else {
                                  photoCounts[id] = current;
                                }
                              }
                            });
                          },
                          onIncrement: () {
                            setState(() {
                              int current = photoCounts[id] ?? 0;
                              current += 25;
                              photoCounts[id] = current;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.base),
                    padding: const EdgeInsets.all(AppSpacing.mld),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: AppRadii.xlAll,
                    ),
                    child: Row(
                      children: [
                        /// 📸 ICON
                        Center(
                          child: Image.asset(AppAssets.emojiPhoto, height: 15),
                        ),

                        const SizedBox(width: 10),

                        /// TEXT
                        Expanded(
                          child: Text(
                            "Includes ${getIncludedPhotoCount()} free photo edits",
                            style: const TextStyle(
                              fontFamily: AppAssets.fontHelveticaNeue,

                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        /// DURATION
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadii.mdAll,
                          ),
                          child: Text(
                            getDurationSummaryLabel(),
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        /// 🔥 ADDED EXTRA BOX — shows only when count > 0
                      ],
                    ),
                  ),

                  /// 🔥 ADDED EXTRA BOX
                  // if (count > 0)
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.green
                      //color: AppColors.surfaceVariant,
                      //borderRadius: AppRadii.xlAll,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(AppSpacing.mld),
                        padding: const EdgeInsets.all(AppSpacing.mld),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.xlAll,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 12,
                              color: AppColors.primary,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "$count Added Extra",
                              style: const TextStyle(
                                fontFamily: AppAssets.fontHelveticaNeue,

                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(height: 0.5, color: AppColors.dividerDark),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary, // light gold
                        AppColors.primaryDark, // dark gold
                      ],
                    )
                  : null,
              border: Border.all(color: AppColors.white70, width: 1),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.black,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget buildTimeDropdown({
    Key? key, // ✅ FIX ADD THIS
    required String title,
    required String? selectedTime,
    required Function(String) onSelect,
    required bool isStart,
    DateTime? date,
  }) {
    bool isOpen = isStart ? isStartOpen : isEndOpen;
    bool highlight = selectedTime != null;

    final list = generateTimeList(isStart: isStart, date: date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 TITLE
        /*       Text( title, style: TextStyle(color: AppColors.white,fontFamily: AppAssets.fontOutfit,fontSize: 12)),

  SizedBox(height: 10,),*/
        /// 🔹 SELECT BOX
        GestureDetector(
          onTap: () {
            if (selectedIndex == 1 && selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please select date first")),
              );
              return;
            }

            if (selectedIndex == 2 && selectedDates.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please select date first")),
              );
              return;
            }

            if (isStart) {
              setState(() {
                isStartOpen = !isStartOpen;
                isEndOpen = false;
              });
            } else {
              if (selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select start time first")),
                );
                return;
              }

              setState(() {
                isEndOpen = !isEndOpen;
                isStartOpen = false;
              });
            }
          },

          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.mld),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadii.mld),
                  border: Border.all(
                    color: highlight
                        ? AppColors
                              .borderGold // ✅ selected
                        : AppColors.white30, // ❌ default
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTime ?? " ",
                      style: TextStyle(color: AppColors.white),
                    ),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 14,
                top: -10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxxs,
                  ),
                  color: AppColors.background, // background match
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: highlight ? AppColors.primary : AppColors.white60,
                      fontFamily: AppAssets.fontOutfit,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10),

        /// 🔥 DROPDOWN LIST
        if (isOpen)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.white70, width: 0.5),
              borderRadius: AppRadii.lgAll,
            ),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final time = list[index];
                final isSelected = time == selectedTime;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      onSelect(time);

                      /// 🔥 AUTO NEXT TIME
                      if (isStart) {
                        int i = list.indexOf(time);
                        if (i != -1 && i + 1 < list.length) {
                          if (date != null) {
                            endTimeMap[date] = list[i + 1];
                          } else {
                            endTimeStr = list[i + 1];
                          }
                        }

                        isStartOpen = false;
                        isEndOpen = true;
                      } else {
                        isEndOpen = false;
                      }
                    });
                  },

                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                      horizontal: AppSpacing.sm,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.mld),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.transparent,
                      ),
                    ),

                    child: Row(
                      children: [
                        /// 🔘 RADIO
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.black
                                  : AppColors.white60,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),

                        SizedBox(width: 12),

                        /// ⏰ TIME TEXT
                        Text(
                          time,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.black
                                : AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CupertinoTimeSheetContent extends StatefulWidget {
  const _CupertinoTimeSheetContent({
    required this.isStart,
    required this.slots,
    required this.currentValue,
    required this.formatSlot,
    required this.isSameTime,
  });

  final bool isStart;
  final List<TimeOfDay> slots;
  final TimeOfDay? currentValue;
  final String Function(TimeOfDay time) formatSlot;
  final bool Function(TimeOfDay a, TimeOfDay b) isSameTime;

  @override
  State<_CupertinoTimeSheetContent> createState() =>
      _CupertinoTimeSheetContentState();
}

class _CupertinoTimeSheetContentState
    extends State<_CupertinoTimeSheetContent> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSlots = _query.isEmpty
        ? widget.slots
        : widget.slots.where((slot) {
            return widget
                .formatSlot(slot)
                .toLowerCase()
                .contains(_query.toLowerCase());
          }).toList();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: AppColors.transparent,
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: AppRadii.topSheet,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.isStart ? 'Start Time' : 'End Time',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        if (widget.currentValue != null)
                          Container(
                            margin: const EdgeInsets.only(
                              right: AppSpacing.xxs,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: AppRadii.fullAll,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              widget.formatSlot(widget.currentValue!),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.dividerDark),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: AppTextField(
                      hint: widget.isStart
                          ? 'Search Start Time...'
                          : 'Search End Time...',
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() => _query = value.trim());
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredSlots.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 32,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'No slots available',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.base,
                              AppSpacing.xxs,
                              AppSpacing.base,
                              AppSpacing.base,
                            ),
                            itemCount: filteredSlots.length,
                            itemBuilder: (context, index) {
                              final slot = filteredSlots[index];
                              final isSelected =
                                  widget.currentValue != null &&
                                  widget.isSameTime(widget.currentValue!, slot);

                              return Semantics(
                                button: true,
                                selected: isSelected,
                                label: widget.formatSlot(slot),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => Navigator.of(context).pop(slot),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: AppSpacing.jumbo,
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.xxs,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.base,
                                      vertical: AppSpacing.md,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.18,
                                            )
                                          : AppColors.transparent,
                                      borderRadius: AppRadii.mdAll,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.transparent,
                                        width: 0.5,
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      widget.formatSlot(slot),
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
