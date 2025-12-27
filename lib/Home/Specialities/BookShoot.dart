import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import 'bookshoot1.dart';

class BookShootScreen extends StatefulWidget {
  final int specialtyId;

  const BookShootScreen({super.key,
    required this.specialtyId,
  });

  @override
  State<BookShootScreen> createState() => _BookShootScreenState();
}

class _BookShootScreenState extends State<BookShootScreen> {
  // int selectedIndex = 0;
  String? selectedDeliverableName;
  int? selectedDeliverableId;
  bool isNextLoading = false;


  int? selectedIndex; // null means nothing selected

  bool isLoadingSpecialties = true;

  List deliverables = [];


  @override
  void initState() {
    super.initState();
    _fetchbooking_data();
  }

  Future<void> _fetchbooking_data() async {
    try {
      final response = await ApiService().fetchData(ApiEndpoints.booking_data);

      if (response != null && response['error'] == false) {
        setState(() {
          deliverables = response['data']['deliverables'] ?? [];
          isLoadingSpecialties = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoadingSpecialties = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorCode.black,
      body: Stack(
        children: [
          /// ✅ BACKGROUND IMAGE FIXED — FULL SCREEN
          Container(
            height: height,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Rectangle 34660882.png",),
                  fit: BoxFit.fill
              ),
            ),
          ),

          /// ✅ BOTTOM SHEET FLOATING ABOVE IMAGE
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 20),
               // padding:  EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Drag line
                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color:ColorCode.kWhiteOpacity70,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        "Book Your Shoot Now",
                        style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: 'Unbounded',   // ← Add this
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          // Looks cleaner in Unbounded
                        ),
                      ),
                      IconButton(
                        icon:  Icon(Icons.close,color: ColorCode.white,),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),

                  Divider(color: ColorCode.kDividerWhite12),
                   SizedBox(height: 16),

                  isLoadingSpecialties
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deliverables.length,
                    itemBuilder: (context, index) {
                      final item = deliverables[index];
                      return buildRadio(
                        item["label"],
                        index,
                        item["id"],
                      );

                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7C89E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isNextLoading
                          ? null
                          : () async {
                        if (selectedDeliverableId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select an option")),
                          );
                          return;
                        }

                        setState(() {
                          isNextLoading = true; // 🔥 loader ON
                        });

                        await Future.delayed(const Duration(milliseconds: 600)); // smooth feel

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Bookshoot1(
                              specialtyId: widget.specialtyId,
                              deliverableId: selectedDeliverableId!,
                              deliverableName: selectedDeliverableName!,
                            ),
                          ),
                        ).then((_) {
                          setState(() {
                            isNextLoading = false; // 🔥 loader OFF when back
                          });
                        });
                      },

                      child: const Text("Next",
                        style: TextStyle(
                          color: ColorCode.kHeadingColor,
                          fontFamily: 'Unbounded',   // ← Add this
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          // Looks cleaner in Unbounded
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadio(String title, int index, int id) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
          selectedDeliverableId = id;          // ✅ ID
          selectedDeliverableName = title;     // ✅ NAME
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: ColorCode.kWhiteOpacity70,
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selectedIndex == index
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorCode.black,
                  ),
                ),
              )
                  : null,
            )
          ],
        ),
      ),
    );
  }


}
