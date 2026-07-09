import '../models/create_meeting_input.dart';
import '../models/generate_meet_link_input.dart';
import '../models/meeting.dart';
import '../models/meeting_filter.dart';
import '../models/meeting_response.dart';
import '../models/meetings_tab.dart';
import '../models/shoot_option.dart';
import '../models/update_meeting_input.dart';

/// Stable interface for meetings. Backed by `MeetingsRepositoryImpl` (Dio)
/// against the `external-meetings` REST surface.
///
/// `update`/`delete`/`addParticipants` carry plumbing parity with the
/// crew-side app — wire them when Edit/Delete/Invite UI affordances ship.
abstract class MeetingsRepository {
  /// `currentUserId` only relevant for the `invited` tab — it scopes the
  /// participant match to the signed-in user. Pass null on tabs that don't
  /// need it; impl treats null as "no invited filter".
  Future<List<Meeting>> list({
    MeetingsTab? tab,
    MeetingFilter? filter,
    String? currentUserId,
  });

  Future<Meeting> getById(String id);

  Future<Meeting> create(CreateMeetingInput input);

  /// Partial update — every field on [patch] nullable, `null` = unchanged.
  /// Server recomputes `duration`; impl never sends it.
  Future<Meeting> update(String id, UpdateMeetingInput patch);

  /// Hard or soft delete — backend behavior undocumented. Caller treats 2xx
  /// as success.
  Future<void> delete(String id);

  /// Attaches participants to an existing meeting. Returns the full updated
  /// Meeting. Used internally by `create` to complete the 2-step create flow;
  /// also surfaced for a future "add participant" UI affordance.
  Future<Meeting> addParticipants(String id, List<String> userIds);

  /// Records the signed-in user's RSVP on the meeting. Server returns the
  /// updated Meeting (or void — impl re-fetches if needed) so callers can
  /// refresh local state.
  Future<Meeting> respond(String id, MeetingResponse response);

  /// Project summaries for the create-meeting shoot picker. Backed by
  /// `admin/get-projects`.
  Future<List<ShootOption>> listProjects();

  /// Generates a Google Meet link via backend. Returns the raw `meetLink`
  /// URL. Throws [AppException] on failure, including when backend responds
  /// with `authUrl` (Google OAuth required — surfaced as generic error).
  Future<String> generateMeetLink(GenerateMeetLinkInput input);
}
