import 'dart:async';

import 'package:beige/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/generate_meet_link_input.dart';
import 'package:beige/features/meetings/domain/models/meeting.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige/features/meetings/domain/models/meeting_participant.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_response.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:beige/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/shoot_option.dart';
import 'package:beige/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:beige/features/meetings/presentation/widgets/meeting_details_sheet.dart';
import 'package:beige/shared/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

Meeting _meeting() => Meeting(
  id: 'm-1',
  title: 'Editorial Sync',
  description: 'planning',
  project: 'Cover Story',
  platform: MeetingPlatform.meet,
  startAt: DateTime(2026, 6, 11, 13),
  endAt: DateTime(2026, 6, 11, 14),
  link: 'https://meet.google.com/x',
  reminderMinutes: 15,
  status: MeetingStatus.upcoming,
  category: MeetingCategory.commercial,
  agenda: const ['Recap', 'Storyboards'],
  participants: const [
    MeetingParticipant(id: '1', name: 'Alice'),
    MeetingParticipant(id: '2', name: 'Bob'),
  ],
);

class _OkRepo implements MeetingsRepository {
  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async => const [];

  @override
  Future<Meeting> getById(String id) async => _meeting();

  @override
  Future<Meeting> create(CreateMeetingInput input) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async => throw UnimplementedError();

  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> respond(String id, MeetingResponse response) async =>
      throw UnimplementedError();

  @override
  Future<List<ShootOption>> listProjects() async => const [];

  @override
  Future<String> generateMeetLink(GenerateMeetLinkInput input) async =>
      throw UnimplementedError();
}

class _ErrRepo implements MeetingsRepository {
  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async => const [];

  @override
  Future<Meeting> getById(String id) async => throw Exception('boom');

  @override
  Future<Meeting> create(CreateMeetingInput input) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async => throw UnimplementedError();

  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> respond(String id, MeetingResponse response) async =>
      throw UnimplementedError();

  @override
  Future<List<ShootOption>> listProjects() async => const [];

  @override
  Future<String> generateMeetLink(GenerateMeetLinkInput input) async =>
      throw UnimplementedError();
}

void main() {
  testWidgets('data branch renders meeting + agenda + participants', (
    tester,
  ) async {
    await tester.pumpProviderApp(
      const Scaffold(body: MeetingDetailsSheet(meetingId: 'm-1')),
      overrides: [meetingsRepositoryProvider.overrideWithValue(_OkRepo())],
    );

    await tester.pumpAndSettle();

    expect(find.text('Editorial Sync'), findsOneWidget);
    expect(find.text('Cover Story'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    // Redesigned sheet collapses agenda into a single description card —
    // when `description` is non-empty it wins over the agenda list.
    expect(find.text('planning'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Join Meeting'), findsOneWidget);
  });

  testWidgets('error branch renders retry CTA', (tester) async {
    await tester.pumpProviderApp(
      const Scaffold(body: MeetingDetailsSheet(meetingId: 'm-1')),
      overrides: [meetingsRepositoryProvider.overrideWithValue(_ErrRepo())],
    );

    await tester.pumpAndSettle();

    expect(find.text('Could not load meeting'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('loading branch shows AppScreenLoader', (tester) async {
    // _PendingRepo never completes — keeps the FutureProvider in loading state.
    await tester.pumpProviderApp(
      const Scaffold(body: MeetingDetailsSheet(meetingId: 'm-1')),
      overrides: [meetingsRepositoryProvider.overrideWithValue(_PendingRepo())],
    );

    await tester.pump();

    expect(find.byType(AppScreenLoader), findsOneWidget);
  });
}

class _PendingRepo implements MeetingsRepository {
  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) => Completer<List<Meeting>>().future;

  @override
  Future<Meeting> getById(String id) => Completer<Meeting>().future;

  @override
  Future<Meeting> create(CreateMeetingInput input) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) async =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) async => throw UnimplementedError();

  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> respond(String id, MeetingResponse response) async =>
      throw UnimplementedError();

  @override
  Future<List<ShootOption>> listProjects() async => const [];

  @override
  Future<String> generateMeetLink(GenerateMeetLinkInput input) async =>
      throw UnimplementedError();
}
