import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ChangeLocationScreen extends StatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  State<ChangeLocationScreen> createState() => _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  LatLng? selectedLatLng;
  String selectedAddress = "Detecting current location...";
  GoogleMapController? mapController;
  final TextEditingController searchController = TextEditingController();
  List<Location> searchResults = [];
  bool isSearching = false;

  List<Map<String, dynamic>> searchResultsData = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  // ================= CURRENT LOCATION =================
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      selectedLatLng = latLng;
    });

    await _getAddress(latLng);

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 16),
    );
  }

  // ================= SEARCH LOCATION =================
  Future<void> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);

      if (locations.isEmpty) {
        setState(() {
          searchResultsData.clear();
          isSearching = false;
        });
        return;
      }

      List<Map<String, dynamic>> results = [];

      for (final loc in locations.take(5)) {
        final placemarks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;

          final addressParts = [
            p.name,
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ]..removeWhere((e) => e == null || e!.isEmpty);

          results.add({
            "latLng": LatLng(loc.latitude, loc.longitude),
            "address": addressParts.join(", "),
          });
        }
      }

      setState(() {
        searchResultsData = results;
        isSearching = results.isNotEmpty;
      });
    } catch (e) {
      debugPrint("Search error: $e");
      setState(() {
        searchResultsData.clear();
        isSearching = false;
      });
    }
  }


  // ================= GET ADDRESS =================
  Future<void> _getAddress(LatLng latLng) async {
    final placemarks =
    await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (placemarks.isNotEmpty) {
      final p = placemarks.first;

      final address =
          "${p.street}, ${p.locality}, ${p.administrativeArea}";

      setState(() {
        selectedAddress = address;
        searchController.text = address; // ✅ show in search box
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
          // ================= TOP BAR =================
          Stack(
            children: [
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
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset("assets/Icons/Reply.png", height: 24),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // SEARCH FIELD
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        if (value.trim().length >= 3) {
                          searchLocation(value.trim());
                        } else {
                          setState(() {
                            searchResultsData.clear();
                            isSearching = false;
                          });
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search for area, street name...",
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
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

              // 🔥 DROPDOWN OVERLAY
              if (isSearching && searchResultsData.isNotEmpty)
                Positioned(
                  top: 140, // search field ke niche
                  left: 16,
                  right: 16,
                  child: Material(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(14),
                    elevation: 8,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResultsData.length,
                      itemBuilder: (context, index) {
                        final item = searchResultsData[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.white70),
                          title: Text(
                            item["address"],
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              selectedLatLng = item["latLng"];
                              selectedAddress = item["address"];
                              searchController.text = item["address"];
                              isSearching = false;
                              searchResultsData.clear();
                            });

                            mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(item["latLng"], 16),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),


          // ================= MAP =================
          Expanded(
            child: selectedLatLng == null
                ? const Center(
              child:
              CircularProgressIndicator(color: Colors.white),
            )
                : GoogleMap(
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
                await _getAddress(latLng); //
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

          // ================= ADDRESS =================
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

      // ================= SAVE BUTTON =================
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
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
