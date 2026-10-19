import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/entities/booking_flow_enums.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/content_type_v2_notifier.dart';
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
  // Keep the autoDispose notifier alive across async calls.
  c.listen(contentTypeV2NotifierProvider, (_, _) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('happy path — submit creates booking and exposes booking_id + string', () async {
    final repo = MockBookingRepository();
    when(() => repo.createBooking(data: any(named: 'data'))).thenAnswer(
      (_) async => const Right({
        'data': {'booking_id': 1449},
      }),
    );
    final c = _container(repo);

    await c
        .read(contentTypeV2NotifierProvider.notifier)
        .submit(contentType: ContentTypeV2.both);

    final state = c.read(contentTypeV2NotifierProvider);
    expect(state.status, ContentTypeV2Status.success);
    expect(state.bookingId, 1449);
    expect(state.contentType, 'photographer,videographer');

    final captured = verify(
      () => repo.createBooking(data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['content_type'], 'photographer,videographer');
    expect(captured.containsKey('booking_id'), false);
  });

  test('edge case — existing booking id is forwarded in the body', () async {
    final repo = MockBookingRepository();
    when(() => repo.createBooking(data: any(named: 'data'))).thenAnswer(
      (_) async => const Right({
        'data': {'booking_id': 77},
      }),
    );
    final c = _container(repo);

    await c
        .read(contentTypeV2NotifierProvider.notifier)
        .submit(contentType: ContentTypeV2.photographer, existingBookingId: 77);

    final captured = verify(
      () => repo.createBooking(data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['booking_id'], 77);
    expect(captured['content_type'], 'photographer');
  });

  test('error case — repository failure surfaces error state', () async {
    final repo = MockBookingRepository();
    when(() => repo.createBooking(data: any(named: 'data'))).thenAnswer(
      (_) async => Left(UnknownException(message: 'boom')),
    );
    final c = _container(repo);

    await c
        .read(contentTypeV2NotifierProvider.notifier)
        .submit(contentType: ContentTypeV2.videographer);

    final state = c.read(contentTypeV2NotifierProvider);
    expect(state.status, ContentTypeV2Status.error);
    expect(state.errorMessage, 'boom');
    expect(state.bookingId, isNull);
  });
}
