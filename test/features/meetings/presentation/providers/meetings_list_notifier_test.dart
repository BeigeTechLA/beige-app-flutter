import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/auth_state_provider.dart';
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
import 'package:beige/features/meetings/presentation/providers/meetings_list_notifier.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_list_state.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Meeting _m(String id, {MeetingStatus status = MeetingStatus.upcoming}) =>
    Meeting(
      id: id,
      title: 'T-$id',
      description: '',
      project: '',
      platform: MeetingPlatform.meet,
      startAt: DateTime(2026, 6, 11, 13),
      endAt: DateTime(2026, 6, 11, 14),
      link: 'https://meet.google.com/x',
      reminderMinutes: 15,
      status: status,
      category: MeetingCategory.commercial,
      agenda: const [],
      participants: const [],
    );

class _FakeRepo implements MeetingsRepository {
  _FakeRepo({
    this.items = const [],
    this.throws,
    this.respondThrows,
    this.respondResult,
  });

  final List<Meeting> items;
  final Object? throws;
  final Object? respondThrows;
  final Meeting? respondResult;
  int listCalls = 0;
  int respondCalls = 0;
  String? lastRespondId;
  MeetingResponse? lastRespondValue;

  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async {
    listCalls += 1;
    if (throws != null) throw throws!;
    return items;
  }

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
  Future<Meeting> respond(String id, MeetingResponse response) async {
    respondCalls += 1;
    lastRespondId = id;
    lastRespondValue = response;
    if (respondThrows != null) throw respondThrows!;
    return respondResult ?? items.firstWhere((m) => m.id == id);
  }

  @override
  Future<List<ShootOption>> listProjects() async => const [];

  @override
  Future<String> generateMeetLink(GenerateMeetLinkInput input) async =>
      throw UnimplementedError();
}

Future<ProviderContainer> _buildContainer({
  required MeetingsRepository repo,
  bool loggedIn = true,
}) async {
  SharedPreferences.setMockInitialValues({'isLoggedIn': loggedIn});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      meetingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

void main() {
  test('build loads items into ready state', () async {
    final repo = _FakeRepo(items: [_m('a'), _m('b')]);
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    // Future.microtask in build → drain
    await Future<void>.delayed(Duration.zero);

    final state = container.read(meetingsListNotifierProvider);
    expect(state.status, MeetingsListStatus.ready);
    expect(state.items.map((m) => m.id), ['a', 'b']);
  });

  test('UnauthorizedException flips auth state to false', () async {
    final repo = _FakeRepo(
      throws: const UnauthorizedException(message: 'expired'),
    );
    final container = await _buildContainer(repo: repo, loggedIn: true);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    // Drive the load directly through refresh() instead of relying on the
    // build-time microtask — keeps the notifier's ref alive across awaits.
    await container.read(meetingsListNotifierProvider.notifier).refresh();

    final state = container.read(meetingsListNotifierProvider);
    expect(state.status, MeetingsListStatus.error);
    expect(state.error, 'expired');
    expect(container.read(authStateProvider), false);
  });

  test('selectTab kicks off a new fetch (server-driven meeting_time_status)', () async {
    final repo = _FakeRepo(
      items: [
        _m('a', status: MeetingStatus.upcoming),
        _m('b', status: MeetingStatus.completed),
      ],
    );
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    final notifier = container.read(meetingsListNotifierProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    expect(repo.listCalls, 1);

    notifier.selectTab(MeetingsTab.upcoming); // same tab — no refetch
    expect(repo.listCalls, 1);

    notifier.selectTab(MeetingsTab.completed);
    await Future<void>.delayed(Duration.zero);
    // Server-side tab now → refetch triggered.
    expect(repo.listCalls, 2);
  });

  test('applyFilter updates state + recomputes items locally', () async {
    final repo = _FakeRepo(items: [_m('a')]);
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    final notifier = container.read(meetingsListNotifierProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    const filter = MeetingFilter(
      categories: {MeetingCategory.commercial},
    );
    notifier.applyFilter(filter);

    // No second fetch — filter applied locally.
    expect(repo.listCalls, 1);
    expect(container.read(meetingsListNotifierProvider).isFiltered, true);
  });

  test('respond patches the matching item in place + clears pending id',
      () async {
    final original = _m('a');
    final updated = original.copyWith(status: MeetingStatus.completed);
    final repo = _FakeRepo(items: [original], respondResult: updated);
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(meetingsListNotifierProvider.notifier);
    final ok = await notifier.respond('a', MeetingResponse.accepted);

    expect(ok, true);
    expect(repo.respondCalls, 1);
    expect(repo.lastRespondId, 'a');
    expect(repo.lastRespondValue, MeetingResponse.accepted);

    final state = container.read(meetingsListNotifierProvider);
    expect(state.allItems.single.status, MeetingStatus.completed);
    expect(state.isRsvpPending('a'), false);
    expect(state.rsvpError, isNull);
  });

  test('respond re-entrant call is ignored while first is in flight',
      () async {
    final repo = _FakeRepo(items: [_m('a')]);
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(meetingsListNotifierProvider.notifier);
    final first = notifier.respond('a', MeetingResponse.accepted);
    final second = notifier.respond('a', MeetingResponse.declined);
    final results = await Future.wait([first, second]);

    expect(results, [true, false]);
    expect(repo.respondCalls, 1);
  });

  test('respond failure surfaces error + clears pending id', () async {
    final repo = _FakeRepo(
      items: [_m('a')],
      respondThrows: const ServerException(message: 'boom'),
    );
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(meetingsListNotifierProvider.notifier);
    final ok = await notifier.respond('a', MeetingResponse.accepted);

    expect(ok, false);
    final state = container.read(meetingsListNotifierProvider);
    expect(state.isRsvpPending('a'), false);
    expect(state.rsvpError, 'boom');

    notifier.clearRsvpError();
    expect(container.read(meetingsListNotifierProvider).rsvpError, isNull);
  });

  test('respond UnauthorizedException flips auth state to false', () async {
    final repo = _FakeRepo(
      items: [_m('a')],
      respondThrows: const UnauthorizedException(message: 'expired'),
    );
    final container = await _buildContainer(repo: repo);
    addTearDown(container.dispose);

    container.listen(meetingsListNotifierProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    final notifier = container.read(meetingsListNotifierProvider.notifier);
    await notifier.respond('a', MeetingResponse.accepted);

    expect(container.read(authStateProvider), false);
  });
}
