import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/restoration/draft_store.dart';
import '../../../../core/restoration/restoration_providers.dart';
import '../../domain/entities/booking_enums.dart';
import '../../domain/entities/creator_assignment.dart';
import '../../domain/entities/creator_assignment_resolver.dart';
import '../../domain/entities/creator_match.dart';
import '../../domain/entities/edit_selection.dart';
import '../../domain/entities/role_counts.dart';
import '../../domain/entities/schedule_input.dart';
import '../../domain/entities/submit_request.dart';
import 'booking_flow_state.dart';

/// Booking-scoped source of truth for the new Book-a-Shoot flow. Screens read
/// and update this instead of threading `state.extra`. Kept alive across the
/// wizard; call [startNewBooking] to reset and [hydrate] to restore a draft.
///
/// Mutations that change pricing inputs (schedule, role counts, edits, add-ons)
/// invalidate the cached review/quote freshness so downstream screens re-fetch.
class BookingFlowController extends Notifier<BookingFlowState> {
  @override
  BookingFlowState build() => const BookingFlowState();

  /// Resets to an empty flow for a brand-new booking.
  void startNewBooking() => state = const BookingFlowState();

  /// Restores a persisted draft (cold start / resume).
  void hydrate(BookingFlowState restored) => state = restored;

  void setBookingId(int bookingId) =>
      state = state.copyWith(bookingId: bookingId);

  void setContentType(BookingContentType contentType) {
    // Content change can alter crew/edit validity downstream.
    state = state.copyWith(
      contentType: contentType,
      clearReviewedFingerprint: true,
      clearQuotedFingerprint: true,
    );
  }

  void setShootType(String name) => state = state.copyWith(shootTypeName: name);

  void setSchedule(ScheduleInput schedule) {
    state = state.copyWith(
      schedule: schedule,
      clearReviewedFingerprint: true,
      clearQuotedFingerprint: true,
    );
  }

  void setDetails({
    required String additionalDetails,
    required List<String> referenceLinks,
  }) {
    state = state.copyWith(
      additionalDetails: additionalDetails,
      referenceLinks: referenceLinks,
    );
  }

  void setMatchingBranch(BookingMatchingBranch branch) {
    // Switching branches clears any manual creator state that no longer
    // applies to the automatic branch.
    state = state.copyWith(
      matchingBranch: branch,
      creatorAssignments: branch == BookingMatchingBranch.letBeigeMatch
          ? const CreatorAssignments()
          : state.creatorAssignments,
    );
  }

  void setRoleCounts(RoleCounts counts) {
    // Reducing a role trims assigned creators beyond the new per-role count
    // (earliest kept) so an excess creator is never silently submitted.
    // Downstream pricing is invalidated here.
    state = state.copyWith(
      roleCounts: counts,
      creatorAssignments: _reconcileAssignments(
        state.creatorAssignments,
        counts,
      ),
      clearReviewedFingerprint: true,
      clearQuotedFingerprint: true,
    );
  }

  /// Drops assignments that exceed the new required count per role, keeping the
  /// earliest-added creators in each role.
  CreatorAssignments _reconcileAssignments(
    CreatorAssignments current,
    RoleCounts counts,
  ) {
    final perRoleKept = <BookingCreatorRole, int>{};
    final next = <AssignedCreator>[];
    for (final a in current.assigned) {
      final kept = perRoleKept[a.role] ?? 0;
      if (kept < counts.countFor(a.role)) {
        next.add(a);
        perRoleKept[a.role] = kept + 1;
      }
    }
    if (next.length == current.assigned.length) return current;
    return current.copyWith(assigned: next);
  }

  void setEditSelection(EditSelection selection) {
    state = state.copyWith(
      editSelection: selection,
      clearReviewedFingerprint: true,
      clearQuotedFingerprint: true,
    );
  }

  // ── Manual creator branch ──────────────────────────────────────────────

  /// Adds a creator using the PDF role-assignment rules. No-op when no
  /// supported role has capacity.
  void addCreator(CreatorMatch match) {
    final next = CreatorAssignmentResolver.add(
      capability: match.capability,
      required: state.roleCounts,
      current: state.creatorAssignments,
    );
    state = state.copyWith(creatorAssignments: next);
  }

  void removeCreator(int crewMemberId) {
    final next = CreatorAssignmentResolver.remove(
      crewMemberId: crewMemberId,
      current: state.creatorAssignments,
    );
    state = state.copyWith(creatorAssignments: next);
  }

  void setLetBeigeChoose(bool value) {
    state = state.copyWith(
      creatorAssignments: state.creatorAssignments.copyWith(
        letBeigeChoose: value,
      ),
    );
  }

  // ── Add-ons ─────────────────────────────────────────────────────────────

  void setAddonQuantity(String slug, int quantity) {
    final next = state.addonSelection.withQuantity(slug, quantity);
    state = state.copyWith(
      addonSelection: next,
      // Changing quantities invalidates review/quote freshness.
      clearReviewedFingerprint: true,
      clearQuotedFingerprint: true,
    );
  }

  void setContact(ContactInfo contact) =>
      state = state.copyWith(contact: contact);

  // ── Step tracking + review/quote caching ────────────────────────────────

  void setCurrentStep(BookingStep step) =>
      state = state.copyWith(currentStep: step);

  void markStepComplete(BookingStep step) {
    if (state.completedSteps.contains(step)) return;
    state = state.copyWith(completedSteps: {...state.completedSteps, step});
  }

  /// Records a successful `/review` against the current add-on fingerprint.
  void markReviewed() => state = state.copyWith(
    reviewedFingerprint: state.addonSelection.fingerprint,
  );

  /// Records a successful `/quote` against the current add-on fingerprint.
  void markQuoted() =>
      state = state.copyWith(quotedFingerprint: state.addonSelection.fingerprint);

  /// Snapshot of the current add-on items for `/review` and `/quote`.
  List<Map<String, dynamic>> addOnItems() => state.addonSelection.toAddOnItems();

  SubmitRequest submitRequest() => state.toSubmitRequest();

  // ── Draft persistence ────────────────────────────────────────────────────

  /// Write-through the current flow to the booking draft so a cold start can
  /// resume. Call after each successful save. Never stores payment secrets —
  /// [BookingFlowState.toJson] already excludes them.
  Future<void> persist({String? currentRoute}) async {
    final store = ref.read(draftStoreProvider);
    final existing = store.readBookingDraft();
    final draft = BookingDraft(
      bookingId: state.bookingId,
      contentTypeId: existing?.contentTypeId,
      shootTypeId: existing?.shootTypeId,
      value: existing?.value,
      currentRoute: currentRoute ?? existing?.currentRoute,
      flow: state.toJson(),
    );
    await store.writeBookingDraft(draft);
  }

  /// Restore a persisted flow draft into state. Returns true when a compatible
  /// draft was loaded. Call at flow entry before building the first screen.
  bool hydrateFromDraft() {
    final draft = ref.read(draftStoreProvider).readBookingDraft();
    final flow = draft?.flow;
    if (flow == null) return false;
    state = BookingFlowState.fromJson(flow);
    return true;
  }

  /// Clears the persisted booking draft (e.g. after payment confirmation).
  Future<void> clearDraft() => ref.read(draftStoreProvider).clearBookingDraft();
}

/// Kept alive across the wizard — never autoDispose, or mid-flow navigation
/// would wipe collected state.
final bookingFlowControllerProvider =
    NotifierProvider<BookingFlowController, BookingFlowState>(
      BookingFlowController.new,
    );
