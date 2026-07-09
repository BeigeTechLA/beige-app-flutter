import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/core/utils/date_time_utils.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/assets.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/features/shoot/presentation/providers/shoot_edit_review_notifier.dart';
import 'package:beige/shared/widgets/loading.dart';

class ShootEditReviewScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const ShootEditReviewScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ShootEditReviewScreen> createState() =>
      _ShootEditReviewScreenState();
}

class _ShootEditReviewScreenState extends ConsumerState<ShootEditReviewScreen> {
  bool payFullAdvance = true;
  int selectedPayment = 0;
  int selectedIndex = 0;

  final TextEditingController notesController = TextEditingController();

  String getContentTypeTitle(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return "Video Shoot Type";
      case 2:
        return "Photo Shoot Type";
      case 3:
        return "Photo & Video Shoot Type";
      default:
        return "Shoot Type";
    }
  }

  List<String> getContentTypeTitles(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return ["Video Shoot Type"];
      case 2:
        return ["Photo Shoot Type"];
      case 3:
        return ["Video Shoot Type", "Photo Shoot Type"];
      default:
        return ["Shoot Type"];
    }
  }

  int _getSafeContentType(Map<String, dynamic>? booking) {
    final value = booking?['content_type'];

    if (value == null) return 0;

    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  String _getShootTypeImage(Map<String, dynamic>? booking) {
    final img = booking?['shoot_type_image_url'];
    if (img == null || img.isEmpty) return "";
    if (img.startsWith("http")) return img;
    return '${ApiEndpoints.imageUrl}$img';
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(
      shootEditReviewNotifierProvider(widget.bookingId),
    );
    final summaryData = reviewState.summaryData;
    final loding = reviewState.status == ShootEditReviewStatus.loading;

    final booking = summaryData?['booking'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        leadingWidth: 40, // 🔥 important
        leading: InkWell(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SvgPicture.asset(
              AppAssets.back,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: Center(
              child: Text(
                "2/2",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      body: booking == null
          ? const AppScreenLoader()
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    children: [
                      /// STEP INDICATOR
                      Row(
                        children: List.generate(
                          2,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                right: AppSpacing.xs,
                              ),
                              height: 5,
                              decoration: BoxDecoration(
                                color: index < 2
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.mld,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppSpacing.xxl),
                      Row(
                        children: [
                          Text(
                            "Review & Confirm",
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xxl),

                      /// 📸 CREATOR CARD
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.base),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.xxxl,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// 🔹 TOP PROFILE ROW
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: AppRadii.xlAll,
                                          child:
                                              _getShootTypeImage(
                                                booking,
                                              ).isNotEmpty
                                              ? Image.network(
                                                  _getShootTypeImage(booking),
                                                  height: 144,
                                                  width: 126,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) {
                                                    return SvgPicture.asset(
                                                      AppAssets
                                                          .imagePlaceholder,
                                                      height: 144,
                                                      width: 126,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : SvgPicture.asset(
                                                  AppAssets.imagePlaceholder,
                                                  height: 144,
                                                  width: 126,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),

                                        const SizedBox(width: AppSpacing.mld),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: AppSpacing.xs),
                                              Text(
                                                booking?['project_name'] ?? '',
                                                style: AppTextStyles.labelLarge
                                                    .copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              SizedBox(height: AppSpacing.xxxs),
                                              Text(
                                                booking?['shoot_type_name'] ??
                                                    '',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors.white70,
                                                    ),
                                              ),
                                              SizedBox(height: AppSpacing.smd),
                                              Text(
                                                getContentTypeTitle(
                                                  _getSafeContentType(booking),
                                                ),

                                                style: AppTextStyles.labelLarge
                                                    .copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: AppSpacing.mld),

                                    SizedBox(
                                      height: 1,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: List.generate(
                                              (constraints.maxWidth / 14)
                                                  .floor(),
                                              (index) => Container(
                                                width: 6,
                                                height: 1,
                                                color: AppColors.white30,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: AppSpacing.md),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.mld,
                                        vertical: AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: AppRadii.xlAll,
                                        border: Border.all(
                                          color: AppColors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          /// 🔥 CHECK MULTI OR SINGLE
                                          if ((booking?['booking_days'] ?? [])
                                              .isNotEmpty) ...[
                                            /// ✅ MULTI DAY
                                            ...List.generate(
                                              booking!['booking_days'].length,
                                              (index) {
                                                var day =
                                                    booking['booking_days'][index];

                                                return Column(
                                                  children: [
                                                    infoRowBlack(
                                                      AppAssets.clock,
                                                      "${DateTimeUtils.formatTime(day['start_time'], fallback: "")} to ${DateTimeUtils.formatTime(day['end_time'], fallback: "")}"
                                                      " (${day['duration_hours']}h)",
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.sm,
                                                    ),
                                                    infoRowBlack(
                                                      AppAssets.calendarDate,
                                                      DateTimeUtils.formatWeekdayDate(
                                                        day['date'],
                                                        fallback: "",
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.sm,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ] else ...[
                                            /// ✅ SINGLE DAY (🔥 IMPORTANT FIX)
                                            infoRowBlack(
                                              AppAssets.clock,
                                              "${DateTimeUtils.formatTime(booking?['start_time'], fallback: "")} to ${DateTimeUtils.formatTime(booking?['end_time'], fallback: "")}"
                                              " (${booking?['duration_hours']}h)",
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.sm,
                                            ),
                                            infoRowBlack(
                                              AppAssets.calendarDate,
                                              DateTimeUtils.formatWeekdayDate(
                                                booking?['event_date'],
                                                fallback: "",
                                              ),
                                            ),
                                          ],

                                          /// 📍 LOCATION (COMMON)
                                          const SizedBox(height: AppSpacing.sm),
                                          infoRowBlack(
                                            AppAssets.location,
                                            booking?['event_location'] ?? "",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                  vertical: AppSpacing.smd,
                                ),
                                child: Container(
                                  height: 1,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.white.withValues(
                                          alpha: 0.09,
                                        ), // left
                                        AppColors.white.withValues(
                                          alpha: 0.09,
                                        ), // center
                                        AppColors.white.withValues(
                                          alpha: 0.09,
                                        ), // right
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSpacing.xxl),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((booking?['video_edit_types'] ?? [])
                                          .isNotEmpty ||
                                      (booking?['photo_edit_types'] ?? [])
                                          .isNotEmpty) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Editing Services",
                                          style: AppTextStyles.titleSmall
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: AppSpacing.smd),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.mld,
                                        vertical: AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMid,
                                        borderRadius: AppRadii.xlAll,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// ================= VIDEO EDITS =================
                                          if ((booking?['video_edit_types'] ??
                                                  [])
                                              .isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSpacing.sm,
                                              ),
                                              child: Text(
                                                "Video Edits:",
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors.white,
                                                    ),
                                              ),
                                            ),

                                            Column(
                                              children: List.generate(
                                                booking?['video_edit_types']
                                                        .length ??
                                                    0,
                                                (index) {
                                                  final item =
                                                      booking?['video_edit_types'][index];

                                                  return Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom:
                                                                AppSpacing.sm,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal:
                                                                AppSpacing.xl,
                                                            vertical:
                                                                AppSpacing.sm,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .goldLight20,
                                                        borderRadius:
                                                            AppRadii.xsAll,
                                                      ),
                                                      child: Text(
                                                        "${item['value']} x${item['count']}",
                                                        style: AppTextStyles
                                                            .labelMedium
                                                            .copyWith(
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                            SizedBox(height: AppSpacing.md),
                                          ],

                                          /// ================= PHOTO EDITS =================
                                          if ((booking?['photo_edit_types'] ??
                                                  [])
                                              .isNotEmpty) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: AppSpacing.sm,
                                              ),
                                              child: Text(
                                                "Photo Edits:",
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors.white,
                                                    ),
                                              ),
                                            ),

                                            Column(
                                              children: List.generate(
                                                booking?['photo_edit_types']
                                                        .length ??
                                                    0,
                                                (index) {
                                                  final item =
                                                      booking?['photo_edit_types'][index];

                                                  return Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            bottom:
                                                                AppSpacing.sm,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal:
                                                                AppSpacing.xl,
                                                            vertical:
                                                                AppSpacing.sm,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .goldLight20,
                                                        borderRadius:
                                                            AppRadii.xsAll,
                                                      ),
                                                      child: Text(
                                                        "${item['value']} x${item['count']}"
                                                        "${item['note'] != null ? ' (${item['note']})' : ''}",
                                                        style: AppTextStyles
                                                            .labelMedium
                                                            .copyWith(
                                                              color: AppColors
                                                                  .primary,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: AppSpacing.xxxl),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (loding) const AppScreenLoader(),
              ],
            ),
      bottomNavigationBar: booking == null
          ? null
          : Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          context.pushNamed(RouteNames.shootUpdated);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.xlAll,
                          ),
                        ),
                        child: Text(
                          "Update Schedule",
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.textHeading,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text,
        style: AppTextStyles.buttonMedium.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget infoRowBlack(String svgIcon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SVG ICON
        SvgPicture.asset(
          svgIcon,
          height: 16,
          width: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.black87,
            BlendMode.srcIn,
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.black),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget priceRow(
    String title,
    String price, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? AppTextStyles.buttonMedium.copyWith(color: AppColors.white70)
                : AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
          ),
          Text(
            price,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDiscount
                        ? AppColors.discountGreen
                        : AppColors.white,
                  )
                : AppTextStyles.labelMedium.copyWith(
                    color: isDiscount
                        ? AppColors.discountGreen
                        : AppColors.white,
                  ),
          ),
        ],
      ),
    );
  }

  Widget paymentRadioTile({required String title, required int value}) {
    final bool isSelected = selectedIndex == value;

    return InkWell(
      borderRadius: AppRadii.xlAll,
      onTap: () {
        setState(() {
          selectedIndex = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMid,
          borderRadius: AppRadii.xlAll,
        ),
        child: Row(
          children: [
            /// 🔹 TITLE
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),

            /// 🔹 CUSTOM RADIO (RIGHT SIDE)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                /// Gradient when selected
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary, // light shade
                          AppColors.primaryDark,
                        ],
                      )
                    : null,

                /// Border
                border: Border.all(color: AppColors.white70, width: 1),
              ),

              /// 🔹 INNER DOT
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.black,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget gradientSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: AppRadii.hugeAll,

          /// 🔥 GRADIENT WHEN ON
          gradient: value
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,

          /// OFF COLOR
          color: value ? null : AppColors.white.withValues(alpha: 0.25),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget builderPricingCard({
    required String title,
    required double amount,
    required List<String> subtitles,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput, // Darker background for the cards
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                "\$${NumberFormat('#,##0.00').format(amount)}",
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
