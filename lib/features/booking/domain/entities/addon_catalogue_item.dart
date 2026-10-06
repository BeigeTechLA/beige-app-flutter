import 'package:flutter/foundation.dart';

/// A catalogue add-on from `GET /bookings/addons` (active web-v4 set). Prices
/// and labels are owned by the runtime catalogue — never hardcode Figma prices
/// or product keys. [slug] is the key sent back in `add_on_items`.
@immutable
class AddonCatalogueItem {
  const AddonCatalogueItem({
    required this.slug,
    required this.title,
    this.description,
    this.price,
    this.priceLabel,
  });

  final String slug;
  final String title;
  final String? description;

  /// Numeric price where provided; display uses [priceLabel] when present.
  final num? price;
  final String? priceLabel;

  factory AddonCatalogueItem.fromJson(Map<String, dynamic> json) =>
      AddonCatalogueItem(
        slug: (json['slug'] ?? '').toString(),
        title: (json['title'] ?? json['name'] ?? '').toString(),
        description: json['description']?.toString(),
        price: json['price'] as num?,
        priceLabel: (json['price_label'] ?? json['price_text'])?.toString(),
      );

  static List<AddonCatalogueItem> listFrom(Object? data) {
    final raw = data is Map<String, dynamic> ? data['data'] : data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AddonCatalogueItem.fromJson)
        .toList();
  }
}
