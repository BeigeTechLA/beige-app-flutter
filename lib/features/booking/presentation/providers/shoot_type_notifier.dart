import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import 'booking_providers.dart';

enum ShootTypeStatus { initial, loading, loaded, saving, success, error }

class ShootTypeState {
  final ShootTypeStatus status;
  final List<Map<String, dynamic>> shootTypes;
  final int? bookingId;
  final String? errorMessage;

  const ShootTypeState({
    this.status = ShootTypeStatus.initial,
    this.shootTypes = const [],
    this.bookingId,
    this.errorMessage,
  });

  ShootTypeState copyWith({
    ShootTypeStatus? status,
    List<Map<String, dynamic>>? shootTypes,
    int? bookingId,
    String? errorMessage,
  }) {
    return ShootTypeState(
      status: status ?? this.status,
      shootTypes: shootTypes ?? this.shootTypes,
      bookingId: bookingId ?? this.bookingId,
      errorMessage: errorMessage,
    );
  }
}

class ShootTypeNotifier
    extends AutoDisposeFamilyNotifier<ShootTypeState, int> {
  bool _stepCompleted = false;

  @override
  ShootTypeState build(int contentTypeId) {
    // --- Booking Analytics: Drop-off tracking for Step 2 ---
    ref.onDispose(() {
      if (!_stepCompleted && state.bookingId != null) {
        AnalyticsService.logEvent(AnalyticsEvents.bookingAbandoned, params: {
          'booking_id': state.bookingId!,
          'last_step': 'shoot_type',
          'step_number': 2,
        });
      }
    });
    _fetchShootTypes(contentTypeId);
    return const ShootTypeState(status: ShootTypeStatus.loading);
  }

  Future<void> _fetchShootTypes(int contentTypeId) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getShootTypes(contentTypeId: contentTypeId);

    result.fold(
      (error) => state = state.copyWith(
        status: ShootTypeStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        final types = data.map<Map<String, dynamic>>((e) {
          return {
            'id': e['shoot_type_id'],
            'name': e['name'],
            'image': e['image_url'],
            'content_type': e['content_type'],
            'tags': _parseTags(e['tags']),
          };
        }).toList();

        state = state.copyWith(
          status: ShootTypeStatus.loaded,
          shootTypes: types,
        );
      },
    );
  }

  Future<void> selectShootType({
    required int bookingId,
    required int contentTypeId,
    required int shootTypeId,
    required String shootTypeName,
  }) async {
    state = state.copyWith(status: ShootTypeStatus.saving);

    final repo = ref.read(bookingRepositoryProvider);
    final body = {
      'project_name': shootTypeName,
      'content_type': contentTypeId,
      'shoot_type_id': shootTypeId,
      'specialty_id': 22,
    };

    final result = await repo.updateBooking(
      bookingId: bookingId,
      data: body,
    );

    result.fold(
      (error) => state = state.copyWith(
        status: ShootTypeStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        _stepCompleted = true;
        // --- Booking Analytics: Step 2 — Shoot type selected ---
        AnalyticsService.logEvent(AnalyticsEvents.bookingStepShootType, params: {
          'booking_id': bookingId,
          'shoot_type': shootTypeName,
          'step_number': 2,
        });
        state = state.copyWith(
          status: ShootTypeStatus.success,
          bookingId: data['data']?['booking_id'] as int?,
        );
      },
    );
  }

  List<dynamic> _parseTags(dynamic tags) {
    if (tags == null) return [];
    try {
      if (tags is String) return jsonDecode(tags);
      if (tags is List) return tags;
    } catch (_) {}
    return [];
  }
}

final shootTypeNotifierProvider = NotifierProvider.autoDispose
    .family<ShootTypeNotifier, ShootTypeState, int>(
  ShootTypeNotifier.new,
);
