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
import 'package:beige/features/meetings/domain/models/shoot_option.dart';
import 'package:beige/features/meetings/domain/models/directory_participant.dart';
import 'package:beige/features/meetings/domain/models/shoot_participant_option.dart';
import 'package:beige/features/meetings/domain/models/update_meeting_input.dart';
import 'package:beige/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:beige/features/meetings/presentation/providers/create_meeting_notifier.dart';
import 'package:beige/features/meetings/presentation/providers/create_meeting_state.dart';
import 'package:beige/features/meetings/presentation/providers/meetings_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Meeting _stubMeeting() => Meeting(
      id: 'created',
      title: 'New',
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
  int createCalls = 0;
  CreateMeetingInput? lastInput;

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
  Future<Meeting> create(CreateMeetingInput input) async {
    createCalls += 1;
    lastInput = input;
    if (throws != null) throw throws!;
    return _stubMeeting();
  }

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

Future<ProviderContainer> _container({
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

void _fillValidForm(CreateMeetingNotifier n) {
  n.setTitle('Kickoff');
  n.setDescription('Planning sync');
  n.setShoot(const ShootOption(id: 42, title: 'Cover Story'));
  n.setDate(DateTime(2026, 6, 11));
  n.setStartTime(const TimeOfDayValue(13, 0));
  n.setEndTime(const TimeOfDayValue(14, 0));
  n.setLink('https://meet.google.com/abc');
  n.setPlatform(MeetingPlatform.meet);
  n.setParticipants(const [
    ShootParticipantOption(id: 'u_1', name: 'Alice', role: 'cp'),
  ]);
}

void main() {
  test('isValid false until all required fields populated', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    expect(container.read(createMeetingNotifierProvider).isValid, false);

    _fillValidForm(n);
    expect(container.read(createMeetingNotifierProvider).isValid, true);
  });

  test('submit no-op when isValid is false', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    await container.read(createMeetingNotifierProvider.notifier).submit();

    expect(repo.createCalls, 0);
    expect(
      container.read(createMeetingNotifierProvider).status,
      CreateMeetingSubmitStatus.idle,
    );
  });

  test('submit happy path → success status + created Meeting', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    _fillValidForm(n);
    await n.submit();

    expect(repo.createCalls, 1);
    final state = container.read(createMeetingNotifierProvider);
    expect(state.status, CreateMeetingSubmitStatus.success);
    expect(state.created?.id, 'created');
    // Participant passed through with the picker's real id.
    expect(repo.lastInput?.participants.map((p) => p.id), ['u_1']);
    expect(repo.lastInput?.participants.map((p) => p.name), ['Alice']);
    // Shoot id threaded into the input.
    expect(repo.lastInput?.shootId, 42);
    expect(repo.lastInput?.project, 'Cover Story');
  });

  test('endAfterStart guards isValid', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    _fillValidForm(n);
    // Flip end before start.
    n.setEndTime(const TimeOfDayValue(12, 0));
    expect(container.read(createMeetingNotifierProvider).endAfterStart, false);
    expect(container.read(createMeetingNotifierProvider).isValid, false);
  });

  test('UnauthorizedException flips auth state + error status', () async {
    final repo = _FakeRepo(
      throws: const UnauthorizedException(message: 'expired'),
    );
    final container = await _container(repo: repo, loggedIn: true);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    _fillValidForm(n);
    await n.submit();

    expect(
      container.read(createMeetingNotifierProvider).status,
      CreateMeetingSubmitStatus.error,
    );
    expect(container.read(authStateProvider), false);
  });

  test('setParticipants dedupes by id, preserving order', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    n.setParticipants(const [
      ShootParticipantOption(id: 'u_1', name: 'Alice'),
      ShootParticipantOption(id: 'u_2', name: 'Bob'),
      ShootParticipantOption(id: 'u_1', name: 'Alice'),
    ]);

    final ids = container
        .read(createMeetingNotifierProvider)
        .invitedParticipants
        .map((p) => p.id)
        .toList();
    expect(ids, ['u_1', 'u_2']);
  });

  test('removeParticipant drops by id', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    n.setParticipants(const [
      ShootParticipantOption(id: 'u_1', name: 'Alice'),
      ShootParticipantOption(id: 'u_2', name: 'Bob'),
    ]);
    n.removeParticipant('u_1');

    final ids = container
        .read(createMeetingNotifierProvider)
        .invitedParticipants
        .map((p) => p.id)
        .toList();
    expect(ids, ['u_2']);
  });

  test('DirectoryParticipant fromJson maps client and optional correctly', () {
    final clientJson = {
      'id': 'c_1',
      'name': 'Client User',
      'email': 'client@revurge.com',
      'role': 'client',
    };
    final client = DirectoryParticipant.fromJson(clientJson);
    expect(client.type, 'client');
    expect(client.isOptional, false);
    expect(client.isSelected, true);

    final staffJson = {
      'id': 's_1',
      'name': 'Staff User',
      'email': 'staff@revurge.com',
      'role': 'sales_rep',
    };
    final staff = DirectoryParticipant.fromJson(staffJson);
    expect(staff.type, 'staff');
    expect(staff.isOptional, true);
    expect(staff.isSelected, false);

    final cpJson = {
      'id': 'cp_1',
      'name': 'Creative Partner User',
      'email': 'cp@revurge.com',
      'role': 'cp',
    };
    final cp = DirectoryParticipant.fromJson(cpJson);
    expect(cp.type, 'creativePartner');
    expect(cp.isOptional, true);
    expect(cp.isSelected, false);
  });

  test('setShoot parses default members and handles mandatory vs optional state', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    final shoot = ShootOption(
      id: 42,
      title: 'Cover Story',
      defaultMembers: const [
        {'id': 'c_1', 'name': 'Pranav Client', 'role': 'client', 'email': 'pranav@revurge.com'},
        {'id': 's_1', 'name': 'Staff One', 'role': 'sales_rep', 'email': 'staff1@revurge.com'},
      ],
    );

    n.setShoot(shoot);

    final state = container.read(createMeetingNotifierProvider);
    expect(state.shootId, 42);
    expect(state.project, 'Cover Story');
    expect(state.defaultInvitedMembers.length, 2);
    
    expect(state.defaultInvitedMembers[0].id, 'c_1');
    expect(state.defaultInvitedMembers[0].type, 'client');
    expect(state.defaultInvitedMembers[0].isSelected, true);

    expect(state.defaultInvitedMembers[1].id, 's_1');
    expect(state.defaultInvitedMembers[1].type, 'staff');
    expect(state.defaultInvitedMembers[1].isSelected, false);

    // Optional defaults are pre-selected out of the box.
    expect(state.optionalSelectedDefaultMembers.length, 1);
    expect(state.optionalSelectedDefaultMembers[0].id, 's_1');
    expect(state.selectedParticipants.map((p) => p.id), containsAll(['c_1', 's_1']));

    // Toggle deselects the optional member.
    n.toggleOptionalDefaultMember(state.defaultInvitedMembers[1]);
    final updatedState = container.read(createMeetingNotifierProvider);
    expect(updatedState.optionalSelectedDefaultMembers, isEmpty);
    expect(updatedState.selectedParticipants.map((p) => p.id), ['c_1']);
  });

  test('toggleAdditionalMember and removeAdditionalMember updates state correctly', () async {
    final repo = _FakeRepo();
    final container = await _container(repo: repo);
    addTearDown(container.dispose);

    final n = container.read(createMeetingNotifierProvider.notifier);
    final staff = const DirectoryParticipant(id: 's_2', name: 'Sarah', type: 'staff');
    final cp = const DirectoryParticipant(id: 'cp_2', name: 'William', type: 'creativePartner');

    n.toggleAdditionalMember(staff);
    n.toggleAdditionalMember(cp);

    var state = container.read(createMeetingNotifierProvider);
    expect(state.selectedAdditionalStaffMembers.length, 1);
    expect(state.selectedAdditionalCreativePartners.length, 1);
    expect(state.selectedParticipants.length, 2);

    n.removeAdditionalMember('s_2');
    state = container.read(createMeetingNotifierProvider);
    expect(state.selectedAdditionalStaffMembers.length, 0);
    expect(state.selectedAdditionalCreativePartners.length, 1);
  });
}
