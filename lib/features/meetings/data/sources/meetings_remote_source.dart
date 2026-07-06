import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../../../core/session/session_store.dart';
import '../../domain/models/create_meeting_input.dart';
import '../../domain/models/generate_meet_link_input.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_response.dart';
import '../../domain/models/shoot_option.dart';
import '../dto/meeting_dto.dart';
import '../mappers/meeting_enum_mapper.dart';

/// One page of meetings + a cursor-style `hasMore` flag.
///
/// `MeetingsRepository.list` collapses pagination today (single shot
/// `limit=100`), but the source exposes the envelope so future infinite scroll
/// can wire through without re-touching this layer.
class MeetingsPage {
  const MeetingsPage({required this.items, required this.hasMore});
  final List<Meeting> items;
  final bool hasMore;
}

/// REST source for the `external-meetings` endpoints.
///
/// All methods translate `DioException` → typed `AppException` via
/// [ExceptionHandler.mapDioError] so the notifier layer sees the same error
/// taxonomy as the rest of the app.
///
/// Two-step create flow lives in the repository impl — this source exposes
/// `create` and `addParticipants` as discrete calls.
class MeetingsRemoteSource {
  MeetingsRemoteSource(this._client, this._session);

  final DioClient _client;
  final SessionStore _session;

  Dio get _dio => _client.dio;

