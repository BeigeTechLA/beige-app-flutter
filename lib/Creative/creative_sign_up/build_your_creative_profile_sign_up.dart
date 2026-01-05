import 'dart:io';

import 'package:beige/Creative/creative_sign_up/professional_details_sing_up.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
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
  final TextEditingController locationController  = TextEditingController();


  final List<String> distances = [
    "Upto 10 Miles",
    "10-20 Miles",
    "20-50 Miles",
  ];




/*
  Future<void> _pickAndCropImage() async {
    try {
      /// 📸 PICK IMAGE
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      /// ✂️ CROP IMAGE
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Profile',
            toolbarColor: const Color(0xFF1C1C1C),
            toolbarWidgetColor: Colors.white,
            backgroundColor: const Color(0xFF121212),
            activeControlsWidgetColor: ColorCode.kButtonColor,
            statusBarColor: Colors.black,
            cropFrameColor: ColorCode.kButtonColor,
            cropGridColor: Colors.white24,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            hideBottomControls: false,
            showCropGrid: false,
          ),
          IOSUiSettings(
            title: 'Crop Your Profile',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      /// ✅ SET IMAGE
      if (croppedFile != null) {
        setState(() {
          profileImage = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint("❌ Image Pick Error: $e");
    }
  }
*/

 /* Future<void> _pickAndCropImage() async {
    try {
      /// 📂 OPEN ONLY GALLERY
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, // ✅ ONLY GALLERY
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      /// ✂️ OPEN CROP SCREEN
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Profile',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: 'Crop Your Profile',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      /// ✅ SET CROPPED IMAGE
      if (croppedFile != null) {
        setState(() {
          profileImage = File(croppedFile.path);
        });

        debugPrint("✅ CROPPED IMAGE PATH: ${profileImage!.path}");
      }
    } catch (e) {
      debugPrint("❌ Image Picker Error: $e");
    }
  }*/



  File? _selectedImage;
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,

            // 🔥 IMPORTANT (v10 FIX)
            cropStyle: CropStyle.circle,   // ✅ YAHI DENA HAI
            hideBottomControls: false,     // zoom slider
            showCropGrid: false,
            lockAspectRatio: true,

            activeControlsWidgetColor: const Color(0xFFF4E1C1),
            statusBarColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Crop Profile',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() {
        profileImage = File(croppedFile.path);
      });

    } catch (e) {
      debugPrint("🔥 Crop error: $e");
    }
  }

  void openCustomCropSheet(File imageFile) {
    double scale = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Crop Your Profile",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  /// 🔥 CIRCULAR CROP VIEW
                  Expanded(
                    child: Center(
                      child: ClipOval(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          scaleEnabled: true,
                          child: Transform.scale(
                            scale: scale,
                            child: Image.file(imageFile),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// 🔥 ZOOM SLIDER (BOTTOM)
                  Slider(
                    value: scale,
                    min: 1,
                    max: 4,
                    activeColor: const Color(0xFFF4E1C1),
                    onChanged: (v) {
                      setSheetState(() => scale = v);
                    },
                  ),

                  /// 🔥 SAVE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4E1C1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      // ⚠️ Yahan actual crop logic add hota hai (next step)
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.black),
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
      "location": locationController.text.trim(),
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

                _buildField("Location*", _locationFocus, locationController),


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

                const SizedBox(height: 40),

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
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: ColorCode.kButtonColor,
      style: const TextStyle(
        color: ColorCode.white,
      ),

      decoration: InputDecoration(
        labelText: title,
        floatingLabelBehavior: FloatingLabelBehavior.always,

        /// 🔥 LABEL COLOR CHANGE
        labelStyle: TextStyle(
          color: focusNode.hasFocus
              ? ColorCode.kButtonColor   // active
              : ColorCode.kWhiteOpacity70, // inactive
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        /// 🔥 BORDER COLOR CHANGE
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorCode.kWhiteOpacity70,
            width: 0.5,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ColorCode.kButtonColor, // 🔥 active border
            width: 1,
          ),
        ),
      ),
      onTap: () {
        setState(() {}); // 🔁 UI refresh on focus
      },
      onChanged: (_) {
        setState(() {}); // 🔁 UI refresh while typing
      },
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

