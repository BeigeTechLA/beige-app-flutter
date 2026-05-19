import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  /// ✅ Format Date → dd-MM-yyyy
  static String formatDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date);
      return DateFormat("dd-MM-yyyy").format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19, 2026
  static String formatReadableDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date);
      return DateFormat("MMM d, yyyy").format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → Tue, 19 May 2026
  static String formatWeekdayDate(String? date, {String fallback = "--"}) {
    try {
      if (date == null || date.isEmpty) return fallback;

      final parsed = DateTime.parse(date);
      return DateFormat("EEE, dd MMM yyyy").format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date Time → Tue, 19 May • 09:00 AM
  static String formatTimelineDateTime(
    String? isoTime, {
    String fallback = "--",
  }) {
    try {
      if (isoTime == null || isoTime.isEmpty) return fallback;

      final parsed = DateTime.parse(isoTime).toLocal();
      return DateFormat("EEE, dd MMM • hh:mm a").format(parsed);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 19, 2026
  static String formatFullMonthDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat("MMMM dd, yyyy").format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → May 2026
  static String formatMonthYear(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat("MMM yyyy").format(date);
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Format Date → Tue
  static String formatWeekdayShort(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return DateFormat("EEE").format(date);
    } catch (_) {
      return fallback;
    }
  }

  static String formatTime(String? time, {String fallback = "--"}) {
    try {
      if (time == null || time.isEmpty) return fallback;

      DateTime parsed;

      /// 🔥 CASE 1: HH:mm:ss (normal API)
      if (time.contains(":") && time.length == 8) {
        parsed = DateFormat("HH:mm:ss").parse(time);
      }
      /// 🔥 CASE 2: HH:mm (sometimes API gives this)
      else if (time.contains(":") && time.length == 5) {
        parsed = DateFormat("HH:mm").parse(time);
      }
      /// 🔥 CASE 3: already ISO format
      else {
        parsed = DateTime.parse(time);
      }

      return DateFormat("hh:mm a").format(parsed);
    } catch (_) {
      return fallback;
    }
  }

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

  static String formatTimeOfDayShort(
    TimeOfDay? time, {
    String fallback = "--",
  }) {
    try {
      if (time == null) return fallback;

      return DateFormat(
        "h:mm a",
      ).format(DateTime(2000, 1, 1, time.hour, time.minute));
    } catch (_) {
      return fallback;
    }
  }

  static String formatDuration(double? hours) {
    try {
      if (hours == null || hours.isNaN || hours.isInfinite) return "--";

      int h = hours.floor();
      int m = ((hours - h) * 60).round();

      if (m == 60) {
        h += 1;
        m = 0;
      }

      if (m == 0) return "${h}h";

      return "${h}h ${m}m";
    } catch (_) {
      return "--";
    }
  }

  static String formatApiDate(DateTime? date, {String fallback = "--"}) {
    try {
      if (date == null) return fallback;

      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return fallback;
    }
  }

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

  static String formatMonthDaysWithCommaYear(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      dates.sort();

      final days = dates.map((date) => DateFormat("d").format(date)).toList();
      final lastDate = dates.last;
      final month = DateFormat("MMM").format(lastDate);
      final year = DateFormat("yyyy").format(lastDate);

      return "$month ${_joinDays(days)}, $year";
    } catch (_) {
      return fallback;
    }
  }

  static String formatSelectedDaysWithLastMonthYear(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      dates.sort();

      final days = dates.map((date) => DateFormat("d").format(date)).toList();
      final monthYear = DateFormat("MMM yyyy").format(dates.last);

      return "Selected Days: ${_joinDays(days)} $monthYear";
    } catch (_) {
      return fallback;
    }
  }

  static String formatGroupedSelectedDaysLabel(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      return "Selected Days: ${_formatGroupedMonthDays(dates)}";
    } catch (_) {
      return fallback;
    }
  }

  static String formatGroupedMonthDays(
    List<DateTime> dates, {
    String fallback = "",
  }) {
    try {
      if (dates.isEmpty) return fallback;

      return _formatGroupedMonthDays(dates, monthFirst: true);
    } catch (_) {
      return fallback;
    }
  }

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
        return DateFormat("MMM d, yyyy").format(parsedDates.first);
      }

      final first = parsedDates.first;
      final last = parsedDates.last;

      if (first.year == last.year && first.month == last.month) {
        return "${DateFormat("MMM d").format(first)}–${last.day}, ${last.year}";
      }

      if (first.year == last.year) {
        return "${DateFormat("MMM d").format(first)} – "
            "${DateFormat("MMM d, yyyy").format(last)}";
      }

      return "${DateFormat("MMM d, yyyy").format(first)} – "
          "${DateFormat("MMM d, yyyy").format(last)}";
    } catch (_) {
      return fallback;
    }
  }

  /// ✅ Date + Time together
  static String formatDateTime(
    String? date,
    String? time, {
    String fallback = "--",
  }) {
    try {
      if (date == null || time == null) return fallback;

      final dateParsed = DateTime.parse(date);
      final timeParsed = DateFormat("HH:mm:ss").parse(time);

      final combined = DateTime(
        dateParsed.year,
        dateParsed.month,
        dateParsed.day,
        timeParsed.hour,
        timeParsed.minute,
      );

      return DateFormat("dd-MM-yyyy hh:mm a").format(combined);
    } catch (_) {
      return fallback;
    }
  }

  static String _formatGroupedMonthDays(
    List<DateTime> dates, {
    bool monthFirst = false,
  }) {
    dates.sort();

    final monthMap = <String, List<int>>{};

    for (final date in dates) {
      final key = DateFormat("MMM yyyy").format(date);
      monthMap.putIfAbsent(key, () => []);
      monthMap[key]!.add(date.day);
    }

    final result = <String>[];

    monthMap.forEach((month, days) {
      days.sort();
      final daysText = _joinDays(days.map((day) => "$day").toList());
      result.add(monthFirst ? "$month $daysText" : "$daysText $month");
    });

    return result.join(", ");
  }

  static String _joinDays(List<String> days) {
    if (days.length == 1) return days.first;
    if (days.length == 2) return "${days[0]} & ${days[1]}";

    return "${days.sublist(0, days.length - 1).join(', ')} & ${days.last}";
  }
}
