import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import 'bookshoot1.dart';

class BookShootScreen extends StatefulWidget {
  const BookShootScreen({super.key});

  @override
  State<BookShootScreen> createState() => _BookShootScreenState();
}

class _BookShootScreenState extends State<BookShootScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorCode.black,
      body: Stack(
        children: [
          /// ✅ BACKGROUND IMAGE FIXED — FULL SCREEN
          Container(
            height: height,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Rectangle 34660882.png",),
                  fit: BoxFit.fill
              ),
            ),
          ),

          /// ✅ BOTTOM SHEET FLOATING ABOVE IMAGE
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 20),
               // padding:  EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Drag line
                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color:ColorCode.kWhiteOpacity70,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        "Book Your Shoot Now",
                        style: TextStyle(
                          color: ColorCode.white,
                          fontFamily: 'Unbounded',   // ← Add this
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          // Looks cleaner in Unbounded
                        ),
                      ),
                      IconButton(
                        icon:  Icon(Icons.close,color: ColorCode.white,),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),

                  Divider(color: ColorCode.kDividerWhite12),
                   SizedBox(height: 16),

                  buildRadio("Shoots & Edits", 0),
                  buildRadio("Shoots & Raw Files", 1),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7C89E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Bookshoot1()),
                        );
                      },
                      child: const Text("Next",
                        style: TextStyle(
                          color: ColorCode.kHeadingColor,
                          fontFamily: 'Unbounded',   // ← Add this
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          // Looks cleaner in Unbounded
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadio(String title, int item) {
    return InkWell(
      onTap: () => setState(() => selectedIndex = item),
      child: Padding(
        padding:  EdgeInsets.all( 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
          style: TextStyle(
            color: ColorCode.kWhiteOpacity70,
            fontFamily: 'Outfit  ',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            // Looks cleaner in Unbounded
          ),),

            // Custom Radio Circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                /// 🔥 GRADIENT WHEN SELECTED
                gradient: selectedIndex == item
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8D1AB), // light shade
                    Color(0xFFD4A14D), // dark shade
                  ],
                )
                    : null,

                color: selectedIndex == item ? null : Colors.transparent,

                /// 🔸 BORDER
                border: Border.all(
                  color: ColorCode.kWhiteOpacity70,
                  width: 1,
                ),
              ),

              child: selectedIndex == item
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorCode.black,
                  ),
                ),
              )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
