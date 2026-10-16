import 'package:beige/features/booking/domain/entities/crew_assignment.dart';
import 'package:flutter_test/flutter_test.dart';

const photographer = {'photographer'};
const videographer = {'videographer'};
const dual = {'photographer', 'videographer'};

void main() {
  group('single-role creators', () {
    test('photographer-only adds to photographer: 1/2 -> 2/2', () {
      const a = CrewAssignment(
        required: {'photographer': 2, 'videographer': 2},
        assigned: {'photographer': [10]},
      );
      final next = a.add(20, photographer);
      expect(next.selectedCount('photographer'), 2);
      expect(next.selectedCount('videographer'), 0);
    });

    test('videographer-only adds to videographer: 0/2 -> 1/2', () {
      const a = CrewAssignment(required: {'photographer': 2, 'videographer': 2});
      final next = a.add(30, videographer);
      expect(next.selectedCount('videographer'), 1);
      expect(next.selectedCount('photographer'), 0);
    });
  });

  group('dual-role assignment', () {
    test('fewer selected wins: P0 V1 -> assigns photographer', () {
      const a = CrewAssignment(
        required: {'photographer': 2, 'videographer': 2},
        assigned: {'videographer': [99]},
      );
      expect(a.targetRoleFor(dual), 'photographer');
    });

    test('preferred role full -> other supported role: P2/2 V1/2 -> videographer', () {
      const a = CrewAssignment(
        required: {'photographer': 2, 'videographer': 2},
        assigned: {
          'photographer': [11, 12],
          'videographer': [99],
        },
      );
      expect(a.targetRoleFor(dual), 'videographer');
    });

    test('tie on selected -> more remaining wins: P0/2 V0/1 -> photographer', () {
      const a = CrewAssignment(required: {'photographer': 2, 'videographer': 1});
      expect(a.targetRoleFor(dual), 'photographer');
    });

    test('tie on selected and remaining -> photographer fallback: P0/1 V0/1', () {
      const a = CrewAssignment(required: {'photographer': 1, 'videographer': 1});
      expect(a.targetRoleFor(dual), 'photographer');
    });

    test('error case — all supported slots full -> cannot add', () {
      const a = CrewAssignment(
        required: {'photographer': 1},
        assigned: {'photographer': [5]},
      );
      expect(a.canAdd(dual), false);
      expect(a.targetRoleFor(dual), isNull);
      // add is a no-op when no space
      expect(a.add(6, dual), a);
    });
  });

  group('remove', () {
    test('frees the exact role slot the creator occupied', () {
      const a = CrewAssignment(
        required: {'photographer': 2, 'videographer': 2},
        assigned: {
          'photographer': [11, 12],
          'videographer': [99],
        },
      );
      final next = a.remove(12);
      expect(next.selectedCount('photographer'), 1);
      expect(next.selectedCount('videographer'), 1); // untouched
      expect(next.contains(12), false);
    });

    test('removing an absent creator is a no-op', () {
      const a = CrewAssignment(
        required: {'photographer': 2},
        assigned: {'photographer': [1]},
      );
      expect(a.remove(999), a);
    });
  });

  group('continue / completeness', () {
    const req = {'photographer': 2, 'videographer': 2};

    test('all slots filled enables continue', () {
      const a = CrewAssignment(
        required: req,
        assigned: {
          'photographer': [1, 2],
          'videographer': [3, 4],
        },
      );
      expect(a.isComplete, true);
      expect(a.continueEnabled(letBeigeChoose: false), true);
    });

    test('partial selection disables continue unless Beige-choose', () {
      const a = CrewAssignment(
        required: req,
        assigned: {
          'photographer': [1],
          'videographer': [3, 4],
        },
      );
      expect(a.continueEnabled(letBeigeChoose: false), false);
      expect(a.continueEnabled(letBeigeChoose: true), true);
    });

    test('Beige-choose enables continue at zero selection', () {
      const a = CrewAssignment(required: req);
      expect(a.continueEnabled(letBeigeChoose: false), false);
      expect(a.continueEnabled(letBeigeChoose: true), true);
    });
  });

  group('selectedCrewIds (API payload)', () {
    test('flattens all roles, photographer first', () {
      const a = CrewAssignment(
        required: {'photographer': 2, 'videographer': 1},
        assigned: {
          'videographer': [99],
          'photographer': [11, 12],
        },
      );
      expect(a.selectedCrewIds, [11, 12, 99]);
      expect(a.totalSelected, 3);
    });

    test('add then remove full round-trip keeps ids consistent', () {
      var a = const CrewAssignment(required: {'photographer': 1, 'videographer': 1});
      a = a.add(1, dual); // -> photographer (fallback)
      a = a.add(2, dual); // photographer full -> videographer
      expect(a.selectedCrewIds, [1, 2]);
      expect(a.isComplete, true);
      a = a.remove(1);
      expect(a.selectedCrewIds, [2]);
      expect(a.canAdd(dual), true); // photographer slot freed
    });
  });
}
