import 'package:flutter/foundation.dart';

/// Edit choices captured on Screen 7. Builds the `PUT /bookings/:id/edits`
/// payload. Keys are the exact strings returned by the edit-types catalogue —
/// never invent or rename them.
///
/// The PDF does not define how quantities above one are encoded. Until a
/// verified example exists, only the boolean + key arrays are sent; quantity
/// controls must not assume repeated keys are accepted.
@immutable
class EditSelection {
  const EditSelection({
    this.editsNeeded = false,
    this.videoEditTypes = const [],
    this.photoEditTypes = const [],
  });

  final bool editsNeeded;
  final List<String> videoEditTypes;
  final List<String> photoEditTypes;

  /// For "No", send `edits_needed:false` and both arrays empty.
  Map<String, dynamic> toEditsPayload() => {
    'edits_needed': editsNeeded,
    'video_edit_types': editsNeeded ? videoEditTypes : <String>[],
    'photo_edit_types': editsNeeded ? photoEditTypes : <String>[],
  };

  EditSelection copyWith({
    bool? editsNeeded,
    List<String>? videoEditTypes,
    List<String>? photoEditTypes,
  }) => EditSelection(
    editsNeeded: editsNeeded ?? this.editsNeeded,
    videoEditTypes: videoEditTypes ?? this.videoEditTypes,
    photoEditTypes: photoEditTypes ?? this.photoEditTypes,
  );

  Map<String, dynamic> toJson() => {
    'editsNeeded': editsNeeded,
    'videoEditTypes': videoEditTypes,
    'photoEditTypes': photoEditTypes,
  };

  factory EditSelection.fromJson(Map<String, dynamic> json) => EditSelection(
    editsNeeded: json['editsNeeded'] as bool? ?? false,
    videoEditTypes:
        (json['videoEditTypes'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    photoEditTypes:
        (json['photoEditTypes'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
  );
}
