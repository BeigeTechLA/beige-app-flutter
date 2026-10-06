import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/assets.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_content_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';

/// Screen 1 — "How do you want to Beige?" Photography / Videography selection
/// resolving to the exact `content_type` wire value.
class BookingContentScreen extends ConsumerStatefulWidget {
  const BookingContentScreen({super.key});

  @override
  ConsumerState<BookingContentScreen> createState() =>
      _BookingContentScreenState();
}

class _BookingContentScreenState extends ConsumerState<BookingContentScreen> {
  bool _photography = false;
  bool _videography = false;

  @override
  void initState() {
    super.initState();
    // Restore any prior selection from the flow draft.
    final existing = ref.read(bookingFlowControllerProvider).contentType;
    switch (existing) {
      case BookingContentType.photographer:
        _photography = true;
      case BookingContentType.videographer:
        _videography = true;
      case BookingContentType.photographerVideographer:
        _photography = true;
        _videography = true;
      case null:
        break;
    }
  }

  BookingContentType? get _selected {
    if (_photography && _videography) {
      return BookingContentType.photographerVideographer;
    }
    if (_photography) return BookingContentType.photographer;
    if (_videography) return BookingContentType.videographer;
    return null;
  }

  Future<void> _continue() async {
    final selected = _selected;
    if (selected == null) {
      TopMessage.show(context, 'Please select at least one service');
      return;
    }
    final ok = await ref
        .read(bookingContentNotifierProvider.notifier)
        .submit(selected);
    if (!mounted) return;
    if (ok) {
      context.pushNamed(RouteNames.bookingShootType);
    } else {
      final error = ref.read(bookingContentNotifierProvider).error;
      TopMessage.show(context, error ?? 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(bookingContentNotifierProvider);
    final isLoading = saveState.isLoading;

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.contentType),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.contentType),
                AppSpacing.verticalXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How do you want to Beige?',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          "Select everything you need. We'll bring it together "
                          'into one seamless production.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        _option(
                          title: 'Photography',
                          image: AppAssets.servicePhotography,
                          value: _photography,
                          onTap: () =>
                              setState(() => _photography = !_photography),
                        ),
                        _option(
                          title: 'Videography',
                          image: AppAssets.serviceVideography,
                          value: _videography,
                          onTap: () =>
                              setState(() => _videography = !_videography),
                        ),
                        _option(
                          title: 'Editing Only (Coming Soon)',
                          image: AppAssets.serviceEditing,
                          value: false,
                          disabled: true,
                          onTap: null,
                        ),
                        _option(
                          title: 'Studios (Coming Soon)',
                          image: AppAssets.serviceStudio,
                          value: false,
                          disabled: true,
                          onTap: null,
                        ),
                        _option(
                          title: 'Livestreaming (Coming Soon)',
                          image: AppAssets.serviceLivestream,
                          value: false,
                          disabled: true,
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ),
                BookingPrimaryButton(
                  label: 'Continue',
                  loading: isLoading,
                  enabled: _selected != null,
                  onTap: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _option({
    required String title,
    required String image,
    required bool value,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : onTap,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iconBackground,
              ),
              child: Center(
                child: Opacity(
                  opacity: disabled ? 0.5 : 1,
                  child: Image.asset(image),
                ),
              ),
            ),
            AppSpacing.gapHBase,
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: disabled
                      ? AppColors.white60
                      : value
                      ? AppColors.primary
                      : AppColors.white,
                ),
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: AppRadii.smAll,
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.borderLight,
                  width: 0.5,
                ),
                color: value ? AppColors.primary : AppColors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: AppColors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
