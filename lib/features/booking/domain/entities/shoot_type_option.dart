import 'package:flutter/foundation.dart';

/// A shoot-type card from `GET /bookings/shoot-types`. The catalogue is shared
/// across content types. Save the exact [name] on continue — never a numeric
/// id.
@immutable
class ShootTypeOption {
  const ShootTypeOption({
    required this.name,
    this.description,
    this.imageUrl,
    this.displayOrder = 0,
  });

  final String name;
  final String? description;
  final String? imageUrl;
  final int displayOrder;

  factory ShootTypeOption.fromJson(Map<String, dynamic> json) =>
      ShootTypeOption(
        name: (json['name'] ?? json['shoot_type'] ?? '').toString(),
        description: (json['description'] ?? json['subtitle'])?.toString(),
        imageUrl: (json['image'] ?? json['image_url'])?.toString(),
        displayOrder: (json['display_order'] ?? json['order'] as num?)
                ?.toInt() ??
            0,
      );

  /// Parses the `data` list of a shoot-types response, sorted by display
  /// order. Tolerant of the exact response envelope (list or `{data: [...]}`).
  static List<ShootTypeOption> listFrom(Object? data) {
    final raw = data is Map<String, dynamic> ? data['data'] : data;
    if (raw is! List) return const [];
    final out = raw
        .whereType<Map<String, dynamic>>()
        .map(ShootTypeOption.fromJson)
        .toList();
    out.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return out;
  }
}
