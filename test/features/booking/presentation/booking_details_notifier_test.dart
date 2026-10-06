import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_details_notifier.dart';
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

  group('BookingDetailsNotifier.submit', () {
    test('saves notes + links and advances step (happy path)', () async {
      when(
        () => repo.updateBookingDetails(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Right({'data': {}}));

      final container = await makeContainer(bookingId: 5);
      final ok = await container
          .read(bookingDetailsNotifierProvider.notifier)
          .submit(
            additionalDetails: 'Outdoor shoot',
            referenceLinks: const ['https://example.com/moodboard'],
          );

      expect(ok, isTrue);
      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.additionalDetails, 'Outdoor shoot');
      expect(flow.referenceLinks, ['https://example.com/moodboard']);
      expect(flow.isStepComplete(BookingStep.details), isTrue);
      final data = verify(
        () => repo.updateBookingDetails(
          bookingId: 5,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(data['additional_details'], 'Outdoor shoot');
      expect(data['reference_links'], ['https://example.com/moodboard']);
    });

    test('empty links send [] (edge case)', () async {
      when(
        () => repo.updateBookingDetails(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => const Right({'data': {}}));

      final container = await makeContainer(bookingId: 5);
      await container
          .read(bookingDetailsNotifierProvider.notifier)
          .submit(additionalDetails: 'notes', referenceLinks: const []);

      final data = verify(
        () => repo.updateBookingDetails(
          bookingId: 5,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(data['reference_links'], isEmpty);
    });

    test('surfaces failure, no booking id guard (error case)', () async {
      final container = await makeContainer();
      final ok = await container
          .read(bookingDetailsNotifierProvider.notifier)
          .submit(additionalDetails: 'x', referenceLinks: const []);
      expect(ok, isFalse);
      expect(
        container.read(bookingDetailsNotifierProvider).status,
        BookingSaveStatus.error,
      );
      verifyNever(
        () => repo.updateBookingDetails(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      );
    });
  });
}
