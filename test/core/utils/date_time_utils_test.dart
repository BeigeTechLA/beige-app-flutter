import 'package:beige/core/utils/date_time_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  tearDown(() {
    // Reset to default (UTC) so tests don't leak zone state.
    DateTimeUtils.setActiveTimezone('');
  });

  group('formatZonedTime', () {
    test('happy path — converts UTC instant to user zone (non-DST)', () {
      // 2026-01-15 20:00Z → America/Los_Angeles is UTC-8 in January → 12:00 PM.
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      final utc = DateTime.utc(2026, 1, 15, 20, 0);
      expect(DateTimeUtils.formatZonedTime(utc), '12:00 PM');
    });

    test('edge case — DST shift (PDT UTC-7 in July)', () {
      // 2026-07-15 20:00Z → America/Los_Angeles is UTC-7 in July → 01:00 PM.
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      final utc = DateTime.utc(2026, 7, 15, 20, 0);
      expect(DateTimeUtils.formatZonedTime(utc), '01:00 PM');
    });

    test('error case — null instant returns fallback', () {
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      expect(DateTimeUtils.formatZonedTime(null, fallback: 'x'), 'x');
    });

    test('invalid IANA name falls back to UTC', () {
      DateTimeUtils.setActiveTimezone('Not/AZone');
      final utc = DateTime.utc(2026, 1, 15, 20, 0);
      // Unknown zone → UTC → 08:00 PM.
      expect(DateTimeUtils.formatZonedTime(utc), '08:00 PM');
    });
  });

  group('formatZonedMeetingDate', () {
    test('happy path — date in user zone', () {
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      final utc = DateTime.utc(2026, 5, 19, 15, 0);
      expect(DateTimeUtils.formatZonedMeetingDate(utc), 'May 19,2026');
    });

    test('edge case — instant crosses date boundary backwards', () {
      // 2026-05-20 03:00Z → LA (UTC-7) → 2026-05-19 20:00 → date is May 19.
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      final utc = DateTime.utc(2026, 5, 20, 3, 0);
      expect(DateTimeUtils.formatZonedMeetingDate(utc), 'May 19,2026');
    });

    test('error case — null returns fallback', () {
      expect(
        DateTimeUtils.formatZonedMeetingDate(null, fallback: '--'),
        '--',
      );
    });
  });

  group('formatTimelineDateTime (ISO UTC string)', () {
    test('happy path — converts ISO UTC to user zone', () {
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      // 2026-05-19T20:00:00Z → LA 13:00 → "Tue, 19 May • 01:00 PM".
      final result =
          DateTimeUtils.formatTimelineDateTime('2026-05-19T20:00:00Z');
      expect(result, 'Tue, 19 May • 01:00 PM');
    });

    test('edge case — naive string treated as UTC', () {
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      final result =
          DateTimeUtils.formatTimelineDateTime('2026-05-19 20:00:00');
      expect(result, 'Tue, 19 May • 01:00 PM');
    });

    test('error case — empty string returns fallback', () {
      expect(
        DateTimeUtils.formatTimelineDateTime('', fallback: '--'),
        '--',
      );
    });
  });

  group('toUserZone', () {
    test('exposes wall-clock components in active zone', () {
      DateTimeUtils.setActiveTimezone('America/Los_Angeles');
      final zoned = DateTimeUtils.toUserZone(DateTime.utc(2026, 1, 15, 20, 0));
      expect(zoned.hour, 12);
      expect(zoned.day, 15);
    });
  });
}
