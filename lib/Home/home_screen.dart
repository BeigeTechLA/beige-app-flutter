  import 'dart:ui';

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
       backgroundColor: ColorCode.bcakgroundcolor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(
                  20, // left
                  28, // top (status bar ke niche look ke liye)
                  20, // right
                  20, // bottom
                ),
                decoration: const BoxDecoration(
                  color: ColorCode.k282828,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 TOP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        /// MENU
                        Image.asset(
                          "assets/Icons/menu-02.png",
                          width: 26,
                          color: Colors.white,
                        ),

                        /// LOCATION
                        Column(
                          children: [
                            Row(
                              children: const [
                                Text(
                                  "Westheimer Rd",
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Santa Ana, Illinois 85486",
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ColorCode.kWhiteOpacity70,
                              ),
                            ),
                          ],
                        ),

                        /// BELL + PROFILE
                        Row(
                          children: [
                            Image.asset(
                              "assets/Icons/notifactioin.png",
                              width: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            const CircleAvatar(
                              radius: 18,
                              backgroundImage:
                              AssetImage("assets/Icons/profile.png"),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    /// 🔹 SEARCH BAR (IMAGE JAISE LOOK)
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: ColorCode.kHeadingColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/Icons/serch.png",
                            width: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: TextField(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Outfit",
                              ),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText:
                                "Search Photographer, Videographer...",
                                hintStyle: TextStyle(
                                  color: ColorCode.kWhiteOpacity70,
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),



            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [

                    // ⭐ TITLE ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text(
                          "Services we Provide",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                         // Looks cleaner in Unbounded
                          ),
                        ),
                  /*      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Specialities(),
                              ),
                            );
                          },
                          child: Image.asset(
                            "assets/Icons/rightside.png",
                            height: 40,   // bigger height
                            width: 40,
                            color: ColorCode.white,
                          ),
                        )*/

                      ],
                    ),

                SizedBox(height: 15,),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 99,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [

                                  /// 🔹 BACKGROUND IMAGE
                                  Positioned.fill(
                                    child: Image.asset(
                                      "assets/images/Frame 2087328875@3x.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  /// 🔹 TOP LEFT TEXT
                                  Positioned(
                                    top: 10,
                                    left: 5,
                                    child: Text(
                                      "Beige \n Fleets ",
                                      style: TextStyle(
                                        color: ColorCode.white,
                                        fontFamily: 'Outfit',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        // Looks cleaner in Unbounded
                                      ),
                                    ),
                                  ),

                                  /// 🔹 BOTTOM RIGHT IMAGE
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Image.asset(
                                      "assets/images/home_car_.png", // small image
                                      height: 70.95,
                                      width: 70.95,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15,),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Specialities(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 99,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: [

                                    /// 🔹 BACKGROUND IMAGE
                                    Positioned.fill(
                                      child: Image.asset(
                                        "assets/images/Frame 2087328875@3x.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    /// 🔹 TOP LEFT TEXT
                                    Positioned(
                                      top: 10,
                                      left: 5,
                                      child: Text(
                                        "Beige\nStudios ",
                                        style: TextStyle(
                                          color: ColorCode.white,
                                          fontFamily: 'Outfit',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          // Looks cleaner in Unbounded
                                        ),
                                      ),
                                    ),

                                    /// 🔹 BOTTOM RIGHT IMAGE
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Image.asset(
                                        "assets/images/home_studio.png", // small image
                                        height: 70.95,
                                        width: 70.95,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15,),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Specialities(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 99,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  children: [

                                    /// 🔹 BACKGROUND IMAGE
                                    Positioned.fill(
                                      child: Image.asset(
                                        "assets/images/Frame 2087328875@3x.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    /// 🔹 TOP LEFT TEXT
                                    Positioned(
                                      top: 10,
                                      left: 5,
                                      child: Text(
                                        "Events &\n Parties ",
                                        style: TextStyle(
                                          color: ColorCode.white,
                                          fontFamily: 'Outfit',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          // Looks cleaner in Unbounded
                                        ),
                                      ),
                                    ),

                                    /// 🔹 BOTTOM RIGHT IMAGE
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Image.asset(
                                        "assets/images/party.png", // small image
                                        height: 70.95,
                                        width: 70.95,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15,),
                            Container(
                              height: 99,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [

                                  /// 🔹 BACKGROUND IMAGE
                                  Positioned.fill(
                                    child: Image.asset(
                                      "assets/images/Frame 2087328875@3x.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  /// 🔹 TOP LEFT TEXT
                                  Positioned(
                                    top: 10,
                                    left: 5,
                                    child: Text(
                                      "Events &\n Parties ",
                                      style: TextStyle(
                                        color: ColorCode.white,
                                        fontFamily: 'Outfit',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        // Looks cleaner in Unbounded
                                      ),
                                    ),
                                  ),

                                  /// 🔹 BOTTOM RIGHT IMAGE
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Image.asset(
                                      "assets/images/party.png", // small image
                                      height: 70.95,
                                      width: 70.95,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15,),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
/*
            Center(
              child: Container(
                height: 260,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/home3.png"), // MAIN IMAGE
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [

                    /// 🔥 DARK GRADIENT OVERLAY
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// 🟢 ACTIVE + RATING
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "4.5 (120)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 🧑‍🎨 TEXT CONTENT
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Ethan Cole",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: "Outfit",
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Photographer Specialist",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),

                    /// 💰 PRICE BUTTON
                    Positioned(
                      bottom: 18,
                      right: 16,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAD7B0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "From \$450/Hr",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),*/


            Center(
                child:
                Container(
                  child: Image.asset("assets/images/Group 1597883815 (1).png"),
                ),
              ),


              SizedBox(height: 25),


              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text(
                          "Featured Creatives",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            // Looks cleaner in Unbounded
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Specialities(),
                              ),
                            );
                          },
                          child: Image.asset(
                            "assets/Icons/rightside.png",
                            height: 40,   // bigger height
                            width: 40,
                            color: ColorCode.white,
                          ),
                        )

                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        teamCard(image: "assets/images/man2.png", name: "George Harris"),
                        teamCard(image: "assets/images/man2.png", name: "Emily Johnson"),
                        teamCard(image: "assets/images/man2.png", name: "Charles Smith"),
                      ],
                    )

                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text(
                          "We Think You’ll Love These ",
                          style: TextStyle(
                            color: ColorCode.white,
                            fontFamily: 'Unbounded',   // ← Add this
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            // Looks cleaner in Unbounded
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Specialities(),
                              ),
                            );
                          },
                          child: Image.asset(
                            "assets/Icons/rightside.png",
                            height: 40,   // bigger height
                            width: 40,
                            color: ColorCode.white,
                          ),
                        ),



                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,   // 👉 horizontal scroll enable
                      child: Row(
                        children: [
                          SizedBox(width: 12), // optional spacing

                          // 🔹 Your First Card
                          Container(
                            width: 210,
                            height: 280,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    "assets/images/home2.png",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(18),
                                    ),
                                    child: Image.asset(
                                      "assets/images/Rectangle 19.png",
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                      height: 120,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    height: 14,
                                    width: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // on press action
                                        },
                                        child: Image.asset(
                                          "assets/images/Heart Angle.png", // 👈 apni image path
                                          height: 24,
                                          width: 24,
                                          color: Colors.white, // agar white chahiye
                                        ),
                                      ),

                                      SizedBox(width: 4),
                                    ],
                                  ),
                                ),

                                // BOTTOM CONTENT
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [


                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.yellow, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "4.5 (120)",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),




                                      Text(
                                        "Angela Kia",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      SizedBox(height: 2),

                                      Text(
                                        "Videography Specialist",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: ColorCode.kButtonColor,
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            child: Text(
                                              "From \$450/Hr",
                                              style: TextStyle(
                                                fontFamily: "Outfit",
                                                color: ColorCode.kCircleGradientTop,
                                                fontWeight: FontWeight.w700,

                                                fontSize: 14,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            height: 36,
                                            width: 36,
                                            child: Image.asset('assets/images/Group 2087328980.png'),
                                            /*  decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white24,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 18,
                                            ),*/
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 16),

                          // 🔹 Second Card (Your full card with button)
                          Container(
                            width: 210,
                            height: 280,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.asset(
                                    "assets/images/home2.png",
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(18),
                                    ),
                                    child: Image.asset(
                                      "assets/images/Rectangle 19.png",
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                      height: 120,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    height: 14,
                                    width: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // on press action
                                        },
                                        child: Image.asset(
                                          "assets/images/Heart Angle.png", // 👈 apni image path
                                          height: 24,
                                          width: 24,
                                          color: Colors.white, // agar white chahiye
                                        ),
                                      ),

                                      SizedBox(width: 4),
                                    ],
                                  ),
                                ),

                                // BOTTOM CONTENT
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [


                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.yellow, size: 18),
                                          SizedBox(width: 4),
                                          Text(
                                            "4.5 (120)",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),




                                      Text(
                                        "Angela Kia",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      SizedBox(height: 2),

                                      Text(
                                        "Videography Specialist",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),

                                      SizedBox(height: 10),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: ColorCode.kButtonColor,
                                              borderRadius: BorderRadius.circular(22),
                                            ),
                                            child: Text(
                                              "From \$450/Hr",
                                              style: TextStyle(
                                                fontFamily: "Outfit",
                                                color: ColorCode.kCircleGradientTop,
                                                fontWeight: FontWeight.w700,

                                                fontSize: 14,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            height: 36,
                                            width: 36,
                                            child: Image.asset('assets/images/Group 2087328980.png'),
                                            /*  decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white24,
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 18,
                                            ),*/
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                      ),
                    )





                  ],
                ),

              ),
            ],
          ),
        )

    );
  }

  // ⭐ SPECIALITY CARD WIDGET
  Widget specialityCard() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias, // image rounded aayegi
      child: Image.asset(
        "assets/images/Group 2087328775 (1).png",
        fit: BoxFit.cover, // pura container fill karegi
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


  Widget teamCard({
    required String image,
    required String name,
  }) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Background Circle
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: ColorCode.k777571,
                shape: BoxShape.circle,
              ),
            ),

            // Image on top of circle
            Positioned(
              top: -20,
              child: ClipOval(
                child: Image.asset(
                  image,
                  height: 110,
                  width: 95,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 8),

        // Name
        Text(
          name,
          style: TextStyle(
            fontFamily: "Outfit",
            color: ColorCode.white,
            fontSize: 13,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }


}
