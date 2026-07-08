import 'package:flutter/foundation.dart';

import 'meeting_category.dart';
import 'meeting_participant.dart';
import 'meeting_platform.dart';
import 'meeting_type.dart';

@immutable
class CreateMeetingInput {
  final String title;
  final String description;
  final String project;
  final int? shootId;
  final DateTime startAt;
  final DateTime endAt;
  final MeetingPlatform platform;
  final String link;
  final int reminderMinutes;
  final MeetingCategory category;
  final MeetingType meetingType;
  final List<String> agenda;
  final List<MeetingParticipant> participants;

  const CreateMeetingInput({
    required this.title,
    required this.description,
    required this.project,
    this.shootId,
    required this.startAt,
    required this.endAt,
    required this.platform,
    required this.link,
    required this.reminderMinutes,
    required this.category,
    required this.meetingType,
    this.agenda = const [],
    this.participants = const [],
  });
}
