import 'package:beige/features/meetings/domain/models/meetings_tab.dart';
import 'package:beige/features/meetings/presentation/widgets/meetings_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders both labels', (tester) async {
    await tester.pumpProviderApp(
      Material(
        child: MeetingsTabBar(
          selected: MeetingsTab.upcoming,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('tap on inactive pill fires onChanged with the right enum',
      (tester) async {
    MeetingsTab? captured;
    await tester.pumpProviderApp(
      Material(
        child: MeetingsTabBar(
          selected: MeetingsTab.upcoming,
          onChanged: (v) => captured = v,
        ),
      ),
    );

    await tester.tap(find.text('Completed'));
    await tester.pump();

    expect(captured, MeetingsTab.completed);
  });

  testWidgets('tap on active pill still emits (parent decides no-op)',
      (tester) async {
    int hits = 0;
    await tester.pumpProviderApp(
      Material(
        child: MeetingsTabBar(
          selected: MeetingsTab.upcoming,
          onChanged: (_) => hits += 1,
        ),
      ),
    );

    await tester.tap(find.text('Upcoming'));
    await tester.pump();

    expect(hits, 1);
  });
}
