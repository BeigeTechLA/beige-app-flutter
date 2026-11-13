import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/screens/editing_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  testWidgets('default duration and extra photo sets update the total', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = MockBookingRepository();
    when(
      () => repo.getBookingTime(bookingId: 7),
    ).thenAnswer((_) async => const Right(<String, dynamic>{}));
    when(
      () => repo.getEditTypesV2(contentType: 'photographer,videographer'),
    ).thenAnswer(
      (_) async => const Right({
        'photo_edit_types': [
          {
            'key': 'extra',
            'value': 'Extra Edited Photos',
            'note': '(25 Photos / Set)',
          },
        ],
        'video_edit_types': [
          {'key': 'highlight', 'value': 'Highlight Video'},
        ],
      }),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookingRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          home: EditingScreen(
            bookingId: 7,
            contentType: 'photographer,videographer',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1 Hour', findRichText: true), findsOneWidget);
    expect(find.text("You'll Receive 50 Photos"), findsOneWidget);
    expect(find.text('Highlight Video'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Video Edits')).dy,
      greaterThan(tester.getTopLeft(find.text("You'll Receive 50 Photos")).dy),
    );
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text("You'll Receive 75 Photos"), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text("You'll Receive 100 Photos"), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text("You'll Receive 75 Photos"), findsOneWidget);
    await tester.tap(find.text('Video Edits'));
    await tester.pump();
    expect(find.text('Highlight Video'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
