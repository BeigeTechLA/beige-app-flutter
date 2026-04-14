import 'dart:io';
import 'dart:ui' as ui;

import 'package:beige/MyProfile/my_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../Customtextfiled/CustomInputField.dart';
import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../service/google_config.dart';
import '../utility/ColorCode.dart';
import 'Change_Password_screen.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  bool isLoading =true;

  File? _profileImage;
  List<dynamic> myprofile = [];

  String? selectedStudio;
  bool showMap = false;

  GoogleMapController? mapController;
  LatLng? currentLatLng;

  String selectedAddress = "Search or select location";
  bool isSaving = false;

  final ImagePicker _picker = ImagePicker();

  String? profileImageUrl;
  double cropScale = 1.0;

  double scale = 1.0;
  double startScale = 1.0;

  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;

  Map<String, dynamic>? myProfile;
  final FocusNode locationFocusNode = FocusNode();
  Set<Marker> markers = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchMyProfile();
    // _getCurrentLocation();
  }


  void _updateMarker(LatLng latLng) {
    setState(() {
      currentLatLng = latLng;

      markers = {
        Marker(
          markerId: const MarkerId("selected_location"),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        )
      };
    });
  }

/*
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
*/

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        final latLng = LatLng(loc.latitude, loc.longitude);

        /// 🔴 ADD THIS
        _updateMarker(latLng);

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

    if (currentLatLng != null) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(position.latitude, position.longitude);

    _updateMarker(latLng);
  }


  Future<void> _fetchMyProfile() async {
    try {
      final response = await ApiService().fetchData(ApiEndpoints.my_profile);

      if (response != null && response['error'] == false) {
        final user = response['data']['user'];

        setState(() {
          myProfile = user;

          nameController.text = user['name'] ?? '';
          emailController.text = user['email'] ?? '';
          locationController.text = user['location'] ?? '';

          profileImageUrl = user['user_profile_image_url'];

          /// ✅ SET MAP LOCATION FROM PROFILE
          if (user['latitude'] != null && user['longitude'] != null) {
            final latLng = LatLng(
              double.parse(user['latitude'].toString()),
              double.parse(user['longitude'].toString()),
            );

            _updateMarker(latLng);

          }

          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
      isLoading = false;
    }
  }

  Future<void> _edit_profile() async {
    debugPrint("🟢 EDIT PROFILE API CALL STARTED");

    try {
      setState(() => isLoading = true);

      final requestBody = {
        "name": nameController.text.trim(),
        "location": locationController.text.trim(),
      };

      debugPrint("📤 REQUEST BODY: $requestBody");

      final response = await ApiService().putData(
        ApiEndpoints.my_profile,
        requestBody,
      );

      debugPrint("📥 API RESPONSE: $response");

      if (response != null && response['error'] == false) {
        debugPrint("✅ PROFILE UPDATED SUCCESSFULLY");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile updated successfully")),
        );

        // ✅ BACK TO PREVIOUS SCREEN
        Navigator.pop(context, true);
      } else {
        debugPrint("❌ PROFILE UPDATE FAILED");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Profile update failed")),
        );
      }
    } catch (e) {
      debugPrint("🚨 API ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚨 Something went wrong")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      debugPrint("🟢 IMAGE PICKED: ${pickedFile.path}");

      /// 🔥 OPEN CROP SHEET
      openCustomCropSheet(file);
    }
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                                      width: 340,
                                      height: 340,
                                      fit: BoxFit.fill,
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
                        SvgPicture.asset(
                          "assets/svg/crop_image.svg", // 👈 your image

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


                        /// 🔹 LEFT IMAGE ICON
                        SvgPicture.asset(
                          "assets/svg/crop_image.svg", // 👈 your image

                          height: 26,
                          width: 26,
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
                  /*    onPressed: () async {
                        final cropped = await _cropImage(
                          imageFile,
                          scale,
                          offset,
                        );

                        if (cropped != null) {
                          setState(() {
                            _profileImage = cropped; // 🔥 IMPORTANT
                          });

                          debugPrint("✅ CROPPED IMAGE PATH: ${cropped.path}");

                          /// 🔥 UPLOAD AFTER CROP
                          await _uploadImage();
                        }

                        Navigator.pop(context);
                      },*/
                      onPressed: () async {
                        setSheetState(() {
                          isSaving = true;
                        });

                        final cropped = await _cropImage(
                          imageFile,
                          scale,
                          offset,
                        );

                        if (cropped != null) {
                          setState(() {
                            _profileImage = cropped;
                          });

                          debugPrint("✅ CROPPED IMAGE PATH: ${cropped.path}");

                          await _uploadImage();
                        }

                        setSheetState(() {
                          isSaving = false;
                        });

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


  Future<void> _uploadImage() async {
    if (_profileImage == null) return;

    try {
      setState(() {
        isUploadingImage = true; // 🔥 start loader
      });

      final fileName = _profileImage!.path.split('/').last;

      FormData formData = FormData.fromMap({
        "profile_photo": await MultipartFile.fromFile(
          _profileImage!.path,
          filename: fileName,
        ),
      });

      final dio = Dio();
      final headers = await ApiService().createAuthorizationHeader();

      final response = await dio.post(
        "${ApiService().baseUrl}auth/profile-photo",
        data: formData,
        options: Options(
          headers: {
            ...headers,
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        await _fetchMyProfile(); // 🔥 refresh profile
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    } finally {
      setState(() {
        isUploadingImage = false; // 🔥 stop loader
      });
    }
  }
  ImageProvider? getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return NetworkImage(
        ApiService().getImageURL(profileImageUrl!),
      );
    }
    else {
      return null; // SVG ke liye null
    }
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [

                    Container(
                      height: 248,
                      width: double.infinity,
                      color: Colors.transparent,
                    ),


                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                        child: Image.asset(
                          "assets/images/profile.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    /// 🔹 BACK BUTTON
                    Positioned(
                      top: 90,
                      left: 16,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        child: SvgPicture.asset(
                          "assets/svg/back.svg",
                          color: ColorCode.black,
                          height: 24,
                        ),
                      ),
                    ),

                    /// 🔹 TITLE
                    const Positioned(
                      top: 90,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: ColorCode.kHeadingColor,
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    /// 🔹 PROFILE IMAGE
                    Positioned(
                      bottom: 0, //
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: getProfileImage(),

                                /// ✅ SVG fallback
                                child: getProfileImage() == null
                                    ? SvgPicture.asset(
                                  "assets/svg/persone.svg",
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                            ),


                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                debugPrint("EDIT CLICKED");
                                _pickImage();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),


                const SizedBox(height: 10),

                /// 🔹 USER INFO
                Text(

                  myProfile?['name'] ?? '',
                  style: TextStyle(
                    fontFamily: "Outfit",
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${myProfile?['email'] ?? ''}",
                  style: TextStyle(
                    color: ColorCode.kWhiteOpacity60,
                    fontFamily: "Outfit",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),


              ],
            ),




            /// 🔹 USER INFO

            const SizedBox(height: 14),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorCode.kDividerStart,
                      ColorCode.kDividerCenter,
                      ColorCode.kDividerEnd,
                    ],
                    stops: [0.0, 0.49, 1.0],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding:  EdgeInsets.all(20.0),
              child: Column(
                children: [

                 /* TextField(
                      controller: nameController,
                      cursorColor: ColorCode.white,

                  style: const TextStyle(
                    color: ColorCode.white, // typed text color
                  ),

                  decoration: InputDecoration(
                    labelText: "Name*",
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

              ),
                  */

                  CustomInputField(
                    title: "Name*",
                    controller: nameController,
                  ),
                  SizedBox(height: 20,),
               /*   TextField(
                    controller: emailController,

                    cursorColor: ColorCode.white,
                    style: const TextStyle(
                      color: ColorCode.white,
                    ),
                    decoration: InputDecoration(
                      labelText: "Email ID*",
                      floatingLabelBehavior: FloatingLabelBehavior.always,

                    *//*  suffixIcon: GestureDetector(
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangePasswordScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.edit,
                          color: ColorCode.kWhiteOpacity70,
                          size: 20,
                        ),
                      ),*//*

                      labelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70,
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
                          color: ColorCode.kWhiteOpacity70,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),*/
                  CustomInputField(
                    title: "Email ID*",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  SizedBox(height: 20,),
                  // TextField(
                  //   controller: locationController,
                  //   onSubmitted: (value) {
                  //     if (value.isNotEmpty) {
                  //       searchLocation(value);
                  //     }
                  //   },
                  //   decoration: InputDecoration(
                  //     labelText: "Location*",
                  //     suffixIcon: InkWell(
                  //       onTap: () {
                  //         if (locationController.text.isNotEmpty) {
                  //           searchLocation(locationController.text);
                  //         }
                  //       },
                  //       child: const Icon(
                  //         Icons.location_on_outlined,
                  //         color: ColorCode.white,
                  //       ),
                  //     ),
                  //     floatingLabelBehavior: FloatingLabelBehavior.always,
                  //     labelStyle: const TextStyle(color: ColorCode.kWhiteOpacity70),
                  //     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(
                  //         color: ColorCode.kWhiteOpacity70,
                  //         width: 0.5,
                  //       ),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(
                  //         color: ColorCode.kWhiteOpacity70,
                  //         width: 0.5,
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                      focusNode: locationFocusNode,
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
                        hintText: "location*",
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

                      /// LOCATION SELECT
                      getPlaceDetailWithLatLng: (prediction) async {

                        final latLng = LatLng(
                          double.parse(prediction.lat!),
                          double.parse(prediction.lng!),
                        );

                        _updateMarker(latLng);

                        setState(() {
                          selectedAddress = prediction.description ?? "";
                        });

                        locationController.text = selectedAddress;

                        locationController.selection = TextSelection.fromPosition(
                          TextPosition(offset: locationController.text.length),
                        );

                        locationFocusNode.unfocus();

                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(latLng, 14),
                        );
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

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      child: currentLatLng == null
                          ? const Center(
                        child: CircularProgressIndicator(),
                      )
                          : GoogleMap(

                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 14,
                        ),

                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        compassEnabled: true,

                        markers: markers, // ✅ USE STATE MARKERS

                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                          ),
                        },

                        onMapCreated: (controller) {
                          mapController = controller;
                          controller.setMapStyle(_darkMapStyle);

                          /// 🔴 ADD THIS
                          if (currentLatLng != null) {
                            mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(currentLatLng!, 14),
                            );
                          }
                        },

                        /// MAP TAP
                        onTap: (latLng) async {

                          _updateMarker(latLng);

                          await getAddressFromLatLng(latLng);

                          locationController.text = selectedAddress;

                          mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(latLng, 14),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                 /* TextField(
                    readOnly: true,
                    obscureText: true,
                    obscuringCharacter: ".",
                    cursorColor: ColorCode.white,

                    decoration: InputDecoration(
                      labelText: "Change Password*",
                      floatingLabelBehavior: FloatingLabelBehavior.always,

                      hintText: "********",
                      hintStyle: const TextStyle(
                      color: ColorCode.white,
                      fontFamily: "Outfit",
                      fontSize: 14,
                        letterSpacing: 4,

                      ),

                      labelStyle: const TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                      ),

                      suffixIcon: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangePasswordScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.edit,
                          color: ColorCode.kWhiteOpacity70,
                          size: 20,
                        ),
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
                          color: ColorCode.kWhiteOpacity70,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),*/

                  CustomInputField(
                    title: "Change Password*",
                    controller: TextEditingController(text: "********"),
                    readOnly: true,
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangePasswordScreen(
                              email: emailController.text,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 15,
                        width: 15,
                        child: SvgPicture.asset(
                          "assets/svg/my_profile/edit.svg",
                          fit: BoxFit.none,

                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            )



          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(22),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: isLoading ? null : _edit_profile,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorCode.kButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            Text(
              "Update Profile",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontWeight: FontWeight.w500,
                color: ColorCode.kHeadingColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
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
    const radius = 120.0;

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