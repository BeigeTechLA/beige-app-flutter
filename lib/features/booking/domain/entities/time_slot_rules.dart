import 'package:flutter/material.dart';

/// Pure, UI-free time-slot rules for the Book-a-Shoot v2 When & Where screen.
///
/// Extracted from the legacy `shoot_date_time_screen.dart` so the booking
/// window logic (15-minute slots + the 4-hour lead-time rule) can be unit
/// tested in isolation and reused by both single-day and multi-day pickers.
///
/// Every function takes an explicit `now` so behaviour is deterministic in
/// tests; callers pass `DateTime.now()`.
class TimeSlotRules {
  const TimeSlotRules._();

  /// Minimum lead time between "now" and the earliest selectable start slot.
  static const Duration leadTime = Duration(hours: 4);

  /// Slot granularity.
  static const Duration slotStep = Duration(minutes: 15);

  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int minutesOfDay(TimeOfDay t) => t.hour * 60 + t.minute;

  static bool isSameTime(TimeOfDay a, TimeOfDay b) =>
      a.hour == b.hour && a.minute == b.minute;

  /// True when [end] is strictly later in the day than [start].
  static bool isTimeAfter(TimeOfDay start, TimeOfDay end) =>
      minutesOfDay(end) > minutesOfDay(start);

  static DateTime dateTimeFor(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  /// Rounds [dt] up to the next 15-minute boundary.
  static DateTime roundUp15(DateTime dt) {
    final remainder = dt.minute % 15;
    final add = remainder == 0 && dt.second == 0 && dt.millisecond == 0
        ? 0
        : 15 - remainder;
    final rounded = DateTime(
      dt.year,
      dt.month,
      dt.day,
      dt.hour,
      dt.minute,
    ).add(Duration(minutes: add));
    return rounded;
  }

  static TimeOfDay roundUp15TimeOfDay(DateTime dt) =>
      TimeOfDay.fromDateTime(roundUp15(dt));

  /// All selectable 15-minute slots for [date].
  ///
  /// - If [date] is today, slots start no earlier than now + [leadTime]
  ///   (the 4-hour rule), rounded up to the next quarter hour.
  /// - When building the end-time list, pass [startBound] to keep only slots
  ///   strictly after the chosen start.
  /// - Returns an empty list when the lead time pushes past the same day
  ///   (e.g. selecting "today" late in the evening).
  static List<TimeOfDay> buildSlots({
    required DateTime date,
    required bool isStart,
    required DateTime now,
    TimeOfDay? startBound,
  }) {
    final latestSlot = DateTime(date.year, date.month, date.day, 23, 45);
    var current = DateTime(date.year, date.month, date.day);

    if (isSameDate(date, now)) {
      current = roundUp15(now.add(leadTime));
      if (!isSameDate(current, date) || current.isAfter(latestSlot)) {
        return <TimeOfDay>[];
      }
    }

    final startBoundMinutes =
        !isStart && startBound != null ? minutesOfDay(startBound) : null;
    final slots = <TimeOfDay>[];

    while (!current.isAfter(latestSlot)) {
      final slot = TimeOfDay.fromDateTime(current);
      if (startBoundMinutes == null || minutesOfDay(slot) > startBoundMinutes) {
        slots.add(slot);
      }
      current = current.add(slotStep);
    }

    return slots;
  }

  /// Default end time = start + [leadTime] (4 hours), clamped to the last slot
  /// of the day. Returns `null` only when no valid end exists after [start].
  static TimeOfDay? defaultEndForStart({
    required DateTime date,
    required TimeOfDay start,
    required DateTime now,
  }) {
    var endDateTime = dateTimeFor(date, start).add(leadTime);
    final latestSlot = DateTime(date.year, date.month, date.day, 23, 45);
    if (endDateTime.isAfter(latestSlot)) {
      endDateTime = latestSlot;
    }
    final end = TimeOfDay.fromDateTime(endDateTime);
    return isTimeAfter(start, end) ? end : null;
  }

  /// Default start for [date]: next valid slot ≥ now+4h on today, else 9:00 AM.
  /// Returns `null` when the day has no selectable slots.
  static TimeOfDay? defaultStartForDate({
    required DateTime date,
    required DateTime now,
  }) {
    final startSlots = buildSlots(date: date, isStart: true, now: now);
    if (startSlots.isEmpty) return null;

    final desired = isSameDate(date, now)
        ? roundUp15TimeOfDay(now.add(leadTime))
        : const TimeOfDay(hour: 9, minute: 0);

    return startSlots.firstWhere(
      (slot) => isSameTime(slot, desired),
      orElse: () => startSlots.first,
    );
  }

  /// Whole-hour duration (rounded up) between [start] and [end] on a day.
  /// Overnight (end ≤ start) wraps to the next day.
  static int durationHours(TimeOfDay start, TimeOfDay end) {
    final startMin = minutesOfDay(start);
    final endMin = minutesOfDay(end);
    final diff = endMin > startMin ? endMin - startMin : (24 * 60 - startMin) + endMin;
    if (diff <= 0) return 0;
    return (diff / 60).ceil();
  }
}
