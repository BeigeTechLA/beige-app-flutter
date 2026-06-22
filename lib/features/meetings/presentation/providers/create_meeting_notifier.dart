import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/models/create_meeting_input.dart';
import '../../domain/models/meeting_category.dart';
import '../../domain/models/meeting_participant.dart';
import '../../domain/models/meeting_platform.dart';
import '../../domain/models/shoot_participant_option.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'create_meeting_state.dart';
import 'meetings_repository_provider.dart';

class CreateMeetingNotifier extends AutoDisposeNotifier<CreateMeetingState> {
  late final MeetingsRepository _repo;

  @override
  CreateMeetingState build() {
    _repo = ref.watch(meetingsRepositoryProvider);
    return const CreateMeetingState();
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);

  /// Selects a shoot from the user's bookings. `shootId` is required for
  /// `isValid`; `name` is the display label persisted only for UI rendering.
  void setShoot({required int shootId, required String name}) {
    state = state.copyWith(shootId: shootId, project: name);
  }

  void setDate(DateTime v) => state = state.copyWith(date: v);
  void setStartTime(TimeOfDayValue v) => state = state.copyWith(startTime: v);
  void setEndTime(TimeOfDayValue v) => state = state.copyWith(endTime: v);
  void setPlatform(MeetingPlatform v) => state = state.copyWith(platform: v);
  void setLink(String v) => state = state.copyWith(link: v);
  void setReminder(int minutes) =>
      state = state.copyWith(reminderMinutes: minutes);

  /// Replaces the invited-participants list. Picker sheet returns the full
  /// selected set so the notifier just mirrors it.
  void setParticipants(List<ShootParticipantOption> picked) {
    // Deduplicate by id — `ShootParticipantOption.==` is id-based, so toSet
    // collapses duplicates while preserving the picked order.
    final unique = <ShootParticipantOption>{};
    final ordered = <ShootParticipantOption>[];
    for (final p in picked) {
      if (unique.add(p)) ordered.add(p);
    }
    state = state.copyWith(invitedParticipants: ordered);
  }

  void removeParticipant(String id) {
    state = state.copyWith(
      invitedParticipants:
          state.invitedParticipants.where((p) => p.id != id).toList(),
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
        participants: state.invitedParticipants
            .map((p) => MeetingParticipant(
                  id: p.id,
                  name: p.name,
                  avatarUrl: p.avatarUrl,
                ))
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
}

final createMeetingNotifierProvider =
    AutoDisposeNotifierProvider<CreateMeetingNotifier, CreateMeetingState>(
  CreateMeetingNotifier.new,
);
