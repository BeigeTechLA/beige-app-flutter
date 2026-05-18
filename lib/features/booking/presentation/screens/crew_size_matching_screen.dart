import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/features/booking/presentation/providers/crew_recommendation_notifier.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

class CrewSizeMatchingScreen extends ConsumerStatefulWidget {
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  const CrewSizeMatchingScreen({super.key, required this.ShootTypeId, required this.bookingId, required this.contentTypeId});

  @override
  ConsumerState<CrewSizeMatchingScreen> createState() => _CrewSizeMatchingScreenState();
}

class _CrewSizeMatchingScreenState extends ConsumerState<CrewSizeMatchingScreen> {

  int currentStep = 1;
  bool _isPopping = false;
  bool _isNavigating = false;

  void _handleBack() {
    if (_isPopping) return;
    if (!context.canPop()) return;
    _isPopping = true;
    context.pop();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _isPopping = false;
    });
  }

  void _handleContinue() {
    if (_isNavigating) return;
    _isNavigating = true;
    ref
        .read(crewRecommendationNotifierProvider(widget.bookingId).notifier)
        .markStepCompleted();
    context.pushNamed(
      RouteNames.findingPerfect,
      extra: {
        'bookingId': widget.bookingId,
        'contentTypeId': widget.contentTypeId,
        'ShootTypeId': widget.ShootTypeId,
      },
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _isNavigating = false;
    });
  }

  String getShootImage(String shootImageUrl) {
    if (shootImageUrl.isEmpty) return "";
    return '${ApiEndpoints.imageUrl}$shootImageUrl';
  }

  String getDefaultOutputText(List<String> defaultOutput) {
    if (defaultOutput.isEmpty) return "-";

    if (defaultOutput.length == 1) {
      return defaultOutput.first;
    }

    return "${defaultOutput.first} (+${defaultOutput.length - 1})";
  }

  @override
  Widget build(BuildContext context) {
    final crewState = ref.watch(crewRecommendationNotifierProvider(widget.bookingId));
    final crewData = crewState.data;
    // Extract data from notifier state
    final shootName = (crewData['shoot_type'] as Map?)?['name'] as String? ?? "";
    final contentType = (crewData['shoot_type'] as Map?)?['content_type'] as String? ?? "";
    final shootImageUrl = (crewData['shoot_type'] as Map?)?['image_url'] as String? ?? "";
    final minCrew = (crewData['recommended_crew'] as Map?)?['min'] as int? ?? 0;
    final maxCrew = (crewData['recommended_crew'] as Map?)?['max'] as int? ?? 0;
    final defaultOutput = List<String>.from(crewData['default_output'] ?? []);

    return AppScaffold(
      hasAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // 🔹 Back Button (Left)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _handleBack,
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                ),
              ),
            ),
            Text(
              "More Details",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [


              Row(
                children: List.generate(3, (index) {
                  double fillWidth = 0;

                  if (index < currentStep) {
                    // ✅ Completed step (FULL)
                    fillWidth = double.infinity;
                  } else if (index == currentStep) {
                    // 🟡 Current step (HALF)
                    fillWidth = 82.44;
                  } else {

                    fillWidth = 0;
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary, // grey background
                        borderRadius: BorderRadius.circular(AppRadii.enormous),
                      ),
                      child: fillWidth > 0
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 5,
                          width: fillWidth == double.infinity ? null : fillWidth,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadii.enormous),
                          ),
                        ),
                      )
                          : const SizedBox(),
                    ),
                  );
                }),
              ),

              const SizedBox(
                height: AppSpacing.xl,
              ),

              Row(
                children: [
                  Text(
                    "Crew Size & Matching",
                    style: AppTextStyles.titleSmall,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Container(

                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: AppRadii.lgAll,
                              border: Border.all(color: AppColors.white.withValues(alpha: 0.30), width: 0.5)
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSpacing.xl),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadii.lgAll,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.black,
                                        borderRadius: BorderRadius.circular(AppRadii.mld),
                                      ),
                                      child: SvgPicture.asset(
                                        AppAssets.info,

                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        "Recommended Crew Size for \nYour Project",
                                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.textHeading),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadii.xxl),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: SizedBox(
                                    height: 280,
                                    width: double.infinity,
                                    child: CachedNetworkImage(
                                      imageUrl: getShootImage(shootImageUrl),
                                      fit: BoxFit.cover,

                                      // ⏳ loading
                                      placeholder: (context, url) {
                                        debugPrint("⏳ IMAGE LOADING → $url");
                                        return Center(
                                          child: Lottie.asset(
                                            AppAssets.lottieSpinner,
                                            width: 120,
                                            height: 120,
                                          ),
                                        );
                                      },

                                      // ✅ success
                                      imageBuilder: (context, imageProvider) {
                                        debugPrint("✅ IMAGE LOADED → ${getShootImage(shootImageUrl)}");
                                        return Image(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        );
                                      },

                                      // ❌ error
                                      errorWidget: (context, url, error) {
                                        debugPrint("❌ IMAGE FAILED → $url");
                                        return Center(
                                          child: Lottie.asset(
                                            AppAssets.lottieSpinner,
                                            width: 120,
                                            height: 120,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),



                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "$shootName ($contentType)",
                                        //  maxLines: 2,                    // allows wrapping
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: AppSpacing.sm),

                                    Text(
                                      "$minCrew - $maxCrew People",
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),

                              ),
                              const SizedBox(height: AppSpacing.smd),
                              if (defaultOutput.isNotEmpty) ...[
                                // const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  child: Divider(color: AppColors.white.withValues(alpha: 0.30)),
                                ),


                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Typical output:",
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Row(
                                        children: [
                                          Text(
                                            getDefaultOutputText(defaultOutput),
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Text(
                              "How would you like to proceed?",
                              style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.smd),
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.hugeAll,
                            /*    border: Border.all(color: AppColors.primary)*/
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(AppSpacing.smd),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary
                                    ),
                                    child: SvgPicture.asset(
                                      AppAssets.ratings,
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.cover,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.onPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      "AI Matchmaker",
                                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),

                              // Divider(color: AppColors.dividerDark,),
                              //

                              const SizedBox(height: AppSpacing.smd),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Our AI will analyse your project and match you with the perfect crew size and specialists",
                                  textAlign: TextAlign.left,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.smd),

                              Container(
                                /*  decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(13)),
                              color: AppColors.surfaceVariant,
                            ),*/
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCheckRow("Optimal team composition"),
                                    const SizedBox(height: AppSpacing.smd),
                                    _buildCheckRow("Matched based on your budget"),
                                    const SizedBox(height: AppSpacing.smd),
                                    _buildCheckRow("Industry best practices"),
                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        Divider(color: AppColors.dividerDark),
                        const SizedBox(height: AppSpacing.mld),
                        Row(
                          children: [
                            Text(
                              "How AI Matching Works",
                              style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                            ),
                          ],
                        ),


                        const SizedBox(height: AppSpacing.xl),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Our intelligent matching system considers multiple factors to build your ideal crew:",
                            textAlign: TextAlign.left,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.mld),

                        Container(
                          /*   decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                            ),*/

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "•",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.primary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Shoot Type & Complexity: ",
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              "Different shoots require different team sizes",
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.white70,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "•",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.primary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Budget Range: ",
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              "We match crews that fit your budget tier",
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.white70,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "•",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.primary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Industry Standards: ",
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              "Based on thousands of successful projects",
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: AppColors.white70,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )


                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              // 🔹 Back Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: _handleBack,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                    ),
                    child: Text(
                      "Back",
                      style: AppTextStyles.buttonSmall.copyWith(
                        fontFamily: AppTextStyles.fontFamilyDisplay,
                        fontSize: 13,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Continue Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lgAll,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Continue",
                      style: AppTextStyles.buttonMedium.copyWith(
                        fontFamily: AppTextStyles.fontFamilyDisplay,
                        color: AppColors.textHeading,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),


        ),
      ),
    );
  }

  Widget _buildCheckRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          AppAssets.checkmark, // ✔️ icon image
          height: 24,
          width: 24,
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white70,
            ),
          ),
        ),
      ],
    );
  }

}