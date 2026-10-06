import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/creator_assignment.dart';
import 'package:beige/features/booking/domain/entities/creator_match.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_creator_matches_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/booking_creator_selection_screen.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late _MockBookingRepository repo;

  setUp(() {
    repo = _MockBookingRepository();
  });

  const match1 = CreatorMatch(
    crewMemberId: 101,
    name: 'Alice Photographer',
    supportsPhotographer: true,
    supportsVideographer: false,
  );

  const match2 = CreatorMatch(
    crewMemberId: 102,
    name: 'Bob Videographer',
    supportsPhotographer: false,
    supportsVideographer: true,
  );

  const matchDual = CreatorMatch(
    crewMemberId: 103,
    name: 'Charlie Dual',
    supportsPhotographer: true,
    supportsVideographer: true,
  );

  group('BookingCreatorMatchesNotifier', () {
    test('loads first page and appends deduplicated results on loadMore', () async {
      when(
        () => repo.getCreatorMatches(
          bookingId: 42,
          page: 1,
          limit: 12,
        ),
      ).thenAnswer(
        (_) async => const Right(
          CreatorMatchPage(
            matches: [match1, match2],
            page: 1,
            hasMore: true,
          ),
        ),
      );

      when(
        () => repo.getCreatorMatches(
          bookingId: 42,
          page: 2,
          limit: 12,
        ),
      ).thenAnswer(
        (_) async => const Right(
          CreatorMatchPage(
            matches: [match2, matchDual], // match2 is duplicate
            page: 2,
            hasMore: false,
          ),
        ),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      final notifier = container.read(
        bookingCreatorMatchesNotifierProvider.notifier,
      );

      // Await first page
      await notifier.loadMore();

      var state = container.read(bookingCreatorMatchesNotifierProvider);
      expect(state.matches.length, 2);
      expect(state.hasMore, isTrue);

      // Load second page
      await notifier.loadMore();

      state = container.read(bookingCreatorMatchesNotifierProvider);
      // match2 deduplicated; match1, match2, matchDual total = 3
      expect(state.matches.length, 3);
      expect(state.hasMore, isFalse);
    });

    test('handles failure gracefully and surfaces error', () async {
      when(
        () => repo.getCreatorMatches(
          bookingId: 42,
          page: 1,
          limit: 12,
        ),
      ).thenAnswer(
        (_) async => const Left(UnknownException(message: 'Failed to fetch matches')),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      final notifier = container.read(
        bookingCreatorMatchesNotifierProvider.notifier,
      );
      await notifier.loadMore();

      final state = container.read(bookingCreatorMatchesNotifierProvider);
      expect(state.error, 'Failed to fetch matches');
      expect(state.matches, isEmpty);
    });
  });

  group('BookingCreatorSelectionScreen Widget Tests', () {
    testWidgets('renders role counters, adds creator, and toggles Let Beige Choose', (
      tester,
    ) async {
      when(
        () => repo.getCreatorMatches(
          bookingId: any(named: 'bookingId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          CreatorMatchPage(
            matches: [match1, match2],
            page: 1,
            hasMore: false,
          ),
        ),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(bookingFlowControllerProvider.notifier);
      controller.setBookingId(42);
      controller.setMatchingBranch(BookingMatchingBranch.choosePartner);
      controller.setRoleCounts(
        const RoleCounts(photographer: 1, videographer: 1),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BookingCreatorSelectionScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify header & role counters bar
      expect(find.text('Photographer 0/1'), findsOneWidget);
      expect(find.text('Videographer 0/1'), findsOneWidget);
      expect(find.text('Alice Photographer'), findsOneWidget);
      expect(find.text('Bob Videographer'), findsOneWidget);

      // Initially, continue button is disabled because 0 of 2 creatives selected
      final continueButton = tester.widget<BookingPrimaryButton>(
        find.byType(BookingPrimaryButton),
      );
      expect(continueButton.enabled, isFalse);

      // Tap + Add on Alice Photographer
      final addButtons = find.text('+ Add');
      expect(addButtons, findsNWidgets(2));
      await tester.tap(addButtons.first);
      await tester.pump();

      // Alice should now be assigned as Photographer
      expect(find.text('Photographer 1/1'), findsOneWidget);
      expect(find.text('Added as Photographer'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);

      // Still need 1 videographer, continue should still be disabled
      final continueButtonAfter1 = tester.widget<BookingPrimaryButton>(
        find.byType(BookingPrimaryButton),
      );
      expect(continueButtonAfter1.enabled, isFalse);

      // Tap "Let Beige choose remaining creatives" banner
      await tester.tap(find.text('Let Beige choose remaining creatives'));
      await tester.pump();

      // Now continue should be enabled!
      final continueButtonAfterCheck = tester.widget<BookingPrimaryButton>(
        find.byType(BookingPrimaryButton),
      );
      expect(continueButtonAfterCheck.enabled, isTrue);
      expect(
        find.text('Continue with Beige Match (1 selected)'),
        findsOneWidget,
      );
    });
  });
}
