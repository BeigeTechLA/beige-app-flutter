import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/core/network/api_endpoints.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/features/booking/presentation/providers/shoot_type_notifier.dart';

class ShootTypeScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final int contentTypeId;
  const ShootTypeScreen({super.key, required this.contentTypeId, required this.bookingId});

  @override
  ConsumerState<ShootTypeScreen> createState() => _ShootTypeScreenState();
}

class _ShootTypeScreenState extends ConsumerState<ShootTypeScreen> {
  int selectedIndex = -1;
  int? selectedShootTypeId;
  String? selectedShootTypeName;

  Future<void> _selectShootType() async {
    if (selectedShootTypeId == null || selectedShootTypeName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select shoot type")),
      );
      return;
    }

    await ref
        .read(shootTypeNotifierProvider(widget.contentTypeId).notifier)
        .selectShootType(
          bookingId: widget.bookingId,
          contentTypeId: widget.contentTypeId,
          shootTypeId: selectedShootTypeId!,
          shootTypeName: selectedShootTypeName!,
        );

    if (!mounted) return;

    final notifierState = ref.read(shootTypeNotifierProvider(widget.contentTypeId));

    if (notifierState.status == ShootTypeStatus.success) {
      final bookingId = notifierState.bookingId ?? widget.bookingId;
      final result = await context.pushNamed<Map>(RouteNames.shootDateTime, extra: {
        'bookingId': bookingId,
        'contentTypeId': widget.contentTypeId,
        'ShootTypeId': selectedShootTypeId!,
        'shootTypeName': selectedShootTypeName,
      });

      if (result != null) {
        setState(() {
          selectedShootTypeId = result['id'] as int?;
          selectedShootTypeName = result['name'] as String?;

          final shootTypes = ref.read(shootTypeNotifierProvider(widget.contentTypeId)).shootTypes;
          final index = shootTypes.indexWhere((e) => e['id'] == selectedShootTypeId);
          if (index != -1) selectedIndex = index;
        });
      }
    } else if (notifierState.status == ShootTypeStatus.error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notifierState.errorMessage ?? "Something went wrong")),
        );
      }
    }
  }

  String _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '${ApiEndpoints.imageUrl}$imagePath';
  }


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


  @override
  Widget build(BuildContext context) {
    final shootState = ref.watch(shootTypeNotifierProvider(widget.contentTypeId));
    final shootTypes = shootState.shootTypes;

    return Scaffold(

      appBar: AppBar(

        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.pop(widget.bookingId),
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                ),
              ),
            ),//
            Text(
              "Create Project",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "1/3",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Outfit",
                  color: AppColors.white,
                  fontWeight: FontWeight.w400,

                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(18.0),
          child: Container(

            child: Column(
              children: [

                Row(
                  children: List.generate(3, (index) {
                    bool isActive = index == 0; // current step (1/3)

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary, // grey background
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: isActive
                            ? Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 5,
                            width: 70, // 🔥 colored portion only
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
                      getContentTypeTitle(widget.contentTypeId),
                      style:  TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 16,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: ListView.builder(
                    cacheExtent: 4000,
                    itemCount: shootTypes.length,
                    padding:  EdgeInsets.only(top: 12),
                    itemBuilder: (context, index) {

                      final item = shootTypes[index];
                      final List tags = item['tags'] ?? [];
                      final String tagsText = tags.join(" , ");

                      final imagePath = item['image']?.toString() ?? '';
                      final fullImageUrl = _getFullImageUrl(imagePath);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// 🔹 IMAGE CARD
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                selectedShootTypeId = item['id'];
                                selectedShootTypeName = item['name'];
                              });

                            },
                            child: Container(

                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),


                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  /// 🔹 LEFT IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: SizedBox(
                                      height: 125,
                                      width: 120,
                                      child: CachedNetworkImage(
                                        imageUrl: fullImageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: Lottie.asset(
                                            "assets/lottie/loading_spinner.json",
                                            width: 60,
                                            height: 60,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  /// 🔹 CENTER TEXT SECTION
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        /// Title
                                        Text(
                                          item['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontFamily: "Outfit",
                                          ),
                                        ),


                                        Text(
                                          tagsText,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.white70,
                                            fontFamily: "Outfit",
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// 🔹 RIGHT RADIO BUTTON
                                  InkWell(
                                    child: Container(
                                      height: 25,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: selectedIndex == index
                                            ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFE8D1AB),
                                            Color(0xFFD4A14D),
                                          ],
                                        )
                                            : null,
                                        border: Border.all(
                                          color: Colors.white54,
                                        ),
                                      ),
                                      child: selectedIndex == index
                                          ? const Center(
                                        child: CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Colors.black,
                                        ),
                                      )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),


                        ],
                      );
                    },
                  ),
                ),



              ],
            ),
          ),

        ),
      ),
      /// ✅ BOTTOM BAR (FIXED)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child:  OutlinedButton(
                onPressed: () => context.pop(widget.bookingId),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:  Text("Back",style: TextStyle(fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: selectedShootTypeId == null
                    ? null
                    : () {
                  _selectShootType();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIndex == -1
                      ? AppColors.goldGradientLight // disabled
                      : AppColors.primary, // enabled
                  foregroundColor: selectedIndex == -1
                      ? Colors.grey.shade400
                      : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
