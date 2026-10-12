import 'package:beige/features/booking/domain/entities/booking_flow_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_wizard_step.dart';
import 'package:beige/features/booking/presentation/widgets/create_project_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(CreateProjectAppBar bar) => MaterialApp(
  home: Scaffold(appBar: bar, body: const SizedBox()),
);

void main() {
  group('CreateProjectAppBar', () {
    testWidgets('happy path — renders title and X/N badge for the branch', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CreateProjectAppBar(
            step: BookingWizardStep.review,
            method: MatchingMethod.manual,
          ),
        ),
      );
      expect(find.text('Create Project'), findsOneWidget);
      expect(find.text('10/11'), findsOneWidget);
    });

    testWidgets('edge case — same step shows different denominator per branch', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CreateProjectAppBar(
            step: BookingWizardStep.review,
            method: MatchingMethod.beigeMatch,
            title: 'Book & Confirm',
          ),
        ),
      );
      expect(find.text('Book & Confirm'), findsOneWidget);
      expect(find.text('9/10'), findsOneWidget);
    });

    testWidgets('error case — step absent from branch shows no badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CreateProjectAppBar(
            step: BookingWizardStep.partnerSelection,
            method: MatchingMethod.beigeMatch,
          ),
        ),
      );
      // partnerSelection is not part of the beigeMatch branch → empty label.
      expect(find.text('8/10'), findsNothing);
    });

    testWidgets('back arrow hidden when showBack is false', (tester) async {
      await tester.pumpWidget(
        _host(
          const CreateProjectAppBar(
            step: BookingWizardStep.contentType,
            showBack: false,
          ),
        ),
      );
      expect(find.byType(CreateProjectAppBar), findsOneWidget);
      // No SvgPicture back asset rendered.
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('onBack fires when the back arrow is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          CreateProjectAppBar(
            step: BookingWizardStep.shootType,
            onBack: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });
  });
}
