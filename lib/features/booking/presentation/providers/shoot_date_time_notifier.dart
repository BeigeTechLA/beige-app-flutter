import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import 'booking_providers.dart';

enum ShootDateTimeStatus { initial, loading, loaded, saving, success, error }

class ShootDateTimeState {
  final ShootDateTimeStatus status;
  final List<dynamic> videoEditTypes;
  final List<dynamic> photoEditTypes;
  final String? errorMessage;

  const ShootDateTimeState({
    this.status = ShootDateTimeStatus.initial,
    this.videoEditTypes = const [],
    this.photoEditTypes = const [],
    this.errorMessage,
  });

  ShootDateTimeState copyWith({
    ShootDateTimeStatus? status,
    List<dynamic>? videoEditTypes,
    List<dynamic>? photoEditTypes,
    String? errorMessage,
  }) {
    return ShootDateTimeState(
      status: status ?? this.status,
      videoEditTypes: videoEditTypes ?? this.videoEditTypes,
      photoEditTypes: photoEditTypes ?? this.photoEditTypes,
      errorMessage: errorMessage,
    );
  }
}

class ShootDateTimeNotifier
    extends AutoDisposeFamilyNotifier<ShootDateTimeState, int> {
  @override
  ShootDateTimeState build(int shootTypeId) {
    _fetchEditTypes(shootTypeId);
    return const ShootDateTimeState(status: ShootDateTimeStatus.loading);
  }

  Future<void> _fetchEditTypes(int shootTypeId) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getEditTypes(shootTypeId: shootTypeId);

    result.fold(
      (error) => state = state.copyWith(
        status: ShootDateTimeStatus.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: ShootDateTimeStatus.loaded,
        videoEditTypes: data['video_edit_types'] as List? ?? [],
        photoEditTypes: data['photo_edit_types'] as List? ?? [],
      ),
    );
  }

  Future<void> saveBookingTime({
    required int bookingId,
    required Map<String, dynamic> payload,
  }) async {
    state = state.copyWith(status: ShootDateTimeStatus.saving);

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.updateBookingTime(
      bookingId: bookingId,
      data: payload,
    );

    result.fold(
      (error) => state = state.copyWith(
        status: ShootDateTimeStatus.error,
        errorMessage: error.message,
      ),
      (_) {
        AnalyticsService.logEvent(AnalyticsEvents.bookingStepDateTime, params: {
          'booking_id': bookingId,
        });
        state = state.copyWith(status: ShootDateTimeStatus.success);
      },
    );
  }
}

final shootDateTimeNotifierProvider = NotifierProvider.autoDispose
    .family<ShootDateTimeNotifier, ShootDateTimeState, int>(
  ShootDateTimeNotifier.new,
);
