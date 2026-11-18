import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum AddOnsStatus { initial, loading, loaded, error }

/// A single add-on from the server catalogue. Rate fields are server-provided;
/// the screen multiplies rate × quantity only for a local cart preview — the
/// authoritative total (fees, card charge, final amount) comes from `/review`.
class AddOn {
  const AddOn({
    required this.slug,
    required this.title,
    required this.description,
    required this.rate,
    required this.rateUnit,
    required this.minQuantity,
    required this.maxQuantity,
  });

  final String slug;
  final String title;
  final String description;
  final double rate;
  final String? rateUnit;
  final int minQuantity;
  final int maxQuantity;

  static AddOn fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
    int toInt(dynamic v, int fallback) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? fallback;
    return AddOn(
      slug: json['slug']?.toString() ?? '',
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? json['subtitle'] ?? '').toString(),
      rate: toDouble(json['rate'] ?? json['price'] ?? json['amount']),
      rateUnit: json['rate_unit']?.toString(),
      minQuantity: toInt(json['min_quantity'], 1),
      maxQuantity: toInt(json['max_quantity'], 99),
    );
  }
}

class AddOnsState {
  final AddOnsStatus status;
  final List<AddOn> catalogue;
  final String? errorMessage;

  const AddOnsState({
    this.status = AddOnsStatus.initial,
    this.catalogue = const [],
    this.errorMessage,
  });

  AddOnsState copyWith({
    AddOnsStatus? status,
    List<AddOn>? catalogue,
    String? errorMessage,
  }) => AddOnsState(
    status: status ?? this.status,
    catalogue: catalogue ?? this.catalogue,
    errorMessage: errorMessage,
  );
}

/// Screen 9 — Optional Add-ons. Loads the catalogue (`GET /bookings/addons`).
/// Selected quantities live in the screen's state and are only submitted later
/// in `/review` and `/quote` as `add_on_items: [{slug, quantity}]`.
class AddOnsNotifier extends Notifier<AddOnsState> {
  @override
  AddOnsState build() => const AddOnsState();

  Future<void> load() async {
    state = state.copyWith(status: AddOnsStatus.loading);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getAddons();
    result.fold(
      (error) => state = state.copyWith(
        status: AddOnsStatus.error,
        errorMessage: error.message,
      ),
      (list) => state = state.copyWith(
        status: AddOnsStatus.loaded,
        catalogue: list
            .whereType<Map>()
            .map((e) => AddOn.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      ),
    );
  }
}

final addOnsNotifierProvider =
    NotifierProvider.autoDispose<AddOnsNotifier, AddOnsState>(
      AddOnsNotifier.new,
    );
