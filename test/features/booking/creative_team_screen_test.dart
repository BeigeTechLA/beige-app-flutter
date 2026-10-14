import 'package:beige/features/booking/presentation/screens/creative_team_screen.dart';
import 'package:beige/features/booking/presentation/widgets/wizard_bottom_bar.dart';
import 'package:beige/shared/widgets/app_qty_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(String contentType) => ProviderScope(
  child: MaterialApp(
    home: CreativeTeamScreen(bookingId: 1, contentType: contentType),
  ),
);

void main() {
  testWidgets('hybrid explanation stays visible whenever hybrid is available', (
    tester,
  ) async {
    const message =
        'One Creative Partner captures both photo and video, so '
        'fewer moments can be captured at once. For full coverage, '
        'book a dedicated Photographer and Videographer.';
    await tester.pumpWidget(_host('photographer,videographer'));
    expect(find.text(message), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    expect(find.text(message), findsOneWidget);

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    expect(find.text(message), findsOneWidget);
  });

  testWidgets('hybrid counts toward the team total and is limited to one', (
    tester,
  ) async {
    await tester.pumpWidget(_host('photographer,videographer'));

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(
      find.text(
        'You’re all set! Three Creative Partners are '
        'a great fit for covering your event.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<AppQtyCounter>(find.byType(AppQtyCounter).last).onIncrement,
      isNull,
    );
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(
      tester.widget<AppQtyCounter>(find.byType(AppQtyCounter).last).value,
      1,
    );

    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(
      find.text(
        'You’re all set! One Creative Partner is '
        'a great fit for covering your event.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(Checkbox).last);
    await tester.pump();
    expect(find.textContaining('You’re all set!'), findsNothing);
    expect(
      tester.widget<AppQtyCounter>(find.byType(AppQtyCounter).last).onIncrement,
      isNotNull,
    );
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pump();
    expect(
      tester.widget<AppQtyCounter>(find.byType(AppQtyCounter).last).value,
      1,
    );
  });

  for (final role in ['photographer', 'videographer']) {
    testWidgets('$role starts selected with one creator and remains editable', (
      tester,
    ) async {
      await tester.pumpWidget(_host(role));
      expect(
        find.textContaining('One Creative Partner captures'),
        findsNothing,
      );
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(tester.widget<AppQtyCounter>(find.byType(AppQtyCounter)).value, 1);
      expect(
        tester.widget<WizardBottomBar>(find.byType(WizardBottomBar)).onContinue,
        isNotNull,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(tester.widget<AppQtyCounter>(find.byType(AppQtyCounter)).value, 2);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<AppQtyCounter>(find.byType(AppQtyCounter)).value, 0);
      expect(
        tester.widget<WizardBottomBar>(find.byType(WizardBottomBar)).onContinue,
        isNull,
      );

      final label = role == 'photographer' ? 'Photographer' : 'Videographer';
      await tester.tap(find.text(label));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      expect(tester.widget<AppQtyCounter>(find.byType(AppQtyCounter)).value, 1);
    });
  }

  testWidgets(
    'combined booking starts with one photographer and videographer',
    (tester) async {
      await tester.pumpWidget(_host('photographer,videographer'));
      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .map((checkbox) => checkbox.value),
        [true, true, false],
      );
      expect(
        tester
            .widgetList<AppQtyCounter>(find.byType(AppQtyCounter))
            .map((counter) => counter.value),
        [1, 1, 0],
      );
      expect(
        tester.widget<WizardBottomBar>(find.byType(WizardBottomBar)).onContinue,
        isNotNull,
      );
    },
  );
}
