import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../app/route_names.dart';
import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../app/colors.dart';
class VideoShootType extends StatefulWidget {
  final int bookingId;
  final int contentTypeId;
  // final int  specialtyId;
  const VideoShootType({super.key, required this.contentTypeId, required this.bookingId});

  @override
  State<VideoShootType> createState() => _VideoShootTypeState();
}
class _VideoShootTypeState extends State<VideoShootType>
{

bool  isLoading =true;

  // int selectedIndex = -1;
List<Map<String, dynamic>> shootTypes = [];

int? selectedContentTypeId; //
/*
int? selectedShootTypeId;
String? selectedShootTypeName;
*/


  int selectedIndex = -1;
  int? selectedShootTypeId;
  String? selectedShootTypeName;


@override
void initState() {
  super.initState();

  if (shootTypes.isEmpty) {
    _callBookingApi(widget.contentTypeId);
  }
}
  Future<void> _callBookingApi(int contentTypeId) async {
    setState(() {
      isLoading = true;
      // shootTypes.clear();
    });

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_shoot_types}$contentTypeId",
      );

      if (response != null &&
          response['error'] == false &&
          response['data'] is List) {

        // ✅ DATA LOAD
        shootTypes = response['data']
            .map<Map<String, dynamic>>((e) => {
          "id": e['shoot_type_id'],
          "name": e['name'],
          "image": e['image_url'],
          "content_type": e['content_type'],
          "tags": _parseTags(e['tags']),
        })
            .toList();

        debugPrint("✅ ShootTypes Loaded → ${shootTypes.length}");

        // 🔥🔥 MOST IMPORTANT FIX (RESTORE SELECTION AFTER DATA)
        if (selectedShootTypeId != null) {
          final index = shootTypes.indexWhere(
                (e) => e['id'] == selectedShootTypeId,
          );

          if (index != -1) {
            selectedIndex = index;
          }
        }
      }
    } catch (e) {
      debugPrint("❌ ShootType API Error → $e");
    } finally {
      setState(() => isLoading = false);
    }
  }



List<dynamic> _parseTags(dynamic tags) {
  if (tags == null) return [];

  try {
    if (tags is String) {
      return jsonDecode(tags);
    } else if (tags is List) {
      return tags;
    }
  } catch (e) {
    debugPrint("⚠️ Tag parse error → $tags");
  }

  return [];
}
Future<void> select_shoottype() async {
  if (selectedShootTypeId == null || selectedShootTypeName == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select shoot type")),
    );
    return;
  }


  setState(() => isLoading = true);

  final body = {
    "project_name": selectedShootTypeName, // ✅ FIRST API NAME
    "content_type": widget.contentTypeId,  // ✅ dynamic
    "shoot_type_id": selectedShootTypeId,  // ✅ dynamic
    "specialty_id": 22,    // ✅ dynamic
    // "deliverable_option": 1,
    // "service_type": 2,
  };

  debugPrint("📤 BOOKING PAYLOAD → $body");

  try {
    final response = await ApiService().postData(
      // ApiEndpoints.booking,
       "${ApiEndpoints.booking}/${widget.bookingId}",
      body,
    );

    debugPrint("📥 BOOKING RESPONSE → $response");

    if (response != null && response['error'] == false) {
      final bookingId = response['data']?['booking_id'];
      final result = await context.pushNamed<Map>(RouteNames.shootDateTime, extra: {
        'bookingId': bookingId,
        'contentTypeId': widget.contentTypeId,
        'shootTypeId': selectedShootTypeId!,
        'shootTypeName': selectedShootTypeName,
      });

      if (result != null) {
        setState(() {
          selectedShootTypeId = result["id"];
          selectedShootTypeName = result["name"];

          final index = shootTypes.indexWhere(
                (e) => e['id'] == selectedShootTypeId,
          );

          if (index != -1) {
            selectedIndex = index;
          }
        });
      }

      if (result != null) {
        setState(() {
          selectedShootTypeId = result["id"];
          selectedShootTypeName = result["name"];

          final index = shootTypes.indexWhere(
                (e) => e['id'] == selectedShootTypeId,
          );

          if (index != -1) {
            selectedIndex = index;
          }
        });
      }

      if (result == true) {
        // 🔥 DO NOTHING (state preserve)
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Something went wrong")),
      );
    }
  } catch (e) {
    debugPrint("❌ Booking API Error → $e");
  } finally {
    setState(() => isLoading = false);
  }
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
                      final fullImageUrl = imagePath.isNotEmpty
                          ? ApiService().getImageURL(imagePath)
                          : '';


                      debugPrint("🧾 RAW IMAGE PATH → $imagePath");
                      debugPrint("🖼 FULL IMAGE URL → $fullImageUrl");

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

                              debugPrint("✅ Selected ID → $selectedShootTypeId");
                              debugPrint("✅ Selected Name → $selectedShootTypeName");
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
                               /*     splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        selectedShootTypeId = item['id'];
                                        selectedShootTypeName = item['name']; // ✅ IMPORTANT FIX
                                      });

                                      debugPrint("✅ Selected ID → $selectedShootTypeId");
                                      debugPrint("✅ Selected Name → $selectedShootTypeName");
                                    },*/
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
                  select_shoottype(); // 🔥 PRE API CALL
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
