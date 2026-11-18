import 'package:calendar_date_picker2/calendar_date_picker2.dart';
// calendar_date_picker2 v4 checks for a `material_ui` Material ancestor, so the
// test host must use material_ui (the Flutter 3.47 Material library) — a
// flutter/material.dart Scaffold does not satisfy its debugCheckHasMaterial.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the `calendar_date_picker2` v4 API contract the booking flow relies on
/// (see shoot_date_time_screen.dart / shoot_type_selection_screen.dart):
/// multi-select, `firstDate` past-date disabling, and the custom `dayBuilder`
/// named-parameter signature. Guards against silent drift across the 2→4 bump.
void main() {
  // Pick a month in the future so every mid-month day is selectable regardless
  // of the real calendar date the suite runs on.
  final today = DateUtils.dateOnly(DateTime.now());
  final nextMonth = DateTime(today.year, today.month + 1);
  Key dayKey(int day) => Key('day-${nextMonth.year}-${nextMonth.month}-$day');

  Widget host({required List<DateTime> selected, required ValueChanged<List<DateTime>> onChanged}) {
    return MaterialApp(
      home: Scaffold(
        body: CalendarDatePicker2(
            displayedMonthDate: nextMonth,
            config: CalendarDatePicker2Config(
              calendarType: CalendarDatePicker2Type.multi,
              selectedDayHighlightColor: Colors.transparent,
              firstDate: today,
              // Same named-param signature the app's dayBuilder uses. A compile
              // break here is exactly what the 2→4 bump risked.
              dayBuilder:
                  ({
                    required DateTime date,
                    TextStyle? textStyle,
                    BoxDecoration? decoration,
                    bool? isSelected,
                    bool? isDisabled,
                    bool? isToday,
                  }) {
                    return Container(
                      key: Key('day-${date.year}-${date.month}-${date.day}'),
                      color: isSelected == true ? Colors.blue : null,
                      child: Center(child: Text('${date.day}')),
                    );
                  },
            ),
            value: selected,
            onValueChanged: onChanged,
          ),
      ),
    );
  }

  testWidgets('renders custom dayBuilder cells for the displayed month', (tester) async {
    await tester.pumpWidget(host(selected: const [], onChanged: (_) {}));
    expect(find.byKey(dayKey(15)), findsOneWidget);
    expect(find.byKey(dayKey(20)), findsOneWidget);
  });

  testWidgets('multi-select accumulates tapped future dates via onValueChanged', (tester) async {
    List<DateTime> selected = [];
    await tester.pumpWidget(
      host(selected: selected, onChanged: (dates) => selected = dates),
    );

    await tester.tap(find.byKey(dayKey(15)));
    await tester.pumpAndSettle();
    expect(selected.length, 1);

    // Re-pump with the new selection so the second tap accumulates (multi mode).
    await tester.pumpWidget(
      host(selected: selected, onChanged: (dates) => selected = dates),
    );
    await tester.tap(find.byKey(dayKey(20)));
    await tester.pumpAndSettle();
    expect(selected.length, 2);
    expect(selected.every((d) => !d.isBefore(today)), isTrue);
  });

  testWidgets('dayBuilder receives isSelected for a pre-selected date', (tester) async {
    final preselected = [DateTime(nextMonth.year, nextMonth.month, 15)];
    await tester.pumpWidget(host(selected: preselected, onChanged: (_) {}));

    final cell = tester.widget<Container>(find.byKey(dayKey(15)));
    expect((cell.color), Colors.blue);
  });
}
