import 'package:beige/ChooseYourRole/choose_your_role_screen.dart';
import 'package:beige/OnbodingScreen/onboding_screen.dart';
import 'package:beige/auth/login_screen.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/google_config.dart';
import '../service/shared_service.dart';

class SignUpScreen extends StatefulWidget {
  final int? role;
  const SignUpScreen({super.key,  this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool savePassword = false;
  bool isLoggingIn = false;
  double? selectedLat;
  double? selectedLng;

  GoogleMapController? mapController;
  LatLng? currentLatLng;
  final FocusNode locationFocusNode = FocusNode();
  bool showMap = false;
  String selectedAddress = "Search or select location";
  bool isMapOpen = false;          // 👈 map show / hide
  List<Location> searchResults = [];
  FocusNode locationFocus = FocusNode();
  bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
  }
  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        savePassword; // ✅ checkbox must be checked
  }
  @override
  void initState() {
    super.initState();
    debugPrint("Signup Role: ${widget.role}");
    _getCurrentLocation();

    locationFocus.addListener(() {
      if (locationFocus.hasFocus) {
        setState(() {
          showMap = true; //
        });
      }
    });
  }




  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      setState(() {
        searchResults = locations; // 👈 dropdown data
      });
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

        setState(() {
          selectedAddress = address;

          /// 🔥 IMPORTANT: TextField ko bhi update karo
          locationController.text = address;
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

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    setState(() {
      currentLatLng = latLng;
      selectedLat = latLng.latitude;   // ✅
      selectedLng = latLng.longitude;  // ✅
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 14),
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[
          if (p.name != null && !_isPlusCode(p.name!)) p.name!,
          if (p.subLocality != null) p.subLocality!,
          if (p.locality != null) p.locality!,
          if (p.administrativeArea != null) p.administrativeArea!,
        ];

        selectedAddress = parts.join(', ');
        locationController.text = selectedAddress;
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _fetchSingup() async {
    final apiService = ApiService();

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        locationController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    /// ✅ EMAIL VALIDATION
    if (!isValidEmail(emailController.text.trim())) {
      _showSnack("Please enter a valid email address");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Password and Confirm Password do not match");
      return;
    }

    if (!savePassword) {
      _showSnack("Please accept Terms & Conditions");
      return;
    }

    setState(() => isLoggingIn = true);

    /// 🟡 PAYLOAD
    final payload = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "user_type": 3,
      "location": locationController.text.trim(),
      "lat": selectedLat,   // ✅
      "lng": selectedLng,

    };

    /// 🟡 PRINT API & PAYLOAD
 /*   debugPrint("🟡 SIGNUP API URL => ${ApiEndpoints.singup}");
    debugPrint("🟡 SIGNUP PAYLOAD => $payload");*/

    try {
      final response = await apiService.postData(
        ApiEndpoints.singup,
        payload,
      );

      /// 🟢 PRINT FULL RESPONSE
      debugPrint("🟢 SIGNUP RESPONSE => $response");

      if (response != null) {
        debugPrint("🟢 ERROR => ${response['error']}");
        debugPrint("🟢 MESSAGE => ${response['message']}");
        debugPrint("🟢 DATA => ${response['data']}");
      }

      if (response != null && response['error'] == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        _showSnack(response?['message'] ?? "Signup failed");
      }
    } catch (e) {
      debugPrint("❌ SIGNUP EXCEPTION => $e");
      _showSnack(e.toString());
    } finally {
      setState(() => isLoggingIn = false);
    }
  }




  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    locationFocusNode.dispose();

    super.dispose();
  }
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorCode.bcakgroundcolor,
        body: SingleChildScrollView(
          padding:  EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ChooseYourRoleScreen()),
                  );
                },
                child: Image.asset("assets/Icons/Reply.png", height: 24),
              ),


              SizedBox(height: 30),

              const Text(
                "Sign Up Now",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorCode.white,
                ),
              ),

              SizedBox(height: 10),

               Text(
                "Join Beige to book talented photographers\n  and videographers.",
                style: TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

               SizedBox(height: 20),

              _buildField("Name", nameController),
              SizedBox(height: 20),
              _buildField("Email ID", emailController),
              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorCode.kWhiteOpacity70,
                    width: 0.8,
                  ),
                ),
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: locationController,
                  focusNode: locationFocus, // ✅ ADD THIS

                  googleAPIKey: GoogleConfig.placesApiKey,
                  debounceTime: 600,

                  isLatLngRequired: true,


                  textStyle: const TextStyle(
                    color: ColorCode.white,
                    fontFamily: "Outfit",
                    fontSize: 14,
                  ),

                  inputDecoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Search or select location",
                    hintStyle: TextStyle(
                      color: ColorCode.kWhiteOpacity70,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: ColorCode.kWhiteOpacity70,
                      ),
                    ),
                  ),
                  getPlaceDetailWithLatLng: (prediction) async {
                    final latLng = LatLng(
                      double.parse(prediction.lat!),
                      double.parse(prediction.lng!),
                    );

                    locationFocus.unfocus();

                    await _updateLocationFromLatLng(latLng);

                    setState(() {
                      currentLatLng = latLng;
                      selectedLat = latLng.latitude;   // ✅ SAVE LAT
                      selectedLng = latLng.longitude;  // ✅ SAVE LNG
                      selectedAddress = prediction.description ?? "";
                      showMap = true;
                    });

                    locationController.text = selectedAddress;
                  },


                  itemClick: (prediction) {
                    locationController.text = prediction.description ?? "";
                    locationController.selection = TextSelection.fromPosition(
                      TextPosition(offset: locationController.text.length),
                    );
                  },

                  isCrossBtnShown: true,
                ),
              ),


              SizedBox(height: 20),

              /// 🗺️ MAP WITH FIXED HEIGHT
              if (showMap)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 280,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: currentLatLng == null
                          ? const Center(child: CircularProgressIndicator())
                          :GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 14,
                        ),

                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        compassEnabled: false,

                        // 🔥 IMPORTANT FIX (touch enable)
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                          ),
                        },

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
                          await _updateLocationFromLatLng(latLng);
                        },
                      ),

                    ),
                  ),
                ),


              SizedBox(height: 20),
              _buildPasswordField(
                "Create Password",
                showPassword,
                    () => setState(() => showPassword = !showPassword),
                passwordController,
              ),

              SizedBox(height: 20),

              _buildPasswordField(
                "Confirm Password",
                showConfirmPassword,
                    () => setState(() => showConfirmPassword = !showConfirmPassword),
                confirmPasswordController,
              ),

              SizedBox(height: 20),

              /// Terms checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        savePassword = !savePassword;
                      });
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: savePassword
                            ? ColorCode.black
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: ColorCode.kWhiteOpacity70,
                        ),
                      ),
                      child: savePassword
                          ? const Icon(Icons.check,
                          size: 14, color: ColorCode.kButtonColor)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          height: 1.4, // line spacing perfect
                        ),
                        children: const [
                          TextSpan(text: "I agree to the ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: ColorCode.kWhiteOpacity70,
                              fontSize: 13,
                              fontFamily: "Outfit", // ⭐ Added Outfit font
                            ),
                          ),

                          TextSpan(
                            text: "Terms & Condition & Privacy Policy",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorCode.white,
                              fontSize: 13,
                              fontFamily: "Outfit", // ⭐ Added Outfit font
                            ),
                          ),


                          TextSpan(text: "\nset out of this site",
                            style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: ColorCode.kWhiteOpacity70,
                            fontSize: 13,
                            fontFamily: "Outfit", // ⭐ Added Outfit font
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),


                ],
              ),

              const SizedBox(height: 40),

              /// Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoggingIn ? null : _fetchSingup,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid
                          ? ColorCode.kCreamSoft   // ✅ Active color
                          : ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      :  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Unbounded",
                      color: isFormValid
                          ? ColorCode.kHeadingColor   // ✅ Active color
                          : ColorCode.kSubtextOpacity,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                    style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ColorCode.kWhiteOpacity70,
                    fontSize: 14,
                    fontFamily: "Outfit", // ⭐ Added Outfit font
                  ),),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>  LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
        cursorColor: ColorCode.white,

        style: const TextStyle(
          color: ColorCode.white, // typed text color
        ),

        decoration: InputDecoration(
          labelText: "$title*",
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
          ),)
        ,);
  }

  Widget _buildPasswordField(
      String title,
      bool isVisible,
      VoidCallback onToggle,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      cursorColor: ColorCode.kWhiteOpacity70,
      style: const TextStyle(
        color: ColorCode.kWhiteOpacity70,
      ),
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// 👁️ EYE ICON
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: ColorCode.kWhiteOpacity70,
            size: 20,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),

        floatingLabelStyle: const TextStyle(
          color: ColorCode.kWhiteOpacity70,
        ),
      ),
    );
  }

}
