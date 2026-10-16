import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/editing_notifier.dart';
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
  c.listen(editingNotifierProvider, (_, __) {});
  return c;
}

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  test('happy path — load parses photo + video edit options', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.getBookingTime(bookingId: any(named: 'bookingId')),
    ).thenAnswer((_) async => const Right({'duration_hours': 1}));
    when(
      () => repo.getEditTypesV2(contentType: any(named: 'contentType')),
    ).thenAnswer(
      (_) async => const Right({
        'photo_edit_types': [
          {'key': 'retouch', 'value': 'Retouching', 'note': '+25 per set'},
        ],
        'video_edit_types': [
          {'key': 'color', 'value': 'Color Grading'},
        ],
      }),
    );
    final c = _container(repo);

    await c
        .read(editingNotifierProvider.notifier)
        .load(bookingId: 7, contentType: 'photographer,videographer');

    final state = c.read(editingNotifierProvider);
    expect(state.status, EditingStatus.loaded);
    expect(state.photoEditTypes.single.key, 'retouch');
    expect(state.photoEditTypes.single.note, '+25 per set');
    expect(state.videoEditTypes.single.value, 'Color Grading');
  });

  test('duration — top-level duration_hours drives included count', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.getBookingTime(bookingId: any(named: 'bookingId')),
    ).thenAnswer((_) async => const Right({'duration_hours': 1}));
    when(
      () => repo.getEditTypesV2(contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => const Right({'photo_edit_types': []}));
    final c = _container(repo);

    await c
        .read(editingNotifierProvider.notifier)
        .load(bookingId: 7, contentType: 'photographer');

    expect(c.read(editingNotifierProvider).durationHours, 1);
  });

  test('duration — computed from start/end times, rounded up', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.getBookingTime(bookingId: any(named: 'bookingId')),
    ).thenAnswer(
      (_) async =>
          const Right({'start_time': '09:00:00', 'end_time': '12:30:00'}),
    );
    when(
      () => repo.getEditTypesV2(contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => const Right({'photo_edit_types': []}));
    final c = _container(repo);

    await c
        .read(editingNotifierProvider.notifier)
        .load(bookingId: 7, contentType: 'photographer');

    // 3.5h → ceil → 4
    expect(c.read(editingNotifierProvider).durationHours, 4);
  });

  test('duration — sums booking_days durations', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.getBookingTime(bookingId: any(named: 'bookingId')),
    ).thenAnswer(
      (_) async => const Right({
        'booking_days': [
          {'duration_hours': 2},
          {'duration_hours': 3},
        ],
      }),
    );
    when(
      () => repo.getEditTypesV2(contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => const Right({'photo_edit_types': []}));
    final c = _container(repo);

    await c
        .read(editingNotifierProvider.notifier)
        .load(bookingId: 7, contentType: 'photographer');

    expect(c.read(editingNotifierProvider).durationHours, 5);
  });

  test(
    'duration — booking time failure is non-fatal (default 1 hour)',
    () async {
      final repo = MockBookingRepository();
      when(
        () => repo.getBookingTime(bookingId: any(named: 'bookingId')),
      ).thenAnswer((_) async => Left(UnknownException(message: 'no time')));
      when(
        () => repo.getEditTypesV2(contentType: any(named: 'contentType')),
      ).thenAnswer((_) async => const Right({'photo_edit_types': []}));
      final c = _container(repo);

      await c
          .read(editingNotifierProvider.notifier)
          .load(bookingId: 7, contentType: 'photographer');

      final state = c.read(editingNotifierProvider);
      expect(state.status, EditingStatus.loaded);
      expect(state.durationHours, 1);
    },
  );

  test('edge case — edits_needed false sends empty key arrays', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateEdits(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    final ok = await c
        .read(editingNotifierProvider.notifier)
        .save(
          bookingId: 7,
          editsNeeded: false,
          photoEditTypes: ['retouch'],
          videoEditTypes: ['color'],
        );

    expect(ok, true);
    final captured =
        verify(
              () => repo.updateEdits(
                bookingId: 7,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['edits_needed'], 0);
    expect(captured['photo_edit_types'], const <String>[]);
    expect(captured['video_edit_types'], const <String>[]);
  });

  test('happy path — edits_needed true forwards selected keys', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.updateEdits(
        bookingId: any(named: 'bookingId'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => const Right({'ok': true}));
    final c = _container(repo);

    await c
        .read(editingNotifierProvider.notifier)
        .save(
          bookingId: 7,
          editsNeeded: true,
          photoEditTypes: ['retouch', 'retouch'],
          videoEditTypes: ['color'],
        );

    final captured =
        verify(
              () => repo.updateEdits(
                bookingId: 7,
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['edits_needed'], 1);
    expect(captured['photo_edit_types'], ['retouch', 'retouch']);
    expect(captured['video_edit_types'], ['color']);
  });

  test('error case — load failure surfaces message', () async {
    final repo = MockBookingRepository();
    when(
      () => repo.getBookingTime(bookingId: any(named: 'bookingId')),
    ).thenAnswer((_) async => const Right({'duration_hours': 1}));
    when(
      () => repo.getEditTypesV2(contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => Left(UnknownException(message: 'edits failed')));
    final c = _container(repo);

    await c
        .read(editingNotifierProvider.notifier)
        .load(bookingId: 7, contentType: 'x');

    final state = c.read(editingNotifierProvider);
    expect(state.status, EditingStatus.error);
    expect(state.errorMessage, 'edits failed');
  });
}
