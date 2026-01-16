import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utility/ColorCode.dart';
import 'crew_size_matching_screen.dart';

class MoreDetailsScreen extends StatefulWidget {
  const MoreDetailsScreen({super.key});

  @override
  State<MoreDetailsScreen> createState() => _MoreDetailsScreenState();
}

class _MoreDetailsScreenState extends State<MoreDetailsScreen> {

  int currentStep = 1;
  bool loding   = true;
  int quantity = 1;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
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
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission permanently denied. Enable from settings."),
        ),
      );
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

     String _darkMapStyle = '''
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

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // 🔹 Back Button (Left)
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
                "2/3",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child:SingleChildScrollView(
        child: Padding(padding:  EdgeInsets.all(16.0),
        child: Column(
          children: [
        
        
        
        Row(
        children: List.generate(3, (index) {
          double fillWidth = 0;
        
          if (index < currentStep) {
            // ✅ Completed step (FULL)
            fillWidth = double.infinity;
          } else if (index == currentStep) {
            // 🟡 Current step (HALF)
            fillWidth = 35.44;
          } else {
            // ⭕ Upcoming step (EMPTY)
            fillWidth = 0;
          }
        
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 5,
              decoration: BoxDecoration(
                color: ColorCode.kSubtextColor, // grey background
                borderRadius: BorderRadius.circular(64),
              ),
              child: fillWidth > 0
                  ? Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 5,
                  width: fillWidth == double.infinity ? null : fillWidth,
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
                  "More Details",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        
        
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              /// 🔹 MORE DETAILS
              Text(
                "More Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        
              const SizedBox(height: 12),
        
              /// 🔹 INCLUDED CARD
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.videocam, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Videographer x 1",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Included",
                        style: TextStyle(
                          color: Color(0xFFE7C38A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 24),
        
              /// 🔹 QUESTION
              Text(
                "Do You Need An Additional\nShooter?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        
              const SizedBox(height: 12),
        
              /// 🔹 YES / NO RADIO
              Row(
                children: [
                  _radioOption("Yes", true),
                  const SizedBox(width: 24),
                  _radioOption("No", false),
                ],
              ),
        
              const SizedBox(height: 16),
        
              /// 🔹 ADDITIONAL SHOOTER CARD
              if (loding)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
        
                      /// 🔹 TOP ROW (CHECKBOX + TEXT + QTY)
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
        
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Videographer",
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "\$385.00",
                                  style: TextStyle(
                                    color: Color(0xFFE7C38A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
        
                          /// ➕➖ Quantity
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7C38A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  },
                                  child: const Icon(Icons.remove, size: 18),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    quantity.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() => quantity++);
                                  },
                                  child: const Icon(Icons.add, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
        
                      const SizedBox(height: 16),
        
        
                    ],
                  ),
                ),
        
               SizedBox(height: 20),
              TextField(
                controller: searchController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    searchLocation(value);
                  }
                },
                decoration: InputDecoration(
                  labelText:"Select Location*",
                  suffixIcon:
                   Icon(Icons.location_on_outlined, color: ColorCode.white),
        
        
                  floatingLabelBehavior: FloatingLabelBehavior.always,
        
                  labelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                  ),
        
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
        
                  /// ⭐ 0.5px BORDER + OPACITY COLOR
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                       // 🔥 exact 0.5px
                    ),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                          // focus border thicker
                    ),
                  ),
        
                  floatingLabelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70,
        
                  ),
                ),
              ),
        
              SizedBox(height: 20),
        
              /// 🗺️ MAP WITH FIXED HEIGHT
              SizedBox(
                height: 280,
                child:ClipRRect(
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
        
              SizedBox(height: 20),
              TextField(
        maxLines: 5,
        
                decoration: InputDecoration(
                  labelText:"Additional Details",
        
                  floatingLabelBehavior: FloatingLabelBehavior.always,
        
                  labelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                  ),
        
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
        
                  /// ⭐ 0.5px BORDER + OPACITY COLOR
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                       // 🔥 exact 0.5px
                    ),
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                          // focus border thicker
                    ),
                  ),
        
                  floatingLabelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70,
        
                  ),
                ),
              ),
              SizedBox(height: 20),

              TextField(


                decoration: InputDecoration(
                  labelText:"Supporting Links",

                  floatingLabelBehavior: FloatingLabelBehavior.always,

                  labelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70, // #1D1D1B 60% opacity
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  /// ⭐ 0.5px BORDER + OPACITY COLOR
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                       // 🔥 exact 0.5px
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorCode.kWhiteOpacity70, // #1D1D1B99 (60% opacity)
                      width: 0.5,                          // focus border thicker
                    ),
                  ),

                  floatingLabelStyle: const TextStyle(
                    color: ColorCode.kWhiteOpacity70,

                  ),
                ),
              ),
            ],
          ),
            SizedBox(height: 20),
        
        
          ],
        ),
        
        ),
      )
      ) ,

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
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                onPressed: () {
                  debugPrint("Continue clicked");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrewSizeMatchingScreen(

                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorCode.kButtonColor,
                  /* backgroundColor: selectedIndex == -1
                      ? ColorCode.kGoldGradientLight // disabled
                      : ColorCode.kButtonColor, // enabled
                  foregroundColor: selectedIndex == -1
                      ? Colors.grey.shade400
                      : Colors.black,*/
                  padding:  EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    color: ColorCode.kHeadingColor,
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
  Widget _radioOption(String title, bool value) {
    return InkWell(
      onTap: () {
        setState(() {
          loding = value;
        });
      },
      child: Row(
        children: [
          Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54),
              color: loding == value
                  ?  Color(0xFFE7C38A)
                  : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

}
