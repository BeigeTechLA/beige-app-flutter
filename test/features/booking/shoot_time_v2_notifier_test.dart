import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/shoot_time_v2_notifier.dart';
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
  c.listen(shootTimeV2NotifierProvider, (_, __) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('happy path — forwards payload and returns true on success', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateBookingTime(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'data': {}}));
    final c = _container(repo);

    final ok = await c.read(shootTimeV2NotifierProvider.notifier).save(
      bookingId: 5,
      payload: const {'booking_type': 'single_day'},
    );

    expect(ok, true);
    expect(c.read(shootTimeV2NotifierProvider).status, ShootTimeV2Status.success);
    verify(
      () => repo.updateBookingTime(
        bookingId: 5,
        data: const {'booking_type': 'single_day'},
      ),
    ).called(1);
  });

  test('error case — returns false and surfaces message', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateBookingTime(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => Left(UnknownException(message: 'time failed')));
    final c = _container(repo);

    final ok = await c
        .read(shootTimeV2NotifierProvider.notifier)
        .save(bookingId: 5, payload: const {});

    expect(ok, false);
    final state = c.read(shootTimeV2NotifierProvider);
    expect(state.status, ShootTimeV2Status.error);
    expect(state.errorMessage, 'time failed');
  });
}
