import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationMapScreen extends StatefulWidget {
  const SelectLocationMapScreen({super.key});

  @override
  State<SelectLocationMapScreen> createState() =>
      _SelectLocationMapScreenState();
}

class _SelectLocationMapScreenState extends State<SelectLocationMapScreen> {
  LatLng? currentLatLng;
  GoogleMapController? mapController;

  List<Location> searchResults = [];
  bool isSearching = false;

  String selectedAddress = "";
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLatLng = latLng;
    });

    /// ✅ IMPORTANT: screen open hote hi address lao
    await getAddressFromLatLng(latLng);
  }

  // ================= REVERSE GEOCODE =================
  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      final placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

        setState(() {
          selectedAddress = address;
          locationController.text = address;
        });
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
      return;
    }

    try {
      final locations = await locationFromAddress(query);

      setState(() {
        searchResults = locations;
        isSearching = true;
      });
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }
  Future<String> _getPlaceText(Location loc) async {
    final placemarks = await placemarkFromCoordinates(
      loc.latitude,
      loc.longitude,
    );

    if (placemarks.isEmpty) return "";

    final p = placemarks.first;
    return "${p.name}, ${p.locality}, ${p.administrativeArea}";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // ================= FULL SCREEN MAP =================
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLatLng!,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              mapController = controller;
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

          // ================= TOP BAR =================
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // BACK BUTTON
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),

                // SEARCH DISPLAY
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: locationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search location",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white54),
                          ),
                          onChanged: searchLocation,
                        ),
                      ),

                      /// 🔽 SEARCH DROPDOWN
                      if (isSearching && searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final loc = searchResults[index];

                              return FutureBuilder<String>(
                                future: _getPlaceText(loc),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }

                                  return ListTile(
                                    leading: const Icon(Icons.location_on, color: Colors.white54),
                                    title: Text(
                                      snapshot.data!,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    onTap: () async {
                                      final latLng = LatLng(loc.latitude, loc.longitude);

                                      setState(() {
                                        currentLatLng = latLng;
                                        locationController.text = snapshot.data!;
                                        selectedAddress = snapshot.data!;
                                        isSearching = false;
                                        searchResults.clear();
                                      });

                                      mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(latLng, 16),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),

                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= BOTTOM CONFIRM CARD =================
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Location",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedAddress.isEmpty
                        ? "Tap on the map to select location"
                        : selectedAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedAddress.isEmpty
                          ? null
                          : () =>
                          Navigator.pop(context, selectedAddress),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Confirm Location"),
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
}
