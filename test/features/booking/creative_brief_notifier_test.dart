import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/creative_brief_notifier.dart';
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
  c.listen(creativeBriefNotifierProvider, (_, __) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('happy path — saves details + links and returns true', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateBookingDetails(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    final ok = await c.read(creativeBriefNotifierProvider.notifier).save(
          bookingId: 10,
          additionalDetails: 'Golden hour vibe',
          referenceLinks: ['https://a.com', 'https://b.com'],
        );

    expect(ok, true);
    expect(
      c.read(creativeBriefNotifierProvider).status,
      CreativeBriefStatus.success,
    );
    final captured = verify(
      () => repo.updateBookingDetails(
        bookingId: 10,
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured['additional_details'], 'Golden hour vibe');
    expect(captured['reference_links'], ['https://a.com', 'https://b.com']);
  });

  test('edge case — empty brief still sends empty values', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateBookingDetails(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    final ok = await c.read(creativeBriefNotifierProvider.notifier).save(
          bookingId: 10,
          additionalDetails: '',
          referenceLinks: const [],
        );

    expect(ok, true);
    final captured = verify(
      () => repo.updateBookingDetails(
        bookingId: 10,
        data: captureAny(named: 'data'),
      ),
    ).captured.single as Map<String, dynamic>;
    expect(captured['additional_details'], '');
    expect(captured['reference_links'], const []);
  });

  test('error case — returns false and surfaces message', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateBookingDetails(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => Left(UnknownException(message: 'save failed')));
    final c = _container(repo);

    final ok = await c.read(creativeBriefNotifierProvider.notifier).save(
          bookingId: 10,
          additionalDetails: 'x',
          referenceLinks: const [],
        );

    expect(ok, false);
    final state = c.read(creativeBriefNotifierProvider);
    expect(state.status, CreativeBriefStatus.error);
    expect(state.errorMessage, 'save failed');
  });
}
