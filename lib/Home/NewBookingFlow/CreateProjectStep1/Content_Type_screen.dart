import 'package:flutter/material.dart';

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
                value: selectedContentType == "all",
                onTap: () {
                  setState(() {
                    selectedContentType = "all";
                  });
                },
              ),

              _buildOption(
                title: "Videography",
                activeImage: "assets/newbookflow/Videocamera_Record_active.png",
                inactiveImage: "assets/newbookflow/Videocamera_Record_inactive.png",
                value: selectedContentType == "video",
                onTap: () {
                  setState(() {
                    selectedContentType = "video";
                  });
                },
              ),


              _buildOption(
                title: "Photography",
                activeImage: "assets/newbookflow/Camera_active.png",
                inactiveImage: "assets/newbookflow/Camera_inactive.png",
                value: selectedContentType == "photo",
                onTap: () {
                  setState(() {
                    selectedContentType = "photo";
                  });
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
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isOptionSelected
                          ? () {
                        debugPrint("Selected: $selectedContentType");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoShootType(
                            /*  specialtyId: widget.specialtyId,
                              contentType: selectedContentType!,*/
                            ),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOptionSelected
                            ? ColorCode.kButtonColor // ✅ active color
                            : ColorCode.kGoldGradientLight, // ❌ disabled color
                        foregroundColor: isOptionSelected
                            ? Colors.black
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text("Continue",style: TextStyle(fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
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
