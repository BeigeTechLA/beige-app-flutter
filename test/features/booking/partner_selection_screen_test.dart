import 'package:beige/features/booking/presentation/providers/partner_matches_notifier.dart';
import 'package:beige/features/booking/presentation/screens/partner_selection_screen.dart';
import 'package:beige/features/booking/presentation/widgets/create_project_app_bar.dart';
import 'package:beige/features/booking/presentation/widgets/wizard_bottom_bar.dart';
import 'package:beige/shared/widgets/finding_creative_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControlledMatches extends PartnerMatchesNotifier {
  @override
  Future<void> load({
    required int bookingId,
    required Map<String, int> roleCounts,
  }) async {
    state = state.copyWith(status: PartnerMatchesStatus.loading);
  }

  void complete({bool fail = false}) {
    state = state.copyWith(
      status: fail ? PartnerMatchesStatus.error : PartnerMatchesStatus.loaded,
      errorMessage: fail ? 'Unable to load partners' : null,
      matches: const [
        PartnerMatch(
          id: 1,
          name: 'Test Creator',
          roleLabel: 'Photographer',
          capabilities: {'photographer'},
        ),
      ],
    );
  }
}

void main() {
  for (final fail in [false, true]) {
    testWidgets('matching loader transitions to ${fail ? 'retry' : 'results'}', (
      tester,
    ) async {
      final notifier = _ControlledMatches();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            partnerMatchesNotifierProvider.overrideWith(() => notifier),
          ],
          child: const MaterialApp(home: PartnerSelectionScreen(bookingId: 1)),
        ),
      );
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(FindingCreativeLoader), findsOneWidget);
      expect(find.text('Finding The Perfect Creator\nFor You...'), findsOneWidget);
      expect(find.byType(CreateProjectAppBar), findsNothing);
      expect(find.byType(WizardBottomBar), findsNothing);

      notifier.complete(fail: fail);
      await tester.pump();

      expect(find.byType(FindingCreativeLoader), findsNothing);
      expect(find.byType(CreateProjectAppBar), findsOneWidget);
      if (fail) {
        expect(find.text('Unable to load partners'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        await tester.pump();
        expect(find.byType(FindingCreativeLoader), findsOneWidget);
        expect(find.byType(WizardBottomBar), findsNothing);
      } else {
        expect(find.text('Select Your Dream Team'), findsOneWidget);
        expect(find.text('Test Creator'), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }
}
