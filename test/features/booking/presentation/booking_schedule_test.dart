import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/schedule_input.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_save_state.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_schedule_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockRepo extends Mock implements BookingRepository {}

void main() {
  group('ScheduleInput.toTimePayload', () {
    test('scheduled mode sends date/time/location (PDF p.4)', () {
      const input = ScheduleInput(
        mode: BookingScheduleMode.scheduled,
        eventDate: '2026-10-08',
        startTime: '09:00',
        endTime: '17:00',
        timeZone: 'Asia/Calcutta',
        eventLocation: '550 West 5th Street',
        eventLatitude: 34.05,
        eventLongitude: -118.25,
      );
      final payload = input.toTimePayload();
      expect(payload['event_date'], '2026-10-08');
      expect(payload['start_time'], '09:00');
      expect(payload['end_time'], '17:00');
      expect(payload['time_zone'], 'Asia/Calcutta');
      expect(payload['event_location'], '550 West 5th Street');
      expect(payload.containsKey('confirm_later'), isFalse);
    });

    test('deferred mode omits date/time, sets confirm_later (PDF p.5)', () {
      const input = ScheduleInput(
        mode: BookingScheduleMode.deferred,
        timeZone: 'Asia/Calcutta',
        eventLocation: '550 West 5th Street',
        eventLatitude: 34.05,
        eventLongitude: -118.25,
      );
      final payload = input.toTimePayload();
      expect(payload['confirm_later'], true);
      expect(payload['booking_type'], 'single_day');
      expect(payload['booking_days'], isEmpty);
      expect(payload.containsKey('event_date'), isFalse);
      expect(payload.containsKey('start_time'), isFalse);
      expect(payload.containsKey('end_time'), isFalse);
    });

    test('switching scheduled->deferred drops stale date/time (edge case)', () {
      const scheduled = ScheduleInput(
        mode: BookingScheduleMode.scheduled,
        eventDate: '2026-10-08',
        startTime: '09:00',
        endTime: '17:00',
        timeZone: 'Asia/Calcutta',
        eventLocation: 'X',
      );
      // Rebuild as deferred from the same fields: payload must not carry dates.
      final deferred = scheduled.copyWith(mode: BookingScheduleMode.deferred);
      final payload = deferred.toTimePayload();
      expect(payload.containsKey('event_date'), isFalse);
      expect(payload['confirm_later'], true);
    });

    test('isValid: scheduled needs all fields, deferred needs location', () {
      const scheduledIncomplete = ScheduleInput(
        mode: BookingScheduleMode.scheduled,
        eventLocation: 'X',
      );
      expect(scheduledIncomplete.isValid, isFalse);
      const deferredOk = ScheduleInput(
        mode: BookingScheduleMode.deferred,
        eventLocation: 'X',
      );
      expect(deferredOk.isValid, isTrue);
    });
  });

  group('BookingScheduleNotifier.submit', () {
    late _MockRepo repo;
    setUpAll(() => registerFallbackValue(<String, dynamic>{}));
    setUp(() => repo = _MockRepo());

    Future<ProviderContainer> makeContainer({int? bookingId}) async {
      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      if (bookingId != null) {
        container
            .read(bookingFlowControllerProvider.notifier)
            .setBookingId(bookingId);
      }
      return container;
    }

    const deferred = ScheduleInput(
      mode: BookingScheduleMode.deferred,
      timeZone: 'UTC',
      eventLocation: 'X',
    );

    test('saves schedule and advances step (happy path)', () async {
      when(
        () => repo.updateBookingTime(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Right({'data': {}}));

      final container = await makeContainer(bookingId: 5);
      final ok = await container
          .read(bookingScheduleNotifierProvider.notifier)
          .submit(deferred);

      expect(ok, isTrue);
      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.schedule?.isDeferred, isTrue);
      expect(flow.isStepComplete(BookingStep.schedule), isTrue);
      final data = verify(
        () => repo.updateBookingTime(
          bookingId: 5,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(data['confirm_later'], true);
    });

    test('rejects without booking id (edge case)', () async {
      final container = await makeContainer();
      final ok = await container
          .read(bookingScheduleNotifierProvider.notifier)
          .submit(deferred);
      expect(ok, isFalse);
      expect(
        container.read(bookingScheduleNotifierProvider).status,
        BookingSaveStatus.error,
      );
      verifyNever(
        () => repo.updateBookingTime(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      );
    });

    test('surfaces failure (error case)', () async {
      when(
        () => repo.updateBookingTime(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => const Left(UnknownException(message: 'time boom')),
      );
      final container = await makeContainer(bookingId: 5);
      final ok = await container
          .read(bookingScheduleNotifierProvider.notifier)
          .submit(deferred);
      expect(ok, isFalse);
      expect(container.read(bookingScheduleNotifierProvider).error, 'time boom');
    });
  });
}
