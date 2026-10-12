import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/shoot_type_v2_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

ProviderContainer _container(BookingRepository repo) {
  final c = ProviderContainer(
    overrides: [bookingRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  c.listen(shootTypeV2NotifierProvider, (_, __) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  group('load', () {
    test('happy path — sorts catalogue by display_order', () async {
      final repo = MockBookingRepository();
      when(repo.getShootTypesV2).thenAnswer(
        (_) async => const Right([
          {'id': 2, 'name': 'Music Video', 'display_order': 2},
          {'id': 1, 'name': 'Wedding', 'display_order': 1},
        ]),
      );
      final c = _container(repo);

      await c.read(shootTypeV2NotifierProvider.notifier).load();

      final state = c.read(shootTypeV2NotifierProvider);
      expect(state.status, ShootTypeV2Status.success);
      expect(state.shootTypes.map((e) => e['name']), ['Wedding', 'Music Video']);
    });

    test('error case — failure surfaces error state', () async {
      final repo = MockBookingRepository();
      when(repo.getShootTypesV2)
          .thenAnswer((_) async => Left(UnknownException(message: 'nope')));
      final c = _container(repo);

      await c.read(shootTypeV2NotifierProvider.notifier).load();

      final state = c.read(shootTypeV2NotifierProvider);
      expect(state.status, ShootTypeV2Status.error);
      expect(state.errorMessage, 'nope');
    });
  });

  group('selectShootType', () {
    test('happy path — sends shoot_type by NAME and returns true', () async {
      final repo = MockBookingRepository();
      when(
        () => repo.updateBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Right({'data': {}}));
      final c = _container(repo);

      final ok = await c
          .read(shootTypeV2NotifierProvider.notifier)
          .selectShootType(bookingId: 10, shootTypeName: 'Wedding');

      expect(ok, true);
      final captured = verify(
        () => repo.updateBooking(
          bookingId: 10,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured, {'shoot_type': 'Wedding'});
      expect(captured.containsKey('shoot_type_id'), false);
    });

    test('error case — failure returns false and sets message', () async {
      final repo = MockBookingRepository();
      when(
        () => repo.updateBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => Left(UnknownException(message: 'save failed')));
      final c = _container(repo);

      final ok = await c
          .read(shootTypeV2NotifierProvider.notifier)
          .selectShootType(bookingId: 10, shootTypeName: 'Wedding');

      expect(ok, false);
      expect(c.read(shootTypeV2NotifierProvider).errorMessage, 'save failed');
    });
  });
}
