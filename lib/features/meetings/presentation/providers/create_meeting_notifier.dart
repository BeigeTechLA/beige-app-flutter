import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/session/session_store.dart';
import '../../../booking/presentation/providers/booking_providers.dart';
import '../../domain/models/create_meeting_input.dart';
import '../../domain/models/directory_participant.dart';
import '../../domain/models/generate_meet_link_input.dart';
import '../../domain/models/meeting_category.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/meeting_type.dart';
import '../../domain/models/shoot_option.dart';
import '../../domain/models/shoot_participant_option.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'create_meeting_state.dart';
import 'meetings_repository_provider.dart';

class CreateMeetingNotifier extends AutoDisposeNotifier<CreateMeetingState> {
  late final MeetingsRepository _repo;
  late final SessionStore _session;

  @override
  CreateMeetingState build() {
    _repo = ref.watch(meetingsRepositoryProvider);
    _session = ref.watch(sessionStoreProvider);
    return CreateMeetingState.withDefaultDateTime();
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);

  /// Selects a shoot/project option. Parses `defaultMembers`, seeds the
  /// default invited list, and pre-selects all optional members (user can
  /// deselect from the UI).
  void setShoot(ShootOption opt) {
    final List<DirectoryParticipant> defaultParticipants = [];
    for (final member in opt.defaultMembers) {
      if (member is Map) {
        final parsedJson = Map<String, dynamic>.from(member);
        defaultParticipants.add(
          DirectoryParticipant.fromJson(parsedJson, isDefault: true),
        );
      }
    }
    final optionalPreselected = defaultParticipants
        .where((p) => p.isOptional)
        .toList(growable: false);

    final projectName = opt.title.split(' (Booking #').first.trim();
    final autoTitle = projectName.isEmpty ? '' : '$projectName Catch Up';

    state = state.copyWith(
      shootId: opt.id,
      project: opt.title,
      title: autoTitle,
      defaultInvitedMembers: defaultParticipants,
      optionalSelectedDefaultMembers: optionalPreselected,
      selectedAdditionalStaffMembers: const [],
      selectedAdditionalCreativePartners: const [],
    );
  }

  /// Sets date/time/link/reminder values
  void setDate(DateTime v) => state = state.copyWith(date: v);

  /// Sets start time and auto-shifts end time to +60 minutes (rolls into
  /// next day only via minute math — caller enforces same-day date).
  void setStartTime(TimeOfDayValue v) {
    final totalEnd = v.hour * 60 + v.minute + 60;
    final endHour = (totalEnd ~/ 60) % 24;
    final endMinute = totalEnd % 60;
    state = state.copyWith(
      startTime: v,
      endTime: TimeOfDayValue(endHour, endMinute),
    );
  }

  void setEndTime(TimeOfDayValue v) => state = state.copyWith(endTime: v);
  void setPlatform(MeetingPlatform v) => state = state.copyWith(platform: v);
  void setMeetingType(MeetingType v) => state = state.copyWith(meetingType: v);
  void setLink(String v) => state = state.copyWith(link: v);
  void setReminder(int minutes) =>
      state = state.copyWith(reminderMinutes: minutes);

  /// Toggles selection of optional default members. No-op for mandatory
  /// (`is_optional == false`) rows — they stay selected by design.
  void toggleOptionalDefaultMember(DirectoryParticipant member) {
    if (!member.isOptional) return;
    final list = List<DirectoryParticipant>.from(
      state.optionalSelectedDefaultMembers,
    );
    if (list.contains(member)) {
      list.remove(member);
    } else {
      list.add(member);
    }
    state = state.copyWith(optionalSelectedDefaultMembers: list);
  }

  /// Fetches directory participants (all staff and creative partners) from external-chat/directory
  Future<void> fetchDirectory() async {
    if (state.directoryLoading) return;
    state = state.copyWith(directoryLoading: true, clearDirectoryError: true);

    final bookingRepo = ref.read(bookingRepositoryProvider);
    final result = await bookingRepo.getBookingParticipants(
      bookingId: state.shootId ?? 0,
    );

    result.fold(
      (e) => state = state.copyWith(
        directoryLoading: false,
        directoryError: e.message,
      ),
      (list) {
        final List<DirectoryParticipant> participants = [];
        for (final item in list) {
          if (item is Map) {
            final parsedJson = Map<String, dynamic>.from(item);
            participants.add(
              DirectoryParticipant.fromJson(parsedJson, isDefault: false),
            );
          }
        }
        state = state.copyWith(
          directoryLoading: false,
          directoryParticipants: participants,
        );
      },
    );
  }

  void setSearchText(String v) {
    state = state.copyWith(searchText: v);
  }

  void setSelectedTab(String v) {
    state = state.copyWith(selectedTab: v);
  }

