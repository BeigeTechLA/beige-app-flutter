import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/meetings/domain/models/create_meeting_input.dart';
import 'package:beige/features/meetings/domain/models/meeting.dart';
import 'package:beige/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige/features/meetings/domain/models/meeting_rsvp.dart';
import 'package:beige/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige/features/meetings/presentation/providers/cancel_meeting_notifier.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo implements MeetingsRepository {
  _FakeRepo({this.throws});

  final Object? throws;
  int deleteCalls = 0;
  String? lastDeletedId;

  @override
  Future<void> delete(String id) async {
    deleteCalls += 1;
    lastDeletedId = id;
    if (throws != null) throw throws!;
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
  Future<Meeting> addParticipants(String id, List<String> userIds) async =>
      throw UnimplementedError();

  @override
  Future<Meeting> respond(String id, MeetingResponse response) async =>
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
      container.read(cancelMeetingNotifierProvider('m_1')).status,
      CancelMeetingStatus.idle,
    );
  });

  test('cancel success → done + delete called once with id', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);
    // Keep provider alive across the async cancel call.
    final sub = container.listen<CancelMeetingState>(
      cancelMeetingNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);

    await container
        .read(cancelMeetingNotifierProvider('m_1').notifier)
        .cancel();

    expect(repo.deleteCalls, 1);
    expect(repo.lastDeletedId, 'm_1');
    expect(
      container.read(cancelMeetingNotifierProvider('m_1')).status,
      CancelMeetingStatus.done,
    );
  });

  test('cancel failure → error + error message captured', () async {
    final repo = _FakeRepo(throws: Exception('server down'));
    final container = await _container(repo: repo);
    addTearDown(container.dispose);
    final sub = container.listen<CancelMeetingState>(
      cancelMeetingNotifierProvider('m_1'),
      (_, _) {},
    );
    addTearDown(sub.close);

    await container
        .read(cancelMeetingNotifierProvider('m_1').notifier)
        .cancel();

    final s = container.read(cancelMeetingNotifierProvider('m_1'));
    expect(s.status, CancelMeetingStatus.error);
    expect(s.error, isNotNull);
  });
}
