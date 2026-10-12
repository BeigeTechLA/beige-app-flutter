import 'package:beige/features/booking/domain/entities/shoot_time_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('datedSingle', () {
    test('happy path — includes date/time + location, no edits', () {
      final p = ShootTimePayload.datedSingle(
        eventDate: '2026-01-12',
        startTime: '10:30',
        endTime: '16:30',
        timeZone: 'America/Los_Angeles',
        location: '550 West 5th Street, Los Angeles',
        latitude: 34.05,
        longitude: -118.25,
      );
      expect(p['booking_type'], 'single_day');
      expect(p['event_date'], '2026-01-12');
      expect(p['start_time'], '10:30');
      expect(p['end_time'], '16:30');
      expect(p['time_zone'], 'America/Los_Angeles');
      expect(p['event_location'], '550 West 5th Street, Los Angeles');
      expect(p['event_latitude'], 34.05);
      expect(p['event_longitude'], -118.25);
      // edits are no longer part of the time payload in v2
      expect(p.containsKey('edits_needed'), false);
      expect(p.containsKey('booking_days'), false);
    });
  });

  group('datedMulti', () {
    test('happy path — carries booking_days + location', () {
      final days = [
        ShootTimePayload.day(date: '2026-01-02', startTime: '10:00', endTime: '18:00'),
        ShootTimePayload.day(date: '2026-01-03', startTime: '09:00', endTime: '17:00'),
      ];
      final p = ShootTimePayload.datedMulti(
        bookingDays: days,
        timeZone: 'UTC',
        location: 'Woodland Hills, CA',
        latitude: 1,
        longitude: 2,
      );
      expect(p['booking_type'], 'multi_day');
      expect((p['booking_days'] as List).length, 2);
      expect((p['booking_days'] as List).first['start_time'], '10:00');
      expect(p['event_location'], 'Woodland Hills, CA');
    });

    test('edge case — empty booking_days still well-formed', () {
      final p = ShootTimePayload.datedMulti(
        bookingDays: const [],
        timeZone: 'UTC',
        location: 'x',
        latitude: 0,
        longitude: 0,
      );
      expect(p['booking_days'], isEmpty);
      expect(p['booking_type'], 'multi_day');
    });
  });

  group('deferred', () {
    test('confirm_later with empty days and no date/time', () {
      final p = ShootTimePayload.deferred(
        timeZone: 'Asia/Calcutta',
        location: 'LA',
        latitude: 1,
        longitude: 2,
      );
      expect(p['confirm_later'], true);
      expect(p['booking_days'], isEmpty);
      expect(p.containsKey('event_date'), false);
      expect(p.containsKey('start_time'), false);
      expect(p['event_location'], 'LA');
    });
  });
}
