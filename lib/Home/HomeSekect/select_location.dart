import 'package:beige/Home/HomeSekect/select_date_time.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  bool savePassword = false;
  String? selectedStudio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:  ColorCode.kBackgroundColor,
      appBar: AppBar(
        // backgroundColor: ColorCode.kBackgroundColor,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            "assets/Icons/Reply.png", height: 24, color: ColorCode.white,),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "1/5",
                style: TextStyle(color: ColorCode.white),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Progress Bar
            Row(
              children: List.generate(
                5,
                    (index) =>
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        height: 5,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? ColorCode.kButtonColor
                              : ColorCode.kSubtextColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Title
            Text(
              "Select The Location",
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            /// ✅ Search Field
            TextField(
              decoration: InputDecoration(
                hintText: "Search for area, street name...",
                hintStyle: TextStyle(
                  color: ColorCode.k777571,
                  fontFamily: 'Outfit                ', // ← Add this
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  // Looks cleaner in Unbounded
                ),

                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    Icons.search,
                    color: ColorCode.white,
                    size: 22,
                  ),
                ),

                filled: true,
                fillColor: ColorCode.k262624,

                // ⭐ Ye sabse important hai – inner padding (top/bottom/left/right)
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 18,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),

              ),
            ),


            const SizedBox(height: 16),

            /// ✅ Map Placeholder
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage("assets/Icons/map.png"),
                        // <-- YOUR IMAGE
                        fit: BoxFit.cover,

                      ),
                    ),
                  ),

                  /// Gradient overlay (optional)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.15), // light overlay
                    ),
                  ),

                  /// Use Current Location Button
                  /*     Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text("Use current location"),
                    ),
                  ),*/
                ],
              ),
            ),

            SizedBox(height: 16),

            /// ✅ Address Row
            Row(
              children: [
                Icon(Icons.location_on_outlined),
                // SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "2458 Sunset Boulevard\nLos Angeles, CA 90026",
                    style: TextStyle(
                      color: ColorCode.white,
                      fontFamily: 'Outfit', // ← Add this
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // Looks cleaner in Unbounded
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Change",
                    style: TextStyle(
                      color: ColorCode.kButtonColor,
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorCode
                          .kButtonColor, // ⭐ Underline ka color

                    ),
                  ),
                ),

              ],
            ),

            SizedBox(height: 12),

            Divider(color: ColorCode.k262624),

            SizedBox(height: 12),

            /// ✅ Next Button
            ///
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => savePassword = !savePassword),
                      child: Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: savePassword ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: ColorCode.white),
                        ),
                        child: savePassword
                            ? const Icon(Icons.check, size: 14, color: ColorCode.kButtonColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "I need a Beige Studio\n",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: "Outfit",

                                  ),
                                ),

                                TextSpan(
                                  text: "Professional studio with lighting & equipment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: ColorCode.k777571,
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )



                  ],
                ),
                SizedBox(height: 15),
                buildSelectStudioField(),
                SizedBox(height: 15),

              ],
            ),

            SizedBox(
              width: double.infinity,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectDateTime(),
                    ),
                  );
                },
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label) {
    return TextField(
        cursorColor: ColorCode.kButtonColor,

        style: const TextStyle(
          color: ColorCode.kButtonColor, // typed text color
        ),

        decoration: InputDecoration(
          labelText: "$label*",
          floatingLabelBehavior: FloatingLabelBehavior.always,

          labelStyle: const TextStyle(
            color: ColorCode.kButtonColor, // #1D1D1B 60% opacity
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          /// ⭐ 0.5px BORDER + OPACITY COLOR
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorCode.kButtonColor, // #1D1D1B99 (60% opacity)
              width: 0.5, // 🔥 exact 0.5px
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorCode.kButtonColor, // #1D1D1B99 (60% opacity)
              width: 0.5, // focus border thicker
            ),
          ),

          floatingLabelStyle: TextStyle(
            color: ColorCode.kButtonColor,
          ),)

    );
  }

  Widget buildSelectStudioField() {
    String? selectedStudio;

    return StatefulBuilder(
      builder: (context, setState) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: "Select Studio",
            labelStyle: TextStyle(
              color: ColorCode.k777571,
              fontSize: 14, // 🔹 Label size same rakha
            ),
            filled: true,
            fillColor: Color(0xFF1C1C1C),

            // 🔥 DROP HEIGHT SMALL
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorCode.kWhiteOpacity70, width: 0.5),
            ),
          ),

          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              isDense: true,   // 🔥 Makes dropdown more compact
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorCode.white,
              ),
              value: selectedStudio,
              dropdownColor: Color(0xFF1C1C1C),
/*
              hint: Text(
                "Select Studio",
                style: TextStyle(
                  color: ColorCode.k777571,
                  fontSize: 15,
                ),
              ),*/

              onChanged: (value) {
                setState(() {
                  selectedStudio = value;
                });
              },

              items: [
                "Studio A",
                "Studio B",
                "Studio C",
                "Studio D",
              ].map((val) {
                return DropdownMenuItem(
                  value: val,

                  // 🔥 DROP ITEM HEIGHT SMALL
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      val,
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

  }



}
