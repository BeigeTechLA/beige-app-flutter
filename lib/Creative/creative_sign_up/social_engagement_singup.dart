import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../utility/ColorCode.dart';

class SocialEngagementSingup extends StatefulWidget {
  final int ?crewMemberId;
  const SocialEngagementSingup({super.key, this.crewMemberId});

  @override
  State<SocialEngagementSingup> createState() =>_SocialEngagementSingupState();
}

class _SocialEngagementSingupState extends State<SocialEngagementSingup> {

  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  final TextEditingController enter_work_titleController = TextEditingController();
  int selectedSocialIndex = -1;
  int? editingIndex;

  List<String> selectedTags = [];

  String? fileType; // image / video

  File? featuredFile;
  bool isVideo = false;

  bool isLoggingIn =false;

  File? documentFile;
  File? resumeFile;
  File? portfolioFile;
  File? certificateFile;
  File? recentWorkFile;

  IconData? selectedIcon;
  Color? selectedColor;
  File? selectedFile;

  List<Map<String, dynamic>> savedLinks = [];
  List<PlatformFile> featuredFiles = [];
  List<bool> featuredIsVideo = [];

  List<File> featuredImages = [];
  bool isPicking = false;
  List<File> certificateFiles = [];

  final List<String> socialNames = [
    "Facebook",
    "Instagram",
    "TikTok",
    "Behance",
    "Website",
  ];

  final List<IconData> socialIcons = [
    Icons.facebook,
    Icons.camera_alt, // Instagram
    Icons.music_note, // TikTok
    Icons.brush,      // Behance
    Icons.language,   // Website
  ];

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        certificateFiles.add(File(result.files.single.path!));
      });
    }
  }


  Future<void> _pickFeaturedMedia(Function setModalState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setModalState(() {
        featuredImages = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
      });
    }
  }

