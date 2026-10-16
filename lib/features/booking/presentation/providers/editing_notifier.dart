import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum EditingStatus { initial, loading, loaded, saving, success, error }

/// A single server-owned edit option. [key] is the exact API key (never
/// invented client-side); [value] is the display label; [note] is an optional
/// sub-label.
class EditOption {
  const EditOption({required this.key, required this.value, this.note});

  final String key;
  final String value;
  final String? note;

  static EditOption fromJson(Map<String, dynamic> json) => EditOption(
    key: json['key']?.toString() ?? '',
    value: json['value']?.toString() ?? '',
    note: json['note']?.toString(),
  );
}

class EditingState {
  static const int defaultDurationHours = 1;
  final EditingStatus status;
  final List<EditOption> photoEditTypes;
  final List<EditOption> videoEditTypes;

  /// Whole-hour booked duration (rounded up) derived from the booking's time
  /// data. Drives the included free-photo count (50/hour) and the duration
  /// label. Defaults to one hour until booking time is available.
  final int durationHours;
  final String? errorMessage;

  const EditingState({
    this.status = EditingStatus.initial,
    this.photoEditTypes = const [],
    this.videoEditTypes = const [],
    this.durationHours = defaultDurationHours,
    this.errorMessage,
  });

  EditingState copyWith({
    EditingStatus? status,
    List<EditOption>? photoEditTypes,
    List<EditOption>? videoEditTypes,
    int? durationHours,
    String? errorMessage,
  }) => EditingState(
    status: status ?? this.status,
    photoEditTypes: photoEditTypes ?? this.photoEditTypes,
    videoEditTypes: videoEditTypes ?? this.videoEditTypes,
    durationHours: durationHours ?? this.durationHours,
    errorMessage: errorMessage,
  );
}

/// Screen 7 — Editing. Loads the server-owned edit catalogue for the booking's
/// content type (`GET /edit-types?content_type`) and saves the selection via
/// `PUT /bookings/:id/edits`. Edit keys are sent verbatim; the app never
/// renames or invents them, and never computes included-photo counts (those are
/// server-calculated and surfaced on the Review screen).
class EditingNotifier extends AutoDisposeNotifier<EditingState> {
  @override
  EditingState build() => const EditingState();

  Future<void> load({
    required int bookingId,
    required String contentType,
  }) async {
    state = state.copyWith(status: EditingStatus.loading);
    final repo = ref.read(bookingRepositoryProvider);

    // Booked duration drives the included free-photo count (50/hour). Fetched
    // alongside the edit catalogue; missing time uses a one-hour estimate.
    final timeResult = await repo.getBookingTime(bookingId: bookingId);
    final durationHours = timeResult.fold(
      (_) => 0,
      (data) => _durationHoursFrom(data),
    );

    final result = await repo.getEditTypesV2(contentType: contentType);
    result.fold(
      (error) => state = state.copyWith(
        status: EditingStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        state = state.copyWith(
          status: EditingStatus.loaded,
          photoEditTypes: _parse(data['photo_edit_types']),
          videoEditTypes: _parse(data['video_edit_types']),
          durationHours: durationHours > 0
              ? durationHours
              : EditingState.defaultDurationHours,
        );
      },
    );
  }

  /// Derives whole-hour booked duration from a `GET /bookings/:id/time`
  /// response. Tolerant of shape: top-level `duration_hours`, else summed
  /// `booking_days[].duration_hours`, else computed from `start_time`/`end_time`
  /// (single-day) or each day's times. Rounds up to whole hours.
  int _durationHoursFrom(Map<String, dynamic> data) {
    final top = _asDouble(data['duration_hours']);
    if (top > 0) return top.ceil();

    final days = data['booking_days'];
    if (days is List && days.isNotEmpty) {
      var hours = 0.0;
      for (final d in days) {
        if (d is! Map) continue;
        final dh = _asDouble(d['duration_hours']);
        hours += dh > 0 ? dh : _hoursBetween(d['start_time'], d['end_time']);
      }
      return hours.ceil();
    }

    return _hoursBetween(data['start_time'], data['end_time']).ceil();
  }

  /// Fractional hours between two `HH:mm` / `HH:mm:ss` strings. 0 if unparsable
  /// or non-positive (overnight spans are treated as 0 here — booking times are
  /// same-day).
  double _hoursBetween(dynamic startRaw, dynamic endRaw) {
    final start = _minutesOfDay(startRaw);
    final end = _minutesOfDay(endRaw);
    if (start == null || end == null) return 0;
    final diff = end - start;
    return diff > 0 ? diff / 60.0 : 0;
  }

  int? _minutesOfDay(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  List<EditOption> _parse(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => EditOption.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<bool> save({
    required int bookingId,
    required bool editsNeeded,
    required List<String> photoEditTypes,
    required List<String> videoEditTypes,
  }) async {
    state = state.copyWith(status: EditingStatus.saving);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateEdits(
      bookingId: bookingId,
      data: {
        'edits_needed': editsNeeded ? 1 : 0,
        'photo_edit_types': editsNeeded ? photoEditTypes : const <String>[],
        'video_edit_types': editsNeeded ? videoEditTypes : const <String>[],
      },
    );
    return result.fold(
      (error) {
        state = state.copyWith(
          status: EditingStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: EditingStatus.success);
        return true;
      },
    );
  }
}

final editingNotifierProvider =
    NotifierProvider.autoDispose<EditingNotifier, EditingState>(
      EditingNotifier.new,
    );
