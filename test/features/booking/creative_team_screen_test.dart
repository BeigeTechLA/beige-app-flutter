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
  for (final role in ['photographer', 'videographer']) {
    testWidgets('$role starts selected with one creator and remains editable', (
      tester,
    ) async {
      await tester.pumpWidget(_host(role));
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

  testWidgets('combined booking starts with one photographer and videographer', (
    tester,
  ) async {
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
  });
}
