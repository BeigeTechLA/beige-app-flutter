import 'package:flutter/foundation.dart';

import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_filter.dart';
import '../../domain/models/meeting_rsvp.dart';
import '../../domain/models/meeting_status.dart';
import '../../domain/models/meetings_tab.dart';

enum MeetingsListStatus { idle, loading, ready, error }

@immutable
class MeetingsListState {
  final MeetingsTab tab;
  final MeetingFilter filter;
  final MeetingsListStatus status;

  /// Full unfiltered page from the API. Stored once on load so tab + filter
  /// changes can recompute locally without refetching. Notifier derives the
  /// visible [items] list + the invited-tab [pendingInviteCount] from this.
  final List<Meeting> allItems;

  /// View-model list — already filtered by [tab] and [filter].
  final List<Meeting> items;
  final String? error;

  /// Id of the signed-in user. Needed to compute the invited tab filter and
  /// pending-invite badge count. Null when logged out.
  final String? currentUserId;

  const MeetingsListState({
    this.tab = MeetingsTab.upcoming,
    this.filter = MeetingFilter.empty,
    this.status = MeetingsListStatus.idle,
    this.allItems = const [],
    this.items = const [],
    this.error,
    this.currentUserId,
  });

  bool get isFiltered => !filter.isEmpty;

  /// Count of meetings where the signed-in user is invited and the RSVP is
  /// still pending (or unknown — legacy payloads). Drives the Invited tab
  /// badge.
  int get pendingInviteCount {
    final me = currentUserId;
    if (me == null) return 0;
    var n = 0;
    for (final m in allItems) {
      for (final p in m.participants) {
        if (p.id != me) continue;
        final s = p.rsvpStatus;
        if (s == null || s == MeetingRsvpStatus.pending) n += 1;
        break;
      }
    }
    return n;
  }

  MeetingsListState copyWith({
    MeetingsTab? tab,
    MeetingFilter? filter,
    MeetingsListStatus? status,
    List<Meeting>? allItems,
    List<Meeting>? items,
    String? error,
    String? currentUserId,
    bool clearError = false,
  }) {
    return MeetingsListState(
      tab: tab ?? this.tab,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

/// Local filter applied to `allItems` to produce the visible list. Keeps the
/// same tab + filter semantics as the repository's server-side path so the UI
/// behavior is identical whether the data was fetched fresh or recomputed.
List<Meeting> applyLocalMeetingFilters(
  List<Meeting> items, {
  required MeetingsTab tab,
  required MeetingFilter filter,
  required String? currentUserId,
}) {
  Iterable<Meeting> result = items;

  switch (tab) {
    case MeetingsTab.upcoming:
      result = result.where((m) => m.status != MeetingStatus.completed);
    case MeetingsTab.completed:
      result = result.where((m) => m.status == MeetingStatus.completed);
    case MeetingsTab.invited:
      if (currentUserId == null) {
        result = const Iterable.empty();
      } else {
        result = result.where((m) {
          for (final p in m.participants) {
            if (p.id != currentUserId) continue;
            final s = p.rsvpStatus;
            return s == null || s == MeetingRsvpStatus.pending;
          }
          return false;
        });
      }
  }

  if (!filter.isEmpty) {
    if (filter.categories.isNotEmpty) {
      result = result.where((m) => filter.categories.contains(m.category));
    }
    if (filter.statuses.isNotEmpty) {
      result = result.where((m) => filter.statuses.contains(m.status));
    }
    if (filter.dateRange != null) {
      final s = filter.dateRange!.start;
      final e = filter.dateRange!.end;
      result = result.where(
        (m) => !m.startAt.isBefore(s) && !m.startAt.isAfter(e),
      );
    }
  }

  final list = result.toList()..sort((a, b) => a.startAt.compareTo(b.startAt));
  return list;
}
