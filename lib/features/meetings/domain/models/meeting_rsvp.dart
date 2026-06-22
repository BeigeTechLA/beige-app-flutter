/// RSVP state of a single participant.
///
/// `pending` — invited, not yet responded; UI surfaces Accept/Decline CTAs.
/// `accepted` — invitation accepted; CTAs hidden, Join visible.
/// `declined` — invitation declined; CTAs hidden, list/detail still readable.
enum MeetingRsvpStatus { pending, accepted, declined }

/// Caller-facing intent for the respond endpoint. Maps 1:1 to the two terminal
/// states.
enum MeetingResponse { accept, decline }

extension MeetingResponseX on MeetingResponse {
  String get wireValue => switch (this) {
        MeetingResponse.accept => 'accepted',
        MeetingResponse.decline => 'declined',
      };
}

MeetingRsvpStatus? rsvpFromServer(String? raw) {
  switch (raw?.toLowerCase().trim()) {
    case 'accepted':
    case 'accept':
      return MeetingRsvpStatus.accepted;
    case 'declined':
    case 'decline':
    case 'rejected':
      return MeetingRsvpStatus.declined;
    case 'pending':
    case 'invited':
      return MeetingRsvpStatus.pending;
  }
  return null;
}
