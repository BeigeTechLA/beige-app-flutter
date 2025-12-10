  import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';
import 'Specialities/specialities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final List<Map<String, String>> items = [
  {"title": "Events &\nParties", "icon": "assets/images/home3.png"},
  {"title": "Creative &\nMedia", "icon": "assets/images/home3.png"},
  {"title": "Travel &\nOutdoors", "icon": "assets/images/home3.png"},
  {"title": "Drone &\nAerial", "icon": "assets/images/home3.png"},
  {"title": "Sports &\nAction", "icon": "assets/images/home3.png"},
  {"title": "Personal\nShoots", "icon": "assets/images/home3.png"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.kBackgroundColor,

        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ⭐ HEADER SECTION
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/Home1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [

                        // 🔹 TOP BAR
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding:  EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                // 👉 LEFT SIDE: Menu Icon + Address Text
                                Row(
                                  children: [
                                    Image(
                                      image: AssetImage("assets/Icons/menu-02.png"),
                                      color: Colors.white,
                                      height: 28,
                                    ),
                                    SizedBox(width: 10),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Westheimer Rd",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Santa Ana, Illinois 85486",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // 👉 RIGHT SIDE: Notification Icon
                                Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 SEARCH BAR
                        Positioned(
                          top: 80,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: "Search Photographer, Videographer....",
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                // ⭐ WHITE CONTAINER — OVERLAPPING
                Transform.translate(
                  offset: Offset(0, -25), // ⭐ Overlap adjusts here
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),

                    child: Column(
                      children: [

                        // ⭐ TITLE ROW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:  [
                            Text(
                              "Specialities",
                              style: TextStyle(
                                color: ColorCode.kHeadingColor,
                                fontFamily: 'Unbounded',   // ← Add this
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,        // Looks cleaner in Unbounded
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Specialities(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "View All",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: ColorCode.kSubtextOpacity,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                ),
                              ),
                            )



                          ],
                        ),

                        SizedBox(height: 15),

                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: specialityCard()),
                                SizedBox(width: 12),
                                Expanded(child: specialityCard()),
                                SizedBox(width: 12),
                                Expanded(child: specialityCard()),
                              ],
                            ),

                            SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(child: specialityCard()),
                                SizedBox(width: 12),
                                Expanded(child: specialityCard()),
                                SizedBox(width: 12),
                                Expanded(child: specialityCard()),
                              ],
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),

                // ⭐ ORANGE CAPTURE CARD
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      image: DecorationImage(
                        image: AssetImage("assets/images/Group 2085664125.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Capture Your\nPerfect Moments",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 12),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Quick Book",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 25),


                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Featured Creatives",
                          style: TextStyle(
                            color: ColorCode.kHeadingColor,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,        // Looks cleaner in Unbounded
                          ),
                        ),

                        Text(
                          "View All",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: ColorCode.kSubtextOpacity,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,      // ← Underline added
                            decorationThickness: 1.5,                  // (Optional) line thickness
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                creatorTile(
                  name: "Ethan Cole",
                  rating: "4.5",
                  price: "\$450",
                  status: "Available",
                  isAvailable: true,
                ),

                creatorTile(
                  name: "Maya Ramirez",
                  rating: "4.2",
                  price: "\$200",
                  status: "Busy",
                  isAvailable: false,
                ),


                SizedBox(height: 40),
              ],
            ),
          ),
        )

    );
  }

  // ⭐ SPECIALITY CARD WIDGET
  Widget specialityCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 6,
        //     spreadRadius: 2,
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          "assets/images/home3.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }


  // ⭐ CREATOR TILE
  Widget creatorTile({
    required String name,
    required String rating,
    required String price,
    required String status,       // Available / Busy
    required bool isAvailable,    // true → green, false → red
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT IMAGE CONTAINER (exact screenshot style)
          Container(
            height: 95,
            width: 95,
            decoration: BoxDecoration(
              color: ColorCode.kCreamSoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/images/Home4.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          // MIDDLE CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME + STATUS BADGE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Unbounded',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // STATUS BADGE
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAvailable ? Colors.green : Colors.red,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // SPECIALIST TEXT
                Text(
                  "Photographer Specialist",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 12),

                // RATING + PRICE ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 20, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(120)",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    // Price
                    Text(
                      "From $price/Hr",
                      style: const TextStyle(
                        fontFamily: 'Unbounded',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


}
