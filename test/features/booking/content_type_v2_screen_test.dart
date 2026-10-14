import 'package:beige/features/booking/presentation/screens/content_type_v2_screen.dart';
import 'package:beige/features/booking/presentation/widgets/wizard_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(String session, {String? contentType, int? bookingId}) =>
    ProviderScope(
      child: MaterialApp(
        home: ContentTypeV2Screen(
          key: ValueKey(session),
          bookingId: bookingId,
          contentType: contentType,
        ),
      ),
    );

void main() {
  testWidgets('fresh booking clears restored and locally selected services', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host('restored', contentType: 'photographer', bookingId: 42),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pumpWidget(_host('fresh'));
    expect(find.byIcon(Icons.check), findsNothing);
    expect(
      tester.widget<WizardBottomBar>(find.byType(WizardBottomBar)).onContinue,
      isNull,
    );

    await tester.tap(find.text('Videography'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Rebuilding the current booking preserves its selection.
    await tester.pumpWidget(_host('fresh'));
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pumpWidget(_host('another-booking'));
    expect(find.byIcon(Icons.check), findsNothing);
    expect(
      tester.widget<WizardBottomBar>(find.byType(WizardBottomBar)).onContinue,
      isNull,
    );
  });
}
