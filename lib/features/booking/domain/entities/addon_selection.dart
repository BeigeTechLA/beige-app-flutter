import 'package:flutter/foundation.dart';

/// A single chosen add-on: catalogue [slug] + [quantity]. Stored in frontend
/// state only until `/review` and `/quote`.
@immutable
class AddonSelectionItem {
  const AddonSelectionItem({required this.slug, required this.quantity});

  final String slug;
  final int quantity;

  Map<String, dynamic> toJson() => {'slug': slug, 'quantity': quantity};

  factory AddonSelectionItem.fromJson(Map<String, dynamic> json) =>
      AddonSelectionItem(
        slug: json['slug'] as String,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}

/// The full add-on selection for a booking. Builds the `add_on_items` array
/// shared by `/review` and `/quote`. Sends `[]` when nothing is selected.
@immutable
class AddonSelection {
  const AddonSelection({this.items = const []});

  final List<AddonSelectionItem> items;

  bool get isEmpty => items.isEmpty;

  /// `add_on_items` array, used identically for both `/review` and `/quote`.
  List<Map<String, dynamic>> toAddOnItems() =>
      items.map((e) => e.toJson()).toList();

  int quantityForSlug(String slug) {
    for (final item in items) {
      if (item.slug == slug) return item.quantity;
    }
    return 0;
  }

  /// Returns a copy with [slug] set to [quantity]. Quantity <= 0 removes it.
  AddonSelection withQuantity(String slug, int quantity) {
    final next = items.where((e) => e.slug != slug).toList();
    if (quantity > 0) {
      next.add(AddonSelectionItem(slug: slug, quantity: quantity));
    }
    return AddonSelection(items: next);
  }

  /// Stable fingerprint for cache/change detection between `/review` and
  /// `/quote` and for review refresh gating. Order-independent.
  String get fingerprint {
    final sorted = [...items]..sort((a, b) => a.slug.compareTo(b.slug));
    return sorted.map((e) => '${e.slug}:${e.quantity}').join(',');
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory AddonSelection.fromJson(Map<String, dynamic> json) => AddonSelection(
    items:
        (json['items'] as List?)
            ?.map(
              (e) => AddonSelectionItem.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        const [],
  );
}
