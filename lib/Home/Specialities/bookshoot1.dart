import 'package:flutter/material.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';
import '../HomeSekect/select_location.dart';

class Bookshoot1 extends StatefulWidget {
  final int specialtyId;
  final int deliverableId;
  final String deliverableName;

  const Bookshoot1({super.key, required this.specialtyId, required this.deliverableId, required this.deliverableName});

  @override
  State<Bookshoot1> createState() => _Bookshoot1State();
}

class _Bookshoot1State extends State<Bookshoot1> {
  int selectedIndex = 0;

  int? selectedServiceTypeId;
  List serviceTypes = [];
  bool isLoading = true;

  bool isPageLoading = true;
  bool isBookingLoading = false;
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
          serviceTypes = response['data']['service_types'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> booking() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().postData(
        ApiEndpoints.booking,
        {
          "specialty_id": widget.specialtyId,
          "deliverable_option": widget.deliverableId,
          "service_type": selectedServiceTypeId,
        },
      );

      if (response != null && response['error'] == false) {
        final int bookingId = response['data']['booking_id'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SelectLocation(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Booking failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: Stack(
        children: [

          /// ✅ Background Image
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

          /// ✅ Bottom Sheet Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 20),
              decoration:BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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

                  const SizedBox(height: 16),

                  /// Title + Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Book Your Shoot Now",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                          fontSize: 16,
                          fontFamily: "Unbounded", //
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,color: ColorCode.white,),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Divider(color: ColorCode.kDividerWhite12),
                  SizedBox(height: 10),

                  /// ✅ Options
              /*    buildRadio("Photography", 0),
                  buildRadio("Videography", 1),
                  buildRadio("Both", 2),*/

                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: serviceTypes.map((item) {
                      return buildRadio(
                        title: item['label'],
                        id: item['id'],
                      );
                    }).toList(),
                  ),


                  const SizedBox(height: 20),

                  /// ✅ Buttons
                  Row(
                    children: [
                      // ✅ Back Button
                      Expanded(
                          child: SizedBox(
                            height: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ColorCode.kHeadingColor,
                                side: const BorderSide(
                                  color: ColorCode.kWhiteOpacity70,
                                  width: 0.5,        // ⭐ BORDER WIDTH 0.5
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  color: ColorCode.white,
                                  fontFamily: 'Unbounded',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )

                      ),

                      const SizedBox(width: 12),

                      // ✅ Next Button
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE7C89E),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            onPressed: isLoading
                                ? null
                                : () {
                            /*  if (selectedServiceTypeId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please select service type")),
                                );
                                return;
                              }
                              booking();*/
                            },

                            child: const Text(
                              "Next",
                              style: TextStyle(
                                color: ColorCode.kHeadingColor,
                                fontFamily: 'Unbounded',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ),
                        ),
                      ),

                    ],
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadio({required String title, required int id}) {
    final isSelected = selectedServiceTypeId == id;

    return InkWell(
      onTap: () {
        setState(() {
          selectedServiceTypeId = id;
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

            /// 🔵 Custom Radio
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
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
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

}