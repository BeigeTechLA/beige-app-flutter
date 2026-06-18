import '../models/create_meeting_input.dart';
import '../models/meeting.dart';
import '../models/meeting_filter.dart';
import '../models/meeting_status.dart';
import '../models/update_meeting_input.dart';

/// Stable interface for meetings. Backed by `MeetingsRepositoryImpl` (Dio)
/// against the `external-meetings` REST surface.
///
/// `update`/`delete`/`addParticipants` carry plumbing parity with the
/// crew-side app — wire them when Edit/Delete/Invite UI affordances ship.
abstract class MeetingsRepository {
  Future<List<Meeting>> list({
    MeetingStatus? tab,
    MeetingFilter? filter,
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
}
