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
  final EditingStatus status;
  final List<EditOption> photoEditTypes;
  final List<EditOption> videoEditTypes;
  final String? errorMessage;

  const EditingState({
    this.status = EditingStatus.initial,
    this.photoEditTypes = const [],
    this.videoEditTypes = const [],
    this.errorMessage,
  });

  EditingState copyWith({
    EditingStatus? status,
    List<EditOption>? photoEditTypes,
    List<EditOption>? videoEditTypes,
    String? errorMessage,
  }) => EditingState(
    status: status ?? this.status,
    photoEditTypes: photoEditTypes ?? this.photoEditTypes,
    videoEditTypes: videoEditTypes ?? this.videoEditTypes,
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

  Future<void> load({required String contentType}) async {
    state = state.copyWith(status: EditingStatus.loading);
    final repo = ref.read(bookingRepositoryProvider);
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
        );
      },
    );
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
