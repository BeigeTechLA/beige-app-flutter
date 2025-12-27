import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';

class SocialEngagementSingup extends StatefulWidget {
  const SocialEngagementSingup({super.key});

  @override
  State<SocialEngagementSingup> createState() =>
      _SocialEngagementSingupState();
}

class _SocialEngagementSingupState extends State<SocialEngagementSingup> {
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
                          color: index <= 1
                              ? ColorCode.kButtonColor
                              : ColorCode.kSubtextColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 📝 TITLE
                const Text(
                  "Social Engagement",
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
                  "Complete your profile and connect with top studios\nand filmmakers.",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Outfit",
                    color: ColorCode.kWhiteOpacity70,
                  ),
                ),

                const SizedBox(height: 24),

                /// ➕ ADD SOCIAL LINKS
                _buildAddTile(
                  title: "Add Social Links",
                  onTap: _openSocialSheet,
                ),
                const SizedBox(height: 20),

                /// 📷 FEATURED WORK
                _buildUploadBox("Featured Work", "Add"),

                const SizedBox(height: 16),

                /// 📜 CERTIFICATES
                _buildUploadBox("Upload Certificates", "Upload"),

                const SizedBox(height: 16),


                _buildUploadBox("Upload Resume/CV", "Upload Resume/CV"),
                const SizedBox(height: 12),
                _buildUploadBox("Upload Portfolio", "Upload Portfolio"),


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
      ),
    );
  }

  /// 🔹 COMMON TILE
  Widget _buildAddTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          /// ➕ CIRCULAR PLUS
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Text(
            title,
            style: const TextStyle(
              color: ColorCode.kWhiteOpacity70,
              fontSize: 16,
              fontFamily: "Outfit",
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 UPLOAD BOX
  Widget _buildUploadBox(String title, String action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Container(
          height: 90,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ColorCode.kSubtextColor,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Text(
              "+ $action",
              style: TextStyle(
                color: ColorCode.kWhiteOpacity70,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 🔽 SOCIAL LINKS SHEET
  void _openSocialSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: ColorCode.bcakgroundcolor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Social Links",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "Add links that showcase your work, recognition,\npersonality and more!",
                style: TextStyle(
                  color: ColorCode.kWhiteOpacity70,
                ),
              ),

              const SizedBox(height: 16),

              /// SOCIAL ICONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _SocialIcon(icon: Icons.facebook),
                  _SocialIcon(icon: Icons.camera_alt),
                  _SocialIcon(icon: Icons.music_note),
                  _SocialIcon(icon: Icons.palette),
                  _SocialIcon(icon: Icons.language),
                ],
              ),

              const SizedBox(height: 20),

              _buildTextField("Name of the Link"),
              const SizedBox(height: 12),
              _buildTextField("Behance / X / Instagram etc."),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ColorCode.kWhiteOpacity70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorCode.kSubtextColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ColorCode.kButtonColor),
        ),
      ),
    );
  }
}

/// 🔹 SOCIAL ICON WIDGET
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorCode.kSubtextColor),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
