import 'package:beige/Home/HomeSekect/select_date_time.dart';
import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  ColorCode.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF6),
        elevation: 0,
        leading:   InkWell(
          onTap: () => Navigator.pop(context),
          child: Image.asset("assets/Icons/Reply.png", height: 24),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "1/5",
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding:  EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Progress Bar
            Row(
              children: List.generate(
                5,
                    (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    height: 5,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.black
                          : Colors.grey.shade300,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// ✅ Search Field
            TextField(
              decoration: InputDecoration(
                hintText: "Search for area, street name...",
                hintStyle: TextStyle(color: ColorCode.kSubtextOpacity),

                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text("Map View"),
                    ),
                  ),

                  /// ✅ Use Current Location Button
                  Positioned(
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
                      label: const Text("use current location"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ✅ Address Row
            Row(
              children: [
                 Icon(Icons.location_on_outlined),
                 // SizedBox(width: 8),
                 Expanded(
                  child: Text(
                    "2458 Sunset Boulevard\nLos Angeles, CA 90026",
                    style: TextStyle(fontSize: 14,color: ColorCode.kHeadingColor,fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Change",
                    style: TextStyle(
                      color: ColorCode.kHeadingColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 12),

            /// ✅ Next Button
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
}
