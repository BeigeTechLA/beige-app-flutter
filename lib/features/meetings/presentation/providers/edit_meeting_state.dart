import 'package:flutter/foundation.dart';

import '../../domain/models/meeting.dart';
import 'create_meeting_state.dart' show TimeOfDayValue;

/// Lifecycle of the edit-meeting form.
///
/// - `loading` — initial fetch of the meeting payload.
/// - `loadError` — fetch failed; show retry.
/// - `ready` — form hydrated, user editing.
/// - `submitting` — PATCH in flight.
/// - `submitError` — PATCH failed; stay on form with snackbar.
/// - `saved` — PATCH succeeded; UI pops + invalidates list.
enum EditMeetingStatus {
  loading,
  loadError,
  ready,
  submitting,
  submitError,
  saved,
}

@immutable
class EditMeetingState {
  final EditMeetingStatus status;

  /// Source-of-truth meeting fetched from `getById`. Used as the diff baseline
  /// when building the `UpdateMeetingInput` patch.
  final Meeting? original;

  final String title;
  final String description;
  final DateTime? date;
  final TimeOfDayValue? startTime;
  final TimeOfDayValue? endTime;
  final String link;
  final int reminderMinutes;

  final String? error;

  const EditMeetingState({
    this.status = EditMeetingStatus.loading,
    this.original,
    this.title = '',
    this.description = '',
    this.date,
    this.startTime,
    this.endTime,
    this.link = '',
    this.reminderMinutes = 15,
    this.error,
  });

  bool get hasTitle => title.trim().isNotEmpty;
  bool get hasDate => date != null;
  bool get hasTimes => startTime != null && endTime != null;
  bool get hasLink => link.trim().isNotEmpty && _looksLikeUrl(link.trim());

  bool get endAfterStart {
    if (!hasTimes) return false;
    final s = startTime!;
    final e = endTime!;
    return (e.hour * 60 + e.minute) > (s.hour * 60 + s.minute);
  }

  /// Form valid + at least one field changed vs. baseline.
  bool get canSubmit =>
      status == EditMeetingStatus.ready &&
      hasTitle &&
      hasDate &&
      hasTimes &&
      endAfterStart &&
      hasLink;

  EditMeetingState copyWith({
    EditMeetingStatus? status,
    Meeting? original,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDayValue? startTime,
    TimeOfDayValue? endTime,
    String? link,
    int? reminderMinutes,
    String? error,
    bool clearError = false,
  }) {
    return EditMeetingState(
      status: status ?? this.status,
      original: original ?? this.original,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      link: link ?? this.link,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

bool _looksLikeUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return false;
  if (!uri.hasScheme) return false;
  return uri.scheme == 'http' || uri.scheme == 'https';
}
