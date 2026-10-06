import 'booking_enums.dart';
import 'creator_assignment.dart';
import 'role_counts.dart';

/// Pure implementation of the PDF manual-creator role-assignment rules
/// (pp. 23-29). No UI, no side effects — directly unit-testable.
///
/// Only Photographer/Videographer dual-role is defined by the PDF. Hybrid
/// (Photo + Video Creator) and Cinematographer assignment is unconfirmed (D4);
/// a dual-role creator is never silently treated as two filled slots.
abstract class CreatorAssignmentResolver {
  /// Returns the role a creator should be assigned to on Add, or null when no
  /// supported role has remaining capacity (Add is disabled).
  static BookingCreatorRole? resolveAddRole({
    required CreatorCapability capability,
    required RoleCounts required,
    required CreatorAssignments current,
  }) {
    int remaining(BookingCreatorRole role) =>
        required.countFor(role) - current.selectedCountFor(role);

    final photoOk =
        capability.supportsPhotographer &&
        remaining(BookingCreatorRole.photographer) > 0;
    final videoOk =
        capability.supportsVideographer &&
        remaining(BookingCreatorRole.videographer) > 0;

    // Single-capability creators.
    if (capability.supportsPhotographer && !capability.supportsVideographer) {
      return photoOk ? BookingCreatorRole.photographer : null;
    }
    if (capability.supportsVideographer && !capability.supportsPhotographer) {
      return videoOk ? BookingCreatorRole.videographer : null;
    }

    // Dual-role creator — prefer the role with fewer selected creators.
    if (capability.isDualRole) {
      final selPhoto = current.selectedCountFor(BookingCreatorRole.photographer);
      final selVideo = current.selectedCountFor(BookingCreatorRole.videographer);

      BookingCreatorRole preferred;
      if (selPhoto != selVideo) {
        preferred = selPhoto < selVideo
            ? BookingCreatorRole.photographer
            : BookingCreatorRole.videographer;
      } else {
        // Tie on selected counts — prefer more remaining required slots.
        final remPhoto = remaining(BookingCreatorRole.photographer);
        final remVideo = remaining(BookingCreatorRole.videographer);
        if (remPhoto != remVideo) {
          preferred = remPhoto > remVideo
              ? BookingCreatorRole.photographer
              : BookingCreatorRole.videographer;
        } else {
          // Both tie — Photographer is the fixed fallback.
          preferred = BookingCreatorRole.photographer;
        }
      }

      final preferredOk = preferred == BookingCreatorRole.photographer
          ? photoOk
          : videoOk;
      if (preferredOk) return preferred;

      // Preferred full — fall back to the other supported role if it has room.
      final other = preferred == BookingCreatorRole.photographer
          ? BookingCreatorRole.videographer
          : BookingCreatorRole.photographer;
      final otherOk = other == BookingCreatorRole.photographer
          ? photoOk
          : videoOk;
      return otherOk ? other : null;
    }

    return null;
  }

  /// Adds a creator to its resolved role. Returns the unchanged state when no
  /// slot is available (Add disabled).
  static CreatorAssignments add({
    required CreatorCapability capability,
    required RoleCounts required,
    required CreatorAssignments current,
  }) {
    if (current.contains(capability.crewMemberId)) return current;
    final role = resolveAddRole(
      capability: capability,
      required: required,
      current: current,
    );
    if (role == null) return current;
    return current.copyWith(
      assigned: [
        ...current.assigned,
        AssignedCreator(crewMemberId: capability.crewMemberId, role: role),
      ],
    );
  }

  /// Removes a creator from the exact role slot it was assigned to. Role is
  /// not recomputed during removal.
  static CreatorAssignments remove({
    required int crewMemberId,
    required CreatorAssignments current,
  }) {
    return current.copyWith(
      assigned: current.assigned
          .where((a) => a.crewMemberId != crewMemberId)
          .toList(),
    );
  }
}
