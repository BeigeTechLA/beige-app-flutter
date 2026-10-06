import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:beige/features/shoot/domain/repositories/shoot_repository.dart';
import 'package:beige/features/shoot/presentation/providers/shoot_providers.dart';
import 'package:beige/features/shoot/presentation/screens/cancel_shoot_screen.dart';
import 'package:beige/features/shoot/presentation/screens/manage_shoot_screen.dart';
import 'package:beige/features/shoot/presentation/screens/my_shoots_screen.dart';

class _MockShootRepository extends Mock implements ShootRepository {}

void main() {
  late _MockShootRepository mockRepo;

  setUp(() {
    mockRepo = _MockShootRepository();
  });

  Widget createSubject({required Widget child}) {
    return ProviderScope(
      overrides: [
        shootRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Phase 7 - My Shoots Deferred Bookings', () {
    testWidgets('renders Amber Gold badge and 30-day copy for deferred bookings with no invented date', (tester) async {
      when(() => mockRepo.getMyShoots(status: 'upcoming')).thenAnswer(
        (_) async => const Right([
          {
            'booking_id': 991,
            'project_name': 'Spring Fashion Editorial',
            'content_type': 'photographer',
            'confirm_later': true,
            'is_date_to_be_decided': true,
            'creative': {'name': 'Sarah Jenkins'},
          },
        ]),
      );
      when(() => mockRepo.getMyShoots(status: 'completed')).thenAnswer(
        (_) async => const Right([]),
      );

      await tester.pumpWidget(createSubject(child: const MyShootsScreen()));
      await tester.pumpAndSettle();

      // Verify the deferred badge appears
      expect(find.text('Date To Be Decided'), findsOneWidget);
      expect(find.text('🗓️'), findsOneWidget);

      // Verify customer copy and action
      expect(find.text('Paid & Confirmed • Choose date within 30 days'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);

      // Verify project name / title appears
      expect(find.text('Sarah Jenkins - Spring Fashion Editorial'), findsOneWidget);

      // Verify NO invented date like "--", "1970", etc.
      expect(find.textContaining('1970'), findsNothing);
      expect(find.text('Shoot Details'), findsNothing);
    });

    testWidgets('renders scheduled bookings with date, time, and Shoot Details action', (tester) async {
      when(() => mockRepo.getMyShoots(status: 'upcoming')).thenAnswer(
        (_) async => const Right([
          {
            'booking_id': 992,
            'project_name': 'Commercial Launch',
            'content_type': 'videographer',
            'event_date': '2026-11-20',
            'start_time': '10:00:00',
            'end_time': '12:00:00',
            'duration_hours': 2,
            'creative': {'name': 'David Miller'},
          },
        ]),
      );
      when(() => mockRepo.getMyShoots(status: 'completed')).thenAnswer(
        (_) async => const Right([]),
      );

      await tester.pumpWidget(createSubject(child: const MyShootsScreen()));
      await tester.pumpAndSettle();

      // No deferred badge
      expect(find.text('Date To Be Decided'), findsNothing);

      // Scheduled action label
      expect(find.text('Shoot Details'), findsOneWidget);
      expect(find.text('David Miller - Commercial Launch'), findsOneWidget);
    });
  });

  group('Phase 7 - Manage & Cancel Shoot deferred compatibility', () {
    testWidgets('ManageShootScreen displays Date To Be Decided when isDeferred is true', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: const ManageShootScreen(
            bookingId: 991,
            projectName: 'Deferred Brand Shoot',
            contentType: 'photographer',
            shootTypeId: 1,
            isDeferred: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Date To Be Decided'), findsOneWidget);
      expect(find.text('Choose your date within 30 days'), findsOneWidget);
      expect(find.textContaining(' to '), findsNothing);
    });

    testWidgets('CancelShootScreen displays Date To Be Decided for deferred booking', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: const CancelShootScreen(
            bookingId: 991,
            projectName: 'Deferred Brand Shoot',
            eventDate: '',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Date To Be Decided'), findsOneWidget);
      expect(find.text('Choose within 30 days'), findsOneWidget);
    });
  });
}
