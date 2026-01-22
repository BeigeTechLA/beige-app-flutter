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

    debugPrint("🎯 Shoot Type API → $response");

    if (response['error'] == false && response['data'] is List) {
      /// 🔥 FILTER BASED ON content_type
      shootTypes = response['data']
          .where((e) =>
      e['content_type'] == widget.contentTypeId ||
          e['content_type'] == 3) // 👈 3 = BOTH
          .map<Map<String, dynamic>>((e) => {
        "id": e['shoot_type_id'],
        "name": e['name'],
        "image": e['image_url'],
        "content_type": e['content_type'],
      })
          .toList();

      debugPrint("✅ FILTERED SHOOT TYPES → $shootTypes");
    }
  } catch (e) {
    debugPrint("❌ ShootType API Error → $e");
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
                    "Video Shoot Type",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
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
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        debugPrint("Selected index: $index");
                      },
                      child: Column(
                        children: [

                          /// 🔹 CARD
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: Image.asset(
                                "assets/newbookflow/Frame_2087328912.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// 🔹 TITLE + RADIO
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Text(
                                  "Corporate Event ${index + 1}",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    color: ColorCode.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                /// ✅ RADIO BUTTON
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
                                      ? Center(
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
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
                onPressed: selectedIndex == -1
                    ? null
                    : () {
                  debugPrint("Selected index: $selectedIndex");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShootDateTimeScreen(),
                    ),
                  );
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
