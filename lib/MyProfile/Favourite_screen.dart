import 'package:flutter/material.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {

  bool isFavourite = false;
  bool isLoading = true;

  List<dynamic> favourites = [];



  @override
  void initState() {
    super.initState();
    _fetchfavourites();
  }
  Future<void> _fetchfavourites() async {
    try {
      final response = await ApiService().fetchData(ApiEndpoints.my_favourites);

      if (response != null && response['error'] == false) {
        setState(() {
          favourites = response['data'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }



  Future<void> _removeFavourite({   required int creatorId, required int index})  async {

    try {
      final response = await ApiService().deleteData(
        "${ApiEndpoints.addfavourites}/$creatorId",
      );

      if (response != null && response['error'] == false) {
        setState(() {
          favourites.removeAt(index); // 🔥 CARD REMOVE
        });

        _showFavouriteToast("Removed from Favourite");
      }
    } catch (e) {
      debugPrint("Remove Favourite Error: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(

            children: [
              /// 🔙 BACK BUTTON
              Align(
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

              /// 🏷 TITLE
               Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   Text(
                    "       Favourites",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorCode.white,
                    ),
                               ),
                 ],
               ),



              Expanded(
                child: ListView.builder(
                  padding:  EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favourites.length,
                  itemBuilder: (context, index) {
                    final item = favourites[index];
                    final int creatorId = item['creator_id'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: SizedBox(
                          height: 220,
                          child: Stack(
                            children: [

                              /// ✅ IMAGE (NULL SAFE)
                              item['profile_image_url'] != null
                                  ? Image.network(
                                ApiService().getImageURL(item['profile_image_url']),
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "assets/images/Rectangle 34661070.png",
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                              ),

                              /// DARK GRADIENT
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 110,
                                  decoration: BoxDecoration(
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

                              /// ACTIVE
                      /*        Positioned(
                                top: 12,
                                left: 12,
                                child: Row(
                                  children: const [
                                    CircleAvatar(radius: 6, backgroundColor: Colors.green),
                                    SizedBox(width: 6),
                                    Text(
                                      "Active",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: "Outfit",
                                      ),
                                    )
                                  ],
                                ),
                              ),*/

                              /// ❤️ REMOVE FAVOURITE
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => _removeFavourite(
                                    creatorId: creatorId,
                                    index: index,
                                  ),
                                  child: Image.asset(
                                    "assets/Icons/Heart_Angl_COLOR.png",
                                    height: 22,
                                  ),
                                ),
                              ),

                              /// TEXT DATA
                              Positioned(
                                bottom: 20,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    /// ⭐ RATING (NULL SAFE)
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.yellow, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          item['rating'] != null
                                              ? "${item['rating']} (${item['total_reviews'] ?? 0})"
                                              : "No ratings",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ColorCode.kWhiteOpacity70,
                                            fontFamily: "Outfit",
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    /// NAME
                                    Text(
                                      item['name'] ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    /// ROLE (NULL SAFE)
                                    Text(
                                      item['primary_title'] ?? "Creative Professional",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: ColorCode.kWhiteOpacity70,
                                        fontFamily: "Outfit",
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// PRICE
                       /*       Positioned(
                                bottom: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ColorCode.kButtonColor,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    item['hourly_rate'] != null
                                        ? "From \$${item['hourly_rate']}/Hr"
                                        : "Price on request",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w600,
                                      color: ColorCode.kCircleGradientTop,
                                    ),
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    );
                  },

                ),
              ),
            ],
          ),
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
