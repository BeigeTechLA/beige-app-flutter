import 'package:beige/features/booking/domain/entities/booking_flow_enums.dart';
import 'package:beige/features/booking/presentation/widgets/schedule_choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({bool enableDeferred = false, ScheduleMode? initial}) => MaterialApp(
  home: Scaffold(
    body: ScheduleChoiceSheet(initial: initial, enableDeferred: enableDeferred),
  ),
);

ElevatedButton _continueButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(find.byType(ElevatedButton));

void main() {
  testWidgets('renders both scheduling options', (tester) async {
    await tester.pumpWidget(_host());
    expect(find.text('I have a date'), findsOneWidget);
    expect(find.text("I'll confirm later"), findsOneWidget);
  });

  testWidgets('Continue disabled until a choice is made', (tester) async {
    await tester.pumpWidget(_host());
    expect(_continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('I have a date'));
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('deferred option inert when not enabled', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text("I'll confirm later"));
    await tester.pump();
    // Tapping the disabled option must not enable Continue.
    expect(_continueButton(tester).onPressed, isNull);
  });

  testWidgets('deferred option selectable when enabled', (tester) async {
    await tester.pumpWidget(_host(enableDeferred: true));
    await tester.tap(find.text("I'll confirm later"));
    await tester.pump();
    expect(_continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('initial selection pre-enables Continue', (tester) async {
    await tester.pumpWidget(_host(initial: ScheduleMode.dated));
    expect(_continueButton(tester).onPressed, isNotNull);
  });
}
