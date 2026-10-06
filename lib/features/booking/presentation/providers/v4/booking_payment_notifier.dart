import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beige/core/firebase/analytics_events.dart';
import 'package:beige/core/firebase/analytics_service.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_summary.dart';
import 'package:beige/features/booking/domain/entities/payment_sheet_config.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_payment_gateway.dart';

enum BookingPaymentStatus {
  idle,
  submitting,
  presentingPayment,
  verifying,
  success,
  pendingVerification,
  failed,
}

@immutable
class BookingPaymentState {
  const BookingPaymentState({
    this.status = BookingPaymentStatus.idle,
    this.selectedMethod = BookingPaymentMethod.stripe,
    this.errorMessage,
    this.summary,
    this.config,
    this.attempts = 0,
  });

  final BookingPaymentStatus status;
  final BookingPaymentMethod selectedMethod;
  final String? errorMessage;
  final BookingSummary? summary;
  final PaymentSheetConfig? config;
  final int attempts;

  bool get isLoading =>
      status == BookingPaymentStatus.submitting ||
      status == BookingPaymentStatus.presentingPayment ||
      status == BookingPaymentStatus.verifying;

  bool get isSuccess => status == BookingPaymentStatus.success;
  bool get isFailed => status == BookingPaymentStatus.failed;
  bool get isPendingVerification =>
      status == BookingPaymentStatus.pendingVerification;

  BookingPaymentState copyWith({
    BookingPaymentStatus? status,
    BookingPaymentMethod? selectedMethod,
    String? errorMessage,
    BookingSummary? summary,
    PaymentSheetConfig? config,
    int? attempts,
    bool clearError = false,
  }) {
    return BookingPaymentState(
      status: status ?? this.status,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      summary: summary ?? this.summary,
      config: config ?? this.config,
      attempts: attempts ?? this.attempts,
    );
  }
}

class BookingPaymentNotifier extends AutoDisposeNotifier<BookingPaymentState> {
  @override
  BookingPaymentState build() {
    return const BookingPaymentState();
  }

