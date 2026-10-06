import 'package:flutter/foundation.dart';

import 'booking_enums.dart';
import 'role_counts.dart';

/// Roles a creator can fill, derived from API capability data — never from the
/// creator's name or card title (PDF manual-creator rule 1).
@immutable
class CreatorCapability {
  const CreatorCapability({
    required this.crewMemberId,
    required this.supportsPhotographer,
    required this.supportsVideographer,
  });

  final int crewMemberId;
  final bool supportsPhotographer;
  final bool supportsVideographer;

  bool get isDualRole => supportsPhotographer && supportsVideographer;

  bool supports(BookingCreatorRole role) => switch (role) {
    BookingCreatorRole.photographer => supportsPhotographer,
    BookingCreatorRole.videographer => supportsVideographer,
    // Cinematographer / Photo+Video capability mapping is unconfirmed (D4).
    _ => false,
  };
}

/// A creator placed into a specific UI role slot. Stores the exact role the
/// UI assigned so removal targets that slot (PDF remove rule).
@immutable
class AssignedCreator {
  const AssignedCreator({required this.crewMemberId, required this.role});

  final int crewMemberId;
  final BookingCreatorRole role;

  Map<String, dynamic> toJson() => {
    'crew_member_id': crewMemberId,
    'role': role.wireKey,
  };

  factory AssignedCreator.fromJson(Map<String, dynamic> json) =>
      AssignedCreator(
        crewMemberId: (json['crew_member_id'] as num).toInt(),
        role:
            BookingCreatorRole.fromWire(json['role'] as String?) ??
            BookingCreatorRole.photographer,
      );
}

/// Manual-branch creator selection state (Branch B). Frontend-only until final
/// submit. `letBeigeChoose` is never serialized into any API payload.
@immutable
class CreatorAssignments {
  const CreatorAssignments({
    this.assigned = const [],
    this.letBeigeChoose = false,
  });

  final List<AssignedCreator> assigned;
  final bool letBeigeChoose;

  int selectedCountFor(BookingCreatorRole role) =>
      assigned.where((a) => a.role == role).length;

  /// Unique creator IDs across all roles, for `selected_crew_ids`.
  List<int> get uniqueSelectedIds {
    final seen = <int>{};
    final out = <int>[];
    for (final a in assigned) {
      if (seen.add(a.crewMemberId)) out.add(a.crewMemberId);
    }
    return out;
  }

  bool contains(int crewMemberId) =>
      assigned.any((a) => a.crewMemberId == crewMemberId);

  CreatorAssignments copyWith({
    List<AssignedCreator>? assigned,
    bool? letBeigeChoose,
  }) => CreatorAssignments(
    assigned: assigned ?? this.assigned,
    letBeigeChoose: letBeigeChoose ?? this.letBeigeChoose,
  );

  /// Continue is allowed when every required role is filled, or when Let Beige
  /// Choose is checked (partial/zero allowed) — PDF rule 7.
  bool canContinue(RoleCounts required) {
    if (letBeigeChoose) return true;
    for (final role in BookingCreatorRole.values) {
      if (selectedCountFor(role) < required.countFor(role)) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
    'assigned': assigned.map((e) => e.toJson()).toList(),
    'letBeigeChoose': letBeigeChoose,
  };

  factory CreatorAssignments.fromJson(Map<String, dynamic> json) =>
      CreatorAssignments(
        assigned:
            (json['assigned'] as List?)
                ?.map((e) => AssignedCreator.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        letBeigeChoose: json['letBeigeChoose'] as bool? ?? false,
      );
}
