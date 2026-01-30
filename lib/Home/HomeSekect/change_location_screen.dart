import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:beige/utility/ColorCode.dart';

class ChangeLocationScreen extends StatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? mapController;

  LatLng? selectedLatLng;
  String selectedAddress = "Search or select location";

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      setState(() {
        selectedAddress =
        "${p.subLocality ?? ""}, ${p.locality ?? ""}, ${p.administrativeArea ?? ""}";
        searchController.text = selectedAddress;
      });
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
      backgroundColor: Colors.black,

      body: Column(
        children: [
          // ================= SEARCH (PLACES AUTOCOMPLETE) =================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: searchController,
              googleAPIKey: "AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc",
              debounceTime: 800,
              isLatLngRequired: true,

              inputDecoration: InputDecoration(
                hintText: "Search location",
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),

              getPlaceDetailWithLatLng: (prediction) {
                if (prediction.lat != null && prediction.lng != null) {
                  LatLng latLng = LatLng(
                    double.parse(prediction.lat!),
                    double.parse(prediction.lng!),
                  );

                  setState(() {
                    selectedLatLng = latLng;
                    selectedAddress = prediction.description!;
                  });

                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(latLng, 16),
                  );
                }
              },

              itemClick: (prediction) {
                searchController.text = prediction.description!;
                searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description!.length),
                );
              },

              seperatedBuilder: const Divider(color: Colors.white24),
              isCrossBtnShown: true,
              textStyle: const TextStyle(color: Colors.white),
            ),
          ),

          // ================= MAP =================
          Expanded(
            child: selectedLatLng == null
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
              zoomControlsEnabled: false,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              selectedAddress,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorCode.kButtonColor,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            Navigator.pop(context, {
              "address": selectedAddress,
              "latLng": selectedLatLng,
            });
          },
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
