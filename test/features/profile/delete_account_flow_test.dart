import 'package:beige/app/theme.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:beige/features/profile/presentation/screens/delete_account_otp_screen.dart';
import 'package:beige/features/profile/presentation/screens/delete_account_success_screen.dart';
import 'package:beige/features/profile/presentation/providers/delete_account_notifier.dart';
import 'package:beige/features/profile/presentation/providers/delete_account_otp_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter router({String initial = '/'}) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const DeleteAccountScreen()),
    GoRoute(
      path: '/otp',
      name: RouteNames.deleteAccountOtp,
      builder: (_, _) => const DeleteAccountOtpScreen(),
    ),
    GoRoute(
      path: '/success',
      name: RouteNames.deleteAccountSuccess,
      builder: (_, _) => const DeleteAccountSuccessScreen(),
    ),
  ],
);

void main() {
  test(
    'legacy deletion methods stay inert without repository dependencies',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final request = container.listen(
        deleteAccountNotifierProvider,
        (_, _) {},
      );
      final otp = container.listen(deleteAccountOtpNotifierProvider, (_, _) {});
      await container
          .read(deleteAccountNotifierProvider.notifier)
          .requestDelete('test');
      expect(request.read().status, DeleteAccountStatus.error);
      await container
          .read(deleteAccountOtpNotifierProvider.notifier)
          .confirmDelete('123456');
      expect(otp.read().confirmStatus, DeleteOtpStatus.error);
      await container
          .read(deleteAccountOtpNotifierProvider.notifier)
          .resendOtp();
      expect(otp.read().resendStatus, DeleteOtpStatus.error);
    },
  );

  testWidgets(
    'preview flow supports paste, resend, and success without auth or API providers',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final r = router();
      addTearDown(r.dispose);
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: r, theme: AppTheme.dark()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue & Proceed to Verification'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('deletion-otp-0')),
        '12a3456',
      );
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('deletion-otp-5')))
            .controller!
            .text,
        '6',
      );
      await tester.tap(find.text('Resend OTP'));
      await tester.pump();
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      expect(
        find.text('UI preview: fields reset. No verification email was sent.'),
        findsOneWidget,
      );
      for (var i = 0; i < 6; i++) {
        await tester.enterText(find.byKey(ValueKey('deletion-otp-$i')), '$i');
      }
      await tester.pump();
      await tester.tap(find.text('Verify & Delete my Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account Deletion Requested'), findsOneWidget);
      expect(
        find.text(
          'UI preview only. No email is sent and your account is unchanged.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('OTP fits a narrow viewport with keyboard and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.reset);
    final r = router(initial: '/otp');
    addTearDown(r.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: r,
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Verify & Delete my Account'));
    expect(tester.takeException(), isNull);
  });
}
