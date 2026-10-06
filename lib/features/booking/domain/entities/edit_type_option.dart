import 'package:flutter/foundation.dart';

/// A selectable edit option from `GET /bookings/edit-types`. The [key] is the
/// exact wire key sent back in `video_edit_types` / `photo_edit_types`.
@immutable
class EditTypeOption {
  const EditTypeOption({required this.key, required this.label, this.quantity});

  final String key;
  final String label;

  /// Included/selected quantity where the catalogue supplies it (optional).
  final int? quantity;

  factory EditTypeOption.fromJson(Map<String, dynamic> json) => EditTypeOption(
    key: (json['key'] ?? '').toString(),
    label: (json['label'] ?? json['name'] ?? '').toString(),
    quantity: (json['quantity'] as num?)?.toInt(),
  );
}

/// Full edit-types catalogue split into video + photo options. Show the
/// relevant lists based on the selected content type.
@immutable
class EditTypesCatalogue {
  const EditTypesCatalogue({
    this.videoEditTypes = const [],
    this.photoEditTypes = const [],
  });

  final List<EditTypeOption> videoEditTypes;
  final List<EditTypeOption> photoEditTypes;

  factory EditTypesCatalogue.fromData(Map<String, dynamic> data) {
    List<EditTypeOption> parse(String key) {
      final raw = data[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(EditTypeOption.fromJson)
          .toList();
    }

    return EditTypesCatalogue(
      videoEditTypes: parse('video_edit_types'),
      photoEditTypes: parse('photo_edit_types'),
    );
  }
}
