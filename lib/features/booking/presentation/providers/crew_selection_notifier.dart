import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import 'booking_providers.dart';

enum CrewSelectionStatus { initial, loading, loaded, error }

class CrewSelectionState {
  final CrewSelectionStatus status;
  final List<dynamic> crewMatches;
  final List<dynamic> nearbyCreators;
  final List<dynamic> otherCreators;
  final Map<String, dynamic> crewRequirements;
  final Set<int> addedCrewUserIds;
  final Map<String, dynamic> requiredByRole;
  final Map<String, dynamic> heldByRole;
  final String? errorMessage;

  const CrewSelectionState({
    this.status = CrewSelectionStatus.initial,
    this.crewMatches = const [],
    this.nearbyCreators = const [],
    this.otherCreators = const [],
    this.crewRequirements = const {},
    this.addedCrewUserIds = const {},
    this.requiredByRole = const {},
    this.heldByRole = const {},
    this.errorMessage,
  });

  CrewSelectionState copyWith({
    CrewSelectionStatus? status,
    List<dynamic>? crewMatches,
    List<dynamic>? nearbyCreators,
    List<dynamic>? otherCreators,
    Map<String, dynamic>? crewRequirements,
    Set<int>? addedCrewUserIds,
    Map<String, dynamic>? requiredByRole,
    Map<String, dynamic>? heldByRole,
    String? errorMessage,
  }) {
    return CrewSelectionState(
      status: status ?? this.status,
      crewMatches: crewMatches ?? this.crewMatches,
      nearbyCreators: nearbyCreators ?? this.nearbyCreators,
      otherCreators: otherCreators ?? this.otherCreators,
      crewRequirements: crewRequirements ?? this.crewRequirements,
      addedCrewUserIds: addedCrewUserIds ?? this.addedCrewUserIds,
      requiredByRole: requiredByRole ?? this.requiredByRole,
      heldByRole: heldByRole ?? this.heldByRole,
      errorMessage: errorMessage,
    );
  }
}

