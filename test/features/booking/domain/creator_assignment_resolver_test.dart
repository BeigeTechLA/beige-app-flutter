import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/creator_assignment.dart';
import 'package:beige/features/booking/domain/entities/creator_assignment_resolver.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:flutter_test/flutter_test.dart';

CreatorCapability _cap(
  int id, {
  required bool photo,
  required bool video,
}) => CreatorCapability(
  crewMemberId: id,
  supportsPhotographer: photo,
  supportsVideographer: video,
);

void main() {
  const required = RoleCounts(photographer: 2, videographer: 2);

  group('single-capability creators', () {
    test('photographer-only goes to photographer', () {
      final next = CreatorAssignmentResolver.add(
        capability: _cap(1, photo: true, video: false),
        required: required,
        current: const CreatorAssignments(),
      );
      expect(next.selectedCountFor(BookingCreatorRole.photographer), 1);
      expect(next.selectedCountFor(BookingCreatorRole.videographer), 0);
    });

    test('videographer-only goes to videographer', () {
      final next = CreatorAssignmentResolver.add(
        capability: _cap(2, photo: false, video: true),
        required: required,
        current: const CreatorAssignments(),
      );
      expect(next.selectedCountFor(BookingCreatorRole.videographer), 1);
    });

    test('photographer-only with full photographer slots is a no-op', () {
      const full = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
          AssignedCreator(crewMemberId: 11, role: BookingCreatorRole.photographer),
        ],
      );
      final next = CreatorAssignmentResolver.add(
        capability: _cap(1, photo: true, video: false),
        required: required,
        current: full,
      );
      expect(next.assigned.length, 2); // unchanged, Add disabled
    });
  });

  group('dual-role creator', () {
    test('prefers the role with fewer selected creators', () {
      // photographer 1/2, videographer 0/2 -> go to videographer.
      const current = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
        ],
      );
      final role = CreatorAssignmentResolver.resolveAddRole(
        capability: _cap(3, photo: true, video: true),
        required: required,
        current: current,
      );
      expect(role, BookingCreatorRole.videographer);
    });

    test('tie on selected -> prefers more remaining required slots', () {
      // selected 0/0 but required photographer 2 vs videographer 1.
      const req = RoleCounts(photographer: 2, videographer: 1);
      final role = CreatorAssignmentResolver.resolveAddRole(
        capability: _cap(3, photo: true, video: true),
        required: req,
        current: const CreatorAssignments(),
      );
      expect(role, BookingCreatorRole.photographer);
    });

    test('full tie -> photographer fallback', () {
      const req = RoleCounts(photographer: 1, videographer: 1);
      final role = CreatorAssignmentResolver.resolveAddRole(
        capability: _cap(3, photo: true, video: true),
        required: req,
        current: const CreatorAssignments(),
      );
      expect(role, BookingCreatorRole.photographer);
    });

    test('preferred role full -> falls back to the other supported role', () {
      // photographer full (2/2), videographer 0/2 -> videographer.
      const current = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
          AssignedCreator(crewMemberId: 11, role: BookingCreatorRole.photographer),
        ],
      );
      final role = CreatorAssignmentResolver.resolveAddRole(
        capability: _cap(3, photo: true, video: true),
        required: required,
        current: current,
      );
      expect(role, BookingCreatorRole.videographer);
    });

    test('all supported slots full -> null (Add disabled)', () {
      const req = RoleCounts(photographer: 1, videographer: 1);
      const current = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
          AssignedCreator(crewMemberId: 11, role: BookingCreatorRole.videographer),
        ],
      );
      final role = CreatorAssignmentResolver.resolveAddRole(
        capability: _cap(3, photo: true, video: true),
        required: req,
        current: current,
      );
      expect(role, isNull);
    });
  });

  group('remove', () {
    test('removes from the exact assigned slot, keeps others', () {
      const current = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
          AssignedCreator(crewMemberId: 11, role: BookingCreatorRole.videographer),
        ],
      );
      final next = CreatorAssignmentResolver.remove(
        crewMemberId: 10,
        current: current,
      );
      expect(next.selectedCountFor(BookingCreatorRole.photographer), 0);
      expect(next.selectedCountFor(BookingCreatorRole.videographer), 1);
    });
  });

  group('canContinue', () {
    test('false until every required role filled without Let Beige Choose', () {
      const current = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
        ],
      );
      expect(current.canContinue(required), isFalse);
    });

    test('Let Beige Choose allows zero/partial selections', () {
      const current = CreatorAssignments(letBeigeChoose: true);
      expect(current.canContinue(required), isTrue);
    });

    test('uniqueSelectedIds dedupes a dual-slot creator', () {
      const current = CreatorAssignments(
        assigned: [
          AssignedCreator(crewMemberId: 10, role: BookingCreatorRole.photographer),
          AssignedCreator(crewMemberId: 11, role: BookingCreatorRole.videographer),
        ],
      );
      expect(current.uniqueSelectedIds, [10, 11]);
    });
  });
}
