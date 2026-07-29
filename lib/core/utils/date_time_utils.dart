import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  // ───────────────────────────────────────────────────────────────
  // Format pattern constants (single source of truth).
  // ───────────────────────────────────────────────────────────────

  /// `05-19-2026`
  static const String kDatePattern = "MM-dd-yyyy";

  /// `May 19, 2026`
  static const String kReadableDatePattern = "MMM d, yyyy";

  /// `Tue, 19 May 2026`
  static const String kWeekdayDatePattern = "EEE, dd MMM yyyy";

  /// `Tue, 19 May • 09:00 AM`
  static const String kTimelineDateTimePattern = "EEE, dd MMM • hh:mm a";

  /// `May 19, 2026`
  static const String kFullMonthDatePattern = "MMMM dd, yyyy";

  /// `May 19,2026` — meeting listing / details / create / edit.
  static const String kMeetingDatePattern = "MMM dd,yyyy";

  /// `May 2026`
  static const String kMonthYearPattern = "MMM yyyy";

  /// `Tue`
  static const String kWeekdayShortPattern = "EEE";

  /// `09:00:00` — API/parse input.
  static const String kTime24HmsPattern = "HH:mm:ss";

  /// `09:00` — API/parse input.
  static const String kTime24HmPattern = "HH:mm";

  /// `09:00 AM`
  static const String kTime12HourPattern = "hh:mm a";

  /// `9:00 AM`
  static const String kTime12HourShortPattern = "h:mm a";

  /// `19` — day-of-month only.
  static const String kDayOfMonthPattern = "d";

  /// `May` — month only.
  static const String kMonthShortPattern = "MMM";

  /// `2026` — year only.
  static const String kYearPattern = "yyyy";

  /// `May 19` — month + day (range start).
  static const String kMonthDayPattern = "MMM d";

  /// `05-19-2026 09:00 AM`
  static const String kDateTimePattern = "MM-dd-yyyy hh:mm a";

  // ───────────────────────────────────────────────────────────────

  /// ✅ Format Date → MM-dd-yyyy
  ///
  /// Used in:
  /// - home_screen.dart
  /// - manage_shoot_screen.dart
  /// - cancel_shoot_screen.dart
  /// - shoot_summary_screen.dart
  static String formatDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date);
      return formatDateValue(parsed, fallback: fallback);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format DateTime → MM-dd-yyyy
  ///
  /// Used in:
  /// - shoot_date_time_screen.dart
  static String formatDateValue(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kDatePattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19, 2026
  ///
  /// Used in: (available — no current call sites)
  static String formatReadableDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date);
      return DateFormat(kReadableDatePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → Tue, 19 May 2026
  ///
  /// Used in:
  /// - shoot_edit_review_screen.dart
  static String formatWeekdayDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date);
      return DateFormat(kWeekdayDatePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date Time → Tue, 19 May • 09:00 AM
  ///
  /// Used in:
  /// - shoot_summary_screen.dart
  static String formatTimelineDateTime(
    String? isoTime, {
    String fallback = "--",
  }) {
    try {
      if (isoTime == null || isoTime.isEmpty) return fallback;

      final parsed = DateTime.parse(isoTime).toLocal();
      return DateFormat(kTimelineDateTimePattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19, 2026
  ///
  /// Used in:
  /// - shoot_type_selection_screen.dart
  /// - shoot_date_time_screen.dart
  static String formatFullMonthDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kFullMonthDatePattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19,2026
  ///
  /// Used in:
  /// - meeting_card.dart
  /// - meeting_details_sheet.dart
  /// - create_meeting_screen.dart
  /// - edit_meeting_screen.dart
  static String formatMeetingDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kMeetingDatePattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 2026
  ///
  /// Used in:
  /// - shoot_type_selection_screen.dart
  /// - shoot_date_time_screen.dart
  static String formatMonthYear(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kMonthYearPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → Tue
  ///
  /// Used in:
  /// - shoot_type_selection_screen.dart
  /// - shoot_date_time_screen.dart
  static String formatWeekdayShort(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat(kWeekdayShortPattern).format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Time → 09:00 AM
  ///
  /// Used in:
  /// - home_screen.dart
  /// - shoot_edit_review_screen.dart
  /// - manage_shoot_screen.dart
  /// - cancel_shoot_screen.dart
  /// - shoot_review_screen.dart
  /// - shoot_summary_screen.dart
  static String formatTime(String? time, {String fallback = "--"}) {
    try {
      if (time == null || time.isEmpty) return fallback;

      DateTime parsed;

      /// 🔥 CASE 1: HH:mm:ss (normal API)
      if (time.contains(":") && time.length == 8) {
        parsed = DateFormat(kTime24HmsPattern).parse(time);
      }
      /// 🔥 CASE 2: HH:mm (sometimes API gives this)
      else if (time.contains(":") && time.length == 5) {
        parsed = DateFormat(kTime24HmPattern).parse(time);
      }
      /// 🔥 CASE 3: already ISO format
      else {
        parsed = DateTime.parse(time);
      }

      return DateFormat(kTime12HourPattern).format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Time without leading zero → 9:00 AM
  ///
  /// Used in:
  /// - my_shoots_screen.dart
  static String formatTimeWithoutLeadingZero(
    String? time, {
    String fallback = "",
  }) {
    try {
      final formatted = formatTime(time, fallback: fallback);
      if (formatted == fallback) return fallback;

      return formatted.startsWith("0") ? formatted.substring(1) : formatted;
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format TimeOfDay (locale-aware) → 9:00 AM
  ///
  /// Used in:
  /// - shoot_type_selection_screen.dart
  /// - shoot_date_time_screen.dart
  static String formatTimeOfDay(
    BuildContext context,
    TimeOfDay? time, {
    String fallback = "",
  }) {
    try {
      if (time == null) return fallback;

      return time.format(context);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format TimeOfDay short → 9:00 AM
  ///
  /// Used in:
  /// - shoot_date_time_screen.dart
  static String formatTimeOfDayShort(
    TimeOfDay? time, {
    String fallback = "--",
  }) {
    try {
      if (time == null) return fallback;

      return DateFormat(
        kTime12HourShortPattern,
      ).format(DateTime(2000, 1, 1, time.hour, time.minute));
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Duration → 2h 30m
  ///
  /// Used in:
  /// - manage_shoot_screen.dart
  /// - shoot_review_screen.dart
  /// - shoot_summary_screen.dart
  static String formatDuration(double? hours, {String fallback = "--"}) {
    try {
      if (hours == null || hours.isNaN || hours.isInfinite) return fallback;

      int h = hours.floor();
      int m = ((hours - h) * 60).round();

      if (m == 60) {
        h += 1;
        m = 0;
      }

      if (m == 0) return "${h}h";

      return "${h}h ${m}m";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format API date payload → 2026-05-19
  ///
  /// Used in:
  /// - shoot_date_time_screen.dart
  static String formatApiDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format API time payload → 09:00:00
  ///
  /// Used in:
  /// - shoot_date_time_screen.dart
  static String formatApiTime(TimeOfDay? time, {String fallback = "--"}) {
    try {
      if (time == null) return fallback;

      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return "$hour:$minute:00";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format month + days summary → May 19 & 20, 2026
  ///
  /// Used in:
  /// - shoot_type_selection_screen.dart
  static String formatMonthDaysWithCommaYear(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    return formatGroupedMonthDays(dates, fallback: fallback);
  }

  /// ✅ Selected-days label → Selected Days: Jul 31, 2026 • Aug 20 & 21, 2026
  ///
  /// Used in:
  /// - shoot_type_selection_screen.dart
  static String formatSelectedDaysWithLastMonthYear(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    return formatGroupedSelectedDaysLabel(dates, fallback: fallback);
  }

  /// ✅ Grouped selected-days label (TOP PLACE) → Selected Days: Jul 31, 2026 • Aug 20 & 21, 2026
  ///
  /// Used in:
  /// - shoot_date_time_screen.dart
  /// - shoot_type_selection_screen.dart
  static String formatGroupedSelectedDaysLabel(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      return "Selected Days: ${_formatGroupedMonthDays(dates, separator: " • ", useBullets: false)}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Grouped compact summary (BELOW CARD PLACE) → Multiline bullet list per month change
  ///
  /// Used in:
  /// - shoot_date_time_screen.dart
  /// - shoot_type_selection_screen.dart
  static String formatGroupedMonthDays(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      return _formatGroupedMonthDays(dates, separator: "\n", useBullets: true);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Card single/range date → May 19, 2026 or May 19–21, 2026
  ///
  /// Used in:
  /// - my_shoots_screen.dart
  static String formatCardDateRange(String? value, {String fallback = ""}) {
    try {
      if (value == null || value.isEmpty) return fallback;

      final rawDates = value
          .split(',')
          .map((date) => date.trim())
          .where((date) => date.isNotEmpty)
          .toList();

      if (rawDates.isEmpty) return fallback;

      final parsedDates = rawDates
          .map((date) => DateTime.tryParse(date))
          .whereType<DateTime>()
          .toList();

      if (parsedDates.length != rawDates.length) return value;
      if (parsedDates.length == 1) {
        return DateFormat(kReadableDatePattern).format(parsedDates.first);
      }

      final first = parsedDates.first;
      final last = parsedDates.last;

      if (first.year == last.year && first.month == last.month) {
        return "${DateFormat(kMonthDayPattern).format(first)}–${last.day}, ${last.year}";
      }

      if (first.year == last.year) {
        return "${DateFormat(kMonthDayPattern).format(first)} – "
            "${DateFormat(kReadableDatePattern).format(last)}";
      }

      return "${DateFormat(kReadableDatePattern).format(first)} – "
          "${DateFormat(kReadableDatePattern).format(last)}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Date + Time together → MM-dd-yyyy 09:00 AM
  ///
  /// Used in: (available — no current call sites)
  static String formatDateTime(
    String? date,
    String? time, {
    String fallback = "--",
  }) {
    try {
      if (date == null || time == null) return fallback;

      final dateParsed = DateTime.parse(date);
      final timeParsed = DateFormat(kTime24HmsPattern).parse(time);

      final combined = DateTime(
        dateParsed.year,
        dateParsed.month,
        dateParsed.day,
        timeParsed.hour,
        timeParsed.minute,
      );

      return DateFormat(kDateTimePattern).format(combined);
    } catch (_) {
      return fallback;
    }
  }

  static String _formatGroupedMonthDays(
    List<DateTime> dates, {
    String separator = " • ",
    bool useBullets = false,
  }) {
    if (dates.isEmpty) return "";
    dates.sort();

    final monthMap = <String, Map<String, dynamic>>{};

    for (final date in dates) {
      final key = "${date.year}-${date.month}";
      if (!monthMap.containsKey(key)) {
        monthMap[key] = {
          'month': DateFormat(kMonthShortPattern).format(date),
          'year': DateFormat(kYearPattern).format(date),
          'days': <int>[],
        };
      }
      (monthMap[key]!['days'] as List<int>).add(date.day);
    }

    final result = <String>[];
    final bool includeBullet = useBullets && monthMap.length > 1;

    monthMap.forEach((_, data) {
      final days = data['days'] as List<int>;
      days.sort();
      final daysText = _joinDays(days.map((day) => "$day").toList());
      final month = data['month'] as String;
      final year = data['year'] as String;

      final bullet = includeBullet ? "• " : "";
      result.add("$bullet$month $daysText, $year");
    });

    return result.join(separator);
  }

  static String _joinDays(List<String> days) {
    if (days.length == 1) return days.first;
    if (days.length == 2) return "${days[0]} & ${days[1]}";

    return "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
  }
}
