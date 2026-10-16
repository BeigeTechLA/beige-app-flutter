import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/add_ons_notifier.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
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
  c.listen(addOnsNotifierProvider, (_, __) {});
  return c;
}

void main() {
  test('happy path — parses catalogue with mixed numeric/string rates', () async {
    final repo = MockBookingRepository();
    when(repo.getAddons).thenAnswer(
      (_) async => const Right([
        {
          'slug': 'extra_camera',
          'title': 'Additional Camera',
          'description': 'A second angle',
          'rate': 350,
          'min_quantity': 1,
          'max_quantity': 3,
        },
        {'slug': 'drone', 'name': 'Drone', 'price': '500'},
      ]),
    );
    final c = _container(repo);

    await c.read(addOnsNotifierProvider.notifier).load();

    final state = c.read(addOnsNotifierProvider);
    expect(state.status, AddOnsStatus.loaded);
    expect(state.catalogue.length, 2);
    expect(state.catalogue.first.slug, 'extra_camera');
    expect(state.catalogue.first.rate, 350);
    expect(state.catalogue.first.maxQuantity, 3);
    expect(state.catalogue[1].title, 'Drone');
    expect(state.catalogue[1].rate, 500);
  });

  test('edge case — empty catalogue loads cleanly', () async {
    final repo = MockBookingRepository();
    when(repo.getAddons).thenAnswer((_) async => const Right([]));
    final c = _container(repo);

    await c.read(addOnsNotifierProvider.notifier).load();

    final state = c.read(addOnsNotifierProvider);
    expect(state.status, AddOnsStatus.loaded);
    expect(state.catalogue, isEmpty);
  });

  test('error case — surfaces message', () async {
    final repo = MockBookingRepository();
    when(repo.getAddons)
        .thenAnswer((_) async => Left(UnknownException(message: 'addons down')));
    final c = _container(repo);

    await c.read(addOnsNotifierProvider.notifier).load();

    final state = c.read(addOnsNotifierProvider);
    expect(state.status, AddOnsStatus.error);
    expect(state.errorMessage, 'addons down');
  });
}
