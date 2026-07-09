import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/generate_meet_link_input.dart';
import 'package:beige/features/meetings/domain/models/meeting.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_response.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:beige/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/shoot_option.dart';
import 'package:beige/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige/features/meetings/presentation/providers/edit_meeting_notifier.dart';
import 'package:beige/features/meetings/presentation/providers/edit_meeting_state.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Meeting _baseline() => Meeting(
  id: 'm_1',
  title: 'Kickoff',
  description: 'Planning sync',
  project: 'Cover Story',
  platform: MeetingPlatform.meet,
  startAt: DateTime(2026, 6, 11, 13),
  endAt: DateTime(2026, 6, 11, 14),
  link: 'https://meet.google.com/abc',
  reminderMinutes: 15,
  status: MeetingStatus.upcoming,
  category: MeetingCategory.commercial,
  agenda: const [],
  participants: const [],
  createdById: 'u_42',
);

class _FakeRepo implements MeetingsRepository {
  _FakeRepo({this.failGet = false, this.failUpdate = false});

  final bool failGet;
  final bool failUpdate;
  int updateCalls = 0;
  UpdateMeetingInput? lastPatch;

  @override
  Future<Meeting> getById(String id) async {
    if (failGet) throw Exception('fetch failed');
    return _baseline();
  }

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) async {
    updateCalls += 1;
    lastPatch = patch;
    if (failUpdate) throw Exception('save failed');
    return _baseline();
  }

  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async => const [];

  @override
  Future<Meeting> create(CreateMeetingInput input) async =>
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

Future<ProviderContainer> _container({required MeetingsRepository repo}) async {
  SharedPreferences.setMockInitialValues({'isLoggedIn': true});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      meetingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

/// Flush a few microtask turns so the async `_load` inside `build()` finishes
/// before assertions. The fake repo resolves synchronously, but Riverpod still
/// needs at least one microtask hop for the `state =` write to settle.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('build hydrates form from getById and lands in ready state', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final sub = container.listen<EditMeetingState>(
      editMeetingNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);
    await _settle();

    final s = container.read(editMeetingNotifierProvider('m_1'));
    expect(s.status, EditMeetingStatus.ready);
    expect(s.title, 'Kickoff');
    expect(s.description, 'Planning sync');
    expect(s.link, 'https://meet.google.com/abc');
    expect(s.startTime?.hour, 13);
    expect(s.startTime?.minute, 0);
    expect(s.endTime?.hour, 14);
    expect(s.endTime?.minute, 0);
    expect(s.original?.createdById, 'u_42');
  });

  test('loadError exposes retryLoad path', () async {
    final repo = _FakeRepo(failGet: true);
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final sub = container.listen<EditMeetingState>(
      editMeetingNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);
    await _settle();

    final s = container.read(editMeetingNotifierProvider('m_1'));
    expect(s.status, EditMeetingStatus.loadError);
    expect(s.error, isNotNull);
  });

  test(
    'submit no-op when nothing changed → saved without update call',
    () async {
      final repo = _FakeRepo();
      final container = await _container(repo: repo);
      addTearDown(container.dispose);

      final sub = container.listen<EditMeetingState>(
        editMeetingNotifierProvider('m_1'),
        (_, _) {},
      );
      addTearDown(sub.close);
      await _settle();

      await container
          .read(editMeetingNotifierProvider('m_1').notifier)
          .submit();

      expect(repo.updateCalls, 0);
      expect(
        container.read(editMeetingNotifierProvider('m_1')).status,
        EditMeetingStatus.saved,
      );
    },
  );

  test('submit sends only diffed fields in patch', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final sub = container.listen<EditMeetingState>(
      editMeetingNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);
    await _settle();

    final n = container.read(editMeetingNotifierProvider('m_1').notifier);
    n.setTitle('Renamed');
    await n.submit();

    expect(repo.updateCalls, 1);
    expect(repo.lastPatch?.title, 'Renamed');
    expect(repo.lastPatch?.description, isNull);
    expect(repo.lastPatch?.link, isNull);
    expect(
      container.read(editMeetingNotifierProvider('m_1')).status,
      EditMeetingStatus.saved,
    );
  });

  test('submit failure flips to submitError', () async {
    final repo = _FakeRepo(failUpdate: true);
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final sub = container.listen<EditMeetingState>(
      editMeetingNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);
    await _settle();

    final n = container.read(editMeetingNotifierProvider('m_1').notifier);
    n.setTitle('Renamed');
    await n.submit();

    expect(
      container.read(editMeetingNotifierProvider('m_1')).status,
      EditMeetingStatus.submitError,
    );
  });
}
