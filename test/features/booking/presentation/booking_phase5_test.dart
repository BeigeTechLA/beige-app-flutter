import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/exceptions/app_exception.dart';
import 'package:beige/core/providers/core_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:beige/features/booking/domain/entities/addon_catalogue_item.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_review.dart';
import 'package:beige/features/booking/domain/entities/payment_review.dart';
import 'package:beige/features/booking/domain/entities/submit_request.dart';
import 'package:beige/features/booking/domain/repositories/booking_repository.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_addons_notifier.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_review_notifier.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_review_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/booking_addons_screen.dart';
import 'package:beige/features/booking/presentation/screens/v4/booking_confirm_pay_screen.dart';
import 'package:beige/features/booking/presentation/screens/v4/booking_review_contact_screen.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late _MockBookingRepository repo;

  setUp(() {
    repo = _MockBookingRepository();
  });

  const addon1 = AddonCatalogueItem(
    slug: 'v4-extra-camera',
    title: 'Additional 4K Camera',
    description: 'Second angle for dynamic cuts.',
    price: 150,
    priceLabel: '+\$150',
  );

  const addon2 = AddonCatalogueItem(
    slug: 'v4-teleprompter',
    title: 'Studio Teleprompter',
    description: '17-inch teleprompter with operator.',
    price: 75,
    priceLabel: '+\$75',
  );

  final mockReview = BookingReview(
    service: 'Videographer',
    occasion: 'Corporate Event',
    description: 'Annual keynotes and executive interviews.',
    schedule: const {
      'event_date': '2026-10-15',
      'start_time': '09:00',
      'end_time': '17:00',
      'duration': 8,
      'event_location': '777 Tower Way, Los Angeles, CA',
    },
    editingServices: const EditingServicesView(
      photoEdits: [],
      videoEdits: [
        EditServiceRow(label: 'Highlight Reel (3-5 min)', key: 'highlight'),
      ],
      receiveText: 'Receive 1 edited video in 48 hours',
    ),
    addOns: const ['Additional 4K Camera x1'],
    includedServices: const [
      '\$1M Liability Insurance',
      'Beige Guarantee',
    ],
    contactFullName: 'Alice Client',
    contactEmail: 'alice@example.com',
    contactPhone: '5551234567',
  );

  const mockPaymentReview = PaymentReview(
    packageService: 'Corporate Video Package',
    includedServices: ['\$1M Liability Insurance', 'Beige Guarantee'],
    crew: ['Videographer x1'],
    editingServices: EditingServicesView(
      receiveText: 'Receive 1 edited video in 48 hours',
    ),
    lineItems: [
      PricingLineItem(label: 'Production Day Rate', amount: 1200, amountLabel: '\$1,200.00'),
      PricingLineItem(label: 'Additional 4K Camera', amount: 150, amountLabel: '\$150.00'),
    ],
    subtotal: 1350,
    subtotalLabel: '\$1,350.00',
    cardProcessingFee: 54,
    cardProcessingFeeLabel: '\$54.00',
    finalAmount: 1404,
    finalAmountLabel: '\$1,404.00',
  );

  group('Phase 5 Providers & Logic', () {
    test('addonCatalogueProvider loads items from repository', () async {
      when(() => repo.getAddonCatalogue()).thenAnswer(
        (_) async => const Right([addon1, addon2]),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final items = await container.read(addonCatalogueProvider.future);
      expect(items.length, 2);
      expect(items.first.title, 'Additional 4K Camera');
    });

    test('BookingQuoteNotifier validates contact and submits quote', () async {
      when(
        () => repo.quoteBooking(
          bookingId: 42,
          addOnItems: any(named: 'addOnItems'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(bookingFlowControllerProvider.notifier);
      controller.setBookingId(42);
      controller.setAddonQuantity('v4-extra-camera', 1);

      final notifier = container.read(bookingQuoteNotifierProvider.notifier);

      // Empty name fails
      final fail1 = await notifier.submitQuote(
        const ContactInfo(fullName: '', email: 'alice@example.com', phone: '5551234567'),
      );
      expect(fail1, isFalse);

      // Invalid email fails
      final fail2 = await notifier.submitQuote(
        const ContactInfo(fullName: 'Alice', email: 'invalid-email', phone: '5551234567'),
      );
      expect(fail2, isFalse);

      // Valid contact succeeds
      final ok = await notifier.submitQuote(
        const ContactInfo(fullName: 'Alice Client', email: 'alice@example.com', phone: '5551234567'),
      );
      expect(ok, isTrue);

      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.isQuoteFresh, isTrue);
      expect(flow.isStepComplete(BookingStep.review), isTrue);
      expect(flow.currentStep, BookingStep.confirmPay);
    });

    test('paymentReviewProvider loads read-only server pricing', () async {
      when(() => repo.getPaymentReview(bookingId: 42)).thenAnswer(
        (_) async => const Right(mockPaymentReview),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      final payment = await container.read(paymentReviewProvider.future);
      expect(payment.finalAmountLabel, '\$1,404.00');
      expect(payment.lineItems.length, 2);
    });
  });

  group('Phase 5 Screen Widget Tests', () {
    testWidgets('BookingAddonsScreen renders catalogue items and changes stepper quantities', (
      tester,
    ) async {
      when(() => repo.getAddonCatalogue()).thenAnswer(
        (_) async => const Right([addon1, addon2]),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BookingAddonsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enhance Your Shoot'), findsOneWidget);
      expect(find.text('Additional 4K Camera'), findsOneWidget);
      expect(find.text('Studio Teleprompter'), findsOneWidget);

      // Tap + on Additional 4K Camera
      final addButtons = find.byIcon(Icons.add);
      expect(addButtons, findsNWidgets(2));
      await tester.tap(addButtons.first);
      await tester.pump();

      final selection = container.read(bookingFlowControllerProvider).addonSelection;
      expect(selection.quantityForSlug('v4-extra-camera'), 1);
      expect(find.text('Continue to Review (1 selected)'), findsOneWidget);
    });

    testWidgets('BookingReviewContactScreen renders summary and validates contact form', (
      tester,
    ) async {
      when(
        () => repo.reviewBooking(
          bookingId: 42,
          addOnItems: any(named: 'addOnItems'),
        ),
      ).thenAnswer((_) async => Right(mockReview));

      when(
        () => repo.quoteBooking(
          bookingId: 42,
          addOnItems: any(named: 'addOnItems'),
        ),
      ).thenAnswer((_) async => const Right(unit));

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = container.read(bookingFlowControllerProvider.notifier);
      controller.setBookingId(42);
      controller.setContact(
        const ContactInfo(
          fullName: 'Alice Client',
          email: 'alice@example.com',
          phone: '5551234567',
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const BookingReviewContactScreen(),
          ),
          GoRoute(
            path: '/confirm-pay',
            name: RouteNames.bookingConfirmPay,
            builder: (_, __) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await container.read(bookingReviewProvider.future);
      await tester.pump();

      expect(find.text('Review Your Project'), findsOneWidget);
      expect(find.text('Corporate Event'), findsOneWidget);
      expect(find.text('Receive 1 edited video in 48 hours'), findsOneWidget);

      // Verify contact fields prefilled
      expect(
        find.byWidgetPredicate(
          (w) => w is TextField && w.controller?.text == 'Alice Client',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is TextField && w.controller?.text == 'alice@example.com',
        ),
        findsOneWidget,
      );

      // Tap Continue to Payment Review
      final continueBtn = find.text('Continue to Payment Review');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final flow = container.read(bookingFlowControllerProvider);
      expect(flow.isQuoteFresh, isTrue);
    });

    testWidgets('BookingConfirmPayScreen renders read-only server pricing receipt', (
      tester,
    ) async {
      when(() => repo.getPaymentReview(bookingId: 42)).thenAnswer(
        (_) async => const Right(mockPaymentReview),
      );

      final prefs = await createMockPrefs();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(bookingFlowControllerProvider.notifier).setBookingId(42);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BookingConfirmPayScreen(),
          ),
        ),
      );

      await container.read(paymentReviewProvider.future);
      await tester.pump();

      expect(find.text('Confirm & Pay'), findsWidgets);
      expect(find.text('Corporate Video Package'), findsOneWidget);
      expect(find.text('Production Day Rate'), findsOneWidget);
      expect(find.text('\$1,200.00'), findsOneWidget);
      expect(find.text('Card Processing Fee'), findsOneWidget);
      expect(find.text('\$54.00'), findsOneWidget);
      expect(find.text('\$1,404.00'), findsWidgets);
      expect(find.text('Confirm & Pay \$1,404.00'), findsOneWidget);
    });
  });
}
