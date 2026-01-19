import 'package:flutter/material.dart';

import '../../../utility/ColorCode.dart';
import '../../HomeSekect/recommended_detils_screen.dart';
import '../Book_Confirm/review_confirm_screen.dart';

class SelectYourDreamTeam extends StatefulWidget {
  const SelectYourDreamTeam({super.key});

  @override
  State<SelectYourDreamTeam> createState() => _SelectYourDreamTeamState();
}

class _SelectYourDreamTeamState extends State<SelectYourDreamTeam> {

  int currentStep = 1;
  bool isAdded = false;

  bool isLoading =true;

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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  fillWidth = 140.44;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Your Dream Team",
                  style: TextStyle(
                    fontFamily: "Unbounded ",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorCode.white,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _openFilterDialog(context);
                  },
                  child: Image.asset(
                    "assets/Icons/Filter.png",
                    height: 24,
                    width: 24,
                    color: ColorCode.white,
                  ),
                ),


              ],
            ),

            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 237,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [

                          /// 🔹 IMAGE
                          Positioned.fill(
                            child: Image.asset(
                              "assets/images/Rectangle 34661070.png",
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// 🔹 GRADIENT
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// 🔹 TOP ROW
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [

                                /// ACTIVE
                                Row(
                                  children: const [
                                    CircleAvatar(
                                        radius: 4,
                                        backgroundColor: Colors.green),
                                    SizedBox(width: 6),
                                    Text(
                                      "Active",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),

                                /// HEART
                                Image.asset(
                                  "assets/images/Heart Angle.png",
                                  height: 22,
                                ),
                              ],
                            ),
                          ),

                          /// 🔹 BOTTOM CONTENT
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [

                                /// LEFT INFO
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: const [
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.amber, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          "4.5 (120)",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Angela Kia",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "Videography Specialist",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),

                                /// RIGHT BUTTON
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isAdded = !isAdded; // 🔁 toggle
                                        });
                                      },
                                      child: Container(
                                        padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isAdded
                                              ? ColorCode.kLightRed        // ❌ Remove state
                                              : ColorCode.kButtonColor,   // ✅ Add state
                                          borderRadius: BorderRadius.circular(30),
                                          border: isAdded
                                              ? Border.all(color: Colors.red) // 🔴 Remove border
                                              : null,
                                        ),
                                        child: Text(
                                          isAdded ? "Remove" : "Add to Crew",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w600,
                                            color: isAdded ? Colors.red : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => RecommendedDetilsScreen(
                                              id: 1 ,
                                              bookingId: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.asset(
                                        "assets/images/Group 2087328980.png",
                                        height: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),

      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            // 🔸 Continue Button
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>  ReviewConfirmScreen(),
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
                    "Continue with 00 Member",
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

  void _openFilterDialog(BuildContext context) {
    int selectedIndex = 1;
    RangeValues priceRange = const RangeValues(100, 15000);

    final List<String> options = [
      "Top Rated",
      "Alphabetical A - Z",
      "Nearest",
      "Newest Profiles",
      "Low to High Price",
      "High to Low Price",
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorCode.k282828,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// TOP INDICATOR
                        Center(
                          child: Container(
                            width: 35,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: ColorCode.kWhiteOpacity70,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Filter By",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Divider(color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 16),

                        /// 🔹 SORT CARD (FIXED)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sort By",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ...List.generate(options.length, (index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() => selectedIndex = index);
                                  },
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          options[index],
                                          style: TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: ColorCode.kWhiteOpacity70,
                                          ),
                                        ),

                                        /// ✅ GRADIENT RADIO (index valid here)
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: selectedIndex == index
                                                ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFFE8D1AB), // light shade
                                                Color(0xFFD4A14D), // dark shade
                                              ],
                                            )
                                                : null,
                                            border: Border.all(
                                              color: Colors.white38,
                                            ),
                                          ),
                                          child: selectedIndex == index
                                              ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration:
                                              const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// PRICE RANGE
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            // color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Price Range",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.white,
                                ),
                              ),
                              RangeSlider(
                                values: priceRange,
                                min: 100,
                                max: 15000,
                                activeColor: ColorCode.kButtonColor,
                                inactiveColor: Colors.white24,
                                onChanged: (values) {
                                  setState(() => priceRange = values);
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Minimum\n\$${priceRange.start.toInt()}",
                                    style: const TextStyle(
                                      color: ColorCode.kWhiteOpacity70,
                                      fontSize: 11,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Maximum\n\$${priceRange.end.toInt()}",
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: ColorCode.kWhiteOpacity70,
                                      fontSize: 11,
                                      fontFamily: "Unbounded",
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                  Border.all(color: ColorCode.kWhiteOpacity60
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = 0;
                                      priceRange =
                                      const RangeValues(100, 15000);
                                    });
                                  },
                                  child: const Text(
                                    "Clear All",
                                    style: TextStyle(
                                      fontFamily: "Unbounded",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: ColorCode.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: ColorCode.kButtonColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                      "Apply",
                                      style: TextStyle(
                                        fontFamily: "Unbounded",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: ColorCode.black,
                                      )
                                  ),
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
          },
        );
      },
    );
  }
}
