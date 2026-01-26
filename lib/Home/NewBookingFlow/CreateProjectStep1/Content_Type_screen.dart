import 'package:flutter/material.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart' show ApiService;
import '../../../utility/ColorCode.dart';
import 'Video_Shoot_Type.dart';

class ContentTypeScreen extends StatefulWidget {
  final int specialtyId;
  const ContentTypeScreen({super.key, required this.specialtyId});

  @override
  State<ContentTypeScreen> createState() => _ContentTypeScreenState();
}

class _ContentTypeScreenState extends State<ContentTypeScreen> {


  String? selectedContentType;

  bool get isOptionSelected => selectedContentType != null;

  String selectedShoot = "";
  List<String> selectedEdits = [];

  List<int> shootTypeIds = [];

  // Expand/Collapse states
  bool shootOpen = true;
  bool isShootTypeLoaded = false; 

  bool editOpen = true;
  bool isLoading =false;


  List specialties = [];

  int? selectedContentTypeId; // 👈 API VALUE
  bool get isContinueEnabled {
    return selectedContentTypeId != null && isShootTypeLoaded && !isLoading;
  }



  Future<void> _callBookingApi(int contentTypeId) async {
    setState(() {
      isLoading = true;
      isShootTypeLoaded = false; // reset
    });

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_shoot_types}$contentTypeId",
      );

      debugPrint("API Response → $response");

      if (response['error'] == false && response['data'] is List) {
        shootTypeIds = response['data']
            .map<int>((e) => e['shoot_type_id'] as int)
            .toList();

        debugPrint("Shoot Type IDs → $shootTypeIds");

        /// ✅ API SUCCESS → BUTTON ACTIVE
        setState(() {
          isShootTypeLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("API Error → $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> select_shoottype() async {
    if (selectedContentTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select content type")),
      );
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "specialty_id": widget.specialtyId,
      "content_type": selectedContentTypeId,
      "shoot_type_id": shootTypeIds.isNotEmpty ? shootTypeIds.first : null,
    };

    debugPrint("📤 BOOKING PAYLOAD → $body");

    try {
      final response = await ApiService().postData(
        ApiEndpoints.booking,
        body,
      );

      debugPrint("📥 BOOKING RESPONSE → $response");

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoShootType(
              contentTypeId: selectedContentTypeId!,
              specialtyId: widget.specialtyId,
              // bookingId: response['data']['booking_id'],*/ // ✅ if available
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







  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
          padding:  EdgeInsets.all(16.0),
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
                          width: 35.44, // 🔥 colored portion only
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
                    "Content Type",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

               SizedBox(height: 12),

              _buildOption(
                title: "Select All",
                activeImage: "assets/newbookflow/selectall_active.png",
                inactiveImage: "assets/newbookflow/slectall_inactive.png",
                value: selectedContentTypeId == 3,
                onTap: () {
                  setState(() => selectedContentTypeId = 3);
                  _callBookingApi(3);
                },
              ),
              /// 🔹 VIDEOGRAPHY → 1
              _buildOption(
                title: "Videography",
                activeImage: "assets/newbookflow/Videocamera_Record_active.png",
                inactiveImage: "assets/newbookflow/Videocamera_Record_inactive.png",
                value: selectedContentTypeId == 1,
                onTap: () {
                  setState(() => selectedContentTypeId = 1);
                  _callBookingApi(1);
                },
              ),
              /// 🔹 PHOTOGRAPHY → 2
              _buildOption(
                title: "Photography",
                activeImage: "assets/newbookflow/Camera_active.png",
                inactiveImage: "assets/newbookflow/Camera_inactive.png",
                value: selectedContentTypeId == 2,
                onTap: () {
                  setState(() => selectedContentTypeId = 2);
                  _callBookingApi(2);
                },
              ),



              _buildOption(
                title: "Editing Only",

                value: false,
                isDisabled: true,
                activeImage: "assets/newbookflow/edit-01.png",
                inactiveImage: "assets/newbookflow/edit-01.png",
                subtitle: "Coming Soon",
                onTap: null,
              ),

              _buildOption(
                title: "Livestreaming",

                value: false,
                isDisabled: true,
                activeImage: "assets/newbookflow/Play_Stream.png",
                inactiveImage: "assets/newbookflow/Play_Stream.png",
                subtitle: "Coming Soon",
                onTap: null,
              ),

              const Spacer(),

              /// 🔹 BOTTOM BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Back",style: TextStyle(fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
                    ),
                  ),
                   SizedBox(width: 12),
                  Expanded(
                    child:ElevatedButton(
                      onPressed: isContinueEnabled
                          ? () {
                        select_shoottype();
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isContinueEnabled
                            ? ColorCode.kButtonColor      // ✅ ACTIVE
                            : ColorCode.kGoldGradientLight, // ❌ DISABLED
                        foregroundColor: isContinueEnabled
                            ? Colors.black
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Text(
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
            ],
          ),
        ),
      ),);


  }
  Widget _buildOption({
    required String title,
    required String activeImage,
    required String inactiveImage,
    required bool value,
    required VoidCallback? onTap,
    bool isDisabled = false,
    String? subtitle,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap, // 🔥 FULL ROW CLICK
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [


            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
              child: Center(
                child: Image.asset(
                  value ? activeImage : inactiveImage,
                  height: 18,
                  width: 18,
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 🔹 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: isDisabled
                          ? ColorCode.kWhiteOpacity70
                          : value
                          ? ColorCode.kButtonColor // 🔥 ACTIVE TEXT
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// 🔹 RIGHT CHECK
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? ColorCode.kButtonColor : Colors.grey,
                ),
                color: value ? ColorCode.kButtonColor : Colors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

}
