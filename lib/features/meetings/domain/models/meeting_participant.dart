import 'package:flutter/foundation.dart';

import 'meeting_response.dart';

@immutable
class MeetingParticipant {
  final String id;
  final String name;
  final String? avatarUrl;

  /// Participant's RSVP state on the meeting. `null` means the server omitted
  /// the field (legacy meetings predate RSVP tracking); UI treats null the
  /// same as `pending` so invited users always see Accept/Decline.
  final MeetingResponse? rsvpStatus;

  const MeetingParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rsvpStatus,
  });

  MeetingParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    MeetingResponse? rsvpStatus,
  }) {
    return MeetingParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
    );
  }
}
