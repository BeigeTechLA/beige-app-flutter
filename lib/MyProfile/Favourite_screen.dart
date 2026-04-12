import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../service/api_endpoints.dart';
import '../service/api_service.dart';
import '../utility/ColorCode.dart';
import '../widgets/loding.dart';

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

      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔙 BACK BUTTON
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/svg/back.svg",
                      height: 24,
                      color: ColorCode.white,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                /// 🏷 TITLE
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    " Favourites",
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorCode.white,
                    ),
                  ),
                ),



                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : favourites.isEmpty
                      ? const Center(
                    child: Text(
                      "No Favourite Data",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: favourites.length,
                    itemBuilder: (context, index) {
                      final item = favourites[index];

                      /// ✅ SAFE NULL HANDLING
                      final int? creatorId = item['crew_member_id'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 220,
                            child: Stack(
                              children: [
                                /// ✅ IMAGE SAFE
                                (item['profile_image_url'] != null &&
                                    item['profile_image_url']
                                        .toString()
                                        .isNotEmpty)
                                    ? Image.network(
                                  ApiService().getImageURL(
                                      item['profile_image_url']),
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                )
                                    : SvgPicture.asset(
                                  "assets/svg/imag_placeholder.svg",
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),

                                /// ❤️ REMOVE BUTTON
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (creatorId != null) {
                                        _removeFavourite(
                                          creatorId: creatorId,
                                          index: index,
                                        );
                                      } else {
                                        debugPrint("creator_id is NULL ❌");
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      "assets/svg/Heart_COLOR.svg",
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          if (isLoading)
            const AppLoader()
        ],

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