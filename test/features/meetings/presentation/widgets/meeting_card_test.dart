import 'package:beige/features/meetings/domain/models/meeting.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_participant.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:beige/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

Meeting _meeting({
  String id = '1',
  String title = 'Pre-Production Kickoff',
  MeetingPlatform platform = MeetingPlatform.meet,
  MeetingStatus status = MeetingStatus.upcoming,
  int participantCount = 2,
}) {
  return Meeting(
    id: id,
    title: title,
    description: '',
    project: 'Cover Story',
    platform: platform,
    startAt: DateTime(2026, 6, 11, 13),
    endAt: DateTime(2026, 6, 11, 14),
    link: 'https://meet.google.com/x',
    reminderMinutes: 15,
    status: status,
    category: MeetingCategory.commercial,
    agenda: const [],
    participants: List.generate(
      participantCount,
      (i) => MeetingParticipant(id: '$i', name: 'P-$i'),
    ),
  );
}

void main() {
  testWidgets('renders title, date label, time range, status, platform', (
    tester,
  ) async {
    await tester.pumpProviderApp(
      Material(
        child: MeetingCard(meeting: _meeting(), onTap: () {}, onJoin: () {}),
      ),
    );

    expect(find.text('Pre-Production Kickoff'), findsOneWidget);
    expect(find.text('Jun 11,2026'), findsOneWidget);
    expect(find.text('01:00 PM to 02:00 PM'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Google Meet'), findsOneWidget);
    expect(find.text('Join Meeting'), findsOneWidget);
  });

  testWidgets('Join CTA fires onJoin', (tester) async {
    var hits = 0;
    await tester.pumpProviderApp(
      Material(
        child: MeetingCard(
          meeting: _meeting(),
          onTap: () {},
          onJoin: () => hits += 1,
        ),
      ),
    );

    await tester.tap(find.text('Join Meeting'));
    await tester.pump();

    expect(hits, 1);
  });

  testWidgets('shows +N Participants chip when count > 4', (tester) async {
    await tester.pumpProviderApp(
      Material(
        child: MeetingCard(
          meeting: _meeting(participantCount: 7),
          onTap: () {},
          onJoin: () {},
        ),
      ),
    );

    expect(find.text('+3 Participants'), findsOneWidget);
  });

  testWidgets('no +N chip when count ≤ 4', (tester) async {
    await tester.pumpProviderApp(
      Material(
        child: MeetingCard(
          meeting: _meeting(participantCount: 3),
          onTap: () {},
          onJoin: () {},
        ),
      ),
    );

    expect(find.textContaining('Participants'), findsNothing);
  });

  testWidgets('hides RSVP buttons for self-created meetings', (tester) async {
    final myUserId = 'user_123';
    final futureTime = DateTime.now().add(const Duration(days: 1));
    final selfCreatedMeeting = Meeting(
      id: 'self',
      title: 'Self Created',
      description: 'd',
      project: 'p',
      platform: MeetingPlatform.meet,
      startAt: futureTime,
      endAt: futureTime.add(const Duration(hours: 1)),
      link: 'https://example.com/self',
      reminderMinutes: 15,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.commercial,
      agenda: const ['agenda'],
      participants: const [],
      createdById: myUserId,
    );

    await tester.pumpProviderApp(
      Material(
        child: MeetingCard(
          meeting: selfCreatedMeeting,
          currentUserId: myUserId,
          onTap: () {},
          onJoin: () {},
          onAccept: () {},
          onReject: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accept'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('shows RSVP buttons for meetings created by others', (
    tester,
  ) async {
    final myUserId = 'user_123';
    final otherUserId = 'user_456';
    final futureTime = DateTime.now().add(const Duration(days: 1));
    final otherCreatedMeeting = Meeting(
      id: 'other',
      title: 'Other Created',
      description: 'd',
      project: 'p',
      platform: MeetingPlatform.meet,
      startAt: futureTime,
      endAt: futureTime.add(const Duration(hours: 1)),
      link: 'https://example.com/other',
      reminderMinutes: 15,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.commercial,
      agenda: const ['agenda'],
      participants: const [],
      createdById: otherUserId,
    );

    await tester.pumpProviderApp(
      Material(
        child: MeetingCard(
          meeting: otherCreatedMeeting,
          currentUserId: myUserId,
          onTap: () {},
          onJoin: () {},
          onAccept: () {},
          onReject: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });
}
