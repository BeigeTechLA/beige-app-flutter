import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shoot_providers.dart';

enum ShootEditReviewStatus {
  initial,
  loading,
  loaded,
  confirming,
  confirmed,
  error,
}

class ShootEditReviewState {
  final ShootEditReviewStatus status;
  final Map<String, dynamic>? summaryData;
  final String? errorMessage;
  final String? successMessage;

  const ShootEditReviewState({
    this.status = ShootEditReviewStatus.initial,
    this.summaryData,
    this.errorMessage,
    this.successMessage,
  });

  ShootEditReviewState copyWith({
    ShootEditReviewStatus? status,
    Map<String, dynamic>? summaryData,
    String? errorMessage,
    String? successMessage,
  }) {
    return ShootEditReviewState(
      status: status ?? this.status,
      summaryData: summaryData ?? this.summaryData,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ShootEditReviewNotifier
    extends AutoDisposeFamilyNotifier<ShootEditReviewState, int> {
  @override
  ShootEditReviewState build(int bookingId) {
    fetchSummary(bookingId);
    return const ShootEditReviewState(status: ShootEditReviewStatus.loading);
  }

  Future<void> fetchSummary(int bookingId) async {
    final repo = ref.read(shootRepositoryProvider);
    final result = await repo.getBookingSummary(bookingId: bookingId);

    result.fold(
      (error) => state = state.copyWith(
        status: ShootEditReviewStatus.error,
        errorMessage: error.message,
      ),
      (data) => state = state.copyWith(
        status: ShootEditReviewStatus.loaded,
        summaryData: data,
      ),
    );
  }

  Future<void> confirmReschedule(int bookingId) async {
    state = state.copyWith(status: ShootEditReviewStatus.confirming);

    final repo = ref.read(shootRepositoryProvider);
    final result = await repo.confirmReschedule(bookingId: bookingId);

    result.fold(
      (error) => state = state.copyWith(
        status: ShootEditReviewStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        final message = (data['message'] as String?) ?? 'Reschedule confirmed';
        state = state.copyWith(
          status: ShootEditReviewStatus.confirmed,
          successMessage: message,
        );
      },
    );
  }
}

final shootEditReviewNotifierProvider = NotifierProvider.autoDispose
    .family<ShootEditReviewNotifier, ShootEditReviewState, int>(
      ShootEditReviewNotifier.new,
    );
