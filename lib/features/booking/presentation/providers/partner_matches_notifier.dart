import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/crew_assignment.dart';
import 'booking_providers.dart';

enum PartnerMatchesStatus { initial, loading, loaded, error }

/// A creative partner returned by `GET /bookings/:id/matches`.
///
/// [capabilities] are the roles this creator can fill (`photographer` /
/// `videographer`). The contract says never to infer role from the name;
/// ids are preferred, but until the server role-id map is confirmed we fall
/// back to the role label. See Phase 4 (capability validation).
class PartnerMatch {
  const PartnerMatch({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.capabilities,
    this.photoPath,
    this.rating,
    this.reviews,
    this.isFavourite = false,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String roleLabel;
  final Set<String> capabilities;
  final String? photoPath;
  final double? rating;
  final int? reviews;
  final bool isFavourite;
  final bool isActive;

  static Set<String> _capabilitiesFrom(Map<String, dynamic> json) {
    final caps = <String>{};
    // Prefer explicit capability lists when the backend provides them.
    final raw = json['capabilities'] ?? json['roles'] ?? json['role_names'];
    if (raw is List) {
      for (final r in raw) {
        final s = r.toString().toLowerCase();
        if (s.contains('photo')) caps.add('photographer');
        if (s.contains('video')) caps.add('videographer');
      }
    }
    if (caps.isEmpty) {
      // Fallback: derive from the role label (flagged for Phase 4).
      final label = (json['role_name'] ?? json['role'] ?? '')
          .toString()
          .toLowerCase();
      if (label.contains('photo')) caps.add('photographer');
      if (label.contains('video')) caps.add('videographer');
    }
    if (caps.isEmpty) caps.add('photographer');
    return caps;
  }

  static PartnerMatch fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    double? toDouble(dynamic v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    return PartnerMatch(
      id: toInt(json['crew_member_id'] ?? json['creative_user_id'] ?? json['id']),
      name: (json['name'] ?? '').toString(),
      roleLabel: (json['role_name'] ?? json['role'] ?? '').toString(),
      capabilities: _capabilitiesFrom(json),
      photoPath: json['profile_photo']?.toString(),
      rating: toDouble(json['average_rating']),
      reviews: json['total_reviews'] == null
          ? null
          : toInt(json['total_reviews']),
      isFavourite: json['is_favourite'] == true || json['is_favourite'] == 1,
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == true || json['is_active'] == 1),
    );
  }
}

class PartnerMatchesState {
  final PartnerMatchesStatus status;
  final List<PartnerMatch> matches;
  final CrewAssignment assignment;
  final bool letBeigeChoose;

  /// True when there were no nearby `items` and the list is the
  /// `random_creators` fallback — drives the "creators around you are booked"
  /// banner (Figma state-no-partner-found).
  final bool noNearby;
  final String? errorMessage;

  const PartnerMatchesState({
    this.status = PartnerMatchesStatus.initial,
    this.matches = const [],
    this.assignment = const CrewAssignment(required: {}),
    this.letBeigeChoose = false,
    this.noNearby = false,
    this.errorMessage,
  });

  PartnerMatchesState copyWith({
    PartnerMatchesStatus? status,
    List<PartnerMatch>? matches,
    CrewAssignment? assignment,
    bool? letBeigeChoose,
    bool? noNearby,
    String? errorMessage,
  }) => PartnerMatchesState(
    status: status ?? this.status,
    matches: matches ?? this.matches,
    assignment: assignment ?? this.assignment,
    letBeigeChoose: letBeigeChoose ?? this.letBeigeChoose,
    noNearby: noNearby ?? this.noNearby,
    errorMessage: errorMessage,
  );
}

/// Screen 8 — Partner Selection (manual branch). Loads matches, tracks the
/// dual-role [CrewAssignment] (pure logic lives in `crew_assignment.dart`), and
/// exposes the flat `selectedCrewIds` submitted later on `PUT /submit`.
class PartnerMatchesNotifier
    extends AutoDisposeNotifier<PartnerMatchesState> {
  @override
  PartnerMatchesState build() => const PartnerMatchesState();

  /// Builds the required-role map from the crew the client chose in Screen 6.
  /// Hybrid (`photoVideoCreator`) is folded into both single roles only when no
  /// dedicated count was set — refined in Phase 4.
  static Map<String, int> requiredFromRoleCounts(Map<String, int> roleCounts) {
    final photographer = roleCounts['photographer'] ?? 0;
    final videographer = roleCounts['videographer'] ?? 0;
    final hybrid = roleCounts['photoVideoCreator'] ?? 0;
    if (photographer == 0 && videographer == 0 && hybrid > 0) {
      return {'photographer': hybrid, 'videographer': hybrid};
    }
    return {
      if (photographer > 0) 'photographer': photographer,
      if (videographer > 0) 'videographer': videographer,
    };
  }

  Future<void> load({
    required int bookingId,
    required Map<String, int> roleCounts,
  }) async {
    state = state.copyWith(
      status: PartnerMatchesStatus.loading,
      assignment: CrewAssignment(required: requiredFromRoleCounts(roleCounts)),
    );
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.getCrewMatches(bookingId: bookingId);
    result.fold(
      (error) => state = state.copyWith(
        status: PartnerMatchesStatus.error,
        errorMessage: error.message,
      ),
      (data) {
        final items = (data['items'] as List?) ?? const [];
        final random = (data['random_creators'] as List?) ?? const [];
        final source = items.isNotEmpty ? items : random;
        state = state.copyWith(
          status: PartnerMatchesStatus.loaded,
          noNearby: items.isEmpty && random.isNotEmpty,
          matches: source
              .whereType<Map>()
              .map((e) => PartnerMatch.fromJson(Map<String, dynamic>.from(e)))
              .where((m) => m.id != 0)
              .toList(),
        );
      },
    );
  }

  void add(PartnerMatch match) {
    state = state.copyWith(
      assignment: state.assignment.add(match.id, match.capabilities),
    );
  }

  void remove(int id) {
    state = state.copyWith(assignment: state.assignment.remove(id));
  }

  void toggleLetBeigeChoose() {
    state = state.copyWith(letBeigeChoose: !state.letBeigeChoose);
  }
}

final partnerMatchesNotifierProvider =
    NotifierProvider.autoDispose<PartnerMatchesNotifier, PartnerMatchesState>(
      PartnerMatchesNotifier.new,
    );