  /// Toggles selection of staff / CP in the bottom sheet selection
  void toggleAdditionalMember(DirectoryParticipant member) {
    if (member.type == 'creativePartner') {
      final list = List<DirectoryParticipant>.from(
        state.selectedAdditionalCreativePartners,
      );
      if (list.contains(member)) {
        list.remove(member);
      } else {
        list.add(member);
      }
      state = state.copyWith(selectedAdditionalCreativePartners: list);
    } else {
      final list = List<DirectoryParticipant>.from(
        state.selectedAdditionalStaffMembers,
      );
      if (list.contains(member)) {
        list.remove(member);
      } else {
        list.add(member);
      }
      state = state.copyWith(selectedAdditionalStaffMembers: list);
    }
  }

  /// Removes an additional member from selected additional lists (triggered by chip's close button)
  void removeAdditionalMember(String id) {
    state = state.copyWith(
      selectedAdditionalStaffMembers: state.selectedAdditionalStaffMembers
          .where((p) => p.id != id)
          .toList(),
      selectedAdditionalCreativePartners: state
          .selectedAdditionalCreativePartners
          .where((p) => p.id != id)
          .toList(),
    );
  }

  /// Kept for backward compatibility with tests/external components
  void setParticipants(List<ShootParticipantOption> picked) {
    final unique = <ShootParticipantOption>{};
    final ordered = <ShootParticipantOption>[];
    for (final p in picked) {
      if (unique.add(p)) ordered.add(p);
    }
    state = state.copyWith(invitedParticipants: ordered);
  }

  void removeParticipant(String id) {
    state = state.copyWith(
      invitedParticipants: state.invitedParticipants
          .where((p) => p.id != id)
          .toList(),
    );
  }

  Future<void> submit() async {
    if (!state.isValid) return;
    state = state.copyWith(
      status: CreateMeetingSubmitStatus.submitting,
      clearError: true,
    );
    try {
      final d = state.date!;
      final s = state.startTime!;
      final e = state.endTime!;
      final input = CreateMeetingInput(
        title: state.title.trim(),
        description: state.description.trim(),
        project: state.project.trim(),
        shootId: state.shootId,
        startAt: DateTime(d.year, d.month, d.day, s.hour, s.minute),
        endAt: DateTime(d.year, d.month, d.day, e.hour, e.minute),
        platform: state.platform,
        link: state.link.trim(),
        reminderMinutes: state.reminderMinutes,
        category: MeetingCategory.commercial,
        meetingType: state.meetingType,
        participants: state.selectedParticipants
            .map(
              (p) => MeetingParticipant(
                id: p.id,
                name: p.name,
                avatarUrl: p.avatarUrl,
                role: p.role,
              ),
            )
            .toList(),
      );
      final created = await _repo.create(input);
      state = state.copyWith(
        status: CreateMeetingSubmitStatus.success,
        created: created,
      );
    } catch (err) {
      state = state.copyWith(
        status: CreateMeetingSubmitStatus.error,
        error: _messageFor(err),
      );
      if (err is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Could not create meeting';
  }

  /// Calls backend to generate a Google Meet link and writes it into
  /// `state.link`. Guarded by [CreateMeetingState.canGenerateMeetLink] — the
  /// UI wraps the Generate button in the same gate, this is defense in depth.
  ///
  /// On success: `state.link` updated, status = success. UI listens and
  /// mirrors into the text controller.
  /// On error (including `authUrl` OAuth response): status = error with a
  /// generic message per product decision — no in-app Google OAuth flow.
  Future<void> generateMeetLink() async {
    if (!state.canGenerateMeetLink) return;
    if (state.linkGenStatus == MeetLinkGenerationStatus.loading) return;

    state = state.copyWith(
      linkGenStatus: MeetLinkGenerationStatus.loading,
      clearLinkGenError: true,
    );

    try {
      final user = await _session.readUser();
      final userId = user?.id ?? '';
      final d = state.date!;
      final s = state.startTime!;
      final e = state.endTime!;
      final startAt = DateTime(d.year, d.month, d.day, s.hour, s.minute);
      final endAt = DateTime(d.year, d.month, d.day, e.hour, e.minute);

      final link = await _repo.generateMeetLink(
        GenerateMeetLinkInput(
          userId: userId,
          summary: state.title.trim(),
          description: state.description.trim(),
          startAt: startAt,
          endAt: endAt,
          orderId: state.shootId!,
        ),
      );

      state = state.copyWith(
        link: link,
        linkGenStatus: MeetLinkGenerationStatus.success,
      );
    } on AppException {
      state = state.copyWith(
        linkGenStatus: MeetLinkGenerationStatus.error,
        linkGenError: 'Something went wrong. Please try again after sometime.',
      );
    }
  }

  /// Resets the generation status/error without touching `state.link`, so a
  /// previously generated link survives the error dismissal and still flows
  /// into the Create Meeting POST body as `meetLink`.
  void clearLinkGenError() {
    state = state.copyWith(
      linkGenStatus: MeetLinkGenerationStatus.idle,
      clearLinkGenError: true,
    );
  }
}

final createMeetingNotifierProvider =
    AutoDisposeNotifierProvider<CreateMeetingNotifier, CreateMeetingState>(
      CreateMeetingNotifier.new,
    );
