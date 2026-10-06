import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_content_notifier.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_save_state.dart';
import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockRepo extends Mock implements BookingRepository {}

void main() {
  late _MockRepo repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    repo = _MockRepo();
  });

  Future<ProviderContainer> makeContainer() async {
    final prefs = await createMockPrefs();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bookingRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('BookingContentNotifier.submit', () {
    test('creates booking and stores booking_id (happy path)', () async {
      when(() => repo.createBooking(data: any(named: 'data'))).thenAnswer(
        (_) async => const Right({
          'data': {'booking_id': 42},
        }),
      );

      final container = await makeContainer();
      final ok = await container
          .read(bookingContentNotifierProvider.notifier)
          .submit(BookingContentType.photographerVideographer);

      expect(ok, isTrue);
      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.bookingId, 42);
      expect(flow.contentType, BookingContentType.photographerVideographer);
      expect(flow.isStepComplete(BookingStep.contentType), isTrue);
      final captured = verify(
        () => repo.createBooking(data: captureAny(named: 'data')),
      ).captured.single as Map<String, dynamic>;
      expect(captured['content_type'], 'photographer,videographer');
    });

    test('updates (not creates) when booking already exists (edge case)',
        () async {
      when(
        () => repo.updateBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Right({'data': {}}));

      final container = await makeContainer();
      container
          .read(bookingFlowControllerProvider.notifier)
          .setBookingId(7);

      final ok = await container
          .read(bookingContentNotifierProvider.notifier)
          .submit(BookingContentType.photographer);

      expect(ok, isTrue);
      expect(container.read(bookingFlowControllerProvider).bookingId, 7);
      verifyNever(() => repo.createBooking(data: any(named: 'data')));
      verify(
        () => repo.updateBooking(bookingId: 7, data: any(named: 'data')),
      ).called(1);
    });

    test('surfaces failure and keeps idle state (error case)', () async {
      when(() => repo.createBooking(data: any(named: 'data'))).thenAnswer(
        (_) async => const Left(UnknownException(message: 'boom')),
      );

      final container = await makeContainer();
      final ok = await container
          .read(bookingContentNotifierProvider.notifier)
          .submit(BookingContentType.videographer);

      expect(ok, isFalse);
      final state = container.read(bookingContentNotifierProvider);
      expect(state.status, BookingSaveStatus.error);
      expect(state.error, 'boom');
      expect(container.read(bookingFlowControllerProvider).bookingId, isNull);
    });
  });
}
