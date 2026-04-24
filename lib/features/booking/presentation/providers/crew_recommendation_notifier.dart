import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  CrewRecommendationState build(int bookingId) {
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
      (data) => state = state.copyWith(
        status: CrewRecommendationStatus.loaded,
        data: data,
      ),
    );
  }
}

final crewRecommendationNotifierProvider = NotifierProvider.autoDispose
    .family<CrewRecommendationNotifier, CrewRecommendationState, int>(
  CrewRecommendationNotifier.new,
);
