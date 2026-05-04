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
import 'package:beige/features/booking/presentation/providers/crew_recommendation_notifier.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';

class CrewSizeMatchingScreen extends ConsumerStatefulWidget {
  final int specialtyId;
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  const CrewSizeMatchingScreen({super.key, required this.specialtyId, required this.ShootTypeId, required this.bookingId, required this.contentTypeId});

  @override
  ConsumerState<CrewSizeMatchingScreen> createState() => _CrewSizeMatchingScreenState();
}

class _CrewSizeMatchingScreenState extends ConsumerState<CrewSizeMatchingScreen> {

  int currentStep = 1;

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
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                ),
              ),
            ),
            Text(
              "More Details",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: AppAssets.fontOutfit,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: TextStyle(
                  fontFamily: AppAssets.fontOutfit,
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(padding:  EdgeInsets.all(20.0),
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
                      margin: const EdgeInsets.only(right: 8),
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary, // grey background
                        borderRadius: BorderRadius.circular(64),
                      ),
                      child: fillWidth > 0
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 5,
                          width: fillWidth == double.infinity ? null : fillWidth,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                      )
                          : const SizedBox(),
                    ),
                  );
                }),
              ),

              SizedBox(
                height: 20,
              ),

              Row(
                children: [
                  Text(
                    "Crew Size & Matching",
                    style: TextStyle(
                      fontFamily: AppAssets.fontUnbounded,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Container(

                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              border: Border.all(color:Colors.white.withOpacity(0.30),width: 0.5)
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding:  EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: SvgPicture.asset(
                                        AppAssets.info,

                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Recommended Crew Size for \nYour Project",
                                        style: TextStyle(color: AppColors.textHeading, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: AppAssets.fontOutfit),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                                padding: const EdgeInsets.all(12.0),
                                child:Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "$shootName ($contentType)",
                                        //  maxLines: 2,                    // ✅ allows wrapping
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppAssets.fontOutfit,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      "$minCrew - $maxCrew People",
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppAssets.fontOutfit,
                                      ),
                                    ),
                                  ],
                                ),

                              ),
                              SizedBox(height: 10),
                              if (defaultOutput.isNotEmpty) ...[
                                // const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Divider(color: AppColors.white.withOpacity(0.30)),
                                ),


                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Typical output:",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.70),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppAssets.fontOutfit,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            getDefaultOutputText(defaultOutput),
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppAssets.fontOutfit,
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

                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "How would you like to proceed?",
                              style: TextStyle(
                                fontFamily: AppAssets.fontUnbounded,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            /*    border: Border.all(color: AppColors.primary)*/
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:Color(0xffE8D1AB)
                                    ),
                                    child: SvgPicture.asset(
                                      AppAssets.ratings,
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.cover,
                                      colorFilter: const ColorFilter.mode(
                                        Color(0xff1D1D1B),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "AI Matchmaker",
                                      style: TextStyle(color: AppColors.primary, fontSize: 16,fontWeight: FontWeight.w700,fontFamily: AppAssets.fontOutfit),//
                                    ),
                                  ),
                                ],
                              ),

                              // Divider(color: AppColors.dividerDark,),
                              //

                              SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Our AI will analyse your project and match you with the perfect crew size and specialists",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppAssets.fontOutfit,
                                  ),
                                ),
                              ),

                              SizedBox(height: 10),

                              Container(
                                /*  decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(13)),
                              color: AppColors.surfaceVariant,
                            ),*/
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCheckRow("Optimal team composition"),
                                    const SizedBox(height: 10),
                                    _buildCheckRow("Matched based on your budget"),
                                    const SizedBox(height: 10),
                                    _buildCheckRow("Industry best practices"),
                                  ],
                                ),
                              ),


                            ],
                          ),
                        ),

                        SizedBox(height: 20),
                        Divider(color: AppColors.dividerDark,),
                        SizedBox(height:15),
                        Row(
                          children: [
                            Text(
                              "How AI Matching Works",
                              style: TextStyle(
                                fontFamily: AppAssets.fontUnbounded,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),


                        SizedBox(height:20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Our intelligent matching system considers multiple factors to build your ideal crew:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppAssets.fontOutfit,
                            ),
                          ),
                        ),
                        SizedBox(height:15),

                        Container(
                          /*   decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                            ),*/

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "•",
                                      style: TextStyle(
                                        color: Color(0xFFE6C48F),
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Shoot Type & Complexity: ",
                                              style: TextStyle(
                                                color: Color(0xffE8D1AB),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppAssets.fontOutfit,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              "Different shoots require different team sizes",
                                              style: TextStyle(
                                                color: AppColors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AppAssets.fontOutfit,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "•",
                                      style: TextStyle(
                                        color: Color(0xFFE6C48F),
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Budget Range: ",
                                              style: TextStyle(
                                                color: Color(0xffE8D1AB),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppAssets.fontOutfit,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              "We match crews that fit your budget tier",
                                              style: TextStyle(
                                                color: AppColors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AppAssets.fontOutfit,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "•",
                                      style: TextStyle(
                                        color: Color(0xFFE6C48F),
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Industry Standards: ",
                                              style: TextStyle(
                                                color: Color(0xffE8D1AB),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppAssets.fontOutfit,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              "Based on thousands of successful projects",
                                              style: TextStyle(
                                                color: AppColors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AppAssets.fontOutfit,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 🔹 Back Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppAssets.fontUnbounded,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 🔸 Continue Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(RouteNames.findingPerfect, extra: {
                        'bookingId': widget.bookingId,
                        'contentTypeId': widget.contentTypeId,
                        'specialtyId': widget.specialtyId,
                        'ShootTypeId': widget.ShootTypeId,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:  Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppAssets.fontUnbounded,
                        fontWeight: FontWeight.w600,
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: AppAssets.fontOutfit,
            ),
          ),
        ),
      ],
    );
  }

}