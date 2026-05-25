import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import 'booking_providers.dart';

enum CrewRecommendationStatus { initial, loading, loaded, error }

class CrewRecommendationState {
  final CrewRecommendationStatus status;
  final Map<String, dynamic> data;
  final String? errorMessage;

  const CrewRecommendationState({
    this.status = CrewRecommendationStatus.initial,
    this.data = const {},
    this.errorMessage,
  });

  CrewRecommendationState copyWith({
    CrewRecommendationStatus? status,
    Map<String, dynamic>? data,
    String? errorMessage,
  }) {
    return CrewRecommendationState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }
}

class CrewRecommendationNotifier
    extends AutoDisposeFamilyNotifier<CrewRecommendationState, int> {
  bool _stepCompleted = false;

  @override
  CrewRecommendationState build(int bookingId) {
    // --- Booking Analytics: Drop-off tracking for Step 5 ---
    ref.onDispose(() {
      if (!_stepCompleted) {
        AnalyticsService.logEvent(AnalyticsEvents.bookingAbandoned, params: {
          'booking_id': bookingId,
          'last_step': 'crew_size',
          'step_number': 5,
        });
      }
    });
    _fetchRecommendation(bookingId);
    return const CrewRecommendationState(
      status: CrewRecommendationStatus.loading,
    );
  }

  Future<void> _fetchRecommendation(int bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getCrewRecommendation(bookingId: bookingId);

    result.fold(
      (error) => state = state.copyWith(
        status: CrewRecommendationStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        // --- Booking Analytics: Step 5 — Crew size recommendation viewed ---
        final crewSize = (data['crew_requirements'] as List?)?.length ?? 0;
        AnalyticsService.logEvent(AnalyticsEvents.bookingStepCrewSize, params: {
          'booking_id': bookingId,
          'recommended_crew_size': crewSize,
          'step_number': 5,
        });
        state = state.copyWith(
          status: CrewRecommendationStatus.loaded,
          data: data,
        );
      },
    );
  }

  void markStepCompleted() {
    _stepCompleted = true;
  }
}

final crewRecommendationNotifierProvider = NotifierProvider.autoDispose
    .family<CrewRecommendationNotifier, CrewRecommendationState, int>(
  CrewRecommendationNotifier.new,
);
