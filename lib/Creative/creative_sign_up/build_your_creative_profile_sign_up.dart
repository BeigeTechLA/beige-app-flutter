import 'dart:io';
import 'dart:ui' as ui;

import 'package:beige/Creative/creative_sign_up/professional_details_sing_up.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import 'package:path_provider/path_provider.dart';
import '../../ChooseYourRole/choose_your_role_screen.dart';
import '../../auth/login_screen.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';

class BuildYourCreativeProfileSignUp extends StatefulWidget {
  const BuildYourCreativeProfileSignUp({super.key});

  @override
  State<BuildYourCreativeProfileSignUp> createState() =>
      _BuildYourCreativeProfileSignUpState();
}

class _BuildYourCreativeProfileSignUpState extends State<BuildYourCreativeProfileSignUp> {


  String? selectedDistance;

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool savePassword = false;
  bool isLoggingIn = false;

  GoogleMapController? mapController;
  LatLng? currentLatLng;

  String selectedAddress = "Search or select location";

  bool showMap = false;
  bool isLoading = false;


  bool isCropping = false;
  File? tempImage;
  double cropScale = 1.0;

  double scale = 1.0;
  double startScale = 1.0;

  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;


  bool get isFormValid {
    return
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        savePassword; // ✅ checkbox must be checked
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController  = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController phoneController     = TextEditingController();


  final List<String> distances = [
    "Upto 10 Miles",
    "10-20 Miles",
    "20-50 Miles",
  ];

  bool loding   = true;
  String? selectedStudio;

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

        final address =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

        setState(() {
          selectedAddress = address;

          /// 🔥 IMPORTANT: TextField ko bhi update karo
          searchController.text = address;
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




  File? _selectedImage;
/*
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,

        /// 🔥 v10 SAFE
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),

        uiSettings: [

          /// ✅ ANDROID (FIGMA-LIKE)
          AndroidUiSettings(
            toolbarTitle: "Crop your Profile",
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,

            hideBottomControls: false, // ✅ Save / Done bottom
            lockAspectRatio: true,
            showCropGrid: false,

            activeControlsWidgetColor: ColorCode.kButtonColor,
            statusBarColor: Colors.black,
          ),

          /// ✅ IOS
          IOSUiSettings(
            title: "Crop your Profile",
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        profileImage = File(croppedFile.path);
      });

    } catch (e) {
      debugPrint("❌ Crop error: $e");
    }
  }
*/

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
                            offset = startOffset + details.focalPointDelta;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [

                            /// IMAGE (NOW CLIPPED)
                            ClipRect(
                              child: SizedBox(
                                width: double.infinity,
                                height: 320,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..translate(offset.dx, offset.dy)
                                    ..scale(scale),
                                  child: Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
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

      const double uiSize = 320;
      const double circleRadius = 130;

      final double imgW = image.width.toDouble();
      final double imgH = image.height.toDouble();

      /// UI → image ratio
      final double ratio = imgW / uiSize;

      /// real crop size in pixels
      final double cropPx = (circleRadius * 2) * ratio / scale;

      /// convert UI offset → image offset
      final double dx =
          (imgW / 2) - (circleRadius * ratio) - (offset.dx * ratio);
      final double dy =
          (imgH / 2) - (circleRadius * ratio) - (offset.dy * ratio);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()..isAntiAlias = true;

      /// circular crop
      canvas.clipPath(
        Path()..addOval(Rect.fromLTWH(0, 0, cropPx, cropPx)),
      );

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(dx, dy, cropPx, cropPx),
        Rect.fromLTWH(0, 0, cropPx, cropPx),
        paint,
      );

      final pic = recorder.endRecording();
      final cropped =
      await pic.toImage(cropPx.toInt(), cropPx.toInt());

      final data =
      await cropped.toByteData(format: ui.ImageByteFormat.png);

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(data!.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("❌ Crop failed: $e");
      return null;
    }
  }



  Future<void> _fetchSingup() async {
    // 🔐 Password match check
    if (passwordController.text != confirmPasswordController.text) {
      _showSnack("Password and Confirm Password do not match");
      return;
    }

    // ☑️ Terms check
    if (!savePassword) {
      _showSnack("Please accept Terms & Conditions");
      return;
    }

    // 🖼 Profile image check
    if (profileImage == null) {
      _showSnack("Please upload profile picture");
      return;
    }

    // 📏 Working distance check (IMPORTANT)
    if (selectedDistance == null || selectedDistance!.isEmpty) {
      _showSnack("Please select working distance");
      return;
    }

    setState(() => isLoggingIn = true);

    final payload = {
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(), // "1" bhi jayega
      "location": searchController.text.trim(),
      "working_distance": selectedDistance!, // ✅ never empty now
    };

    /// 🟢 DEBUG
    debugPrint("📤 SIGNUP PAYLOAD:");
    payload.forEach((k, v) => debugPrint("$k : $v"));
    debugPrint("📸 PROFILE IMAGE: ${profileImage!.path}");

    try {
      final response = await ApiService().postMultipart(
        ApiEndpoints.register_step1,
        payload,
        profileImage!,
      );

      debugPrint("📥 API RESPONSE: $response");

      if (response != null && response['error'] == false) {
        final crewMemberId = response['data']?['crew_member_id'];

        if (crewMemberId == null) {
          _showSnack("Crew member id not received");
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfessionalDetailsSingUp(
              crewMemberId: crewMemberId,
            ),
          ),
        );
      } else {
        _showSnack(response?['message'] ?? "Signup failed");
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint("❌ STATUS: ${e.response?.statusCode}");
        debugPrint("❌ ERROR DATA: ${e.response?.data}");
      }
      _showSnack("Signup failed");
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
      backgroundColor: ColorCode.bcakgroundcolor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "1/3",
                style: TextStyle(color: ColorCode.white),
              ),
            ),
          )
        ],
            ),
                SizedBox(height: 8),

