import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/restoration/restoration_providers.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_summary.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/booking_providers.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/loading.dart';

/// Provider fetching verified booking summary from `GET /bookings/:id/summary-details`.
/// Ensures success screen relies on server truth, not transient extras alone.
final bookingSummaryDetailsProvider = FutureProvider.autoDispose
    .family<BookingSummary, int>((ref, bookingId) async {
  final repo = ref.read(bookingRepositoryProvider);
  final res = await repo.getBookingSummary(bookingId: bookingId);
  return res.fold(
    (err) => throw Exception(err.message),
    (summary) => summary,
  );
});

/// Screen 12 / Step 12 (Phase 6) — Booking Confirmation Screen.
///
/// Terminal state of the Book-a-Shoot flow. Uses verified server summary details
/// from `GET /bookings/:id/summary-details` to render the confirmed package,
/// booking ID, schedule (or deferred note), and cleared draft state.
class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    this.initialSummary,
  });

  final int bookingId;
  final BookingSummary? initialSummary;

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Flow terminal state: purge drafts so cold start cannot re-enter completed flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(draftStoreProvider).clearBookingDraft();
      ref.read(bookingFlowControllerProvider.notifier).clearDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(
      bookingSummaryDetailsProvider(widget.bookingId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.goNamed(RouteNames.myShoots);
      },
      child: AppScaffold(
        hasAppBar: true,
        appBar: BookingStepHeader.appBar(
          context,
          step: BookingStep.confirmation,
          onBack: () => context.goNamed(RouteNames.myShoots),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: summaryAsync.when(
            loading: () => widget.initialSummary != null
                ? _buildContent(widget.initialSummary!)
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
            error: (_, __) => widget.initialSummary != null
                ? _buildContent(widget.initialSummary!)
                : _buildFallbackContent(),
            data: (summary) => _buildContent(summary),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: BookingPrimaryButton(
              label: 'Go to My Shoots',
              onTap: () => context.goNamed(RouteNames.myShoots),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BookingSummary summary) {
    final isDeferred = summary.isDateToBeDecided;
    final service = summary.serviceName ?? 'Creative Shoot';
    final date = summary.formattedDate;
    final amount = summary.finalAmountText;

    return ListView(
      children: [
        AppSpacing.verticalBase,

        // Lottie Success Animation
        const Center(
          child: AppSuccessAnimation(height: 140, repeat: false),
        ),

        AppSpacing.verticalSm,

        // Title
        Center(
          child: Text(
            'Booking Confirmed!',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontFamily: AppAssets.fontUnbounded,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        AppSpacing.verticalSm,

        Center(
          child: Text(
            'Your payment was confirmed and your shoot order is confirmed.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        AppSpacing.verticalXl,

        // Order Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.white15, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Summary',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: AppRadii.smAll,
                    ),
                    child: Text(
                      '#${summary.bookingId ?? widget.bookingId}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(color: AppColors.white10, height: 24),

              _row('Service', service),
              AppSpacing.verticalSm,

              if (isDeferred) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date & Time',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Date to be decided (within 30 days)',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (date != null && date.isNotEmpty) ...[
                _row('Date & Time', date),
              ],

              if (amount != null && amount.isNotEmpty) ...[
                AppSpacing.verticalSm,
                _row('Total Paid', amount, isBold: true),
              ],
            ],
          ),
        ),

        AppSpacing.verticalBase,

        // Next steps card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadii.mdAll,
            border: Border.all(color: AppColors.white10, width: 0.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              AppSpacing.gapHMd,
              Expanded(
                child: Text(
                  'A receipt and shoot details have been sent to your email address.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        AppSpacing.verticalXl,
      ],
    );
  }

  Widget _buildFallbackContent() {
    return ListView(
      children: [
        AppSpacing.verticalBase,
        const Center(
          child: AppSuccessAnimation(height: 140, repeat: false),
        ),
        AppSpacing.verticalSm,
        Center(
          child: Text(
            'Booking Confirmed!',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontFamily: AppAssets.fontUnbounded,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.verticalSm,
        Center(
          child: Text(
            'Your booking #${widget.bookingId} has been confirmed.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        AppSpacing.verticalXl,
      ],
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: isBold ? AppColors.primary : AppColors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
