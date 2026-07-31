import 'package:beige/shared/widgets/top_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('does not remove the overlay twice after manual dismissal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => TopMessage.show(context, 'Something went wrong'),
            child: const Text('Show message'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show message'));
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('Something went wrong'), findsNothing);

    await tester.pump(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
  });
}
