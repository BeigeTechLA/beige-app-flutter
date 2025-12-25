import 'package:beige/Home/HomeSekect/select_date_time.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';

class SelectLocation extends StatefulWidget {
  final int bookingId;

  const SelectLocation({super.key, required this.bookingId});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  bool savePassword = false;
  String? selectedStudio;
  bool showMap = false;
bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  GoogleMapController? mapController;
  LatLng? currentLatLng;

  Future<void> select_location() async {
    if (currentLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select location from map")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().putData(
        "${ApiEndpoints.booking}/${widget.bookingId}/location",
        {
          "event_location": "Selected from map",
          "event_latitude": currentLatLng!.latitude,
          "event_longitude": currentLatLng!.longitude,
        },
      );

      if (response != null && response['error'] == false) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelectDateTime(
              bookingId: widget.bookingId,
            ),
          ),
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



  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng!, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:  ColorCode.kBackgroundColor,
      appBar: AppBar(
        // backgroundColor: ColorCode.kBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            "assets/Icons/Reply.png", height: 24, color: ColorCode.white,),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "1/5",
                style: TextStyle(color: ColorCode.white),
              ),
            ),
          )
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Progress Bar
            Row(
              children: List.generate(
                5,
                    (index) =>
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        height: 5,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? ColorCode.kButtonColor
                              : ColorCode.kSubtextColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Title
            Text(
              "Select The Location",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            /// ✅ Search Field
          /*  TextField(
              decoration: InputDecoration(
                hintText: "Search for area, street name...",
                hintStyle: TextStyle(
                  color: ColorCode.k777571,
                  fontFamily: 'Outfit                ', // ← Add this
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  // Looks cleaner in Unbounded
                ),

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    Icons.search,
                    color: ColorCode.white,
                    size: 22,
                  ),
                ),

                filled: true,
                fillColor: ColorCode.k262624,

                // ⭐ Ye sabse important hai – inner padding (top/bottom/left/right)
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 18,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),

              ),
            ),*/

            TextField(
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    showMap = true;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "Search for area, street name...",
                hintStyle: TextStyle(
                  color: ColorCode.k777571,
                  fontFamily: 'Outfit',
                  fontSize: 12,
                ),
                prefixIcon: const Icon(Icons.search, color: ColorCode.white),
                filled: true,
                fillColor: ColorCode.k262624,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ✅ Map Placeholder
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: currentLatLng == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLatLng!,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("current"),
                      position: currentLatLng!,
                    ),
                  },
                  onTap: (latLng) {
                    setState(() {
                      currentLatLng = latLng;
                    });
                  },
                ),
              ),
            ),


            SizedBox(height: 16),

            /// ✅ Address Row
            Row(
              children: [
                Icon(Icons.location_on_outlined),
                // SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "2458 Sunset Boulevard\nLos Angeles, CA 90026",
                    style: TextStyle(
                      color: ColorCode.white,
                      fontFamily: 'Outfit', // ← Add this
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // Looks cleaner in Unbounded
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Change",
                    style: TextStyle(
                      color: ColorCode.kButtonColor,
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorCode
                          .kButtonColor, // ⭐ Underline ka color

                    ),
                  ),
                ),

              ],
            ),

            SizedBox(height: 12),

            Divider(color: ColorCode.k262624),

            SizedBox(height: 12),

            /// ✅ Next Button
            ///
     /*       Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => savePassword = !savePassword),
                      child: Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: savePassword ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: ColorCode.white),
                        ),
                        child: savePassword
                            ? const Icon(Icons.check, size: 14, color: ColorCode.kButtonColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "I need a Beige Studio\n",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: "Outfit",

                                  ),
                                ),

                                TextSpan(
                                  text: "Professional studio with lighting & equipment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: ColorCode.k777571,
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )



                  ],
                ),
                SizedBox(height: 15),
                buildSelectStudioField(),
                SizedBox(height: 15),

              ],
            ),*/

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7C89E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : select_location,

                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildSelectStudioField() {
    String? selectedStudio;

    return StatefulBuilder(
      builder: (context, setState) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: "Select Studio",
            labelStyle: TextStyle(
              color: ColorCode.k777571,
              fontSize: 14, // 🔹 Label size same rakha
            ),
            filled: true,
            fillColor: Color(0xFF1C1C1C),

            // 🔥 DROP HEIGHT SMALL
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,   // 🔥 Makes dropdown more compact
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorCode.white,
              ),
              value: selectedStudio,
              dropdownColor: Color(0xFF1C1C1C),
/*
              hint: Text(
                "Select Studio",
                style: TextStyle(
                  color: ColorCode.k777571,
                  fontSize: 15,
                ),
              ),*/

              onChanged: (value) {
                setState(() {
                  selectedStudio = value;
                });
              },

              items: [
                "Studio A",
                "Studio B",
                "Studio C",
                "Studio D",
              ].map((val) {
                return DropdownMenuItem(
                  value: val,

                  // 🔥 DROP ITEM HEIGHT SMALL
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      val,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

  }



}
