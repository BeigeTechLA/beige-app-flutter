import 'dart:io';
import 'dart:ui' as ui;

import 'package:beige/OnbodingScreen/onboding_screen.dart';
import 'package:beige/auth/new_login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../Customtextfiled/CustomInputField.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/google_config.dart';
import '../service/shared_service.dart';
import '../utility/ColorCode.dart';
import '../widgets/TopMessage.dart';
import 'login_screen.dart';


class NewSingUpScreen extends StatefulWidget {
  const NewSingUpScreen({super.key});

  @override
  State<NewSingUpScreen> createState() => _NewSingUpScreenState();
}

class _NewSingUpScreenState extends State<NewSingUpScreen> {

  File? profileImage;
  final ImagePicker _picker = ImagePicker();
  final FocusNode _locationFocus = FocusNode();
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



  bool isLoading = false;


  bool isCropping = false;
  File? tempImage;
  double cropScale = 1.0;

  double scale = 1.0;
  double startScale = 1.0;

  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    nameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    // locationController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));

    _getCurrentLocation();
 /*   _getCurrentLocation();
    nameController.addListener(() {
      setState(() {});
    });

    emailController.addListener(() {
      setState(() {});
    });*/
    locationFocus.addListener(() {
      if (locationFocus.hasFocus) {
        setState(() {
          showMap = true; //
        });
      }
    });
  }


  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    openCustomCropSheet(File(picked.path)); // ✅ IMPORTANT
  }


  void openCustomCropSheet(File imageFile) {
    Offset offset = Offset.zero;
    double scale = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Crop your Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      InkWell(
                        onTap: () => Navigator.pop(context), // ❌ close bottom sheet
                        borderRadius: BorderRadius.circular(20),
                        child:  Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: 20),

                  Divider(color: ColorCode.kDividerWhite12,),

                  /// 🔥 CIRCULAR PREVIEW AREA
                  Expanded(
                    child: Center(
                      child:GestureDetector(
                        onScaleStart: (details) {
                          startScale = scale;
                          startOffset = offset;
                        },
                        onScaleUpdate: (details) {
                          setSheetState(() {
                            scale = (startScale * details.scale).clamp(1.0, 4.0);
                            // offset = startOffset + details.focalPointDelta;
                            offset += details.focalPointDelta;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [

                            /// IMAGE (NOW CLIPPED)
                            ClipRect(
                              child: SizedBox(
                                width: 320,
                                height: 320,
                                child: ClipRect(
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..translate(offset.dx, offset.dy)
                                      ..scale(scale),
                                    child: Image.file(
                                      imageFile,
                                      width: 320,
                                      height: 320,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// CIRCLE OVERLAY
                            IgnorePointer(
                              child: CustomPaint(
                                size: const Size(320, 320),
                                painter: CircleHolePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),


                    ),
                  ),






                  const SizedBox(height: 16),

                  /// 🔥 ZOOM SLIDER
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        /// 🔹 LEFT IMAGE ICON
                        Image.asset(
                          "assets/images/Image.png", // 👈 your image

                          height: 20,
                          width: 20,
                          /*  color: Colors.white.withOpacity(0.7), */// optional
                        ),

                        const SizedBox(width: 10),

                        /// 🔹 SLIDER
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: ColorCode.kButtonColor,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: ColorCode.kButtonColor,
                            ),
                            child: Slider(
                              min: 1,
                              max: 5,
                              value: scale,
                              onChanged: (v) {
                                setSheetState(() => scale = v);
                              },
                            ),
                          ),

                        ),

                        const SizedBox(width: 10),

                        /// 🔹 RIGHT IMAGE ICON
                        /// 🔹 LEFT IMAGE ICON
                        Image.asset(
                          "assets/images/Image.png", // 👈 your image

                          height: 24,
                          width: 24,
                          /*  color: Colors.white.withOpacity(0.7), */// optional
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 10),

                  /// 🔥 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.kButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final cropped = await _cropImage(
                          imageFile,
                          scale,
                          offset,
                        );

                        if (cropped != null) {
                          setState(() {
                            profileImage = cropped;
                          });
                        }

                        Navigator.pop(context);
                      },
                      child:  Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<File?> _cropImage(
      File imageFile,
      double scale,
      Offset offset,
      ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      // UI size (crop widget size)
      const double uiSize = 360;
      const double cropUI = 260; // jitna UI me crop box hai

      final imgW = image.width.toDouble();
      final imgH = image.height.toDouble();

      // Ratio (safe for portrait + landscape)
      final ratioX = imgW / uiSize;
      final ratioY = imgH / uiSize;
      final ratio = ratioX < ratioY ? ratioX : ratioY;

      // Real image crop size
      final cropSize = (cropUI * ratio) / scale;

      // Center based crop
      double dx = (imgW / 2) - (cropSize / 2) - (offset.dx * ratio);
      double dy = (imgH / 2) - (cropSize / 2) - (offset.dy * ratio);

      // Prevent overflow
      dx = dx.clamp(0.0, imgW - cropSize);
      dy = dy.clamp(0.0, imgH - cropSize);

      // Canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      // ✅ NO CLIP — PURE RECTANGLE IMAGE
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(dx, dy, cropSize, cropSize),
        Rect.fromLTWH(0, 0, cropSize, cropSize),
        paint,
      );

      final pic = recorder.endRecording();
      final cropped =
      await pic.toImage(cropSize.toInt(), cropSize.toInt());

      final data =
      await cropped.toByteData(format: ui.ImageByteFormat.png);

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(data!.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("❌ Crop failed: $e");
      return null;
    }
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

        // 🔥 BUILD CLEAN ADDRESS (NO PLUS CODE)
        final parts = <String>[
          if (p.name != null && !_isPlusCode(p.name!)) p.name!,
          if (p.subLocality != null) p.subLocality!,
          if (p.locality != null) p.locality!,
          if (p.administrativeArea != null) p.administrativeArea!,
        ];

        selectedAddress = parts.join(', ');

        locationController.text = selectedAddress;
        locationController.selection = TextSelection.fromPosition(
          TextPosition(offset: locationController.text.length),
        );
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

  Future<void> _fetchSignup() async {

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final location = locationController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    /// 🔴 NAME
    if (name.isEmpty) {
      TopMessage.show(context, "Please enter your name");
      return;
    }

    /// 🔴 EMAIL
    if (email.isEmpty) {
      TopMessage.show(context, "Please enter your email address");
      return;
    }

    if (!isValidEmail(email)) {
      TopMessage.show(context, "Please enter a valid email address");
      return;
    }

    /// 🔴 LOCATION
    if (location.isEmpty) {
      TopMessage.show(context, "Please select your location");
      return;
    }

    /// 🔴 PROFILE IMAGE
    if (profileImage == null) {
      TopMessage.show(context, "Please upload profile picture");
      return;
    }

    /// 🔴 PASSWORD
    if (password.isEmpty) {
      TopMessage.show(context, "Please enter password");
      return;
    }

    if (password.length < 6) {
      TopMessage.show(context, "Password must be at least 6 characters");
      return;
    }

    /// 🔴 CONFIRM PASSWORD
    if (confirmPassword.isEmpty) {
      TopMessage.show(context, "Please confirm your password");
      return;
    }

    if (password != confirmPassword) {
      TopMessage.show(context, "Passwords do not match");
      return;
    }

    /// 🔴 TERMS CHECKBOX
    if (!savePassword) {
      TopMessage.show(context, "Please accept Terms & Conditions");
      return;
    }

    setState(() => isLoggingIn = true);

    try {

      final response = await ApiService().postMultipart(
        ApiEndpoints.singup,
        {
          "name": name,
          "email": email,
          "user_type": "3",
          "password": password,
          "location": location,
          "lat": selectedLat.toString(),
          "lng": selectedLng.toString(),
        },
        profileImage,
      );

      if (response == null) {
        TopMessage.show(context, "No response from server");
        return;
      }

      if (response['error'] == false &&
          (response['code'] == 200 || response['code'] == 201)) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NewLoginScreen()),
        );

      } else {
        TopMessage.show(context, response['message'] ?? "Signup failed");
      }

    } catch (e) {
      TopMessage.show(context, "Server error");
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

    return Scaffold(
      // backgroundColor: ColorCode.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [

                /// 🔝 TOP IMAGE + TITLE SECTION
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Stack(
                    children: [

                      /// 🖼️ BACKGROUND IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/Rectangle_574057023.png",
                          fit: BoxFit.fill,
                        ),
                      ),


                      /// 🔙 BACK BUTTON
                      Positioned(
                        top: 50, // 🔥 yaha value adjust kar sakte ho (30–50)
                        left: 16,
                        child:InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            "assets/svg/back.svg",
                            height: 24,
                          ),
                        )
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [

                            Text(
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
                              "Join Beige to book talented photographers\nand videographers for your projects.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                color: ColorCode.kWhiteOpacity70,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                /// 📦 FORM CONTAINER (NICHE)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      /// 🧱 MAIN FORM CONTAINER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 36, 20, 20), // 👈 top extra
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: ColorCode.bcakgroundcolor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [

                            const SizedBox(height: 22),

                        /*    _buildField("Name", nameController),
                            const SizedBox(height: 16),
                            _buildField("Email ID", emailController),
                            const SizedBox(height: 16),*/

                            CustomInputField(
                              title: "Name*",
                              controller: nameController,
                              keyboardType: TextInputType.name,
                            ),

                            const SizedBox(height: 16),

                            CustomInputField(
                              title: "Email ID*",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              // autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// LABEL


                                /// FIELD
                                GooglePlaceAutoCompleteTextField(
                                  textEditingController: locationController,
                                  focusNode: locationFocus,
                                  googleAPIKey: GoogleConfig.placesApiKey,
                                  debounceTime: 600,
                                  isLatLngRequired: true,

                                  textStyle: const TextStyle(
                                    color: ColorCode.white,
                                    fontFamily: "Outfit",
                                    fontSize: 14,
                                  ),

                                  inputDecoration: InputDecoration(
                                    hintText: "Location*",
                                    hintStyle: const TextStyle(
                                      color: ColorCode.kWhiteOpacity70,
                                    ),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    border: InputBorder.none,

                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),

                                    /// 📍 LOCATION SVG
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: SvgPicture.asset(
                                        "assets/svg/LocationPin.svg",
                                        width: 10,
                                        height: 10,
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
                                      selectedLat = latLng.latitude;
                                      selectedLng = latLng.longitude;
                                      selectedAddress = prediction.description ?? "";
                                      showMap = true;
                                    });

                                    locationController.text = selectedAddress;
                                  },

                                  itemClick: (prediction) {
                                    locationController.text = prediction.description ?? "";
                                  },

                                  isCrossBtnShown: true,
                                ),

                              ],
                            ),


                            SizedBox(height:16),

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

                            const SizedBox(height: 16),

                       /*     _buildPasswordField(
                              "Create Password",
                              showPassword,
                                  () => setState(() => showPassword = !showPassword),
                              passwordController,
                            ),
                            const SizedBox(height: 16),

                            _buildPasswordField(
                              "Confirm Password",
                              showConfirmPassword,
                                  () => setState(() => showConfirmPassword = !showConfirmPassword),
                              confirmPasswordController,
                            ),*/


                            CustomInputField(
                              title: "Create Password*",
                              controller: passwordController,
                              isPassword: true,
                              isVisible: showPassword,
                              onToggle: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;   // ✅ correct variable
                                  });
                                },
                                icon: SvgPicture.asset(
                                  showPassword
                                      ? "assets/svg/eyes1.svg"
                                      : "assets/svg/eyes2.svg",
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            CustomInputField(
                              title: "Confirm Password*",
                              controller: confirmPasswordController,
                              isPassword: true,
                              isVisible: showConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  showConfirmPassword = !showConfirmPassword;
                                });
                              },
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showConfirmPassword = !showConfirmPassword;  // ✅ correct
                                  });
                                },
                                icon: SvgPicture.asset(
                                  showConfirmPassword
                                      ? "assets/svg/eyes1.svg"
                                      : "assets/svg/eyes2.svg",
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            _profilePictureCard(),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // 🔥 important
                              children: [

                                /// CHECKBOX
                                Padding(
                                  padding: const EdgeInsets.only(top: 3), // align with first text line
                                  child: GestureDetector(
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
                                            ? ColorCode.kButtonColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: ColorCode.kWhiteOpacity70,
                                        ),
                                      ),
                                      child: savePassword
                                          ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: ColorCode.black,
                                      )
                                          : null,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// TEXT
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: "I agree to the ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: ColorCode.kWhiteOpacity70,
                                            fontSize: 13,
                                            fontFamily: "Outfit",
                                          ),
                                        ),
                                        const TextSpan(
                                          text: "Terms & Conditions and Privacy Policy",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: ColorCode.white,
                                            fontSize: 13,
                                            fontFamily: "Outfit",
                                          ),
                                        ),
                                        const TextSpan(
                                          text: " set out of this site",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: ColorCode.kWhiteOpacity70,
                                            fontSize: 13,
                                            fontFamily: "Outfit",
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isFormValid ? _fetchSignup : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? ColorCode.kButtonColor
                                      : ColorCode.kGoldGradientLight,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                child: Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontFamily: "Unbounded",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isFormValid
                                        ? ColorCode.kHeadingColor
                                        : ColorCode.k282828,
                                  ),
                                ),
                              ),
                            )


                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      /*    /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                    Positioned(
                      top: -24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorCode.k282828,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: ColorCode.kWhiteOpacity70,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Tell Us About Yourself & Add Details",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.kWhiteOpacity70,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),*/
                      Positioned(
                        top: -30,
                        left: 20,
                        right: 20,
                        child: ifUserDataCard(),
                      ),

                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity60,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  NewLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (isLoggingIn)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  color: ColorCode.kButtonColor,
                ),
              ),
            ),
        ],

      ),


    );

  }

  Widget _buildField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      cursorColor: ColorCode.white,
      style: const TextStyle(
        color: ColorCode.white,
        fontFamily: "Outfit",
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          fontFamily: "Outfit",
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.0,
          letterSpacing: 0,
          color: ColorCode.kWhiteOpacity70,
        ),

        floatingLabelStyle: const TextStyle(
          fontFamily: "Outfit",
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.0,
          letterSpacing: 0,
          color: ColorCode.kWhiteOpacity70,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
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
      ),
    );
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
      style:const TextStyle(
        fontFamily: "Outfit",
        fontWeight: FontWeight.w400,
        fontSize: 12,

        color: ColorCode.kWhiteOpacity70,
      ),
      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: const TextStyle(
          fontFamily: "Outfit",
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.0,
          letterSpacing: 0,
          color: ColorCode.kWhiteOpacity70,
        ),

        floatingLabelStyle: const TextStyle(
          fontFamily: "Outfit",
          fontWeight: FontWeight.w400,
          fontSize: 15,
          height: 1.0,
          letterSpacing: 0,
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
            color: ColorCode.white,
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


      ),
    );
  }

  Widget _profilePictureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: ColorCode.kBorderLight
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          const Text(
            "Profile Picture",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
              color: ColorCode.white,
            ),
          ),

          const SizedBox(height: 4),

          /// SUB TITLE
          Text(
            "Add photo to build connection and trust",
            style: TextStyle(
                fontSize: 12,
                fontFamily: "Outfit",
                color: ColorCode.kWhiteOpacity70
            ),
          ),

          const SizedBox(height: 16),

          /// IMAGE + BUTTON ROW
          Row(
            children: [
              /// 👤 PROFILE IMAGE
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? SvgPicture.asset(
                  "assets/svg/persone.svg",

                )
                    : null,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                    decoration: BoxDecoration(
                      color: ColorCode.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Icon(
                          profileImage == null
                              ? Icons.camera_alt_outlined   // image nahi hai
                              : Icons.refresh,              // image hai → re-upload
                          size: 18,
                          color: Colors.black,
                        ),
                        // Icon(Icons.camera_alt_outlined, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          profileImage == null
                              ? "Upload Profile Picture"
                              : "ReUpload Profile Picture",
                          style:  TextStyle(
                              fontSize: 12,        // 🔹 thoda bada (image jaisa)
                              fontWeight: FontWeight.w500, // 🔹 bold
                              color: Colors.black,
                              fontFamily: "Outfit"
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),



            ],
          ),

        ],
      ),
    );
  }


  Widget ifUserDataCard() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty && email.isEmpty && profileImage == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: ColorCode.k282828,
          border: Border.all(color: ColorCode.kHeadingColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:  [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorCode.k1D1D1B_Opacity70,
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child:  Center(
                child: SvgPicture.asset(
                  "assets/svg/persone.svg",

                ),
              ),
            ),

            const SizedBox(width: 10),

            Text(
              "Tell Us About Yourself & Add Details",
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 12,
                color: ColorCode.k5D5D5D,
              ),
            ),
          ],
        ),
      );
    }

    // 🔥 Dynamic Card (jab data fill ho)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          /// 🔵 PROFILE IMAGE OR ICON
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profileImage != null
                ? FileImage(profileImage!)
                : null,
            child: profileImage == null
                ? const Icon(
              Icons.person,
              size: 26,
              color: Colors.grey,
            )
                : null,
          ),

          const SizedBox(width: 14),

          /// 📝 NAME + EMAIL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔹 NAME
                Row(
                  children: [
                    const Text(
                      "Name: ",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      name.isEmpty ? "Your Name" : name,
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// 🔹 EMAIL WITH LABEL
                Row(
                  children: [
                    const Text(
                      "Email: ",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        email.isEmpty ? "Your Email" : email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  }
class CircleHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    /// dark overlay
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    /// clear circle
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 130.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()..blendMode = BlendMode.clear,
    );

    canvas.restore();

    /// white border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


