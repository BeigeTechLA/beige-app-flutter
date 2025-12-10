import 'package:flutter/material.dart';

import '../../utility/ColorCode.dart';
import '../HomeSekect/select_location.dart';

class Bookshoot1 extends StatefulWidget {
  const Bookshoot1({super.key});

  @override
  State<Bookshoot1> createState() => _Bookshoot1State();
}

class _Bookshoot1State extends State<Bookshoot1> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// ✅ Background Image
          // Container(
          //   decoration: const BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage("assets/bg.jpg"), // add image
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),

          /// ✅ Bottom Sheet Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding:  EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Drag Indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Title + Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Book Your Shoot Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,color: ColorCode.kHeadingColor,),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Divider(color:ColorCode.grey_white,),
                  SizedBox(height: 16),

                  /// ✅ Options
                  buildRadio("Photography", 0),
                  buildRadio("Videography", 1),
                  buildRadio("Both", 2),

                  const SizedBox(height: 20),

                  /// ✅ Buttons
                  Row(
                    children: [
                      // ✅ Back Button
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ColorCode.kHeadingColor,
                              side:  BorderSide(color: ColorCode.kSubtextOpacity),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context); // ✅ Back action
                            },
                            child: const Text(
                              "Back",
                              style: TextStyle(
                                color: ColorCode.kHeadingColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ✅ Next Button
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE7C89E),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) =>  SelectLocation()),
                              );
                            },
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                color: ColorCode.kHeadingColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ),
                        ),
                      ),
                    ],
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Radio Tile Widget
  Widget buildRadio(String title, int value) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Title
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: ColorCode.kHeadingColor,
              ),
            ),

            /// ✅ Custom Circle
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectedIndex == value
                    ? Colors.black
                    : Colors.transparent,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: selectedIndex == value
                  ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}