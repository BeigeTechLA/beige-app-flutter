import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_shoot_type_notifier.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_save_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockRepo extends Mock implements BookingRepository {}

void main() {
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
      container.read(bookingFlowControllerProvider.notifier).setBookingId(bookingId);
    }
    return container;
  }

  group('BookingShootTypeNotifier.submit', () {
    test('saves exact shoot-type name (happy path)', () async {
      when(
        () => repo.updateBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Right({'data': {}}));

      final container = await makeContainer(bookingId: 9);
      final ok = await container
          .read(bookingShootTypeNotifierProvider.notifier)
          .submit('Wedding');

      expect(ok, isTrue);
      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.shootTypeName, 'Wedding');
      expect(flow.isStepComplete(BookingStep.shootType), isTrue);
      final data = verify(
        () => repo.updateBooking(bookingId: 9, data: captureAny(named: 'data')),
      ).captured.single as Map<String, dynamic>;
      expect(data['shoot_type'], 'Wedding');
      expect(data.containsKey('shoot_type_id'), isFalse);
    });

    test('rejects when booking id missing without calling API (edge case)',
        () async {
      final container = await makeContainer();
      final ok = await container
          .read(bookingShootTypeNotifierProvider.notifier)
          .submit('Wedding');

      expect(ok, isFalse);
      expect(
        container.read(bookingShootTypeNotifierProvider).status,
        BookingSaveStatus.error,
      );
      verifyNever(
        () => repo.updateBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      );
    });

    test('surfaces failure (error case)', () async {
      when(
        () => repo.updateBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => const Left(UnknownException(message: 'nope')),
      );

      final container = await makeContainer(bookingId: 9);
      final ok = await container
          .read(bookingShootTypeNotifierProvider.notifier)
          .submit('Wedding');

      expect(ok, isFalse);
      expect(container.read(bookingShootTypeNotifierProvider).error, 'nope');
    });
  });
}