/*
  Future<void> _pickFeaturedMedia(Function setModalState) async {
    if (isPicking) return;
    isPicking = true;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // 🔥 MULTIPLE
    );

    if (result != null && result.files.isNotEmpty) {
      setModalState(() {
        featuredImages = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
      });

      setState(() {});
    }

    isPicking = false;
  }
*/

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        documentFile = File(result.files.single.path!);
      });
    }
  }


  Future<void> _pickPortfolio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        portfolioFile = File(result.files.single.path!);
      });
    }
  }


  bool isImageFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  Future<void> _fetchSingup3() async {
    if (widget.crewMemberId == null) {
      _showSnack("Crew member id missing");
      return;
    }

    if (savedLinks.isEmpty) {
      _showSnack("Please add at least one social link");
      return;
    }

   if (featuredImages.isEmpty || featuredFile == null) {
     _showSnack("Please upload featured work");
     return;
   }

    setState(() => isLoggingIn = true);

    final socialLinks = savedLinks.map((e) {
      return {
        "platform": e['name'].toString().toLowerCase(),
        "url": e['url'],
      };
    }).toList();

    final featuredWork = [
    /*  {
        "work_title": enter_work_titleController.text.trim(),
        "tags": selectedTags,
      }*/
      {
        "work_title": "Wedding Shoot",
        "tags": ["cinematography", "drone"]
      }

    ];

    final certifications = [
      "Certified Cinematographer – XYZ Institute",
      "Drone Pilot License – DGCA",
    ];

    final payload = {
      "crew_member_id": widget.crewMemberId.toString(),
      "certifications": jsonEncode(certifications),
      "social_media_links": jsonEncode(socialLinks),
      "featured_work": jsonEncode(featuredWork),
    };

    /// 🔥 DEBUG PRINTS (LIKE POSTMAN)
    debugPrint("========== SIGNUP STEP-3 REQUEST ==========");
    payload.forEach((key, value) {
      debugPrint("$key : $value");
    });

    debugPrint("📁 FEATURED FILE:");
    debugPrint("Path: ${featuredFile!.path}");
    debugPrint("Name: ${featuredFile!.path.split('/').last}");
    debugPrint("Size: ${featuredFile!.lengthSync()} bytes");
    debugPrint("==========================================");

    try {
      final response = await ApiService().postMultipart(
        ApiEndpoints.register_step3,
        payload,
          featuredFile
      );

      debugPrint("📥 API RESPONSE: $response");

      if (response != null && response['error'] == false) {
        _showSnack("Signup Step-3 Completed 🎉");
      } else {
        _showSnack(response?['message'] ?? "Signup failed");
      }
    } catch (e) {
      debugPrint("❌ API ERROR: $e");
      _showSnack("Something went wrong");
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
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        "assets/Icons/Reply.png",
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      ""
                          "3/3",
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

                ///  ADD SOCIAL LINKS
                ///
                if (savedLinks.isNotEmpty)
                  Column(
                    children: savedLinks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return Container(
                         margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                          color: Colors.black26,
                        ),
                        child: Row(
                          children: [
                            /// ICON
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: ColorCode.kButtonColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'],
                                color: ColorCode.kButtonColor,
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// NAME + URL
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// 🗑 DELETE ICON
                            InkWell(
                              onTap: () {
                                setState(() {
                                  savedLinks.removeAt(index);
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                _buildAddTile(
                  title: "Add Social Links",
                  onTap: _openSocialSheet,
                ),
                const SizedBox(height: 20),


                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorCode.bcakgroundcolor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Featured Work",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          if (featuredImages.isNotEmpty)
                            InkWell(
                              onTap: _featuredSheet,
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: const [
                                  Icon(Icons.add, size: 18, color: Color(0xFFF4E1C1)),
                                  SizedBox(width: 4),
                                  Text(
                                    "Add another",
                                    style: TextStyle(
                                      color: Color(0xFFF4E1C1),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),


                       SizedBox(height: 12),

                      /// ADD / PREVIEW BOX
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: featuredImages.isEmpty ? _featuredSheet : null,
                        child: featuredImages.isEmpty
                            ? Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                "Add",
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        )

                        /// 🔥 IMAGE PREVIEW MODE (NO BORDER)
                            : SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.95),
                            itemCount: featuredImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.file(
                                          featuredImages[index],
                                          fit: BoxFit.fill,
                                        ),
                                      ),

                                      /// OPTIONAL TITLE OVERLAY
                                      Positioned(
                                        left: 12,
                                        bottom: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "Featured Work",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                ),




                SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorCode.bcakgroundcolor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🔹 HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Upload Certifications",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          if (certificateFiles.isNotEmpty)
                            InkWell(
                              onTap: _pickCertificate,
                              child: Row(
                                children: const [
                                  Icon(Icons.add, size: 18, color: Color(0xFFF4E1C1)),
                                  SizedBox(width: 4),
                                  Text(
                                    "Add another",
                                    style: TextStyle(
                                      color: Color(0xFFF4E1C1),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 EMPTY STATE (UPLOAD BOX)
                      if (certificateFiles.isEmpty)
                        GestureDetector(
                          onTap: _pickCertificate,
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white38),
                            ),
                            child: const Center(
                              child: Text(
                                "Upload",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                      /// 🔹 FILE LIST
                      if (certificateFiles.isNotEmpty)
                        Column(
                          children: List.generate(certificateFiles.length, (index) {
                            final file = certificateFiles[index];
                            final fileName = file.path.split('/').last;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [

                                  /// FILE ICON
                                  const Icon(Icons.link, color: Colors.white),

                                  const SizedBox(width: 10),

                                  /// FILE NAME
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),

                                  /// VIEW
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                                    onPressed: () {
                                      // TODO: Open PDF / Image viewer
                                    },
                                  ),

                                  /// DELETE
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        certificateFiles.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),




                SizedBox(height: 16),


        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorCode.bcakgroundcolor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  const Text(
                    "Upload Documents",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// RESUME
                  _documentBlock(
                    label: "Upload Resume/CV",
                    file: documentFile,
                    onUpload: _pickDocument,
                    onDelete: () {
                      setState(() => documentFile = null);
                    },
                  ),

                  const SizedBox(height: 12),

                  /// PORTFOLIO
                  _documentBlock(
                    label: "Upload Portfolio",
                    file: portfolioFile,
                    onUpload: _pickPortfolio,
                    onDelete: () {
                      setState(() => portfolioFile = null);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 12),



                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoggingIn
                        ? null
                        : () {
                      debugPrint("🟢 NEXT BUTTON CLICKED");
                      _fetchSingup3();
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
                        fontFamily: "Unbounded",
                        color: ColorCode.kHeadingColor,
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
            height: 30,
            width: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 16,
            ),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Text(
            title,
            style: const TextStyle(
              color: ColorCode.kWhiteOpacity70,
              fontSize: 15,
              fontFamily: "Outfit",
            ),
          ),
        ],
      ),
    );
  }
  Widget _documentBlock({
    required String label,
    required File? file,
    required VoidCallback onUpload,
    required VoidCallback onDelete,
  }) {
    return file == null
        ? GestureDetector(
      onTap: onUpload,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white24,
            style: BorderStyle.solid, // dashed jaisa look
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    )

    /// 🔥 FILE PREVIEW MODE
        : Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [

          /// FILE ICON
          const Icon(Icons.insert_drive_file,
              color: Colors.white, size: 22),

          const SizedBox(width: 10),

          /// FILE NAME
          Expanded(
            child: Text(
              file.path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          /// VIEW
          IconButton(
            icon: const Icon(Icons.remove_red_eye,
                color: Colors.white),
            onPressed: () {
              // TODO: open file viewer
            },
          ),

          /// DELETE
          IconButton(
            icon: const Icon(Icons.delete,
                color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
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
  Divider(color: ColorCode.kDividerWhite12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _socialImage(index: 0, imagePath: "assets/Icons/facebook.png"),
                  _socialImage(index: 1, imagePath: "assets/Icons/ins.png"),
                  _socialImage(index: 2, imagePath: "assets/Icons/tick_tok.png"),
                  _socialImage(index: 3, imagePath: "assets/Icons/Vector.png"),
                  _socialImage(index: 4, imagePath: "assets/Icons/webside.png"),
                ],
              ),



              const SizedBox(height: 20),
              _buildField("Name of the Link", nameLinkController),
              const SizedBox(height: 12),
              _buildField("Link URL", linkController),

              const SizedBox(height: 20),
              if (savedLinks.isNotEmpty) ...[
                const SizedBox(height: 12),

                Column(
                  children: savedLinks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                        color: Colors.black26,
                      ),
                      child: Row(
                        children: [
                          /// ICON
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: ColorCode.kButtonColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: ColorCode.kButtonColor,
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// NAME + URL
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['url'],
                                  style: const TextStyle(
                                    color: ColorCode.kWhiteOpacity70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          /// ✏️ EDIT
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                            onPressed: () {
                              setState(() {
                                editingIndex = index;
                                nameLinkController.text = item['name'];
                                linkController.text = item['url'];
                                selectedSocialIndex =
                                    socialIcons.indexOf(item['icon']);
                              });

                              _openSocialSheet();
                            },
                          ),

                          /// 🗑 DELETE
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                savedLinks.removeAt(index); // ✅ DELETE INSTANT
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),


                /// ➕ ADD ANOTHER LINK
               /* InkWell(
                  onTap: _openSocialSheet,
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: ColorCode.kButtonColor),
                      SizedBox(width: 6),
                      Text(
                        "Add another link",
                        style: TextStyle(
                          color: ColorCode.kButtonColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),*/
              ],

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
                  onPressed: () {
                    if (nameLinkController.text.isEmpty ||
                        linkController.text.isEmpty ||
                        selectedSocialIndex == -1) return;

                    setState(() {
                      if (editingIndex != null) {
                        /// ✏️ UPDATE EXISTING
                        savedLinks[editingIndex!] = {
                          "name": nameLinkController.text,
                          "url": linkController.text,
                          "icon": socialIcons[selectedSocialIndex],
                        };
                      } else {
                        /// ➕ ADD NEW
                        savedLinks.add({
                          "name": nameLinkController.text,
                          "url": linkController.text,
                          "icon": socialIcons[selectedSocialIndex],
                        });
                      }
                    });

                    /// CLEAR
                    nameLinkController.clear();
                    linkController.clear();
                    selectedSocialIndex = -1;
                    editingIndex = null;

                    Navigator.pop(context);
                  },



                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),


            ],
          ),


        );


      },
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
  Widget _socialImage({
    required int index,
    required String imagePath,
  }) {
    final bool isSelected = selectedSocialIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          selectedSocialIndex = index;

          /// 🔥 AUTO FILL NAME FIELD
          nameLinkController.text = socialNames[index];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorCode.kButtonColor
                : Colors.white24,
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: ColorCode.kButtonColor.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 22,
            width: 22,
            color: isSelected
                ? ColorCode.kButtonColor
                : Colors.white,
          ),
        ),
      ),
    );
  }



//Featured Work
  void _featuredSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration:  BoxDecoration(
                color: ColorCode.bcakgroundcolor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔘 TOP DRAG INDICATOR
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin:  EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    /// 🟢 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Featured Work",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Unbounded ",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon:  Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),

                     Text(
                      "For best results, use a PNG, JPG, Video or\nGIF image etc.",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Outfit"

                      ),
                    ),

                     SizedBox(height: 16),
                     Divider(color: ColorCode.kDividerWhite12),
                     SizedBox(height: 20),

                    /// ✏️ WORK TITLE
                    _buildField(
                      "Enter Work Title",
                      enter_work_titleController,
                    ),

                    SizedBox(height: 16),

                /*    GestureDetector(
                      onTap: () => _pickFeaturedMedia(setModalState),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: featuredFile == null
                            ? Column(
                          children: const [
                            Icon(Icons.upload, color: Colors.white, size: 28),
                            SizedBox(height: 10),
                            Text(
                              "Upload new image, video, or browse",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Choose a file in a 4:3, 5:4, 9:16, or 16:9\n"
                                  "aspect ratio. Max 10MB (images)\n500MB (videos).",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ColorCode.kWhiteOpacity70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            if (!isVideo)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9, // 🔥 change if needed
                                  child: Image.file(
                                    featuredFile!,
                                    width: double.infinity,
                                    fit: BoxFit.cover, // full container fill
                                  ),
                                ),
                              ),

                            if (isVideo)
                              Container(
                                height: 180,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),

                             SizedBox(height: 10),

                            const Text(
                              "Tap to change media",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),*/

                    GestureDetector(
                      onTap: () => _pickFeaturedMedia(setModalState),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: featuredImages.isEmpty
                            ? Column(
                          children: const [
                            Icon(Icons.upload, color: Colors.white, size: 28),
                            SizedBox(height: 10),
                            Text(
                              "Upload images",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "You can select multiple images\n(Max 10MB each)",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                            : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: featuredImages.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                featuredImages[index],
                                fit: BoxFit.cover, // 🔥 FULL IMAGE
                              ),
                            );
                          },
                        ),
                      ),
                    ),


                    SizedBox(height: 16),

                    /// 🏷️ ADD TAGS
                    GestureDetector(
                       // onTap: _openAddTagSheet,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.local_offer_outlined,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                "# Add Tags",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                     SizedBox(height: 24),

                    /// 💾 SAVE BUTTON
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void _openAddTagSheet() {
    TextEditingController tagController = TextEditingController();
    List<String> tempTags = List.from(selectedTags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔘 TOP DRAG INDICATOR
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    /// 🟢 HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Tag",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Unbounded",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),

                     SizedBox(height: 8),

                     Text(
                      "Help people find your work",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity70,
                        fontSize: 13,
                      ),
                    ),

                     SizedBox(height: 16),
                     Divider(color: ColorCode.kDividerWhite12),
                     SizedBox(height: 20),

                    /// TextField
                    TextField(
                      controller: tagController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        // label: "Tag",
                        hintText: "Type Tag and Press Enter",
                        hintStyle: TextStyle
                          (
                          fontSize: 14,
                          fontFamily: "Outfit",
                            color: Colors.white54


                        ),
                        contentPadding:  EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(                          borderRadius: BorderRadius.all(Radius.circular(12)),

                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty &&
                            !tempTags.contains(value.trim())) {
                          setModalState(() {
                            tempTags.add(value.trim());
                            tagController.clear();
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    /// Tags Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tempTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.black,
                          labelStyle:
                          const TextStyle(color: Colors.white),
                          deleteIconColor: Colors.white,
                          onDeleted: () {
                            setModalState(() {
                              tempTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAD3A1),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedTags = tempTags;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}

