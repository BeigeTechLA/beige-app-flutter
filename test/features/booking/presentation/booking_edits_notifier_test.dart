import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/edit_selection.dart';
import 'package:beige/features/booking/domain/entities/edit_type_option.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_edits_notifier.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_save_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockRepo extends Mock implements BookingRepository {}

void main() {
  late _MockRepo repo;

  setUpAll(() {
    registerFallbackValue(const EditSelection());
  });
  setUp(() => repo = _MockRepo());

  Future<ProviderContainer> makeContainer({
    int? bookingId,
    BookingMatchingBranch? branch,
    BookingContentType? contentType,
  }) async {
    final prefs = await createMockPrefs();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        bookingRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final ctrl = container.read(bookingFlowControllerProvider.notifier);
    if (bookingId != null) ctrl.setBookingId(bookingId);
    if (contentType != null) ctrl.setContentType(contentType);
    if (branch != null) ctrl.setMatchingBranch(branch);
    return container;
  }

  const selection = EditSelection(
    editsNeeded: true,
    photoEditTypes: ['edited_photos'],
    videoEditTypes: ['highlight_video_4_7'],
  );

  group('BookingEditsNotifier.submit', () {
    test('saves edits and routes manual branch to creator selection', () async {
      when(
        () => repo.saveEdits(
          bookingId: any(named: 'bookingId'),
          selection: any(named: 'selection'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final container = await makeContainer(
        bookingId: 5,
        branch: BookingMatchingBranch.choosePartner,
      );
      final ok = await container
          .read(bookingEditsNotifierProvider.notifier)
          .submit(selection);

      expect(ok, isTrue);
      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.editSelection.editsNeeded, isTrue);
      expect(flow.isStepComplete(BookingStep.edits), isTrue);
      expect(flow.currentStep, BookingStep.creatorSelection);
    });

    test('automatic branch routes to add-ons', () async {
      when(
        () => repo.saveEdits(
          bookingId: any(named: 'bookingId'),
          selection: any(named: 'selection'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final container = await makeContainer(
        bookingId: 5,
        branch: BookingMatchingBranch.letBeigeMatch,
      );
      await container
          .read(bookingEditsNotifierProvider.notifier)
          .submit(const EditSelection());

      expect(
        container.read(bookingFlowControllerProvider).currentStep,
        BookingStep.addons,
      );
    });

    test('rejects without booking id (edge case)', () async {
      final container = await makeContainer();
      final ok = await container
          .read(bookingEditsNotifierProvider.notifier)
          .submit(const EditSelection());
      expect(ok, isFalse);
      expect(
        container.read(bookingEditsNotifierProvider).status,
        BookingSaveStatus.error,
      );
      verifyNever(
        () => repo.saveEdits(
          bookingId: any(named: 'bookingId'),
          selection: any(named: 'selection'),
        ),
      );
    });

    test('surfaces failure (error case)', () async {
      when(
        () => repo.saveEdits(
          bookingId: any(named: 'bookingId'),
          selection: any(named: 'selection'),
        ),
      ).thenAnswer(
        (_) async => const Left(UnknownException(message: 'edit boom')),
      );
      final container = await makeContainer(bookingId: 5);
      final ok = await container
          .read(bookingEditsNotifierProvider.notifier)
          .submit(selection);
      expect(ok, isFalse);
      expect(container.read(bookingEditsNotifierProvider).error, 'edit boom');
    });
  });

  group('editTypesCatalogueProvider', () {
    test('loads catalogue for the flow content type (happy path)', () async {
      when(
        () => repo.getEditTypesCatalogue(
          contentType: BookingContentType.videographer,
        ),
      ).thenAnswer(
        (_) async => const Right(
          EditTypesCatalogue(
            videoEditTypes: [
              EditTypeOption(key: 'highlight_video_4_7', label: 'Highlight'),
            ],
          ),
        ),
      );

      final container = await makeContainer(
        contentType: BookingContentType.videographer,
      );
      final cat = await container.read(editTypesCatalogueProvider.future);
      expect(cat.videoEditTypes.single.key, 'highlight_video_4_7');
    });

    test('throws when content type unset (error case)', () async {
      final container = await makeContainer();
      expect(
        () => container.read(editTypesCatalogueProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });
}
