import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/text_styles.dart';
import '../../../../app/spacing.dart';
import '../../../../app/radii.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/shared/widgets/loading.dart';
import 'package:beige/features/profile/presentation/providers/booking_history_notifier.dart';

class ShootHistoryScreen extends ConsumerWidget {
  const ShootHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(bookingHistoryNotifierProvider);
    final isLoading =
        historyState.status == BookingHistoryStatus.loading;
    final bookings = historyState.bookings;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BACK
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Text(
                "Booking History",
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            AppSpacing.verticalXl,

            Expanded(
              child: isLoading
                  ? const Center(
                      child: AppCircularLoader(
                        color: AppColors.primary,
                      ),
                    )
                  : bookings.isEmpty
                      ? Center(
                          child: Text(
                            "No bookings found",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];

                            final String image =
                                booking['profile_image_url'] ?? "";
                            final String name =
                                booking['creator_name'] ?? "-";
                            final String role =
                                booking['primary_title'] ?? "";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.smd),
                              child: ClipRRect(
                                borderRadius: AppRadii.hugeAll,
                                child: SizedBox(
                                  height: 220,
                                  child: Stack(
                                    children: [
                                      /// IMAGE
                                      image.isNotEmpty
                                          ? Image.network(
                                              ApiEndpoints.imageUrl +
                                                  image,
                                              width: double.infinity,
                                              height: 220,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              errorBuilder: (context,
                                                  error, stackTrace) {
                                                return Center(
                                                  child: SvgPicture.asset(
                                                    AppAssets.imagePlaceholder,
                                                    width: 120,
                                                    height: 120,
                                                    fit: BoxFit.contain,
                                                  ),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: SvgPicture.asset(
                                                AppAssets.imagePlaceholder,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.contain,
                                              ),
                                            ),

                                      /// GRADIENT
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 110,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end:
                                                  Alignment.bottomCenter,
                                              colors: [
                                                AppColors.transparent,
                                                AppColors.black
                                                    .withValues(alpha: 0.85),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      /// DETAILS
                                      Positioned(
                                        bottom: AppSpacing.xl,
                                        left: AppSpacing.base,
                                        right: AppSpacing.base,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppSpacing.verticalXs,
                                            Text(
                                              name,
                                              style: AppTextStyles.buttonMedium.copyWith(
                                                color: AppColors.white,
                                              ),
                                            ),
                                            Text(
                                              role,
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
