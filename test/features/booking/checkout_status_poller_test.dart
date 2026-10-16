import 'dart:async';

import 'package:beige/features/payment/presentation/providers/checkout_status_poller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('confirmed payment finishes once without a redirect', (
    tester,
  ) async {
    var requests = 0;
    var completions = 0;
    final poller = CheckoutStatusPoller(
      isPaid: () async => ++requests == 2,
      onPaid: () => completions++,
    )..start();
    addTearDown(poller.stop);
    await tester.pump(const Duration(seconds: 3));
    expect(completions, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(completions, 1);
    await tester.pump(const Duration(seconds: 30));
    expect(requests, 2);
    expect(completions, 1);
  });

  testWidgets('status errors retry without closing checkout', (tester) async {
    var requests = 0;
    var completions = 0;
    final poller = CheckoutStatusPoller(
      isPaid: () async {
        if (++requests == 1) throw Exception('offline');
        return true;
      },
      onPaid: () => completions++,
    )..start();
    addTearDown(poller.stop);
    await tester.pump(const Duration(seconds: 3));
    expect(completions, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(completions, 1);
  });

  testWidgets(
    'slow requests do not overlap and dismissal ignores late success',
    (tester) async {
      final response = Completer<bool>();
      var requests = 0;
      var completions = 0;
      final poller = CheckoutStatusPoller(
        isPaid: () {
          requests++;
          return response.future;
        },
        onPaid: () => completions++,
      )..start();
      addTearDown(poller.stop);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 30));
      expect(requests, 1);
      poller.stop();
      response.complete(true);
      await tester.pump();
      expect(completions, 0);
      await tester.pump(const Duration(seconds: 30));
      expect(requests, 1);
    },
  );

  testWidgets('unconfirmed payment stays open and stopping cancels polling', (
    tester,
  ) async {
    var requests = 0;
    final poller = CheckoutStatusPoller(
      isPaid: () async {
        requests++;
        return false;
      },
      onPaid: () => fail('Unconfirmed payment must not close checkout'),
    )..start();
    addTearDown(poller.stop);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(requests, 2);
    poller.stop();
    await tester.pump(const Duration(seconds: 30));
    expect(requests, 2);
  });
}
