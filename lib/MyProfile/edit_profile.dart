import 'dart:io';

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


  final ImagePicker _picker = ImagePicker();

  String? profileImageUrl;

  Map<String, dynamic>? myProfile;
  final FocusNode locationFocusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchMyProfile();
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

    /// ❌ DON'T override profile location
    if (currentLatLng != null) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
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
            currentLatLng = LatLng(
              double.parse(user['latitude'].toString()),
              double.parse(user['longitude'].toString()),
            );
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
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      debugPrint("🟢 IMAGE PICKED: ${pickedFile.path}");

      // ✅ IMAGE SELECT HOTE HI API CALL
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) {
      debugPrint("❌ NO IMAGE FOUND");
      return;
    }

    try {
      setState(() => isLoading = true);

      final fileName = _profileImage!.path.split('/').last;

      debugPrint("🟡 START UPLOAD");
      debugPrint("📁 FILE: $fileName");
      debugPrint("🌐 API: ${ApiService().baseUrl}auth/profile-photo");

      FormData formData = FormData.fromMap({
        "profile_photo": await MultipartFile.fromFile(
          _profileImage!.path,
          filename: fileName,
        ),
      });

      final dio = Dio();
      final headers = await ApiService().createAuthorizationHeader();

      debugPrint("🧾 HEADERS: $headers");

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

      debugPrint("✅ API HIT");
      debugPrint("📊 STATUS: ${response.statusCode}");
      debugPrint("📦 RESPONSE: ${response.data}");

      await _fetchMyProfile(); // 👈 GET again

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profile image uploaded")),
        );
      }
    } catch (e) {
      debugPrint("❌ UPLOAD ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Upload failed")),
      );
    } finally {
      setState(() => isLoading = false);
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
                      color: Colors.transparent, // ताकि पीछे कुछ दिखे नहीं
                    ),

                    /// 🔹 BACKGROUND HEADER (Height 200 ही रखी ताकि डिज़ाइन न बिगड़े)
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
                        onTap: () => Navigator.pop(context),
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
                                  "assets/svg/profile.svg",
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                            ),


                            GestureDetector(
                              behavior: HitTestBehavior.opaque, // यह क्लिक एरिया को पक्का करता है
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
        
                  TextField(
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
                  SizedBox(height: 20,),
                  TextField(
                    controller: emailController,
        
                    cursorColor: ColorCode.white,
                    style: const TextStyle(
                      color: ColorCode.white,
                    ),
                    decoration: InputDecoration(
                      labelText: "Email ID*",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
        
                    /*  suffixIcon: GestureDetector(
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
                      ),*/
        
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
                      focusNode: locationFocusNode, // ✅ IMPORTANT
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

                      /// ✅ ONLY when place is selected
                      getPlaceDetailWithLatLng: (prediction) async {
                        final latLng = LatLng(
                          double.parse(prediction.lat!),
                          double.parse(prediction.lng!),
                        );

                        setState(() {
                          currentLatLng = latLng;
                          selectedAddress = prediction.description ?? "";
                        });

                        locationController.text = selectedAddress;

                        locationController.selection = TextSelection.fromPosition(
                          TextPosition(offset: locationController.text.length),
                        );

                        locationFocusNode.unfocus(); // ✅ cursor stable

                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(latLng, 14),
                        );
                      },

                      /// ❌ YAHAN setState MAT LAGANA
                      itemClick: (prediction) {
                        locationController.text = prediction.description ?? "";
                        locationController.selection = TextSelection.fromPosition(
                          TextPosition(offset: locationController.text.length),
                        );
                      },

                      isCrossBtnShown: true,
                    ),
                  ),


                  SizedBox(height: 20,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      child: currentLatLng == null
                          ?  Center(
                        child: CircularProgressIndicator(),
                      )
                          :GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 14,
                        ),

                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        compassEnabled: true,


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
                          setState(() {
                            currentLatLng = latLng;
                          });

                          await getAddressFromLatLng(latLng);

                          locationController.text = selectedAddress;
                        },
                      )
                    ),

                  ),

                  SizedBox(height: 20,),

                  TextField(
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
