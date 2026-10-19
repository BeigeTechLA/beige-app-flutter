import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/creative_team_notifier.dart';
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
  c.listen(creativeTeamNotifierProvider, (_, _) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('happy path — wraps role_counts and returns true', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateCrew(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    final ok = await c.read(creativeTeamNotifierProvider.notifier).save(
          bookingId: 5,
          roleCounts: {'photographer': 2, 'videographer': 0, 'photoVideoCreator': 1},
        );

    expect(ok, true);
    expect(
      c.read(creativeTeamNotifierProvider).status,
      CreativeTeamStatus.success,
    );
    final captured = verify(
      () => repo.updateCrew(bookingId: 5, data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    expect(captured['role_counts'], {
      'photographer': 2,
      'videographer': 0,
      'photoVideoCreator': 1,
    });
  });

  test('edge case — zero-filled unselected roles are still sent', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateCrew(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    await c.read(creativeTeamNotifierProvider.notifier).save(
          bookingId: 5,
          roleCounts: {'photographer': 1, 'videographer': 0, 'photoVideoCreator': 0},
        );

    final captured = verify(
      () => repo.updateCrew(bookingId: 5, data: captureAny(named: 'data')),
    ).captured.single as Map<String, dynamic>;
    final counts = captured['role_counts'] as Map<String, dynamic>;
    expect(counts['videographer'], 0);
    expect(counts['photoVideoCreator'], 0);
  });

  test('error case — returns false and surfaces message', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateCrew(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => Left(UnknownException(message: 'crew failed')));
    final c = _container(repo);

    final ok = await c.read(creativeTeamNotifierProvider.notifier).save(
          bookingId: 5,
          roleCounts: {'photographer': 1},
        );

    expect(ok, false);
    final state = c.read(creativeTeamNotifierProvider);
    expect(state.status, CreativeTeamStatus.error);
    expect(state.errorMessage, 'crew failed');
  });
}
