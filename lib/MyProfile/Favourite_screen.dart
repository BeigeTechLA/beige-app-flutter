import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {

  bool isFavourite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔙 BACK BUTTON
            Padding(
              padding:  EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/Icons/Reply.png",
                    height: 24,
                    color: ColorCode.white,
                  ),
                ),
              ),
            ),

            /// 🏷 TITLE
             Row(
               mainAxisAlignment: MainAxisAlignment.start,
               children: [
                 Text(
                  "Favourites",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorCode.white,
                  ),
                             ),
               ],
             ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding:  EdgeInsets.symmetric(horizontal: 16),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          /// 🔹 BACKGROUND IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              "assets/images/home3.png",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// 🔹 DARK BOTTOM GRADIENT
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(18),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          ///  ONLINE DOT
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: Colors.green,
                                ),
                                SizedBox(width: 5,),
                                Text("Active",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w500,fontFamily: "Outfit"),)
                              ],
                            ),


                          ),

                          /// HEART ICON
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isFavourite = !isFavourite;
                                });

                                _showFavouriteToast(
                                  isFavourite
                                      ? "Added to Favourite"
                                      : "Removed from Favourite",
                                );
                              },
                              child: Image.asset(
                                isFavourite
                                    ? "assets/Icons/Heart_Angl_COLOR.png" // ❤️ selected
                                    : "assets/images/Heart Angle.png",    // 🤍 unselected
                                height: 22,
                                width: 22,
                              ),
                            ),
                          ),



                          /// 🔹 TEXT CONTENT
                          Positioned(
                            bottom: 20,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// ⭐ RATING
                                Row(
                                  children: const [
                                    Icon(Icons.star, color: Colors.yellow, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      "4.5 (120)",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: "Outfit",
                                        color: ColorCode.kWhiteOpacity70,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// 👤 NAME
                                const Text(
                                  "Angela Kia",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                    color: ColorCode.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                /// 🎥 ROLE
                                const Text(
                                  "Videography Specialist",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: "Outfit",
                                    color: ColorCode.kWhiteOpacity70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 💰 PRICE + ACTION BUTTON
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorCode.kButtonColor,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Text(
                                    "From \$450/Hr",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      color: ColorCode.kCircleGradientTop,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Image.asset(
                                  "assets/images/Group 2087328980.png",
                                  height: 34,
                                  width: 34,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showFavouriteToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: ColorCode.kButtonColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Outfit",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => overlayEntry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }


}
