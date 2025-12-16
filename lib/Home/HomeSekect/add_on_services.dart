import 'package:beige/utility/ColorCode.dart';
import 'package:flutter/material.dart';

import 'booking_summary_detils.dart';

class AddOnServices extends StatefulWidget {
  const AddOnServices({super.key});

  @override
  State<AddOnServices> createState() => _AddOnServicesState();
}

class _AddOnServicesState extends State<AddOnServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1D1B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/Icons/Vector.png",
                    height: 24,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
          
          
                const SizedBox(height: 20),
          
                /// 🟡 TITLE
                const Text(
                  "Add - Ons",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorCode.white,
                  ),
                ),
          
                const SizedBox(height: 6),
          
                /// 🔹 SUB TITLE
                Text(
                  "Would you like to add anything to your shoot?",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorCode.kWhiteOpacity70,
                  ),
                ),
          
                const SizedBox(height: 20),
          
          
           Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     Text("Drone Footage"),
                        Text("1 hr - 30 min"),
                        Text("\$ 500.00/-"),
          
                      ],
                    ),
                  ),
          
                  /// ➕ BUTTON
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8D1AB), // light shade
                          Color(0xFFD4A14D), // dark shade
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ],
              ),
            Divider(color: Colors.white30,thickness: 1,),
               Row(
               children: [
                 /// TEXT
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("Additional Hour of Videographer",
                         style: TextStyle(
                           color: ColorCode.white,
                           fontFamily: "Outfit",
                           fontWeight: FontWeight.w400,
                           fontSize: 14
                       ),
                       ),
          
                       Text("1 hr - 30 min",
                         style: TextStyle(
                         color: ColorCode.kWhiteOpacity60,
                         fontFamily: "Outfit",
                         fontWeight: FontWeight.w400,
                           fontSize: 10
                       ),),
                       SizedBox(height: 5,),
                       Text("\$ 250.00/-",
                         style: TextStyle(
                             color: ColorCode.white,
                             fontFamily: "Outfit",
                             fontWeight: FontWeight.w400,
                             fontSize: 14
                         ),
                       ),
                       SizedBox(height: 30,),
          
                       TextField(
                         style: const TextStyle(
                           color: Colors.white,
                           fontSize: 14,
                         ),
                         cursorColor: Colors.white,
                         decoration: InputDecoration(
                           hintText: "How many hours",
                           hintStyle: TextStyle(
                             fontFamily: "Outfit",
                             fontSize: 10,
                             fontWeight: FontWeight.w400,
                             color: ColorCode.kWhiteOpacity70,
                           ),
                           filled: true,
                           fillColor: ColorCode.kHeadingColor,
                           contentPadding: const EdgeInsets.symmetric(
                             horizontal: 5,
                             vertical: 4, // 🔽 reduced height
                           ),
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(6),
                             borderSide: BorderSide.none,
                           ),
                           enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: BorderSide.none,
                           ),
                           focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: BorderSide.none,
                           ),
                         ),
                       ),
          
          
                     ],
                   ),
                 ),

                 Container(
                   width: 32,
                   height: 32,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(8),
                     gradient: const LinearGradient(
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                       colors: [
                         Color(0xFFE8D1AB), // light shade
                         Color(0xFFD4A14D), // dark shade
                       ],
                     ),
                   ),
                   child: const Icon(
                     Icons.add,
                     color: Colors.black,
                     size: 18,
                   ),
                 ),
               ],
             ),
              Divider(color: Colors.white30,thickness: 1,),
              Row(
                children: [
                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Additional Videographer",
                          style: TextStyle(
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),
                        ),
          
                        Text("1 hr - 30 min",
                          style: TextStyle(
                              color: ColorCode.kWhiteOpacity60,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 10
                          ),),
                        SizedBox(height: 5,),
                        Text("\$ 850.00/-",
                          style: TextStyle(
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),
                        ),
                        SizedBox(height: 30,),
          
                        TextField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "How many hours",
                            hintStyle: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: ColorCode.kWhiteOpacity70,
                            ),
                            filled: true,
                            fillColor: ColorCode.kHeadingColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 4, // 🔽 reduced height
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
          
          
                      ],
                    ),
                  ),
          
                  /// ➕ BUTTON
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8D1AB), // light shade
                          Color(0xFFD4A14D), // dark shade
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white30,thickness: 1,),
          
              Row(
                children: [
                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Same Day Editing",
                          style: TextStyle(
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),
                        ),

                        Text("\$ 300.00/-",
                          style: TextStyle(
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),
                        ),

          
                      ],
                    ),
                  ),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8D1AB), // light shade
                          Color(0xFFD4A14D), // dark shade
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white30,thickness: 1,),

              Row(
                children: [
                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Color Graded RAW Footage",
                          style: TextStyle(
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),
                        ),


                        // SizedBox(height: 5,),
                        Text("\$ 350/-",
                          style: TextStyle(
                              color: ColorCode.white,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 14
                          ),
                        ),
                        SizedBox(height: 30,),



                      ],
                    ),
                  ),

                  /// ➕ BUTTON
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8D1AB), // light shade
                          Color(0xFFD4A14D), // dark shade
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),

                ],
              ),
          
          
            ],
          ),
                ),
          
          
          
                /// 🟡 BOTTOM BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.kButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingSummaryDetils(),
                        ),
                      );
                    },

                    child: const Text(
                      "Proceed to Payment",
                      style: TextStyle(
                          color: ColorCode.kHeadingColor,
                          fontFamily: "Unbounded",
                          fontWeight: FontWeight.w500,
                          fontSize: 15
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 ADD-ON CARD WIDGET
  Widget addOnCard({
    required String title,
    String? subtitle,
    required String price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// ➕ BUTTON
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEAD7B0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
