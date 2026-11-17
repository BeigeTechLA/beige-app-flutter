import 'package:beige/core/providers/auth_state_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:beige/app/theme.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/core/providers/account_status_provider.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:beige/features/account_deletion/data/account_deletion_repository.dart';
import 'package:beige/features/account_deletion/domain/deletion_request.dart';
import 'package:beige/features/account_deletion/presentation/account_recovery_screens.dart';
import 'package:beige/features/account_deletion/presentation/deletion_provider.dart';
import 'package:beige/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:beige/features/profile/presentation/screens/delete_account_otp_screen.dart';
import 'package:beige/features/profile/presentation/screens/delete_account_success_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDeletionRepository extends AccountDeletionRepository {
  FakeDeletionRepository() : super(Dio());
  int sends = 0, confirmations = 0, cancellations = 0;
  bool failConfirm = false, failCancel = false;
  final request = DeletionRequest(
    id: 'DEL-42',
    status: 'deletion_pending',
    scheduledAt: DateTime(2027, 1, 16),
  );
  @override
  Future<void> requestOtp() async {
    sends++;
  }

  @override
  Future<DeletionRequest> confirm(String otp) async {
    confirmations++;
    if (failConfirm) throw Exception('Invalid code');
    return request;
  }

  @override
  Future<DeletionRequest> status() async => request;
  @override
  Future<DeletionRequest> cancel() async {
    cancellations++;
    if (failCancel) throw Exception('Failed');
    return const DeletionRequest(status: 'cancelled');
  }
}

class TestAuth extends AuthStateNotifier {
  int logouts = 0;
  @override
  bool build() => true;
  @override
  Future<void> logout() async {
    logouts++;
    state = false;
    await ref.read(sharedPreferencesProvider).clear();
    ref.invalidate(deletionProvider);
    ref.invalidate(accountStatusProvider);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Outfit', 'Unbounded']) {
      final loader = FontLoader(family);
      for (final weight in ['Regular']) {
        loader.addFont(rootBundle.load('assets/fonts/$family-$weight.ttf'));
      }
      await loader.load();
    }
  });
  late ProviderContainer container;
  late FakeDeletionRepository repo;
  late GoRouter router;
  final screenshotKey = GlobalKey();

  Future<void> pump(
    WidgetTester tester, {
    String initial = '/delete-account',
    Size size = const Size(375, 812),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'email': 'person@example.com',
      'account_status':
          initial.contains('pending') || initial.contains('cancel')
          ? 'deletion_pending'
          : 'active',
    });
    final prefs = await SharedPreferences.getInstance();
    repo = FakeDeletionRepository();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith(TestAuth.new),
        accountDeletionRepositoryProvider.overrideWithValue(repo),
      ],
    );
    router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.home,
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (_, _) => const Scaffold(body: Text('Login')),
        ),
        GoRoute(
          path: '/delete-account',
          builder: (_, _) => const DeleteAccountScreen(),
        ),
        GoRoute(
          path: '/delete-account-otp',
          name: RouteNames.deleteAccountOtp,
          builder: (_, _) => const DeleteAccountOtpScreen(),
        ),
        GoRoute(
          path: '/delete-account-success',
          name: RouteNames.deleteAccountSuccess,
          builder: (_, _) => const DeleteAccountSuccessScreen(),
        ),
        GoRoute(
          path: '/account-deletion-pending',
          name: RouteNames.accountDeletionPending,
          builder: (_, _) => const AccountDeletionPendingScreen(),
        ),
        GoRoute(
          path: '/cancel-account-deletion',
          name: RouteNames.cancelAccountDeletion,
          builder: (_, _) => const CancelAccountDeletionScreen(),
        ),
      ],
    );
    addTearDown(() {
      router.dispose();
      container.dispose();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: screenshotKey,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: AppTheme.dark(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_DELETION')) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    if (name.contains('restored') || name.contains('requested')) {
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)),
        );
      }
    }
    await tester.runAsync(() async {
      final boundary =
          screenshotKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '/tmp/beige-$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets(
    'profile flow sends and resends OTP and only shows success after confirmation',
    (tester) async {
      await pump(tester);
      await tester.tap(find.text('Continue & Proceed to Verification'));
      await tester.pumpAndSettle();
      expect(repo.sends, 1);
      await tester.enterText(
        find.byKey(const ValueKey('deletion-otp-0')),
        '012345',
      );
      await tester.pump();
      repo.failConfirm = true;
      await tester.tap(find.text('Verify & Delete my Account'));
      await tester.pumpAndSettle();
      expect(find.text('Verify Your Identity'), findsOneWidget);
      expect(container.read(accountStatusProvider), AccountStatus.active);
      await tester.tap(find.text('Resend OTP'));
      await tester.pumpAndSettle();
      expect(repo.sends, 2);
      await tester.pump(const Duration(seconds: 5));
      repo.failConfirm = false;
      await tester.enterText(
        find.byKey(const ValueKey('deletion-otp-0')),
        '654321',
      );
      await tester.pump();
      await tester.tap(find.text('Verify & Delete my Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account Deletion Requested'), findsOneWidget);
      await capture(tester, 'deletion-requested');
      expect(
        find.textContaining('January 16, 2027', findRichText: true),
        findsOneWidget,
      );
      expect(container.read(authStateProvider), isFalse);
      expect(
        (container.read(authStateProvider.notifier) as TestAuth).logouts,
        1,
      );
      expect(container.read(deletionProvider).request, isNull);
      expect(find.textContaining('confirmation email'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'two recovery screens support keep, cancel failure and success state',
    (tester) async {
      await pump(tester, initial: '/account-deletion-pending');
      await capture(tester, 'deletion-pending');
      expect(find.text('Your Account Is Pending Deletion'), findsOneWidget);
      await tester.tap(find.text('Restore Account & Cancel Deletion'));
      await tester.pumpAndSettle();
      await capture(tester, 'deletion-cancel');
      expect(find.text('Signed in as p***@example.com'), findsOneWidget);
      await tester.tap(find.text('Keep Deletion Request Active'));
      await tester.pumpAndSettle();
      expect(repo.cancellations, 0);
      await tester.tap(find.text('Restore Account & Cancel Deletion'));
      await tester.pumpAndSettle();
      repo.failCancel = true;
      await tester.tap(find.text('Cancel Deletion Request'));
      await tester.pumpAndSettle();
      expect(
        container.read(accountStatusProvider),
        AccountStatus.deletionPending,
      );
      expect(find.text('Account Deletion Cancelled'), findsNothing);
      repo.failCancel = false;
      await tester.tap(find.text('Cancel Deletion Request'));
      await tester.pumpAndSettle();
      expect(find.text('Account Deletion Cancelled'), findsOneWidget);
      expect(find.text('DEL-42'), findsOneWidget);
      await capture(tester, 'deletion-restored');
      await tester.tap(find.text('Go to Account'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final path in [
    '/account-deletion-pending',
    '/cancel-account-deletion',
    '/delete-account-otp',
  ]) {
    testWidgets('$path supports narrow screens and large text', (tester) async {
      await pump(
        tester,
        initial: path,
        size: const Size(320, 568),
        textScale: 1.6,
      );
      if (path.contains('otp')) {
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
