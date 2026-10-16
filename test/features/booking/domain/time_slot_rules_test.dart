import 'package:beige/features/booking/domain/entities/time_slot_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Fixed "now" at 10:05 so the 4-hour rule and 15-min rounding are exercised.
  final now = DateTime(2026, 1, 12, 10, 5);
  final today = DateTime(2026, 1, 12);
  final future = DateTime(2026, 1, 20);

  group('roundUp15', () {
    test('rounds a partial quarter up', () {
      expect(
        TimeSlotRules.roundUp15(DateTime(2026, 1, 12, 10, 5)),
        DateTime(2026, 1, 12, 10, 15),
      );
    });

    test('leaves an exact boundary unchanged', () {
      expect(
        TimeSlotRules.roundUp15(DateTime(2026, 1, 12, 10, 30)),
        DateTime(2026, 1, 12, 10, 30),
      );
    });
  });

  group('buildSlots — happy path', () {
    test('future day returns full-day 15-min grid starting at 00:00', () {
      final slots =
          TimeSlotRules.buildSlots(date: future, isStart: true, now: now);
      expect(slots.first, const TimeOfDay(hour: 0, minute: 0));
      expect(slots.last, const TimeOfDay(hour: 23, minute: 45));
      expect(slots.length, 96); // 24h * 4
    });
  });

  group('buildSlots — 4-hour rule (edge)', () {
    test('today starts no earlier than now+4h rounded up', () {
      final slots =
          TimeSlotRules.buildSlots(date: today, isStart: true, now: now);
      // now 10:05 + 4h = 14:05 → rounds up to 14:15.
      expect(slots.first, const TimeOfDay(hour: 14, minute: 15));
    });

    test('end slots are strictly after the chosen start bound', () {
      final slots = TimeSlotRules.buildSlots(
        date: future,
        isStart: false,
        now: now,
        startBound: const TimeOfDay(hour: 9, minute: 0),
      );
      expect(slots.first, const TimeOfDay(hour: 9, minute: 15));
      expect(slots.every((s) => TimeSlotRules.minutesOfDay(s) > 9 * 60), isTrue);
    });
  });

  group('buildSlots — error/empty', () {
    test('today late in the evening past the 4h window yields no slots', () {
      final lateNow = DateTime(2026, 1, 12, 20, 30); // +4h = 00:30 next day
      final slots = TimeSlotRules.buildSlots(
        date: today,
        isStart: true,
        now: lateNow,
      );
      expect(slots, isEmpty);
    });
  });

  group('defaultEndForStart', () {
    test('returns start + 4h on a normal day', () {
      final end = TimeSlotRules.defaultEndForStart(
        date: future,
        start: const TimeOfDay(hour: 9, minute: 0),
        now: now,
      );
      expect(end, const TimeOfDay(hour: 13, minute: 0));
    });

    test('clamps to 23:45 when start + 4h overflows the day', () {
      final end = TimeSlotRules.defaultEndForStart(
        date: future,
        start: const TimeOfDay(hour: 22, minute: 0),
        now: now,
      );
      expect(end, const TimeOfDay(hour: 23, minute: 45));
    });
  });

  group('defaultStartForDate', () {
    test('future day defaults to 9:00 AM', () {
      expect(
        TimeSlotRules.defaultStartForDate(date: future, now: now),
        const TimeOfDay(hour: 9, minute: 0),
      );
    });

    test('today defaults to the first slot after the 4h rule', () {
      expect(
        TimeSlotRules.defaultStartForDate(date: today, now: now),
        const TimeOfDay(hour: 14, minute: 15),
      );
    });

    test('returns null when the day has no available slots', () {
      final lateNow = DateTime(2026, 1, 12, 21, 0);
      expect(
        TimeSlotRules.defaultStartForDate(date: today, now: lateNow),
        isNull,
      );
    });
  });

  group('durationHours', () {
    test('same-day whole hours', () {
      expect(
        TimeSlotRules.durationHours(
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 18, minute: 0),
        ),
        8,
      );
    });

    test('rounds partial hours up', () {
      expect(
        TimeSlotRules.durationHours(
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 12, minute: 30),
        ),
        3,
      );
    });

    test('overnight end wraps to next day', () {
      expect(
        TimeSlotRules.durationHours(
          const TimeOfDay(hour: 22, minute: 0),
          const TimeOfDay(hour: 2, minute: 0),
        ),
        4,
      );
    });
  });
}