                /// ✅ Progress Bar
                Row(
                  children: List.generate(
                    3,
                        (index) =>
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            height: 5,
                            decoration: BoxDecoration(
                              color: index == -1
                                  ? ColorCode.kButtonColor
                                  : ColorCode.kSubtextColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                  ),
                ),

                SizedBox(height: 20),
                 Text(
                  "Build your Creative Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Unbounded",
                    fontWeight: FontWeight.w500,
                    color: ColorCode.white,
                  ),
                ),

                 SizedBox(height: 12),

                /// 📄 SUBTITLE
                 Text(
                  "Create your profile to get discovered by production \n teams.",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorCode.kWhiteOpacity70,
                  ),
                ),
                SizedBox(height: 20),

                _buildField("First Name*", _firstNameFocus, firstNameController),

                SizedBox(height: 20),

                _buildField("Last Name*", _lastNameFocus, lastNameController),

                SizedBox(height: 20),

                _buildField("Email Address*", _emailFocus, emailController),

                SizedBox(height: 20),

                TextField(
                  controller: searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      searchLocation(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Select Location*",
                    suffixIcon: InkWell(
                      onTap: () {
                        if (searchController.text.isNotEmpty) {
                          searchLocation(searchController.text);
                        }
                      },
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: ColorCode.white,
                      ),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: const TextStyle(color: ColorCode.kWhiteOpacity70),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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

                _workingDistanceDropdown(),
                SizedBox(height: 20),

                _buildPasswordField(
                  "Create Password",
                  showPassword,
                      () => setState(() => showPassword = !showPassword),
                  passwordController,
                  _passwordFocus,
                ),

                SizedBox(height: 20),

                _buildPasswordField(
                  "Confirm Password",
                  showConfirmPassword,
                      () => setState(() => showConfirmPassword = !showConfirmPassword),
                  confirmPasswordController,
                  _confirmPasswordFocus,
                ),

                SizedBox(height: 20),

                _profilePictureCard(),

                 SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => savePassword = !savePassword),
                      child: Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: savePassword ? ColorCode.kButtonColor : Colors.black,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: ColorCode.kWhiteOpacity70),
                        ),
                        child: savePassword
                            ? const Icon(Icons.check, size: 14, color: ColorCode.black)
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

                 SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoggingIn ? null : _fetchSingup,
                    // onPressed: isLoggingIn ? null : _fetchSingup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid
                          ? ColorCode.kButtonColor   // ✅ Active color
                          : ColorCode.kGold40,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoggingIn
                        ? const CircularProgressIndicator(color: Colors.white)
                        :  Text(
                      "Next",
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

                 SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text("Already have an account? ",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 14,
                        fontFamily: "Outfit",
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
      ),
    );
  }

  Widget _buildField(
      String title,
      FocusNode focusNode,
      TextEditingController controller, {
        Widget? suffixIcon,
        Function(String)? onSubmitted, // ✅ ADD THIS
      }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: ColorCode.kButtonColor,
      style: const TextStyle(color: ColorCode.white),

      onSubmitted: onSubmitted, // ✅ HERE

      decoration: InputDecoration(
        labelText: title,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: focusNode.hasFocus
              ? ColorCode.kButtonColor
              : ColorCode.kWhiteOpacity70,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
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
            color: ColorCode.kButtonColor,
            width: 1,
          ),
        ),
      ),
    );
  }



  Widget _workingDistanceDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDistance,
      dropdownColor: const Color(0xFF1C1C1C),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: "Working Distance*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        labelStyle: TextStyle(
          color: selectedDistance != null
              ? ColorCode.kButtonColor   // active
              : ColorCode.kWhiteOpacity70,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
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
            color: ColorCode.kButtonColor,
            width: 1,
          ),
        ),
      ),

    /*  hint: const Text(
        "Select distance",
        style: TextStyle(color: Colors.white54),
      ),*/

      items: distances
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
          .toList(),

      onChanged: (value) {
        setState(() {
          selectedDistance = value;
        });
      },
    );
  }


  Widget _buildPasswordField(
      String title,
      bool isVisible,
      VoidCallback onToggle,
      TextEditingController controller,
      FocusNode focusNode,
      ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: !isVisible,
      cursorColor: ColorCode.kButtonColor,

      style: const TextStyle(
        color: ColorCode.white,
      ),

      decoration: InputDecoration(
        labelText: "$title*",
        floatingLabelBehavior: FloatingLabelBehavior.always,

        /// 🔥 LABEL COLOR CHANGE
        labelStyle: TextStyle(
          color: focusNode.hasFocus
              ? ColorCode.kButtonColor
              : ColorCode.kWhiteOpacity70,
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
            color: focusNode.hasFocus
                ? ColorCode.kButtonColor
                : ColorCode.kWhiteOpacity70,
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

        /// 🔥 ACTIVE BORDER
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorCode.kButtonColor,
            width: 1,
          ),
        ),
      ),

      onTap: () => setState(() {}),
      onChanged: (_) => setState(() {}),
    );
  }


  Widget _profilePictureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorCode.kGold40
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
                : const AssetImage("assets/images/profile_placeholder.png")
            as ImageProvider,
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
