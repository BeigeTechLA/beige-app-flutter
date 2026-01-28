import 'package:flutter/material.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import 'Shoot_Date_Time_screen.dart';
class VideoShootType extends StatefulWidget {

  final int contentTypeId;
  final int specialtyId;
  const VideoShootType({super.key, required this.contentTypeId, required this.specialtyId});

  @override
  State<VideoShootType> createState() => _VideoShootTypeState();
}

class _VideoShootTypeState extends State<VideoShootType> {
bool  isLoading =true;

  int selectedIndex = -1;
List<Map<String, dynamic>> shootTypes = [];


int? selectedShootTypeId;
String? selectedShootTypeName; // ✅ NAME store karne ke liye

@override
void initState() {
  super.initState();

  _callBookingApi(widget.contentTypeId); // 🔥 AUTO API CALL
}


Future<void> _callBookingApi(int contentTypeId) async {
  setState(() => isLoading = true);

  try {
    final response = await ApiService().fetchData(
      "${ApiEndpoints.booking_shoot_types}$contentTypeId",
    );

    if (response['error'] == false && response['data'] is List) {
      shootTypes = response['data']
          .where((e) =>
      e['content_type'] == widget.contentTypeId ||
          e['content_type'] == 3)
          .map<Map<String, dynamic>>((e) => {
        "id": e['shoot_type_id'],
        "name": e['name'],
        "image": e['image_url'],
        "content_type": e['content_type'],
      })
          .toList();
    }
  } catch (e) {
    debugPrint("❌ ShootType API Error → $e");
  } finally {
    setState(() => isLoading = false);
  }
}


int? selectedContentTypeId; // 👈 API VALUE


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
    "specialty_id": widget.specialtyId,    // ✅ dynamic
    // "deliverable_option": 1,
    // "service_type": 2,
  };

  debugPrint("📤 BOOKING PAYLOAD → $body");

  try {
    final response = await ApiService().postData(
      ApiEndpoints.booking,
      body,
    );

    debugPrint("📥 BOOKING RESPONSE → $response");

    if (response != null && response['error'] == false) {
      final bookingId = response['data']?['booking_id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShootDateTimeScreen(specialtyId: widget.specialtyId, ShootTypeId: selectedShootTypeId!,
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
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  color: ColorCode.white,
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
                  itemCount: shootTypes.length,
                  padding: const EdgeInsets.only(top: 12),
                  itemBuilder: (context, index) {
                    final item = shootTypes[index];        // ✅ PEHLE
                    // final imagePath = item['image'];       // ✅ PHIR USE
                    final imagePath = item['image']?.toString() ?? '';
                    final fullImageUrl = imagePath.isNotEmpty
                        ? ApiService().getImageURL(imagePath)
                        : '';

                    selectedShootTypeId = item['id'];
                    selectedShootTypeName = item['name'];

                    debugPrint("🧾 RAW IMAGE PATH → $imagePath");
                    debugPrint("🖼 FULL IMAGE URL → $fullImageUrl");

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          selectedShootTypeId = item['id']; // 👈 IMPORTANT
                        });

                        debugPrint("✅ Selected ShootType ID → $selectedShootTypeId");
                      },
                      child: Column(
                        children: [

                          /// 🔹 IMAGE CARD (DYNAMIC)
                        Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: imagePath.isNotEmpty
                              ? Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,

                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                // ✅ fully loaded image
                                return child;
                              }

                              // ✅ proper loader only
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ColorCode.kButtonColor,
                                ),
                              );
                            },

                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/newbookflow/Frame_2087328912.png",
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            "assets/newbookflow/Frame_2087328912.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),





                        /// 🔹 TITLE + RADIO
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                /// 🔹 TITLE (DYNAMIC)
                                Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    color: ColorCode.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                /// 🔹 RADIO BUTTON
                                Container(
                                  height: 32,
                                  width: 32,
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
                                      color: ColorCode.kWhiteOpacity70,
                                      width: 1,
                                    ),
                                  ),
                                  child: selectedIndex == index
                                      ? const Center(
                                    child: CircleAvatar(
                                      radius: 5,
                                      backgroundColor: Colors.black,
                                    ),
                                  )
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
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
