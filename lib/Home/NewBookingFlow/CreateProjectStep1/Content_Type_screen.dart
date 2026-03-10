import 'package:flutter/material.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart' show ApiService;
import '../../../utility/ColorCode.dart';
import 'Video_Shoot_Type.dart';

class ContentTypeScreen extends StatefulWidget {
  final int ?specialtyId;
  const ContentTypeScreen({super.key,  this.specialtyId});

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

  List<int> selectedContentTypeIds = [];

  List specialties = [];


  bool get isContinueEnabled {
    return selectedContentTypeIds.isNotEmpty && isShootTypeLoaded && !isLoading;
  }

  bool get isSelectAll =>
      selectedContentTypeIds.contains(1) &&
          selectedContentTypeIds.contains(2);




  Future<void> _callBookingApi(int contentTypeId) async {

    // 🔥 SELECT ALL → NO LOADER, NO API
    if (contentTypeId == 3) {
      setState(() {
        isShootTypeLoaded = true;
        isLoading = false;
      });
      return;
    }


    setState(() {
      isLoading = true;
      isShootTypeLoaded = false;
    });

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking_shoot_types}$contentTypeId",
      );

      if (response['error'] == false && response['data'] is List) {
        shootTypeIds = response['data']
            .map<int>((e) => e['shoot_type_id'] as int)
            .toList();

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

/*  Future<void> select_shoottype() async {
    if (selectedContentTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select content type")),
      );
      return;
    }

    setState(() => isLoading = true);

    int contentTypeToSend =
    isSelectAll ? 3 : selectedContentTypeIds.first;

    final body = {
      "specialty_id": widget.specialtyId,
      "content_type": contentTypeToSend,
      if (!isSelectAll && shootTypeIds.isNotEmpty)
        "shoot_type_id": shootTypeIds.first,
    };

    debugPrint("📤 BOOKING PAYLOAD → $body");

    try {
      final response =
      await ApiService().postData(ApiEndpoints.booking, body);
      final bookingId = response['data']?['booking_id'];
      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoShootType(
              contentTypeId: contentTypeToSend,
              // specialtyId: widget.specialtyId,
              bookingId: bookingId,
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
  }*/


  Future<void> _handleSelection(int contentTypeId) async {

    if (isLoading) return; // 🔥 multiple click stop

    setState(() {
      isLoading = true;
      selectedContentTypeIds = contentTypeId == 3 ? [1,2] : [contentTypeId];
    });

    if (contentTypeId != 3) {
      await _callBookingApi(contentTypeId);
    } else {
      setState(() {
        isShootTypeLoaded = true;
      });
    }

    if (!isShootTypeLoaded) {
      setState(() => isLoading = false);
      return;
    }

    int contentTypeToSend = contentTypeId == 3 ? 3 : contentTypeId;

    final body = {
      "specialty_id": widget.specialtyId,
      "content_type": contentTypeToSend,
      if (contentTypeToSend != 3 && shootTypeIds.isNotEmpty)
        "shoot_type_id": shootTypeIds.first,
    };

    try {
      final response =
      await ApiService().postData(ApiEndpoints.booking, body);

      final bookingId = response['data']?['booking_id'];

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoShootType(
              contentTypeId: contentTypeToSend,
              bookingId: bookingId,
            ),
          ),
        );
      }

    } catch (e) {
      debugPrint("❌ Error → $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

/*  Future<void> _handleSelection(int contentTypeId) async {

    setState(() {
      selectedContentTypeIds = contentTypeId == 3 ? [1,2] : [contentTypeId];
    });

    /// Select All → API nahi
    if (contentTypeId != 3) {
      await _callBookingApi(contentTypeId);
    } else {
      setState(() {
        isShootTypeLoaded = true;
      });
    }

    if (!isShootTypeLoaded) return;

    int contentTypeToSend = contentTypeId == 3 ? 3 : contentTypeId;

    final body = {
      "specialty_id": widget.specialtyId,
      "content_type": contentTypeToSend,
      if (contentTypeToSend != 3 && shootTypeIds.isNotEmpty)
        "shoot_type_id": shootTypeIds.first,
    };

    try {
      final response =
      await ApiService().postData(ApiEndpoints.booking, body);

      final bookingId = response['data']?['booking_id'];

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoShootType(
              contentTypeId: contentTypeToSend,
              bookingId: bookingId,
            ),
          ),
        );
      }

    } catch (e) {
      debugPrint("❌ Error → $e");
    }
  }*/




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [

            /// Center Title
            Center(
              child: Text(
                "Create Project",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /// Right Step Text
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

        body: Stack(
          children: [

            /// MAIN UI
            SafeArea(
              child: AbsorbPointer(
                absorbing: isLoading, // 🔥 API call ke time click disable
                child: Opacity(
                  opacity: isLoading ? 0.6 : 1.0, // 🔥 thoda blur/disable feel
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [

                        /// STEP PROGRESS BAR
                        Row(
                          children: List.generate(3, (index) {
                            bool isActive = index == 0;

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                height: 5,
                                decoration: BoxDecoration(
                                  color: ColorCode.kSubtextColor,
                                  borderRadius: BorderRadius.circular(64),
                                ),
                                child: isActive
                                    ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 5,
                                    width: 35.44,
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

                        const SizedBox(height: 20),

                        /// TITLE
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Content Type",
                            style: TextStyle(
                              fontFamily: "Unbounded",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// SELECT ALL
                        _buildOption(
                          title: "Select All",
                          activeImage: "assets/newbookflow/SelectAll_active.png",
                          inactiveImage: "assets/newbookflow/slectall_inactive.png",
                          value: isSelectAll,
                          onTap: () => _handleSelection(3),
                        ),

                        /// VIDEOGRAPHY
                        _buildOption(
                          title: "Videography",
                          activeImage:
                          "assets/newbookflow/Videocamera_Record_active.png",
                          inactiveImage:
                          "assets/newbookflow/Videocamera_Record_inactive.png",
                          value: selectedContentTypeIds.contains(1),
                          onTap: () => _handleSelection(1),
                        ),

                        /// PHOTOGRAPHY
                        _buildOption(
                          title: "Photography",
                          activeImage: "assets/newbookflow/Camera_active.png",
                          inactiveImage: "assets/newbookflow/Camera_inactive.png",
                          value: selectedContentTypeIds.contains(2),
                          onTap: () => _handleSelection(2),
                        ),

                        /// EDITING
                        _buildOption(
                          title: "Editing Only (Coming Soon)",
                          value: false,
                          isDisabled: true,
                          activeImage: "assets/newbookflow/edit-01.png",
                          inactiveImage: "assets/newbookflow/edit-01.png",
                          onTap: null,
                        ),

                        /// LIVESTREAM
                        _buildOption(
                          title: "Livestreaming (Coming Soon)",
                          value: false,
                          isDisabled: true,
                          activeImage: "assets/newbookflow/Play_Stream.png",
                          inactiveImage: "assets/newbookflow/Play_Stream.png",
                          onTap: null,
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));


  }
  Widget _buildOption({
    required String title,
    required String activeImage,
    required String inactiveImage,
    required bool value,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12), // ⭐ important
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// ICON
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: Center(
                child: Image.asset(
                  value ? activeImage : inactiveImage,
                  height: 20,
                  width: 20,
                ),
              ),
            ),

            const SizedBox(width: 16),

            /// TITLE
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? ColorCode.kWhiteOpacity60
                      : value
                      ? ColorCode.kButtonColor
                      : Colors.white,
                ),
              ),
            ),

            /// CHECK BOX
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? ColorCode.kButtonColor
                      : ColorCode.kBorderLight,
                  width: 0.5,
                ),
                color: value
                    ? ColorCode.kButtonColor
                    : Colors.transparent,
              ),
              child: value
                  ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.black,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

}
