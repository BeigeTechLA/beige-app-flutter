import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../service/api_endpoints.dart';
import '../../../service/api_service.dart';
import '../../../utility/ColorCode.dart';
import '../../HomeSekect/finding_the_perfect_screen.dart';

class CrewSizeMatchingScreen extends StatefulWidget {
  final int specialtyId;
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  const CrewSizeMatchingScreen({super.key, required this.specialtyId, required this.ShootTypeId, required this.bookingId, required this.contentTypeId});

  @override
  State<CrewSizeMatchingScreen> createState() => _CrewSizeMatchingScreenState();
}

class _CrewSizeMatchingScreenState extends State<CrewSizeMatchingScreen> {

  int currentStep = 1;
bool isLoading =true;

  List<String> defaultOutput = [];

  String shootName = "";
  String contentType = "";
  int minCrew = 0;
  int maxCrew = 0;


  List<Map<String, dynamic>> roles = [];
  List<String> reasoning = [];
  String shootImageUrl = "";


  @override
  void initState() {
    super.initState();

    _CrewSizeMatching();
  }
  Future<void> _CrewSizeMatching() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService().fetchData(
        "${ApiEndpoints.booking}/${widget.bookingId}/crew-recommendation",
      );

      debugPrint("API Response → $response");

      if (response != null && response['error'] == false) {
        final data = response['data'];

        setState(() {
          shootName = data['shoot_type']['name'] ?? "";
          contentType = data['shoot_type']['content_type'] ?? "";

          // ✅ ADD THIS
          shootImageUrl = data['shoot_type']['image_url'] ?? "";

          minCrew = data['recommended_crew']['min'] ?? 0;
          maxCrew = data['recommended_crew']['max'] ?? 0;

          defaultOutput = List<String>.from(data['default_output'] ?? []);


          roles = List<Map<String, dynamic>>.from(
            data['recommended_crew']['roles'] ?? [],
          );

          reasoning = List<String>.from(data['reasoning'] ?? []);
        });

      }
    } catch (e) {
      debugPrint("API Error → $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String getShootImage() {
    if (shootImageUrl.isEmpty) return "";
    return ApiService().getImageURL(shootImageUrl);
  }

  String getDefaultOutputText() {
    if (defaultOutput.isEmpty) return "-";

    if (defaultOutput.length == 1) {
      return defaultOutput.first;
    }

    return "${defaultOutput.first} (+${defaultOutput.length - 1})";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // 🔹 Back Button (Left)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  color: ColorCode.white,
                ),
              ),
            ),
            Text(
              "More Details",
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: TextStyle(
                  color: ColorCode.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(padding:  EdgeInsets.all(16.0),
            child: Column(
              children: [
          
          
                Row(
                  children: List.generate(3, (index) {
                    double fillWidth = 0;
          
                    if (index < currentStep) {
                      // ✅ Completed step (FULL)
                      fillWidth = double.infinity;
                    } else if (index == currentStep) {
                      // 🟡 Current step (HALF)
                      fillWidth = 82.44;
                    } else {
          
                      fillWidth = 0;
                    }
          
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 5,
                        decoration: BoxDecoration(
                          color: ColorCode.kSubtextColor, // grey background
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: fillWidth > 0
                            ? Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 5,
                            width: fillWidth == double.infinity ? null : fillWidth,
                            decoration: BoxDecoration(
                              color: ColorCode.kButtonColor,
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                        )
                            : const SizedBox(),
                      ),
                    );
                  }),
                ),
          
                SizedBox(
                  height: 20,
                ),
          
                Row(
                  children: [
                    Text(
                      "Crew Size & Matching",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          
                SizedBox(height: 20),
          
                Container(
                  // padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(color: ColorCode.white)
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding:  EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ColorCode.kButtonColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info_outline, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Recommended Crew Size for \nYour Project",
                                style: TextStyle(color: ColorCode.kHeadingColor, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Outfit"),
                              ),
                            ),
                          ],
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 280,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: getShootImage(),
                              fit: BoxFit.cover,

                              // ⏳ loading
                              placeholder: (context, url) {
                                debugPrint("⏳ IMAGE LOADING → $url");
                                return Center(
                                  child: Lottie.asset(
                                    "assets/lottie/Untitled_file.json",
                                    width: 120,
                                    height: 120,
                                  ),
                                );
                              },

                              // ✅ success
                              imageBuilder: (context, imageProvider) {
                                debugPrint("✅ IMAGE LOADED → ${getShootImage()}");
                                return Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                );
                              },

                              // ❌ error
                              errorWidget: (context, url, error) {
                                debugPrint("❌ IMAGE FAILED → $url");
                                return Center(
                                  child: Lottie.asset(
                                    "assets/lottie/Untitled_file.json",
                                    width: 120,
                                    height: 120,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),



                      Padding(
                    padding: const EdgeInsets.all(12.0),
                    child:Row(
                      children: [
                        Expanded(
                          child: Text(
                            "$shootName (${contentType.toUpperCase()})",
                            maxLines: 2,                    // ✅ allows wrapping
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ColorCode.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Outfit",
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          "$minCrew - $maxCrew People",
                          style: const TextStyle(
                            color: ColorCode.kButtonColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Outfit",
                          ),
                        ),
                      ],
                    ),

                      ),
                  SizedBox(height: 10),
                      if (defaultOutput.isNotEmpty) ...[
                        const SizedBox(height: 10),

                        Divider(color: ColorCode.kDividerWhite12),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Typical output:",
                                    style: TextStyle(
                                      color: ColorCode.kWhiteOpacity70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    getDefaultOutputText(),
                                    style: const TextStyle(
                                      color: ColorCode.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "How would you like to proceed?",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          
                SizedBox(height: 10),
                Container(
                   padding: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                  /*    border: Border.all(color: ColorCode.kButtonColor)*/
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/newbookflow/ai_matchmaker.png",
                            fit: BoxFit.cover,
                          ),
                           SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "AI Matchmaker",
                              style: TextStyle(color: ColorCode.kButtonColor, fontSize: 16,fontWeight: FontWeight.w700,fontFamily: "Outfit"),
                            ),
                          ),
                        ],
                      ),

                      // Divider(color: ColorCode.kDividerWhite12,),
                      //

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Text("Our AI will analyse your project and match you\nwith the perfect crew size and specialists",style: TextStyle(color: ColorCode.white, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Outfit"),
                          ),

                        ],
                      ),

                      SizedBox(height: 10),

                    Container(
          /*  decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(13)),
              color: ColorCode.k282828,
            ),*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckRow("Optimal team composition"),
                const SizedBox(height: 10),
                _buildCheckRow("Matched based on your budget"),
                const SizedBox(height: 10),
                _buildCheckRow("Industry best practices"),
              ],
            ),
          ),


          ],
                  ),
                ),

                SizedBox(height: 20),
                Divider(color: ColorCode.kDividerWhite12,),
                SizedBox(height:15),
                Row(
                  children: [
                    Text(
                      "How AI Matching Works",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),


                SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    Text("Our intelligent matching system considers multiple\nfactors to build your ideal crew:",style: TextStyle(color: ColorCode.kWhiteOpacity70, fontSize: 14,fontWeight: FontWeight.w400,fontFamily: "Outfit"),
                    ),

                  ],
                ),
                SizedBox(height:15),

          Container(
         /*   decoration: BoxDecoration(
              color: ColorCode.k282828,
              borderRadius: BorderRadius.circular(14),
            ),*/

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "•",
                      style: TextStyle(
                        color: Color(0xFFE6C48F),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Shoot Type & Complexity: ",
                              style: TextStyle(
                                color: Color(0xFFE6C48F),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Outfit",
                              ),
                            ),
                            TextSpan(
                              text:
                              "Different shoots require\n different team sizes",
                              style: TextStyle(
                                color: ColorCode.kWhiteOpacity70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Outfit",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "•",
                      style: TextStyle(
                        color: Color(0xFFE6C48F),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Budget Range: ",
                              style: TextStyle(
                                color: Color(0xFFE6C48F),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Outfit",
                              ),
                            ),
                            TextSpan(
                              text:
                              "We match crews that fit your \nbudget tier",
                              style: TextStyle(
                                color: ColorCode.kWhiteOpacity70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Outfit",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "•",
                      style: TextStyle(
                        color: Color(0xFFE6C48F),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Industry Standards: ",
                              style: TextStyle(
                                color: Color(0xFFE6C48F),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: "Outfit",
                              ),
                            ),
                            TextSpan(
                              text:
                              "Based on thousands of \n successful projects",
                              style: TextStyle(
                                color: ColorCode.kWhiteOpacity70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Outfit",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )



          ],
            ),
          ),
        ),
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 🔹 Back Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 🔸 Continue Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FindingThePerfectScreen(
                            bookingId: widget.bookingId,
                            contentTypeId: widget.contentTypeId,
                            specialtyId: widget.specialtyId,
                            ShootTypeId: widget.ShootTypeId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.kButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:  Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w600,
                        color: ColorCode.kHeadingColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),


    ),
    );
  }

  Widget _buildCheckRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          "assets/newbookflow/true.png", // ✔️ icon image
          height: 24,
          width: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ColorCode.kWhiteOpacity70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: "Outfit",
            ),
          ),
        ),
      ],
    );
  }

}
