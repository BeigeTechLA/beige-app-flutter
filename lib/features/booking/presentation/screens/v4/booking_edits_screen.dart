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
import 'package:beige/features/booking/domain/entities/edit_selection.dart';
import 'package:beige/features/booking/domain/entities/edit_type_option.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_edits_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';

/// Screen 7 — "Want Beige to edit it?" Yes/No plus per-content edit-type
/// selection. Only edit keys are sent; quantity encoding is unresolved (D3)
/// and delivery text is owned by the server at /review.
class BookingEditsScreen extends ConsumerStatefulWidget {
  const BookingEditsScreen({super.key});

  @override
  ConsumerState<BookingEditsScreen> createState() => _BookingEditsScreenState();
}

class _BookingEditsScreenState extends ConsumerState<BookingEditsScreen> {
  bool _editsNeeded = true;
  final Set<String> _photoKeys = {};
  final Set<String> _videoKeys = {};

  @override
  void initState() {
    super.initState();
    final existing = ref.read(bookingFlowControllerProvider).editSelection;
    _editsNeeded = existing.editsNeeded;
    _photoKeys.addAll(existing.photoEditTypes);
    _videoKeys.addAll(existing.videoEditTypes);
  }

  EditSelection get _selection => EditSelection(
    editsNeeded: _editsNeeded,
    photoEditTypes: _photoKeys.toList(),
    videoEditTypes: _videoKeys.toList(),
  );

  Future<void> _continue() async {
    final ok = await ref
        .read(bookingEditsNotifierProvider.notifier)
        .submit(_selection);
    if (!mounted) return;
    if (ok) {
      final isManual = ref.read(bookingFlowControllerProvider).isManualBranch;
      final target = isManual
          ? RouteNames.bookingCreatorSelection
          : RouteNames.bookingAddons;
      context.pushNamed(target);
    } else {
      TopMessage.show(
        context,
        ref.read(bookingEditsNotifierProvider).error ?? 'Something went wrong',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bookingEditsNotifierProvider).isLoading;

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.edits),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                const BookingStepHeader(step: BookingStep.edits),
                AppSpacing.verticalXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Want Beige to edit it?',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Text(
                          'Turn your raw footage into polished, ready-to-share '
                          'content—professionally edited by the Beige team.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.verticalBase,
                        _yesNoToggle(),
                        if (_editsNeeded) ...[
                          AppSpacing.verticalBase,
                          _catalogueSection(),
                        ],
                      ],
                    ),
                  ),
                ),
                AppSpacing.verticalBase,
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

  Widget _yesNoToggle() {
    return Row(
      children: [
        _togglePill(
          label: 'Yes',
          selected: _editsNeeded,
          onTap: () => setState(() => _editsNeeded = true),
        ),
        AppSpacing.gapHBase,
        _togglePill(
          label: 'No',
          selected: !_editsNeeded,
          onTap: () => setState(() => _editsNeeded = false),
        ),
      ],
    );
  }

  Widget _togglePill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.transparent,
          borderRadius: AppRadii.lgAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.white30,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.black : AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _catalogueSection() {
    final catalogue = ref.watch(editTypesCatalogueProvider);
    return catalogue.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => _ErrorRetry(
        onRetry: () => ref.invalidate(editTypesCatalogueProvider),
      ),
      data: (data) {
        if (data.photoEditTypes.isEmpty && data.videoEditTypes.isEmpty) {
          return Text(
            'No edit options available for this content type.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.photoEditTypes.isNotEmpty) ...[
              _sectionLabel('Photo Edits'),
              ...data.photoEditTypes.map(
                (o) => _editRow(
                  option: o,
                  selected: _photoKeys.contains(o.key),
                  onTap: () => setState(() {
                    _photoKeys.contains(o.key)
                        ? _photoKeys.remove(o.key)
                        : _photoKeys.add(o.key);
                  }),
                ),
              ),
            ],
            if (data.videoEditTypes.isNotEmpty) ...[
              AppSpacing.verticalBase,
              _sectionLabel('Choose your edits'),
              ...data.videoEditTypes.map(
                (o) => _editRow(
                  option: o,
                  selected: _videoKeys.contains(o.key),
                  onTap: () => setState(() {
                    _videoKeys.contains(o.key)
                        ? _videoKeys.remove(o.key)
                        : _videoKeys.add(o.key);
                  }),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _editRow({
    required EditTypeOption option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.mdAll,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (option.quantity != null) ...[
                      AppSpacing.verticalXxs,
                      Text(
                        '${option.quantity} included',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                height: 28,
                width: 28,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.smAll,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.borderLight,
                    width: 0.5,
                  ),
                  color: selected ? AppColors.primary : AppColors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: AppColors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load edit options.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            AppSpacing.verticalMd,
            TextButton(
              onPressed: onRetry,
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
    );
  }
}
