import 'package:beige/Home/HomeSekect/select_date_time.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../widgets/TopMessage.dart';
import 'change_location_screen.dart';

class SelectLocation extends StatefulWidget {


  const SelectLocation({super.key, });

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  bool savePassword = false;
  String? selectedStudio;
  bool showMap = false;
   bool isLoading = false;

  GoogleMapController? mapController;
  LatLng? currentLatLng;

  String selectedAddress = "Search or select location";
  TextEditingController searchController = TextEditingController();




  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        final latLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          currentLatLng = latLng;
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );

        await getAddressFromLatLng(latLng);
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Location not found")),
      // );
      TopMessage.show(context,'Location not found');

    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          selectedAddress =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
        });
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }





  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings(); // 👈 THIS IS IMPORTANT
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Location permission permanently denied. Enable from settings."),
      //   ),
      // );

      TopMessage.show(context,"Location permission permanently denied. Enable from settings.");

      await Geolocator.openAppSettings(); // 👈 Open app settings
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }



  @override
  Widget build(BuildContext context) {

    const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#383838"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

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
              controller: searchController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  searchLocation(value);
                }
              },
              decoration: InputDecoration(
                hintText: "Search area, street, city...",
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
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  onMapCreated: (controller) {
                    mapController = controller;
                    controller.setMapStyle(_darkMapStyle);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: currentLatLng!,
                    ),
                  },
                  onTap: (latLng) async {
                    setState(() {
                      currentLatLng = latLng;
                    });
                    await getAddressFromLatLng(latLng);
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
                    selectedAddress,
                    style: TextStyle(
                      color: ColorCode.white,
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeLocationScreen(
                          // initialLatLng: currentLatLng!,
                        ),
                      ),
                    );

                    if (result != null && result is Map) {
                      setState(() {
                        selectedAddress = result['address'] as String;
                        currentLatLng = result['latLng'] as LatLng;
                        searchController.text = selectedAddress; // 👈 optional but best
                      });
                    }


                  },
                  child:  Text(
                    "Change",
                    style: TextStyle(
                      color: ColorCode.kButtonColor,
                      decoration: TextDecoration.underline,
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
              onPressed: () {

              },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
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
