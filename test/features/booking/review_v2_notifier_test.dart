import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/review_v2_notifier.dart';
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
  c.listen(reviewV2NotifierProvider, (_, _) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('happy path — loadReview stores server payload', () async {
    final repo = MockBookingRepository();
    when(() => repo.getReview(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => const Right({
        'pricing_summary': {'final_amount': 4004},
      }),
    );
    final c = _container(repo);

    await c
        .read(reviewV2NotifierProvider.notifier)
        .loadReview(bookingId: 5, addOnItems: const []);

    final state = c.read(reviewV2NotifierProvider);
    expect(state.status, ReviewV2Status.loaded);
    expect(state.review?['pricing_summary'], {'final_amount': 4004});
  });

  test('happy path — quoteAndSubmit sends submit contract fields', () async {
    final repo = MockBookingRepository();
    when(() => repo.saveQuote(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => const Right({'ok': true}));
    when(() => repo.submitBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    final ok = await c.read(reviewV2NotifierProvider.notifier).quoteAndSubmit(
          bookingId: 5,
          fullName: 'Jane',
          email: 'j@x.com',
          phone: '123',
          matchingMethod: 'ai_matchmaker',
          selectedCrewIds: [11, 22],
          addOnItems: const [
            {'slug': 'drone', 'quantity': 1}
          ],
        );

    expect(ok, true);
    final captured = verify(
      () => repo.submitBooking(bookingId: 5, data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['full_name'], 'Jane');
    expect(captured['matching_method'], 'ai_matchmaker');
    expect(captured['selected_crew_ids'], [11, 22]);
  });

  test('beigeMatch — submit sends empty selected_crew_ids', () async {
    final repo = MockBookingRepository();
    when(() => repo.saveQuote(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => const Right({'ok': true}));
    when(() => repo.submitBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    await c.read(reviewV2NotifierProvider.notifier).quoteAndSubmit(
          bookingId: 5,
          fullName: 'Jane',
          email: 'j@x.com',
          phone: '123',
          matchingMethod: 'ai_matchmaker',
          selectedCrewIds: const [],
          addOnItems: const [],
        );

    final captured = verify(
      () => repo.submitBooking(bookingId: 5, data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['selected_crew_ids'], const <int>[]);
    expect(captured['matching_method'], 'ai_matchmaker');
  });

  test('error case — quote failure short-circuits before submit', () async {
    final repo = MockBookingRepository();
    when(() => repo.saveQuote(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer(
      (_) async => Left(UnknownException(message: 'quote failed')),
    );
    final c = _container(repo);

    final ok = await c.read(reviewV2NotifierProvider.notifier).quoteAndSubmit(
          bookingId: 5,
          fullName: 'Jane',
          email: 'j@x.com',
          phone: '123',
          matchingMethod: 'ai_matchmaker',
          selectedCrewIds: const [],
          addOnItems: const [],
        );

    expect(ok, false);
    expect(c.read(reviewV2NotifierProvider).errorMessage, 'quote failed');
    verifyNever(() => repo.submitBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ));
  });

  test('edge case — invalid paymentsheet response yields null checkout', () async {
    final repo = MockBookingRepository();
    when(() => repo.openPaymentSheet(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => const Right({'data': {}}));
    final c = _container(repo);

    final checkout = await c
        .read(reviewV2NotifierProvider.notifier)
        .openCommasCheckout(bookingId: 5);

    expect(checkout, isNull);
  });

  test('isPaid — reads nested payment status', () async {
    final repo = MockBookingRepository();
    when(() => repo.getSummaryDetails(bookingId: any(named: 'bookingId')))
        .thenAnswer(
      (_) async => const Right({
        'payment': {'status': 'Paid'},
      }),
    );
    final c = _container(repo);

    final paid =
        await c.read(reviewV2NotifierProvider.notifier).isPaid(bookingId: 5);
    expect(paid, true);
  });
}
