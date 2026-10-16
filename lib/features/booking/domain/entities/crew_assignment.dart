import 'package:flutter/foundation.dart';

/// Pure dual-role creator-assignment logic for the manual partner-selection
/// screen (Screen 8). UI-only state — the backend never receives role
/// assignment, only the flat list of selected creator IDs at final submit.
///
/// Rules (contract, API_Bookingflowchange.pdf):
/// - A creator supporting a single role is added to that role.
/// - A dual-role creator is assigned to the role with **fewer selected**
///   creators; on a tie, the role with **more remaining slots**; on a further
///   tie, **photographer** is the fixed fallback.
/// - If the preferred role is full, assign to the other supported role if it
///   has space; if all supported roles are full, the creator cannot be added.
/// - Removing a creator frees the exact role slot it occupied.
///
/// See docs/features/bookings/booking_flow_v2_implementation_plan.md §2.8.
@immutable
class CrewAssignment {
  const CrewAssignment({required this.required, this.assigned = const {}});

  /// Required creators per role, e.g. `{'photographer': 2, 'videographer': 2}`.
  final Map<String, int> required;

  /// Creator IDs currently assigned to each role, in selection order.
  final Map<String, List<int>> assigned;

  /// Fixed fallback role when every tie-breaker is equal.
  static const String _fallbackRole = 'photographer';

  /// Roles this booking needs at least one of, in a stable order
  /// (photographer first so it wins the fixed-fallback tie).
  List<String> get _roles {
    final keys = required.keys.where((r) => (required[r] ?? 0) > 0).toList();
    keys.sort((a, b) {
      if (a == _fallbackRole) return -1;
      if (b == _fallbackRole) return 1;
      return a.compareTo(b);
    });
    return keys;
  }

  int selectedCount(String role) => assigned[role]?.length ?? 0;
  int requiredCount(String role) => required[role] ?? 0;
  int remaining(String role) => requiredCount(role) - selectedCount(role);
  bool isRoleFull(String role) => remaining(role) <= 0;

  /// Flat list of every selected creator ID — the only thing sent to the API.
  List<int> get selectedCrewIds =>
      [for (final role in _roles) ...?assigned[role]];

  int get totalSelected => selectedCrewIds.length;

  /// All required role slots filled.
  bool get isComplete => _roles.every(isRoleFull);

  /// Continue is enabled when every required role is filled, or when the user
  /// opted into Beige choosing (then any count — including zero — is valid).
  bool continueEnabled({required bool letBeigeChoose}) =>
      letBeigeChoose || isComplete;

  /// The role a creator with [capabilities] would be placed in if added now,
  /// or `null` if no supported role has space (Add should be disabled).
  String? targetRoleFor(Set<String> capabilities) {
    final candidates = _roles
        .where((r) => capabilities.contains(r) && !isRoleFull(r))
        .toList();
    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    candidates.sort((a, b) {
      final bySelected = selectedCount(a).compareTo(selectedCount(b));
      if (bySelected != 0) return bySelected; // fewer selected wins
      final byRemaining = remaining(b).compareTo(remaining(a));
      if (byRemaining != 0) return byRemaining; // more remaining wins
      if (a == _fallbackRole) return -1; // photographer fallback
      if (b == _fallbackRole) return 1;
      return a.compareTo(b);
    });
    return candidates.first;
  }

  bool canAdd(Set<String> capabilities) => targetRoleFor(capabilities) != null;

  bool contains(int creatorId) => selectedCrewIds.contains(creatorId);

  /// Returns a new assignment with [creatorId] added to its target role, or
  /// the same instance (unchanged) if no role has space / it is already added.
  CrewAssignment add(int creatorId, Set<String> capabilities) {
    if (contains(creatorId)) return this;
    final role = targetRoleFor(capabilities);
    if (role == null) return this;
    final next = {
      for (final entry in assigned.entries) entry.key: List<int>.from(entry.value),
    };
    (next[role] ??= <int>[]).add(creatorId);
    return CrewAssignment(required: required, assigned: next);
  }

  /// Returns a new assignment with [creatorId] removed from whichever role slot
  /// it occupied.
  CrewAssignment remove(int creatorId) {
    if (!contains(creatorId)) return this;
    final next = {
      for (final entry in assigned.entries)
        entry.key: entry.value.where((id) => id != creatorId).toList(),
    };
    return CrewAssignment(required: required, assigned: next);
  }

  @override
  bool operator ==(Object other) =>
      other is CrewAssignment &&
      mapEquals(other.required, required) &&
      _assignedEquals(other.assigned, assigned);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(required.entries.map((e) => Object.hash(e.key, e.value))),
    Object.hashAllUnordered(
      assigned.entries.map((e) => Object.hash(e.key, Object.hashAll(e.value))),
    ),
  );

  static bool _assignedEquals(
    Map<String, List<int>> a,
    Map<String, List<int>> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!listEquals(a[key], b[key])) return false;
    }
    return true;
  }
}
