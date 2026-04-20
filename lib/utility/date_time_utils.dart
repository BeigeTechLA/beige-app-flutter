import 'package:intl/intl.dart';

class DateTimeUtils {

  /// ✅ Format Date → dd-MM-yyyy
  static String formatDate(String? date) {
    if (date == null || date.isEmpty) return "--";
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd-MM-yyyy").format(parsed);
    } catch (e) {
      return "--";
    }
  }

  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return "--";

    try {
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
    } catch (e) {
      return "--";
    }
  }
  static String formatDuration(double? hours) {

    if (hours == null) return "--";

    int h = hours.floor();
    int m = ((hours - h) * 60).round();

    if (m == 60) {
      h += 1;
      m = 0;
    }

    if (m == 0) return "${h}h";

    return "${h}h ${m}m";
  }
  /// ✅ Date + Time together
  static String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return "--";
    try {
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
    } catch (e) {
      return "--";
    }
  }
}