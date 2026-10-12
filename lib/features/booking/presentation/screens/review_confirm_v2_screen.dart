import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../profile/presentation/providers/profile_notifier.dart';
import '../../domain/entities/booking_flow_enums.dart';
import '../../domain/entities/booking_wizard_step.dart';
import '../providers/review_v2_notifier.dart';
import '../widgets/create_project_app_bar.dart';
import 'commas_checkout_screen.dart';

/// Screen 10 of the Book-a-Shoot v2 flow — Review & Confirm + Pay.
///
/// Renders the server-calculated review payload (pricing is never computed in
/// the app), collects contact info, then runs the pay chain:
/// `/quote` → `/submit` → `/paymentsheet` (Commas) → Commas WebView → verify
/// `/summary-details` → Success. The webhook is the trusted source; a backend
/// verification poll runs after the WebView closes before showing success.
class ReviewConfirmV2Screen extends ConsumerStatefulWidget {
  const ReviewConfirmV2Screen({
    super.key,
    required this.bookingId,
    this.contentType,
    this.shootTypeName,
    this.matchingMethod = MatchingMethod.manual,
    this.selectedCrewIds = const [],
    this.addOnItems = const [],
  });

  final int bookingId;
  final String? contentType;
  final String? shootTypeName;
  final MatchingMethod matchingMethod;
  final List<int> selectedCrewIds;
  final List<Map<String, dynamic>> addOnItems;

  @override
  ConsumerState<ReviewConfirmV2Screen> createState() =>
      _ReviewConfirmV2ScreenState();
}

