import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shoot_providers.dart';

enum ShootSummaryStatus { initial, loading, loaded, error }

class ShootSummaryState {
  final ShootSummaryStatus status;
  final Map<String, dynamic>? shootDetails;
  final List<dynamic> timeline;
  final String? errorMessage;

  const ShootSummaryState({
    this.status = ShootSummaryStatus.initial,
    this.shootDetails,
    this.timeline = const [],
    this.errorMessage,
  });

  ShootSummaryState copyWith({
    ShootSummaryStatus? status,
    Map<String, dynamic>? shootDetails,
    List<dynamic>? timeline,
    String? errorMessage,
  }) {
    return ShootSummaryState(
      status: status ?? this.status,
      shootDetails: shootDetails ?? this.shootDetails,
      timeline: timeline ?? this.timeline,
      errorMessage: errorMessage,
    );
  }
}

class ShootSummaryNotifier
    extends AutoDisposeFamilyNotifier<ShootSummaryState, int> {
  @override
  ShootSummaryState build(int bookingId) {
    fetchShootSummary(bookingId);
    return const ShootSummaryState(status: ShootSummaryStatus.loading);
  }

  Future<void> fetchShootSummary(int bookingId) async {
    final repo = ref.read(shootRepositoryProvider);

    final results = await Future.wait([
      repo.getShootDetails(bookingId: bookingId),
      repo.getShootTimeline(bookingId: bookingId),
    ]);

    final detailsResult = results[0];
    final timelineResult = results[1];

    Map<String, dynamic>? details = state.shootDetails;
    List<dynamic> timeline = state.timeline;
    String? error;

    detailsResult.fold(
      (e) => error = e.message,
      (data) => details = data as Map<String, dynamic>,
    );

    timelineResult.fold(
      (e) => error ??= e.message,
      (data) => timeline = data as List<dynamic>,
    );

    state = state.copyWith(
      status:
          error != null ? ShootSummaryStatus.error : ShootSummaryStatus.loaded,
      shootDetails: details,
      timeline: timeline,
      errorMessage: error,
    );
  }
}

final shootSummaryNotifierProvider = NotifierProvider.autoDispose
    .family<ShootSummaryNotifier, ShootSummaryState, int>(
  ShootSummaryNotifier.new,
);
