import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';
import 'finding_the_perfect_screen.dart';

class ReviewConfirm extends StatefulWidget {
  const ReviewConfirm({super.key});

  @override
  State<ReviewConfirm> createState() => _ReviewConfirmState();
}

class _ReviewConfirmState extends State<ReviewConfirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      appBar: AppBar(
        backgroundColor:  ColorCode.bcakgroundcolor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset("assets/Icons/Reply.png", height: 24),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("5/5", style: TextStyle(color: ColorCode.white)),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ------------------ PROGRESS BAR ------------------
              Row(
                children: List.generate(
                  5,
                      (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index < 5
                            ? ColorCode.kButtonColor
                            : ColorCode.kSubtextColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Review & Confirm",
                style: TextStyle(
                  fontFamily: "Unbounded",
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              /// ------------------ WHITE CARD ------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Row(
                      children: [
                        Image.asset("assets/images/Group 2087328887.png", height: 24),
                        const SizedBox(width: 10),
                         Text(
                          "Wedding Event (Photography)",
                          style: TextStyle(
                            fontSize: 15,
                            color: ColorCode.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Outfit",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// --- Time Row ---
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              text: "01:30 AM to 03:30 AM ",
                              style: TextStyle(
                                color: ColorCode.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Outfit",
                              ),
                              children: [
                                TextSpan(
                                  text: "(Estimated 11h duration)",
                                  style: TextStyle(
                                    color: ColorCode.kButtonColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// --- Date Row ---
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          "March 22, 2025",
                          style:TextStyle(
                            color: ColorCode.kWhiteOpacity70,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Outfit",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// --- Location Row ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "2458 Sunset Boulevard Los Angeles, CA 90026",
                            style:TextStyle(
                              color: ColorCode.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Outfit",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ------------------ MAP SECTION ------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/map1.png", // your map image
                  fit: BoxFit.cover,
                ),
              ),
             SizedBox(height: 14,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: ColorCode.k2A2A2A,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 TITLE
                    Text(
                      "Additional Information",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        color: ColorCode.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 DESCRIPTION
                    Text(
                      "This is a one-day wedding event capturing the ceremony, portraits, and family moments. "
                          "Expecting candid coverage with a warm style. Final edited photos needed within a week.",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        color: ColorCode.kWhiteOpacity70,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,

                      ),
                    ),
                  ],
                ),
              ),


               SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCode.kButtonColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindingThePerfectScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Find Creative",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),


      /// ------------------ BOTTOM BUTTON ------------------
    /*  bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8D1AB),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Find Creative",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: "Unbounded",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),*/

    );
  }
}
