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
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorCode.bcakgroundcolor,
      body: Stack(
        children: [

          /// ✅ Background Image
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

          /// ✅ Bottom Sheet Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(right: 20,left: 20,top: 10,bottom: 20),
              decoration:BoxDecoration(
                color: ColorCode.k282828,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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

                  const SizedBox(height: 16),

                  /// Title + Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Book Your Shoot Now",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorCode.white,
                          fontSize: 16,
                          fontFamily: "Unbounded", //
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,color: ColorCode.white,),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Divider(color: ColorCode.kWhiteOpacity60),
                  SizedBox(height: 10),

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
                                side: const BorderSide(
                                  color: ColorCode.kWhiteOpacity70,
                                  width: 0.5,        // ⭐ BORDER WIDTH 0.5
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Back",
                                style: TextStyle(
                                  color: ColorCode.white,
                                  fontFamily: 'Unbounded',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )

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
                                fontFamily: 'Unbounded',   // ← Add this
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                // Looks cleaner in Unbounded
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

  /// ✅ Premium Gradient Radio Tile
  Widget buildRadio(String title, int item) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = item;
        });
      },
      child: Padding(
        padding:  EdgeInsets.all( 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Title
            Text(
              title,
              style: TextStyle(
                color: ColorCode.kWhiteOpacity70,
                fontFamily: 'Outfit  ',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                // Looks cleaner in Unbounded
              ),),

            /// 🔵 Custom Gradient Radio Circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                /// Gradient when selected
                gradient: selectedIndex == item
                    ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorCode.kButtonColor,
                    ColorCode.kCreamSoft
                  ],
                )
                    : null,

                /// When NOT selected → white background
                color: selectedIndex == item ? null : Colors.transparent,

                /// Border
                border: Border.all(
                  color: selectedIndex == item
                      ? ColorCode.kWhiteOpacity70
                      : ColorCode.kWhiteOpacity70,
                  width: 1,
                ),
              ),

              /// Inner Dot (Visible only when selected)
              child: selectedIndex == item
                  ? Center(
                child: Container(
                  width: 10,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
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