  void selectMethod(BookingPaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void resetError() {
    state = state.copyWith(
      status: BookingPaymentStatus.idle,
      clearError: true,
    );
  }

  /// Full Phase 6 submit and pay sequence:
  /// 1. `PUT /bookings/:id/submit` (preserves state on failure; does NOT create payment session).
  /// 2. `POST /bookings/:id/paymentsheet` for explicit provider.
  /// 3. Present Stripe SDK or Commas embedded WebView.
  /// 4. Webhook verification loop with bounded checks against `GET /bookings/:id/summary-details`.
  Future<bool> submitAndPay(
    BuildContext context, {
    BookingPaymentMethod? method,
  }) async {
    if (state.isLoading) return false;

    final repo = ref.read(bookingRepositoryProvider);
    final gateway = ref.read(bookingPaymentGatewayProvider);
    final flowState = ref.read(bookingFlowControllerProvider);
    final bookingId = flowState.bookingId;

    if (bookingId == null) {
      state = state.copyWith(
        status: BookingPaymentStatus.failed,
        errorMessage: 'Missing booking ID. Please restart the booking.',
      );
      return false;
    }

    final chosenMethod = method ?? state.selectedMethod;
    state = state.copyWith(
      status: BookingPaymentStatus.submitting,
      selectedMethod: chosenMethod,
      clearError: true,
    );

    // Track analytics with versioned funnel metadata
    final flowVersionParams = {
      'flow_version': 4,
      'step_key': BookingStep.confirmPay.name,
      'schedule_mode': flowState.schedule?.mode.name ?? 'unknown',
      'matching_branch': flowState.matchingBranch?.name ?? 'unknown',
    };

    AnalyticsService.logEvent(
      AnalyticsEvents.paymentInitiated,
      params: {
        ...flowVersionParams,
        'booking_id': bookingId,
        'method': chosenMethod.wireValue,
      },
    );

    // ── 1. Final Submit ───────────────────────────────────────────────────
    final submitRes = await repo.submitBooking(
      bookingId: bookingId,
      request: flowState.toSubmitRequest(),
    );

    final submitFailed = submitRes.fold(
      (err) {
        state = state.copyWith(
          status: BookingPaymentStatus.failed,
          errorMessage: err.message,
        );
        AnalyticsService.logEvent(
          AnalyticsEvents.paymentFailed,
          params: {
            ...flowVersionParams,
            'stage': 'submit',
            'error': err.message,
          },
        );
        return true;
      },
      (_) => false,
    );

    if (submitFailed) return false;

    // ── 2. Create Payment Sheet ───────────────────────────────────────────
    state = state.copyWith(status: BookingPaymentStatus.presentingPayment);

    final sheetRes = await repo.createPaymentSheet(
      bookingId: bookingId,
      method: chosenMethod,
    );

    PaymentSheetConfig? config;
    final sheetFailed = sheetRes.fold(
      (err) {
        state = state.copyWith(
          status: BookingPaymentStatus.failed,
          errorMessage: err.message,
        );
        AnalyticsService.logEvent(
          AnalyticsEvents.paymentFailed,
          params: {
            ...flowVersionParams,
            'stage': 'paymentsheet',
            'error': err.message,
          },
        );
        return true;
      },
      (cfg) {
        config = cfg;
        return false;
      },
    );

    if (sheetFailed || config == null) return false;

    if (!config!.isUsable) {
      state = state.copyWith(
        status: BookingPaymentStatus.failed,
        errorMessage: 'Invalid payment session data returned from server.',
      );
      return false;
    }

    state = state.copyWith(config: config);

    // ── 3. Present Payment Gateway ────────────────────────────────────────
    if (!context.mounted) return false;
    PaymentGatewayResult gatewayResult;
    if (chosenMethod == BookingPaymentMethod.stripe) {
      gatewayResult = await gateway.presentStripe(
        context: context,
        config: config!,
      );
    } else {
      gatewayResult = await gateway.presentCommas(
        context: context,
        bookingId: bookingId,
        checkoutUrl: config!.commasCheckoutUrl!,
      );
    }

    if (gatewayResult == PaymentGatewayResult.canceled) {
      // User dismissed or canceled checkout — return to idle gracefully
      state = state.copyWith(status: BookingPaymentStatus.idle);
      return false;
    }

    if (gatewayResult == PaymentGatewayResult.failed) {
      state = state.copyWith(
        status: BookingPaymentStatus.failed,
        errorMessage: 'Payment was not completed. Please try again.',
      );
      AnalyticsService.logEvent(
        AnalyticsEvents.paymentFailed,
        params: {
          ...flowVersionParams,
          'stage': 'gateway',
        },
      );
      return false;
    }

    // ── 4. Webhook Verification Loop ──────────────────────────────────────
    return verifyPayment(bookingId);
  }

  /// Bounded status verification against `GET /bookings/:id/summary-details`.
  Future<bool> verifyPayment(int bookingId) async {
    final repo = ref.read(bookingRepositoryProvider);
    final flowState = ref.read(bookingFlowControllerProvider);
    final flowVersionParams = {
      'flow_version': 4,
      'step_key': BookingStep.confirmation.name,
      'schedule_mode': flowState.schedule?.mode.name ?? 'unknown',
      'matching_branch': flowState.matchingBranch?.name ?? 'unknown',
    };

    state = state.copyWith(
      status: BookingPaymentStatus.verifying,
      attempts: 0,
      clearError: true,
    );

    const maxAttempts = 4;
    int currentAttempt = 0;
    BookingSummary? lastSummary;

    while (currentAttempt < maxAttempts) {
      currentAttempt++;
      state = state.copyWith(attempts: currentAttempt);

      final summaryRes = await repo.getBookingSummary(bookingId: bookingId);
      final summary = summaryRes.fold((_) => null, (s) => s);

      if (summary != null) {
        lastSummary = summary;
        if (summary.isPaid) {
          // Success confirmed! Update wizard state & clear persisted draft
          final controller = ref.read(bookingFlowControllerProvider.notifier);
          controller
            ..markStepComplete(BookingStep.confirmPay)
            ..markStepComplete(BookingStep.payment)
            ..setCurrentStep(BookingStep.confirmation);
          await controller.clearDraft();

          state = state.copyWith(
            status: BookingPaymentStatus.success,
            summary: summary,
          );

          AnalyticsService.logEvent(
            AnalyticsEvents.paymentSuccess,
            params: {
              ...flowVersionParams,
              'booking_id': bookingId,
            },
          );
          AnalyticsService.logEvent(
            AnalyticsEvents.purchase,
            params: {
              ...flowVersionParams,
              'booking_id': bookingId,
              'amount': summary.finalAmountText ?? '',
            },
          );
          return true;
        }
      }

      if (currentAttempt < maxAttempts) {
        await Future.delayed(
          Duration(milliseconds: currentAttempt == 1 ? 1200 : 2000),
        );
      }
    }

    // Polling bounded checks exhausted before backend confirmation
    state = state.copyWith(
      status: BookingPaymentStatus.pendingVerification,
      summary: lastSummary,
    );
    return false;
  }
}

final bookingPaymentNotifierProvider =
    AutoDisposeNotifierProvider<BookingPaymentNotifier, BookingPaymentState>(
      BookingPaymentNotifier.new,
    );
