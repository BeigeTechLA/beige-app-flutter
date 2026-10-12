import 'booking_flow_enums.dart';

/// Logical steps of the Book-a-Shoot v2 wizard, independent of route names.
///
/// Progress is numbered **X/N counting payment success** (decision locked
/// 2026-10-08): manual = 11 steps, beigeMatch = 10 (it skips partner
/// selection). The denominator and position are derived from the active
/// [MatchingMethod] — never hardcoded per screen.
///
/// See docs/features/bookings/booking_flow_v2_implementation_plan.md §8.
enum BookingWizardStep {
  contentType,
  shootType,
  whenWhere,
  creativeBrief,
  partnerPreference,
  creativeTeam,
  editing,
  partnerSelection, // manual branch only
  addOns,
  review,
  paymentSuccess,
}

/// Ordered step list for a given matching method. beigeMatch drops
/// [BookingWizardStep.partnerSelection].
List<BookingWizardStep> wizardStepsFor(MatchingMethod method) {
  return [
    BookingWizardStep.contentType,
    BookingWizardStep.shootType,
    BookingWizardStep.whenWhere,
    BookingWizardStep.creativeBrief,
    BookingWizardStep.partnerPreference,
    BookingWizardStep.creativeTeam,
    BookingWizardStep.editing,
    if (method == MatchingMethod.manual) BookingWizardStep.partnerSelection,
    BookingWizardStep.addOns,
    BookingWizardStep.review,
    BookingWizardStep.paymentSuccess,
  ];
}

/// 1-based position + total for a step in the active branch, e.g. `(8, 11)`.
///
/// When [method] is still unknown (early steps), defaults to the manual list
/// so the shared steps 1–7 number identically in both branches. Returns `null`
/// if the step is not part of the active branch (e.g. partnerSelection under
/// beigeMatch).
({int position, int total})? wizardProgress(
  BookingWizardStep step, {
  MatchingMethod method = MatchingMethod.manual,
}) {
  final steps = wizardStepsFor(method);
  final index = steps.indexOf(step);
  if (index == -1) return null;
  return (position: index + 1, total: steps.length);
}

/// Formats progress as `"8/11"`. Falls back to an empty string when the step
/// is not in the active branch.
String wizardProgressLabel(
  BookingWizardStep step, {
  MatchingMethod method = MatchingMethod.manual,
}) {
  final p = wizardProgress(step, method: method);
  return p == null ? '' : '${p.position}/${p.total}';
}
