import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_type.dart';
import '../../domain/models/update_meeting_input.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'create_meeting_state.dart' show TimeOfDayValue;
import 'edit_meeting_state.dart';
import 'meetings_repository_provider.dart';

/// Loads an existing meeting, hydrates the form, builds the `UpdateMeetingInput`
/// diff on submit. Family-keyed by `meetingId` so two edits don't share state.
class EditMeetingNotifier
    extends AutoDisposeFamilyNotifier<EditMeetingState, String> {
  late final MeetingsRepository _repo;

  @override
  EditMeetingState build(String meetingId) {
    _repo = ref.watch(meetingsRepositoryProvider);
    _load(meetingId);
    return const EditMeetingState(status: EditMeetingStatus.loading);
  }

  Future<void> _load(String meetingId) async {
    try {
      final m = await _repo.getById(meetingId);
      state = _hydrate(m);
    } catch (err) {
      state = state.copyWith(
        status: EditMeetingStatus.loadError,
        error: _messageFor(err),
      );
      if (err is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  Future<void> retryLoad() async {
    if (state.original != null) return;
    state = const EditMeetingState(status: EditMeetingStatus.loading);
    await _load(arg);
  }

  void setTitle(String v) => state = state.copyWith(title: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setDate(DateTime v) => state = state.copyWith(date: v);
  void setStartTime(TimeOfDayValue v) => state = state.copyWith(startTime: v);
  void setEndTime(TimeOfDayValue v) => state = state.copyWith(endTime: v);
  void setLink(String v) => state = state.copyWith(link: v);
  void setReminder(int minutes) =>
      state = state.copyWith(reminderMinutes: minutes);
  void setMeetingType(MeetingType v) => state = state.copyWith(meetingType: v);

  Future<void> submit() async {
    if (!state.canSubmit) return;
    final patch = _buildPatch();
    if (patch.isEmpty) {
      // Nothing changed — treat as a successful no-op so the screen can pop.
      state = state.copyWith(status: EditMeetingStatus.saved);
      return;
    }
    state = state.copyWith(
      status: EditMeetingStatus.submitting,
      clearError: true,
    );
    try {
      await _repo.update(arg, patch);
      state = state.copyWith(status: EditMeetingStatus.saved);
    } catch (err) {
      state = state.copyWith(
        status: EditMeetingStatus.submitError,
        error: _messageFor(err),
      );
      if (err is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  EditMeetingState _hydrate(Meeting m) {
    final start = TimeOfDayValue(m.startAt.hour, m.startAt.minute);
    final end = TimeOfDayValue(m.endAt.hour, m.endAt.minute);
    return EditMeetingState(
      status: EditMeetingStatus.ready,
      original: m,
      title: m.title,
      description: m.description,
      date: DateTime(m.startAt.year, m.startAt.month, m.startAt.day),
      startTime: start,
      endTime: end,
      link: m.link,
      reminderMinutes: m.reminderMinutes,
      meetingType: m.meetingType ?? MeetingType.postProduction,
    );
  }

  /// Diffs current state against baseline `original` to produce a PATCH body.
  UpdateMeetingInput _buildPatch() {
    final base = state.original;
    if (base == null) return const UpdateMeetingInput();
    final d = state.date!;
    final s = state.startTime!;
    final e = state.endTime!;
    final newStart = DateTime(d.year, d.month, d.day, s.hour, s.minute);
    final newEnd = DateTime(d.year, d.month, d.day, e.hour, e.minute);

    String? title = state.title.trim() == base.title
        ? null
        : state.title.trim();
    String? description = state.description.trim() == base.description
        ? null
        : state.description.trim();
    DateTime? startAt = newStart == base.startAt ? null : newStart;
    DateTime? endAt = newEnd == base.endAt ? null : newEnd;
    String? link = state.link.trim() == base.link ? null : state.link.trim();
    int? reminder = state.reminderMinutes == base.reminderMinutes
        ? null
        : state.reminderMinutes;
    MeetingType? meetingType = state.meetingType == base.meetingType
        ? null
        : state.meetingType;

    return UpdateMeetingInput(
      title: title,
      description: description,
      startAt: startAt,
      endAt: endAt,
      link: link,
      reminderMinutes: reminder,
      meetingType: meetingType,
    );
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Could not save meeting';
  }
}

final editMeetingNotifierProvider = NotifierProvider.autoDispose
    .family<EditMeetingNotifier, EditMeetingState, String>(
      EditMeetingNotifier.new,
    );