class CrewSelectionNotifier
    extends AutoDisposeFamilyNotifier<CrewSelectionState, int> {
  bool _stepCompleted = false;

  @override
  CrewSelectionState build(int bookingId) {
    // --- Booking Analytics: Drop-off tracking for Step 6 ---
    ref.onDispose(() {
      if (!_stepCompleted) {
        AnalyticsService.logEvent(AnalyticsEvents.bookingAbandoned, params: {
          'booking_id': bookingId,
          'last_step': 'crew_selection',
          'step_number': 6,
        });
      }
    });
    _fetchInitialData(bookingId);
    return const CrewSelectionState(status: CrewSelectionStatus.loading);
  }

  Future<void> _fetchInitialData(int bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);

    final results = await Future.wait([
      repo.getCrewMatches(bookingId: bookingId),
      repo.getHolds(bookingId: bookingId),
    ]);

    final matchesResult = results[0];
    final holdsResult = results[1];

    /// Process matches
    List<dynamic> crewMatches = [];
    List<dynamic> nearby = [];
    List<dynamic> other = [];

    Map<int, int> requiredCountByRole = {};
    Set<int> allowedRoleIds = {};
    final matchesFailed = matchesResult.fold(
          (error) {
        state = state.copyWith(
          status: CrewSelectionStatus.error,
          errorMessage: error.message,
        );
        return true;
      },
          (data) {

        /// 🔥 MAIN ITEMS
        final items = (data['items'] as List?) ?? [];

        /// 🔥 FALLBACK RANDOM CREATORS
        final randomCreators =
            (data['random_creators'] as List?) ?? [];

        /// 🔥 IF ITEMS EMPTY → USE RANDOM CREATORS
        crewMatches = items;

        /// 🔥 DISTANCE WISE FILTER
        /// 🔥 LOCATION BASED CREATORS
        for (var item in crewMatches) {

          double distance = 0;

          if (item['distance_km'] != null) {
            distance =
                (item['distance_km'] as num?)?.toDouble() ?? 0;
          }

          if (distance > 0 && distance <= 100) {
            nearby.add(item);
          }
        }

        /// 🔥 RANDOM FALLBACK CREATORS
        other = randomCreators;

        /// ✅ REQUIREMENTS SAFE
        final requirements =
            (data['crew_requirements'] as List?) ?? [];

        allowedRoleIds = requirements
            .map<int>(
              (e) => int.tryParse(
            e['role_id'].toString(),
          ) ??
              0,
        )
            .where((id) => id != 0)
            .toSet();

        requiredCountByRole = {
          for (var r in requirements)
            (int.tryParse(r['role_id'].toString()) ?? 0):
            (int.tryParse(
              r['required_count'].toString(),
            ) ??
                0),
        };

        return false;
      },
    );
    if (matchesFailed) return;

    /// Process holds
    Set<int> addedCrewUserIds = {};

    Map<String, dynamic> requiredByRole = {};
    Map<String, dynamic> heldByRole = {};

    holdsResult.fold(
          (error) {
        /// Non-critical
      },
          (data) {

        /// ✅ SAFE CREATIVES
        final creatives =
            (data['creatives'] as List?) ?? [];

        addedCrewUserIds = creatives
            .map<int>(
              (e) => int.tryParse(
            e['creative_user_id'].toString(),
          ) ??
              0,
        )
            .where((id) => id != 0)
            .toSet();

        /// ✅ SAFE SUMMARY
        final summary =
        data['summary'] as Map<String, dynamic>?;

        if (summary != null) {

          requiredByRole = Map<String, dynamic>.from(
            summary['required_by_role'] ?? {},
          );

          heldByRole = Map<String, dynamic>.from(
            summary['held_by_role'] ?? {},
          );
        }
      },
    );

    /// Analytics
    AnalyticsService.logEvent(
      AnalyticsEvents.bookingStepCrew,
      params: {
        'booking_id': bookingId,
        'crew_matches': crewMatches.length,
        'step_number': 6,
      },
    );

    /// ✅ FINAL STATE
    state = state.copyWith(
      status: CrewSelectionStatus.loaded,
      crewMatches: crewMatches,
      nearbyCreators: nearby,
      otherCreators: other,
      addedCrewUserIds: addedCrewUserIds,
      requiredByRole: requiredByRole,
      heldByRole: heldByRole,
    );
  }

  Future<void> filterCrew({
    required int bookingId,
    required String sort,
    int page = 1,
    int limit = 30,
  }) async {
    state = state.copyWith(status: CrewSelectionStatus.loading);

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getCrewMatches(
      bookingId: bookingId,
      sort: sort,
      page: page,
      limit: limit,
    );

    result.fold(
      (error) => state = state.copyWith(
        status: CrewSelectionStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        final items = data['items'] as List? ?? [];
        state = state.copyWith(
          status: CrewSelectionStatus.loaded,
          crewMatches: items,
        );
      },
    );
  }

  /// Returns true if hold added successfully.
  Future<bool> addHold({
    required int bookingId,
    required int crewMemberId,
    required int roleId,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.addHold(
      bookingId: bookingId,
      crewMemberId: crewMemberId,
      roleId: roleId,
    );

    return result.fold(
      (error) => false,
      (data) {
        final updated = Set<int>.from(state.addedCrewUserIds)..add(crewMemberId);
        state = state.copyWith(addedCrewUserIds: updated);
        return true;
      },
    );
  }

  /// Returns true if hold removed successfully.
  Future<bool> removeHold({
    required int bookingId,
    required int crewMemberId,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.removeHold(
      bookingId: bookingId,
      crewMemberId: crewMemberId,
    );

    return result.fold(
      (error) => false,
      (data) {
        final updated = Set<int>.from(state.addedCrewUserIds)..remove(crewMemberId);
        state = state.copyWith(addedCrewUserIds: updated);
        return true;
      },
    );
  }

  /// Refresh holds from backend.
  Future<void> refreshHolds(int bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getHolds(bookingId: bookingId);

    result.fold(
      (_) {},
      (data) {
        final creatives = data['creatives'] as List? ?? [];
        final addedIds = creatives
            .map<int>((e) => e['creative_user_id'] as int)
            .toSet();

        final summary = data['summary'] as Map<String, dynamic>?;
        Map<String, dynamic> requiredByRole = {};
        Map<String, dynamic> heldByRole = {};
        if (summary != null) {
          requiredByRole = Map<String, dynamic>.from(summary['required_by_role'] ?? {});
          heldByRole = Map<String, dynamic>.from(summary['held_by_role'] ?? {});
        }

        state = state.copyWith(
          addedCrewUserIds: addedIds,
          requiredByRole: requiredByRole,
          heldByRole: heldByRole,
        );
      },
    );
  }

  void markStepCompleted() {
    _stepCompleted = true;
  }
}

final crewSelectionNotifierProvider = NotifierProvider.autoDispose
    .family<CrewSelectionNotifier, CrewSelectionState, int>(
  CrewSelectionNotifier.new,
);
