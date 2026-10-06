import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/creator_match.dart';
import '../booking_flow_controller.dart';
import '../booking_providers.dart';

/// Paginated creator list for the manual branch (`GET /bookings/:id/matches`).
/// Accumulates deduplicated creators across pages. No hold/availability
/// mutations — selection stays local until final submit.
@immutable
class CreatorMatchesState {
  const CreatorMatchesState({
    this.matches = const [],
    this.page = 0,
    this.hasMore = true,
    this.loading = false,
    this.error,
  });

  final List<CreatorMatch> matches;
  final int page;
  final bool hasMore;
  final bool loading;
  final String? error;

  bool get isEmpty => matches.isEmpty;

  CreatorMatchesState copyWith({
    List<CreatorMatch>? matches,
    int? page,
    bool? hasMore,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => CreatorMatchesState(
    matches: matches ?? this.matches,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class BookingCreatorMatchesNotifier
    extends AutoDisposeNotifier<CreatorMatchesState> {
  static const int _limit = 12;

  @override
  CreatorMatchesState build() {
    // Kick off the first page once listeners attach.
    Future.microtask(loadMore);
    return const CreatorMatchesState();
  }

  /// Loads the next page and appends new, non-duplicate creators. No-op while
  /// a load is in flight or when the list is exhausted.
  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    final bookingId = ref.read(bookingFlowControllerProvider).bookingId;
    if (bookingId == null) {
      state = state.copyWith(
        loading: false,
        hasMore: false,
        error: 'Missing booking. Please restart the booking.',
      );
      return;
    }

    state = state.copyWith(loading: true, clearError: true);
    final nextPage = state.page + 1;
    final result = await ref
        .read(bookingRepositoryProvider)
        .getCreatorMatches(bookingId: bookingId, page: nextPage, limit: _limit);

    state = result.fold(
      (failure) => state.copyWith(loading: false, error: failure.message),
      (pageData) {
        final seen = state.matches.map((m) => m.crewMemberId).toSet();
        final merged = [
          ...state.matches,
          ...pageData.matches.where((m) => seen.add(m.crewMemberId)),
        ];
        return state.copyWith(
          matches: merged,
          page: nextPage,
          hasMore: pageData.hasMore,
          loading: false,
        );
      },
    );
  }

  /// Full reload from page 1 (retry after error).
  void refresh() {
    state = const CreatorMatchesState();
    loadMore();
  }
}

final bookingCreatorMatchesNotifierProvider =
    AutoDisposeNotifierProvider<
      BookingCreatorMatchesNotifier,
      CreatorMatchesState
    >(BookingCreatorMatchesNotifier.new);
