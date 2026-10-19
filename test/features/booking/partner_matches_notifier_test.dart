import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/partner_matches_notifier.dart';
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
  c.listen(partnerMatchesNotifierProvider, (_, _) {});
  return c;
}

void main() {
  group('requiredFromRoleCounts', () {
    test('happy path — keeps dedicated counts', () {
      expect(
        PartnerMatchesNotifier.requiredFromRoleCounts(
          {'photographer': 2, 'videographer': 1, 'photoVideoCreator': 0},
        ),
        {'photographer': 2, 'videographer': 1},
      );
    });

    test('edge case — hybrid-only folds into both roles', () {
      expect(
        PartnerMatchesNotifier.requiredFromRoleCounts(
          {'photographer': 0, 'videographer': 0, 'photoVideoCreator': 2},
        ),
        {'photographer': 2, 'videographer': 2},
      );
    });
  });

  test('happy path — loads matches, derives capabilities, add fills a slot',
      () async {
    final repo = MockBookingRepository();
    when(() => repo.getCrewMatches(
          bookingId: any(named: 'bookingId'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        )).thenAnswer(
      (_) async => const Right({
        'items': [
          {'crew_member_id': 11, 'name': 'A', 'role_name': 'Photographer Specialist'},
          {'crew_member_id': 22, 'name': 'B', 'role_name': 'Videography Specialist'},
        ],
      }),
    );
    final c = _container(repo);
    final notifier = c.read(partnerMatchesNotifierProvider.notifier);

    await notifier.load(bookingId: 5, roleCounts: {'photographer': 1, 'videographer': 1});

    var state = c.read(partnerMatchesNotifierProvider);
    expect(state.status, PartnerMatchesStatus.loaded);
    expect(state.matches.length, 2);
    expect(state.matches.first.capabilities, {'photographer'});

    notifier.add(state.matches.first);
    state = c.read(partnerMatchesNotifierProvider);
    expect(state.assignment.selectedCrewIds, [11]);
    expect(state.assignment.selectedCount('photographer'), 1);

    notifier.remove(11);
    expect(c.read(partnerMatchesNotifierProvider).assignment.selectedCrewIds, isEmpty);
  });

  test('edge case — empty items falls back to random_creators + noNearby flag',
      () async {
    final repo = MockBookingRepository();
    when(() => repo.getCrewMatches(
          bookingId: any(named: 'bookingId'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        )).thenAnswer(
      (_) async => const Right({
        'items': [],
        'random_creators': [
          {'crew_member_id': 99, 'name': 'C', 'role_name': 'Photographer'},
        ],
      }),
    );
    final c = _container(repo);

    await c
        .read(partnerMatchesNotifierProvider.notifier)
        .load(bookingId: 5, roleCounts: {'photographer': 1});

    final state = c.read(partnerMatchesNotifierProvider);
    expect(state.status, PartnerMatchesStatus.loaded);
    expect(state.noNearby, isTrue);
    expect(state.matches.single.id, 99);
  });

  test('error case — surfaces message', () async {
    final repo = MockBookingRepository();
    when(() => repo.getCrewMatches(
          bookingId: any(named: 'bookingId'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        )).thenAnswer(
      (_) async => Left(UnknownException(message: 'matches failed')),
    );
    final c = _container(repo);

    await c
        .read(partnerMatchesNotifierProvider.notifier)
        .load(bookingId: 5, roleCounts: {'photographer': 1});

    final state = c.read(partnerMatchesNotifierProvider);
    expect(state.status, PartnerMatchesStatus.error);
    expect(state.errorMessage, 'matches failed');
  });
}
