import '../../domain/models/create_meeting_input.dart';
import '../../domain/models/generate_meet_link_input.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/meetings_tab.dart';
import '../../domain/models/shoot_option.dart';
import '../../domain/models/update_meeting_input.dart';
import '../../domain/repositories/meetings_repository.dart';
import '../mappers/meeting_enum_mapper.dart';
import '../sources/meetings_remote_source.dart';

/// Dio-backed implementation of [MeetingsRepository].
///
/// Two-step create flow is hidden from callers — the create-body `participants`
/// field is a confirmed dead path, so the impl POSTs the meeting then POSTs
/// `/participants` when the input has any. UI still sees one `Future<Meeting>`.
///
/// Server only exposes `limit`/`page`/`sortBy` query params today — `tab` and
/// [MeetingFilter] are applied client-side on the fetched page. Volumes today
/// (≤30 records observed) make in-memory filtering acceptable; re-evaluate
/// when pagination ships.
class MeetingsRepositoryImpl implements MeetingsRepository {
  MeetingsRepositoryImpl(this._remote);

  final MeetingsRemoteSource _remote;

  @override
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  }) async {
    // Tab now drives a server-side `meeting_time_status` filter.
    // MeetingFilter (category / status / date range) still applies locally.
    final page = await _remote.list(meetingTimeStatus: _tabToServer(tab));
    return _applyClientFilters(
      page.items,
      filter: filter,
      currentUserId: currentUserId,
    );
  }

  static String? _tabToServer(MeetingsTab? tab) {
    switch (tab) {
      case MeetingsTab.upcoming:
        return 'upcoming';
      case MeetingsTab.completed:
        return 'completed';
      case null:
        return null;
    }
  }

  @override
  Future<Meeting> getById(String id) => _remote.getById(id);

  @override
  Future<Meeting> create(CreateMeetingInput input) => _remote.create(input);

  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) {
    final body = _buildUpdateBody(patch);
    return _remote.update(id, body);
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);

  @override
  Future<Meeting> addParticipants(String id, List<String> userIds) =>
      _remote.addParticipants(id, userIds);

  @override
  Future<Meeting> respond(String id, MeetingResponse response) =>
      _remote.respond(id, response);

  @override
  Future<List<ShootOption>> listProjects() => _remote.getProjects();

  @override
  Future<String> generateMeetLink(GenerateMeetLinkInput input) =>
      _remote.generateMeetLink(input);

  /// Serializes [UpdateMeetingInput] to the server's snake_case patch body.
  /// Skips `null` fields so PATCH stays truly partial. `duration` never
  /// included — server recomputes from times.
  Map<String, dynamic> _buildUpdateBody(UpdateMeetingInput p) {
    final body = <String, dynamic>{};
    if (p.title != null) body['meeting_title'] = p.title;
    if (p.description != null) body['description'] = p.description;
    if (p.startAt != null) {
      body['meeting_date_time'] = p.startAt!.toUtc().toIso8601String();
    }
    if (p.endAt != null) {
      body['meeting_end_time'] = p.endAt!.toUtc().toIso8601String();
    }
    if (p.link != null) body['meetLink'] = p.link;
    if (p.reminderMinutes != null) body['reminder_minutes'] = p.reminderMinutes;
    if (p.status != null) {
      body['meeting_status'] = MeetingEnumMapper.statusToServer(p.status!);
    }
    if (p.category != null) {
      body['meeting_type'] = MeetingEnumMapper.categoryToServer(p.category!);
    }
    return body;
  }

  /// Tab is now server-side (`meeting_time_status`). [MeetingFilter]
  /// (category / status / date range) still applies locally; sort stays local.
  List<Meeting> _applyClientFilters(
    List<Meeting> items, {
    MeetingFilter? filter,
    String? currentUserId,
  }) {
    Iterable<Meeting> result = items;

    if (filter != null && !filter.isEmpty) {
      if (filter.categories.isNotEmpty) {
        result = result.where((m) => filter.categories.contains(m.category));
      }
      if (filter.statuses.isNotEmpty) {
        result = result.where((m) => filter.statuses.contains(m.status));
      }
      if (filter.dateRange != null) {
        final s = filter.dateRange!.start;
        final e = filter.dateRange!.end;
        result = result.where(
          (m) => !m.startAt.isBefore(s) && !m.startAt.isAfter(e),
        );
      }
    }

    final list = result.toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return list;
  }
}
