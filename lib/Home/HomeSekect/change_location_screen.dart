import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class ChangeLocationScreen extends StatefulWidget {
  final LatLng initialLatLng;

  const ChangeLocationScreen({super.key, required this.initialLatLng});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  LatLng? selectedLatLng;
  String selectedAddress = "Search or select location";
  GoogleMapController? mapController;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLatLng = widget.initialLatLng;
    _getAddress(widget.initialLatLng);

    /// STATUS BAR – BLACK THEME
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final latLng =
        LatLng(locations.first.latitude, locations.first.longitude);

        setState(() => selectedLatLng = latLng);

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );

        await _getAddress(latLng);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: const Text(
            "Location not found",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _getAddress(LatLng latLng) async {
    final placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      final p = placemarks.first;
      setState(() {
        selectedAddress =
        "${p.street}, ${p.locality}, ${p.administrativeArea}";
      });
    }
  }

  /// 🌙 DARK MAP STYLE
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
          /// 🔝 TOP BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child:   InkWell(
                      onTap: () => Navigator.pop(context),
                    child: Image.asset("assets/Icons/Reply.png", height: 24),
                  ),

                  /*nkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),*/
                ),
                const SizedBox(height: 16),

                /// 🔍 SEARCH FIELD
                TextField(
                  controller: searchController,
                  onSubmitted: _searchLocation,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search for area, street name...",
                    hintStyle:  TextStyle(color: ColorCode.kWhiteOpacity70,fontFamily: "Outfit",fontWeight: FontWeight.w400,fontSize: 12),
                    prefixIcon:
                     Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🗺 DARK MAP
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: selectedLatLng!,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                mapController = controller;
                controller.setMapStyle(_darkMapStyle);
              },
              onTap: (latLng) async {
                setState(() => selectedLatLng = latLng);
                await _getAddress(latLng);
              },
              markers: {
                Marker(
                  markerId: const MarkerId("m1"),
                  position: selectedLatLng!,
                ),
              },
              zoomControlsEnabled: false,
            ),
          ),

          /// 📍 ADDRESS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              selectedAddress,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),

      /// 💾 SAVE BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorCode.kButtonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 52),
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
