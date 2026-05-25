import 'package:beige/app/colors.dart';
import 'package:beige/shared/widgets/app_booking_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders booking details and handles the primary action', (
    tester,
  ) async {
    var actionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: SizedBox(
              width: 360,
              child: AppBookingCard(
                imagePath: '',
                title: 'Lucas Bennett - Birthday Photography',
                subtitle: 'Mar 12-13, 2025 · 1:30 AM – 1:30 AM',
                actionLabel: 'Book Again',
                actionStyle: AppBookingCardActionStyle.outline,
                onActionTap: () => actionTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Lucas Bennett - Birthday Photography'), findsOneWidget);
    expect(find.text('Mar 12-13, 2025 · 1:30 AM – 1:30 AM'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);

    await tester.tap(find.text('Book Again'));

    expect(actionTapped, isTrue);
  });
}
