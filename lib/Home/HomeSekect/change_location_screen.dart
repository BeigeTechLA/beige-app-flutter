import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:beige/utility/ColorCode.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../service/google_config.dart';

class ChangeLocationScreen extends StatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? mapController;

  LatLng? selectedLatLng;
  String selectedAddress = "select location";
  bool isManualSelection = false;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (selectedLatLng == null) {
      _getCurrentLocation();
    }
  }


  // ================= CURRENT LOCATION =================
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLatLng = latLng;
      });

      await _getAddressFromLatLng(latLng);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ================= ADDRESS FROM LAT LNG =================
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // 🔥 use Set to remove duplicates
        final addressParts = <String>{
          if (p.street != null && p.street!.isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode!,
          if (p.country != null && p.country!.isNotEmpty) p.country!,
        };

        String fullAddress = addressParts.join(', ');

        setState(() {
          selectedAddress = fullAddress;
          searchController.text = fullAddress;
        });
      }
    } catch (e) {
      debugPrint("Address error: $e");
    }
  }

  Future<void> changeLocationApi() async {
    if (selectedLatLng == null) return;

    final payload = {
      "location": selectedAddress,
      "lat": selectedLatLng!.latitude,
      "lng": selectedLatLng!.longitude,
    };

    try {
      debugPrint("📤 CHANGE LOCATION PAYLOAD = $payload");

      final response = await ApiService().putData(
        ApiEndpoints.chnage_location,
        payload,
      );

      debugPrint("📥 CHANGE LOCATION RESPONSE = $response");

      if (response != null && response['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location updated successfully")),
        );

        Navigator.pop(context, payload); // return updated data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['message'] ?? "Update failed")),
        );
      }
    } catch (e) {
      debugPrint("❌ CHANGE LOCATION ERROR = $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }
  }

  // ================= DARK MAP STYLE =================
  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
]
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ================= SEARCH (PLACES AUTOCOMPLETE) =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 70,   // 👈 status bar spacing
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration:  BoxDecoration(
              color: ColorCode.k282828,
              border: Border.all(color: Colors.transparent),

              /// ❌ REMOVE SHADOW
              boxShadow: const [],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),

              ),
            ),

            child: GooglePlaceAutoCompleteTextField(
              textEditingController: searchController,
              focusNode: searchFocusNode,
              googleAPIKey: GoogleConfig.placesApiKey,
              debounceTime: 800,
              isLatLngRequired: true,

              /// ✅ MAIN FIX HERE
              boxDecoration: BoxDecoration(
                color: ColorCode.kHeadingColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.transparent),
              ),

              textStyle: const TextStyle(
                color: ColorCode.kWhiteOpacity70,
                fontFamily: "Outfit",
                fontSize: 14,
              ),

              inputDecoration: InputDecoration(
                hintText: "Search location",
                hintStyle: TextStyle(color: ColorCode.kWhiteOpacity70,),

                filled: true,
                fillColor: Colors.transparent, // ⚠️ important

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,

                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    "assets/svg/serch.svg",
                    color: Colors.white,
                    height: 20,
                    width: 20,
                  ),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    searchController.clear();
                    searchFocusNode.unfocus();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: ColorCode.kWhiteOpacity70,
                      size: 20,
                    ),
                  ),
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),

              isCrossBtnShown: false,
              getPlaceDetailWithLatLng: (prediction) async {
                if (prediction.lat != null && prediction.lng != null) {

                  final latLng = LatLng(
                    double.parse(prediction.lat!),
                    double.parse(prediction.lng!),
                  );

                  /// 🔥 FIRST: close keyboard
                  searchFocusNode.unfocus();

                  /// 🔥 SECOND: delay (important)
                  await Future.delayed(const Duration(milliseconds: 200));

                  setState(() {
                    selectedLatLng = latLng;
                    selectedAddress = prediction.description ?? "";
                    searchController.text = selectedAddress;
                  });

                  /// 🔥 move map
                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(latLng, 16),
                  );
                }
              },

              itemClick: (prediction) async {
                searchController.text = prediction.description ?? "";

                /// 🔥 important (cursor fix)
                searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: searchController.text.length),
                );

                searchFocusNode.unfocus();
              },
            ),
          ),


          // ================= MAP =================
          Expanded(
            child: Stack(
              children: [

                /// ================= MAP =================
                selectedLatLng == null
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLatLng!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                    _mapController.complete(controller);
                    controller.setMapStyle(_darkMapStyle);
                  },
                  zoomControlsEnabled: false,   // ❗ ANDROID zoom +/- remove
              // Android zoom buttons
                  mapToolbarEnabled: false,       // 🔥 IMPORTANT (iOS fix)
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: false,

                  /// gestures (keep ON)
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
              /*    myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,*/
                  onTap: (latLng) async {
                    setState(() => selectedLatLng = latLng);
                    await _getAddressFromLatLng(latLng);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedLatLng!,
                    ),
                  },


                  // scrollGesturesEnabled: true,
                ),

                /// ================= ZOOM BUTTONS =================
                Positioned(
                  right: 16,
                  bottom: 20,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final controller = await _mapController.future;
                          controller.animateCamera(CameraUpdate.zoomIn());
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: SvgPicture.asset(
                              "assets/svg/zoom+.svg",
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final controller = await _mapController.future;
                          controller.animateCamera(CameraUpdate.zoomOut());
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: SvgPicture.asset(
                              "assets/svg/zoom-.svg",
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
     /*     Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    selectedAddress,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                      fontFamily: "Outfit",
                    ),
                  ),
                ),
              ),
            ],
          ),*/
        ],
      ),
      bottomNavigationBar: ClipRRect(
      /*  borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),*/
        child: Stack(
          children: [

            /// 🔥 BACKGROUND BLUR (MAIN)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 40,  // 👈 side blur
                sigmaY: 60,  // 👈 MORE vertical blur (bottom heavy 🔥)
              ),
              /*child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1B).withOpacity(0.6), // 👈 figma color
                ),
              ),*/
            ),

            /// 🔥 TOP FADE (important for smooth merge)
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            /// 🔥 CONTENT (TEXT + BUTTON)
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// LOCATION TEXT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      selectedAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontFamily: "Outfit",
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6C29C),
                        minimumSize: const Size(double.infinity, 52),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedLatLng == null) return;
                        await changeLocationApi();
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Unbounded",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
