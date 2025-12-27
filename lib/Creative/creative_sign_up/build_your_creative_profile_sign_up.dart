import 'package:beige/Creative/creative_sign_up/professional_details_sing_up.dart';
import 'package:flutter/material.dart';
import '../../ChooseYourRole/choose_your_role_screen.dart';
import '../../utility/ColorCode.dart';

class BuildYourCreativeProfileSignUp extends StatefulWidget {
  const BuildYourCreativeProfileSignUp({super.key});

  @override
  State<BuildYourCreativeProfileSignUp> createState() =>
      _BuildYourCreativeProfileSignUpState();
}

class _BuildYourCreativeProfileSignUpState extends State<BuildYourCreativeProfileSignUp> {


  String? selectedDistance;
 /* File? profileImage;
  final ImagePicker _picker = ImagePicker();*/

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
          "assets/Icons/Reply.png", height: 24, color: ColorCode.white,),
          ),

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
                              color: index == 0
                                  ? ColorCode.kButtonColor
                                  : ColorCode.kSubtextColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                  ),
                ),

                SizedBox(height: 12),
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

                _buildField("First Name*", _firstNameFocus),
                SizedBox(height: 20),

                _buildField("Last Name*", _lastNameFocus),
                SizedBox(height: 20),

                _buildField("Email Address*", _emailFocus),
                SizedBox(height: 20),

                _buildField("Location*", _locationFocus),

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
                    onPressed: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) =>  ProfessionalDetailsSingUp()),
                        );
                    },
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
                       /* Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) =>  LoginScreen()),
                        );*/
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
      ) {
    return TextField(
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
    final List<String> distances = [
      "0 – 5 km",
      "5 – 10 km",
      "10 – 25 km",
      "25 – 50 km",
      "50+ km",
    ];

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

      hint: const Text(
        "Select distance",
        style: TextStyle(color: Colors.white54),
      ),

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
          color: Colors.white.withOpacity(0.08),
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
              /// PROFILE IMAGE
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: const AssetImage(
                  "assets/images/profile_placeholder.png",
                ), // replace with picked image later
              ),

              const SizedBox(width: 14),

              /// UPLOAD BUTTON
              Expanded(
                child: InkWell(
                  onTap: () {
                    // TODO: open image picker
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4E1C1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Upload Profile Picture",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
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
