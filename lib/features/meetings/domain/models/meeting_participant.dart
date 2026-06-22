import 'package:flutter/foundation.dart';

import 'meeting_rsvp.dart';

@immutable
class MeetingParticipant {
  final String id;
  final String name;
  final String? avatarUrl;

  /// Optional invitation status. Defaults to `pending` when the server payload
  /// omits the field (legacy meetings predate RSVP tracking). Null means
  /// "field genuinely absent" — UI treats null the same as `pending` for CTA
  /// gating so invited users are never stuck without an Accept/Decline.
  final MeetingRsvpStatus? rsvpStatus;

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
    MeetingRsvpStatus? rsvpStatus,
  }) {
    return MeetingParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
    );
  }
}
