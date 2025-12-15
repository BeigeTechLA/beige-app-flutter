import 'package:beige/Home/Specialities/BookShoot.dart';
import 'package:flutter/material.dart';
import '../../utility/ColorCode.dart';

class Specialities extends StatefulWidget {
  const Specialities({super.key});

  @override
  State<Specialities> createState() => _SpecialitiesState();
}

class _SpecialitiesState extends State<Specialities> {

  // 🔹 Dummy list (10 items)
  final List<Map<String, String>> items = List.generate(
    10,
        (index) => {
      "title": "Events &\nParties",
      "bg": "assets/images/Frame 2087328875@3x.png",
      "icon": "assets/images/party.png",
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: SafeArea(   // ✅ TOP SE AUTO GAP
        child: Padding(
          padding: const EdgeInsets.all(20), // ✅ PROPER SIDE + TOP SPACE
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔙 BACK BUTTON
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  "assets/Icons/Reply.png",
                  height: 24,
                  width: 24,
                  color: ColorCode.white,
                ),
              ),

              const SizedBox(height: 20), // ⬅️ thoda niche

              /// 🔹 TITLE
              const Text(
                "Book A shoot",
                style: TextStyle(
                  color: ColorCode.white,
                  fontFamily: 'Unbounded',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24), // ⬅️ title ke niche space

              /// 🔥 GRID VIEW
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return _buildGridItem(items[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 🔹 SINGLE GRID ITEM
  Widget _buildGridItem(Map<String, String> item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  BookShootScreen(), // next screen
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [

            /// BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                item["bg"]!,
                fit: BoxFit.cover,
              ),
            ),

            /// TOP LEFT TEXT
            Positioned(
              top: 10,
              left: 8,
              child: Text(
                item["title"]!,
                style: const TextStyle(
                  color: ColorCode.white,
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            /// BOTTOM RIGHT ICON
            Positioned(
              bottom: 0,
              right: 2,
              child: Image.asset(
                item["icon"]!,
                height: 70,
                width: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
