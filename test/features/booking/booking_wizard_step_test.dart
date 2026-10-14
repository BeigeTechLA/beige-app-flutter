import 'package:beige/features/booking/domain/entities/booking_flow_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_wizard_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('wizardStepsFor', () {
    test('manual branch has 11 steps including partner selection', () {
      final steps = wizardStepsFor(MatchingMethod.manual);
      expect(steps.length, 11);
      expect(steps.contains(BookingWizardStep.partnerSelection), true);
      expect(steps.last, BookingWizardStep.paymentSuccess);
    });

    test('beigeMatch branch has 10 steps and skips partner selection', () {
      final steps = wizardStepsFor(MatchingMethod.beigeMatch);
      expect(steps.length, 10);
      expect(steps.contains(BookingWizardStep.partnerSelection), false);
    });

    test('shared steps 1-7 are identical in both branches', () {
      final manual = wizardStepsFor(MatchingMethod.manual).take(7);
      final match = wizardStepsFor(MatchingMethod.beigeMatch).take(7);
      expect(manual, orderedEquals(match));
    });
  });

  group('wizardProgressLabel', () {
    test('happy path — review is 10/11 manual, 9/10 beigeMatch', () {
      expect(
        wizardProgressLabel(BookingWizardStep.review, method: MatchingMethod.manual),
        '10/11',
      );
      expect(
        wizardProgressLabel(BookingWizardStep.review, method: MatchingMethod.beigeMatch),
        '9/10',
      );
    });

    test('success counts as the final step (11/11 or 10/10)', () {
      expect(
        wizardProgressLabel(BookingWizardStep.paymentSuccess, method: MatchingMethod.manual),
        '11/11',
      );
      expect(
        wizardProgressLabel(BookingWizardStep.paymentSuccess, method: MatchingMethod.beigeMatch),
        '10/10',
      );
    });

    test('edge case — add-ons shifts position between branches', () {
      // manual: add-ons is step 9 (after partner selection at 8)
      expect(
        wizardProgressLabel(BookingWizardStep.addOns, method: MatchingMethod.manual),
        '9/11',
      );
      // beigeMatch: add-ons is step 8 (partner selection skipped)
      expect(
        wizardProgressLabel(BookingWizardStep.addOns, method: MatchingMethod.beigeMatch),
        '8/10',
      );
    });

    test('error case — partner selection not in beigeMatch returns empty label', () {
      expect(
        wizardProgressLabel(
          BookingWizardStep.partnerSelection,
          method: MatchingMethod.beigeMatch,
        ),
        '',
      );
      expect(
        wizardProgress(
          BookingWizardStep.partnerSelection,
          method: MatchingMethod.beigeMatch,
        ),
        isNull,
      );
    });
  });

  group('ContentTypeV2.apiValue', () {
    test('maps each enum to the API content_type string', () {
      expect(ContentTypeV2.photographer.apiValue, 'photographer');
      expect(ContentTypeV2.videographer.apiValue, 'videographer');
      expect(ContentTypeV2.both.apiValue, 'photographer,videographer');
    });

    test('fromApiValue parses both orderings of the combined string', () {
      expect(ContentTypeV2.fromApiValue('photographer,videographer'), ContentTypeV2.both);
      expect(ContentTypeV2.fromApiValue('videographer,photographer'), ContentTypeV2.both);
      expect(ContentTypeV2.fromApiValue('photographer'), ContentTypeV2.photographer);
      expect(ContentTypeV2.fromApiValue('junk'), isNull);
    });
  });
}
