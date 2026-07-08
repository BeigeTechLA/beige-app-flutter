import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_filter.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:beige/features/meetings/presentation/widgets/meeting_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('Apply disabled until a chip is toggled', (tester) async {
    await tester.pumpProviderApp(
      const Scaffold(body: MeetingFilterSheet(current: MeetingFilter.empty)),
    );

    final apply = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Apply'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(apply.onPressed, isNull);
  });

  testWidgets(
    'tapping a category chip enables Apply and returns the filter on tap',
    (tester) async {
      MeetingFilter? popped;
      await tester.pumpProviderApp(
        Material(
          child: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  popped = await Navigator.of(ctx).push<MeetingFilter>(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: MeetingFilterSheet(current: MeetingFilter.empty),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(MeetingCategory.commercial.label));
      await tester.pump();

      await tester.ensureVisible(find.text('Apply'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(popped, isNotNull);
      expect(popped!.categories, contains(MeetingCategory.commercial));
    },
  );

  testWidgets('Clear All resets staged draft to empty', (tester) async {
    await tester.pumpProviderApp(
      const Scaffold(
        body: MeetingFilterSheet(
          current: MeetingFilter(
            categories: {MeetingCategory.commercial},
            statuses: {MeetingStatus.completed},
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Clear All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear All'));
    await tester.pump();

    // After Clear, draft equals empty. Apply enabled because draft now differs
    // from `current` (which had selections).
    final apply = tester.widget<ElevatedButton>(
      find.ancestor(
        of: find.text('Apply'),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(apply.onPressed, isNotNull);
  });
}
