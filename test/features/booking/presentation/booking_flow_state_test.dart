import 'package:beige/core/restoration/draft_store.dart';
import 'package:beige/features/booking/domain/entities/addon_selection.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/creator_assignment.dart';
import 'package:beige/features/booking/domain/entities/edit_selection.dart';
import 'package:beige/features/booking/domain/entities/role_counts.dart';
import 'package:beige/features/booking/domain/entities/schedule_input.dart';
import 'package:beige/features/booking/domain/entities/submit_request.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_guard.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BookingFlowState sample() => BookingFlowState(
    bookingId: 42,
    contentType: BookingContentType.photographerVideographer,
    shootTypeName: 'Wedding',
    schedule: const ScheduleInput(
      mode: BookingScheduleMode.scheduled,
      eventDate: '2026-10-08',
      startTime: '09:00',
      endTime: '17:00',
      timeZone: 'Asia/Calcutta',
      eventLocation: '550 West 5th Street',
      eventLatitude: 34.05,
      eventLongitude: -118.25,
    ),
    additionalDetails: 'Outdoor shoot',
    referenceLinks: const ['https://example.com/moodboard'],
    matchingBranch: BookingMatchingBranch.choosePartner,
    roleCounts: const RoleCounts(photographer: 1, videographer: 1),
    editSelection: const EditSelection(
      editsNeeded: true,
      photoEditTypes: ['edited_photos'],
    ),
    creatorAssignments: const CreatorAssignments(
      assigned: [
        AssignedCreator(crewMemberId: 2129, role: BookingCreatorRole.photographer),
      ],
    ),
    addonSelection: const AddonSelection(
      items: [AddonSelectionItem(slug: 'v4-teleprompter', quantity: 1)],
    ),
    contact: const ContactInfo(
      fullName: 'Harsh',
      email: 'h@test.com',
      phone: '7777777777',
    ),
  );

  group('BookingFlowState round-trip', () {
    test('toJson/fromJson preserves all fields (happy path)', () {
      final restored = BookingFlowState.fromJson(sample().toJson());
      expect(restored.bookingId, 42);
      expect(restored.contentType, BookingContentType.photographerVideographer);
      expect(restored.shootTypeName, 'Wedding');
      expect(restored.schedule!.eventDate, '2026-10-08');
      expect(restored.matchingBranch, BookingMatchingBranch.choosePartner);
      expect(restored.roleCounts.photographer, 1);
      expect(restored.editSelection.photoEditTypes, ['edited_photos']);
      expect(restored.creatorAssignments.uniqueSelectedIds, [2129]);
      expect(restored.addonSelection.items.single.slug, 'v4-teleprompter');
      expect(restored.contact.email, 'h@test.com');
    });

    test('empty state round-trips to defaults (edge case)', () {
      final restored = BookingFlowState.fromJson(const BookingFlowState().toJson());
      expect(restored.bookingId, isNull);
      expect(restored.roleCounts.total, 0);
      expect(restored.addonSelection.isEmpty, isTrue);
    });
  });

  group('submit mapping', () {
    test('manual branch sends unique selected ids', () {
      expect(sample().toSubmitRequest().selectedCrewIds, [2129]);
    });

    test('automatic branch always sends empty crew ids', () {
      final auto = sample().copyWith(
        matchingBranch: BookingMatchingBranch.letBeigeMatch,
      );
      expect(auto.toSubmitRequest().selectedCrewIds, isEmpty);
    });
  });

  group('review/quote freshness', () {
    test('changing add-ons invalidates a prior review fingerprint', () {
      final reviewed = sample().copyWith(
        reviewedFingerprint: sample().addonSelection.fingerprint,
      );
      expect(reviewed.isReviewFresh, isTrue);

      final changed = reviewed.copyWith(
        addonSelection: reviewed.addonSelection.withQuantity('v4-drone', 1),
      );
      expect(changed.isReviewFresh, isFalse);
    });
  });

  group('BookingDraft migration', () {
    test('new draft round-trips embedded flow', () {
      final draft = BookingDraft(
        bookingId: 42,
        currentRoute: '/booking-edits',
        flow: sample().toJson(),
      );
      final restored = BookingDraft.fromJson(draft.toJson());
      expect(restored.draftVersion, BookingDraft.currentDraftVersion);
      expect(restored.flow, isNotNull);
      expect(restored.flow!['bookingId'], 42);
    });

    test('legacy draft without draftVersion drops any flow (migration)', () {
      final legacyJson = {
        'contentTypeId': 3,
        'bookingId': 7,
        'currentRoute': '/content-type',
        'flow': {'bookingId': 7}, // stale/unexpected on a v1 payload
      };
      final restored = BookingDraft.fromJson(legacyJson);
      expect(restored.draftVersion, BookingDraft.currentDraftVersion);
      expect(restored.flow, isNull);
      expect(restored.bookingId, 7);
      expect(restored.contentTypeId, 3);
    });
  });

  group('BookingFlowGuard', () {
    test('manual branch includes creator selection step', () {
      final steps = BookingFlowGuard.orderedSteps(sample());
      expect(steps, contains(BookingStep.creatorSelection));
    });

    test('automatic branch omits creator selection step', () {
      final auto = sample().copyWith(
        matchingBranch: BookingMatchingBranch.letBeigeMatch,
      );
      expect(
        BookingFlowGuard.orderedSteps(auto),
        isNot(contains(BookingStep.creatorSelection)),
      );
    });

    test('schedule prerequisite requires a saved shoot type', () {
      const noShoot = BookingFlowState(
        bookingId: 1,
        contentType: BookingContentType.photographer,
      );
      expect(
        BookingFlowGuard.prerequisitesMet(noShoot, BookingStep.schedule),
        isFalse,
      );
    });

    test('confirmPay requires a fresh quote', () {
      final noQuote = sample();
      expect(
        BookingFlowGuard.prerequisitesMet(noQuote, BookingStep.confirmPay),
        isFalse,
      );
      final quoted = noQuote.copyWith(
        quotedFingerprint: noQuote.addonSelection.fingerprint,
      );
      expect(
        BookingFlowGuard.prerequisitesMet(quoted, BookingStep.confirmPay),
        isTrue,
      );
    });

    test('resume lands on the first incomplete reachable step', () {
      const afterContent = BookingFlowState(
        bookingId: 1,
        contentType: BookingContentType.photographer,
        completedSteps: {BookingStep.contentType},
      );
      // content saved, shoot type not -> resume at shootType.
      expect(BookingFlowGuard.resumeStep(afterContent), BookingStep.shootType);
    });
  });
}
