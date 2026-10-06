import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/features/booking/domain/entities/addon_catalogue_item.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/presentation/providers/booking_flow_controller.dart';
import 'package:beige/features/booking/presentation/providers/v4/booking_addons_notifier.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_primary_button.dart';
import 'package:beige/features/booking/presentation/screens/v4/widgets/booking_step_header.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

/// Screen 9 / Screen 8 (Phase 5) — Optional Add-ons.
///
/// Catalogue-driven add-ons from `GET /bookings/addons`. Quantities and slugs
/// are stored in frontend flow state until `/review` and `/quote`.
class BookingAddonsScreen extends ConsumerWidget {
  const BookingAddonsScreen({super.key});

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(bookingFlowControllerProvider.notifier);
    controller
      ..markStepComplete(BookingStep.addons)
      ..setCurrentStep(BookingStep.review);
    await controller.persist(currentRoute: RouteNames.bookingReviewContact);

    if (context.mounted) {
      context.pushNamed(RouteNames.bookingReviewContact);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogueAsync = ref.watch(addonCatalogueProvider);
    final flowState = ref.watch(bookingFlowControllerProvider);
    final selection = flowState.addonSelection;
    final totalSelected = selection.items.fold<int>(0, (sum, i) => sum + i.quantity);

    return AppScaffold(
      hasAppBar: true,
      appBar: BookingStepHeader.appBar(context, step: BookingStep.addons),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Column(
          children: [
            const BookingStepHeader(step: BookingStep.addons),
            AppSpacing.verticalBase,
            Expanded(
              child: catalogueAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Couldn't load add-ons.",
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                      ),
                      AppSpacing.verticalMd,
                      TextButton(
                        onPressed: () => ref.invalidate(addonCatalogueProvider),
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
                data: (items) {
                  return ListView(
                    children: [
                      Text(
                        'Enhance Your Shoot',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.verticalSm,
                      Text(
                        'Choose optional add-ons to customize your production.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppSpacing.verticalBase,
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                          child: Center(
                            child: Text(
                              'No add-ons available for this shoot.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ...items.map(
                          (item) => _buildAddonCard(
                            context: context,
                            ref: ref,
                            item: item,
                            quantity: selection.quantityForSlug(item.slug),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            AppSpacing.verticalBase,
            BookingPrimaryButton(
              label: totalSelected > 0
                  ? 'Continue to Review ($totalSelected selected)'
                  : 'Continue to Review',
              onTap: () => _continue(context, ref),
            ),
            AppSpacing.verticalBase,
          ],
        ),
      ),
    );
  }

  /// Interactive Stepper Card (Option A).
  Widget _buildAddonCard({
    required BuildContext context,
    required WidgetRef ref,
    required AddonCatalogueItem item,
    required int quantity,
  }) {
    final isSelected = quantity > 0;
    final controller = ref.read(bookingFlowControllerProvider.notifier);

    final displayPrice = item.priceLabel?.isNotEmpty == true
        ? item.priceLabel!
        : (item.price != null ? '+\$${item.price}' : '');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.white15,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (displayPrice.isNotEmpty)
                Text(
                  displayPrice,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Stepper controls
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                enabled: quantity > 0,
                onTap: () {
                  if (quantity > 0) {
                    controller.setAddonQuantity(item.slug, quantity - 1);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  '$quantity',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add,
                enabled: true,
                onTap: () => controller.setAddonQuantity(item.slug, quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.white.withValues(alpha: 0.05),
          borderRadius: AppRadii.smAll,
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.white15,
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
