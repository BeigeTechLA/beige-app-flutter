import 'package:flutter/material.dart';

import '../../../utility/ColorCode.dart';

class CrewSizeMatchingScreen extends StatefulWidget {
  const CrewSizeMatchingScreen({super.key});

  @override
  State<CrewSizeMatchingScreen> createState() => _CrewSizeMatchingScreenState();
}

class _CrewSizeMatchingScreenState extends State<CrewSizeMatchingScreen> {

  int currentStep = 1;

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
              "Create Project",
              style: TextStyle(
                color: ColorCode.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
                    // ⭕ Upcoming step (EMPTY)
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: ColorCode.white)
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
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


                 SizedBox(height: 24),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Image.asset(
                      "assets/newbookflow/Frame_2087328912.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Corporate Event (Video)",style: TextStyle(color: ColorCode.white, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Outfit"),
                    ),

                    Text("02-04 People",style: TextStyle(color: ColorCode.kButtonColor, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Outfit"),
                    )
                  ],
                ),
                 SizedBox(height: 10),   SizedBox(height: 10),
                Divider(color: ColorCode.kDividerWhite12,),

                Column(
                  children: [
                    Row(
                      children: [
                        Text("Typical output:",
                          style: TextStyle(color: ColorCode.kWhiteOpacity70, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Outfit"),
                        ),

                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("1 highlight reel",
                          style: TextStyle(color: ColorCode.white, fontSize: 14,fontWeight: FontWeight.w500,fontFamily: "Outfit"),
                        ),
                      ],
                    ),
                  ],
                )

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
