import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_status.dart';
import 'meeting_type.dart';

/// Partial patch for an existing meeting. Every field nullable — `null` means
/// "leave unchanged" (PATCH semantics). `duration` deliberately absent —
/// server recomputes from start/end.
@immutable
class UpdateMeetingInput {
  final String? title;
  final String? description;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? link;
  final int? reminderMinutes;
  final MeetingStatus? status;
  final MeetingCategory? category;
  final MeetingType? meetingType;

  const UpdateMeetingInput({
    this.title,
    this.description,
    this.startAt,
    this.endAt,
    this.link,
    this.reminderMinutes,
    this.status,
    this.category,
    this.meetingType,
  });

  bool get isEmpty =>
      title == null &&
      description == null &&
      startAt == null &&
      endAt == null &&
      link == null &&
      reminderMinutes == null &&
      status == null &&
      category == null &&
      meetingType == null;
}
