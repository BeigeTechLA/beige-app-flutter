import 'package:beige/features/booking/domain/entities/booking_flow_enums.dart';
import 'package:beige/features/booking/presentation/screens/partner_preference_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({MatchingMethod? initialMethod}) => ProviderScope(
  child: MaterialApp(
    home: PartnerPreferenceScreen(
      bookingId: 1,
      contentType: 'photographer',
      initialMethod: initialMethod,
    ),
  ),
);

ElevatedButton _continueButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.byType(ElevatedButton));

void main() {
  testWidgets('renders both choices and the AI matchmaker info', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.text('Let Beige Match Me'), findsOneWidget);
    expect(find.text('Choose my Creative Partner'), findsOneWidget);
    expect(find.text('About AI Matchmaker'), findsOneWidget);
  });

  testWidgets('Beige matching is selected by default with Continue enabled', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
    expect(
      find.textContaining("We'll find the right Creative Partner"),
      findsOneWidget,
    );

    await tester.tap(find.text('Choose my Creative Partner'));
    await tester.pump();

    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('info copy adapts to the selected matching method', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(
      find.textContaining("We'll find the right Creative Partner"),
      findsOneWidget,
    );

    await tester.tap(find.text('Choose my Creative Partner'));
    await tester.pump();

    expect(
      find.textContaining('Discover our Creative Partners'),
      findsOneWidget,
    );

    await tester.tap(find.text('Let Beige Match Me'));
    await tester.pump();

    expect(
      find.textContaining("We'll find the right Creative Partner"),
      findsOneWidget,
    );
    expect(find.textContaining('Discover our Creative Partners'), findsNothing);
  });

  testWidgets('preserves an existing manual matching choice', (tester) async {
    await tester.pumpWidget(_harness(initialMethod: MatchingMethod.manual));
    await tester.pump();

    expect(
      find.textContaining('Discover our Creative Partners'),
      findsOneWidget,
    );
    expect(
      find.textContaining("We'll find the right Creative Partner"),
      findsNothing,
    );
    expect(_continueButton(tester).onPressed, isNotNull);
  });
}
