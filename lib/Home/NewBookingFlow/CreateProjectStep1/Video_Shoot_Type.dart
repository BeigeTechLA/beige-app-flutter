import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import 'Shoot_Date_Time_screen.dart';
class VideoShootType extends StatefulWidget {
  final int bookingId;
  final int contentTypeId;
  // final int  specialtyId;
  const VideoShootType({super.key, required this.contentTypeId, required this.bookingId});

  @override
  State<VideoShootType> createState() => _VideoShootTypeState();
}
class _VideoShootTypeState extends State<VideoShootType>
    with AutomaticKeepAliveClientMixin {

bool  isLoading =true;

  int selectedIndex = -1;
List<Map<String, dynamic>> shootTypes = [];


int? selectedShootTypeId;
String? selectedShootTypeName;

@override
bool get wantKeepAlive => true; //
@override
void initState() {
  super.initState();
  _callBookingApi(widget.contentTypeId);
}


Future<void> _callBookingApi(int contentTypeId) async {
  setState(() => isLoading = true);

  try {
    final response = await ApiService().fetchData(
      "${ApiEndpoints.booking_shoot_types}$contentTypeId",
    );

    if (response != null &&
        response['error'] == false &&
        response['data'] is List) {

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
    }
  } catch (e) {
    debugPrint("❌ ShootType API Error → $e");
  } finally {
    setState(() => isLoading = false);
  }
}

int? selectedContentTypeId; //

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShootDateTimeScreen(
            // specialtyId: widget.specialtyId,
            ShootTypeId: selectedShootTypeId!,
            bookingId: bookingId, contentTypeId: widget.contentTypeId,
          ),
        ),
      );
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
     super.build(context);
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
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                ),
              ),
            ),
            Text(
              "Create Project",
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "1/3",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.all(20.0),
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
                        color: ColorCode.kSubtextColor, // grey background
                        borderRadius: BorderRadius.circular(64),
                      ),
                      child: isActive
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 5,
                          width: 70, // 🔥 colored portion only
                          decoration: BoxDecoration(
                            color: ColorCode.kButtonColor,
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
                      color: ColorCode.white,
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
                        Container(
                          padding: const EdgeInsets.all(10),
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
                                        "assets/lottie/Untitled_file.json",
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
                                        color: ColorCode.kWhiteOpacity70,
                                        fontFamily: "Outfit",
                                      ),
                                    ),

                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// 🔹 RIGHT RADIO BUTTON
                              InkWell(
                                splashColor: Colors.transparent,
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
                                },
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


                      ],
                    );
                  },
                ),
              ),



            ],
          ),

        ),
      ),
      /// ✅ BOTTOM BAR (FIXED)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child:  OutlinedButton(
                onPressed: () => Navigator.pop(context),
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
                      ? ColorCode.kGoldGradientLight // disabled
                      : ColorCode.kButtonColor, // enabled
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
