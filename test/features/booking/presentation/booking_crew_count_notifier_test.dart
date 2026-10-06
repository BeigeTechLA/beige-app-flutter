import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_crew_count_notifier.dart';
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
      container
          .read(bookingFlowControllerProvider.notifier)
          .setBookingId(bookingId);
    }
    return container;
  }

  const counts = RoleCounts(videographer: 1, photographer: 1);

  test('saves role_counts with exact keys incl zeroes (happy path)', () async {
    when(
      () => repo.updateBooking(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'data': {}}));

    final container = await makeContainer(bookingId: 5);
    final ok = await container
        .read(bookingCrewCountNotifierProvider.notifier)
        .submit(counts);

    expect(ok, isTrue);
    final flow = container.read(bookingFlowControllerProvider);
    expect(flow.roleCounts.videographer, 1);
    expect(flow.isStepComplete(BookingStep.crewCount), isTrue);
    final data = verify(
      () => repo.updateBooking(bookingId: 5, data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    final rc = data['role_counts'] as Map<String, dynamic>;
    expect(rc['videographer'], 1);
    expect(rc['photographer'], 1);
    expect(rc['cinematographer'], 0);
    expect(rc['photoVideoCreator'], 0);
  });

  test('rejects when booking id missing (edge case)', () async {
    final container = await makeContainer();
    final ok = await container
        .read(bookingCrewCountNotifierProvider.notifier)
        .submit(counts);
    expect(ok, isFalse);
    expect(
      container.read(bookingCrewCountNotifierProvider).status,
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
    ).thenAnswer((_) async => const Left(UnknownException(message: 'crew boom')));

    final container = await makeContainer(bookingId: 5);
    final ok = await container
        .read(bookingCrewCountNotifierProvider.notifier)
        .submit(counts);
    expect(ok, isFalse);
    expect(container.read(bookingCrewCountNotifierProvider).error, 'crew boom');
  });
}
