import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_details_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';

/// Screen 4 — "How do you want to Beige it?" Optional project notes plus a
/// reference/inspiration link list. All fields optional; saves notes + a
/// reference-link array (possibly empty) to `/details`.
class BookingDetailsScreen extends ConsumerStatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final List<String> _links = [];

  @override
  void initState() {
    super.initState();
    final flow = ref.read(bookingFlowControllerProvider);
    _detailsController.text = flow.additionalDetails;
    _links.addAll(flow.referenceLinks);
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _addLink() {
    final link = _linkController.text.trim();
    if (link.isEmpty || _links.contains(link)) {
      _linkController.clear();
      return;
    }
    setState(() {
      _links.add(link);
      _linkController.clear();
    });
  }

  void _removeLink(String link) => setState(() => _links.remove(link));

  Future<void> _continue() async {
    final ok = await ref
        .read(bookingDetailsNotifierProvider.notifier)
        .submit(
          additionalDetails: _detailsController.text.trim(),
          referenceLinks: List<String>.from(_links),
        );
    if (!mounted) return;
    if (ok) {
      context.pushNamed(RouteNames.bookingMatchingChoice);
    } else {
      TopMessage.show(
        context,
        ref.read(bookingDetailsNotifierProvider).error ??
            'Something went wrong',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingDetailsNotifierProvider).isLoading;

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.details),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.details),
                AppSpacing.verticalXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How do you want to Beige it?',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          'Share your vision, vibe, references, or anything '
                          "else we should know. We'll take it from there.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        _detailsField(),
                        AppSpacing.verticalBase,
                        _inspirationField(),
                        if (_links.isNotEmpty) AppSpacing.verticalMd,
                        ..._links.map(_linkRow),
                      ],
                    ),
                  ),
                ),
                BookingPrimaryButton(
                  label: 'Continue',
                  loading: isLoading,
                  onTap: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.white30, width: 0.5),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: TextField(
        controller: _detailsController,
        maxLines: 6,
        minLines: 5,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        cursorColor: AppColors.primary,
        decoration: InputDecoration.collapsed(
          hintText:
              'Share your vision, vibe, references, or examples you love.',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white60,
          ),
        ),
      ),
    );
  }

  Widget _inspirationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add inspiration',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSm,
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(color: AppColors.white30, width: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.inputHorizontal,
                  vertical: AppSpacing.xxs,
                ),
                child: TextField(
                  controller: _linkController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                  cursorColor: AppColors.primary,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addLink(),
                  decoration: InputDecoration.collapsed(
                    hintText:
                        'Drop a link to a mood board, cool content, or examples.',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white60,
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.gapHSm,
            GestureDetector(
              onTap: _addLink,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.lgAll,
                ),
                child: Text(
                  'Add',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _linkRow(String link) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.link, size: 18, color: AppColors.white60),
          AppSpacing.gapHSm,
          Expanded(
            child: Text(
              link,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
            ),
          ),
          GestureDetector(
            onTap: () => _removeLink(link),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(left: AppSpacing.sm),
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: AppColors.white60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
