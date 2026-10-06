import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/restoration/draft_store.dart';
import 'package:beige/core/restoration/restoration_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_summary.dart';
import 'package:beige/features/booking/domain/entities/payment_sheet_config.dart';
import 'package:beige/features/booking/domain/entities/submit_request.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_gateway.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/booking_confirmation_screen.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_payment_failure_sheet.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_payment_method_sheet.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_payment_processing_overlay.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';

import '../../../helpers/pump_app.dart';

class _MockBookingRepository extends Mock implements BookingRepository {}

class _MockBookingPaymentGateway extends Mock implements BookingPaymentGateway {}

class _MockDraftStore extends Mock implements DraftStore {}

void main() {
  late _MockBookingRepository repo;
  late _MockBookingPaymentGateway gateway;
  late _MockDraftStore draftStore;

  setUpAll(() {
    registerFallbackValue(_MockBuildContext());
    registerFallbackValue(
      const SubmitRequest(
        contact: ContactInfo(),
        selectedCrewIds: [],
      ),
    );
    registerFallbackValue(BookingPaymentMethod.stripe);
    registerFallbackValue(
      const PaymentSheetConfig(method: BookingPaymentMethod.stripe),
    );
  });

  setUp(() {
    repo = _MockBookingRepository();
    gateway = _MockBookingPaymentGateway();
    draftStore = _MockDraftStore();
    when(() => draftStore.clearBookingDraft()).thenAnswer((_) async => true);
    when(() => draftStore.readBookingDraft()).thenReturn(null);
  });

  group('BookingPaymentNotifier — Unit Tests', () {
    test('happy path: submits booking, creates stripe sheet, presents stripe, and confirms', () async {
      when(
        () => repo.submitBooking(
          bookingId: any(named: 'bookingId'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => repo.createPaymentSheet(
          bookingId: any(named: 'bookingId'),
          method: BookingPaymentMethod.stripe,
        ),
      ).thenAnswer(
        (_) async => const Right(
          PaymentSheetConfig(
            method: BookingPaymentMethod.stripe,
            stripePaymentIntentClientSecret: 'pi_test_secret',
            stripeCustomerId: 'cus_123',
          ),
        ),
      );

      when(
        () => gateway.presentStripe(
          context: any(named: 'context'),
          config: any(named: 'config'),
        ),
      ).thenAnswer((_) async => PaymentGatewayResult.success);

      when(
        () => repo.getBookingSummary(bookingId: 42),
      ).thenAnswer(
        (_) async => Right(
          BookingSummary.fromData({
            'id': 42,
            'is_paid': true,
            'package': {'service': 'Photo Shoot'},
            'pricing': {'final_amount': '\$450.00'},
          }),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
          bookingPaymentGatewayProvider.overrideWithValue(gateway),
          draftStoreProvider.overrideWithValue(draftStore),
        ],
      );
      addTearDown(container.dispose);

      // Setup booking ID in flow
      container
          .read(bookingFlowControllerProvider.notifier)
          .setBookingId(42);
      container.read(bookingFlowControllerProvider.notifier).setContact(
            const ContactInfo(
              fullName: 'Alex Test',
              email: 'alex@example.com',
              phone: '5551234567',
            ),
          );

      // Build context mock
      final context = _MockBuildContext();

      final notifier = container.read(bookingPaymentNotifierProvider.notifier);
      final success = await notifier.submitAndPay(
        context,
        method: BookingPaymentMethod.stripe,
      );

      expect(success, isTrue);
      expect(
        container.read(bookingPaymentNotifierProvider).status,
        BookingPaymentStatus.success,
      );
      expect(
        container.read(bookingPaymentNotifierProvider).summary?.isPaid,
        isTrue,
      );

      // Verify submit call
      verify(
        () => repo.submitBooking(
          bookingId: 42,
          request: any(named: 'request'),
        ),
      ).called(1);

      // Verify payment sheet call
      verify(
        () => repo.createPaymentSheet(
          bookingId: 42,
          method: BookingPaymentMethod.stripe,
        ),
      ).called(1);

      // Verify flow controller completed payment step
      final flowState = container.read(bookingFlowControllerProvider);
      expect(flowState.isStepComplete(BookingStep.payment), isTrue);
    });

    test('submit failure: does not create payment sheet and preserves state', () async {
      when(
        () => repo.submitBooking(
          bookingId: any(named: 'bookingId'),
          request: any(named: 'request'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerException(message: 'Invalid contact info')),
      );

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
          bookingPaymentGatewayProvider.overrideWithValue(gateway),
          draftStoreProvider.overrideWithValue(draftStore),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      final notifier = container.read(bookingPaymentNotifierProvider.notifier);
      final success = await notifier.submitAndPay(
        _MockBuildContext(),
        method: BookingPaymentMethod.stripe,
      );

      expect(success, isFalse);
      expect(
        container.read(bookingPaymentNotifierProvider).status,
        BookingPaymentStatus.failed,
      );
      expect(
        container.read(bookingPaymentNotifierProvider).errorMessage,
        'Invalid contact info',
      );

      // Payment sheet MUST NEVER be called when submit fails
      verifyNever(
        () => repo.createPaymentSheet(
          bookingId: any(named: 'bookingId'),
          method: any(named: 'method'),
        ),
      );
      verifyNever(
        () => gateway.presentStripe(
          context: any(named: 'context'),
          config: any(named: 'config'),
        ),
      );
    });

    test('gateway cancel: returns to idle gracefully', () async {
      when(
        () => repo.submitBooking(
          bookingId: any(named: 'bookingId'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => repo.createPaymentSheet(
          bookingId: any(named: 'bookingId'),
          method: any(named: 'method'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          PaymentSheetConfig(
            method: BookingPaymentMethod.stripe,
            stripePaymentIntentClientSecret: 'pi_secret',
          ),
        ),
      );

      when(
        () => gateway.presentStripe(
          context: any(named: 'context'),
          config: any(named: 'config'),
        ),
      ).thenAnswer((_) async => PaymentGatewayResult.canceled);

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
          bookingPaymentGatewayProvider.overrideWithValue(gateway),
          draftStoreProvider.overrideWithValue(draftStore),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      final notifier = container.read(bookingPaymentNotifierProvider.notifier);
      final success = await notifier.submitAndPay(
        _MockBuildContext(),
        method: BookingPaymentMethod.stripe,
      );

      expect(success, isFalse);
      expect(
        container.read(bookingPaymentNotifierProvider).status,
        BookingPaymentStatus.idle,
      );
    });
  });

  group('Phase 6 Widgets', () {
    testWidgets('BookingPaymentMethodSheet switches provider and fires onProceed', (tester) async {
      BookingPaymentMethod? selected;

      await tester.pumpProviderApp(
        Scaffold(
          body: BookingPaymentMethodSheet(
            amountLabel: '\$450.00',
            onProceed: (m) => selected = m,
          ),
        ),
      );

      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('Commas Checkout'), findsOneWidget);
      expect(find.text('\$450.00'), findsOneWidget);

      // Select Commas
      await tester.tap(find.text('Commas Checkout'));
      await tester.pumpAndSettle();

      // Tap Proceed
      await tester.tap(find.byType(BookingPrimaryButton));
      await tester.pumpAndSettle();

      expect(selected, BookingPaymentMethod.commas);
    });

    testWidgets('BookingPaymentFailureSheet renders error and handles retry/change', (tester) async {
      PaymentFailureAction? actionTaken;

      await tester.pumpProviderApp(
        Scaffold(
          body: BookingPaymentFailureSheet(
            errorMessage: 'Card has expired.',
            onAction: (a) => actionTaken = a,
          ),
        ),
      );

      expect(find.text('Payment Incomplete'), findsOneWidget);
      expect(find.text('Card has expired.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Change Payment Method'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(actionTaken, PaymentFailureAction.retry);
    });

    testWidgets('BookingPaymentProcessingOverlay renders pending verification options', (tester) async {
      bool rechecked = false;
      bool wentToShoots = false;

      const pendingState = BookingPaymentState(
        status: BookingPaymentStatus.pendingVerification,
      );

      await tester.pumpProviderApp(
        BookingPaymentProcessingOverlay(
          state: pendingState,
          onRecheck: () => rechecked = true,
          onGoToShoots: () => wentToShoots = true,
        ),
      );

      expect(find.text('Confirmation Pending'), findsOneWidget);
      expect(find.text('Check Status Again'), findsOneWidget);
      expect(find.text('View in My Shoots'), findsOneWidget);

      await tester.tap(find.text('Check Status Again'));
      await tester.pump();
      expect(rechecked, isTrue);

      await tester.tap(find.text('View in My Shoots'));
      await tester.pump();
      expect(wentToShoots, isTrue);
    });

    testWidgets('BookingConfirmationScreen renders verified server summary', (tester) async {
      final summary = BookingSummary.fromData({
        'id': 108,
        'is_paid': true,
        'package': {'service': 'Cinematic Video'},
        'schedule': {'date': '2026-11-20 14:00'},
        'pricing': {'final_amount_label': '\$650.00'},
      });

      when(() => repo.getBookingSummary(bookingId: 108))
          .thenAnswer((_) async => Right(summary));

      await tester.pumpProviderApp(
        BookingConfirmationScreen(
          bookingId: 108,
          initialSummary: summary,
        ),
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
          draftStoreProvider.overrideWithValue(draftStore),
        ],
      );
      await tester.pump();

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('#108'), findsOneWidget);
      expect(find.text('Cinematic Video'), findsOneWidget);
      expect(find.text('2026-11-20 14:00'), findsOneWidget);
      expect(find.text('\$650.00'), findsOneWidget);
      expect(find.text('Go to My Shoots'), findsOneWidget);
    });

    testWidgets('BookingConfirmationScreen renders deferred notice without inventing date', (tester) async {
      final deferredSummary = BookingSummary.fromData({
        'id': 109,
        'is_paid': true,
        'package': {'service': 'Portrait Shoot'},
        'schedule': {'is_date_to_be_decided': true},
        'pricing': {'final_amount_label': '\$300.00'},
      });

      when(() => repo.getBookingSummary(bookingId: 109))
          .thenAnswer((_) async => Right(deferredSummary));

      await tester.pumpProviderApp(
        BookingConfirmationScreen(
          bookingId: 109,
          initialSummary: deferredSummary,
        ),
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
          draftStoreProvider.overrideWithValue(draftStore),
        ],
      );
      await tester.pump();

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('Date to be decided (within 30 days)'), findsOneWidget);
      expect(find.text('#109'), findsOneWidget);
    });
  });
}

class _MockBuildContext extends Mock implements BuildContext {
  @override
  bool get mounted => true;
}