class _ReviewConfirmV2ScreenState extends ConsumerState<ReviewConfirmV2Screen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(reviewV2NotifierProvider.notifier)
          .loadReview(
            bookingId: widget.bookingId,
            addOnItems: widget.addOnItems,
          ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateContactIfEmpty(Map<String, dynamic> contact) {
    final name = (contact['name'] ?? contact['full_name'])?.toString().trim();
    final email = contact['email']?.toString().trim();
    final phone =
        (contact['phone'] ??
                contact['phone_number'] ??
                contact['mobile'] ??
                contact['contact_number'])
            ?.toString();
    if (_nameController.text.isEmpty && name != null && name.isNotEmpty) {
      _nameController.text = name;
    }
    if (_emailController.text.isEmpty && email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
    if (_phoneController.text.isEmpty && phone != null) {
      // Match the previous booking flow's phone normalization.
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      _phoneController.text = digits.length >= 10
          ? digits.substring(digits.length - 10)
          : digits;
    }
  }

  // ── Pay chain ────────────────────────────────────────────────────────

  Future<void> _pay() async {
    if (_processing) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      TopMessage.show(context, 'Please fill in your contact details');
      return;
    }

    setState(() => _processing = true);
    final notifier = ref.read(reviewV2NotifierProvider.notifier);
    try {
      // 1. Quote + submit (contact + selected crew + matching method).
      final submitted = await notifier.quoteAndSubmit(
        bookingId: widget.bookingId,
        fullName: name,
        email: email,
        phone: phone,
        matchingMethod: widget.matchingMethod.apiValue,
        selectedCrewIds: widget.selectedCrewIds,
        addOnItems: widget.addOnItems,
      );
      if (!mounted) return;
      if (!submitted) {
        _showError('Failed to submit booking');
        return;
      }

      // 2. Open Commas checkout session.
      final checkout = await notifier.openCommasCheckout(
        bookingId: widget.bookingId,
      );
      if (!mounted) return;
      if (checkout == null) {
        _showError('Failed to start checkout');
        return;
      }

      // 3. Open embedded checkout WebView, await the redirect outcome.
      final result = await context.pushNamed<CommasCheckoutResult>(
        RouteNames.commasCheckout,
        pathParameters: {'bookingId': widget.bookingId.toString()},
        extra: {'checkoutUrl': checkout.embeddedUrl},
      );
      if (!mounted) return;
      if (result == CommasCheckoutResult.failed) {
        context.goNamed(RouteNames.paymentFailed);
        return;
      }
      if (result != CommasCheckoutResult.success) {
        notifier.resetPaying();
        return;
      }

      // 4. Verify against backend (webhook is trusted); retry while pending.
      var paid = false;
      for (var attempt = 0; attempt < 5; attempt++) {
        paid = await notifier.isPaid(bookingId: widget.bookingId);
        if (paid) break;
        if (attempt == 0 && mounted) {
          TopMessage.show(context, 'Payment confirmation in progress…');
        }
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
      }

      if (!mounted) return;
      if (paid) {
        context.goNamed(
          RouteNames.paymentSuccess,
          pathParameters: {'bookingId': widget.bookingId.toString()},
          extra: {'fullName': name, 'phone': phone, 'paymentMethod': 'commas'},
        );
      } else {
        TopMessage.show(
          context,
          'Still confirming your payment. Check My Shoots shortly.',
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showError(String fallback) {
    final msg = ref.read(reviewV2NotifierProvider).errorMessage;
    TopMessage.show(context, msg ?? fallback);
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewV2NotifierProvider);
    final profileState = ref.watch(profileNotifierProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (profileState.profile != null) {
        _populateContactIfEmpty(profileState.profile!);
      }
      _populateContactIfEmpty(_asMap(state.review?['contact']));
    });

    return AppScaffold(
      hasAppBar: true,
      useSafeArea: true,
      appBar: CreateProjectAppBar(
        step: BookingWizardStep.review,
        method: widget.matchingMethod,
        title: 'Book & Confirm',
      ),
      body: state.status == ReviewV2Status.loading
          ? const Center(child: AppImageLoader(size: 60))
          : state.status == ReviewV2Status.error && state.review == null
          ? _error(state.errorMessage)
          : _content(state.review ?? const {}),
      bottomNavigationBar: _payBar(state.review ?? const {}),
    );
  }

  Widget _content(Map<String, dynamic> review) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHWide),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Confirm',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
          ),
          AppSpacing.verticalBase,
          _summaryCard(review),
          AppSpacing.verticalXl,
          _sectionTitle('Contact Information'),
          AppSpacing.verticalMd,
          AppTextField(label: 'Full Name*', controller: _nameController),
          AppSpacing.verticalMd,
          AppTextField(
            label: 'Email ID*',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          AppSpacing.verticalMd,
          AppTextField(
            label: 'Phone Number*',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          AppSpacing.verticalXl,
          _pricingSummary(review),
        ],
      ),
    );
  }

  Widget _summaryCard(Map<String, dynamic> review) {
    final project = _asMap(review['project']);
    final contentType =
        (project['content_type'] ?? _contentTypeLabel(widget.contentType))
            .toString();
    final title = (project['shoot_type'] ?? widget.shootTypeName ?? '')
        .toString();
    final schedule = _asMap(review['schedule']);
    final dateTbd =
        schedule['is_date_to_be_decided'] == true ||
        schedule['is_date_to_be_decided'] == 1;
    final dateText = dateTbd
        ? ''
        : (schedule['date'] ?? schedule['event_date'] ?? '').toString();
    final timeText = dateTbd
        ? ''
        : (schedule['time'] ?? schedule['time_range'] ?? '').toString();
    final locationText =
        (schedule['location'] ?? schedule['event_location'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contentType.isNotEmpty)
            Text(
              'Content Type: $contentType',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (dateTbd) ...[
            AppSpacing.verticalMd,
            _scheduleRow(
              Icons.schedule,
              'Date & time to be finalised with the Beige team',
            ),
          ],
          if (timeText.isNotEmpty ||
              dateText.isNotEmpty ||
              locationText.isNotEmpty) ...[
            AppSpacing.verticalMd,
            if (timeText.isNotEmpty) _scheduleRow(Icons.access_time, timeText),
            if (dateText.isNotEmpty)
              _scheduleRow(Icons.calendar_today_outlined, dateText),
            if (locationText.isNotEmpty)
              _scheduleRow(Icons.location_on_outlined, locationText),
          ],
        ],
      ),
    );
  }

  Widget _scheduleRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.white54),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
          ),
        ),
      ],
    ),
  );

  Widget _pricingSummary(Map<String, dynamic> review) {
    final pricing = _asMap(review['pricing_summary']);
    final items = (pricing['items'] as List?) ?? const [];
    if (items.isEmpty && pricing.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Pricing Summary'),
        AppSpacing.verticalMd,
        for (final raw in items)
          if (raw is Map)
            _priceRow((raw['label'] ?? '').toString(), _money(raw['amount'])),
        if (pricing['subtotal'] != null) ...[
          const Divider(color: AppColors.white15, height: AppSpacing.lg),
          _priceRow('Sub Total', _money(pricing['subtotal'])),
        ],
        if (pricing['card_processing_fee'] != null)
          _priceRow(
            'Card Payment Charges (4%)',
            _money(pricing['card_processing_fee']),
          ),
        if (pricing['final_amount'] != null) ...[
          const Divider(color: AppColors.white15, height: AppSpacing.lg),
          _priceRow(
            'Final Amount',
            _money(pricing['final_amount']),
            emphasize: true,
          ),
        ],
      ],
    );
  }

  Widget _priceRow(String label, String amount, {bool emphasize = false}) {
    final style = emphasize
        ? AppTextStyles.bodyLargeMedium.copyWith(
            fontSize: 18,
            color: AppColors.white,
          )
        : AppTextStyles.bodySmall.copyWith(color: AppColors.white70);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          Text(amount, style: style),
        ],
      ),
    );
  }

  Widget _payBar(Map<String, dynamic> review) {
    final pricing = _asMap(review['pricing_summary']);
    final finalAmount = pricing['final_amount'];
    final label = finalAmount == null ? 'Pay' : 'Pay ${_money(finalAmount)}';
    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.screenHWide),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _processing ? null : _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
          ),
          child: _processing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                  ),
                )
              : Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontFamily: AppTextStyles.fontFamilyDisplay,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    color: AppColors.black,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
  );

  Widget _error(String? message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? 'Failed to load review',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
          ),
          AppSpacing.verticalBase,
          OutlinedButton(
            onPressed: () => ref
                .read(reviewV2NotifierProvider.notifier)
                .loadReview(
                  bookingId: widget.bookingId,
                  addOnItems: widget.addOnItems,
                ),
            child: Text('Retry', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    ),
  );

  // ── Helpers ──────────────────────────────────────────────────────────

  Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : const {};

  String _money(dynamic value) {
    if (value == null) return '';
    if (value is num) return '\$${value.toStringAsFixed(2)}';
    final s = value.toString();
    return s.startsWith('\$') ? s : '\$$s';
  }

  String _contentTypeLabel(String? content) {
    final c = (content ?? '').toLowerCase();
    final photo = c.contains('photographer');
    final video = c.contains('videographer');
    if (photo && video) return 'Photography, Videography';
    if (video) return 'Videography';
    if (photo) return 'Photography';
    return '';
  }
}
