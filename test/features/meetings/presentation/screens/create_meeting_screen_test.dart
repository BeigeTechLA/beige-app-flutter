import 'package:beige/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/meeting.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_response.dart';
import 'package:beige/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/shoot_option.dart';
import 'package:beige/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige/features/meetings/presentation/providers/create_meeting_notifier.dart';
import 'package:beige/features/meetings/presentation/providers/create_meeting_state.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:beige/features/meetings/presentation/screens/create_meeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

class _StubRepo implements MeetingsRepository {
  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async =>
      const [];

  @override
  Future<Meeting> getById(String id) async => throw UnimplementedError();

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
}

void main() {
  testWidgets('header text + submit CTA render', (tester) async {
    await tester.pumpProviderApp(
      const CreateMeetingScreen(),
      overrides: [
        meetingsRepositoryProvider.overrideWithValue(_StubRepo()),
      ],
    );

    expect(find.text('Create New Meeting'), findsOneWidget);
    expect(find.text('Create & Send Invite'), findsOneWidget);
  });

  testWidgets('submit CTA disabled while state is invalid', (tester) async {
    await tester.pumpProviderApp(
      const CreateMeetingScreen(),
      overrides: [
        meetingsRepositoryProvider.overrideWithValue(_StubRepo()),
      ],
    );

    final btn = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Create & Send Invite'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(btn.onPressed, isNull);
  });

  testWidgets('endAfterStart error surfaces in End Time field',
      (tester) async {
    await tester.pumpProviderApp(
      const CreateMeetingScreen(),
      overrides: [
        meetingsRepositoryProvider.overrideWithValue(_StubRepo()),
      ],
    );

    // Reach the notifier and seed start > end.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CreateMeetingScreen)),
    );
    final n = container.read(createMeetingNotifierProvider.notifier);
    n.setStartTime(const TimeOfDayValue(14, 0));
    n.setEndTime(const TimeOfDayValue(13, 0));
    await tester.pump();

    expect(find.text('End must be after start'), findsOneWidget);
  });
}
