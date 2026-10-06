import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/booking_review.dart';
import 'package:beige/features/booking/domain/entities/submit_request.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_review_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';

/// Screen 10 / Screen 9 (Phase 5) — Review + Contact.
///
/// Reads `POST /bookings/:id/review` with the current add-on items.
/// STRICT RULE: NO final pricing, card processing fees, or payment methods are
/// rendered here — Confirm & Pay owns pricing.
///
/// On Continue, validates contact fields and saves the quote via
/// `POST /bookings/:id/quote` with identical add-ons before navigating.
class BookingReviewContactScreen extends ConsumerStatefulWidget {
  const BookingReviewContactScreen({super.key});

  @override
  ConsumerState<BookingReviewContactScreen> createState() =>
      _BookingReviewContactScreenState();
}

class _BookingReviewContactScreenState
    extends ConsumerState<BookingReviewContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    final existingContact = ref.read(bookingFlowControllerProvider).contact;
    _nameController.text = existingContact.fullName;
    _emailController.text = existingContact.email;
    _phoneController.text = existingContact.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Full name is required' : null;
      _emailError = (email.isEmpty || !email.contains('@'))
          ? 'Valid email address is required'
          : null;
      _phoneError = (phone.isEmpty || phone.replaceAll(RegExp(r'[^0-9]'), '').length < 7)
          ? 'Valid phone number is required'
          : null;
    });

    return _nameError == null && _emailError == null && _phoneError == null;
  }

  Future<void> _continue() async {
    if (!_validate()) return;

    final contact = ContactInfo(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final ok = await ref
        .read(bookingQuoteNotifierProvider.notifier)
        .submitQuote(contact);

    if (!mounted) return;
    if (ok) {
      context.pushNamed(RouteNames.bookingConfirmPay);
    } else {
      final error = ref.read(bookingQuoteNotifierProvider).error;
      TopMessage.show(context, error ?? 'Failed to save quote');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(bookingReviewProvider);
    final quoteSaveState = ref.watch(bookingQuoteNotifierProvider);
    final isSaving = quoteSaveState.isLoading;

    // Prefill controllers if flow state contact was updated from server
    ref.listen<AsyncValue<BookingReview>>(bookingReviewProvider, (_, next) {
      next.whenData((review) {
        if (_nameController.text.isEmpty && review.contactFullName != null) {
          _nameController.text = review.contactFullName!;
        }
        if (_emailController.text.isEmpty && review.contactEmail != null) {
          _emailController.text = review.contactEmail!;
        }
        if (_phoneController.text.isEmpty && review.contactPhone != null) {
          _phoneController.text = review.contactPhone!;
        }
      });
    });

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.review),
      body: AbsorbPointer(
        absorbing: isSaving,
        child: Opacity(
          opacity: isSaving ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.review),
                AppSpacing.verticalBase,
                Expanded(
                  child: reviewAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Couldn't load review summary.",
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                          ),
                          AppSpacing.verticalMd,
                          TextButton(
                            onPressed: () => ref.invalidate(bookingReviewProvider),
                            child: Text(
                              'Retry',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (review) => ListView(
                      children: [
                        Text(
                          'Review Your Project',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          'Review your shoot specifications and provide your contact information.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        // Section 1: Project Details Card
                        _buildProjectCard(review),
                        AppSpacing.verticalBase,
                        // Section 2: Editing & Delivery Card
                        _buildEditsCard(review),
                        AppSpacing.verticalBase,
                        // Section 3: Inclusions & Add-ons Card
                        _buildInclusionsCard(review),
                        AppSpacing.verticalBase,
                        // Section 4: Contact Information Form
                        _buildContactCard(),
                        AppSpacing.verticalBase,
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalBase,
                BookingPrimaryButton(
                  label: 'Continue to Payment Review',
                  loading: isSaving,
                  onTap: _continue,
                ),
                AppSpacing.verticalBase,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BookingReview review) {
    final flowState = ref.watch(bookingFlowControllerProvider);
    final scheduleMap = review.schedule;
    final isDeferred = review.isDateToBeDecided || flowState.isDeferred;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white15, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Project Specifications'),
          const SizedBox(height: 10),
          _detailRow('Service', review.service ?? flowState.contentType?.wireValue ?? 'Shoot'),
          if (review.occasion != null && review.occasion!.isNotEmpty)
            _detailRow('Occasion', review.occasion!),
          if (flowState.shootTypeName != null)
            _detailRow('Shoot Type', flowState.shootTypeName!),
          if (review.description != null && review.description!.isNotEmpty)
            _detailRow('Details', review.description!),
          const Divider(color: AppColors.white10, height: 20),
          if (isDeferred)
            _detailRow('Schedule', 'Date & time to be decided later')
          else ...[
            if (scheduleMap['event_date'] != null)
              _detailRow('Date', scheduleMap['event_date'].toString()),
            if (scheduleMap['start_time'] != null && scheduleMap['end_time'] != null)
              _detailRow('Time', '${scheduleMap['start_time']} - ${scheduleMap['end_time']}'),
            if (scheduleMap['duration'] != null)
              _detailRow('Duration', '${scheduleMap['duration']} hours'),
          ],
          if (scheduleMap['event_location'] != null || flowState.schedule?.eventLocation != null)
            _detailRow(
              'Location',
              (scheduleMap['event_location'] ?? flowState.schedule?.eventLocation).toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildEditsCard(BookingReview review) {
    final edits = review.editingServices;
    final hasPhotoEdits = edits.photoEdits.isNotEmpty;
    final hasVideoEdits = edits.videoEdits.isNotEmpty;
    final receiveText = edits.receiveText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white15, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Edits & Delivery'),
          const SizedBox(height: 10),
          if (receiveText != null && receiveText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadii.mdAll,
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.primary, size: 18),
                  AppSpacing.gapHSm,
                  Expanded(
                    child: Text(
                      receiveText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (!hasPhotoEdits && !hasVideoEdits)
            Text(
              'No editing services selected (Raw footage delivery)',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            )
          else ...[
            if (hasPhotoEdits)
              _detailRow('Photo Edits', edits.photoEdits.map((e) => e.label).join(', ')),
            if (hasVideoEdits)
              _detailRow('Video Edits', edits.videoEdits.map((e) => e.label).join(', ')),
          ],
        ],
      ),
    );
  }

  Widget _buildInclusionsCard(BookingReview review) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white15, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Inclusions & Add-ons'),
          const SizedBox(height: 10),
          if (review.includedServices.isNotEmpty) ...[
            Text(
              'Included with Package',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.includedServices.map((s) => _servicePill(s, isIncluded: true)).toList(),
            ),
            const Divider(color: AppColors.white10, height: 20),
          ],
          Text(
            'Selected Add-ons',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          if (review.addOns.isEmpty)
            Text(
              'No additional add-ons selected',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.addOns.map((a) => _servicePill(a, isIncluded: false)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white15, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Contact Information'),
          const SizedBox(height: 6),
          Text(
            'Enter the contact information for shoot confirmation and delivery updates.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          AppSpacing.verticalBase,
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Jane Doe',
            errorText: _nameError,
            icon: Icons.person_outline,
          ),
          AppSpacing.verticalMd,
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'jane@example.com',
            errorText: _emailError,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          AppSpacing.verticalMd,
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '(555) 000-0000',
            errorText: _phoneError,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.mdAll,
              borderSide: const BorderSide(color: AppColors.white15, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.mdAll,
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadii.mdAll,
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadii.mdAll,
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _servicePill(String text, {required bool isIncluded}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isIncluded
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.white.withValues(alpha: 0.08),
        borderRadius: AppRadii.smAll,
        border: Border.all(
          color: isIncluded ? AppColors.primary : AppColors.white15,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isIncluded) ...[
            const Icon(Icons.check, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: isIncluded ? AppColors.primary : AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
