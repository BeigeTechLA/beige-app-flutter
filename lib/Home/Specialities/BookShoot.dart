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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// ✅ Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"), // add image
                fit: BoxFit.cover,
              ),
            ),
          ),

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
                      height: 6,
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
                        icon: const Icon(Icons.close),
                        onPressed: () {},
                      )
                    ],
                  ),
                 Divider(color:ColorCode.grey_white,),
                   SizedBox(height: 16),

                  /// ✅ Options
                  buildRadio("Shoots & Edits", 0),
                  buildRadio("Shoots & Raw Files", 1),

                  const SizedBox(height: 20),

                  /// ✅ Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE7C89E),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) =>  Bookshoot1()),
                              );
                            },
                            child: const Text("Next"),
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
