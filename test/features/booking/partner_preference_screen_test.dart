import 'package:beige/features/booking/presentation/screens/partner_preference_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness() => const ProviderScope(
      child: MaterialApp(
        home: PartnerPreferenceScreen(bookingId: 1, contentType: 'photographer'),
      ),
    );

ElevatedButton _continueButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.byType(ElevatedButton));

void main() {
  testWidgets('renders both choices and the AI matchmaker info', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.text('Let Beige Match Me'), findsOneWidget);
    expect(find.text('Choose my Creative Partner'), findsOneWidget);
    expect(find.text('About AI Matchmaker'), findsOneWidget);
  });

  testWidgets('Continue is disabled until a choice is made', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Choose my Creative Partner'));
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('info copy adapts to the selected matching method',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    // Manual default copy.
    expect(find.textContaining('Discover our Creative Partners'), findsOneWidget);

    await tester.tap(find.text('Let Beige Match Me'));
    await tester.pump();

    expect(find.textContaining("We'll find the right Creative Partner"),
        findsOneWidget);
    expect(find.textContaining('Discover our Creative Partners'), findsNothing);
  });
}
