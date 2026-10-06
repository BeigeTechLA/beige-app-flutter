import '../../domain/entities/booking_enums.dart';
import 'booking_flow_state.dart';

/// Pure prerequisite rules for the Book-a-Shoot flow. Routes consult this to
/// reject entry when upstream saves are missing, and restoration uses it to
/// resume at the earliest valid step. No navigation here — callers redirect.
///
/// Schedule mode and matching branch are independent dimensions; the ordered
/// step list differs only by whether the manual creator-selection step exists
/// (Branch B has it, Branch A does not).
abstract class BookingFlowGuard {
  /// Branch-aware ordered steps from content type through confirmation.
  static List<BookingStep> orderedSteps(BookingFlowState state) {
    return [
      BookingStep.contentType,
      BookingStep.shootType,
      BookingStep.schedule,
      BookingStep.details,
      BookingStep.matchingChoice,
      BookingStep.crewCount,
      BookingStep.edits,
      if (state.isManualBranch) BookingStep.creatorSelection,
      BookingStep.addons,
      BookingStep.review,
      BookingStep.confirmPay,
      BookingStep.payment,
      BookingStep.confirmation,
    ];
  }

  /// Whether the data prerequisites for [step] are satisfied. This checks real
  /// saved state, not just the `completedSteps` set, so a tampered/partial
  /// draft cannot deep-link past a missing save.
  static bool prerequisitesMet(BookingFlowState state, BookingStep step) {
    final hasBooking = state.bookingId != null;
    switch (step) {
      case BookingStep.contentType:
        return true;
      case BookingStep.shootType:
        return state.contentType != null && hasBooking;
      case BookingStep.schedule:
        return (state.shootTypeName ?? '').isNotEmpty && hasBooking;
      case BookingStep.details:
        return (state.schedule?.isValid ?? false) && hasBooking;
      case BookingStep.matchingChoice:
        return state.isStepComplete(BookingStep.details);
      case BookingStep.crewCount:
        return state.matchingBranch != null;
      case BookingStep.edits:
        return state.isStepComplete(BookingStep.crewCount);
      case BookingStep.creatorSelection:
        return state.isManualBranch && state.isStepComplete(BookingStep.edits);
      case BookingStep.addons:
        if (state.isManualBranch) {
          return state.isStepComplete(BookingStep.creatorSelection);
        }
        return state.isStepComplete(BookingStep.edits);
      case BookingStep.review:
        return state.isStepComplete(BookingStep.addons);
      case BookingStep.confirmPay:
        // Confirm & Pay must not recalculate — it needs a fresh saved quote.
        return state.isQuoteFresh;
      case BookingStep.payment:
        return state.isStepComplete(BookingStep.confirmPay);
      case BookingStep.confirmation:
        return state.isStepComplete(BookingStep.payment);
    }
  }

  /// Earliest step that is reachable but not yet complete — the resume target
  /// after a cold start. Falls back to content type.
  static BookingStep resumeStep(BookingFlowState state) {
    for (final step in orderedSteps(state)) {
      if (!prerequisitesMet(state, step)) {
        // A prior save is missing — resume at the last satisfiable step.
        final idx = orderedSteps(state).indexOf(step);
        return idx <= 0 ? BookingStep.contentType : orderedSteps(state)[idx - 1];
      }
      if (!state.isStepComplete(step)) return step;
    }
    return BookingStep.confirmation;
  }
}
