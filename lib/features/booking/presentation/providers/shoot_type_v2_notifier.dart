import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

enum ShootTypeV2Status { initial, loading, success, error, saving }

class ShootTypeV2State {
  final ShootTypeV2Status status;
  final List<Map<String, dynamic>> shootTypes;
  final String? errorMessage;

  const ShootTypeV2State({
    this.status = ShootTypeV2Status.initial,
    this.shootTypes = const [],
    this.errorMessage,
  });

  ShootTypeV2State copyWith({
    ShootTypeV2Status? status,
    List<Map<String, dynamic>>? shootTypes,
    String? errorMessage,
  }) {
    return ShootTypeV2State(
      status: status ?? this.status,
      shootTypes: shootTypes ?? this.shootTypes,
      errorMessage: errorMessage,
    );
  }
}

/// Screen 2 — Shoot Type. Loads the content-agnostic catalogue and saves the
/// selected shoot type by NAME (`shoot_type`), never by id, per contract.
class ShootTypeV2Notifier extends AutoDisposeNotifier<ShootTypeV2State> {
  @override
  ShootTypeV2State build() => const ShootTypeV2State();

  /// Loads the shoot-type catalogue once when the screen opens.
  Future<void> load() async {
    if (state.status == ShootTypeV2Status.loading) return;
    state = state.copyWith(status: ShootTypeV2Status.loading);

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getShootTypesV2();
    result.fold(
      (error) => state = state.copyWith(
        status: ShootTypeV2Status.error,
        errorMessage: error.message,
      ),
      (list) {
        final types = list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
        assert(() {
          if (types.isNotEmpty) {
            debugPrint('[shoot-types-v2] first item: ${types.first}');
          }
          return true;
        }());
        // Honour the catalogue's display_order when present.
        types.sort((a, b) {
          final ao = (a['display_order'] as num?)?.toInt() ?? 0;
          final bo = (b['display_order'] as num?)?.toInt() ?? 0;
          return ao.compareTo(bo);
        });
        state = state.copyWith(
          status: ShootTypeV2Status.success,
          shootTypes: types,
        );
      },
    );
  }

  /// Saves the selected shoot type by name. Returns true on success.
  Future<bool> selectShootType({
    required int bookingId,
    required String shootTypeName,
  }) async {
    state = state.copyWith(status: ShootTypeV2Status.saving);
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateBooking(
      bookingId: bookingId,
      data: {'shoot_type': shootTypeName},
    );
    return result.fold(
      (error) {
        state = state.copyWith(
          status: ShootTypeV2Status.error,
          errorMessage: error.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: ShootTypeV2Status.success);
        return true;
      },
    );
  }
}

final shootTypeV2NotifierProvider =
    NotifierProvider.autoDispose<ShootTypeV2Notifier, ShootTypeV2State>(
      ShootTypeV2Notifier.new,
    );
