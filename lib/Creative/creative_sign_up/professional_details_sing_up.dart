import 'package:beige/Creative/creative_sign_up/social_engagement_singup.dart';
import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';

class ProfessionalDetailsSingUp extends StatefulWidget {
  const ProfessionalDetailsSingUp({super.key});

  @override
  State<ProfessionalDetailsSingUp> createState() =>
      _ProfessionalDetailsSingUpState();
}

class _ProfessionalDetailsSingUpState
    extends State<ProfessionalDetailsSingUp> {
  String? primaryRole;
  String? experience;
  String? hourlyRate;
  String? skills;
  String? equipment;

  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 BACK + STEP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      "assets/Icons/Reply.png",
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "2/3",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 12),

              /// 🔵 PROGRESS BAR
              Row(
                children: List.generate(
                  3,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? ColorCode.kButtonColor
                            : ColorCode.kSubtextColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 📝 TITLE
              const Text(
                "Professional Details",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Unbounded",
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              /// SUBTITLE
              const Text(
                "Create your profile to get discovered by production teams.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Outfit",
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

              const SizedBox(height: 24),

              _dropdownField("Primary Role*", primaryRole,
                  ["Photographer", "Videographer", "Editor"], (v) {
                    setState(() => primaryRole = v);
                  }),

              const SizedBox(height: 20),

              _dropdownField("Years of Experience*", experience,
                  ["0-1 Years", "1-3 Years", "3-5 Years", "5+ Years"], (v) {
                    setState(() => experience = v);
                  }),

              const SizedBox(height: 20),

              _dropdownField("Hourly Rate*", hourlyRate,
                  ["₹500/hr", "₹1000/hr", "₹2000+/hr"], (v) {
                    setState(() => hourlyRate = v);
                  }),

              const SizedBox(height: 20),

              /// BIO FIELD
              _textField(
                title: "Bio / About",
                hint: "Highlight your creative focus.",
                controller: bioController,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              _dropdownField("Add Skills", skills,
                  ["Lighting", "Cinematography", "Editing"], (v) {
                    setState(() => skills = v);
                  }),

              const SizedBox(height: 20),

              _dropdownField("Add Equipment", equipment,
                  ["Camera", "Drone", "Gimbal"], (v) {
                    setState(() => equipment = v);
                  }),

              const SizedBox(height: 30),

              /// NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) =>  SocialEngagementSingup()),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// LOGIN TEXT
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(
                      color: ColorCode.kWhiteOpacity70,
                    ),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: ColorCode.kButtonColor,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 🔽 DROPDOWN FIELD
  Widget _dropdownField(String title, String? value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1C1C1C),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(title),
      items: items
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }

  /// ✍️ TEXT FIELD
  Widget _textField({
    required String title,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(title).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }

  /// 🎨 COMMON DECORATION
  InputDecoration _inputDecoration(String title) {
    return InputDecoration(
      labelText: title,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(color: ColorCode.kWhiteOpacity70),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: ColorCode.kButtonColor, width: 1),
      ),
    );
  }
}
