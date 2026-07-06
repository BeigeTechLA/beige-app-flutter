import 'package:flutter/foundation.dart';

import '../../domain/models/directory_participant.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/shoot_participant_option.dart';

enum CreateMeetingSubmitStatus { idle, submitting, success, error }

enum MeetLinkGenerationStatus { idle, loading, success, error }

@immutable
class CreateMeetingState {
  final String title;
  final String description;
  final String project;
  final int? shootId;
  final DateTime? date;
  final TimeOfDayValue? startTime;
  final TimeOfDayValue? endTime;
  final MeetingPlatform platform;
  final String link;
  final int reminderMinutes;
  final List<ShootParticipantOption> invitedParticipants; // Deprecated but kept for backward compatibility/types
  final CreateMeetingSubmitStatus status;
  final String? error;
  final Meeting? created;

  // New participant state fields
  final bool directoryLoading;
  final String? directoryError;
  final List<DirectoryParticipant> directoryParticipants;
  final List<DirectoryParticipant> defaultInvitedMembers;
  final List<DirectoryParticipant> optionalSelectedDefaultMembers;
  final List<DirectoryParticipant> selectedAdditionalStaffMembers;
  final List<DirectoryParticipant> selectedAdditionalCreativePartners;
  final String searchText;
  final String selectedTab; // 'staff' | 'cp'

  // Meet link generation
  final MeetLinkGenerationStatus linkGenStatus;
  final String? linkGenError;

  const CreateMeetingState({
    this.title = '',
    this.description = '',
    this.project = '',
    this.shootId,
    this.date,
    this.startTime,
    this.endTime,
    this.platform = MeetingPlatform.meet,
    this.link = '',
    this.reminderMinutes = 15,
    this.invitedParticipants = const [],
    this.status = CreateMeetingSubmitStatus.idle,
    this.error,
    this.created,
    this.directoryLoading = false,
    this.directoryError,
    this.directoryParticipants = const [],
    this.defaultInvitedMembers = const [],
    this.optionalSelectedDefaultMembers = const [],
    this.selectedAdditionalStaffMembers = const [],
    this.selectedAdditionalCreativePartners = const [],
    this.searchText = '',
    this.selectedTab = 'staff',
    this.linkGenStatus = MeetLinkGenerationStatus.idle,
    this.linkGenError,
  });

  bool get hasTitle => title.trim().isNotEmpty;
  bool get hasDescription => description.trim().isNotEmpty;
  bool get hasDate => date != null;
  bool get hasTimes => startTime != null && endTime != null;
  bool get hasLink => link.trim().isNotEmpty && _looksLikeUrl(link.trim());

  /// Prereqs for the Generate Meet Link button. Only Meet platform supports
  /// backend-driven generation. Requires all fields the backend needs to
  /// create the Google Calendar event.
  bool get canGenerateMeetLink =>
      platform == MeetingPlatform.meet &&
      hasTitle &&
      hasDescription &&
      hasDate &&
      hasTimes &&
      endAfterStart &&
      shootId != null;

  bool get endAfterStart {
    if (!hasTimes) return false;
    final s = startTime!;
    final e = endTime!;
    return (e.hour * 60 + e.minute) > (s.hour * 60 + s.minute);
  }

  /// Unified deduplicated list of all selected participants.
  List<DirectoryParticipant> get selectedParticipants {
    final List<DirectoryParticipant> allSelected = [];
    
    // 1. Legacy/test compatibility: include deprecated invitedParticipants
    for (final p in invitedParticipants) {
      allSelected.add(DirectoryParticipant(
        id: p.id,
        name: p.name,
        role: p.role,
        type: p.role == 'client' ? 'client' : ((p.role == 'cp' || p.role == 'creative_partner') ? 'creativePartner' : 'staff'),
        avatarUrl: p.avatarUrl,
        isOptional: p.role != 'client',
        isSelected: true,
      ));
    }
    
    // 2. Default invited members: Clients are mandatory and selectedByDefault is true.
    // Optional default members are included only if they are present in optionalSelectedDefaultMembers.
    for (final p in defaultInvitedMembers) {
      if (!p.isOptional || optionalSelectedDefaultMembers.contains(p)) {
        allSelected.add(p);
      }
    }
    
    // 3. Selected additional staff members
    allSelected.addAll(selectedAdditionalStaffMembers);
    
    // 4. Selected additional creative partners
    allSelected.addAll(selectedAdditionalCreativePartners);
    
    // Deduplicate by ID
    final seenIds = <String>{};
    final List<DirectoryParticipant> result = [];
    for (final p in allSelected) {
      if (seenIds.add(p.id)) {
        result.add(p);
      }
    }
    return result;
  }

  bool get isValid =>
      hasTitle &&
      hasDescription &&
      shootId != null &&
      hasDate &&
      hasTimes &&
      endAfterStart &&
      hasLink &&
      selectedParticipants.isNotEmpty;

  CreateMeetingState copyWith({
    String? title,
    String? description,
    String? project,
    int? shootId,
    DateTime? date,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    MeetingPlatform? platform,
    String? link,
    int? reminderMinutes,
    List<ShootParticipantOption>? invitedParticipants,
    CreateMeetingSubmitStatus? status,
    String? error,
    bool clearError = false,
    Meeting? created,
    bool? directoryLoading,
    String? directoryError,
    bool clearDirectoryError = false,
    List<DirectoryParticipant>? directoryParticipants,
    List<DirectoryParticipant>? defaultInvitedMembers,
    List<DirectoryParticipant>? optionalSelectedDefaultMembers,
    List<DirectoryParticipant>? selectedAdditionalStaffMembers,
    List<DirectoryParticipant>? selectedAdditionalCreativePartners,
    String? searchText,
    String? selectedTab,
    MeetLinkGenerationStatus? linkGenStatus,
    String? linkGenError,
    bool clearLinkGenError = false,
  }) {
    return CreateMeetingState(
      title: title ?? this.title,
      description: description ?? this.description,
      project: project ?? this.project,
      shootId: shootId ?? this.shootId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      platform: platform ?? this.platform,
      link: link ?? this.link,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      invitedParticipants: invitedParticipants ?? this.invitedParticipants,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      created: created ?? this.created,
      directoryLoading: directoryLoading ?? this.directoryLoading,
      directoryError: clearDirectoryError ? null : (directoryError ?? this.directoryError),
      directoryParticipants: directoryParticipants ?? this.directoryParticipants,
      defaultInvitedMembers: defaultInvitedMembers ?? this.defaultInvitedMembers,
      optionalSelectedDefaultMembers: optionalSelectedDefaultMembers ?? this.optionalSelectedDefaultMembers,
      selectedAdditionalStaffMembers: selectedAdditionalStaffMembers ?? this.selectedAdditionalStaffMembers,
      selectedAdditionalCreativePartners: selectedAdditionalCreativePartners ?? this.selectedAdditionalCreativePartners,
      searchText: searchText ?? this.searchText,
      selectedTab: selectedTab ?? this.selectedTab,
      linkGenStatus: linkGenStatus ?? this.linkGenStatus,
      linkGenError:
          clearLinkGenError ? null : (linkGenError ?? this.linkGenError),
    );
  }
}

@immutable
class TimeOfDayValue {
  final int hour;
  final int minute;
  const TimeOfDayValue(this.hour, this.minute);
}

bool _looksLikeUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  if (!uri.hasScheme) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}