  /// Single funnel for `DioException` → `AppException`.
  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      throw ExceptionHandler.mapDioError(e);
    }
  }

  Future<MeetingsPage> list({
    int page = 1,
    int limit = 100,
    String sortBy = 'meeting_date_time:desc',
    String? meetingTimeStatus,
  }) {
    return _guard(() async {
      final user = await _session.readUser();
      final userId = user?.id ?? '';
      if (userId.isEmpty) {
        throw const UnauthorizedException(
          message: 'Cannot list meetings without an authenticated user',
        );
      }
      final resp = await _dio.get<dynamic>(
        ApiEndpoints.meetingsByUser(userId),
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          if (meetingTimeStatus != null) 'meeting_time_status': meetingTimeStatus,
        },
      );
      final raw = resp.data;
      final rawList = _unwrapResults(raw);
      final items = rawList
          .map((m) => MeetingDto.fromRestJson(m, currentUserId: userId))
          .toList(growable: false);
      return MeetingsPage(
        items: items,
        hasMore: _hasMoreFromEnvelope(raw, page: page, limit: limit),
      );
    });
  }

  Future<Meeting> getById(String id) {
    return _guard(() async {
      final userId = await _currentUserId();
      final resp = await _dio.get<dynamic>(ApiEndpoints.meetingById(id));
      return MeetingDto.fromRestJson(
        _unwrapItem(resp.data),
        currentUserId: userId,
      );
    });
  }

  Future<Meeting> create(CreateMeetingInput input) {
    return _guard(() async {
      final user = await _session.readUser();
      final adminId = int.tryParse(user?.id ?? '');
      final selfId = user?.id ?? '';
      final cpIds = <String>[];
      final participantIds = <String>[];
      for (final p in input.participants) {

        if (p.id.isEmpty) continue;
        if (p.id == selfId) continue;
        final role = (p.role ?? '').toLowerCase();
        if (role == 'cp' ||
            role == 'creative_partner' ||
            role == 'creativepartner') {
          cpIds.add(p.id);
        } else {
          participantIds.add(p.id);
        }
      }
      final body = <String, dynamic>{
        'meeting_date_time': input.startAt.toUtc().toIso8601String(),
        'meeting_end_time': input.endAt.toUtc().toIso8601String(),
        'meeting_status': 'pending',
        'meeting_type': MeetingEnumMapper.categoryToServer(input.category),
        'meeting_title': input.title,
        'description': input.description,
        'meetLink': input.link,
        'cp_ids': cpIds,
        if (adminId != null) 'admin_id': adminId,
        'participants': participantIds,
        'send_notification': false,
        'reminder_minutes': input.reminderMinutes,
      };
      if (adminId != null) {
        body['created_by_id'] = adminId;
      }
      if (input.shootId != null) {
        body['order_id'] = input.shootId.toString();
      }
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.meetings,
        data: body,
      );
      return MeetingDto.fromRestJson(
        _unwrapItem(resp.data),
        currentUserId: user?.id ?? '',
      );
    });
  }

  /// Attaches participants to an existing meeting. Returns the full updated
  /// meeting.
  ///
  /// `role` field on the request body has no observable effect — server
  /// always tags added users as `role: "participant"`. Send the same value so
  /// behavior does not depend on backend ignoring an unknown role.
  Future<Meeting> addParticipants(String meetingId, List<String> userIds) {
    return _guard(() async {
      final currentUserId = await _currentUserId();
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.meetingParticipants(meetingId),
        data: {
          'role': 'participant',
          'user_ids': userIds,
        },
      );
      return MeetingDto.fromRestJson(
        _unwrapItem(resp.data),
        currentUserId: currentUserId,
      );
    });
  }

  /// Partial update. Caller supplies only the keys to change.
  ///
  /// `duration` is stripped defensively — server recomputes from start/end.
  Future<Meeting> update(String id, Map<String, dynamic> patch) {
    return _guard(() async {
      final currentUserId = await _currentUserId();
      final body = Map<String, dynamic>.of(patch)..remove('duration');
      final resp = await _dio.patch<dynamic>(
        ApiEndpoints.meetingById(id),
        data: body,
      );
      return MeetingDto.fromRestJson(
        _unwrapItem(resp.data),
        currentUserId: currentUserId,
      );
    });
  }

  Future<void> delete(String id) {
    return _guard(() async {
      await _dio.delete<dynamic>(ApiEndpoints.meetingById(id));
    });
  }

  /// GET `admin/get-projects` — projects list used by the create-meeting
  /// shoot dropdown. Response shape:
  /// `{data: {stats, projects: [{project: {stream_project_booking_id, name,
  /// ...}}]}}`. Maps each entry to a [ShootOption] using
  /// `stream_project_booking_id` as `id` and `name` as `title`. Entries
  /// missing either field are skipped.
  Future<List<ShootOption>> getProjects() {
    return _guard(() async {
      final resp = await _dio.get<dynamic>(ApiEndpoints.adminGetProjects);
      final raw = resp.data;
      Iterable<dynamic> projects = const [];
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is Map<String, dynamic>) {
          final list = data['projects'];
          if (list is List) projects = list;
        }
      }
      return projects
          .map(_projectToOption)
          .whereType<ShootOption>()
          .toList(growable: false);
    });
  }

  static ShootOption? _projectToOption(dynamic entry) {
    if (entry is! Map) return null;
    final project = entry['project'];
    if (project is! Map) return null;
    final id = project['stream_project_booking_id'];
    if (id is! int) return null;
    final rawMembers = project['default_members'] ?? project['defaultMembers'];
    final List<dynamic> defaultMembers = rawMembers is List ? rawMembers : const [];
    final title = _buildShootLabel(project, id);
    if (title.isEmpty) return null;
    return ShootOption(
      id: id,
      title: title,
      defaultMembers: defaultMembers,
    );
  }

  /// Builds `{SHOOT_TYPE} Shoot - {Client Name} (Booking #{id})`.
  /// Client name comes from `client_name` if present, else parsed from
  /// `project_name` (segment after last " - "). Falls back to `project_name` /
  /// `name` when shoot_type or client are missing.
  static String _buildShootLabel(Map<dynamic, dynamic> project, int id) {
    final projectName = (project['project_name'] as String?)?.trim() ??
        (project['name'] as String?)?.trim() ??
        '';
    final shootType = (project['shoot_type'] as String?)?.trim();
    final clientName = (project['client_name'] as String?)?.trim() ??
        _clientFromProjectName(projectName);

    if (shootType != null && shootType.isNotEmpty && clientName.isNotEmpty) {
      return '${shootType.toUpperCase()} Shoot - $clientName (Booking #$id)';
    }
    if (projectName.isNotEmpty) {
      return '$projectName (Booking #$id)';
    }
    return '';
  }

  static String _clientFromProjectName(String projectName) {
    if (projectName.isEmpty) return '';
    final idx = projectName.lastIndexOf(' - ');
    if (idx == -1) return projectName;
    return projectName.substring(idx + 3).trim();
  }

  /// Generates a Google Meet link via `external-meetings/create-event`.
  /// Backend proxies Google Calendar API. Returns the raw `meetLink` string.
  ///
  /// If backend responds with `authUrl` (Google OAuth required), throws
  /// [ServerException] so the notifier surfaces a generic error toast — the
  /// in-app OAuth flow is intentionally not implemented per product decision.
  Future<String> generateMeetLink(GenerateMeetLinkInput input) {
    return _guard(() async {
      final body = <String, dynamic>{
        'userId': input.userId,
        'summary': input.summary,
        'location': 'Online',
        'description': input.description,
        'startDateTime': input.startAt.toUtc().toIso8601String(),
        'endDateTime': input.endAt.toUtc().toIso8601String(),
        'orderId': input.orderId.toString(),
      };
      final resp = await _dio.post<dynamic>(
        ApiEndpoints.externalMeetingsCreateEvent,
        data: body,
      );
      final data = resp.data;
      if (data is Map) {
        final link = data['meetLink'];
        if (link is String && link.isNotEmpty) return link;
        if (data['authUrl'] is String) {
          throw const ServerException(
            message: 'Meet link authorization required',
          );
        }
      }
      throw const ServerException(message: 'Unexpected meet link response');
    });
  }

  /// Records the signed-in user's RSVP. Server returns the updated meeting
  /// payload in the same shape as `getById`.
  Future<Meeting> respond(String id, MeetingResponse response) {
    return _guard(() async {
      final currentUserId = await _currentUserId();
      final resp = await _dio.patch<dynamic>(
        ApiEndpoints.meetingRespond(id),
        data: {'response': response.serverValue},
      );
      return MeetingDto.fromRestJson(
        _unwrapItem(resp.data),
        currentUserId: currentUserId,
      );
    });
  }

  /// Reads the session user id once per call. Empty string when no user is in
  /// session — MeetingDto treats empty as "skip myResponse resolution".
  Future<String> _currentUserId() async {
    final user = await _session.readUser();
    return user?.id ?? '';
  }

  // ───── envelope helpers ────────────────────────────────────────────────

  /// List envelope is `{results, page, limit, totalPages, totalResults}`.
  /// Falls back to bare-list / generic envelope shapes in case backend ever
  /// pivots.
  static List<Map<String, dynamic>> _unwrapResults(dynamic raw) {
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    if (raw is Map<String, dynamic>) {
      for (final key in const ['results', 'data', 'items']) {
        final v = raw[key];
        if (v is List) return v.cast<Map<String, dynamic>>();
      }
    }
    throw const FormatException('Unrecognized meetings list envelope');
  }

  /// Single-object endpoints (`GET :id`, `POST`, `POST /participants`, PATCH)
  /// return the Meeting directly. Stay tolerant in case backend wraps in
  /// `{data: ...}` later.
  static Map<String, dynamic> _unwrapItem(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      for (final key in const ['data', 'result']) {
        final v = raw[key];
        if (v is Map<String, dynamic>) return v;
      }
      return raw;
    }
    throw const FormatException('Unrecognized meeting envelope');
  }

  /// `hasMore = page < totalPages` per documented envelope. Falls back to
  /// `data.length >= limit` if `totalPages` absent.
  static bool _hasMoreFromEnvelope(
    dynamic raw, {
    required int page,
    required int limit,
  }) {
    if (raw is Map<String, dynamic>) {
      final total = raw['totalPages'];
      if (total is num) return page < total;
    }
    try {
      return _unwrapResults(raw).length >= limit;
    } catch (_) {
      return false;
    }
  }
}
