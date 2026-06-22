import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/meeting.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_rsvp.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:beige/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige/features/meetings/presentation/providers/meeting_response_notifier.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Meeting _stub() => Meeting(
      id: 'm_1',
      title: 'Kickoff',
      description: '',
      project: '',
      platform: MeetingPlatform.meet,
      startAt: DateTime(2026, 6, 11, 13),
      endAt: DateTime(2026, 6, 11, 14),
      link: 'https://meet.google.com/x',
      reminderMinutes: 15,
      status: MeetingStatus.upcoming,
      category: MeetingCategory.commercial,
      agenda: const [],
      participants: const [],
    );

class _FakeRepo implements MeetingsRepository {
  _FakeRepo({this.throws});

  final Object? throws;
  int respondCalls = 0;
  MeetingResponse? lastResponse;
  String? lastId;

  @override
  Future<Meeting> respond(String id, MeetingResponse response) async {
    respondCalls += 1;
    lastResponse = response;
    lastId = id;
    if (throws != null) throw throws!;
    return _stub();
  }

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

void main() {
  test('initial state is idle', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    expect(
      container.read(meetingResponseNotifierProvider('m_1')).status,
      MeetingResponseStatus.idle,
    );
  });

  test('accept → MeetingResponse.accept + accepted status', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);
    final sub = container.listen<MeetingResponseState>(
      meetingResponseNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);

    await container
        .read(meetingResponseNotifierProvider('m_1').notifier)
        .accept();

    expect(repo.respondCalls, 1);
    expect(repo.lastResponse, MeetingResponse.accept);
    expect(repo.lastId, 'm_1');
    expect(
      container.read(meetingResponseNotifierProvider('m_1')).status,
      MeetingResponseStatus.accepted,
    );
  });

  test('decline → MeetingResponse.decline + declined status', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);
    final sub = container.listen<MeetingResponseState>(
      meetingResponseNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);

    await container
        .read(meetingResponseNotifierProvider('m_1').notifier)
        .decline();

    expect(repo.lastResponse, MeetingResponse.decline);
    expect(
      container.read(meetingResponseNotifierProvider('m_1')).status,
      MeetingResponseStatus.declined,
    );
  });

  test('failure → error status', () async {
    final repo = _FakeRepo(throws: Exception('server down'));
    final container = await _container(repo: repo);
    addTearDown(container.dispose);
    final sub = container.listen<MeetingResponseState>(
      meetingResponseNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);

    await container
        .read(meetingResponseNotifierProvider('m_1').notifier)
        .accept();

    expect(
      container.read(meetingResponseNotifierProvider('m_1')).status,
      MeetingResponseStatus.error,
    );
  });

  test('wire value mapping accept→accepted, decline→declined', () {
    expect(MeetingResponse.accept.wireValue, 'accepted');
    expect(MeetingResponse.decline.wireValue, 'declined');
  });

  test('rsvpFromServer maps known + unknown variants', () {
    expect(rsvpFromServer('accepted'), MeetingRsvpStatus.accepted);
    expect(rsvpFromServer('ACCEPT'), MeetingRsvpStatus.accepted);
    expect(rsvpFromServer('declined'), MeetingRsvpStatus.declined);
    expect(rsvpFromServer('rejected'), MeetingRsvpStatus.declined);
    expect(rsvpFromServer('pending'), MeetingRsvpStatus.pending);
    expect(rsvpFromServer('invited'), MeetingRsvpStatus.pending);
    expect(rsvpFromServer(null), isNull);
    expect(rsvpFromServer('garbage'), isNull);
  });
}
