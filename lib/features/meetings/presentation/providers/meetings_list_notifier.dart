import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meetings_tab.dart';
import '../../domain/repositories/meetings_repository.dart';
import 'meetings_list_state.dart';
import 'meetings_repository_provider.dart';

class MeetingsListNotifier extends AutoDisposeNotifier<MeetingsListState> {
  late final MeetingsRepository _repo;

  @override
  MeetingsListState build() {
    _repo = ref.watch(meetingsRepositoryProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    Future.microtask(_load);
    return MeetingsListState(
      status: MeetingsListStatus.loading,
      currentUserId: currentUserId,
    );
  }

  Future<void> _load() async {
    state = state.copyWith(
      status: MeetingsListStatus.loading,
      clearError: true,
    );
    try {
      // Single fetch — tab + filter both applied locally so the Invited badge
      // can be computed off the raw page without a second round trip.
      final all = await _repo.list();
      state = state.copyWith(
        allItems: all,
        items: applyLocalMeetingFilters(
          all,
          tab: state.tab,
          filter: state.filter,
          currentUserId: state.currentUserId,
        ),
        status: MeetingsListStatus.ready,
      );
    } catch (e) {
      state = state.copyWith(
        status: MeetingsListStatus.error,
        error: _messageFor(e),
      );
      if (e is UnauthorizedException) {
        ref.read(authStateProvider.notifier).updateState(false);
      }
    }
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    return 'Failed to load meetings';
  }

  void selectTab(MeetingsTab tab) {
    if (tab == state.tab) return;
    final items = applyLocalMeetingFilters(
      state.allItems,
      tab: tab,
      filter: state.filter,
      currentUserId: state.currentUserId,
    );
    state = state.copyWith(tab: tab, items: items);
  }

  void applyFilter(MeetingFilter filter) {
    final items = applyLocalMeetingFilters(
      state.allItems,
      tab: state.tab,
      filter: filter,
      currentUserId: state.currentUserId,
    );
    state = state.copyWith(filter: filter, items: items);
  }

  void clearFilter() {
    final items = applyLocalMeetingFilters(
      state.allItems,
      tab: state.tab,
      filter: MeetingFilter.empty,
      currentUserId: state.currentUserId,
    );
    state = state.copyWith(filter: MeetingFilter.empty, items: items);
  }

  Future<void> refresh() => _load();
}

final meetingsListNotifierProvider =
    AutoDisposeNotifierProvider<MeetingsListNotifier, MeetingsListState>(
  MeetingsListNotifier.new,
);
